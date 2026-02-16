# snowconvert-financial-planning-migration

Migration of a SQL Server–based financial planning application to Snowflake, including schema migration, procedure refactoring, and validation of budgeting and consolidation workflows.

---

## Approach

My approach to this migration focused on understanding what the original SQL Server code was doing from a business and data perspective, and then re-implementing that behavior in a way that fits Snowflake’s execution model.

Rather than attempting a line-by-line translation of procedural SQL Server logic (such as cursors, table variables, and row-by-row control flow), I restructured the implementation to express the same outcomes using set-based aggregation and declarative queries. Where the structure changed, the goal was that the observable behavior and results remained consistent.

Throughout the migration, the emphasis was on:
- Preserving financial correctness
- Maintaining the same validation and decision points
- Making results directly comparable between systems

### Data flow and evaluation strategy

To enable meaningful comparison, I created a representative dataset in SQL Server that exercises the core behaviors of budget consolidation, including:
- Multi-level cost center hierarchies
- Multiple sibling branches
- Leaf-level budget activity
- Multiple hierarchy roots

This data was:
1. Created and validated in SQL Server
2. Exported as CSV
3. Loaded into Snowflake staging tables
4. Promoted into type-enforced tables
5. Validated using schema and data sanity checks

Using identical inputs in both systems made it possible to reason about differences in behavior as migration issues rather than data issues.

### Hierarchy design decisions

The original SQL Server implementation relies on `HIERARCHYID` and procedural traversal logic. Since Snowflake does not support `HIERARCHYID`, I adopted a materialized path representation stored as a string.

Hierarchy construction was implemented as a standalone procedure (`sp_BuildCostCenterHierarchy`) that produces a reusable hierarchy artifact. Treating hierarchy construction as a dependency allowed it to be tested and validated independently before being used by the consolidation procedure.

---

## Scope of Work

The following components were migrated and validated:

- Migration of the Planning schema and all eight core tables:
  - FiscalPeriod  
  - CostCenter  
  - GLAccount  
  - BudgetHeader  
  - BudgetLineItem  
  - AllocationRule  
  - ConsolidationJournal  
  - ConsolidationJournalLine  

- Complete Snowflake implementation of cost center hierarchy construction  
  - [`sp_BuildCostCenterHierarchy.sql`](MigrationMaterials/StoredProcedures/sp_BuildCostCenterHierarchy.sql)

- Migration of supporting views and constraints required by consolidation logic

- Generation of a representative SQL Server dataset and migration into Snowflake for evaluation

- Complete Snowflake implementation of:
  - [`usp_ProcessBudgetConsolidation.sql`](MigrationMaterials/StoredProcedures/usp_ProcessBudgetConsolidation.sql)

- Validation of `usp_ProcessBudgetConsolidation` and all of its dependencies using targeted sanity checks and comparative queries

---

## Use of AI

AI was used as a practical acceleration and reasoning tool throughout the migration, particularly to help design meaningful validation rather than to automate the migration end-to-end.

A key challenge in validating this type of migration is ensuring that the test data actually exercises the important behaviors of the procedures being migrated. I used AI to help reason about what the core functional components of the system were and how to design data that would trigger them in a controlled way.

In particular, AI was used to:
- Build a working understanding of common financial planning concepts reflected in the schema (such as cost center hierarchies, budget rollups, and consolidation boundaries)
- Generate high-level summaries of stored procedures to clarify their intent before refactoring
- Identify the major behavioral components of `usp_ProcessBudgetConsolidation` (for example: hierarchy construction, leaf-level aggregation, hierarchical rollups, and validation logic)
- Help design a representative dataset in SQL Server that tests these components, including multiple hierarchy levels, sibling branches, multiple roots, and leaf-level budgets
- Accelerate the creation of validation and sanity-check queries used to compare behavior between SQL Server and Snowflake
- Assist with portions of the migrated code for supporting objects and boilerplate logic, with all outputs treated as starting points and reviewed and refined.

Overall, AI helped reduce iteration time and made it feasible to design broader validation coverage than would have been practical otherwise, while keeping all architectural and correctness decisions explicitly human-driven.

---

## Testing and Validation Overview

Validation focused on confirming that the Snowflake implementation behaves the same as the SQL Server version when given the same inputs.

Rather than relying on a single check, validation was performed at multiple levels:

1. **Input consistency**  
   Leaf-level totals were compared between SQL Server and Snowflake to confirm that consolidation inputs matched exactly.

2. **Hierarchical aggregation behavior**  
   Rollup results were compared to verify that parent cost centers equal the sum of their descendants and that hierarchy boundaries are respected.

3. **End-to-end outputs**  
   Final consolidated results were validated at the root level to confirm overall correctness.

### Targeted procedure tests

