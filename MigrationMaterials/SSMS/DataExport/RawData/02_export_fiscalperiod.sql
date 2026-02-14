DECLARE @FiscalYear SMALLINT = 2025;

SELECT
  fp.FiscalPeriodID,
  fp.FiscalYear,
  fp.FiscalQuarter,
  fp.FiscalMonth,
  fp.PeriodName,
  CONVERT(varchar(10), fp.PeriodStartDate, 23) AS PeriodStartDate,  -- YYYY-MM-DD
  CONVERT(varchar(10), fp.PeriodEndDate, 23)   AS PeriodEndDate,    -- YYYY-MM-DD
  CASE WHEN fp.IsClosed = 1 THEN 1 ELSE 0 END AS IsClosed,
  fp.ClosedByUserID,
  CASE WHEN fp.ClosedDateTime IS NULL THEN NULL ELSE CONVERT(varchar(33), fp.ClosedDateTime, 126) END AS ClosedDateTime,
  CASE WHEN fp.IsAdjustmentPeriod = 1 THEN 1 ELSE 0 END AS IsAdjustmentPeriod,
  fp.WorkingDays,
  CONVERT(varchar(33), fp.CreatedDateTime, 126)  AS CreatedDateTime,
  CONVERT(varchar(33), fp.ModifiedDateTime, 126) AS ModifiedDateTime
FROM Planning.FiscalPeriod fp
WHERE fp.FiscalYear = @FiscalYear
ORDER BY fp.FiscalPeriodID;
