#!/bin/bash

valentepuppetcmd="${HOME}/mym/valentepuppet/tasks/puppet_tasks_sh.ps1"
function regen(){
  regenfns=./.`basename $0`.regenfns.dat ;
  echo regenfns=$regenfns= 1>&2 ;
  echo > $regenfns
  
  for fname in  echoMeNRun  catMe  echoMsg installPkg custom_puppet_configuration dlPEConsole_SetParameters  dlPEConsole  ; do 
      echo "function $fname(){" >> $regenfns
      ${valentepuppetcmd} showFNCMDs - $fname | grep -E -v  '====' >> $regenfns
      echo "}" >> $regenfns
  done ;

  for fname in   puppet_PuppetEntreprise_download    ;   do 
      echo "function $fname(){" >> $regenfns
      ${valentepuppetcmd} showFNCMDs - $fname | sed -E 's/curl /echo DISABLED: curl/g' | sed -E 's/tar -xzvf/tar -tf/g' |  grep -E -v  '====' >> $regenfns
      echo "}" >> $regenfns
  done ;

  cat >> $regenfns << _EEE
  
    puppet_PuppetEntreprise_download \${DOWNLOAD_VERSION} \$@
  
  
tar -tf ./puppet*.gz > /dev/null && (
      echo "Begin Checking........." ;
      ( tar  -t -f \$PWD/puppet*.gz    > /dev/null    && echo  "To Continue:  tar -xzvf    \$(ls -1 \$PWD/puppet*.gz) "  )  ||   \
      {
        rm   -f        \$PWD/puppet*.gz    ;
        echo " !!!!!!!!!!    ERROROUS DOWNLOAD : \$(ls -1 \$PWD/puppet*.gz)    Removed  !!!!!!!!!!!!!!!!!!!" ;  
      }
  exit 0 ;
)
_EEE

  echo "###Valentepuppet1##" >> $regenfns

  awk  'BEGIN { np=0}   /^###Valentepuppet0##/ { np=2; print ;  system("cat '$regenfns'") ;  next ; }  /^###Valentepuppet1##/{ np=0;  next; }  np==0{ print }         '\
             $0 > ./.`basename $0`.dat ;
  #cat ./.`basename $0`.dat  >  $0  ;
}
if [ "regen" = "$1" ] ; then
  regen 
  echo -e "\n\n#===IMPT======IMPT======IMPT======IMPT======IMPT======IMPT======IMPT======IMPT===\n # To use Regen, it must be run like this at prompt '   eval \$($0 regen)   ' \n If u do not see any command after this.. then you have done it right. \n#===IMPT======IMPT======IMPT======IMPT======IMPT======IMPT======IMPT======IMPT===\n\n" 1>&2 ;
  echo "cat ./.`basename $0`.dat >  $0" ;
  exit 0 ;  
fi;
 if  [ "loadlib" = "$1" ] ; then
  echo Loading....$0..... ;
  loadlibspuppet_tasks_sh="$loadlibs:$0:"
  return; exit 0;
 fi;

###Valentepuppet0##

