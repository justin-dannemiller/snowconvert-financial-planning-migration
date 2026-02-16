CREATE OR REPLACE TABLE BUDGETLINEITEM (
  BudgetLineItemID           NUMBER(38,0)  NOT NULL,  -- bigint
  BudgetHeaderID             INT           NOT NULL,
  GLAccountID                INT           NOT NULL,
  CostCenterID               INT           NOT NULL,
  FiscalPeriodID             INT           NOT NULL,
  OriginalAmount             NUMBER(18,4)  NOT NULL,
  AdjustedAmount             NUMBER(18,4)  NOT NULL,
  FinalAmount                NUMBER(18,4)  NULL,
  LocalCurrencyAmount        NUMBER(18,4)  NULL,
  ReportingCurrencyAmount    NUMBER(18,4)  NULL,
  StatisticalQuantity        NUMBER(18,4)  NULL,
  UnitOfMeasure              VARCHAR       NULL,
  SpreadMethodCode           VARCHAR       NULL,
  SeasonalityFactor          NUMBER(18,4)  NULL,
  SourceSystem               VARCHAR       NULL,
  SourceReference            VARCHAR       NULL,
  ImportBatchID              VARCHAR(36)   NULL,       -- uniqueidentifier
  IsAllocated                BOOLEAN       NOT NULL,
  AllocationSourceLineID     NUMBER(38,0)  NULL,
  AllocationPercentage       NUMBER(18,4)  NULL,
  LastModifiedByUserID       INT           NULL,
  LastModifiedDateTime       TIMESTAMP_NTZ NOT NULL,
  RowHash                    VARCHAR       NULL        -- varbinary -> hex string
);

CREATE OR REPLACE SEQUENCE PLANNING.BUDGETLINEITEMID_SEQ START = 1 INCREMENT = 1;
