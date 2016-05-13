MASTER='split-master'
curl -k -X GET -H "Accept: pson"  https://"${MASTER}":8140/status/v1/simple
