DECLARE @BudgetHeaderID INT = (SELECT TOP 1 BudgetHeaderID FROM Planning.BudgetHeader WHERE BudgetCode='BUDGET_2025_BASE');

DECLARE @Jan INT = (SELECT FiscalPeriodID FROM Planning.FiscalPeriod WHERE FiscalYear=2025 AND FiscalMonth=1);
DECLARE @Feb INT = (SELECT FiscalPeriodID FROM Planning.FiscalPeriod WHERE FiscalYear=2025 AND FiscalMonth=2);

DECLARE @Rev INT = (SELECT GLAccountID FROM Planning.GLAccount WHERE AccountNumber='4000');
DECLARE @Exp INT = (SELECT GLAccountID FROM Planning.GLAccount WHERE AccountNumber='5000');
DECLARE @ICR INT = (SELECT GLAccountID FROM Planning.GLAccount WHERE AccountNumber='1300');
DECLARE @ICP INT = (SELECT GLAccountID FROM Planning.GLAccount WHERE AccountNumber='2300');

-- Leaf/team cost centers
DECLARE @US_WEST INT = (SELECT CostCenterID FROM Planning.CostCenter WHERE CostCenterCode='NWHUS-OPS-W');
DECLARE @US_EAST INT = (SELECT CostCenterID FROM Planning.CostCenter WHERE CostCenterCode='NWHUS-OPS-E');
DECLARE @DE_BER  INT = (SELECT CostCenterID FROM Planning.CostCenter WHERE CostCenterCode='NWHDE-OPS-BER');


INSERT INTO Planning.BudgetLineItem (
    BudgetHeaderID, GLAccountID, CostCenterID, FiscalPeriodID,
    OriginalAmount, AdjustedAmount,
    SpreadMethodCode, SourceSystem, SourceReference,
    ImportBatchID, IsAllocated, AllocationSourceLineID, AllocationPercentage,
    LastModifiedByUserID, LastModifiedDateTime
)
SELECT *
FROM (VALUES
    -- Revenue & expense
    (@BudgetHeaderID, @Rev, @US_WEST, @Jan,  250000.00, 0.00, 'MANUAL', 'SEED', 'seed-1', NULL, 0, NULL, NULL, NULL, SYSUTCDATETIME()),
    (@BudgetHeaderID, @Exp, @US_WEST, @Jan,  -90000.00, 0.00, 'MANUAL', 'SEED', 'seed-2', NULL, 0, NULL, NULL, NULL, SYSUTCDATETIME()),
    (@BudgetHeaderID, @Rev, @US_EAST, @Jan,  180000.00, 0.00, 'MANUAL', 'SEED', 'seed-3', NULL, 0, NULL, NULL, NULL, SYSUTCDATETIME()),
    (@BudgetHeaderID, @Exp, @US_EAST, @Jan,  -70000.00, 0.00, 'MANUAL', 'SEED', 'seed-4', NULL, 0, NULL, NULL, NULL, SYSUTCDATETIME()),

    -- Intercompany example (US receivable vs DE payable; not perfectly offset so reconciliation has variance)
    (@BudgetHeaderID, @ICR, @US_WEST, @Feb,   15000.00, 0.00, 'MANUAL', 'SEED', 'seed-ic-1', NULL, 0, NULL, NULL, NULL, SYSUTCDATETIME()),
    (@BudgetHeaderID, @ICP, @DE_BER,  @Feb,  -14500.00, 0.00, 'MANUAL', 'SEED', 'seed-ic-2', NULL, 0, NULL, NULL, NULL, SYSUTCDATETIME())
) v(
    BudgetHeaderID, GLAccountID, CostCenterID, FiscalPeriodID,
    OriginalAmount, AdjustedAmount,
    SpreadMethodCode, SourceSystem, SourceReference,
    ImportBatchID, IsAllocated, AllocationSourceLineID, AllocationPercentage,
    LastModifiedByUserID, LastModifiedDateTime
)
WHERE NOT EXISTS (
    SELECT 1
    FROM Planning.BudgetLineItem bli
    WHERE bli.BudgetHeaderID = v.BudgetHeaderID
      AND bli.GLAccountID = v.GLAccountID
      AND bli.CostCenterID = v.CostCenterID
      AND bli.FiscalPeriodID = v.FiscalPeriodID
);
