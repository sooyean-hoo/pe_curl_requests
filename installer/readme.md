# Issues
The original version [Original GitHub link](https://github.com/glarizza/pe_curl_requests ) cannot be used with different distributions. It is stated to be able to be used with multi-distributions: 
- SUSE
- Centos
- RHEL
- Ubuntu

However the original script can only able to detect the latest version and download only the el 7 x86-64 version only. There is no mechanism to detect the system which it is run on, nor there is any to check that the downloaded resource is a valid one.

# Objective
Add the above said features to the scripts

*Primary*
1.  Detect the system which it is run on

    - Determine the Distribution Name
    - Determine the Distribution Version
    - Determine the Distribution Architecture

2. Check that the downloaded resource

*Secondary*
1. Batch Download
2. More effective query


# Benefit
- Faster the deployments, as it is automated.
- Updated Scripts can be download via https from GitHub's RAW mode and run.


# Requirement
- Need to be on Puppet Network to Enjoy the Full Functions of this script.

# Known Problems
It can only worked with (For Now): 
- SUSE
- Centos
- RHEL
- Ubuntu

# Operation
Run with --help for a quick overview.