#!/bin/bash
# Get the list of environments that the Puppetserver knows about.
# https://docs.puppetlabs.com/puppet/latest/reference/http_api/http_environments.html

CERT="$(puppet agent --configprint hostcert)"
CACERT="$(puppet agent --configprint localcacert)"
PRVKEY="$(puppet agent --configprint hostprivkey)"
OPTIONS="--cert ${CERT} --cacert ${CACERT} --key ${PRVKEY}"
MASTER="$(puppet agent --configprint server)"

/opt/puppetlabs/puppet/bin/curl -s -X GET $OPTIONS "https://${MASTER}:8140/puppet/v3/environments" | python -m json.tool

