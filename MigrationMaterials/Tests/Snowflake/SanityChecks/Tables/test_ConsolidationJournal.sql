-- Expected: all result counts = 0 unless otherwise stated.
-- Note: This table may be empty before running usp_ProcessBudgetConsolidation.

-- 1) Row count (informational)
SELECT 'ConsolidationJournal' AS table_name, COUNT(*) AS row_count
FROM PLANNING.CONSOLIDATIONJOURNAL;

-- 2) Primary key uniqueness
SELECT COUNT(*) - COUNT(DISTINCT JournalID) AS duplicate_journal_ids
FROM PLANNING.CONSOLIDATIONJOURNAL;

-- 3) Unique JournalNumber
SELECT COUNT(*) AS duplicate_journal_numbers
FROM (
  SELECT JournalNumber
  FROM PLANNING.CONSOLIDATIONJOURNAL
  GROUP BY JournalNumber
  HAVING COUNT(*) > 1
);

-- 4) FK: BudgetHeaderID exists
SELECT COUNT(*) AS missing_budgetheader
FROM PLANNING.CONSOLIDATIONJOURNAL cj
LEFT JOIN PLANNING.BUDGETHEADER bh ON bh.BudgetHeaderID = cj.BudgetHeaderID
WHERE bh.BudgetHeaderID IS NULL;

-- 5) FK: FiscalPeriodID exists
SELECT COUNT(*) AS missing_fiscalperiod
FROM PLANNING.CONSOLIDATIONJOURNAL cj
LEFT JOIN PLANNING.FISCALPERIOD fp ON fp.FiscalPeriodID = cj.FiscalPeriodID
WHERE fp.FiscalPeriodID IS NULL;

-- 6) FK: ReversalPeriodID exists
SELECT COUNT(*) AS missing_reversalperiod
FROM PLANNING.CONSOLIDATIONJOURNAL cj
LEFT JOIN PLANNING.FISCALPERIOD fp ON fp.FiscalPeriodID = cj.ReversalPeriodID
WHERE cj.ReversalPeriodID IS NOT NULL
  AND fp.FiscalPeriodID IS NULL;

-- 7) FK: ReversedFromJournalID exists
SELECT COUNT(*) AS missing_reversedfrom
FROM PLANNING.CONSOLIDATIONJOURNAL cj
LEFT JOIN PLANNING.CONSOLIDATIONJOURNAL src ON src.JournalID = cj.ReversedFromJournalID
WHERE cj.ReversedFromJournalID IS NOT NULL
  AND src.JournalID IS NULL;

-- 8) Totals non-negative (optional: depends on business rules)
SELECT COUNT(*) AS negative_totals
FROM PLANNING.CONSOLIDATIONJOURNAL
WHERE TotalDebits < 0 OR TotalCredits < 0;

-- 9) IsBalanced consistency with totals (if stored boolean)
SELECT COUNT(*) AS inconsistent_isbalanced
FROM PLANNING.CONSOLIDATIONJOURNAL
WHERE (TotalDebits = TotalCredits AND IsBalanced <> TRUE)
   OR (TotalDebits <> TotalCredits AND IsBalanced <> FALSE);

-- 10) Status domain (if you want to enforce a set; adjust if proc uses others)
SELECT COUNT(*) AS invalid_status
FROM PLANNING.CONSOLIDATIONJOURNAL
WHERE StatusCode NOT IN ('DRAFT','POSTED','REVERSED','APPROVED','SUBMITTED');
