CREATE OR REPLACE PROCEDURE PLANNING.USP_PROCESSBUDGETCONSOLIDATION(
    SOURCE_BUDGET_HEADER_ID     INT,
    TARGET_BUDGET_HEADER_ID     INT,                -- pass NULL to create a new one
    CONSOLIDATION_TYPE          STRING,             -- 'FULL', 'INCREMENTAL', 'DELTA' (currently informational)
    INCLUDE_ELIMINATIONS        BOOLEAN,
    RECALCULATE_ALLOCATIONS     BOOLEAN,
    PROCESSING_OPTIONS          VARIANT,            -- replaces XML; may be NULL
    USER_ID                     INT,
    DEBUG_MODE                  BOOLEAN
)
RETURNS VARIANT
LANGUAGE SQL
EXECUTE AS CALLER
AS
$$
DECLARE
    v_proc_start      TIMESTAMP_NTZ;
    v_step_start      TIMESTAMP_NTZ;
    v_step            STRING;
    v_rows_processed  INT DEFAULT 0;
    v_target_id       INT;
    v_run_id          STRING;
    v_msg             STRING;

    -- Optional processing options
    v_include_zero_balances BOOLEAN DEFAULT TRUE;
    v_rounding_precision    INT DEFAULT NULL;

    -- Counters
    v_cnt    INT DEFAULT 0;
    v_ins    INT DEFAULT 0;
    v_elim   INT DEFAULT 0;
    v_upd    INT DEFAULT 0;
    v_added  INT DEFAULT 0;

