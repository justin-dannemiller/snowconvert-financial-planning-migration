-- Expected: all result counts = 0 unless otherwise stated.

-- 1) Row count (informational)
SELECT 'GLAccount' AS table_name, COUNT(*) AS row_count
FROM PLANNING.GLACCOUNT;

-- 2) Primary key uniqueness
SELECT COUNT(*) - COUNT(DISTINCT GLAccountID) AS duplicate_glaccount_ids
FROM PLANNING.GLACCOUNT;

-- 3) Unique AccountNumber
SELECT COUNT(*) AS duplicate_account_numbers
FROM (
  SELECT AccountNumber
  FROM PLANNING.GLACCOUNT
  GROUP BY AccountNumber
  HAVING COUNT(*) > 1
);

-- 4) Domain checks: AccountType in ('A','L','E','R','X')
SELECT COUNT(*) AS invalid_account_type
FROM PLANNING.GLACCOUNT
WHERE AccountType NOT IN ('A','L','E','R','X');

-- 5) Domain checks: NormalBalance in ('D','C')
SELECT COUNT(*) AS invalid_normal_balance
FROM PLANNING.GLACCOUNT
WHERE NormalBalance NOT IN ('D','C');

-- 6) Self-referential FK integrity (ParentAccountID must exist if non-null)
SELECT COUNT(*) AS missing_parent_accounts
FROM PLANNING.GLACCOUNT c
LEFT JOIN PLANNING.GLACCOUNT p ON p.GLAccountID = c.ParentAccountID
WHERE c.ParentAccountID IS NOT NULL
  AND p.GLAccountID IS NULL;

-- 7) Simple hierarchy sanity: ParentAccountID should not equal self
SELECT COUNT(*) AS self_parent_rows
FROM PLANNING.GLACCOUNT
WHERE ParentAccountID = GLAccountID;

-- 8) Optional: account level sanity (>= 1)
SELECT COUNT(*) AS invalid_account_level
FROM PLANNING.GLACCOUNT
WHERE AccountLevel < 1;
