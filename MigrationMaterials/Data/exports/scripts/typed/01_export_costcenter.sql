SELECT
  CostCenterID,
  CostCenterCode,
  CostCenterName,
  ParentCostCenterID,
  HierarchyPath.ToString() AS Hierarchy_Path,
  HierarchyLevel           AS Hierarchy_Level,
  ManagerEmployeeID,
  DepartmentCode,
  IsActive,
  EffectiveFromDate,
  EffectiveToDate,
  AllocationWeight,
  ValidFrom,
  ValidTo
FROM Planning.CostCenter;
