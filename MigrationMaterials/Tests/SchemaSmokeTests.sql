-- ============================================================
-- Schema Smoke Test
-- Purpose: Verify migrated Planning schema objects exist and
--          are queryable before data load or validation.
-- ============================================================

-- 1) Verify schema exists
SHOW SCHEMAS LIKE 'PLANNING';

-- 2) Verify core tables exist
SHOW TABLES IN SCHEMA PLANNING;

-- 3) Describe core tables (metadata validation only)
DESC TABLE PLANNING.FISCALPERIOD;
DESC TABLE PLANNING.GLACCOUNT;
DESC TABLE PLANNING.COSTCENTER;
DESC TABLE PLANNING.BUDGETHEADER;
DESC TABLE PLANNING.BUDGETLINEITEM;
DESC TABLE PLANNING.ALLOCATIONRULE;
DESC TABLE PLANNING.CONSOLIDATIONJOURNAL;
DESC TABLE PLANNING.CONSOLIDATIONJOURNALLINE;

-- 4) Minimal queryability check (returns 0 rows pre-load, but must not error)
SELECT COUNT(*) AS fiscal_period_row_count FROM PLANNING.FISCALPERIOD;
SELECT COUNT(*) AS gl_account_row_count    FROM PLANNING.GLACCOUNT;
SELECT COUNT(*) AS cost_center_row_count   FROM PLANNING.COSTCENTER;
SELECT COUNT(*) AS budget_header_row_count FROM PLANNING.BUDGETHEADER;
SELECT COUNT(*) AS line_item_row_count     FROM PLANNING.BUDGETLINEITEM;

-- 5) Optional: View compilation check (if views already migrated)
-- SELECT COUNT(*) FROM PLANNING.VW_BUDGETCONSOLIDATIONSUMMARY;
