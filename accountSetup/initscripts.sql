-- switch to accountAdmin ROLES
use role accountadmin;

-- create storage integration with GCS

CREATE STORAGE INTEGRATION GCS_snowflake_log
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = GCS
  ENABLED = TRUE
  STORAGE_ALLOWED_LOCATIONS = ('gcs://snowflake-audit-logs/logs/');

-- create external stage   
create or replace stage gcs_snowflake
  url='gcs://snowflake-audit-logs/logs/'
  storage_integration = GCS_snowflake_log;
  
-- create file format for storing into external storage
CREATE FILE FORMAT "SNOWFLAKE_AUDIT_LOG"."PUBLIC".CSV_AUTO
 TYPE = 'CSV'
 COMPRESSION = 'AUTO'
 FIELD_DELIMITER = ','
 RECORD_DELIMITER = '\n'
 SKIP_HEADER = 0
 FIELD_OPTIONALLY_ENCLOSED_BY = 'NONE'
 TRIM_SPACE = TRUE
 ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE
 ESCAPE = 'NONE'
 ESCAPE_UNENCLOSED_FIELD = '\134'
 DATE_FORMAT = 'AUTO'
 TIMESTAMP_FORMAT = 'AUTO'
 NULL_IF = ('\\N');

-- grant access to file format and external stage to public role
GRANT USAGE ON FILE FORMAT "SNOWFLAKE_AUDIT_LOG"."PUBLIC"."CSV_AUTO" TO ROLE "PUBLIC"; 
GRANT USAGE ON STAGE "SNOWFLAKE_AUDIT_LOG"."PUBLIC"."GCS_SNOWFLAKE" TO ROLE "PUBLIC";

-- switch back to public
use role public;
