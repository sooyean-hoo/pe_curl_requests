#!/bin/bash
CONSOLE='split-console.puppetlabs.vm'

curl -k -X GET https://${CONSOLE}:4433/rbac-api/v1/groups \
  --cert $(puppet config print hostcert) \
  --key $(puppet config print hostprivkey) \
  --cacert $(puppet config print localcacert) \
  -H "Content-Type: application/json" | python -m json.tool
