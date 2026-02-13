-- Minimal GL account set
;WITH Seed AS (
    SELECT * FROM (VALUES
        ('4000','Product Revenue','R',NULL,NULL,1,1,1,0,0,'C','USD',NULL,0,1),
        ('5000','Operating Expense','E',NULL,NULL,1,1,1,0,0,'D','USD',NULL,0,1),

        -- Intercompany pair: receivable vs payable
        ('1300','Intercompany Receivable','A',NULL,NULL,1,1,1,0,0,'D','USD',NULL,1,1),
        ('2300','Intercompany Payable','L',NULL,NULL,1,1,1,0,0,'C','USD',NULL,1,1)
    ) AS t(
        AccountNumber, AccountName, AccountType, AccountSubType, ParentAccountNumber,
        AccountLevel, IsPostable, IsBudgetable, IsStatistical, Dummy0,
        NormalBalance, CurrencyCode, IFRSAccountCode, IntercompanyFlag, IsActive
    )
)
-- Insert rows that don't exist
INSERT INTO Planning.GLAccount (
    AccountNumber, AccountName, AccountType, AccountSubType, ParentAccountID,
    AccountLevel, IsPostable, IsBudgetable, IsStatistical, NormalBalance, CurrencyCode,
    ConsolidationAccountID, IntercompanyFlag, IsActive, CreatedDateTime, ModifiedDateTime,
    TaxCode, StatutoryAccountCode, IFRSAccountCode
)
SELECT
    s.AccountNumber, s.AccountName, s.AccountType, s.AccountSubType, NULL,
    s.AccountLevel, s.IsPostable, s.IsBudgetable, s.IsStatistical, s.NormalBalance, s.CurrencyCode,
    NULL, s.IntercompanyFlag, s.IsActive, SYSUTCDATETIME(), SYSUTCDATETIME(),
    NULL, NULL, s.IFRSAccountCode
FROM Seed s
WHERE NOT EXISTS (
    SELECT 1 FROM Planning.GLAccount a WHERE a.AccountNumber = s.AccountNumber
);

-- Wire up consolidation mapping for intercompany accounts (only if not set)
UPDATE a
SET ConsolidationAccountID = b.GLAccountID
FROM Planning.GLAccount a
JOIN Planning.GLAccount b ON
    (a.AccountNumber='1300' AND b.AccountNumber='2300')
 OR (a.AccountNumber='2300' AND b.AccountNumber='1300')
WHERE a.IntercompanyFlag = 1
  AND a.ConsolidationAccountID IS NULL;
