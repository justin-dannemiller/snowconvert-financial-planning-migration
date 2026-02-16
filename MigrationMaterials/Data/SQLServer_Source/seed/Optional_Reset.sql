SET NOCOUNT ON;

BEGIN TRY
  BEGIN TRAN;

  -- Fact/child tables first
  DELETE FROM Planning.BudgetLineItem;
  DELETE FROM Planning.BudgetHeader;

  -- Dimensions
  DELETE FROM Planning.CostCenter;
  DELETE FROM Planning.GLAccount;
  DELETE FROM Planning.FiscalPeriod;

  COMMIT;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK;
  THROW;
END CATCH;
