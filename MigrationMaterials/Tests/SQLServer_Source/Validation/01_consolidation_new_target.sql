DECLARE @SourceBudgetHeaderID INT = 
(
  SELECT TOP 1 BudgetHeaderID
  FROM Planning.BudgetHeader
  WHERE BudgetCode = 'BUD25_BASE'
);

DECLARE @TargetBudgetHeaderID INT = NULL;  -- force create new target
DECLARE @RowsProcessed INT = NULL;
DECLARE @ErrorMessage NVARCHAR(4000) = NULL;
DECLARE @ReturnCode INT;

EXEC @ReturnCode = Planning.usp_ProcessBudgetConsolidation
    @SourceBudgetHeaderID   = @SourceBudgetHeaderID,
    @TargetBudgetHeaderID   = @TargetBudgetHeaderID OUTPUT,
    @ConsolidationType      = 'FULL',
    @IncludeEliminations    = 1,
    @RecalculateAllocations = 0,          -- IMPORTANT
    @ProcessingOptions      = NULL,
    @UserID                 = 1,
    @DebugMode              = 1,
    @RowsProcessed          = @RowsProcessed OUTPUT,
    @ErrorMessage           = @ErrorMessage OUTPUT;

SELECT
  @ReturnCode AS ReturnCode,
  @TargetBudgetHeaderID AS TargetBudgetHeaderID,
  @RowsProcessed AS RowsProcessed,
  @ErrorMessage AS ErrorMessage;
