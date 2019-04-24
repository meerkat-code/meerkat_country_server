#!/usr/bin/env bash

### The following args should be passed as env variables
# USERNAME - name of the user in whom home dir meerkat_country_server is checked out
# COUNTRY_NAME - name of deployed country e.g. car or demo
# ACTION - docker-compose action you'd like to use. e.g. 'up -d', 'stop', 'start', 'rm -v'
# [optional] SERVICE - name of docker service e.g. odk, nest, nginx
#
# Example usage in crontab:
# @reboot USERNAME=ec2-user COUNTRY_NAME=car ACTION='up -d' country_server_console_wrapper.sh  >> /var/log/country_startup.log 2>&1


/usr/local/bin/docker-compose -f /home/${USERNAME}/meerkat_country_server/docker-compose.yml -f /home/${USERNAME}/meerkat_${COUNTRY_NAME}/nest/${COUNTRY_NAME} ${ACTION} ${SERVICE}