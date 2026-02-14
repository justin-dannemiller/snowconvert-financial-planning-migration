SELECT
  CONVERT(VARCHAR(50), BudgetHeaderID) AS BudgetHeaderID,
  CONVERT(VARCHAR(100), BudgetCode) AS BudgetCode,
  CONVERT(NVARCHAR(200), BudgetName) AS BudgetName,
  CONVERT(VARCHAR(50), BudgetType) AS BudgetType,
  CONVERT(VARCHAR(50), ScenarioType) AS ScenarioType,
  CONVERT(VARCHAR(50), FiscalYear) AS FiscalYear,
  CONVERT(VARCHAR(50), StartPeriodID) AS StartPeriodID,
  CONVERT(VARCHAR(50), EndPeriodID) AS EndPeriodID,
  CONVERT(VARCHAR(50), BaseBudgetHeaderID) AS BaseBudgetHeaderID,
  CONVERT(VARCHAR(50), StatusCode) AS StatusCode,
  CONVERT(VARCHAR(50), SubmittedByUserID) AS SubmittedByUserID,
  CONVERT(VARCHAR(33), SubmittedDateTime, 126) AS SubmittedDateTime,
  CONVERT(VARCHAR(50), ApprovedByUserID) AS ApprovedByUserID,
  CONVERT(VARCHAR(33), ApprovedDateTime, 126) AS ApprovedDateTime,
  CONVERT(VARCHAR(33), LockedDateTime, 126) AS LockedDateTime,
  CONVERT(VARCHAR(50), IsLocked) AS IsLocked,
  CONVERT(VARCHAR(50), VersionNumber) AS VersionNumber,
  CONVERT(NVARCHAR(MAX), Notes) AS Notes,
  CONVERT(NVARCHAR(MAX), ExtendedProperties) AS ExtendedProperties,
  CONVERT(VARCHAR(33), CreatedDateTime, 126) AS CreatedDateTime,
  CONVERT(VARCHAR(33), ModifiedDateTime, 126) AS ModifiedDateTime
FROM Planning.BudgetHeader
ORDER BY BudgetHeaderID;
