#!/bin/bash

MASTER='split-master'
ENVIRONMENT='production'
curl -k -X GET -H "Accept: pson" https://"${MASTER}":8140/puppet/v3/status/:name?environment="${ENVIRONMENT}" | python -m json.tool
