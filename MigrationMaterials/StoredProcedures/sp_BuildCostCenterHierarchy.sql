-- StoredProcedures/sp_BuildCostCenterHierarchy.sql
--
-- Source object (SQL Server):
--   Planning.tvf_ExplodeCostCenterHierarchy(@RootCostCenterID, @MaxDepth, @IncludeInactive, @AsOfDate)
--
-- Snowflake migration approach:
--   Snowflake has no multi-statement table-valued functions.
--   We refactor to a parameterized stored procedure that materializes the hierarchy into a TEMP table
--   named HIERARCHY_TABLE in the caller's session for downstream joins.
--
-- Output (session-scoped):
--   TEMP TABLE HIERARCHY_TABLE with columns:
--     CostCenterID, CostCenterCode, CostCenterName, ParentCostCenterID,
--     HierarchyLevel, HierarchyPath, SortPath, IsLeaf, ChildCount, CumulativeWeight

CREATE OR REPLACE PROCEDURE PLANNING.SP_BuildCostCenterHierarchy(
    ROOT_COSTCENTER_ID  INT,
    MAX_DEPTH           INT,
    INCLUDE_INACTIVE    BOOLEAN,
    AS_OF_DATE          DATE
)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS CALLER
AS
$$
DECLARE
    v_root_id        INT;
    v_max_depth      INT;
    v_include_inact  BOOLEAN;
    v_effective_date DATE;
BEGIN
    v_root_id         := ROOT_COSTCENTER_ID;
    v_max_depth       := MAX_DEPTH;
    v_include_inact   := INCLUDE_INACTIVE;
    v_effective_date  := COALESCE(AS_OF_DATE, CURRENT_DATE());

    CREATE OR REPLACE TEMP TABLE HIERARCHY_TABLE AS
    WITH RECURSIVE H AS (

        -- Root(s)
        SELECT
            cc.CostCenterID,
            cc.CostCenterCode,
            cc.CostCenterName,
            cc.ParentCostCenterID,
            0 AS HierarchyLevel,
            cc.CostCenterName::STRING AS HierarchyPath,
            LPAD(cc.CostCenterID::STRING, 10, '0') AS SortPath,
            cc.AllocationWeight::NUMBER(18,10) AS CumulativeWeight
        FROM PLANNING.COSTCENTER cc
        WHERE
            (
                (:v_root_id IS NULL AND cc.ParentCostCenterID IS NULL)
                OR
                (:v_root_id IS NOT NULL AND cc.CostCenterID = :v_root_id)
            )
            AND (cc.IsActive = TRUE OR :v_include_inact = TRUE)
            AND cc.EffectiveFromDate <= :v_effective_date
            AND (cc.EffectiveToDate IS NULL OR cc.EffectiveToDate >= :v_effective_date)

        UNION ALL

        -- Children
        SELECT
            child.CostCenterID,
            child.CostCenterCode,
            child.CostCenterName,
            child.ParentCostCenterID,
            h.HierarchyLevel + 1 AS HierarchyLevel,
            h.HierarchyPath || ' > ' || child.CostCenterName AS HierarchyPath,
            h.SortPath || '/' || LPAD(child.CostCenterID::STRING, 10, '0') AS SortPath,
            (h.CumulativeWeight * child.AllocationWeight)::NUMBER(18,10) AS CumulativeWeight
        FROM PLANNING.COSTCENTER child
        JOIN H
          ON child.ParentCostCenterID = H.CostCenterID
        WHERE
            H.HierarchyLevel < :v_max_depth
            AND (child.IsActive = TRUE OR :v_include_inact = TRUE)
            AND child.EffectiveFromDate <= :v_effective_date
            AND (child.EffectiveToDate IS NULL OR child.EffectiveToDate >= :v_effective_date)
    )
    SELECT
        h.CostCenterID,
        h.CostCenterCode,
        h.CostCenterName,
        h.ParentCostCenterID,
        h.HierarchyLevel,
        h.HierarchyPath,
        h.SortPath,

        IFF(
            EXISTS (
                SELECT 1
                FROM PLANNING.COSTCENTER c2
                WHERE c2.ParentCostCenterID = h.CostCenterID
                  AND (c2.IsActive = TRUE OR :v_include_inact = TRUE)
                  AND c2.EffectiveFromDate <= :v_effective_date
                  AND (c2.EffectiveToDate IS NULL OR c2.EffectiveToDate >= :v_effective_date)
            ),
            FALSE, TRUE
        ) AS IsLeaf,

        (
            SELECT COUNT(*)
            FROM H ch
            WHERE ch.ParentCostCenterID = h.CostCenterID
        ) AS ChildCount,

        h.CumulativeWeight
    FROM H h;

    RETURN 'OK: HIERARCHY_TABLE created';
END;
$$;
