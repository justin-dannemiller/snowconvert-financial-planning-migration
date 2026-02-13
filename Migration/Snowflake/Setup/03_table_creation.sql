-- FISCALPERIOD
CREATE OR REPLACE TABLE PUBLIC.FISCALPERIOD (
    FiscalPeriodID       NUMBER(38,0) NOT NULL,
    FiscalYear           NUMBER(38,0) NOT NULL,
    FiscalQuarter        NUMBER(38,0) NOT NULL,
    FiscalMonth          NUMBER(38,0) NOT NULL,
    PeriodName           VARCHAR(50)  NOT NULL,
    PeriodStartDate      DATE         NOT NULL,
    PeriodEndDate        DATE         NOT NULL,
    IsClosed             BOOLEAN      NOT NULL DEFAULT FALSE,
    ClosedByUserID       NUMBER(38,0),
    ClosedDateTime       TIMESTAMP_NTZ,
    IsAdjustmentPeriod   BOOLEAN      NOT NULL DEFAULT FALSE,
    WorkingDays          NUMBER(38,0),
    CreatedDateTime      TIMESTAMP_NTZ NOT NULL DEFAULT CURRENT_TIMESTAMP(),
    ModifiedDateTime     TIMESTAMP_NTZ NOT NULL DEFAULT CURRENT_TIMESTAMP(),
    RowVersionStamp      TIMESTAMP_NTZ NOT NULL DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT PK_FiscalPeriod PRIMARY KEY (FiscalPeriodID),
    CONSTRAINT UQ_FiscalPeriod_YearMonth UNIQUE (FiscalYear, FiscalMonth)
);


-- Cost Center
CREATE OR REPLACE TABLE SNOWFLAKE_LEARNING_DB.PUBLIC.COSTCENTER (
    CostCenterID           NUMBER(38,0) NOT NULL,
    CostCenterCode         VARCHAR(50)   NOT NULL,
    CostCenterName         VARCHAR(200)  NOT NULL,

    ParentCostCenterID     NUMBER(38,0),

    -- Materialized path hierarchy (Option A)
    Hierarchy_Path         VARCHAR(500),      -- e.g. '/1/3/7/'
    Hierarchy_Level        NUMBER(38,0),       -- root = 0 or 1 (your choice, just be consistent)

    ManagerEmployeeID      NUMBER(38,0),
    DepartmentCode         VARCHAR(50),

    IsActive               BOOLEAN       NOT NULL,
    EffectiveFromDate      DATE          NOT NULL,
    EffectiveToDate        DATE,

    AllocationWeight       NUMBER(19,4)  NOT NULL,

    ValidFrom              TIMESTAMP_NTZ NOT NULL,
    ValidTo                TIMESTAMP_NTZ NOT NULL,

    CONSTRAINT PK_CostCenter PRIMARY KEY (CostCenterID)
);

-- GLAccount
CREATE OR REPLACE TABLE SNOWFLAKE_LEARNING_DB.PUBLIC.GLACCOUNT (
    GLAccountID             NUMBER(38,0) NOT NULL,               -- load SQL Server IDs as-is
    AccountNumber           VARCHAR(20)  NOT NULL,
    AccountName             VARCHAR(150) NOT NULL,
    AccountType             VARCHAR(1)   NOT NULL,               -- 'A','L','E','R','X'
    AccountSubType          VARCHAR(30),
    ParentAccountID         NUMBER(38,0),

    AccountLevel            NUMBER(38,0) NOT NULL DEFAULT 1,
    IsPostable              BOOLEAN      NOT NULL DEFAULT TRUE,
    IsBudgetable            BOOLEAN      NOT NULL DEFAULT TRUE,
    IsStatistical           BOOLEAN      NOT NULL DEFAULT FALSE,

    NormalBalance           VARCHAR(1)   NOT NULL DEFAULT 'D',    -- 'D' or 'C'
    CurrencyCode            VARCHAR(3)   NOT NULL DEFAULT 'USD',
    ConsolidationAccountID  NUMBER(38,0),

    IntercompanyFlag        BOOLEAN      NOT NULL DEFAULT FALSE,
    IsActive                BOOLEAN      NOT NULL DEFAULT TRUE,

    CreatedDateTime         TIMESTAMP_NTZ NOT NULL DEFAULT CURRENT_TIMESTAMP(),
    ModifiedDateTime        TIMESTAMP_NTZ NOT NULL DEFAULT CURRENT_TIMESTAMP(),

    -- SPARSE columns -> just nullable columns in Snowflake
    TaxCode                 VARCHAR(20),
    StatutoryAccountCode    VARCHAR(30),
    IFRSAccountCode         VARCHAR(30),

    CONSTRAINT PK_GLAccount PRIMARY KEY (GLAccountID),
    CONSTRAINT UQ_GLAccount_Number UNIQUE (AccountNumber)
);


