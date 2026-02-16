-- Sanity checks for PLANNING.USP_PROCESSBUDGETCONSOLIDATION output integrity
-- Assumes a successful run has been executed.

CALL PLANNING.SP_BuildCostCenterHierarchy(NULL, 10, FALSE, CURRENT_DATE());

-- IMPORTANT: Update these with the specific target budget and run ID for your given run
SET TARGET_ID = 502;
SET RUN_ID    = '129cd524-cd56-4c13-8677-6bf888f27558';

-- 1) Run wrote rows
SELECT COUNT(*) AS rows_for_run
FROM PLANNING.BUDGETLINEITEM
WHERE BudgetHeaderID = $TARGET_ID
  AND SourceReference = $RUN_ID;

-- 2) No NULL amounts inserted
SELECT COUNT(*) AS null_amount_rows
FROM PLANNING.BUDGETLINEITEM
WHERE BudgetHeaderID = $TARGET_ID
  AND SourceReference = $RUN_ID
  AND OriginalAmount IS NULL;

-- 3) Every row references a valid CostCenter + GLAccount + FiscalPeriod
SELECT COUNT(*) AS broken_fk_rows
FROM PLANNING.BUDGETLINEITEM bli
LEFT JOIN PLANNING.COSTCENTER cc   ON cc.CostCenterID = bli.CostCenterID
LEFT JOIN PLANNING.GLACCOUNT gla   ON gla.GLAccountID = bli.GLAccountID
LEFT JOIN PLANNING.FISCALPERIOD fp ON fp.FiscalPeriodID = bli.FiscalPeriodID
WHERE bli.BudgetHeaderID = $TARGET_ID
  AND bli.SourceReference = $RUN_ID
  AND (cc.CostCenterID IS NULL OR gla.GLAccountID IS NULL OR fp.FiscalPeriodID IS NULL);

-- 4) All inserted cost centers exist in hierarchy table (materialized universe)
SELECT COUNT(*) AS costcenters_missing_from_hierarchy
FROM (
  SELECT DISTINCT CostCenterID
  FROM PLANNING.BUDGETLINEITEM
  WHERE BudgetHeaderID = $TARGET_ID
    AND SourceReference = $RUN_ID
) x
LEFT JOIN HIERARCHY_TABLE ht
  ON ht.CostCenterID = x.CostCenterID
WHERE ht.CostCenterID IS NULL;

-- 5) No duplicate rows at the intended grain (GL, CostCenter, Period) within the run
-- (This should hold because you aggregate into CONSOLIDATED_AMOUNTS keyed by those 3 fields.)
SELECT
  GLAccountID, CostCenterID, FiscalPeriodID,
  COUNT(*) AS cnt
FROM PLANNING.BUDGETLINEITEM
WHERE BudgetHeaderID = $TARGET_ID
  AND SourceReference = $RUN_ID
GROUP BY 1,2,3
HAVING COUNT(*) > 1
ORDER BY cnt DESC;

-- 6) Quick run metadata check: output rows labeled consistently
SELECT
  MIN(SourceSystem) AS min_sourcesystem,
  MAX(SourceSystem) AS max_sourcesystem,
  MIN(SpreadMethodCode) AS min_spreadmethod,
  MAX(SpreadMethodCode) AS max_spreadmethod
FROM PLANNING.BUDGETLINEITEM
WHERE BudgetHeaderID = $TARGET_ID
  AND SourceReference = $RUN_ID;

-- 7) Header linkage exists (target ties back to source)
SELECT
  BudgetHeaderID,
  BaseBudgetHeaderID,
  BudgetType,
  StatusCode
FROM PLANNING.BUDGETHEADER
WHERE BudgetHeaderID = $TARGET_ID;
