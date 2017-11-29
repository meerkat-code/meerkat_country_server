-- Create user if it doesn't exist already
DO
$body$
BEGIN
   IF NOT EXISTS (
      SELECT
      FROM   pg_catalog.pg_user
      WHERE  usename = 'odk_user') THEN

      CREATE ROLE "odk_user" WITH PASSWORD 'password';
   END IF;
END
$body$;

alter role 'odk_user' with login;
grant all privileges on database "odk_db" to "odk_user";
alter database "odk_db" owner to "odk_user";
\c "odk_db";

-- Create schema if it doesn't exist already
DO
$body$
BEGIN
   IF NOT EXISTS (
      SELECT
      FROM   information_schema.schemata
      WHERE  schema_name = 'odk_db') THEN

      CREATE SCHEMA "odk_db";
   END IF;
END
$body$;

grant all privileges on schema "odk_db" to "odk_user";
