#!/bin/bash
# This script searches the puppetserver API for all known classes that match ^pe_.*
# Adjust the search pattern to tailor this script to your particular search pattern.

# Set variables for the curl.
CERT="/etc/puppetlabs/puppet/ssl/certs/pe-internal-classifier.pem"
KEY="/etc/puppetlabs/puppet/ssl/private_keys/pe-internal-classifier.pem"
CACERT="/etc/puppetlabs/puppet/ssl/certs/ca.pem"

/opt/puppetlabs/puppet/bin/curl -s -X GET \
                                --header "Content-Type: application/json" \
                                --cert   "$CERT" \
                                --key    "$KEY" \
                                --cacert "$CACERT" \
                                "https://$(hostname -f):8140/puppet/v3/resource_types/^pe_.*?environment=production&kind=class" | python -m json.tool | grep \"name\"

