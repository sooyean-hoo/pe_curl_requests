# Use the reference form of any resource type you want to query for.
curl -G -H  "Accept: application/json"            \
  'http://localhost:8080/pdb/query/v4/resources'  \
  --data-urlencode 'query=["=","exported", true]' | jgrep "type=Host"
