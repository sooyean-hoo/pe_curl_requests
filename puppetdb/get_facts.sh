curl -X GET \
  --tlsv1 \
  --data-urlencode query='["and", ["=", "name", "osfamily"], ["=", "value", "RedHat"]]' \
  --cert   $(puppet config print hostcert) \
  --key    $(puppet config print hostprivkey) \
  --cacert $(puppet config print localcacert) \
  https://$(puppet config print server):8081/pdb/query/v4/facts