-- BudgetHeader
CREATE OR REPLACE TABLE SNOWFLAKE_LEARNING_DB.PUBLIC.BUDGETHEADER (
    BudgetHeaderID         NUMBER(38,0) NOT NULL,               -- load SQL Server IDs as-is
    BudgetCode             VARCHAR(30)  NOT NULL,
    BudgetName             VARCHAR(100) NOT NULL,
    BudgetType             VARCHAR(20)  NOT NULL,
    ScenarioType           VARCHAR(20)  NOT NULL,
    FiscalYear             NUMBER(38,0) NOT NULL,
    StartPeriodID          NUMBER(38,0) NOT NULL,
    EndPeriodID            NUMBER(38,0) NOT NULL,
    BaseBudgetHeaderID     NUMBER(38,0),

    StatusCode             VARCHAR(15)  NOT NULL DEFAULT 'DRAFT',
    SubmittedByUserID      NUMBER(38,0),
    SubmittedDateTime      TIMESTAMP_NTZ,
    ApprovedByUserID       NUMBER(38,0),
    ApprovedDateTime       TIMESTAMP_NTZ,
    LockedDateTime         TIMESTAMP_NTZ,

    -- SQL Server computed persisted column -> store a real column in Snowflake
    -- We'll set it during load (or maintain via ETL) as (LockedDateTime IS NOT NULL)
    IsLocked               BOOLEAN      NOT NULL DEFAULT FALSE,

    VersionNumber          NUMBER(38,0) NOT NULL DEFAULT 1,
    Notes                  VARCHAR,

    -- XML -> VARIANT (we can keep raw XML text or parse later)
    ExtendedProperties     VARIANT,

    CreatedDateTime        TIMESTAMP_NTZ NOT NULL DEFAULT CURRENT_TIMESTAMP(),
    ModifiedDateTime       TIMESTAMP_NTZ NOT NULL DEFAULT CURRENT_TIMESTAMP(),

    CONSTRAINT PK_BudgetHeader PRIMARY KEY (BudgetHeaderID),
    CONSTRAINT UQ_BudgetHeader_Code_Year UNIQUE (BudgetCode, FiscalYear, VersionNumber)
);


-- BudgetLineItem
CREATE OR REPLACE TABLE SNOWFLAKE_LEARNING_DB.PUBLIC.BUDGETLINEITEM (
    BudgetLineItemID        NUMBER(38,0) NOT NULL,                 -- load SQL Server IDs as-is
    BudgetHeaderID          NUMBER(38,0) NOT NULL,
    GLAccountID             NUMBER(38,0) NOT NULL,
    CostCenterID            NUMBER(38,0) NOT NULL,
    FiscalPeriodID          NUMBER(38,0) NOT NULL,

    OriginalAmount          NUMBER(19,4) NOT NULL DEFAULT 0,
    AdjustedAmount          NUMBER(19,4) NOT NULL DEFAULT 0,

    -- SQL Server persisted computed -> stored column in Snowflake
    FinalAmount             NUMBER(19,4),

    LocalCurrencyAmount     NUMBER(19,4),
    ReportingCurrencyAmount NUMBER(19,4),
    StatisticalQuantity     NUMBER(18,6),
    UnitOfMeasure           VARCHAR(10),

    SpreadMethodCode        VARCHAR(10),
    SeasonalityFactor       NUMBER(8,6),

    SourceSystem            VARCHAR(30),
    SourceReference         VARCHAR(100),
    ImportBatchID           VARCHAR(36),

    IsAllocated             BOOLEAN      NOT NULL DEFAULT FALSE,
    AllocationSourceLineID  NUMBER(38,0),
    AllocationPercentage    NUMBER(8,6),

    LastModifiedByUserID    NUMBER(38,0),
    LastModifiedDateTime    TIMESTAMP_NTZ NOT NULL DEFAULT CURRENT_TIMESTAMP(),

    -- Store hash (32 bytes) - populated during load or post-load update
    RowHash                 BINARY(32),

    CONSTRAINT PK_BudgetLineItem PRIMARY KEY (BudgetLineItemID)
);

