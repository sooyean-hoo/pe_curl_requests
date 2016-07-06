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

Same thing but for windows people, please written with powershell v5
```
 #this is so you can trust your puppet master cert... you can trust it right?.. mine still owes me about $20
 add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

$token = "dear god this is a long variable... like i get we want it unique and it is .. boy it is, but the powerball number is a lot smaller .. just saying"

$servername= "<YOUR_CONSOLE_MASTER>"


#i bet there is a better way to do this too.. but hey 
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("X-Authentication", "$token")
$headers.Add("Content-Type", "application/json")


#get what we have
$results2 = Invoke-RestMethod -Uri "https://${servername}:4433/rbac-api/v1/ds" -Headers $headers  -Method Get
#lets be sure we are bool
$results2.search_nested_groups = [bool]$false
#ps loves objects... really loves them.. so lets be sure we are talking the right way
$body = $results2 | ConvertTo-Json

Invoke-RestMethod -Uri "https://${servername}:4433/rbac-api/v1/ds" -Headers $headers -Method Put -Body $body

```
