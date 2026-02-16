-- Final Consolidated Output – Root-Level Totals
-- Economically meaningful validation of the Snowflake target artifact
-- (avoids hierarchy-level double counting)
SELECT
  ht.CostCenterCode AS RootCode,
  SUM(bli.OriginalAmount) AS RootTotalInTarget
FROM PLANNING.BUDGETLINEITEM bli
JOIN HIERARCHY_TABLE ht
  ON ht.CostCenterID = bli.CostCenterID
WHERE bli.BudgetHeaderID = 502
  AND bli.SourceReference = '129cd524-cd56-4c13-8677-6bf888f27558'
  AND (ht.ParentCostCenterID IS NULL OR ht.HierarchyLevel = 0)
GROUP BY 1;
