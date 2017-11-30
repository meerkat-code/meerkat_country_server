CREATE DATABASE odk_db;

CREATE ROLE odk_user WITH PASSWORD 'password';

ALTER ROLE odk_user WITH login;
GRANT ALL PRIVILEGES ON DATABASE odk_db TO odk_user;
ALTER DATABASE odk_db owner TO odk_user;
\c odk_db;

CREATE SCHEMA odk_db;

GRANT ALL PRIVILEGES ON schema odk_db TO odk_user;
