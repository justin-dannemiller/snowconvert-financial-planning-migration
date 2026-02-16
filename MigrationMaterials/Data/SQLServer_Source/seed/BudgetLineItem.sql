-- Debug: show budget headers currently in the DB
SELECT BudgetHeaderID, BudgetCode, FiscalYear, VersionNumber, StatusCode
FROM Planning.BudgetHeader
ORDER BY BudgetHeaderID;

DECLARE @BudgetHeaderID INT =
(
    SELECT TOP 1 BudgetHeaderID
    FROM Planning.BudgetHeader
    WHERE BudgetCode = 'BUD25_BASE'
    ORDER BY BudgetHeaderID
);

IF @BudgetHeaderID IS NULL
BEGIN
    THROW 50010, 'BudgetLineItem seed failed: expected BudgetHeader BudgetCode=BUD25_BASE not found. Run BudgetHeader seed (or update BudgetCode) before BudgetLineItem.', 1;
END

PRINT CONCAT('Using @BudgetHeaderID = ', @BudgetHeaderID);


DECLARE @BudgetHeaderID INT = (SELECT TOP 1 BudgetHeaderID FROM Planning.BudgetHeader WHERE BudgetCode='BUD25_BASE');

DECLARE @Jan INT = (SELECT FiscalPeriodID FROM Planning.FiscalPeriod WHERE FiscalYear=2025 AND FiscalMonth=1);
DECLARE @Feb INT = (SELECT FiscalPeriodID FROM Planning.FiscalPeriod WHERE FiscalYear=2025 AND FiscalMonth=2);

DECLARE @Rev INT = (SELECT GLAccountID FROM Planning.GLAccount WHERE AccountNumber='4000');
DECLARE @Exp INT = (SELECT GLAccountID FROM Planning.GLAccount WHERE AccountNumber='5000');
DECLARE @ICR INT = (SELECT GLAccountID FROM Planning.GLAccount WHERE AccountNumber='1300');
DECLARE @ICP INT = (SELECT GLAccountID FROM Planning.GLAccount WHERE AccountNumber='2300');

DECLARE @US_WEST INT = (SELECT CostCenterID FROM Planning.CostCenter WHERE CostCenterCode='NWHUS-OPS-W');
DECLARE @US_EAST INT = (SELECT CostCenterID FROM Planning.CostCenter WHERE CostCenterCode='NWHUS-OPS-E');
DECLARE @DE_BER  INT = (SELECT CostCenterID FROM Planning.CostCenter WHERE CostCenterCode='NWHDE-OPS-BER');

DECLARE @US_IT_INF INT = (SELECT CostCenterID FROM Planning.CostCenter WHERE CostCenterCode='NWHUS-IT-INF');

INSERT INTO Planning.BudgetLineItem (
    BudgetHeaderID, GLAccountID, CostCenterID, FiscalPeriodID,
    OriginalAmount, AdjustedAmount,
    SpreadMethodCode, SourceSystem, SourceReference,
    ImportBatchID, IsAllocated, AllocationSourceLineID, AllocationPercentage,
    LastModifiedByUserID, LastModifiedDateTime
)
VALUES
    -- ------------------------------------------------------------
    -- Baseline rows (SourceSystem=SEED)
    -- ------------------------------------------------------------
    (@BudgetHeaderID, @Rev, @US_WEST, @Jan,  250000.00, 0.00, 'MANUAL', 'SEED', 'JAN25_US_WEST_REV_BASE', NULL, 0, NULL, NULL, NULL, SYSUTCDATETIME()),
    (@BudgetHeaderID, @Exp, @US_WEST, @Jan,  -90000.00, 0.00, 'MANUAL', 'SEED', 'JAN25_US_WEST_OPEX_BASE', NULL, 0, NULL, NULL, NULL, SYSUTCDATETIME()),
    (@BudgetHeaderID, @Rev, @US_EAST, @Jan,  180000.00, 0.00, 'MANUAL', 'SEED', 'JAN25_US_EAST_REV_BASE', NULL, 0, NULL, NULL, NULL, SYSUTCDATETIME()),
    (@BudgetHeaderID, @Exp, @US_EAST, @Jan,  -70000.00, 0.00, 'MANUAL', 'SEED', 'JAN25_US_EAST_OPEX_BASE', NULL, 0, NULL, NULL, NULL, SYSUTCDATETIME()),

    -- Realistic intercompany balances across entities (not guaranteed to "pair" in your current elim logic)
    (@BudgetHeaderID, @ICR, @US_WEST, @Feb,   15000.00, 0.00, 'MANUAL', 'SEED', 'FEB25_US_WEST_ICR_BASE', NULL, 0, NULL, NULL, NULL, SYSUTCDATETIME()),
    (@BudgetHeaderID, @ICP, @DE_BER,  @Feb,  -14500.00, 0.00, 'MANUAL', 'SEED', 'FEB25_DE_BER_ICP_BASE',  NULL, 0, NULL, NULL, NULL, SYSUTCDATETIME()),

    -- ------------------------------------------------------------
    -- Coverage rows (SourceSystem=SEED_TEST)
    -- ------------------------------------------------------------

    -- Guaranteed elimination pair for your current Snowflake matching logic:
    -- SAME (BudgetHeaderID, GLAccountID, CostCenterID, FiscalPeriodID) partition, opposite amounts, adjacent insert.
    (@BudgetHeaderID, @ICR, @US_EAST, @Feb,   1000.00, 0.00, 'MANUAL', 'SEED_TEST', 'FEB25_US_EAST_ICR_ADJ__ELIMPAIR_A', NULL, 0, NULL, NULL, NULL, SYSUTCDATETIME()),
    (@BudgetHeaderID, @ICR, @US_EAST, @Feb,  -1000.00, 0.00, 'MANUAL', 'SEED_TEST', 'FEB25_US_EAST_ICR_ADJ__ELIMPAIR_B', NULL, 0, NULL, NULL, NULL, SYSUTCDATETIME()),

    -- RoundingPrecision test (unique natural key): -10.005 rounds differently at precision=2
    (@BudgetHeaderID, @Exp, @US_EAST, @Feb,    -10.005, 0.00, 'MANUAL', 'SEED_TEST', 'FEB25_US_EAST_OPEX_ADJ__ROUNDING', NULL, 0, NULL, NULL, NULL, SYSUTCDATETIME()),

    -- Optional: extra descendant row to strengthen rollup breadth without violating natural key
    (@BudgetHeaderID, @Rev, @US_IT_INF, @Jan,  12000.00, 0.00, 'MANUAL', 'SEED_TEST', 'JAN25_US_IT_REV__ROLLUP_EXTRA', NULL, 0, NULL, NULL, NULL, SYSUTCDATETIME());
