-- Expected: all result counts = 0 unless otherwise stated.

-- 1) Row count (informational)
SELECT 'BudgetHeader' AS table_name, COUNT(*) AS row_count
FROM PLANNING.BUDGETHEADER;

-- 2) Primary key uniqueness
SELECT COUNT(*) - COUNT(DISTINCT BudgetHeaderID) AS duplicate_budgetheader_ids
FROM PLANNING.BUDGETHEADER;

-- 3) Unique (BudgetCode, FiscalYear, VersionNumber)
SELECT COUNT(*) AS duplicate_budgetcode_year_version
FROM (
  SELECT BudgetCode, FiscalYear, VersionNumber
  FROM PLANNING.BUDGETHEADER
  GROUP BY BudgetCode, FiscalYear, VersionNumber
  HAVING COUNT(*) > 1
);

-- 4) FK: StartPeriodID exists
SELECT COUNT(*) AS missing_start_period
FROM PLANNING.BUDGETHEADER bh
LEFT JOIN PLANNING.FISCALPERIOD fp ON fp.FiscalPeriodID = bh.StartPeriodID
WHERE fp.FiscalPeriodID IS NULL;

-- 5) FK: EndPeriodID exists
SELECT COUNT(*) AS missing_end_period
FROM PLANNING.BUDGETHEADER bh
LEFT JOIN PLANNING.FISCALPERIOD fp ON fp.FiscalPeriodID = bh.EndPeriodID
WHERE fp.FiscalPeriodID IS NULL;

-- 6) Period ordering (StartPeriodID <= EndPeriodID)
SELECT COUNT(*) AS invalid_period_range
FROM PLANNING.BUDGETHEADER
WHERE StartPeriodID > EndPeriodID;

-- 7) Status domain check
SELECT COUNT(*) AS invalid_status
FROM PLANNING.BUDGETHEADER
WHERE StatusCode NOT IN ('DRAFT','SUBMITTED','APPROVED','REJECTED','LOCKED','ARCHIVED');

-- 8) BaseBudgetHeaderID (self-FK) integrity
SELECT COUNT(*) AS missing_base_budget
FROM PLANNING.BUDGETHEADER bh
LEFT JOIN PLANNING.BUDGETHEADER base ON base.BudgetHeaderID = bh.BaseBudgetHeaderID
WHERE bh.BaseBudgetHeaderID IS NOT NULL
  AND base.BudgetHeaderID IS NULL;

-- 9) IsLocked semantics check (if stored as INT and derived from LockedDateTime)
-- Adjust if you stored as BOOLEAN.
SELECT COUNT(*) AS inconsistent_islocked
FROM PLANNING.BUDGETHEADER
WHERE (LockedDateTime IS NULL AND IsLocked <> 0)
   OR (LockedDateTime IS NOT NULL AND IsLocked <> 1);
