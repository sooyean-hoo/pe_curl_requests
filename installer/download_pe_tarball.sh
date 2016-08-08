#!/bin/bash
# This script will download the requested version of PE from S3. It will
# also resume broken downloads to save time and rename the resultant file
DOWNLOAD_DIST=${DOWNLOAD_DIST:-el}
DOWNLOAD_RELEASE=${DOWNLOAD_RELEASE:-7}
DOWNLOAD_ARCH=${DOWNLOAD_ARCH:-x86_64}
DOWNLOAD_VERSION=${DOWNLOAD_VERSION:-latest}

curl -L \
  -o "./puppet_enterprise_${DOWNLOAD_DIST}_${DOWNLOAD_RELEASE}_${DOWNLOAD_ARCH}_${DOWNLOAD_VERSION}.tar.gz" \
  -C - \
  "https://pm.puppetlabs.com/cgi-bin/download.cgi?dist=${DOWNLOAD_DIST}&rel=${DOWNLOAD_RELEASE}&arch=${DOWNLOAD_ARCH}&ver=${DOWNLOAD_VERSION}"

