DECLARE @StartPeriodID INT = (SELECT MIN(FiscalPeriodID) FROM Planning.FiscalPeriod WHERE FiscalYear=2025);
DECLARE @EndPeriodID   INT = (SELECT MAX(FiscalPeriodID) FROM Planning.FiscalPeriod WHERE FiscalYear=2025);

IF NOT EXISTS (SELECT 1 FROM Planning.BudgetHeader WHERE BudgetCode='BUDGET_2025_BASE')
BEGIN
    INSERT INTO Planning.BudgetHeader (
        BudgetCode, BudgetName, BudgetType, ScenarioType, FiscalYear,
        StartPeriodID, EndPeriodID, BaseBudgetHeaderID, StatusCode,
        VersionNumber, Notes, ExtendedProperties,
        CreatedDateTime, ModifiedDateTime
    )
    VALUES (
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
        N'Seeded for migration testing',
        NULL,
        SYSUTCDATETIME(),
        SYSUTCDATETIME()
    );
END
