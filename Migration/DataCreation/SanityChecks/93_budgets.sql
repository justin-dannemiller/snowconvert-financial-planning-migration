-- D1: Base budget exists
SELECT BudgetHeaderID, BudgetCode, StatusCode, StartPeriodID, EndPeriodID
FROM Planning.BudgetHeader
WHERE BudgetCode = 'BUDGET_2025_BASE';

-- D2: No orphan FKs in line items (should be 0)
SELECT TOP 50 bli.BudgetLineItemID
FROM Planning.BudgetLineItem bli
LEFT JOIN Planning.BudgetHeader bh ON bh.BudgetHeaderID = bli.BudgetHeaderID
LEFT JOIN Planning.GLAccount ga ON ga.GLAccountID = bli.GLAccountID
LEFT JOIN Planning.CostCenter cc ON cc.CostCenterID = bli.CostCenterID
LEFT JOIN Planning.FiscalPeriod fp ON fp.FiscalPeriodID = bli.FiscalPeriodID
WHERE bh.BudgetHeaderID IS NULL OR ga.GLAccountID IS NULL OR cc.CostCenterID IS NULL OR fp.FiscalPeriodID IS NULL;

-- D3: Duplicate natural key within a budget (should be 0 unless you *allow* multiple lines)
SELECT BudgetHeaderID, GLAccountID, CostCenterID, FiscalPeriodID, COUNT(*) AS Cnt
FROM Planning.BudgetLineItem
GROUP BY BudgetHeaderID, GLAccountID, CostCenterID, FiscalPeriodID
HAVING COUNT(*) > 1;
