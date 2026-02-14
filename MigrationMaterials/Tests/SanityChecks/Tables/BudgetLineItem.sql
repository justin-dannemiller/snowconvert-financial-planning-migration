-- Expected: all result counts = 0 unless otherwise stated.

-- 1) Row count (informational)
SELECT 'BudgetLineItem' AS table_name, COUNT(*) AS row_count
FROM PLANNING.BUDGETLINEITEM;

-- 2) Primary key uniqueness
SELECT COUNT(*) - COUNT(DISTINCT BudgetLineItemID) AS duplicate_budgetlineitem_ids
FROM PLANNING.BUDGETLINEITEM;

-- 3) FK coverage: BudgetHeaderID
SELECT COUNT(*) AS missing_budgetheader
FROM PLANNING.BUDGETLINEITEM bli
LEFT JOIN PLANNING.BUDGETHEADER bh ON bh.BudgetHeaderID = bli.BudgetHeaderID
WHERE bh.BudgetHeaderID IS NULL;

-- 4) FK coverage: GLAccountID
SELECT COUNT(*) AS missing_glaccount
FROM PLANNING.BUDGETLINEITEM bli
LEFT JOIN PLANNING.GLACCOUNT ga ON ga.GLAccountID = bli.GLAccountID
WHERE ga.GLAccountID IS NULL;

-- 5) FK coverage: CostCenterID
SELECT COUNT(*) AS missing_costcenter
FROM PLANNING.BUDGETLINEITEM bli
LEFT JOIN PLANNING.COSTCENTER cc ON cc.CostCenterID = bli.CostCenterID
WHERE cc.CostCenterID IS NULL;

-- 6) FK coverage: FiscalPeriodID
SELECT COUNT(*) AS missing_fiscalperiod
FROM PLANNING.BUDGETLINEITEM bli
LEFT JOIN PLANNING.FISCALPERIOD fp ON fp.FiscalPeriodID = bli.FiscalPeriodID
WHERE fp.FiscalPeriodID IS NULL;

-- 7) AllocationSourceLineID (self-reference style) should exist if present
SELECT COUNT(*) AS missing_allocation_source_line
FROM PLANNING.BUDGETLINEITEM bli
LEFT JOIN PLANNING.BUDGETLINEITEM src ON src.BudgetLineItemID = bli.AllocationSourceLineID
WHERE bli.AllocationSourceLineID IS NOT NULL
  AND src.BudgetLineItemID IS NULL;

-- 8) Amount sanity: allow negatives if business permits, but flag extreme values (informational)
SELECT
  MIN(OriginalAmount) AS min_original,
  MAX(OriginalAmount) AS max_original,
  MIN(AdjustedAmount) AS min_adjusted,
  MAX(AdjustedAmount) AS max_adjusted
FROM PLANNING.BUDGETLINEITEM;

-- 9) If AllocationPercentage should be 0..1 (or 0..100 depending on design)
-- Pick one; here we assume 0..1
SELECT COUNT(*) AS invalid_allocation_percentage
FROM PLANNING.BUDGETLINEITEM
WHERE AllocationPercentage IS NOT NULL
  AND (AllocationPercentage < 0 OR AllocationPercentage > 1);

-- 10) ImportBatchID format sanity (UUID-like) (informational)
SELECT COUNT(*) AS suspicious_importbatchid
FROM PLANNING.BUDGETLINEITEM
WHERE ImportBatchID IS NOT NULL
  AND LENGTH(ImportBatchID) <> 36;
