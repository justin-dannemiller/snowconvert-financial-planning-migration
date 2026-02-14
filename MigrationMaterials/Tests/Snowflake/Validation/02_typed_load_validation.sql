-- FiscalPeriod Validation

-- Quick verification
SELECT COUNT(*) AS row_count FROM SNOWFLAKE_LEARNING_DB.PLANNING.FISCALPERIOD;

-- Parse-failure spot check (should be 0 if your raw is clean)
SELECT
  SUM(IFF(TRY_TO_NUMBER(FiscalPeriodID) IS NULL AND FiscalPeriodID IS NOT NULL, 1, 0)) AS bad_id,
  SUM(IFF(TRY_TO_DATE(PeriodStartDate) IS NULL AND PeriodStartDate IS NOT NULL, 1, 0)) AS bad_start_date,
  SUM(IFF(TRY_TO_TIMESTAMP_NTZ(CreatedDateTime) IS NULL AND CreatedDateTime IS NOT NULL, 1, 0)) AS bad_created_ts
FROM SNOWFLAKE_LEARNING_DB.PLANNING_STG.FISCALPERIOD_RAW;

-- GLAccount Validation
-- Quick verification
SELECT COUNT(*) AS row_count FROM SNOWFLAKE_LEARNING_DB.PLANNING.GLACCOUNT;

-- Optional: domain sanity (should return 0 rows if clean)
SELECT *
FROM SNOWFLAKE_LEARNING_DB.PLANNING.GLACCOUNT
WHERE AccountType NOT IN ('A','L','E','R','X')
   OR NormalBalance NOT IN ('D','C');


-- CostCenter Validation
-- Quick verification
SELECT COUNT(*) AS row_count FROM SNOWFLAKE_LEARNING_DB.PLANNING.COSTCENTER;

-- Parent reference sanity: children whose ParentCostCenterID doesn't exist (should be 0)
SELECT COUNT(*) AS orphan_parent_refs
FROM SNOWFLAKE_LEARNING_DB.PLANNING.COSTCENTER c
LEFT JOIN SNOWFLAKE_LEARNING_DB.PLANNING.COSTCENTER p
  ON c.ParentCostCenterID = p.CostCenterID
WHERE c.ParentCostCenterID IS NOT NULL
  AND p.CostCenterID IS NULL;

-- Hierarchy path sanity (optional): roots should be level 1 and have no parent
SELECT COUNT(*) AS suspicious_roots
FROM SNOWFLAKE_LEARNING_DB.PLANNING.COSTCENTER
WHERE HierarchyLevel = 1
  AND ParentCostCenterID IS NOT NULL;


-- BudgetHeader Validation
-- Quick verification
SELECT COUNT(*) AS row_count FROM SNOWFLAKE_LEARNING_DB.PLANNING.BUDGETHEADER;

-- Status domain sanity (should return 0 rows if clean)
SELECT COUNT(*) AS bad_status_codes
FROM SNOWFLAKE_LEARNING_DB.PLANNING.BUDGETHEADER
WHERE StatusCode NOT IN ('DRAFT','SUBMITTED','APPROVED','REJECTED','LOCKED','ARCHIVED');

-- FK sanity: Start/End periods must exist
SELECT COUNT(*) AS bad_start_period
FROM SNOWFLAKE_LEARNING_DB.PLANNING.BUDGETHEADER h
LEFT JOIN SNOWFLAKE_LEARNING_DB.PLANNING.FISCALPERIOD p
  ON h.StartPeriodID = p.FiscalPeriodID
WHERE p.FiscalPeriodID IS NULL;

SELECT COUNT(*) AS bad_end_period
FROM SNOWFLAKE_LEARNING_DB.PLANNING.BUDGETHEADER h
LEFT JOIN SNOWFLAKE_LEARNING_DB.PLANNING.FISCALPERIOD p
  ON h.EndPeriodID = p.FiscalPeriodID
WHERE p.FiscalPeriodID IS NULL;

-- BudgetLineItem Validation
-- Quick verification
SELECT COUNT(*) AS row_count FROM SNOWFLAKE_LEARNING_DB.PLANNING.BUDGETLINEITEM

-- Important validations:
-- 1) Natural key uniqueness (should be 0 duplicates)
SELECT COUNT(*) AS duplicate_natural_keys
FROM (
  SELECT BudgetHeaderID, GLAccountID, CostCenterID, FiscalPeriodID, COUNT(*) AS c
  FROM SNOWFLAKE_LEARNING_DB.PLANNING.BUDGETLINEITEM
  GROUP BY 1,2,3,4
  HAVING COUNT(*) > 1
);

-- 2) Orphan checks (should all be 0)
SELECT COUNT(*) AS orphan_headers
FROM SNOWFLAKE_LEARNING_DB.PLANNING.BUDGETLINEITEM li
LEFT JOIN SNOWFLAKE_LEARNING_DB.PLANNING.BUDGETHEADER h
  ON li.BudgetHeaderID = h.BudgetHeaderID
WHERE h.BudgetHeaderID IS NULL;

SELECT COUNT(*) AS orphan_accounts
FROM SNOWFLAKE_LEARNING_DB.PLANNING.BUDGETLINEITEM li
LEFT JOIN SNOWFLAKE_LEARNING_DB.PLANNING.GLACCOUNT a
  ON li.GLAccountID = a.GLAccountID
WHERE a.GLAccountID IS NULL;

SELECT COUNT(*) AS orphan_costcenters
FROM SNOWFLAKE_LEARNING_DB.PLANNING.BUDGETLINEITEM li
LEFT JOIN SNOWFLAKE_LEARNING_DB.PLANNING.COSTCENTER c
  ON li.CostCenterID = c.CostCenterID
WHERE c.CostCenterID IS NULL;

SELECT COUNT(*) AS orphan_periods
FROM SNOWFLAKE_LEARNING_DB.PLANNING.BUDGETLINEITEM li
LEFT JOIN SNOWFLAKE_LEARNING_DB.PLANNING.FISCALPERIOD p
  ON li.FiscalPeriodID = p.FiscalPeriodID
WHERE p.FiscalPeriodID IS NULL;