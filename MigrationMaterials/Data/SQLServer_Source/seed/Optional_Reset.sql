-- Optional reset (safe-ish order)
DELETE FROM Planning.BudgetLineItem;
DELETE FROM Planning.BudgetHeader;

-- Dimensions (only if you're sure nothing else depends on them)
DELETE FROM Planning.CostCenter;
DELETE FROM Planning.GLAccount;
DELETE FROM Planning.FiscalPeriod;
