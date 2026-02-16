-- Build hierarchy artifacts (same as your rollup script)
CALL PLANNING.SP_BuildCostCenterHierarchy(NULL, 10, FALSE, CURRENT_DATE());

-- Parameters
SET ROOT_CODE = 'NWHUS-HQ';
SET SRC_BUDGET_ID = 27;

WITH root AS (
  SELECT CostCenterID, SortPath
  FROM HIERARCHY_TABLE
  WHERE CostCenterCode = $ROOT_CODE
  QUALIFY ROW_NUMBER() OVER (ORDER BY CostCenterID DESC) = 1
),
subtree AS (
  SELECT ht.*
  FROM HIERARCHY_TABLE ht
  JOIN root
    ON ht.SortPath = root.SortPath
    OR ht.SortPath LIKE root.SortPath || '/%'
),
-- leaf = node with no children in the subtree
leaves AS (
  SELECT s.*
  FROM subtree s
  LEFT JOIN subtree child
    ON child.ParentCostCenterID = s.CostCenterID
  WHERE child.CostCenterID IS NULL
),
leaf_totals AS (
  SELECT
    bli.COSTCENTERID,
    SUM(bli.FINALAMOUNT) AS LEAF_SUMFINAL,
    COUNT(*) AS LEAF_LINECOUNT
  FROM PLANNING.BUDGETLINEITEM bli
  WHERE bli.BUDGETHEADERID = $SRC_BUDGET_ID
  GROUP BY 1
)
SELECT
  l.HierarchyLevel,
  l.CostCenterCode,
  l.CostCenterName,
  l.CostCenterID,
  COALESCE(t.LEAF_LINECOUNT, 0) AS LEAF_LINECOUNT,
  COALESCE(t.LEAF_SUMFINAL, 0)  AS LEAF_SUMFINAL
FROM leaves l
LEFT JOIN leaf_totals t
  ON t.COSTCENTERID = l.CostCenterID
ORDER BY l.CostCenterCode;
