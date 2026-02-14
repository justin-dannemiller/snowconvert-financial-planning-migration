SELECT
  CONVERT(VARCHAR(50), FiscalPeriodID) AS FiscalPeriodID,
  CONVERT(VARCHAR(50), FiscalYear) AS FiscalYear,
  CONVERT(VARCHAR(50), FiscalQuarter) AS FiscalQuarter,
  CONVERT(VARCHAR(50), FiscalMonth) AS FiscalMonth,
  CONVERT(NVARCHAR(200), PeriodName) AS PeriodName,
  CONVERT(VARCHAR(10), PeriodStartDate, 23) AS PeriodStartDate,
  CONVERT(VARCHAR(10), PeriodEndDate, 23) AS PeriodEndDate,
  CASE WHEN IsClosed = 1 THEN '1' ELSE '0' END AS IsClosed,
  CONVERT(VARCHAR(50), ClosedByUserID) AS ClosedByUserID,
  CONVERT(VARCHAR(33), ClosedDateTime, 126) AS ClosedDateTime,
  CASE WHEN IsAdjustmentPeriod = 1 THEN '1' ELSE '0' END AS IsAdjustmentPeriod,
  CONVERT(VARCHAR(50), WorkingDays) AS WorkingDays,
  CONVERT(VARCHAR(33), CreatedDateTime, 126) AS CreatedDateTime,
  CONVERT(VARCHAR(33), ModifiedDateTime, 126) AS ModifiedDateTime
FROM Planning.FiscalPeriod
ORDER BY FiscalPeriodID;