BEGIN
    v_proc_start := CURRENT_TIMESTAMP();
    v_run_id := UUID_STRING();
    v_target_id := TARGET_BUDGET_HEADER_ID;

    -- -------------------------
    -- TEMP tables (table vars)
    -- -------------------------
    CREATE OR REPLACE TEMP TABLE PROCESSING_LOG (
        LOG_ID        INT AUTOINCREMENT,
        STEP_NAME     STRING,
        START_TIME    TIMESTAMP_NTZ,
        END_TIME      TIMESTAMP_NTZ,
        ROWS_AFFECTED INT,
        STATUS_CODE   STRING,
        MESSAGE       STRING
    );

    CREATE OR REPLACE TEMP TABLE CONSOLIDATED_AMOUNTS (
        GLACCOUNTID        INT NOT NULL,
        COSTCENTERID       INT NOT NULL,
        FISCALPERIODID     INT NOT NULL,
        CONSOLIDATEDAMOUNT NUMBER(19,4) NOT NULL,
        ELIMINATIONAMOUNT  NUMBER(19,4) DEFAULT 0,
        FINALAMOUNT        NUMBER(19,4),
        SOURCECOUNT        INT,
        PRIMARY KEY (GLACCOUNTID, COSTCENTERID, FISCALPERIODID)
    );

    CREATE OR REPLACE TEMP TABLE INSERTED_LINES (
        BUDGETLINEITEMID   NUMBER,
        GLACCOUNTID        INT,
        COSTCENTERID       INT,
        FISCALPERIODID     INT,
        AMOUNT             NUMBER(19,4)
    );

    -- -------------------------
    -- Step: Parameter Validation
    -- -------------------------
    v_step := 'Parameter Validation';
    v_step_start := CURRENT_TIMESTAMP();

    IF (:SOURCE_BUDGET_HEADER_ID IS NULL) THEN
        v_msg := 'SOURCE_BUDGET_HEADER_ID cannot be NULL';
        INSERT INTO PROCESSING_LOG(STEP_NAME, START_TIME, END_TIME, ROWS_AFFECTED, STATUS_CODE, MESSAGE)
        VALUES (:v_step, :v_step_start, CURRENT_TIMESTAMP(), 0, 'ERROR', :v_msg);
        RETURN OBJECT_CONSTRUCT('status','ERROR','step',v_step,'message',v_msg);
    END IF;

    SELECT COUNT(*)
      INTO :v_cnt
    FROM PLANNING.BUDGETHEADER
    WHERE BUDGETHEADERID = :SOURCE_BUDGET_HEADER_ID;

    IF (v_cnt = 0) THEN
        v_msg := 'Source budget header not found: ' || SOURCE_BUDGET_HEADER_ID::STRING;
        INSERT INTO PROCESSING_LOG(STEP_NAME, START_TIME, END_TIME, ROWS_AFFECTED, STATUS_CODE, MESSAGE)
        VALUES (:v_step, :v_step_start, CURRENT_TIMESTAMP(), 0, 'ERROR', :v_msg);
        RETURN OBJECT_CONSTRUCT('status','ERROR','step',v_step,'message',v_msg);
    END IF;

    SELECT COUNT(*)
      INTO :v_cnt
    FROM PLANNING.BUDGETHEADER
    WHERE BUDGETHEADERID = :SOURCE_BUDGET_HEADER_ID
      AND STATUSCODE NOT IN ('APPROVED','LOCKED');

    IF (v_cnt > 0) THEN
        v_msg := 'Source budget must be APPROVED or LOCKED for consolidation';
        INSERT INTO PROCESSING_LOG(STEP_NAME, START_TIME, END_TIME, ROWS_AFFECTED, STATUS_CODE, MESSAGE)
        VALUES (:v_step, :v_step_start, CURRENT_TIMESTAMP(), 0, 'ERROR', :v_msg);
        RETURN OBJECT_CONSTRUCT('status','ERROR','step',v_step,'message',v_msg);
    END IF;

    INSERT INTO PROCESSING_LOG(STEP_NAME, START_TIME, END_TIME, ROWS_AFFECTED, STATUS_CODE, MESSAGE)
    VALUES (:v_step, :v_step_start, CURRENT_TIMESTAMP(), 0, 'COMPLETED', NULL);

    -- -------------------------
    -- Step: Parse Processing Options (VARIANT)
    -- -------------------------
    v_step := 'Parse Processing Options';
    v_step_start := CURRENT_TIMESTAMP();

    IF (:PROCESSING_OPTIONS IS NOT NULL) THEN

        -- IncludeZeroBalances: accept boolean OR string OR number
        v_include_zero_balances :=
            COALESCE(
                IFF(TYPEOF(PROCESSING_OPTIONS:"IncludeZeroBalances") = 'BOOLEAN',
                    PROCESSING_OPTIONS:"IncludeZeroBalances"::BOOLEAN,
                    TRY_TO_BOOLEAN(PROCESSING_OPTIONS:"IncludeZeroBalances"::STRING)
                ),
                TRUE
            );

        -- RoundingPrecision: accept number OR string
        v_rounding_precision :=
            IFF(TYPEOF(PROCESSING_OPTIONS:"RoundingPrecision") IN ('INTEGER','FIXED','NUMBER'),
                PROCESSING_OPTIONS:"RoundingPrecision"::INT,
                TRY_TO_NUMBER(PROCESSING_OPTIONS:"RoundingPrecision"::STRING)::INT
            );

    END IF;

    v_msg := OBJECT_CONSTRUCT(
        'IncludeZeroBalances', v_include_zero_balances,
        'RoundingPrecision',  v_rounding_precision
    )::STRING;

    INSERT INTO PROCESSING_LOG(STEP_NAME, START_TIME, END_TIME, ROWS_AFFECTED, STATUS_CODE, MESSAGE)
    VALUES (:v_step, :v_step_start, CURRENT_TIMESTAMP(), 0, 'COMPLETED', :v_msg);

    -- Step: Create Target Budget
    v_step := 'Create Target Budget';
    v_step_start := CURRENT_TIMESTAMP();

    IF (:v_target_id IS NULL) THEN
        -- Generate the new ID up-front (safe + deterministic)
        SELECT PLANNING.BUDGETHEADERID_SEQ.NEXTVAL
            INTO :v_target_id;

        INSERT INTO PLANNING.BUDGETHEADER (
            BudgetHeaderID,
            BudgetCode, BudgetName, BudgetType, ScenarioType, FiscalYear,
            StartPeriodID, EndPeriodID, BaseBudgetHeaderID, StatusCode,
            IsLocked,
            VersionNumber, ExtendedProperties,
            CreatedDateTime, ModifiedDateTime
        )
        SELECT
            :v_target_id,
            bh.BudgetCode || '_CONSOL_' || TO_CHAR(CURRENT_DATE(), 'YYYYMMDD'),
            bh.BudgetName || ' - Consolidated',
            'CONSOLIDATED',
            bh.ScenarioType,
            bh.FiscalYear,
            bh.StartPeriodID,
            bh.EndPeriodID,
            bh.BudgetHeaderID,
            'DRAFT',
            0,                -- IsLocked: new draft target should be unlocked
            1,
            OBJECT_CONSTRUCT(
                'ConsolidationRun',
                OBJECT_CONSTRUCT(
                    'RunID', :v_run_id,
                    'SourceID', :SOURCE_BUDGET_HEADER_ID,
                    'Timestamp', :v_proc_start
                ),
                'PriorExtendedProperties', bh.ExtendedProperties
            )::STRING,
            CURRENT_TIMESTAMP(),
            CURRENT_TIMESTAMP()
        FROM PLANNING.BUDGETHEADER bh
        WHERE bh.BudgetHeaderID = :SOURCE_BUDGET_HEADER_ID;
    END IF;

    -- If caller provided TARGET_BUDGET_HEADER_ID, ensure it exists
    SELECT COUNT(*)
    INTO :v_cnt
    FROM PLANNING.BUDGETHEADER
    WHERE BudgetHeaderID = :v_target_id;

    IF (v_cnt = 0) THEN
        v_msg := 'Target budget header not found: ' || :v_target_id::STRING;
        INSERT INTO PROCESSING_LOG(STEP_NAME, START_TIME, END_TIME, ROWS_AFFECTED, STATUS_CODE, MESSAGE)
        VALUES (:v_step, :v_step_start, CURRENT_TIMESTAMP(), 0, 'ERROR', :v_msg);
        RETURN OBJECT_CONSTRUCT('status','ERROR','step',v_step,'message',v_msg);
    END IF;


    INSERT INTO PROCESSING_LOG(STEP_NAME, START_TIME, END_TIME, ROWS_AFFECTED, STATUS_CODE, MESSAGE)
    VALUES (:v_step, :v_step_start, CURRENT_TIMESTAMP(), 1, 'COMPLETED', 'TargetBudgetHeaderID='||:v_target_id::STRING);

    -- -------------------------
    -- Step: Build Hierarchy
    -- -------------------------
    v_step := 'Build Hierarchy';
    v_step_start := CURRENT_TIMESTAMP();

    CALL PLANNING.SP_BuildCostCenterHierarchy(NULL, 10, FALSE, CURRENT_DATE());

    SELECT COUNT(*)
      INTO :v_cnt
    FROM HIERARCHY_TABLE;

    INSERT INTO PROCESSING_LOG(STEP_NAME, START_TIME, END_TIME, ROWS_AFFECTED, STATUS_CODE, MESSAGE)
    VALUES (:v_step, :v_step_start, CURRENT_TIMESTAMP(), :v_cnt, 'COMPLETED', 'HIERARCHY_TABLE created');

    -- -------------------------
    -- Step: Build Hierarchy Closure (boundary-safe)
    -- -------------------------
    v_step := 'Build Hierarchy Closure';
    v_step_start := CURRENT_TIMESTAMP();

    CREATE OR REPLACE TEMP TABLE HIERARCHY_CLOSURE AS
    SELECT
      anc.CostCenterID AS AncestorCostCenterID,
      des.CostCenterID AS DescendantCostCenterID
    FROM HIERARCHY_TABLE anc
    JOIN HIERARCHY_TABLE des
      ON des.SortPath = anc.SortPath
      OR des.SortPath LIKE anc.SortPath || '/%';

    SELECT COUNT(*) INTO :v_cnt FROM HIERARCHY_CLOSURE;

    INSERT INTO PROCESSING_LOG(STEP_NAME, START_TIME, END_TIME, ROWS_AFFECTED, STATUS_CODE, MESSAGE)
    VALUES (:v_step, :v_step_start, CURRENT_TIMESTAMP(), :v_cnt, 'COMPLETED', 'HIERARCHY_CLOSURE created');

    -- -------------------------
    -- Step: Hierarchy Consolidation (set-based)
    -- -------------------------
    v_step := 'Hierarchy Consolidation';
    v_step_start := CURRENT_TIMESTAMP();

    INSERT INTO CONSOLIDATED_AMOUNTS (GLACCOUNTID, COSTCENTERID, FISCALPERIODID, CONSOLIDATEDAMOUNT, SOURCECOUNT)
    WITH agg AS (
        SELECT
            bli.GLAccountID,
            c.AncestorCostCenterID AS CostCenterID,
            bli.FiscalPeriodID,
            SUM(bli.FinalAmount) AS Amount,
            COUNT(*) AS SourceCnt
        FROM PLANNING.BUDGETLINEITEM bli
        JOIN HIERARCHY_CLOSURE c
          ON c.DescendantCostCenterID = bli.CostCenterID
        WHERE bli.BudgetHeaderID = :SOURCE_BUDGET_HEADER_ID
        GROUP BY 1,2,3
    )
    SELECT
        GLAccountID,
        CostCenterID,
        FiscalPeriodID,
        Amount::NUMBER(19,4),
        SourceCnt
    FROM agg;

    SELECT COUNT(*) INTO :v_ins FROM CONSOLIDATED_AMOUNTS;

    INSERT INTO PROCESSING_LOG(STEP_NAME, START_TIME, END_TIME, ROWS_AFFECTED, STATUS_CODE, MESSAGE)
    VALUES (:v_step, :v_step_start, CURRENT_TIMESTAMP(), :v_ins, 'COMPLETED', NULL);

    -- -------------------------
    -- Step: Intercompany Eliminations (set-based)
    -- -------------------------
    IF (:INCLUDE_ELIMINATIONS = TRUE) THEN
        v_step := 'Intercompany Eliminations';
        v_step_start := CURRENT_TIMESTAMP();

        CREATE OR REPLACE TEMP TABLE ELIM_PAIRS AS
        WITH ic AS (
            SELECT
                bli.GLAccountID,
                bli.CostCenterID,
                bli.FiscalPeriodID,
                bli.FinalAmount::NUMBER(19,4) AS Amt,
                ROW_NUMBER() OVER (
                    PARTITION BY bli.GLAccountID, bli.CostCenterID, bli.FiscalPeriodID
                    ORDER BY bli.BudgetLineItemID
                ) AS rn
            FROM PLANNING.BUDGETLINEITEM bli
            JOIN PLANNING.GLACCOUNT gla
              ON gla.GLACCOUNTID = bli.GLACCOUNTID
            WHERE bli.BudgetHeaderID = :SOURCE_BUDGET_HEADER_ID
              AND gla.IntercompanyFlag = 1
        ),
        paired AS (
            SELECT
                a.GLAccountID,
                a.CostCenterID,
                a.FiscalPeriodID,
                a.Amt AS ElimAmt
            FROM ic a
            JOIN ic b
              ON b.GLAccountID = a.GLAccountID
             AND b.CostCenterID = a.CostCenterID
             AND b.FiscalPeriodID = a.FiscalPeriodID
             AND b.rn = a.rn + 1
            WHERE a.Amt <> 0
              AND b.Amt = -a.Amt
        )
        SELECT * FROM paired;

        UPDATE CONSOLIDATED_AMOUNTS ca
        SET ELIMINATIONAMOUNT = ca.ELIMINATIONAMOUNT + e.ElimAmt
        FROM ELIM_PAIRS e
        WHERE ca.GLACCOUNTID = e.GLACCOUNTID
          AND ca.COSTCENTERID = e.COSTCENTERID
          AND ca.FISCALPERIODID = e.FISCALPERIODID;

        SELECT COUNT(*) INTO :v_elim FROM ELIM_PAIRS;

        INSERT INTO PROCESSING_LOG(STEP_NAME, START_TIME, END_TIME, ROWS_AFFECTED, STATUS_CODE, MESSAGE)
        VALUES (:v_step, :v_step_start, CURRENT_TIMESTAMP(), :v_elim, 'COMPLETED', NULL);
    END IF;

    -- -------------------------
    -- Step: Recalculate Allocations / FinalAmount
    -- -------------------------
    IF (:RECALCULATE_ALLOCATIONS = TRUE) THEN
        v_step := 'Recalculate Allocations';
        v_step_start := CURRENT_TIMESTAMP();

        UPDATE CONSOLIDATED_AMOUNTS
        SET FINALAMOUNT =
            IFF(
                :v_rounding_precision IS NULL,
                (CONSOLIDATEDAMOUNT - ELIMINATIONAMOUNT),
                ROUND((CONSOLIDATEDAMOUNT - ELIMINATIONAMOUNT), :v_rounding_precision)
            );

        IF (v_include_zero_balances = FALSE) THEN
            DELETE FROM CONSOLIDATED_AMOUNTS
            WHERE COALESCE(FINALAMOUNT, 0) = 0;
        END IF;

        SELECT COUNT(*) INTO :v_upd FROM CONSOLIDATED_AMOUNTS;

        INSERT INTO PROCESSING_LOG(STEP_NAME, START_TIME, END_TIME, ROWS_AFFECTED, STATUS_CODE, MESSAGE)
        VALUES (:v_step, :v_step_start, CURRENT_TIMESTAMP(), :v_upd, 'COMPLETED', NULL);
    ELSE
        UPDATE CONSOLIDATED_AMOUNTS
        SET FINALAMOUNT = (CONSOLIDATEDAMOUNT - ELIMINATIONAMOUNT);
    END IF;

    -- -------------------------
    -- Step: Insert Results (final line items)
    -- -------------------------
    v_step := 'Insert Results';
    v_step_start := CURRENT_TIMESTAMP();

    INSERT INTO PLANNING.BUDGETLINEITEM (
        BudgetLineItemID,
        BudgetHeaderID, GLAccountID, CostCenterID, FiscalPeriodID,
        OriginalAmount, AdjustedAmount, SpreadMethodCode, SourceSystem, SourceReference,
        IsAllocated, LastModifiedByUserID, LastModifiedDateTime
    )
    SELECT
        PLANNING.BUDGETLINEITEMID_SEQ.NEXTVAL,
        :v_target_id,
        ca.GLACCOUNTID,
        ca.COSTCENTERID,
        ca.FISCALPERIODID,
        ca.FINALAMOUNT,
        0,
        'CONSOLIDATED',
        'CONSOLIDATION_PROC',
        :v_run_id,
        FALSE,
        :USER_ID,
        CURRENT_TIMESTAMP()
    FROM CONSOLIDATED_AMOUNTS ca
    WHERE ca.FINALAMOUNT IS NOT NULL;

    SELECT COUNT(*)
      INTO :v_added
    FROM PLANNING.BUDGETLINEITEM
    WHERE BudgetHeaderID = :v_target_id
      AND SourceReference = :v_run_id;

    v_rows_processed := v_added;

    INSERT INTO PROCESSING_LOG(STEP_NAME, START_TIME, END_TIME, ROWS_AFFECTED, STATUS_CODE, MESSAGE)
    VALUES (:v_step, :v_step_start, CURRENT_TIMESTAMP(), :v_rows_processed, 'COMPLETED', NULL);

    IF (:DEBUG_MODE = TRUE) THEN
        RETURN OBJECT_CONSTRUCT(
            'status', 'OK',
            'SourceBudgetHeaderID', :SOURCE_BUDGET_HEADER_ID,
            'TargetBudgetHeaderID', :v_target_id,
            'RunID', :v_run_id,
            'RowsProcessed', v_rows_processed,
            'ProcessingLog',
              (SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*)) WITHIN GROUP (ORDER BY LOG_ID) FROM PROCESSING_LOG)
        );
    END IF;

    RETURN OBJECT_CONSTRUCT(
        'status', 'OK',
        'SourceBudgetHeaderID', SOURCE_BUDGET_HEADER_ID,
        'TargetBudgetHeaderID', v_target_id,
        'RunID', v_run_id,
        'RowsProcessed', v_rows_processed
    );