-- ALllocationRule
CREATE OR REPLACE TABLE SNOWFLAKE_LEARNING_DB.PUBLIC.ALLOCATIONRULE (
    AllocationRuleID        NUMBER(38,0) NOT NULL,
    RuleCode                VARCHAR(30)  NOT NULL,
    RuleName                VARCHAR(100) NOT NULL,
    RuleDescription         VARCHAR(500),
    RuleType                VARCHAR(20)  NOT NULL,     -- DIRECT, STEP_DOWN, RECIPROCAL, ACTIVITY_BASED
    AllocationMethod        VARCHAR(20)  NOT NULL,     -- FIXED_PCT, HEADCOUNT, ...

    SourceCostCenterID      NUMBER(38,0),
    SourceCostCenterPattern VARCHAR(50),
    SourceAccountPattern    VARCHAR(50),

    -- XML -> VARIANT (store parsed XML or raw text; we'll load as string/variant)
    TargetSpecification     VARIANT      NOT NULL,

    AllocationBasis         VARCHAR(30),
    AllocationPercentage    NUMBER(8,6),
    RoundingMethod          VARCHAR(10)  NOT NULL DEFAULT 'NEAREST',
    RoundingPrecision       NUMBER(38,0) NOT NULL DEFAULT 2,
    MinimumAmount           NUMBER(19,4),

    ExecutionSequence       NUMBER(38,0) NOT NULL DEFAULT 100,
    DependsOnRuleID         NUMBER(38,0),

    EffectiveFromDate       DATE         NOT NULL,
    EffectiveToDate         DATE,
    IsActive                BOOLEAN      NOT NULL DEFAULT TRUE,

    CreatedByUserID         NUMBER(38,0),
    CreatedDateTime         TIMESTAMP_NTZ NOT NULL DEFAULT CURRENT_TIMESTAMP(),
    ModifiedByUserID        NUMBER(38,0),
    ModifiedDateTime        TIMESTAMP_NTZ NOT NULL DEFAULT CURRENT_TIMESTAMP(),

    CONSTRAINT PK_AllocationRule PRIMARY KEY (AllocationRuleID),
    CONSTRAINT UQ_AllocationRule_Code UNIQUE (RuleCode)
);

-- ConsolidationJournal
CREATE OR REPLACE TABLE SNOWFLAKE_LEARNING_DB.PUBLIC.CONSOLIDATIONJOURNAL (
    JournalID              NUMBER(38,0) NOT NULL,
    JournalNumber          VARCHAR(30)  NOT NULL,
    JournalType            VARCHAR(20)  NOT NULL,

    BudgetHeaderID         NUMBER(38,0) NOT NULL,
    FiscalPeriodID         NUMBER(38,0) NOT NULL,
    PostingDate            DATE         NOT NULL,

    Description            VARCHAR(500),

    StatusCode             VARCHAR(15)  NOT NULL DEFAULT 'DRAFT',

    SourceEntityCode       VARCHAR(20),
    TargetEntityCode       VARCHAR(20),

    IsAutoReverse          BOOLEAN      NOT NULL DEFAULT FALSE,
    ReversalPeriodID       NUMBER(38,0),
    ReversedFromJournalID  NUMBER(38,0),
    IsReversed             BOOLEAN      NOT NULL DEFAULT FALSE,

    TotalDebits            NUMBER(19,4) NOT NULL DEFAULT 0,
    TotalCredits           NUMBER(19,4) NOT NULL DEFAULT 0,

    -- SQL Server computed column -> store a real column in Snowflake
    IsBalanced             BOOLEAN      NOT NULL DEFAULT FALSE,

    PreparedByUserID       NUMBER(38,0),
    PreparedDateTime       TIMESTAMP_NTZ,
    ReviewedByUserID       NUMBER(38,0),
    ReviewedDateTime       TIMESTAMP_NTZ,
    ApprovedByUserID       NUMBER(38,0),
    ApprovedDateTime       TIMESTAMP_NTZ,
    PostedByUserID         NUMBER(38,0),
    PostedDateTime         TIMESTAMP_NTZ,

    -- FILESTREAM/attachments: store bytes directly (or store a URL to stage/external storage)
    AttachmentData         BINARY,

    -- ROWGUIDCOL + NEWSEQUENTIALID() -> UUID string with default
    AttachmentRowGuid      STRING       NOT NULL DEFAULT UUID_STRING(),

    CONSTRAINT PK_ConsolidationJournal PRIMARY KEY (JournalID),
    CONSTRAINT UQ_ConsolidationJournal_Number UNIQUE (JournalNumber),
    CONSTRAINT UQ_ConsolidationJournal_RowGuid UNIQUE (AttachmentRowGuid)
);


CREATE OR REPLACE TABLE SNOWFLAKE_LEARNING_DB.PUBLIC.CONSOLIDATIONJOURNALLINE (
    JournalLineID           NUMBER(38,0) NOT NULL,
    JournalID               NUMBER(38,0) NOT NULL,
    LineNumber              NUMBER(38,0) NOT NULL,

    GLAccountID             NUMBER(38,0) NOT NULL,
    CostCenterID            NUMBER(38,0) NOT NULL,

    DebitAmount             NUMBER(19,4) NOT NULL DEFAULT 0,
    CreditAmount            NUMBER(19,4) NOT NULL DEFAULT 0,

    -- SQL Server persisted computed -> stored column in Snowflake
    NetAmount               NUMBER(19,4),

    LocalCurrencyCode       VARCHAR(3)   NOT NULL DEFAULT 'USD',
    LocalCurrencyAmount     NUMBER(19,4),
    ExchangeRate            NUMBER(18,10),

    Description             VARCHAR(255),
    ReferenceNumber         VARCHAR(50),

    PartnerEntityCode       VARCHAR(20),
    PartnerAccountID        NUMBER(38,0),

    StatisticalQuantity     NUMBER(18,6),
    StatisticalUOM          VARCHAR(10),

    AllocationRuleID        NUMBER(38,0),

    CreatedDateTime         TIMESTAMP_NTZ NOT NULL DEFAULT CURRENT_TIMESTAMP(),

    CONSTRAINT PK_ConsolidationJournalLine PRIMARY KEY (JournalLineID),
    CONSTRAINT UQ_ConsolidationJournalLine_JournalLine UNIQUE (JournalID, LineNumber)
);
