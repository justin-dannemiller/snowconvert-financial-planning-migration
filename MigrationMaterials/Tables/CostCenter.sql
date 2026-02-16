CREATE OR REPLACE TABLE PLANNING.COSTCENTER (
  CostCenterID        INT            NOT NULL,
  CostCenterCode      VARCHAR        NOT NULL,
  CostCenterName      VARCHAR        NOT NULL,
  ParentCostCenterID  INT            NULL,
  HierarchyPath       VARCHAR        NULL,   -- hierarchyid.ToString()
  HierarchyLevel      INT            NULL,
  ManagerEmployeeID   INT            NULL,
  DepartmentCode      VARCHAR        NULL,
  IsActive            BOOLEAN        NOT NULL,
  EffectiveFromDate   DATE           NOT NULL,
  EffectiveToDate     DATE           NULL,
  AllocationWeight    NUMBER(18,4)   NOT NULL,
  ValidFrom           TIMESTAMP_NTZ  NOT NULL,
  ValidTo             TIMESTAMP_NTZ  NOT NULL
);
