# Kurve Snowflake Native Container App
Kurve automates extraction of primary keys, foreign keys, date keys and other critical relational metadata and constructs a visual metadata graph.  Kurve then allows for multi-table data preparation for analytics and AI workloads by leveraging the metadata graphs it builds.

## Post-installation instructions:
```sql
-- Create a database for Kurve to write to or use an existing one
--CREATE DATABASE IF NOT EXISTS MY_OUTPUT_DB;

-- grants the user needs to run after installation
GRANT USAGE ON DATABASE MY_OUTPUT_DB TO APPLICATION <application_name>;

-- create a schema if needed or use an existing one
-- CREATE SCHEMA IF NOT EXISTS MY_OUTPUT_DB.MY_OUTPUT_SCHEMA;

-- grant usage to the application on your output schema
GRANT USAGE ON SCHEMA MY_OUTPUT_DB.MY_OUTPUT_SCHEMA TO APPLICATION <application_name>;

-- grant other permissions on output schema to application
GRANT CREATE TEMPORARY TABLE ON SCHEMA MY_OUTPUT_DB.MY_OUTPUT_SCHEMA TO APPLICATION <application_name>;

GRANT CREATE TABLE ON SCHEMA MY_OUTPUT_DB.MY_OUTPUT_SCHEMA TO APPLICATION <application_name>;

GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA MY_OUTPUT_DB.MY_OUTPUT_SCHEMA TO APPLICATION <application_name>;

-- grant future ownership of Kurve-created table to your rule
-- may need to use ACCOUNTADMIN or admin role...
GRANT SELECT ON FUTURE TABLES IN SCHEMA MY_OUTPUT_DB.MY_OUTPUT_SCHEMA TO ROLE <my_role>;

-- create a warehouse for the application to use
-- MUST BE NAME 'KURVE_WAREHOUSE'!
CREATE WAREHOUSE IF NOT EXISTS KURVE_WAREHOUSE
WAREHOUSE_SIZE = 'X-SMALL';

-- grant usage on kurve warehouse to app
GRANT USAGE ON WAREHOUSE KURVE_WAREHOUSE TO APPLICATION <application_name>;

-- grant the application privileges on SNOWFLAKE_SAMPLE_DATA for sample tests
GRANT IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE_SAMPLE_DATA TO APPLICATION <application_name>;
```

## Check the status of the application after installation
```sql
-- check the status first and when it is READY get the endpoint
CALL <application_name>.kurve_core.service_status();

-- if READY get endpoint and paste into browser
CALL <application_name>.kurve_core.service_endpoint();
```

## Add more data sources
grant usage on <database> to application <application_name>;
grant usage on <database.schema> to application <application_name>;
grant select on <database.schema.table> to application <application_name>;

Check out the docs here: [https://kurveai.github.io/kurvedocs/](https://kurveai.github.io/kurvedocs/)
