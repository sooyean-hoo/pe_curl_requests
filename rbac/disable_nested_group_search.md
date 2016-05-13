# Console RBAC: Disable Nested Group Search

When the PE console is configured to use LDAP, it can sometimes be very slow to process a login. This is because a nested group search is being performed, which is very inefficient.

https://docs.puppet.com/pe/latest/rbac_dsref_v1.html#note-nested-groups

To drastically speed up LDAP login time, run the following commands:


1. Grab the current LDAP config from the console:

```
curl -k -X GET https://<YOUR_CONSOLE_MASTER>:4433/rbac-api/v1/ds -H "X-Authentication:$TOKEN" > ds.json
```

1. Edit the resultant `ds.json` file changing only the search_nested_groups field from `true` to `false`.
1. Post the new config to the console

```
curl -k https://<YOUR_CONSOLE_MASTER>:4433/rbac-api/v1/ds -H "X-Authentication:$TOKEN" -H "Content-Type: application/json" -X PUT --data @new_ds.json
```

