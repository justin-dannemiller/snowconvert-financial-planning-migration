-- Build hierarchy artifacts
CALL PLANNING.SP_BuildCostCenterHierarchy(NULL, 10, FALSE, CURRENT_DATE());

CREATE OR REPLACE TEMP TABLE HIERARCHY_CLOSURE AS
SELECT
  anc.COSTCENTERID AS ANCESTORCOSTCENTERID,
  des.COSTCENTERID AS DESCENDANTCOSTCENTERID
FROM HIERARCHY_TABLE anc
JOIN HIERARCHY_TABLE des
  ON des.SORTPATH = anc.SORTPATH
  OR des.SORTPATH LIKE anc.SORTPATH || '/%';

-- Parameters (edit these two)
SET ROOT_CODE = 'NWHUS-HQ';
SET SRC_BUDGET_ID = 27;

WITH root AS (
  SELECT CostCenterID, SortPath
  FROM HIERARCHY_TABLE
  WHERE CostCenterCode = $ROOT_CODE
  QUALIFY ROW_NUMBER() OVER (ORDER BY CostCenterID DESC) = 1
),
-- "Direct" amount at each node (only rows whose CostCenterID == node)
direct_amt AS (
  SELECT
    bli.COSTCENTERID,
    SUM(bli.FINALAMOUNT) AS DIRECT_SUMFINAL
  FROM PLANNING.BUDGETLINEITEM bli
  WHERE bli.BUDGETHEADERID = $SRC_BUDGET_ID
  GROUP BY 1
),
-- "Rolled up" amount under each ancestor (sum over all descendants)
rollup_amt AS (
  SELECT
    c.ANCESTORCOSTCENTERID AS COSTCENTERID,
    SUM(bli.FINALAMOUNT) AS ROLLUP_SUMFINAL
  FROM HIERARCHY_CLOSURE c
  JOIN PLANNING.BUDGETLINEITEM bli
    ON bli.COSTCENTERID = c.DESCENDANTCOSTCENTERID
   AND bli.BUDGETHEADERID = $SRC_BUDGET_ID
  GROUP BY 1
)
SELECT
  ht.HierarchyLevel,
  LPAD('', ht.HierarchyLevel * 2, ' ') || ht.CostCenterCode AS TREE_NODE,
  ht.CostCenterName,
  ht.CostCenterID,
  ht.ParentCostCenterID,
  COALESCE(d.DIRECT_SUMFINAL, 0) AS DIRECT_SUMFINAL,
  COALESCE(r.ROLLUP_SUMFINAL, 0) AS ROLLUP_SUMFINAL
FROM HIERARCHY_TABLE ht
JOIN root
  ON ht.SortPath = root.SortPath
  OR ht.SortPath LIKE root.SortPath || '/%'
LEFT JOIN direct_amt d
  ON d.COSTCENTERID = ht.CostCenterID
LEFT JOIN rollup_amt r
  ON r.COSTCENTERID = ht.CostCenterID
ORDER BY ht.HierarchyLevel
