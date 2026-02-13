DECLARE @BudgetHeaderID INT =
  (SELECT TOP 1 BudgetHeaderID FROM Planning.BudgetHeader WHERE BudgetCode='BUDGET_2025_BASE');

DECLARE @ICR INT = (SELECT GLAccountID FROM Planning.GLAccount WHERE AccountNumber='1300');
DECLARE @ICP INT = (SELECT GLAccountID FROM Planning.GLAccount WHERE AccountNumber='2300');

WITH X AS (
  SELECT
    LEFT(cc.CostCenterCode, CHARINDEX('-', cc.CostCenterCode + '-') - 1) AS EntityCode,
    ga.AccountNumber,
    SUM(bli.FinalAmount) AS Amt
  FROM Planning.BudgetLineItem bli
  JOIN Planning.CostCenter cc ON cc.CostCenterID = bli.CostCenterID
  JOIN Planning.GLAccount ga ON ga.GLAccountID = bli.GLAccountID
  WHERE bli.BudgetHeaderID = @BudgetHeaderID
    AND bli.GLAccountID IN (@ICR, @ICP)
  GROUP BY LEFT(cc.CostCenterCode, CHARINDEX('-', cc.CostCenterCode + '-') - 1), ga.AccountNumber
)
SELECT *
FROM X
ORDER BY EntityCode, AccountNumber;

-- Also show overall net across IC accounts (should be non-zero if you seeded mismatch)
WITH N AS (
  SELECT SUM(bli.FinalAmount) AS NetIC
  FROM Planning.BudgetLineItem bli
  WHERE bli.BudgetHeaderID = @BudgetHeaderID
    AND bli.GLAccountID IN (@ICR, @ICP)
)
SELECT NetIC FROM N;
