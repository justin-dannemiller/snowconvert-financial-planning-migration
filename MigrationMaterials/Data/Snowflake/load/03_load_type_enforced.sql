
USE DATABASE SNOWFLAKE_LEARNING_DB;
USE SCHEMA PLANNING;

-- FiscalPeriod

TRUNCATE TABLE SNOWFLAKE_LEARNING_DB.PLANNING.FISCALPERIOD;

INSERT INTO SNOWFLAKE_LEARNING_DB.PLANNING.FISCALPERIOD (
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
)
SELECT
  TRY_TO_NUMBER(FiscalPeriodID)                      AS FiscalPeriodID,
  TRY_TO_NUMBER(FiscalYear)                          AS FiscalYear,
  TRY_TO_NUMBER(FiscalQuarter)                       AS FiscalQuarter,
  TRY_TO_NUMBER(FiscalMonth)                         AS FiscalMonth,
  PeriodName                                         AS PeriodName,
  TRY_TO_DATE(PeriodStartDate)                       AS PeriodStartDate,
  TRY_TO_DATE(PeriodEndDate)                         AS PeriodEndDate,
  IFF(TRY_TO_NUMBER(IsClosed) = 1, TRUE, FALSE)      AS IsClosed,
  TRY_TO_NUMBER(ClosedByUserID)                      AS ClosedByUserID,
  TRY_TO_TIMESTAMP_NTZ(ClosedDateTime)               AS ClosedDateTime,
  IFF(TRY_TO_NUMBER(IsAdjustmentPeriod) = 1, TRUE, FALSE) AS IsAdjustmentPeriod,
  TRY_TO_NUMBER(WorkingDays)                         AS WorkingDays,
  TRY_TO_TIMESTAMP_NTZ(CreatedDateTime)              AS CreatedDateTime,
  TRY_TO_TIMESTAMP_NTZ(ModifiedDateTime)             AS ModifiedDateTime
FROM SNOWFLAKE_LEARNING_DB.PLANNING_STG.FISCALPERIOD_RAW;



-- GLAccount

TRUNCATE TABLE SNOWFLAKE_LEARNING_DB.PLANNING.GLACCOUNT;

INSERT INTO SNOWFLAKE_LEARNING_DB.PLANNING.GLACCOUNT (
  GLAccountID,
  AccountNumber,
  AccountName,
  AccountType,
  AccountSubType,
  ParentAccountID,
  AccountLevel,
  IsPostable,
  IsBudgetable,
  IsStatistical,
  NormalBalance,
  CurrencyCode,
  ConsolidationAccountID,
  IntercompanyFlag,
  IsActive,
  CreatedDateTime,
  ModifiedDateTime,
  TaxCode,
  StatutoryAccountCode,
  IFRSAccountCode
)
SELECT
  TRY_TO_NUMBER(GLAccountID)                          AS GLAccountID,
  AccountNumber                                       AS AccountNumber,
  AccountName                                         AS AccountName,
  AccountType                                         AS AccountType,
  NULLIF(AccountSubType, '')                          AS AccountSubType,
  TRY_TO_NUMBER(ParentAccountID)                      AS ParentAccountID,
  TRY_TO_NUMBER(AccountLevel)                         AS AccountLevel,
  IFF(TRY_TO_NUMBER(IsPostable) = 1, TRUE, FALSE)     AS IsPostable,
  IFF(TRY_TO_NUMBER(IsBudgetable) = 1, TRUE, FALSE)   AS IsBudgetable,
  IFF(TRY_TO_NUMBER(IsStatistical) = 1, TRUE, FALSE)  AS IsStatistical,
  NormalBalance                                       AS NormalBalance,
  CurrencyCode                                        AS CurrencyCode,
  TRY_TO_NUMBER(ConsolidationAccountID)               AS ConsolidationAccountID,
  IFF(TRY_TO_NUMBER(IntercompanyFlag) = 1, TRUE, FALSE) AS IntercompanyFlag,
  IFF(TRY_TO_NUMBER(IsActive) = 1, TRUE, FALSE)       AS IsActive,
  TRY_TO_TIMESTAMP_NTZ(CreatedDateTime)               AS CreatedDateTime,
  TRY_TO_TIMESTAMP_NTZ(ModifiedDateTime)              AS ModifiedDateTime,
  NULLIF(TaxCode, '')                                 AS TaxCode,
  NULLIF(StatutoryAccountCode, '')                    AS StatutoryAccountCode,
  NULLIF(IFRSAccountCode, '')                         AS IFRSAccountCode
