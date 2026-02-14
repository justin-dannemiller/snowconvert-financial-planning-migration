-- Tests/test_sp_BuildCostCenterHierarchy.sql
-- Assumes SP has been created and COSTCENTER data exists.

-- Build hierarchy (defaults matching your SQL Server call: NULL, 10, 0, GETDATE())
CALL PLANNING.SP_BuildCostCenterHierarchy(NULL, 10, FALSE, CURRENT_DATE());

-- 1) Basic rowcount
SELECT COUNT(*) AS hierarchy_rowcount
FROM HIERARCHY_TABLE;

-- 2) Counts by level (hierarchy "shape")
SELECT
  HierarchyLevel,
  COUNT(*) AS nodes
FROM HIERARCHY_TABLE
GROUP BY 1
ORDER BY 1;

-- 3) Duplicate CostCenterID check (should be zero)
SELECT
  CostCenterID,
  COUNT(*) AS cnt
FROM HIERARCHY_TABLE
GROUP BY 1
HAVING COUNT(*) > 1
ORDER BY cnt DESC, CostCenterID;

-- 4) Parent reference check (non-root nodes should have parent in exploded set)
SELECT
  h.CostCenterID,
  h.ParentCostCenterID
FROM HIERARCHY_TABLE h
LEFT JOIN HIERARCHY_TABLE p
  ON p.CostCenterID = h.ParentCostCenterID
WHERE h.ParentCostCenterID IS NOT NULL
  AND p.CostCenterID IS NULL
ORDER BY h.CostCenterID;

-- 5) Quick sample
SELECT
  CostCenterID,
  ParentCostCenterID,
  HierarchyLevel,
  HierarchyPath,
  SortPath,
  CumulativeWeight,
  IsLeaf,
  ChildCount
FROM HIERARCHY_TABLE
ORDER BY HierarchyLevel DESC, CostCenterID
LIMIT 50;
