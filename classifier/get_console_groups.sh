#!/bin/bash
CONSOLE='pe-385-master.puppetdebug.vlan'

curl -k -X GET https://${CONSOLE}:4433/classifier-api/v1/groups \
  --cert $(puppet config print hostcert) \
  --key $(puppet config print hostprivkey) \
  --cacert $(puppet config print localcacert) \
  -H "Content-Type: application/json" | python -m json.tool
