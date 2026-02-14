CREATE OR REPLACE TABLE PLANNING.ALLOCATIONRULE (
  AllocationRuleID         INT            NOT NULL,
  RuleCode                 VARCHAR(30)    NOT NULL,
  RuleName                 VARCHAR(100)   NOT NULL,
  RuleDescription          VARCHAR(500)   NULL,
  RuleType                 VARCHAR(20)    NOT NULL,   -- DIRECT, STEP_DOWN, RECIPROCAL, ACTIVITY_BASED
  AllocationMethod         VARCHAR(20)    NOT NULL,   -- FIXED_PCT, HEADCOUNT, SQUARE_FOOTAGE, REVENUE, CUSTOM

  SourceCostCenterID       INT            NULL,
  SourceCostCenterPattern  VARCHAR(50)    NULL,
  SourceAccountPattern     VARCHAR(50)    NULL,

  TargetSpecification      VARIANT        NOT NULL,   -- store parsed XML or raw string
  AllocationBasis          VARCHAR(30)    NULL,
  AllocationPercentage     NUMBER(8,6)    NULL,
  RoundingMethod           VARCHAR(10)    NOT NULL,
  RoundingPrecision        INT            NOT NULL,
  MinimumAmount            NUMBER(19,4)   NULL,

  ExecutionSequence        INT            NOT NULL,
  DependsOnRuleID          INT            NULL,

  EffectiveFromDate        DATE           NOT NULL,
  EffectiveToDate          DATE           NULL,
  IsActive                 BOOLEAN        NOT NULL,

  CreatedByUserID          INT            NULL,
  CreatedDateTime          TIMESTAMP_NTZ  NOT NULL,
  ModifiedByUserID         INT            NULL,
  ModifiedDateTime         TIMESTAMP_NTZ  NOT NULL
);
