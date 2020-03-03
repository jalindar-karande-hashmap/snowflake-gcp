use role accountadmin;

create or replace procedure unload_load_history()
  returns string not null
  language javascript
  as
  $$
    var sql_command = ""
    var sql_command = sql_command.concat("copy into @public.gcs_snowflake/load_history","/",Date.now()," from (select SCHEMA_NAME, TABLE_NAME, sum(ERROR_COUNT), sum(ROW_COUNT) from SNOWFLAKE.ACCOUNT_USAGE.LOAD_HISTORY group by SCHEMA_NAME, TABLE_NAME) file_format = (format_name = 'CSV_AUTO') overwrite=true;");
    var statement1 = snowflake.createStatement( {sqlText: sql_command} );
    var result_set1 = statement1.execute();
  return sql_command;
  $$;
  
ALTER PROCEDURE unload_load_history () EXECUTE AS OWNER;
  
 
create or replace task logs_unload_task
  warehouse = COMPUTE_WH
  SCHEDULE = '60 MINUTE'
  as
  call unload_load_history();
  
ALTER TASK logs_unload_task resume;

