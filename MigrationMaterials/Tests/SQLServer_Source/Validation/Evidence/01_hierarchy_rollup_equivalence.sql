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
DirectAmt AS (
    SELECT
        bli.CostCenterID,
        SUM(bli.FinalAmount) AS DirectSumFinal
    FROM Planning.BudgetLineItem bli
    WHERE bli.BudgetHeaderID = @SourceBudgetHeaderID
    GROUP BY bli.CostCenterID
),
RollupAmt AS (
    SELECT
        anc.CostCenterID,
        SUM(bli.FinalAmount) AS RollupSumFinal
    FROM Subtree anc
    JOIN Subtree des
      ON des.HierarchyPath = anc.HierarchyPath
      OR des.HierarchyPath LIKE anc.HierarchyPath + '%'
    JOIN Planning.BudgetLineItem bli
      ON bli.CostCenterID = des.CostCenterID
     AND bli.BudgetHeaderID = @SourceBudgetHeaderID
    GROUP BY anc.CostCenterID
)
SELECT
    s.HierarchyLevel,
    REPLICATE('  ', s.HierarchyLevel) + s.CostCenterCode AS TreeNode,
    s.CostCenterName,
    s.CostCenterID,
    s.ParentCostCenterID,
    COALESCE(d.DirectSumFinal, 0) AS DirectSumFinal,
    COALESCE(r.RollupSumFinal, 0) AS RollupSumFinal
FROM Subtree s
LEFT JOIN DirectAmt d ON d.CostCenterID = s.CostCenterID
LEFT JOIN RollupAmt r ON r.CostCenterID = s.CostCenterID
ORDER BY s.HierarchyLevel;
