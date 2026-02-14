-- Expected: all result counts = 0 unless otherwise stated.

-- 1) Row count (informational)
SELECT 'CostCenter' AS table_name, COUNT(*) AS row_count
FROM PLANNING.COSTCENTER;

-- 2) Primary key uniqueness
SELECT COUNT(*) - COUNT(DISTINCT CostCenterID) AS duplicate_costcenter_ids
FROM PLANNING.COSTCENTER;

-- 3) Unique CostCenterCode
SELECT COUNT(*) AS duplicate_costcenter_codes
FROM (
  SELECT CostCenterCode
  FROM PLANNING.COSTCENTER
  GROUP BY CostCenterCode
  HAVING COUNT(*) > 1
);

-- 4) Self-referential FK integrity
SELECT COUNT(*) AS missing_parent_costcenters
FROM PLANNING.COSTCENTER c
LEFT JOIN PLANNING.COSTCENTER p ON p.CostCenterID = c.ParentCostCenterID
WHERE c.ParentCostCenterID IS NOT NULL
  AND p.CostCenterID IS NULL;

-- 5) ParentCostCenterID should not equal self
SELECT COUNT(*) AS self_parent_rows
FROM PLANNING.COSTCENTER
WHERE ParentCostCenterID = CostCenterID;

-- 6) AllocationWeight between 0 and 1 (from SQL Server CHECK)
SELECT COUNT(*) AS invalid_allocation_weight
FROM PLANNING.COSTCENTER
WHERE AllocationWeight < 0 OR AllocationWeight > 1;

-- 7) Effective date sanity
SELECT COUNT(*) AS invalid_effective_ranges
FROM PLANNING.COSTCENTER
WHERE EffectiveToDate IS NOT NULL
  AND EffectiveToDate < EffectiveFromDate;

-- 8) Validity timestamps sanity (if you loaded ValidFrom/ValidTo)
SELECT COUNT(*) AS invalid_valid_ranges
FROM PLANNING.COSTCENTER
WHERE ValidTo < ValidFrom;

-- 9) HierarchyPath sanity (informational)
-- If you are storing a materialized path like '/1/2/', this checks it starts/ends with '/'
SELECT COUNT(*) AS suspicious_hierarchy_paths
FROM PLANNING.COSTCENTER
WHERE HierarchyPath IS NOT NULL
  AND (LEFT(HierarchyPath, 1) <> '/' OR RIGHT(HierarchyPath, 1) <> '/');
