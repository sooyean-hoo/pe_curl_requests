

curl -k -X GET https://localhost:4433/rbac-api/v1/groups \
  --cert /etc/puppetlabs/puppet/ssl/certs/pemaster.puppetlabs.vm.pem \
  --key /etc/puppetlabs/puppet/ssl/private_keys/pemaster.puppetlabs.vm.pem \
  --cacert /etc/puppetlabs/puppet/ssl/certs/ca.pem \
  -H "Content-Type: application/json"
