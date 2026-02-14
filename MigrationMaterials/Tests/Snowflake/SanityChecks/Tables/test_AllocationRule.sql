-- Expected: all result counts = 0 unless otherwise stated.

-- 1) Row count (informational)
SELECT 'AllocationRule' AS table_name, COUNT(*) AS row_count
FROM PLANNING.ALLOCATIONRULE;

-- 2) Primary key uniqueness
SELECT COUNT(*) - COUNT(DISTINCT AllocationRuleID) AS duplicate_allocationrule_ids
FROM PLANNING.ALLOCATIONRULE;

-- 3) Unique RuleCode
SELECT COUNT(*) AS duplicate_rule_codes
FROM (
  SELECT RuleCode
  FROM PLANNING.ALLOCATIONRULE
  GROUP BY RuleCode
  HAVING COUNT(*) > 1
);

-- 4) FK: SourceCostCenterID exists
SELECT COUNT(*) AS missing_source_costcenter
FROM PLANNING.ALLOCATIONRULE ar
LEFT JOIN PLANNING.COSTCENTER cc ON cc.CostCenterID = ar.SourceCostCenterID
WHERE ar.SourceCostCenterID IS NOT NULL
  AND cc.CostCenterID IS NULL;

-- 5) FK: DependsOnRuleID exists
SELECT COUNT(*) AS missing_depends_on_rule
FROM PLANNING.ALLOCATIONRULE ar
LEFT JOIN PLANNING.ALLOCATIONRULE dep ON dep.AllocationRuleID = ar.DependsOnRuleID
WHERE ar.DependsOnRuleID IS NOT NULL
  AND dep.AllocationRuleID IS NULL;

-- 6) Domain: RuleType
SELECT COUNT(*) AS invalid_rule_type
FROM PLANNING.ALLOCATIONRULE
WHERE RuleType NOT IN ('DIRECT','STEP_DOWN','RECIPROCAL','ACTIVITY_BASED');

-- 7) Domain: RoundingMethod
SELECT COUNT(*) AS invalid_rounding_method
FROM PLANNING.ALLOCATIONRULE
WHERE RoundingMethod NOT IN ('NEAREST','UP','DOWN','NONE');

-- 8) Effective date range sanity
SELECT COUNT(*) AS invalid_effective_ranges
FROM PLANNING.ALLOCATIONRULE
WHERE EffectiveToDate IS NOT NULL
  AND EffectiveToDate < EffectiveFromDate;

-- 9) AllocationPercentage sanity (assume 0..1)
SELECT COUNT(*) AS invalid_allocation_percentage
FROM PLANNING.ALLOCATIONRULE
WHERE AllocationPercentage IS NOT NULL
  AND (AllocationPercentage < 0 OR AllocationPercentage > 1);

-- 10) TargetSpecification presence (should be non-null)
SELECT COUNT(*) AS null_target_spec
FROM PLANNING.ALLOCATIONRULE
WHERE TargetSpecification IS NULL;