function echoMeNRun(){
  logFile=/tmp/echoMeNRun.txt ;
  #$@ || eval $@    2>&1   | tee $logFile ;
   eval $@          2>&1   | tee $logFile ;
  (sleep 5 && rm -f $logFile )  &
  echo " " ;
}
function catMe(){
  if [ "$1"  = "-" ] ; then
		shift;
		echoMeNRun cat ${@:-/tmp/a.t} ;
  else
	  echoMsg "==" cat ${@:-/tmp/a.t}
	  grep -v -n  "@@@@@SOMEIMPOSSIBLESTRING@SHOWLINENUMBER@@@@@"  "${@:-/tmp/a.t}"
  fi;
}
function echoMsg(){
	if [[ $1  =~ ^[0-9]+$  ]] ; then
		spacerCount="$1" ;
		shift 1 ;
	else
		spacerCount=100 ;
	fi;

	repC="$1" ;
	repCPrefix='='
	repCPostfix=''

	if [[ "$1" =~  ^[\>\<,.?+=%@!:\ \*_^-]+$    ]] ; then
		if [  0${#repC}  -eq 1   -o   0${#repC}  -eq 2   ] ; then
			if [  0${#repC}  -gt 1 ] ; then
				repCPrefix=${repC:0:1} ;
				repCPostfix=${repC:1:1} ;
			else
				repCPrefix=$repC ;
			fi;
			shift ;
		fi;
	fi;



	prefix=`printf %${spacerCount}s |tr " " "$repCPrefix" `

	[ -z  "$repCPostfix" ] || \
	 postfix=`printf %${spacerCount}s |tr " " "$repCPostfix" `

	if [ ! -z "$1" ] ; then
		prefix="$prefix "
		postfix=" $postfix"
	fi;

	echo -e "$prefix$@$postfix"
}
function installPkg(){
    ((which paru || paru --help ) && {
		  paru -Syu --noconfirm ;
	}) || \
    ((which yay || yay --help ) && {
		  yay -Syu --builddir /tmp  --noconfirm $@ ;
	}) || \
	((which pacman  ||  pacman --help  )  && {
		sudo pacman -Syu  --noconfirm $@ ;
	}) || \
	(( which apt-get || apt-get --help )  && {
		sudo apt-get  install -y $@ ;
	}) || \
	(( which yum  || yum --help )  && {
		sudo yum install -y $@ ;
	})
}
function custom_puppet_configuration(){

  [ "$1" = "-" ] && shift ;

  puppetCMD=`which puppet`
  puppetCMD=${puppetCMD:-puppet}

  PUPPET_BIN_DIR=${PUPPET_BIN_DIR:-/opt/puppetlabs/puppet/bin}

  PUPPET_CONF_DIR=`${puppetCMD} config print confdir`
  PUPPET_CONF_DIR=${PUPPET_CONF_DIR:-/etc/puppetlabs/puppet}

  if ${puppetCMD} --help > /dev/null 2>/dev/null  ; then
  	puppetCMD --help > /dev/null 2>/dev/null
  else
  	puppetCMD=""
  fi
 
  echo  "===puppetCMD=${puppetCMD}"

  set | grep -E '^PUPPET_BIN_DIR=|^PUPPET_CONF_DIR=';

  # Parse optional pre-installation configuration of Puppet settings via
  # command-line arguments. Arguments should be one of the valid flags,
  # or else a section/setting/value directive.
  #
  # Valid Flags:
  #
  # --puppet-service-ensure <value>
  # --puppet-service-enable <value>
  #
  # Section / Setting / Value directives:
  #
  #   <section>:<setting>=<value>
  #
  # There are four valid section settings in puppet.conf: "main", "master",
  # "agent", "user". If you provide valid setting and value for one of these
  # four sections, it will end up in <confdir>/puppet.conf.
  #
  # There are two sections in csr_attributes.yaml: "custom_attributes" and
  # "extension_requests". If you provide valid setting and value for one
  # of these two sections, it will end up in <confdir>/csr_attributes.yaml.
  #
  # note:Custom Attributes are only present in the CSR, while Extension
  # Requests are both in the CSR and included as X509 extensions in the
  # signed certificate (and are thus available as "trusted facts" in Puppet).
  #
  # Regex is authoritative for valid sections, settings, and values.  Any
  # non-flag input that fails regex will trigger this script to fail with error
  # message.
  regex='^(main|master|agent|user|custom_attributes|extension_requests):([^=]+)=(.*)$'
  declare -a attr_array
  declare -a extn_array

  while (( "$#" )); do
    if [[ $1 == '--puppet-service-ensure' ]]; then
      shift; PUPPET_SERVICE_ENSURE="$1"
    elif [[ $1 == '--puppet-service-enable' ]]; then
      shift; PUPPET_SERVICE_ENABLE="$1"
    elif [[ $1 == '--puppet-service-debug' ]]; then
      PUPPET_SERVICE_DEBUG='--debug'
    elif [[ $1 =~ $regex ]]; then
      section=${BASH_REMATCH[1]}
      setting=${BASH_REMATCH[2]}
      value=${BASH_REMATCH[3]}
      case $section in
        custom_attributes)
          echo \
          attr_array=\("${attr_array[@]}" "${setting}: '${value}'"\)
          attr_array=("${attr_array[@]}" "${setting}: '${value}'")
          ;;
        extension_requests)
		  echo \
          extn_array=\("${extn_array[@]}" "${setting}: '${value}'"\)
          extn_array=("${extn_array[@]}" "${setting}: '${value}'")
          ;;
        *)
          echo \
          "${PUPPET_BIN_DIR}/puppet" config set "$setting" "$value" --section "$section"
          "${PUPPET_BIN_DIR}/puppet" config set "$setting" "$value" --section "$section"
      esac
    else
      echo \
      fail "Unable to interpret argument: '${1}'. Expected flag or '<section>:<setting>=<value>' matching regex: '${regex}'"
      fail "Unable to interpret argument: '${1}'. Expected flag or '<section>:<setting>=<value>' matching regex: '${regex}'"
    fi

    shift
  done

  # If the the length of the attr_array or extn_array is greater than zero, it
  # means we have settings, so we'll create the csr_attributes.yaml file.
  if [[ ${#attr_array[@]} -gt 0 || ${#extn_array[@]} -gt 0 ]]; then
    mkdir -p "${PUPPET_CONF_DIR}"
    echo '---' > "${PUPPET_CONF_DIR}/csr_attributes.yaml"

    if [[ ${#attr_array[@]} -gt 0 ]]; then
      echo "custom_attributes: ${attr_array}"
      echo 'custom_attributes:' >> "${PUPPET_CONF_DIR}/csr_attributes.yaml"
      for ((i = 0; i < ${#attr_array[@]}; i++)); do
        echo "  ${attr_array[i]}" >> "${PUPPET_CONF_DIR}/csr_attributes.yaml"
      done
    fi

    if [[ ${#extn_array[@]} -gt 0 ]]; then
      echo "extension_requests: ${extn_array}"
      echo 'extension_requests:' >> "${PUPPET_CONF_DIR}/csr_attributes.yaml"
      for ((i = 0; i < ${#extn_array[@]}; i++)); do
        echo "  ${extn_array[i]}" >> "${PUPPET_CONF_DIR}/csr_attributes.yaml"
      done
    fi
  fi

  tmpfile=`mktemp`
  grep -v 'toberemoved' "${PUPPET_CONF_DIR}/csr_attributes.yaml" > ${tmpfile} ; mv -fr  {tmpfile} "${PUPPET_CONF_DIR}/csr_attributes.yaml"
  grep -v 'toberemoved' "${PUPPET_CONF_DIR}/puppet.conf" > ${tmpfile} ; mv -fr  {tmpfile} "${PUPPET_CONF_DIR}/puppet.conf"

}
function dlPEConsole_SetParameters(){
  [ -e /etc/os-release ] && source /etc/os-release && (  catMe /etc/os-release  ||  cat /etc/os-release )  # Based on https://gist.github.com/natefoo/814c5bf936922dad97ff
 # which lsb-release > /dev/null &&  lsb-release -a

	mode=$1 ;
	[ -d  "$mode" ] && ( cd "$mode"  && mode='' )
	if [ "$mode" =  "dlPEConsole" ] ; then  mode=""; shift ; fi ;
	if [ "$mode" =  "show"        ] ; then           shift ; fi ;
	if [ "$mode" =  "check"       ] ; then           shift ; fi ;

	destdir=$1 ;
	if [ -d "$destdir" ] ; then           shift ; fi ;

	PE_VERSION="$1" ;   [ "$PE_VERSION" = "-" ] && PE_VERSION=""
	ARCH="$2";          [ "$ARCH" = "-" ]       && ARCH=""
	DIST="$3";          [ "$DIST" = "-" ]       && DIST=""
	VERSION="$4";       [ "$VERSION" = "-" ]    && VERSION=""


	ARCH=${ARCH:-$(uname -m)}
  [[ "$PLATFORM_ID$ID_LIKE$ID" =~ rhel ]] && DIST=${DIST:-el}
  [[ "$PLATFORM_ID$ID_LIKE$ID" =~ fedora ]] && DIST=${DIST:-el}
  [[ "$NAME" =~ Scientific ]] && DIST=${DIST:-sles}
  [[ "$ID" =~ ubuntu ]] && DIST=${DIST:-ubuntu}
	VERSION=${VERSION:-$VERSION_ID}

  if [[ ${DIST} =~ el ]] ; then
    VERSION=${VERSION/.*/}
  else
    VERSION=${VERSION} ;
  fi
  if [[ ${DIST} =~ ubuntu ]] ; then
    ARCH=amd64 ;
  fi;

  if [ "check" != "$mode"   ]  ; then
	echoMsg .. Checking.... PE_VERSION=$PE_VERSION
	echoMsg .. Checking.... ARCH=$ARCH
	echoMsg .. Checking.... DIST=$DIST
	echoMsg .. Checking.... rel=$VERSION
  fi;

	######Default Values
	PE_VERSION=${PE_VERSION:-latest}  ## latest, 2018.1.3
	ARCH=${ARCH:-x86_64}              ## x86_64, AMD64
	DIST=${DIST:-el}                  ## ubuntu,el,sles
    rel=${VERSION:-7}                 ##  7, 8, 16.04, , 16.10


	echoMsg :: Final PE_VERSION=$PE_VERSION
	echoMsg :: Final ARCH=$ARCH
	echoMsg :: Final DIST=$DIST
	echoMsg :: Final rel=$VERSION
}
function dlPEConsole(){
	tmpDir=${tmpDir:-/tmp} ;

    #prequire
    for cmdused in which sudo openssl gettext ; do
      ${cmdused}  --help > /dev/null ||  puppet resource package ${cmdused} ;
      ${cmdused}  --help > /dev/null ||  installPkg ${cmdused}  ;
    done;

    dlPEConsole_SetParameters $@

 	mode=$1 ;

	cd ${tmpDir}
	[ -d  "$mode" ] && ( cd "$mode"  && mode='' )
	[[  "$mode" =~ 'show|check'  ]] || mode=''


	echoMsg :: "Current Directory = $PWD"


    if [   -z "$mode"   ]  ; then
      echoMsg :: Downloading

	  which wget && echo \
	  	wget --content-disposition \""https://pm.puppet.com/cgi-bin/download.cgi?dist=${DIST}&rel=${rel}&arch=${ARCH}&ver=${PE_VERSION}"\"  &&  \
	  	wget --content-disposition "https://pm.puppet.com/cgi-bin/download.cgi?dist=${DIST}&rel=${rel}&arch=${ARCH}&ver=${PE_VERSION}"   \
	  || (
	    which curl && echo \
	    	curl -JLO \""https://pm.puppet.com/cgi-bin/download.cgi?dist=${DIST}&rel=${rel}&arch=${ARCH}&ver=${PE_VERSION}"\" && \
	    	curl -JLO "https://pm.puppet.com/cgi-bin/download.cgi?dist=${DIST}&rel=${rel}&arch=${ARCH}&ver=${PE_VERSION}"
	  )
	elif [ "$mode" = "check"  ]  ; then
		[ -z "$tmpf" ] && tmpf=`mktemp`
		grep '#dlPEConsole_versioncheck#' $0 | cut -d'#' -f3 > $tmpf

		echo $PE_VERSION >>  $tmpf



		nextversion=$(cat $tmpf| sort -nu | grep -A1 "$PE_VERSION" |tail -1 )

		if  [ -z "$nextversion" -o "$nextversion" =    "9999.0.0.latest"  -o "$nextversion" =    "latest" ] ; then
			echo latest ;
			return 0 ;
		fi
		echo $nextversion;
		echoMsg '=='  dlPEConsole check $nextversion ;
		dlPEConsole check $nextversion ;



		echoMsg '=='  rm -f $tmpf
		rm -f $tmpf
		exit 0 ;
	# based on https://puppet.com/docs/pe/2019.8/upgrading_pe.html
    #dlPEConsole_versioncheck#9999.0.0.latest
	#dlPEConsole_versioncheck#
	#dlPEConsole_versioncheck#2018.1.3
	#dlPEConsole_versioncheck#
	#dlPEConsole_versioncheck#2016.4.10
	#
	else #show
		echoMsg :: "Url https://pm.puppet.com/cgi-bin/download.cgi?dist=${DIST}&rel=${rel}&arch=${ARCH}&ver=${PE_VERSION}"
		echo
		echoMsg :: '    Run wget --content-disposition "https://pm.puppet.com/cgi-bin/download.cgi?dist=${DIST}&rel=${rel}&arch=${ARCH}&ver=${PE_VERSION}  "'
		echo OR
		echoMsg :: '    Run curl -JLO "https://pm.puppet.com/cgi-bin/download.cgi?dist=${DIST}&rel=${rel}&arch=${ARCH}&ver=${PE_VERSION}"'
		echo
		file2down=$(   curl -JLv  --max-filesize 100000  "https://pm.puppet.com/cgi-bin/download.cgi?dist=${DIST}&rel=${rel}&arch=${ARCH}&ver=${PE_VERSION}"  2>&1  |  grep Location |  sed -E  's/^[^:]+: //g' | xargs -L 1  basename  |grep puppet | sort -u )
		echoMsg :: "   Version To Download : $file2down "
		echoMsg '=='  'curl -JLv  --max-filesize 100000  "https://pm.puppet.com/cgi-bin/download.cgi?dist=${DIST}&rel=${rel}&arch=${ARCH}&ver=${PE_VERSION}"  2>&1  |  grep Location'
		curl -JLv  --max-filesize 100000  "https://pm.puppet.com/cgi-bin/download.cgi?dist=${DIST}&rel=${rel}&arch=${ARCH}&ver=${PE_VERSION}"  2>&1  |  grep Location
	fi;

	echoMsg :: In $PWD now
  	echoMeNRun ls -ltr puppet*.gz
  	echoMeNRun ls -lhtr puppet*.gz
}
function puppet_PuppetEntreprise_download(){
	# tmpDir=""
	tmpDir=${tmpDir:-/tmp} ;


	DOWNLOAD_VERSION_REQ=$1 ;
	[  "$DOWNLOAD_VERSION_REQ" = 'puppet_PuppetEntreprise_download' ] && DOWNLOAD_VERSION_REQ=""
	if 	[ ! -z "$DOWNLOAD_VERSION_REQ" ] ; then
		export DOWNLOAD_VERSION_REQ=$DOWNLOAD_VERSION_REQ ;
		export DOWNLOAD_VERSION=$DOWNLOAD_VERSION_REQ ;
		export PE_VERSION=$DOWNLOAD_VERSION_REQ ;
	fi;

	echoMsg '==' "Running.... cd $tmpDir &&  pwd && \
	echo DISABLED: curl  \"https://raw.githubusercontent.com/sooyean-hoo/pe_curl_requests/feature/SYInstallerEnhance/installer/download_pe_tarball.sh\"   | bash - " ;
	cd $tmpDir &&  pwd && \
	echo DISABLED: curl  "https://raw.githubusercontent.com/sooyean-hoo/pe_curl_requests/feature/SYInstallerEnhance/installer/download_pe_tarball.sh"   | bash - ;

	ls -ltr ./puppet*.gz
	[ -s ./puppet*.gz ] ||  cd $tmpDir &&  pwd && dlPEConsole $DOWNLOAD_VERSION_REQ

	echoMsg '==' 'cd $tmpDir && tar -tf ./puppet*gz ; ls -ltr ./puppet*.gz  '

	cd $tmpDir && \
	ls -l ;  \
	tar -tf ./puppet*gz ; \
    ls -ltr ./puppet*.gz   ; \

}
  
    puppet_PuppetEntreprise_download ${DOWNLOAD_VERSION}
  
  
tar -tf ./puppet*.gz > /dev/null && (
      echo "Begin Checking........." ;
      ( tar  -t -f $PWD/puppet*.gz    > /dev/null    && echo  "To Continue:  tar -xzvf    $(ls -1 $PWD/puppet*.gz) "  )  ||         {
        rm   -f        $PWD/puppet*.gz    ;
        echo " !!!!!!!!!!    ERROROUS DOWNLOAD : $(ls -1 $PWD/puppet*.gz)    Removed  !!!!!!!!!!!!!!!!!!!" ;  
      }
  exit 0 ;
)
###Valentepuppet1##

Dist="";
DistV="";
DArch="";

dlScript=/tmp/lst$$.txt.sh 

DOWNLOAD_VERSION=${DOWNLOAD_VERSION:-latest}

if [[ $DOWNLOAD_VERSION == latest ]]; then
  latest_released_version_number="$(curl -s http://versions.puppet.com.s3-website-us-west-2.amazonaws.com/ | tail -n1)"
  DOWNLOAD_VERSION=${latest_released_version_number:-latest}
fi;


echo "DOWNLOAD_DIST=\"$DOWNLOAD_DIST\"  DOWNLOAD_RELEASE=\"$DOWNLOAD_RELEASE\"  DOWNLOAD_ARCH=\"$DOWNLOAD_ARCH\"  DOWNLOAD_VERSION=\"$DOWNLOAD_VERSION\" " > $dlScript 

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
 
			echo  DOWNLOAD_DIST=\"$(         tail -1  /tmp/lst$$.txt.d          )\"   DOWNLOAD_RELEASE=\"$(   tail -1  /tmp/lst$$.txt.distV    )\" DOWNLOAD_ARCH=\"$(        tail -1  /tmp/lst$$.txt.arch      )\"  DOWNLOAD_VERSION=\"$(   tail -1  /tmp/lst$$.txt.Version  )\"  \
		       dl=    $0         >>    /tmp/lst$$.txt.sh ;

	done  ;

	
	for  line in  $(    cat  /tmp/lst$$.txt  |  sed -E 's/.tar$/ /g'     )   ; do 

		echo $line     |  IFS=-     read   p e v d distV arch  ;

			echo $line | cut -d- -f4  >> /tmp/lst$$.txt.d
			echo $line | cut -d- -f5  >> /tmp/lst$$.txt.distV
			echo $line | cut -d- -f6  >> /tmp/lst$$.txt.arch
 
 
 
			
	
	done  ;
}


if  [[  "" != "$HELP" ||  "dl" == "$1" ||  "$dl" == "batch"    \
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
DOWNLOAD_VERSION=2018.1.0 DOWNLOAD_RELEASE=7 DOWNLOAD_DIST=el  dl=batch  $0  = download all the 2018.1.0 versions for RHEL 7  distributions
=======

__END


if  [[   "dl" == "$1"  ||  "$dl" == "batch"   ]] ;  then
	exitNOW="" ;
	echo =========BATCH Download Mode====== DOWNLOADING ALL  $DOWNLOAD_VERSION versions for different distributions ==============================================================
	  
	  if [ -z "$(grep bash $dlScript )" ] ; then
	  	bash $dlScript ;
	  	>  $dlScript ;
	  fi;
	  	

fi;



	 rm /tmp/lst$$.txt.d
	 rm  /tmp/lst$$.txt.distV
	 rm /tmp/lst$$.txt.arch

	 rm  -f /tmp/lst$$.txt
	

     test   -z "$exitNOW"  ||  { rm -f $dlScript ;  exit 0 ; }   ;
fi;







cat $dlScript |  sed -E "s/[^ =]+=/ /g" | \
\
while read  DOWNLOAD_DIST  DOWNLOAD_RELEASE  DOWNLOAD_ARCH  DOWNLOAD_VERSION SOMEBULLSHIT ; do
	
	
	DOWNLOAD_DIST=$( echo $DOWNLOAD_DIST |  tr -d \" )  
	DOWNLOAD_RELEASE=$( echo $DOWNLOAD_RELEASE |  tr -d \" )
	DOWNLOAD_ARCH=$( echo $DOWNLOAD_ARCH |  tr -d \" )
	DOWNLOAD_VERSION=$( echo $DOWNLOAD_VERSION |  tr -d \" )

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
			
			
			[ -z "$DEBUG" ] || \
			{
			cat << __END
			DOWNLOAD_DIST=$ID
			DOWNLOAD_RELEASE=$VERSION_ID
			DOWNLOAD_ARCH=$ARCH
			DOWNLOAD_VERSION=$DOWNLOAD_VERSION
__END
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
			
			
			(\
			[ -z "$DOWNLOAD_DIST"    ] || \
			[ -z "$DOWNLOAD_RELEASE" ] || \
			[ -z "$DOWNLOAD_ARCH"    ] || \
			[ -z "$DOWNLOAD_VERSION" ] ) \
			&& \
			{
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
			
			echo Begin Checking.........;
			( tar  -t -f ./$tarball_name   > /dev/null    && echo  To Continue:  tar -xzvf    ./$tarball_name  )  ||   \
			{
				rm   -f        ./$tarball_name    ;
				echo " !!!!!!!!!!    ERROROUS DOWNLOAD : ./$tarball_name   Removed  !!!!!!!!!!!!!!!!!!!" ;  
			}
			
			#for DIS in ubuntu archlinux centos  debian  brunolimaq/suse_12_1   ; do  docker run --rm -it     -v $PWD:/tmp  -w /tmp/  $DIS  /tmp/download_pe_tarball.sh   ; done
			
			# https://artifactory.delivery.puppetlabs.net/artifactory/generic_enterprise__local/archives/releases/2019.2.2/
			
			
			#curl  https://artifactory.delivery.puppetlabs.net/artifactory/generic_enterprise__local/archives/releases/2019.2.2/ | grep href | grep puppet | sed -E 's/^.+(puppet.+tar).+$/\1/g'
done ;
 rm -f $dlScript
