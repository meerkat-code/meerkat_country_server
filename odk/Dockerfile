FROM tomcat:8-jre8

ENV BUILD_DEPS='postgresql netcat curl zip gettext' \
    AGGREGATE_URL='https://s3-eu-west-1.amazonaws.com/test-meerkat/aggregate' \
    DBCONNECTOR_VERSION='42.0.0'

RUN apt-get update \
    && apt-get install -y ${BUILD_DEPS} --no-install-recommends \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*; exit 0

RUN curl -OL https://jdbc.postgresql.org/download/postgresql-${DBCONNECTOR_VERSION}.jar \
    && mv postgresql-${DBCONNECTOR_VERSION}.jar ${CATALINA_HOME}/lib/

ADD create_db_and_user.sql /create_db_and_user.sql
RUN curl -L ${AGGREGATE_URL}/ODKAggregate.war  --output /ODKAggregate.war

#Sets defaults env vars
ENV DB_HOSTNAME='localhost' \
    DB_PORT='5432' \
    DB_DATABASE='odk_db' \
    DB_SCHEMA='odk_db' \
    DB_USER='odk_user' \
    DB_PASSWORD='password' \
    ODK_PORT='80' \
    ODK_PORT_SECURE='443' \
    ODK_HOSTNAME='localhost' \
    ODK_ADMIN_USER='' \
    ODK_ADMIN_USERNAME='dev' \
    ODK_AUTH_REALM='Meerkat ODK Aggregate' \
    ODK_CHANNELTYPE='REQUIRES_SECURE_CHANNEL'

#Copy self-signed certs and server configs
COPY config/server.xml.template /usr/local/tomcat/conf/server.xml.template
COPY config/self-signed-certs-tomcat/server.jks /server.jks

#Copy the run script and allow executing it
ADD run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE ${ODK_PORT}
ENTRYPOINT ["/run.sh"]
