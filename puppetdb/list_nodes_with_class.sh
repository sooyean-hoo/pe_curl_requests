#!/bin/bash

SET_SERVER=$(puppet config print server)
PUPPETDB="${PUPPETDB:-$SET_SERVER}"

curl -X GET \
  --tlsv1 \
  --stderr /dev/null \
  --data-urlencode 'query=["and",["=","type","Class"],["=","title","Profile::Base"]]' \
  --cert   $(puppet config print hostcert) \
  --key    $(puppet config print hostprivkey) \
  --cacert $(puppet config print localcacert) \
  https://"${PUPPETDB}":8081/pdb/query/v4/resources | python -m json.tool \
  | grep 'certname'
