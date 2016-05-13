#!/bin/bash

nc_backup='node_classifier_dump.json'
[[ -f $nc_backup ]] || { echo "Unable to find NC backup: ${nc_backup}" >&2; exit 1; }

curl -X POST -H 'Content-Type: application/json' \
  --cert "$(puppet config print hostcert)" \
  --key "$(puppet config print hostprivkey)" \
  --cacert "$(puppet config print localcacert)" \
  -d @$nc_backup \
  "https://$(hostname -f):4433/classifier-api/v1/import-hierarchy"

