SET_SERVER=$(puppet config print server)
CONSOLE="${CONSOLE:-$SET_SERVER}"

curl -X GET \
  --tlsv1 \
  --data-urlencode query='["and", ["=", "name", "osfamily"], ["=", "value", "RedHat"]]' \
  --cert   $(puppet config print hostcert) \
  --key    $(puppet config print hostprivkey) \
  --cacert $(puppet config print localcacert) \
  https://${CONSOLE}:8081/pdb/query/v4/facts
