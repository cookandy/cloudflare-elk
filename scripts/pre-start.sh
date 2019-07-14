#!/bin/bash

# check to see if required variables are set
[[ -z ${CF_FIELDS} ]] && echo "CF_FIELDS is required. exiting!" && exit 1
[[ -z ${CF_EMAIL} ]] && echo "CF_EMAIL is required. exiting!" && exit 1
[[ -z ${CF_API_KEY} ]] && echo "CF_API_KEY is required. exiting!" && exit 1
[[ -z ${CF_ZONES} ]] && echo "CF_ZONES is required. exiting!" && exit 1

# set default fetch time to 5 min, and clean logs time to 60 min (if not set)
[[ -z ${CF_LOGS_FETCH_MIN} ]] && CF_LOGS_FETCH_MIN="5"
[[ -z ${CF_LOGS_FETCH_SCHEDULE} ]] && CF_LOGS_FETCH_SCHEDULE="*/5 * * * *"
[[ -z ${CF_LOGS_CLEAN_MIN} ]] && CF_LOGS_CLEAN_MIN="60"

# set default clean indices schedule to once/day (if not set)
[[ -z ${ES_CLEAN_INDICES_SCHEDULE} ]] && ES_CLEAN_INDICES_SCHEDULE="0 0 * * *"

# echo system vars from docker so they're available in cron
printenv | grep -v "no_proxy" >> /etc/environment

# update and load the cron
echo "$CF_LOGS_FETCH_SCHEDULE /scripts/fetch-cf-logs.sh" >> /crons.conf
echo "$ES_CLEAN_INDICES_SCHEDULE /scripts/clean-old-indices.sh" >> /crons.conf
crontab /crons.conf

# download geolite db
curl http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.mmdb.gz | gunzip > /GeoLite2-City.mmdb

# now call the original elk start script
/usr/local/bin/start.sh
