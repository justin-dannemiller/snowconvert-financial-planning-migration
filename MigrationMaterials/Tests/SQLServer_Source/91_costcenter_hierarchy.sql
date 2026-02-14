-- B1: Orphans (ParentCostCenterID points to nothing) should be 0
SELECT child.CostCenterCode, child.ParentCostCenterID
FROM Planning.CostCenter child
LEFT JOIN Planning.CostCenter parent ON parent.CostCenterID = child.ParentCostCenterID
WHERE child.ParentCostCenterID IS NOT NULL
  AND parent.CostCenterID IS NULL;

-- B2: Roots count (should be 3: NWHUS-HQ, NWHCA-HQ, NWHDE-HQ)
SELECT COUNT(*) AS RootCount
FROM Planning.CostCenter
WHERE ParentCostCenterID IS NULL;

-- B3: Quick edge list (spot-check)
SELECT child.CostCenterCode AS Child, parent.CostCenterCode AS Parent
FROM Planning.CostCenter child
LEFT JOIN Planning.CostCenter parent ON parent.CostCenterID = child.ParentCostCenterID
ORDER BY Parent, Child;
