# snowconvert-financial-planning-migration
Migration of a SQL Server financial planning application to Snowflake, including schema and stored procedure refactoring for budgeting, allocation, consolidation, and financial close workflows.



## *Use of AI and Approach*
I used AI as a productivity and reasoning aid throughout the migration.

I used it early on to identify and reason about SQL Server features that do not have direct Snowflake equivalents (such as FILESTREAM, cursor-based processing, and certain transaction patterns), which helped guide design decisions during schema and procedure refactoring.

Because I am not deeply familiar with enterprise financial planning systems, I also used AI to quickly understand the typical structure and workflows of these systems (cost center hierarchies, budget consolidation, intercompany eliminations, and allocation rules). This helped me reason about the intent behind the schema and stored procedures rather than treating them as opaque SQL.

To understand procedural logic, I used AI to generate high-level natural language summaries of the stored procedures. This made it easier to separate business behavior from SQL Server–specific implementation details.

AI was also used to generate initial versions of migrated tables, views, and some of the procedure logic. These drafts were treated as starting points only. All structural decisions—such as replacing cursor-based hierarchy traversal with set-based rollups using a materialized path—were manually reasoned about and refined.

Finally, I used AI to help design comprehensive test cases and sanity checks, including example datasets that exercise hierarchy depth, sibling rollups, intercompany activity, and fiscal period coverage. These tests were based on my understanding of the procedures’ assumptions and failure modes and were intended to validate semantic correctness rather than just successful execution.



## *Testing and Validation Plan*
My validation approach was to compare Snowflake results directly against SQL Server using the same input data, effectively using the procedure output in SQL Server as a baseline of accuracy. As part of this, I created several sanity checks on the generated data in the SQL server to catch broken assumptions early (hierarchy integrity, entity parsing, intercompany mappings, and period coverage) so that any discrepancies discovered later could be attributed to migration logic rather than data issues.

For consolidation, this validation would include:

Aggregate comparisons by account, cost center, and fiscal period

Verifying parent cost centers equal the sum of their descendants

Ensuring overall totals match when eliminations are disabled



## *Key Design Direction*

My approach to migrating the consolidation logic was intentionally not a 1:1 translation of the SQL Server implementation. Rather than attempting to replicate cursor-based, procedural control flow in Snowflake, I was in the process of restructuring the logic to capture the core business behavior—hierarchical rollups and aggregation—using set-based operations.

Specifically, the goal was to express consolidation as a series of declarative aggregations that operate over the cost center hierarchy in a single pass, allowing Snowflake to parallelize the work naturally. This approach avoids procedural bottlenecks and better matches Snowflake’s execution model, even though I did not fully complete the final procedure within the time window.

The focus throughout was on preserving business correctness while adapting the implementation to patterns that scale well in Snowflake, rather than reproducing SQL Server constructs that do not translate directly.
