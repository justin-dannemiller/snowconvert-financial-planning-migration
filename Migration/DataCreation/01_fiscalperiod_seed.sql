-- Seed Fiscal Periods (example: 2025 Jan–Dec)
DECLARE @year SMALLINT = 2025;

;WITH m AS (
    SELECT 1 AS FiscalMonth UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
    UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8
    UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
)
INSERT INTO Planning.FiscalPeriod (
    FiscalYear, FiscalQuarter, FiscalMonth, PeriodName,
    PeriodStartDate, PeriodEndDate, IsClosed, IsAdjustmentPeriod,
    WorkingDays, CreatedDateTime, ModifiedDateTime
)
SELECT
    @year,
    CASE WHEN FiscalMonth IN (1,2,3) THEN 1 WHEN FiscalMonth IN (4,5,6) THEN 2
         WHEN FiscalMonth IN (7,8,9) THEN 3 ELSE 4 END,
    FiscalMonth,
    CONCAT(@year, '-', RIGHT(CONCAT('0', FiscalMonth), 2)),
    DATEFROMPARTS(@year, FiscalMonth, 1),
    EOMONTH(DATEFROMPARTS(@year, FiscalMonth, 1)),
    0,
    0,
    NULL,
    SYSUTCDATETIME(),
    SYSUTCDATETIME()
FROM m
WHERE NOT EXISTS (
    SELECT 1 FROM Planning.FiscalPeriod fp
    WHERE fp.FiscalYear = @year AND fp.FiscalMonth = m.FiscalMonth
);
