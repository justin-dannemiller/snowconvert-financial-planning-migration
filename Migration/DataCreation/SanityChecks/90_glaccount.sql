-- A1: Ensure the 4 accounts exist exactly once
SELECT AccountNumber, AccountName, AccountType, NormalBalance, IntercompanyFlag, IsActive, ConsolidationAccountID
FROM Planning.GLAccount
WHERE AccountNumber IN ('4000','5000','1300','2300')
ORDER BY AccountNumber;

-- A2: Ensure IC pair is wired both ways
SELECT
  a.AccountNumber,
  a.ConsolidationAccountID,
  b.AccountNumber AS PartnerAccountNumber
FROM Planning.GLAccount a
LEFT JOIN Planning.GLAccount b ON b.GLAccountID = a.ConsolidationAccountID
WHERE a.AccountNumber IN ('1300','2300')
ORDER BY a.AccountNumber;

-- A3: IC accounts must be flagged + have partner
SELECT AccountNumber, IntercompanyFlag, ConsolidationAccountID
FROM Planning.GLAccount
WHERE AccountNumber IN ('1300','2300')
  AND (IntercompanyFlag <> 1 OR ConsolidationAccountID IS NULL);
-- should return 0 rows
