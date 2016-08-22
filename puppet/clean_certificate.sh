#!/bin/bash

CA='puppetca.puppetdebug.vlan'
NODE='mynode.puppetdebug.vlan'

curl -X DELETE \
  -H "Content-Type: text/pson" \
  --tlsv1 \
  --cert   $(puppet config print hostcert) \
  --key    $(puppet config print hostprivkey) \
  --cacert $(puppet config print localcacert) \
  https://${CA}:8140/puppet-ca/v1/certificate_status/${NODE}?environment=production | python -m json.tool
