DECLARE @StartPeriodID INT = (SELECT MIN(FiscalPeriodID) FROM Planning.FiscalPeriod WHERE FiscalYear=2025);
DECLARE @EndPeriodID   INT = (SELECT MAX(FiscalPeriodID) FROM Planning.FiscalPeriod WHERE FiscalYear=2025);

INSERT INTO Planning.BudgetHeader (
    BudgetCode, BudgetName, BudgetType, ScenarioType, FiscalYear,
    StartPeriodID, EndPeriodID, BaseBudgetHeaderID, StatusCode,
    VersionNumber, Notes, ExtendedProperties,
    CreatedDateTime, ModifiedDateTime
)
VALUES
(
    'BUDGET_2025_BASE',
    N'2025 Operating Budget (Base)',
    'OPERATING',
    'BASE',
    2025,
    @StartPeriodID,
    @EndPeriodID,
    NULL,
    'APPROVED',
    1,
    N'Seeded baseline budget for consolidation migration testing',
    NULL,
    SYSUTCDATETIME(),
    SYSUTCDATETIME()
),
(
    'BUDGET_2025_DRAFT',
    N'2025 Operating Budget (Draft - Validation Test)',
    'OPERATING',
    'BASE',
    2025,
    @StartPeriodID,
    @EndPeriodID,
    NULL,
    'DRAFT',
    1,
    N'Seeded to verify consolidation rejects non-approved budgets',
    NULL,
    SYSUTCDATETIME(),
    SYSUTCDATETIME()
),
(
    'BUDGET_2025_TARGET',
    N'2025 Consolidation Target (Pre-created)',
    'CONSOLIDATED',
    'BASE',
    2025,
    @StartPeriodID,
    @EndPeriodID,
    NULL,
    'DRAFT',
    1,
    N'Seeded to test consolidation when TARGET_BUDGET_HEADER_ID is provided',
    NULL,
    SYSUTCDATETIME(),
    SYSUTCDATETIME()
);
