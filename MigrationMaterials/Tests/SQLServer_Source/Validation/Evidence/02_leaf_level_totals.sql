DECLARE @RootCode VARCHAR(20) = 'NWHUS-HQ';
DECLARE @SourceBudgetHeaderID INT = 27;

;WITH H AS (
    SELECT *
    FROM Planning.tvf_ExplodeCostCenterHierarchy(NULL, 10, 0, GETDATE())
),
Root AS (
    SELECT TOP 1 CostCenterID, CostCenterName, HierarchyPath
    FROM H
    WHERE CostCenterCode = @RootCode
    ORDER BY CostCenterID DESC
),
Subtree AS (
    SELECT h.*
    FROM H h
    CROSS JOIN Root r
    WHERE h.HierarchyPath = r.HierarchyPath
       OR h.HierarchyPath LIKE r.HierarchyPath + '%'
),
-- Leaf = node that has no child within the same subtree
Leaves AS (
    SELECT s.*
    FROM Subtree s
    WHERE NOT EXISTS (
        SELECT 1
        FROM Subtree c
        WHERE c.ParentCostCenterID = s.CostCenterID
    )
),
LeafTotals AS (
    SELECT
        bli.CostCenterID,
        COUNT(*) AS LeafLineCount,
        SUM(bli.FinalAmount) AS LeafSumFinal
    FROM Planning.BudgetLineItem bli
    WHERE bli.BudgetHeaderID = @SourceBudgetHeaderID
    GROUP BY bli.CostCenterID
)
SELECT
    l.HierarchyLevel,
    REPLICATE('  ', l.HierarchyLevel) + l.CostCenterCode AS LeafNode,
    l.CostCenterName,
    l.CostCenterID,
    COALESCE(t.LeafLineCount, 0) AS LeafLineCount,
    COALESCE(t.LeafSumFinal, 0)  AS LeafSumFinal
FROM Leaves l
LEFT JOIN LeafTotals t
    ON t.CostCenterID = l.CostCenterID
ORDER BY l.CostCenterCode;
