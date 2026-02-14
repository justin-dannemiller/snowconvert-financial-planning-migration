-- 01_create_raw_tables.sql

CREATE OR REPLACE TABLE PLANNING_STG.FISCALPERIOD_RAW (
  FiscalPeriodID VARCHAR,
  FiscalYear VARCHAR,
  FiscalQuarter VARCHAR,
  FiscalMonth VARCHAR,
  PeriodName VARCHAR,
  PeriodStartDate VARCHAR,
  PeriodEndDate VARCHAR,
  IsClosed VARCHAR,
  ClosedByUserID VARCHAR,
  ClosedDateTime VARCHAR,
  IsAdjustmentPeriod VARCHAR,
  WorkingDays VARCHAR,
  CreatedDateTime VARCHAR,
  ModifiedDateTime VARCHAR
);

CREATE OR REPLACE TABLE PLANNING_STG.GLACCOUNT_RAW (
  GLAccountID VARCHAR,
  AccountNumber VARCHAR,
  AccountName VARCHAR,
  AccountType VARCHAR,
  AccountSubType VARCHAR,
  ParentAccountID VARCHAR,
  AccountLevel VARCHAR,
  IsPostable VARCHAR,
  IsBudgetable VARCHAR,
  IsStatistical VARCHAR,
  NormalBalance VARCHAR,
  CurrencyCode VARCHAR,
  ConsolidationAccountID VARCHAR,
  IntercompanyFlag VARCHAR,
  IsActive VARCHAR,
  CreatedDateTime VARCHAR,
  ModifiedDateTime VARCHAR,
  TaxCode VARCHAR,
  StatutoryAccountCode VARCHAR,
  IFRSAccountCode VARCHAR
);

CREATE OR REPLACE TABLE PLANNING_STG.COSTCENTER_RAW (
  CostCenterID VARCHAR,
  CostCenterCode VARCHAR,
  CostCenterName VARCHAR,
  ParentCostCenterID VARCHAR,
  HierarchyPath VARCHAR,
  HierarchyLevel VARCHAR,
  ManagerEmployeeID VARCHAR,
  DepartmentCode VARCHAR,
  IsActive VARCHAR,
  EffectiveFromDate VARCHAR,
  EffectiveToDate VARCHAR,
  AllocationWeight VARCHAR,
  ValidFrom VARCHAR,
  ValidTo VARCHAR
);

CREATE OR REPLACE TABLE PLANNING_STG.BUDGETHEADER_RAW (
  BudgetHeaderID VARCHAR,
  BudgetCode VARCHAR,
  BudgetName VARCHAR,
  BudgetType VARCHAR,
  ScenarioType VARCHAR,
  FiscalYear VARCHAR,
  StartPeriodID VARCHAR,
  EndPeriodID VARCHAR,
  BaseBudgetHeaderID VARCHAR,
  StatusCode VARCHAR,
  SubmittedByUserID VARCHAR,
  SubmittedDateTime VARCHAR,
  ApprovedByUserID VARCHAR,
  ApprovedDateTime VARCHAR,
  LockedDateTime VARCHAR,
  IsLocked VARCHAR,
  VersionNumber VARCHAR,
  Notes VARCHAR,
  ExtendedProperties VARCHAR,
  CreatedDateTime VARCHAR,
  ModifiedDateTime VARCHAR
);

CREATE OR REPLACE TABLE PLANNING_STG.BUDGETLINEITEM_RAW (
  BudgetLineItemID VARCHAR,
  BudgetHeaderID VARCHAR,
  GLAccountID VARCHAR,
  CostCenterID VARCHAR,
  FiscalPeriodID VARCHAR,
  OriginalAmount VARCHAR,
  AdjustedAmount VARCHAR,
  FinalAmount VARCHAR,
  LocalCurrencyAmount VARCHAR,
  ReportingCurrencyAmount VARCHAR,
  StatisticalQuantity VARCHAR,
  UnitOfMeasure VARCHAR,
  SpreadMethodCode VARCHAR,
  SeasonalityFactor VARCHAR,
  SourceSystem VARCHAR,
  SourceReference VARCHAR,
  ImportBatchID VARCHAR,
  IsAllocated VARCHAR,
  AllocationSourceLineID VARCHAR,
  AllocationPercentage VARCHAR,
  LastModifiedByUserID VARCHAR,
  LastModifiedDateTime VARCHAR,
  RowHash VARCHAR
);
