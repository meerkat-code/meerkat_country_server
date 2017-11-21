create database "odk_db";
create user "odk_user" with unencrypted password 'password';
grant all privileges on database "odk_db" to "odk_user";
alter database "odk_db" owner to "odk_user";
\c "odk_db";
create schema "odk_db";
grant all privileges on schema "odk_db" to "odk_user";