EXCEPTION
  WHEN OTHER THEN

    INSERT INTO PROCESSING_LOG(STEP_NAME, START_TIME, END_TIME, ROWS_AFFECTED, STATUS_CODE, MESSAGE)
    SELECT
      COALESCE(:v_step, '(unknown)'),
      COALESCE(:v_step_start, CURRENT_TIMESTAMP()),
      CURRENT_TIMESTAMP(),
      0,
      'ERROR',
      OBJECT_CONSTRUCT(
        'SQLSTATE', :SQLSTATE,
        'SQLCODE',  :SQLCODE,
        'SQLERRM',  :SQLERRM,
        'LAST_QUERY_ID', LAST_QUERY_ID()
      )::STRING;

    IF (DEBUG_MODE = TRUE) THEN
    RETURN OBJECT_CONSTRUCT(
        'status','ERROR',
        'step', COALESCE(v_step,'(unknown)'),
        'sqlstate', SQLSTATE,
        'sqlcode',  SQLCODE,
        'sqlerrm',  SQLERRM,
        'last_query_id', LAST_QUERY_ID(),
        'ProcessingLog',
        (SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*)) WITHIN GROUP (ORDER BY LOG_ID)
        FROM PROCESSING_LOG)
    );
    END IF;

    RETURN OBJECT_CONSTRUCT(
    'status','ERROR',
    'step', COALESCE(v_step,'(unknown)'),
    'sqlstate', SQLSTATE,
    'sqlcode',  SQLCODE,
    'sqlerrm',  SQLERRM,
    'last_query_id', LAST_QUERY_ID()
    );
END;
$$;