FROM SNOWFLAKE_LEARNING_DB.PLANNING_STG.GLACCOUNT_RAW;



-- CostCenter
TRUNCATE TABLE SNOWFLAKE_LEARNING_DB.PLANNING.COSTCENTER;

INSERT INTO SNOWFLAKE_LEARNING_DB.PLANNING.COSTCENTER (
  CostCenterID,
  CostCenterCode,
  CostCenterName,
  ParentCostCenterID,
  HierarchyPath,
  HierarchyLevel,
  ManagerEmployeeID,
  DepartmentCode,
  IsActive,
  EffectiveFromDate,
  EffectiveToDate,
  AllocationWeight,
  ValidFrom,
  ValidTo
)
SELECT
  TRY_TO_NUMBER(CostCenterID)                         AS CostCenterID,
  CostCenterCode                                      AS CostCenterCode,
  CostCenterName                                      AS CostCenterName,
  TRY_TO_NUMBER(ParentCostCenterID)                   AS ParentCostCenterID,
  NULLIF(HierarchyPath, '')                           AS HierarchyPath,
  TRY_TO_NUMBER(HierarchyLevel)                       AS HierarchyLevel,
  TRY_TO_NUMBER(ManagerEmployeeID)                    AS ManagerEmployeeID,
  NULLIF(DepartmentCode, '')                          AS DepartmentCode,
  IFF(TRY_TO_NUMBER(IsActive) = 1, TRUE, FALSE)       AS IsActive,
  TRY_TO_DATE(EffectiveFromDate)                      AS EffectiveFromDate,
  TRY_TO_DATE(EffectiveToDate)                        AS EffectiveToDate,
  TRY_TO_NUMBER(AllocationWeight)                     AS AllocationWeight,
  TRY_TO_TIMESTAMP_NTZ(ValidFrom)                     AS ValidFrom,
  TRY_TO_TIMESTAMP_NTZ(ValidTo)                       AS ValidTo
FROM SNOWFLAKE_LEARNING_DB.PLANNING_STG.COSTCENTER_RAW;



-- BudgetHeader

TRUNCATE TABLE SNOWFLAKE_LEARNING_DB.PLANNING.BUDGETHEADER;

INSERT INTO SNOWFLAKE_LEARNING_DB.PLANNING.BUDGETHEADER (
  BudgetHeaderID,
  BudgetCode,
  BudgetName,
  BudgetType,
  ScenarioType,
  FiscalYear,
  StartPeriodID,
  EndPeriodID,
  BaseBudgetHeaderID,
  StatusCode,
  SubmittedByUserID,
  SubmittedDateTime,
  ApprovedByUserID,
  ApprovedDateTime,
  LockedDateTime,
  IsLocked,
  VersionNumber,
  Notes,
  ExtendedProperties,
  CreatedDateTime,
  ModifiedDateTime
)
SELECT
  TRY_TO_NUMBER(BudgetHeaderID)                       AS BudgetHeaderID,
  BudgetCode                                          AS BudgetCode,
  BudgetName                                          AS BudgetName,
  BudgetType                                          AS BudgetType,
  ScenarioType                                        AS ScenarioType,
  TRY_TO_NUMBER(FiscalYear)                           AS FiscalYear,
  TRY_TO_NUMBER(StartPeriodID)                        AS StartPeriodID,
  TRY_TO_NUMBER(EndPeriodID)                          AS EndPeriodID,
  TRY_TO_NUMBER(BaseBudgetHeaderID)                   AS BaseBudgetHeaderID,
  StatusCode                                          AS StatusCode,
  TRY_TO_NUMBER(SubmittedByUserID)                    AS SubmittedByUserID,
  TRY_TO_TIMESTAMP_NTZ(SubmittedDateTime)             AS SubmittedDateTime,
  TRY_TO_NUMBER(ApprovedByUserID)                     AS ApprovedByUserID,
  TRY_TO_TIMESTAMP_NTZ(ApprovedDateTime)              AS ApprovedDateTime,
  TRY_TO_TIMESTAMP_NTZ(LockedDateTime)                AS LockedDateTime,
  IFF(TRY_TO_TIMESTAMP_NTZ(LockedDateTime) IS NOT NULL, 1, 0) AS IsLocked,
  TRY_TO_NUMBER(VersionNumber)                        AS VersionNumber,
  NULLIF(Notes, '')                                   AS Notes,
  NULLIF(ExtendedProperties, '')                      AS ExtendedProperties,
  TRY_TO_TIMESTAMP_NTZ(CreatedDateTime)               AS CreatedDateTime,
  TRY_TO_TIMESTAMP_NTZ(ModifiedDateTime)              AS ModifiedDateTime
