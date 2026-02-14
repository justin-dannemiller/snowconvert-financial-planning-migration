-- Views/vw_BudgetConsolidationSummary.sql
--
-- Source object (SQL Server):
--   Planning.vw_BudgetConsolidationSummary (indexed view via unique clustered index)
--
-- Snowflake migration approach:
--   Implemented as a logical VIEW. Snowflake does not support indexes in the same way;
--   if materialization is needed, this can be converted to a MATERIALIZED VIEW,
--   but semantics and refresh behavior differ from SQL Server indexed views.

CREATE OR REPLACE VIEW PLANNING.VW_BUDGETCONSOLIDATIONSUMMARY AS
SELECT 
    bh.BudgetHeaderID,
    bh.BudgetCode,
    bh.BudgetName,
    bh.BudgetType,
    bh.ScenarioType,
    bh.FiscalYear,

    fp.FiscalPeriodID,
    fp.FiscalQuarter,
    fp.FiscalMonth,
    fp.PeriodName,

    gla.GLAccountID,
    gla.AccountNumber,
    gla.AccountName,
    gla.AccountType,

    cc.CostCenterID,
    cc.CostCenterCode,
    cc.CostCenterName,
    cc.ParentCostCenterID,

    SUM(bli.OriginalAmount) AS TotalOriginalAmount,
    SUM(bli.AdjustedAmount) AS TotalAdjustedAmount,
    SUM(bli.OriginalAmount + bli.AdjustedAmount) AS TotalFinalAmount,
    SUM(COALESCE(bli.LocalCurrencyAmount, 0)) AS TotalLocalCurrency,
    SUM(COALESCE(bli.ReportingCurrencyAmount, 0)) AS TotalReportingCurrency,
    COUNT(*) AS LineItemCount
FROM PLANNING.BUDGETLINEITEM bli
JOIN PLANNING.BUDGETHEADER bh
  ON bli.BudgetHeaderID = bh.BudgetHeaderID
JOIN PLANNING.GLACCOUNT gla
  ON bli.GLAccountID = gla.GLAccountID
JOIN PLANNING.COSTCENTER cc
  ON bli.CostCenterID = cc.CostCenterID
JOIN PLANNING.FISCALPERIOD fp
  ON bli.FiscalPeriodID = fp.FiscalPeriodID
GROUP BY
    bh.BudgetHeaderID,
    bh.BudgetCode,
    bh.BudgetName,
    bh.BudgetType,
    bh.ScenarioType,
    bh.FiscalYear,
    fp.FiscalPeriodID,
    fp.FiscalQuarter,
    fp.FiscalMonth,
    fp.PeriodName,
    gla.GLAccountID,
    gla.AccountNumber,
    gla.AccountName,
    gla.AccountType,
    cc.CostCenterID,
    cc.CostCenterCode,
    cc.CostCenterName,
    cc.ParentCostCenterID;
