SELECT
  CONVERT(VARCHAR(50), GLAccountID) AS GLAccountID,
  CONVERT(VARCHAR(50), AccountNumber) AS AccountNumber,
  CONVERT(NVARCHAR(200), AccountName) AS AccountName,
  CONVERT(VARCHAR(10), AccountType) AS AccountType,
  CONVERT(VARCHAR(200), AccountSubType) AS AccountSubType,
  CONVERT(VARCHAR(50), ParentAccountID) AS ParentAccountID,
  CONVERT(VARCHAR(50), AccountLevel) AS AccountLevel,
  CASE WHEN IsPostable = 1 THEN '1' ELSE '0' END AS IsPostable,
  CASE WHEN IsBudgetable = 1 THEN '1' ELSE '0' END AS IsBudgetable,
  CASE WHEN IsStatistical = 1 THEN '1' ELSE '0' END AS IsStatistical,
  CONVERT(VARCHAR(10), NormalBalance) AS NormalBalance,
  CONVERT(VARCHAR(10), CurrencyCode) AS CurrencyCode,
  CONVERT(VARCHAR(50), ConsolidationAccountID) AS ConsolidationAccountID,
  CASE WHEN IntercompanyFlag = 1 THEN '1' ELSE '0' END AS IntercompanyFlag,
  CASE WHEN IsActive = 1 THEN '1' ELSE '0' END AS IsActive,
  CONVERT(VARCHAR(33), CreatedDateTime, 126) AS CreatedDateTime,
  CONVERT(VARCHAR(33), ModifiedDateTime, 126) AS ModifiedDateTime,
  CONVERT(VARCHAR(200), TaxCode) AS TaxCode,
  CONVERT(VARCHAR(200), StatutoryAccountCode) AS StatutoryAccountCode,
  CONVERT(VARCHAR(200), IFRSAccountCode) AS IFRSAccountCode
FROM Planning.GLAccount
ORDER BY GLAccountID;