FROM SNOWFLAKE_LEARNING_DB.PLANNING_STG.BUDGETHEADER_RAW;



-- BudgetLineItem
TRUNCATE TABLE SNOWFLAKE_LEARNING_DB.PLANNING.BUDGETLINEITEM;

INSERT INTO SNOWFLAKE_LEARNING_DB.PLANNING.BUDGETLINEITEM (
  BudgetLineItemID,
  BudgetHeaderID,
  GLAccountID,
  CostCenterID,
  FiscalPeriodID,
  OriginalAmount,
  AdjustedAmount,
  FinalAmount,
  LocalCurrencyAmount,
  ReportingCurrencyAmount,
  StatisticalQuantity,
  UnitOfMeasure,
  SpreadMethodCode,
  SeasonalityFactor,
  SourceSystem,
  SourceReference,
  ImportBatchID,
  IsAllocated,
  AllocationSourceLineID,
  AllocationPercentage,
  LastModifiedByUserID,
  LastModifiedDateTime,
  RowHash
)
SELECT
  TRY_TO_NUMBER(BudgetLineItemID)                         AS BudgetLineItemID,
  TRY_TO_NUMBER(BudgetHeaderID)                           AS BudgetHeaderID,
  TRY_TO_NUMBER(GLAccountID)                              AS GLAccountID,
  TRY_TO_NUMBER(CostCenterID)                             AS CostCenterID,
  TRY_TO_NUMBER(FiscalPeriodID)                           AS FiscalPeriodID,

  TRY_TO_NUMBER(OriginalAmount)                           AS OriginalAmount,
  TRY_TO_NUMBER(AdjustedAmount)                           AS AdjustedAmount,
  TRY_TO_NUMBER(OriginalAmount) + TRY_TO_NUMBER(AdjustedAmount) AS FinalAmount,

  TRY_TO_NUMBER(LocalCurrencyAmount)                      AS LocalCurrencyAmount,
  TRY_TO_NUMBER(ReportingCurrencyAmount)                  AS ReportingCurrencyAmount,
  TRY_TO_NUMBER(StatisticalQuantity)                      AS StatisticalQuantity,

  NULLIF(UnitOfMeasure, '')                               AS UnitOfMeasure,
  NULLIF(SpreadMethodCode, '')                            AS SpreadMethodCode,
  TRY_TO_NUMBER(SeasonalityFactor)                        AS SeasonalityFactor,

  NULLIF(SourceSystem, '')                                AS SourceSystem,
  NULLIF(SourceReference, '')                             AS SourceReference,
  NULLIF(ImportBatchID, '')                               AS ImportBatchID,

  IFF(TRY_TO_NUMBER(IsAllocated) = 1, TRUE, FALSE)        AS IsAllocated,
  TRY_TO_NUMBER(AllocationSourceLineID)                   AS AllocationSourceLineID,
  TRY_TO_NUMBER(AllocationPercentage)                     AS AllocationPercentage,

  TRY_TO_NUMBER(LastModifiedByUserID)                     AS LastModifiedByUserID,
  TRY_TO_TIMESTAMP_NTZ(LastModifiedDateTime)              AS LastModifiedDateTime,
  NULLIF(RowHash, '')                                     AS RowHash
FROM SNOWFLAKE_LEARNING_DB.PLANNING_STG.BUDGETLINEITEM_RAW;