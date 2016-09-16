#!/bin/bash

PUPPETDB=$(puppet config print server)

curl -X GET \
  --tlsv1 \
  --data-urlencode 'query=["and", ["=", "type", "Package"], ["=", "certname", "gary.puppetlabs.vm"]]' \
  --cert   $(puppet config print hostcert) \
  --key    $(puppet config print hostprivkey) \
  --cacert $(puppet config print localcacert) \
  https://"${PUPPETDB}":8081/pdb/query/v4/resources | python -m json.tool
