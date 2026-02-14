-- Tests/Snowflake/SanityChecks/Views/test_vw_BudgetConsolidationSummary.sql
-- Goal: sanity-check that the view aggregates BudgetLineItem correctly.

-- 1) Does it return rows?
SELECT COUNT(*) AS view_rowcount
FROM PLANNING.VW_BUDGETCONSOLIDATIONSUMMARY;

-- 2) Uniqueness check on the "indexed view" key (should be 0 duplicates)
SELECT
  BudgetHeaderID, GLAccountID, CostCenterID, FiscalPeriodID,
  COUNT(*) AS cnt
FROM PLANNING.VW_BUDGETCONSOLIDATIONSUMMARY
GROUP BY 1,2,3,4
HAVING COUNT(*) > 1
ORDER BY cnt DESC;

-- 3) Pick a few random keys and recompute directly from BudgetLineItem to compare
-- (Should return 0 rows if everything matches)
WITH sample_keys AS (
  SELECT BudgetHeaderID, GLAccountID, CostCenterID, FiscalPeriodID
  FROM PLANNING.VW_BUDGETCONSOLIDATIONSUMMARY
  QUALIFY ROW_NUMBER() OVER (ORDER BY RANDOM()) <= 25
),
recalc AS (
  SELECT
    bli.BudgetHeaderID,
    bli.GLAccountID,
    bli.CostCenterID,
    bli.FiscalPeriodID,
    SUM(bli.OriginalAmount) AS TotalOriginalAmount,
    SUM(bli.AdjustedAmount) AS TotalAdjustedAmount,
    SUM(bli.OriginalAmount + bli.AdjustedAmount) AS TotalFinalAmount,
    SUM(COALESCE(bli.LocalCurrencyAmount, 0)) AS TotalLocalCurrency,
    SUM(COALESCE(bli.ReportingCurrencyAmount, 0)) AS TotalReportingCurrency,
    COUNT(*) AS LineItemCount
  FROM PLANNING.BUDGETLINEITEM bli
  JOIN sample_keys k
    ON k.BudgetHeaderID = bli.BudgetHeaderID
   AND k.GLAccountID = bli.GLAccountID
   AND k.CostCenterID = bli.CostCenterID
   AND k.FiscalPeriodID = bli.FiscalPeriodID
  GROUP BY 1,2,3,4
)
SELECT
  v.BudgetHeaderID, v.GLAccountID, v.CostCenterID, v.FiscalPeriodID,
  v.TotalFinalAmount AS view_final,
  r.TotalFinalAmount AS calc_final,
  v.LineItemCount AS view_cnt,
  r.LineItemCount AS calc_cnt
FROM PLANNING.VW_BUDGETCONSOLIDATIONSUMMARY v
JOIN recalc r
  ON v.BudgetHeaderID = r.BudgetHeaderID
 AND v.GLAccountID = r.GLAccountID
 AND v.CostCenterID = r.CostCenterID
 AND v.FiscalPeriodID = r.FiscalPeriodID
WHERE
     v.TotalOriginalAmount       <> r.TotalOriginalAmount
  OR v.TotalAdjustedAmount       <> r.TotalAdjustedAmount
  OR v.TotalFinalAmount          <> r.TotalFinalAmount
  OR v.TotalLocalCurrency        <> r.TotalLocalCurrency
  OR v.TotalReportingCurrency    <> r.TotalReportingCurrency
  OR v.LineItemCount             <> r.LineItemCount;

-- 4) Global reconciliation: sum of totals across the view should equal the base table sums
-- (These two SELECTs should match)
SELECT
  SUM(TotalOriginalAmount) AS view_sum_original,
  SUM(TotalAdjustedAmount) AS view_sum_adjusted,
  SUM(TotalFinalAmount)    AS view_sum_final,
  SUM(TotalLocalCurrency)  AS view_sum_local,
  SUM(TotalReportingCurrency) AS view_sum_reporting,
  SUM(LineItemCount)       AS view_sum_line_count
FROM PLANNING.VW_BUDGETCONSOLIDATIONSUMMARY;

SELECT
  SUM(OriginalAmount) AS base_sum_original,
  SUM(AdjustedAmount) AS base_sum_adjusted,
  SUM(OriginalAmount + AdjustedAmount) AS base_sum_final,
  SUM(COALESCE(LocalCurrencyAmount, 0)) AS base_sum_local,
  SUM(COALESCE(ReportingCurrencyAmount, 0)) AS base_sum_reporting,
  COUNT(*) AS base_line_count
FROM PLANNING.BUDGETLINEITEM;
