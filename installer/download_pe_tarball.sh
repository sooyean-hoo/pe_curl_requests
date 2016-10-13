#!/bin/bash
# This script will download the requested version of PE from S3. It will
# also resume broken downloads to save time and rename the resultant file

# INSTALLER CHOICES #
# Either pass these environment variables inline or modify the default
# values (note, it's the value after the ':-' but before the close curly brace }
DOWNLOAD_DIST=${DOWNLOAD_DIST:-el}
DOWNLOAD_RELEASE=${DOWNLOAD_RELEASE:-7}
DOWNLOAD_ARCH=${DOWNLOAD_ARCH:-x86_64}
DOWNLOAD_VERSION=${DOWNLOAD_VERSION:-latest}

tarball_name="puppet-enterprise-${DOWNLOAD_VERSION}-${DOWNLOAD_DIST}-${DOWNLOAD_RELEASE}-${DOWNLOAD_ARCH}.tar.gz"

echo "Downloading PE $DOWNLOAD_VERSION for ${DOWNLOAD_DIST}-${DOWNLOAD_RELEASE}-${DOWNLOAD_ARCH} to: ${tarball_name}"
echo

curl --progress-bar \
  -L \
  -o "./${tarball_name}" \
  -C - \
  "https://pm.puppetlabs.com/cgi-bin/download.cgi?dist=${DOWNLOAD_DIST}&rel=${DOWNLOAD_RELEASE}&arch=${DOWNLOAD_ARCH}&ver=${DOWNLOAD_VERSION}"

