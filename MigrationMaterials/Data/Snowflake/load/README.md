# Load Pipeline (SQL Server → Snowflake)

This folder contains scripts that load data exported from SQL Server (CSV format) into Snowflake using a two-stage process:
1. **Raw landing** into temporary staging tables with all columns defined as `VARCHAR`, and
2. **Typed loading** into final Snowflake tables with explicit type enforcement and validation.

This approach avoids COPY-time parsing failures, makes casting errors observable, and mirrors production-grade migration pipelines.

### Execution order

1) Run `00_setup.sql`  
2) Upload CSV files to `@PLANNING_STG.LOAD_STAGE`  
3) Run `01_create_raw_tables.sql`  
4) Run `02_copy_into_raw_tables.sql`  
5) Run `03_load_type_enforced.sql`
