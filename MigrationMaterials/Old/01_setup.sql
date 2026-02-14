-- Use existing compute
USE WAREHOUSE COMPUTE_WH;

-- Use a DB you have access to
USE DATABASE SNOWFLAKE_LEARNING_DB;

-- Use PUBLIC schema (since PLANNING isn't sticking / not authorized)
USE SCHEMA PUBLIC;

-- Recommended session settings
ALTER SESSION SET TIMEZONE = 'UTC';
ALTER SESSION SET TIMESTAMP_TYPE_MAPPING = 'TIMESTAMP_NTZ';

-- Verify context
SELECT
  CURRENT_ROLE()      AS role,
  CURRENT_WAREHOUSE() AS warehouse,
  CURRENT_DATABASE()  AS database,
  CURRENT_SCHEMA()    AS schema;
