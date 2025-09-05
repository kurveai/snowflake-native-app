CREATE APPLICATION ROLE IF NOT EXISTS kurve_app_role;

CREATE SCHEMA IF NOT EXISTS kurve_core;

--CREATE SCHEMA IF NOT EXISTS kurve_output;

GRANT USAGE ON SCHEMA kurve_core TO APPLICATION ROLE kurve_app_role;
--GRANT USAGE ON SCHEMA kurve_output TO APPLICATION ROLE kurve_app_role;
--GRANT CREATE TABLE ON SCHEMA kurve_output TO APPLICATION ROLE kurve_app_role;
--GRANT CREATE VIEW ON SCHEMA kurve_output TO APPLICATION ROLE kurve_app_role;
--GRANT SELECT, INSERT, UPDATE, DELETE ON FUTURE TABLES IN SCHEMA kurve_output TO APPLICATION ROLE kurve_app_role;

-- taking this outside of the stored procedure
--LET pool_name VARCHAR := 'KURVE_COMPUTE_POOL';

CREATE COMPUTE POOL IF NOT EXISTS KURVE_COMPUTE_POOL --IDENTIFIER('KURVE_COMPUTE_POOL')
      MIN_NODES = 1
      MAX_NODES = 1
      INSTANCE_FAMILY = CPU_X64_M
      AUTO_RESUME = true;


CREATE SERVICE IF NOT EXISTS kurve_core.kurve_service
      IN COMPUTE POOL KURVE_COMPUTE_POOL --identifier('KURVE_COMPUTE_POOL')
      FROM spec='service_spec.yml';

-- could this be the required statement?
GRANT USAGE ON SERVICE kurve_core.kurve_service TO APPLICATION ROLE kurve_app_role;

-- necessary for hitting endpoint on browser?
GRANT SERVICE ROLE KURVE_CORE.KURVE_SERVICE!all_endpoints_usage TO APPLICATION ROLE kurve_app_role;

--GRANT USAGE ON WAREHOUSE my_app_wh TO APPLICATION ROLE my_app.app_user_role;

CREATE OR REPLACE PROCEDURE kurve_core.service_status()
RETURNS TABLE ()
LANGUAGE SQL
EXECUTE AS OWNER
AS $$
   BEGIN
         LET stmt VARCHAR := 'SHOW SERVICE CONTAINERS IN SERVICE kurve_core.kurve_service';
         LET res RESULTSET := (EXECUTE IMMEDIATE :stmt);
         RETURN TABLE(res);
   END;
$$;


CREATE OR REPLACE PROCEDURE kurve_core.service_endpoint()
RETURNS TABLE ()
LANGUAGE SQL
EXECUTE AS OWNER
AS $$
  BEGIN
    LET stmt VARCHAR := 'SHOW ENDPOINTS IN SERVICE kurve_core.kurve_service';
    LET res RESULTSET := (EXECUTE IMMEDIATE :stmt);
    RETURN TABLE(res);
  END;
$$;


CREATE OR REPLACE PROCEDURE kurve_core.get_snowhealth()
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
    service_endpoint_url VARCHAR;
    json_response VARCHAR;
    -- IMPORTANT: Replace 'YOUR_SERVICE_NAME' with the actual name of your service
    -- as defined in your CREATE SERVICE statement.
    service_name VARCHAR := 'KURVE_SERVICE';
    endpoint_path VARCHAR := '/snowhealth';
BEGIN
    -- Get the internal URL for the specified service and endpoint path.
    -- SYSTEM$GET_SERVICE_ENDPOINT_URL is used for internal service communication.
    service_endpoint_url := SYSTEM$GET_SERVICE_ENDPOINT_URL(service_name, endpoint_path);

    -- Call the Python UDF to fetch the JSON from the internal endpoint
    json_response := KURVE_CORE.GET_JSON_FROM_INTERNAL_ENDPOINT(service_endpoint_url);

    RETURN json_response;
END;
$$;


GRANT USAGE ON PROCEDURE kurve_core.service_status() TO APPLICATION ROLE kurve_app_role;
GRANT USAGE ON PROCEDURE kurve_core.service_endpoint() TO APPLICATION ROLE kurve_app_role;
GRANT USAGE ON PROCEDURE kurve_core.get_snowhealth() TO APPLICATION ROLE kurve_app_role;
