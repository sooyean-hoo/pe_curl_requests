CONSOLE='console.example.com'
curl -k -X GET https://${CONSOLE}:4433/rbac-api/v1/ds \
  --cert $(puppet config print hostcert) \
  --key $(puppet config print hostprivkey) \
  --cacert $(puppet config print localcacert) \
  -H "Content-Type: application/json" | python -m json.tool
