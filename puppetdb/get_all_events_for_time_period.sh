#!/bin/bash
# This script searches PuppetDB's events endpoint for all events between a set
# time period (24 hours before right now and 24 hours after right now).

PUPPETDB='pe-201620-master.puppetdebug.vlan'
TOMORROW=`date -d '+1 day' -Isec`
YESTERDAY=`date -d '-1 day' -Isec`

# Other individual queries...
#--data-urlencode "query=[\">\", \"run_end_time\", \"${YESTERDAY}\"]" \
#--data-urlencode "query=[\"<\", \"run_end_time\", \"${TOMORROW}\"]" \

curl -X GET \
  --tlsv1 \
  --data-urlencode "query=[\"and\", [\">\", \"run_end_time\", \"${YESTERDAY}\"], [\"<\", \"run_end_time\", \"${TOMORROW}\"]]" \
  --cert   $(puppet config print hostcert) \
  --key    $(puppet config print hostprivkey) \
  --cacert $(puppet config print localcacert) \
  https://${PUPPETDB}:8081/pdb/query/v4/events | python -m json.tool
