#!/bin/bash

if  [[ "help" == "$1" || "$1" =~  [-]+help   ]] ; then     #  ||  -z  "$1"  
	cat << __END
# This script will download the requested version of PE from S3.
# If no version is specified, the latest version will be used. It will
# also resume broken downloads to save time and rename the resultant file.

# INSTALLER CHOICES #
# Either pass these environment variables inline or modify the default
# values (note, it's the value after the ':-' but before the close curly brace }


__END
  exit 0;
fi;


> /tmp/vv.sh
for i  in  /etc/*-release ;  do     cat  $i  |  grep  \=   |  tr  -d  \(\)  >>  /tmp/vv.sh  ;  done ;
.  /tmp/vv.sh ;

cat /tmp/vv.sh

rm     /tmp/vv.sh


ARCH=$(  uname -m  )

#echo id =  $ID ;  
#echo version id = $VERSION_ID ;
#echo arch=$ARCH


#echo u
#cat /etc/issue
#
#echo net
#cat /etc/issue.net
#
#uname -a
#
#
#ls -l /etc

[   "ubuntu"  =  "$ID"  ]  && {
	ARCH=$(  echo $ARCH                |  sed   s/x86_64/amd64/g   )
}


ID=$(  echo $ID            |  sed   -e s/centos/el/g   -e s/redhat/el/g   -e  s/opensuse/sles/g   )


curl --help   >  /dev/null  || {
	 apt update -y && apt upgrade -y
	apt install -y curl     ||   \
	apt install -y php7.0-curl  || \
	yum install --force curl	
	
	 zypper install  -n curl    ||   \
	zypper install -n php7.0-curl  
	 
	 curl --version   > /dev/null
} 


DOWNLOAD_DIST=${DOWNLOAD_DIST:-$ID}
DOWNLOAD_RELEASE=${DOWNLOAD_RELEASE:-$VERSION_ID}
DOWNLOAD_ARCH=${DOWNLOAD_ARCH:-$ARCH}
DOWNLOAD_VERSION=${DOWNLOAD_VERSION:-latest}
echo ======================






cat << __END
DOWNLOAD_DIST=${DOWNLOAD_DIST:-el}
DOWNLOAD_RELEASE=${DOWNLOAD_RELEASE:-7}
DOWNLOAD_ARCH=${DOWNLOAD_ARCH:-x86_64}
DOWNLOAD_VERSION=${DOWNLOAD_VERSION:-latest}
__END
echo ======================



if [[ $DOWNLOAD_VERSION == latest ]]; then
  latest_released_version_number="$(curl -s http://versions.puppet.com.s3-website-us-west-2.amazonaws.com/ | tail -n1)"
  DOWNLOAD_VERSION=${latest_released_version_number:-latest}
fi

tarball_name="puppet-enterprise-${DOWNLOAD_VERSION}-${DOWNLOAD_DIST}-${DOWNLOAD_RELEASE}-${DOWNLOAD_ARCH}.tar.gz"

echo "Downloading PE $DOWNLOAD_VERSION for ${DOWNLOAD_DIST}-${DOWNLOAD_RELEASE}-${DOWNLOAD_ARCH} to: ${tarball_name}"
echo

curl --progress-bar \
  -L \
  -o "./${tarball_name}" \
  -C - \
  "https://pm.puppetlabs.com/cgi-bin/download.cgi?dist=${DOWNLOAD_DIST}&rel=${DOWNLOAD_RELEASE}&arch=${DOWNLOAD_ARCH}&ver=${DOWNLOAD_VERSION}"


( tar  -t -f ./$tarball_name   > /dev/null    && echo  To Continue:  tar -xzvf    ./$tarball_name  )  ||   \
{
	rm   -f        ./$tarball_name    ;
	echo " !!!!!!!!!!    ERROROUS DOWNLOAD : ./$tarball_name   Removed  !!!!!!!!!!!!!!!!!!!" ;


}

#for DIS in ubuntu archlinux centos  debian  brunolimaq/suse_12_1   ; do  docker run --rm -it     -v $PWD:/tmp  -w /tmp/  $DIS  /tmp/download_pe_tarball.sh   ; done

# https://artifactory.delivery.puppetlabs.net/artifactory/generic_enterprise__local/archives/releases/2019.2.2/


#curl  https://artifactory.delivery.puppetlabs.net/artifactory/generic_enterprise__local/archives/releases/2019.2.2/ | grep href | grep puppet | sed -E 's/^.+(puppet.+tar).+$/\1/g'
