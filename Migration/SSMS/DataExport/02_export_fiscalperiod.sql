SELECT
  FiscalPeriodID,
  FiscalYear,
  FiscalQuarter,
  FiscalMonth,
  PeriodName,
  PeriodStartDate,
  PeriodEndDate,
  IsClosed,
  ClosedByUserID,
  ClosedDateTime,
  IsAdjustmentPeriod,
  WorkingDays,
  CreatedDateTime,
  ModifiedDateTime
FROM Planning.FiscalPeriod;
