-- =========================================================
-- Align Sequences to Existing Data (post-load)
-- =========================================================

-- -------------------------
-- BudgetHeaderID sequence
-- -------------------------
SET NEXT_BUDGETHEADER_ID = (
  SELECT COALESCE(MAX(BudgetHeaderID), 0) + 1
  FROM PLANNING.BUDGETHEADER
);

SET SQL_ALIGN_BUDGETHEADER =
  'CREATE OR REPLACE SEQUENCE PLANNING.BUDGETHEADERID_SEQ START = ' || $NEXT_BUDGETHEADER_ID || ' INCREMENT = 1';

EXECUTE IMMEDIATE $SQL_ALIGN_BUDGETHEADER;


-- -------------------------
-- BudgetLineItemID sequence
-- -------------------------
SET NEXT_BUDGETLINEITEM_ID = (
  SELECT COALESCE(MAX(BudgetLineItemID), 0) + 1
  FROM PLANNING.BUDGETLINEITEM
);

SET SQL_ALIGN_BUDGETLINEITEM =
  'CREATE OR REPLACE SEQUENCE PLANNING.BUDGETLINEITEMID_SEQ START = ' || $NEXT_BUDGETLINEITEM_ID || ' INCREMENT = 1';

EXECUTE IMMEDIATE $SQL_ALIGN_BUDGETLINEITEM;
