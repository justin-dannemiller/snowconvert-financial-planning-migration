-- Expected: all result counts = 0 unless otherwise stated.

-- 1) Row count (informational)
SELECT 'FiscalPeriod' AS table_name, COUNT(*) AS row_count
FROM PLANNING.FISCALPERIOD;

-- 2) Primary key uniqueness
SELECT COUNT(*) - COUNT(DISTINCT FiscalPeriodID) AS duplicate_fiscalperiod_ids
FROM PLANNING.FISCALPERIOD;

-- 3) Unique constraint intent: (FiscalYear, FiscalMonth)
SELECT COUNT(*) AS duplicate_year_month_pairs
FROM (
  SELECT FiscalYear, FiscalMonth
  FROM PLANNING.FISCALPERIOD
  GROUP BY FiscalYear, FiscalMonth
  HAVING COUNT(*) > 1
);

-- 4) Quarter range check (1..4)
SELECT COUNT(*) AS invalid_quarter
FROM PLANNING.FISCALPERIOD
WHERE FiscalQuarter < 1 OR FiscalQuarter > 4;

-- 5) Month range check (1..13)
SELECT COUNT(*) AS invalid_month
FROM PLANNING.FISCALPERIOD
WHERE FiscalMonth < 1 OR FiscalMonth > 13;

-- 6) Date range check (end >= start)
SELECT COUNT(*) AS invalid_date_ranges
FROM PLANNING.FISCALPERIOD
WHERE PeriodEndDate < PeriodStartDate;

-- 7) Open periods filtered-index intent (informational)
SELECT FiscalYear, COUNT(*) AS open_periods
FROM PLANNING.FISCALPERIOD
WHERE IsClosed = FALSE
GROUP BY FiscalYear
ORDER BY FiscalYear;
