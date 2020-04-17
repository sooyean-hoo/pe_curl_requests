#!/bin/bash


Dist="";
DistV="";
DArch="";

DOWNLOAD_VERSION=${DOWNLOAD_VERSION:-latest}

if [[ $DOWNLOAD_VERSION == latest ]]; then
  latest_released_version_number="$(curl -s http://versions.puppet.com.s3-website-us-west-2.amazonaws.com/ | tail -n1)"
  DOWNLOAD_VERSION=${latest_released_version_number:-latest}
fi;

function getAllVersions(){

	 > /tmp/lst$$.txt.sh

	  > /tmp/lst$$.txt.d
	  > /tmp/lst$$.txt.distV
	  echo ${DOWNLOAD_VERSION} > /tmp/lst$$.txt.Version


	  > /tmp/lst$$.txt
	curl  https://artifactory.delivery.puppetlabs.net/artifactory/generic_enterprise__local/archives/releases/${DOWNLOAD_VERSION}/ | grep href | grep puppet |   grep tar.gz   | sed -E 's/^.+(puppet.+tar.gz).+$/\1/g'    |  sort  -u  | tee  /tmp/lst$$.txt
	
	for  line in  $(    cat  /tmp/lst$$.txt  |  sed -E 's/.tar.gz$/ /g'     )   ; do 

		echo $line     |  IFS=-     read   p e v d distV arch  ;

			echo $line | cut -d- -f4  >> /tmp/lst$$.txt.d
			echo $line | cut -d- -f5  >> /tmp/lst$$.txt.distV
			echo $line | cut -d- -f6  >> /tmp/lst$$.txt.arch
 
			echo  DOWNLOAD_DIST=$(         tail -1  /tmp/lst$$.txt.d          )   DOWNLOAD_RELEASE=$(   tail -1  /tmp/lst$$.txt.distV    ) DOWNLOAD_ARCH=$(        tail -1  /tmp/lst$$.txt.arch      )  DOWNLOAD_VERSION=$(   tail -1  /tmp/lst$$.txt.Version  )  \
		   $0         >>    /tmp/lst$$.txt.sh ;

	done  ;

	
	for  line in  $(    cat  /tmp/lst$$.txt  |  sed -E 's/.tar$/ /g'     )   ; do 

		echo $line     |  IFS=-     read   p e v d distV arch  ;

			echo $line | cut -d- -f4  >> /tmp/lst$$.txt.d
			echo $line | cut -d- -f5  >> /tmp/lst$$.txt.distV
			echo $line | cut -d- -f6  >> /tmp/lst$$.txt.arch
 
 
 
			
	
	done  ;
}


if  [[  "" != "$HELP" ||  "dl" == "$1" ||  "$dl" == "all"    \
         ||   "help" == "$1" || "$1" =~  [-]+help   ]] ;  then     #  ||  -z  "$1"  
         
	exitNOW="1";

	cat << __END
	
======IMPT==IMPT===IMPT==IMPT===IMPT==IMPT===IMPT==IMPT===IMPT==IMPT===
You need to be on Puppet Network  aka VPN..  to Enjoy the Full Functions of this script.
======IMPT==IMPT===IMPT==IMPT===IMPT==IMPT===IMPT==IMPT===IMPT==IMPT===	

Latest Version of Puppet Entreprise is $latest_released_version_number ;


__END

aaa=$(curl  --connect-timeout 10   https://artifactory.delivery.puppetlabs.net   ) ;
test  -z "$aaa"  &&  \
	echo "========================================================================= Please get on Puppet NetWork aka VPN and try again.  =========================================================================" &&  exit 0 ;
	
	cat << __END
 	
# This script will download the requested version of PE from S3.
# If no version is specified, the latest version will be used. It will
# also resume broken downloads to save time and rename the resultant file.

# INSTALLER CHOICES #
# Either pass these environment variables inline or modify the default
# values (note, it's the value after the ':-' but before the close curly brace }


Latest Version of Puppet Entreprise is $latest_released_version_number ;

# All Versions of the $DOWNLOAD_VERSION PE:
$(   getAllVersions    )

#Environment variables available
DOWNLOAD_DIST=$(  cat /tmp/lst$$.txt.d    |  sort -u | tr [:cntrl:]   ,  )
DOWNLOAD_RELEASE=$(  cat /tmp/lst$$.txt.distV    |  sort -u | tr [:cntrl:]   ,  )
DOWNLOAD_ARCH=$(  cat /tmp/lst$$.txt.arch   |  sort -u | tr [:cntrl:]   ,  )
DOWNLOAD_VERSION=$(  cat /tmp/lst$$.txt.Version   |  sort -u | tr [:cntrl:]   ,  )latest

E.g. 
DOWNLOAD_DIST=el  DOWNLOAD_RELEASE=7  DOWNLOAD_ARCH=x86_64  DOWNLOAD_VERSION=latest  $0 help ;




#To Get Info Other Versions of  Puppet Entreprise:
Use DOWNLOAD_VERSION=

E.g.
DOWNLOAD_VERSION=2018.1.0   $0  help



## Operation
Download: ===BATCH Download Mode===
    $0  dl = download all the latest versions for different distributions

DOWNLOAD_VERSION=2018.1.0   $0  dl = download all the 2018.1.0 versions for different distributions
DOWNLOAD_VERSION=2018.1.0 DOWNLOAD_RELEASE=7 DOWNLOAD_DIST=el   $0  dl = download all the 2018.1.0 versions for RHEL 7  distributions
DOWNLOAD_VERSION=2018.1.0 DOWNLOAD_RELEASE=7 DOWNLOAD_DIST=el  dl=all  $0  = download all the 2018.1.0 versions for RHEL 7  distributions
=======

__END


if  [[   "dl" == "$1"  ||  "$dl" == "all"   ]] ;  then
	exitNOW="" ;
	echo =========BATCH Download Mode====== DOWNLOADING ALL  $DOWNLOAD_VERSION versions for different distributions ==============================================================
	  bash /tmp/lst$$.txt.sh  ;

fi;



	 rm /tmp/lst$$.txt.d
	 rm  /tmp/lst$$.txt.distV
	 rm /tmp/lst$$.txt.arch

	rm  -f /tmp/lst$$.txt
	
	rm -f   /tmp/lst$$.txt.sh

     test   -z "$exitNOW"  ||  exit 0  ;
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
echo ======DETECTED================
cat << __END
DOWNLOAD_DIST=${DOWNLOAD_DIST:-UNKNOWN}
DOWNLOAD_RELEASE=${DOWNLOAD_RELEASE:-UNKNOWN}
DOWNLOAD_ARCH=${DOWNLOAD_ARCH:-UNKNOWN}
DOWNLOAD_VERSION=${DOWNLOAD_VERSION:-UNKNOWN}
__END
echo ======================


( \
[ -z "$DOWNLOAD_DIST"    ] || \
[ -z "$DOWNLOAD_RELEASE" ] || \  
[ -z "$DOWNLOAD_ARCH"    ] || \
[ -z "$DOWNLOAD_VERSION" ]  ) \
|| {
 	echo ===========================There are UNKNOWN parameters: AUTODETECT Fail ====================
 	echo Try again with HELP=Y set to see what other options
 	exit  0;	
 }


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
