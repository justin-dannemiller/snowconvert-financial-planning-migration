SET NOCOUNT ON;

DECLARE @Inserted INT = 1;

-- 1) Define seed once (same codes/names you want)
IF OBJECT_ID('tempdb..#Seed') IS NOT NULL DROP TABLE #Seed;
CREATE TABLE #Seed (
    CostCenterCode     VARCHAR(20)  NOT NULL,
    CostCenterName     NVARCHAR(100) NOT NULL,
    ParentCode         VARCHAR(20)  NULL,
    HierarchyPath      hierarchyid  NULL,
    IsActive           BIT          NOT NULL,
    AllocationWeight   DECIMAL(19,4) NOT NULL
);

INSERT INTO #Seed (CostCenterCode, CostCenterName, ParentCode, HierarchyPath, IsActive, AllocationWeight)
VALUES
    -- Level 1: Entities
    ('NWHUS-HQ',        'Northwind Health (US) - HQ',        NULL, hierarchyid::Parse('/1/'),        1, 1.00),
    ('NWHCA-HQ',        'Northwind Health (Canada) - HQ',    NULL, hierarchyid::Parse('/2/'),        1, 1.00),
    ('NWHDE-HQ',        'Northwind Health (Germany) - HQ',   NULL, hierarchyid::Parse('/3/'),        1, 1.00),

    -- Level 2: Business Units
    ('NWHUS-HOSP',      'US Hospitals Division',             'NWHUS-HQ', hierarchyid::Parse('/1/1/'), 1, 1.00),
    ('NWHUS-INS',       'US Insurance Products',             'NWHUS-HQ', hierarchyid::Parse('/1/2/'), 1, 1.00),
    ('NWHCA-HOSP',      'Canada Hospitals Division',         'NWHCA-HQ', hierarchyid::Parse('/2/1/'), 1, 1.00),
    ('NWHDE-HOSP',      'Germany Hospitals Division',        'NWHDE-HQ', hierarchyid::Parse('/3/1/'), 1, 1.00),

    -- Level 3: Functions
    ('NWHUS-HOSP-REV',  'US Hospitals - Revenue Cycle',      'NWHUS-HOSP', hierarchyid::Parse('/1/1/1/'), 1, 1.00),
    ('NWHUS-HOSP-OPS',  'US Hospitals - Operations',         'NWHUS-HOSP', hierarchyid::Parse('/1/1/2/'), 1, 1.00),
    ('NWHUS-HOSP-IT',   'US Hospitals - IT',                 'NWHUS-HOSP', hierarchyid::Parse('/1/1/3/'), 1, 1.00),
    ('NWHUS-INS-ACT',   'US Insurance - Actuarial',          'NWHUS-INS',  hierarchyid::Parse('/1/2/1/'), 1, 1.00),
    ('NWHCA-HOSP-OPS',  'Canada Hospitals - Operations',     'NWHCA-HOSP', hierarchyid::Parse('/2/1/1/'), 1, 1.00),
    ('NWHDE-HOSP-OPS',  'Germany Hospitals - Operations',    'NWHDE-HOSP', hierarchyid::Parse('/3/1/1/'), 1, 1.00),

    -- Level 4: Teams (leafs)
    ('NWHUS-REV-AR',    'US Rev Cycle - Accounts Receivable','NWHUS-HOSP-REV', hierarchyid::Parse('/1/1/1/1/'), 1, 1.00),
    ('NWHUS-REV-BILL',  'US Rev Cycle - Billing',            'NWHUS-HOSP-REV', hierarchyid::Parse('/1/1/1/2/'), 1, 1.00),
    ('NWHUS-OPS-W',     'US Hospital Ops - West Region',     'NWHUS-HOSP-OPS', hierarchyid::Parse('/1/1/2/1/'), 1, 1.00),
    ('NWHUS-OPS-E',     'US Hospital Ops - East Region',     'NWHUS-HOSP-OPS', hierarchyid::Parse('/1/1/2/2/'), 1, 1.00),
    ('NWHUS-IT-INF',    'US Hospital IT - Infrastructure',   'NWHUS-HOSP-IT', hierarchyid::Parse('/1/1/3/1/'), 1, 1.00),
    ('NWHDE-OPS-BER',   'Germany Hospital Ops - Berlin',     'NWHDE-HOSP-OPS', hierarchyid::Parse('/3/1/1/1/'), 1, 1.00);

-- 2) Insert roots first (ParentCode IS NULL)
INSERT INTO Planning.CostCenter (
    CostCenterCode, CostCenterName, ParentCostCenterID,
    HierarchyPath,
    ManagerEmployeeID, DepartmentCode,
    IsActive, EffectiveFromDate, EffectiveToDate,
    AllocationWeight
)
SELECT
    s.CostCenterCode, s.CostCenterName, NULL,
    s.HierarchyPath,
    NULL, NULL,
    s.IsActive,
    CAST('2024-01-01' AS date), NULL,
    s.AllocationWeight
FROM #Seed s
WHERE s.ParentCode IS NULL
  AND NOT EXISTS (
      SELECT 1 FROM Planning.CostCenter cc WHERE cc.CostCenterCode = s.CostCenterCode
  );

-- 3) Iteratively insert children whose parent now exists
WHILE @Inserted > 0
BEGIN
    INSERT INTO Planning.CostCenter (
        CostCenterCode, CostCenterName, ParentCostCenterID,
        HierarchyPath,
        ManagerEmployeeID, DepartmentCode,
        IsActive, EffectiveFromDate, EffectiveToDate,
        AllocationWeight
    )
    SELECT
        s.CostCenterCode,
        s.CostCenterName,
        p.CostCenterID AS ParentCostCenterID,
        s.HierarchyPath,
        NULL, NULL,
        s.IsActive,
        CAST('2024-01-01' AS date), NULL,
        s.AllocationWeight
    FROM #Seed s
    INNER JOIN Planning.CostCenter p
        ON p.CostCenterCode = s.ParentCode
    WHERE s.ParentCode IS NOT NULL
      AND NOT EXISTS (
          SELECT 1 FROM Planning.CostCenter cc WHERE cc.CostCenterCode = s.CostCenterCode
      );

    SET @Inserted = @@ROWCOUNT;
END

-- 4) Hard fail if anything still missing (git reproducibility)
IF EXISTS (
    SELECT 1
    FROM #Seed s
    LEFT JOIN Planning.CostCenter cc ON cc.CostCenterCode = s.CostCenterCode
    WHERE cc.CostCenterID IS NULL
)
BEGIN
    SELECT s.CostCenterCode AS MissingCostCenterCode
    FROM #Seed s
    LEFT JOIN Planning.CostCenter cc ON cc.CostCenterCode = s.CostCenterCode
    WHERE cc.CostCenterID IS NULL
    ORDER BY s.CostCenterCode;

    THROW 50001, 'CostCenter seed failed: some cost centers were not inserted. See MissingCostCenterCode output.', 1;
END

