#!/bin/bash

echo "---- Modifying ODK Aggregate server conf template ----"
envsubst < /etc/nginx/sites-available/odk_aggregate_https.template | tee /etc/nginx/sites-available/odk_aggregate_https && echo

echo "---- Creating symlinks ----"
mkdir -p /etc/nginx/sites-enabled
rm -f /etc/nginx/sites-enabled/odk_aggregate_http*
ln -s /etc/nginx/sites-available/odk_aggregate_http /etc/nginx/sites-enabled/odk_aggregate_http
ln -s /etc/nginx/sites-available/odk_aggregate_https /etc/nginx/sites-enabled/odk_aggregate_https

nginx -g 'daemon off;'
