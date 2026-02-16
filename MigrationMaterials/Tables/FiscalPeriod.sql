CREATE OR REPLACE TABLE PLANNING.FISCALPERIOD (
  FiscalPeriodID         INT           NOT NULL,
  FiscalYear             INT           NOT NULL,
  FiscalQuarter          INT           NOT NULL,
  FiscalMonth            INT           NOT NULL,
  PeriodName             VARCHAR       NOT NULL,
  PeriodStartDate        DATE          NOT NULL,
  PeriodEndDate          DATE          NOT NULL,
  IsClosed               BOOLEAN       NOT NULL,
  ClosedByUserID         INT           NULL,
  ClosedDateTime         TIMESTAMP_NTZ NULL,
  IsAdjustmentPeriod     BOOLEAN       NOT NULL,
  WorkingDays            NUMBER(10,0)  NULL,
  CreatedDateTime        TIMESTAMP_NTZ NOT NULL,
  ModifiedDateTime       TIMESTAMP_NTZ NOT NULL
);