In addition to comparative queries, I generated targeted tests to validate key execution paths of the consolidation procedure:

- **New target creation (end-to-end execution)**  
  Validates parameter handling, hierarchy construction, rollup aggregation, and insertion into a newly created target budget.  
  - [`03_consolidation_new_target.sql`](MigrationMaterials/Tests/Snowflake/Validation/03_consolidation_new_target.sql)

- **Provided target execution**  
  Exercises the alternate code path where an existing target budget is supplied and confirms deterministic behavior.  
  - [`04_consolidation_target_provided.sql`](MigrationMaterials/Tests/Snowflake/Validation/04_consolidation_target_provided.sql)

- **Status validation**  
  Confirms that consolidation is rejected for budgets in invalid states (e.g., DRAFT).  
  - [`05_consolidation_status_validation.sql`](MigrationMaterials/Tests/Snowflake/Validation/05_consolidation_status_validation.sql)

- **Run traceability and determinism**  
  Confirms that repeated executions are append-only and that results can be attributed to individual runs via `SourceReference`.  
  - [`06_consolidation_run_traceability.sql`](MigrationMaterials/Tests/Snowflake/Validation/06_consolidation_run_traceability.sql)

### Intercompany elimination note

The SQL Server procedure includes logic for intercompany eliminations. However, the provided schema enforces a unique key across the identifying fields used for elimination pairing. This constraint prevents multiple qualifying rows from existing simultaneously, making the elimination path unreachable in both SQL Server and Snowflake.

This behavior was documented rather than altered to ensure the migrated procedure reflects the observable behavior of the original system.

---

## Validation Evidence

The following sections show representative comparisons between SQL Server and Snowflake using identical input data.

### Leaf-Level Totals Comparison

This comparison verifies that **consolidation inputs are identical** between SQL Server and Snowflake before any hierarchical logic is applied. Because all rollups are computed from leaf values, matching results here strongly constrain the space of possible downstream errors.

**Validation scripts:**
- [Snowflake: 02_leaf_level_totals.sql](MigrationMaterials/Tests/Snowflake/Validation/Evidence/02_leaf_level_totals.sql)
- [SQL Server: 02_leaf_level_totals.sql](MigrationMaterials/Tests/SQLServer_Source/Validation/Evidence/02_leaf_level_totals.sql)

**SQL Server — Leaf-level totals**  
*Sum of final budget amounts at leaf cost centers for the source budget. These values represent the raw inputs to consolidation in the original system.*

![SQL Server leaf totals](MigrationMaterials/Docs/images/SQLServer_LeafLevelTotals.png)

**Snowflake — Leaf-level totals**  
*The same aggregation computed in Snowflake using the migrated data. Matching totals confirm correct data migration and input consistency.*

![Snowflake leaf totals](MigrationMaterials/Docs/images/Snowflake_LeafLevelTotals.png)

---

### Hierarchy Rollup Comparison

This comparison verifies that **hierarchical aggregation behavior is preserved**, including correct parent–child relationships and summation across multiple hierarchy levels.

**Validation scripts:**
- [Snowflake: 01_hierarchy_rollup_equivalence.sql](MigrationMaterials/Tests/Snowflake/Validation/Evidence/01_hierarchy_rollup_equivalence.sql)
- [SQL Server: 01_hierarchy_rollup_equivalence.sql](MigrationMaterials/Tests/SQLServer_Source/Validation/Evidence/01_hierarchy_rollup_equivalence.sql)

**SQL Server — Hierarchical rollup**  
*Rollup totals computed using the original SQL Server hierarchy logic, showing direct and aggregated amounts at each cost center level.*

![SQL Server hierarchy rollup](MigrationMaterials/Docs/images/SQLServer_Hierarchy_Rollup_Equivalence.png)

**Snowflake — Hierarchical rollup**  
*Equivalent rollup computed in Snowflake using a materialized-path hierarchy and set-based aggregation. Matching values confirm preserved rollup semantics.*

![Snowflake hierarchy rollup](MigrationMaterials/Docs/images/Snowflake_Hierarchy_Rollup_Equivalence.png)

---

### Consolidated Root-Level Totals

This view validates **end-to-end consolidation correctness** by confirming that final totals at each hierarchy root match expectations after all rollups have been applied.

**Validation script:**
- [Snowflake: 03_consolidated_root_level_totals.sql](MigrationMaterials/Tests/Snowflake/Validation/Evidence/03_consolidated_root_level_totals.sql)

**Snowflake — Consolidated totals by root**  
*Final consolidated amounts at the top-level cost centers. These totals reflect the complete execution of hierarchy construction and rollup logic.*

![Snowflake root totals](MigrationMaterials/Docs/images/Snowflake_RootLevelTotals.png)
