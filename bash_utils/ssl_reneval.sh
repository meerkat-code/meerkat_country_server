#!/usr/bin/env bash
set -x
### Script for updating ssl certs for country repo nginx
# TO BE RUN BY root
#
### The following args should be passed as env variables for country_server_console_wrapper script
# USERNAME - name of the user in whom home dir meerkat_country_server is checked out
# COUNTRY_NAME - name of deployed country e.g. car or demo
#
echo "$(date) ------- Running SSL reneval."
ACTION=stop SERVICE=nginx country_server_console_wrapper
certbot-auto renew
ACTION=start SERVICE=nginx country_server_console_wrapper
echo "$(date) ------- SSL reneval finished."
