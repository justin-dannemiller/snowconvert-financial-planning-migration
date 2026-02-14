SELECT
  CONVERT(VARCHAR(50), CostCenterID) AS CostCenterID,
  CONVERT(VARCHAR(50), CostCenterCode) AS CostCenterCode,
  CONVERT(NVARCHAR(200), CostCenterName) AS CostCenterName,
  CONVERT(VARCHAR(50), ParentCostCenterID) AS ParentCostCenterID,
  CASE WHEN HierarchyPath IS NULL THEN NULL ELSE HierarchyPath.ToString() END AS HierarchyPath,
  CONVERT(VARCHAR(50), HierarchyLevel) AS HierarchyLevel,
  CONVERT(VARCHAR(50), ManagerEmployeeID) AS ManagerEmployeeID,
  CONVERT(VARCHAR(50), DepartmentCode) AS DepartmentCode,
  CASE WHEN IsActive = 1 THEN '1' ELSE '0' END AS IsActive,
  CONVERT(VARCHAR(10), EffectiveFromDate, 23) AS EffectiveFromDate,
  CONVERT(VARCHAR(10), EffectiveToDate, 23) AS EffectiveToDate,
  CONVERT(VARCHAR(50), AllocationWeight) AS AllocationWeight,
  CONVERT(VARCHAR(33), ValidFrom, 126) AS ValidFrom,
  CONVERT(VARCHAR(33), ValidTo, 126) AS ValidTo
FROM Planning.CostCenter
ORDER BY CostCenterID;
