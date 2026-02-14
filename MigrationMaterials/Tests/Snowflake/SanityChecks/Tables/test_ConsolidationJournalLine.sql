-- ConsolidationJournalLine_SanityChecks.sql
-- Expected: all result counts = 0 unless otherwise stated.
-- Note: This table may be empty before running usp_ProcessBudgetConsolidation.

-- 1) Row count (informational)
SELECT 'ConsolidationJournalLine' AS table_name, COUNT(*) AS row_count
FROM PLANNING.CONSOLIDATIONJOURNALLINE;

-- 2) Primary key uniqueness
SELECT COUNT(*) - COUNT(DISTINCT JournalLineID) AS duplicate_journalline_ids
FROM PLANNING.CONSOLIDATIONJOURNALLINE;

-- 3) Unique (JournalID, LineNumber)
SELECT COUNT(*) AS duplicate_journal_line_numbers
FROM (
  SELECT JournalID, LineNumber
  FROM PLANNING.CONSOLIDATIONJOURNALLINE
  GROUP BY JournalID, LineNumber
  HAVING COUNT(*) > 1
);

-- 4) FK: JournalID exists
SELECT COUNT(*) AS missing_journal
FROM PLANNING.CONSOLIDATIONJOURNALLINE jl
LEFT JOIN PLANNING.CONSOLIDATIONJOURNAL j ON j.JournalID = jl.JournalID
WHERE j.JournalID IS NULL;

-- 5) FK: GLAccountID exists
SELECT COUNT(*) AS missing_glaccount
FROM PLANNING.CONSOLIDATIONJOURNALLINE jl
LEFT JOIN PLANNING.GLACCOUNT ga ON ga.GLAccountID = jl.GLAccountID
WHERE ga.GLAccountID IS NULL;

-- 6) FK: CostCenterID exists
SELECT COUNT(*) AS missing_costcenter
FROM PLANNING.CONSOLIDATIONJOURNALLINE jl
LEFT JOIN PLANNING.COSTCENTER cc ON cc.CostCenterID = jl.CostCenterID
WHERE cc.CostCenterID IS NULL;

-- 7) FK: AllocationRuleID exists
SELECT COUNT(*) AS missing_allocationrule
FROM PLANNING.CONSOLIDATIONJOURNALLINE jl
LEFT JOIN PLANNING.ALLOCATIONRULE ar ON ar.AllocationRuleID = jl.AllocationRuleID
WHERE jl.AllocationRuleID IS NOT NULL
  AND ar.AllocationRuleID IS NULL;

-- 8) Debit/Credit invariant from SQL Server CHECK:
-- - debit >= 0 and credit >= 0
-- - cannot have both debit > 0 and credit > 0
SELECT COUNT(*) AS debit_credit_violations
FROM PLANNING.CONSOLIDATIONJOURNALLINE
WHERE DebitAmount < 0
   OR CreditAmount < 0
   OR (DebitAmount > 0 AND CreditAmount > 0);

-- 9) NetAmount consistency (if you stored NetAmount)
SELECT COUNT(*) AS inconsistent_netamount
FROM PLANNING.CONSOLIDATIONJOURNALLINE
WHERE NetAmount <> (DebitAmount - CreditAmount);

-- 10) Currency code sanity (3 chars)
SELECT COUNT(*) AS suspicious_currency_codes
FROM PLANNING.CONSOLIDATIONJOURNALLINE
WHERE LocalCurrencyCode IS NULL
   OR LENGTH(LocalCurrencyCode) <> 3;
