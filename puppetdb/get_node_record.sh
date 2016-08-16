#!/bin/bash

PUPPETDB='puppetdb.puppetdebug.vlan'
NODE='mynode.puppetdebug.vlan'

curl -X GET \
  --tlsv1 \
  --cert   $(puppet config print hostcert) \
  --key    $(puppet config print hostprivkey) \
  --cacert $(puppet config print localcacert) \
  https://${PUPPETDB}:8081/pdb/query/v4/nodes/${NODE}
