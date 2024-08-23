#!/bin/bash

valentepuppetcmd="${HOME}/mym/valentepuppet/tasks/puppet_tasks_sh.ps1"
function regen(){
  regenfns=./.`basename $0`.regenfns.dat ;
  echo regenfns=$regenfns= 1>&2 ;
  echo > $regenfns
  
  for fname in  echoMeNRun  catMe  echoMsg installPkg addrepoPkg upgradePkg chkPkg custom_puppet_configuration dlPEConsole_SetParameters  dlPEConsole installrbenv        cleanse_dlPEConsole installPEConsole ping_NC_Test  getValueHashTags runChain installnvm rungithubactionuse ; do 
      echo "function $fname(){" >> $regenfns
      ${valentepuppetcmd} showFNCMDs - $fname | grep -E -v  '^====' >> $regenfns
      echo "}" >> $regenfns
  done ;

  for fname in   puppet_PuppetEntreprise_download    ;   do 
      echo "function $fname(){" >> $regenfns
      ${valentepuppetcmd} showFNCMDs - $fname | sed -E 's/curl /echo echo DISABLED: curl/g' | sed -E 's/tar -xzvf/tar -tf/g' |  grep -E -v  '====' >> $regenfns
      echo "}" >> $regenfns
  done ;

  cat >> $regenfns << '_EEE'
 if  [ "loadlib" = "$1" ] ; then
  echo Loading....$@..... ;
  loadlibspuppet_tasks_sh="$loadlibs:$0:"
  return; exit 0;
 fi;
 if  [ "exec" = "$1" ] ; then
  shift ;
  echo Execing....$@..... ;
  $@ ; errorid=$?;
  return; exit $errorid;
 fi;
_EEE

  cat >> $regenfns << _EEE
    tmpDir="\${tmpDir:-\$PWD}" ;
    export tmpDir="\${tmpDir}" ;
    puppet_PuppetEntreprise_download \${DOWNLOAD_VERSION} \$@
  
  
tar -tf  \$(ls -1  \${tmpDir}/puppet*.gz) > /dev/null && (
      echo "Begin Checking........." ;
      ( tar  -t -f  \${tmpDir}/puppet*.gz    > /dev/null    && echo  "To Continue:  tar -xzvf    \$(ls -1  \${tmpDir}/puppet*.gz) "  )  ||   \
      {
        rm   -f         \${tmpDir}/puppet*.gz    ;
        echo " !!!!!!!!!!    ERROROUS DOWNLOAD : \$(ls -1  \${tmpDir}/puppet*.gz)    Removed  !!!!!!!!!!!!!!!!!!!" ;  
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

###Valentepuppet0##

function echoMeNRun(){
  echo "==================================" Running.... $@ "==========================================="
  logFile=/tmp/echoMeNRun.txt ;
  #$@ || eval $@    2>&1   | tee $logFile ;
   eval $@          2>&1   | tee $logFile ;
  (sleep 5 && rm -f $logFile )  &
  echo " " ;
  echo  ===================================================================================
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

  msg="$@";
	if [ ! -z "$1" ] ; then
		prefix="$prefix"
		postfix="$postfix"
    msg=" $@ "
	fi;
	echo -e "$prefix$msg$postfix"
}
function installPkg(){
    ((which paru || paru --help ) 2> /dev/null && {
		  paru -Syu --noconfirm ;
	}) || \
    ((which yay || yay --help ) 2> /dev/null && {
		  yay -Syu --builddir /tmp  --noconfirm $@ ;
	}) || \
	((which pacman  ||  pacman --help  ) 2> /dev/null  && {
		sudo pacman -Syu  --noconfirm $@  || pacman -Syu  --noconfirm $@  ;
	}) || \
  (( which apt  || apt --help ) 2> /dev/null  && {
    sudo apt install -y $@ || apt install -y $@ ;
  }) || \
	(( which apt-get || apt-get --help ) 2> /dev/null  && {
		sudo apt-get  install -y $@ || apt-get  install -y $@ ;
	}) || \
	(( which yum  || yum --help ) 2> /dev/null  && {
		sudo yum install -y $@ || yum install -y $@ ;
	}) || \
  (( which zypper  || zypper --help ) 2> /dev/null  && {
    sudo zypper install -y -l $@ || zypper install -y -l $@ ;
  }) 
}
function addrepoPkg(){
#   ((which paru || paru --help ) && {
#       paru -Syu --noconfirm ;
#   }) || \
#   ((which yay || yay --help ) && {
#       yay -Syu --noconfirm ;
#   }) || \
#   ((which pacman || pacman --help ) && {
#     sudo pacman -Syu --noconfirm || pacman -Syu --noconfirm  ;
#   }) || \
#   (( which apt-get || apt-get --help )  &&  { \
#     sudo apt update -y || apt update -y  ; \
#   }) || \
  (( which yum  || yum --help )  && {
    sudo yum-config-manager --add-repo $@ || sudo curl --add-repo $@    -o  /etc/yum.repos.d/`basename $@`  ;
  }) || \
  (( which zypper  || yum --help )  && {
    sudo zypper addrepo $@ || zypper addrepo $@ ;
  })
}
function upgradePkg(){
  ((which paru || paru --help ) && {
		  paru -Syu --noconfirm ;
	}) || \
	((which yay || yay --help ) && {
		  yay -Syu --noconfirm ;
	}) || \
	((which pacman || pacman --help ) && {
		sudo pacman -Syu --noconfirm || pacman -Syu --noconfirm  ;
	}) || \
	(( which apt-get || apt-get --help )  &&  { \
		sudo apt update -y || apt update -y  ; \
  }) || \
  (( which yum  || yum --help )  && {
    sudo yum update -y $@ || yum update -y $@ ;
  }) || \
  (( which zypper  || yum --help )  && {
    sudo zypper update -y -l $@ || zypper update -y -l $@ ;
  })
}
function chkPkg(){
    ((which paru || paru --help ) && {
		  paru -Syu --noconfirm ;
	}) || \
    ((which yay || yay --help ) && {
		  yay -Q $@ ;
	}) || \
	((which pacman || pacman --help ) && {
		sudo pacman -Q $@ ||  pacman -Q $@  ;
	}) || \
	((which apt-cache || apt-cache --help )  && {
		sudo apt-cache search  $@ | grep install ||  apt-cache search  $@ | grep install ;
	}) || \
  (( which zypper  || yum --help )  && {
    sudo zypper info $@ || zypper info $@ ;
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
          echo ==========$1= Store the entry in attr_array for later addition to csr_attributes.yaml
          echo \
          attr_array=\("${attr_array[@]}" "${setting}: '${value}'"\)
          attr_array=("${attr_array[@]}" "${setting}: '${value}'")
          ;;
        extension_requests)
          echo ==========$1= Store the entry in extn_array for later addition to csr_attributes.yaml
		  echo \
          extn_array=\("${extn_array[@]}" "${setting}: '${value}'"\)
          extn_array=("${extn_array[@]}" "${setting}: '${value}'")
          ;;
        *)
          echo ==========$1= Set the specified entry in puppet.conf
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
  echoMsg :: "tmpDir directory where the tar file is = $tmpDir"


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


		#echo  ========$tmpf

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
function installrbenv(){
  #### rbenv installation
        touch ~/.bash_profile
        touch ~/.bashrc
        
        source ~/.bash_profile

        git clone https://github.com/rbenv/rbenv.git ~/.rbenv
        cd ~/.rbenv && pwd && ls -l
        cd ~/.rbenv && src/configure && make -C src
        [ ! -z "`grep .rbenv/bin ~/.bashrc `"   ] || echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
        [ ! -z "`grep rbenv\ init ~/.bashrc `"  ] || echo 'eval "$(rbenv init -)"' >> ~/.bashrc


        #exec $SHELL -l

        cd ~ && pwd && export HOME=`pwd`
        [ -z "`grep rbenv\ init ~/.bashrc `"  ] || source ~/.bash_profile
        echo  ====RBENV Installed===========
        which rbenv
        echo $PATH
        echo ============

        mkdir -p "$(rbenv root)"/plugins
        git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build

        cd "$(rbenv root)"/plugins/ruby-build && pwd && ls -l
        echo  ====RBbuild Installed===========  
}
function cleanse_dlPEConsole(){

	echoMsg '=='  "cd /tmp"
	echoMsg '=='  'rm -fr  puppet-enterprise*'
	echoMsg '=='  'ls -l   puppet-enterprise*'

  cd /tmp
	rm -fr  puppet-enterprise*
	ls -l   puppet-enterprise*
}
function installPEConsole(){

  tmpDir=${tmpDir:-/tmp} ;

  issues=()

  stageflags="$@"
  [[ "$puppet_paras" =~  ^= ]] || stageflags="$(echo $stageflags | sed -E 's/^[^=]+//g')"  ;
  stageflags=${stageflags:-=SETVALUES==PRECHECK==UNTAR==PRECONFIG==PRECONFIG2==INSTALL=}

  # stageflags=${stageflags:-=SETVALUES==PRECHECK==UNTAR==PRECONFIG==PRECONFIG2==PREP=}   # Run the prepmode of the installer

  echoMsg %% ====stageflags=$stageflags====
  echoMsg %% ====tmpDir=$tmpDir====



  			   sudo ls -l  ${tmpDir}/installPEConsole.SETVALUES.txt > /dev/null || \
			    issues[${#issues[@]}]=" @Missing setvalue: ${tmpDir}/installPEConsole.SETVALUES.txt"

  echoMsg ++ ====SETVALUES====
  [ -e ${tmpDir}/installPEConsole.SETVALUES.txt ] && source  ${tmpDir}/installPEConsole.SETVALUES.txt  && catMe  ${tmpDir}/installPEConsole.SETVALUES.txt ;

  srcgitKey=${srcgitKey:-${tmpDir}/occkeys}
  gitKey=${gitKey:-\"/etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa\"}
  gitURL=${gitURL:-\"git@github.com:sooyean-hoo/control-repo.git\"}              ## "ssh://git@gitlab.sooyean.com:8022/sooyean.hoo/control-repo.git"
  adminpasswd=${adminpasswd:-\"welcome1\"}
  dnsaltnames=${dnsaltnames:-[\"puppet\",\"peconsole_aws\",\"centos7.localdomain\"]}
  codeMgrConf=${codeMgrConf:-true};

#   srcgitKey='${tmpDir}/occkey'
#   gitKey='"/etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa"'
#   gitURL='"git@github.com:sooyean-hoo/control-repo.git"'              ## "ssh://git@gitlab.sooyean.com:8022/sooyean.hoo/control-repo.git"
#   adminpasswd='"welcome1"'
#   dnsaltnames='["puppet","peconsole_aws","centos7.localdomain"]'
#   codeMgrConf='true';

#   puppet_master_host='puppet'

  eval  $(  grep -A50  -F 'function installPEConsole()' $0 | grep -E   '^#'| sed -E 's/=/   /g' | awk -F' ' '{print "echoMsg :: "$2"=\$"$2";     " }'  | tr -d '[:cntrl:]'    )  ;

  if  [ -e ${tmpDir}/installPEConsole.SETVALUES.txt ] ; then
  	echoMsg :: =====From  ${tmpDir}/installPEConsole.SETVALUES.txt =====
	grep =  ${tmpDir}/installPEConsole.SETVALUES.txt | cut -d= -f1 | tr -d  ' '   | xargs -L 1  -I{}  bash -c "echo {}=\${} "
	echoMsg :: ====================================================
  fi;

  [[  $stageflags  =~ =PRECHECK= ]] || exit 0 ;
    echoMsg ++ ====PRECHECK====


        eval "sudo ls -l ${srcgitKey//\"/} " > /dev/null ; errorid=$? ;
        sudo ls -l  ${srcgitKey//\"/} > /dev/null ;
            test 0$?$errorid -eq 0 || issues[${#issues[@]}]=" @Missing srcgitKey: $srcgitKey "

        eval "sudo ls -l ${gitKey//\"/} "  > /dev/null ; errorid=$? ;
        sudo ls -l  ${gitKey//\"/} > /dev/null;
            test 0$?$errorid -eq 0 || issues[${#issues[@]}]=" @Missing gitKey: $gitKey "


		echoMsg %% ====tar.gz available now====
		sudo ls -1tra ${tmpDir}/puppet-enterprise*.tar.gz

		targz2use_=`ls -1tra ${tmpDir}/puppet-enterprise*.tar.gz  | tail -n 1`
		targz2use=${targz2use:-$targz2use_}         # May be overwritten by  ${tmpDir}/installPEConsole.SETVALUES.txt
		echoMsg %% ====targz2use=$targz2use===`ls -ltra ${tmpDir}/puppet-enterprise*.tar.gz  | tail -n 1`===


  	echoMsg %% ====Issues====
  	echo ${issues[@]}

  if [ ! -e ${srcgitKey//\"/} ] ; then
  	if [[  $stageflags  =~ =PREP=   ]] ; then
		echoMsg %% SKIPPED CHECK for Missing $srcgitKey, as it is doing =PREP=
  	else
	    echoMsg %% "\n\n\nFATAL Missing $srcgitKey.. Please upload to ${tmpDir}" ;
	    exit 0;
    fi;
  fi;


  if [ -z "$(ls  ${tmpDir}/puppet-enterprise*.tar.gz  )" ] ; then
    echoMsg %% "\n\n\nFATAL Missing tar files.. Please upload to ${tmpDir} " ;
    echoMeNRun ls -l ${tmpDir}/puppet-enterprise*.tar.gz
    exit 0;
  fi;

 [[  $stageflags  =~ =UNTAR= ]] || exit 0 ;
  echoMsg ++ ====UNTAR====

  cd ${tmpDir}
  test 0`mount  | grep noexec | grep  ${tmpDir} | wc -l ` -gt 0 && cd /var/tmp/

  tar -tf "$targz2use" 2>&1  > /dev/null ||  echoMsg %% "\n\n\nFATAL Error extracting $targz2use.. Please ensure the tar file is not corrupted in ${tmpDir} " ;
  echoMeNRun tar -xzvf "$targz2use"

  if [ -z "$targz2use"  -o   0 -ne  0$? -o  -z "`ls -l ${tmpDir}/puppet-enterprise*`" ] ; then
	echoMsg %% "\n\n\nFATAL Error extracting $targz2use.. Please ensure the tar file is not corrupted in ${tmpDir} " ;
	echoMeNRun ls -ld ${targz2use:-puppet-enterprise*}
    exit 0;
  fi;



  if [[  $stageflags  =~ =SETHOCONFVALUES= ]]  ; then
    if [ -e ${tmpDir}/installPEConsole.SETVALUES.conf ] ; then
      echoMsg ++ ====SETHOCONFVALUES====
#	[ -e ${tmpDir}/installPEConsole.SETVALUES.conf ] && source  ${tmpDir}/installPEConsole.SETVALUES.conf  && catMe  ${tmpDir}/installPEConsole.SETVALUES.conf ;

	  cd ${tmpDir}
	  test 0`mount  | grep noexec | grep  ${tmpDir} | wc -l ` -gt 0 && cd /var/tmp/

  	  installer=$PWD/$(find -iname '*-installer')
      cd $(dirname "$installer" )
  	  sudo su - << __END
 $installer -y -p
__END
		echoMsg '==' $installer -y -p



	  [ -e ${tmpDir}/installPEConsole.SETVALUES.txt ] && source  ${tmpDir}/installPEConsole.SETVALUES.txt  && catMe  ${tmpDir}/installPEConsole.SETVALUES.txt ;
############### PECONF.TEMPLATE
#  "pe_install::puppet_master_dnsaltnames": dnsaltnames
#  "puppet_enterprise::profile::master::r10k_remote": gitURL
#  "puppet_enterprise::profile::master::code_manager_auto_configure": codeMgrConf
#  "puppet_enterprise::profile::master::r10k_private_key": gitKey
#  "console_admin_password": adminpasswd
#
#  "puppet_enterprise::puppet_master_host"
#  "pe_install::install::classification::pe_node_group_environment"
#  "puppet_enterprise::ipv6_only"
#  "puppet_enterprise::master::recover_configuration::pe_environment"
#  "puppet_enterprise::profile::certificate_authority"
#  "puppet_enterprise::profile::master::check_for_updates"
#  "puppet_enterprise::profile::master::r10k_known__hosts"
#  "puppet_enterprise::profile::console::classifier_synchronization_period"
#  "puppet_enterprise::profile::console::ldap_sync_period_seconds"
#  "puppet_enterprise::profile::console::ldap_cipher_suites"
#  "puppet_enterprise::profile::console::rbac_failed_attempts_lockout"
#  "puppet_enterprise::profile::console::rbac_password_reset_expiration"
#  "puppet_enterprise::profile::console::rbac_session_timeout"
#  "puppet_enterprise::profile::console::session_maximum_lifetime"
#  "puppet_enterprise::profile::console::session_timeout_warning_seconds"
#  "puppet_enterprise::profile::console::session_timeout_polling_frequency_seconds"
#  "puppet_enterprise::profile::console::rbac_token_auth_lifetime"
#  "puppet_enterprise::profile::console::rbac_token_maximum_lifetime"
#  "puppet_enterprise::profile::console::console_ssl_listen_port"
#  "puppet_enterprise::profile::console::ssl_listen_address"
#  "puppet_enterprise::profile::console::classifier_prune_threshold"
#  "puppet_enterprise::profile::console::classifier_node_check_in_storage"
#  "puppet_enterprise::profile::console::display_local_time"
#  "puppet_enterprise::profile::console::disclaimer_content_path"
#  "puppet_enterprise::api_port"
#  "puppet_enterprise::console_services::no_longer_reporting_cutoff"
#
#####################

      conftmp=`mktemp`
 	  peconf=$PWD/$(find -iname pe.conf)

      #cp  ${tmpDir}/installPEConsole.SETVALUES.conf   $conftmp
      cat  $peconf > $conftmp

	  cat ${tmpDir}/installPEConsole.SETVALUES.txt |sed -E 's/;/\n/g'| sed -E 's/=.+$//g'| tr -d ' ' | while read commonvalue ; do
		  [ -z   "`set |grep $commonvalue | sed -E 's/^.+=//'`" ] && continue

		  confpropname="$( grep   ": $commonvalue"   $0 | sed -E 's/: .+$//g'| tr -d '# ' )"
		  if [ -z "$confpropname" ] ; then
		    confpropname="$(    grep '::'$commonvalue'"' ./puppet_tasks_sh.ps1 | sed -E 's/: .+$//g'| tr -d '# '         )"
		  fi;

		  echoMsg '==' "Running.... /opt/puppetlabs/installer/bin/hocon -f $conftmp set         '${confpropname}'   `set |grep ${commonvalue}= | sed -E s/^.+=// | head -1`  "
		        echo "/opt/puppetlabs/installer/bin/hocon -f $conftmp set         '${confpropname}'   `set |grep ${commonvalue}= | sed -E s/^.+=// | head -1`  "  | bash -

	  done;

	  catMe $conftmp

	  echoMeNRun sudo mv -f  $conftmp 	$peconf.NEWCONF || cat  $conftmp >  $peconf.NEWCONF

	 cd ${tmpDir}
	 test 0`mount  | grep noexec | grep  ${tmpDir} | wc -l ` -gt 0 && cd /var/tmp/

#	  uninstaller=$PWD/$(find -iname '*-uninstaller')
#  	  cd $(dirname "$uninstaller" )
#  	  sudo su - << __END
# $uninstaller -y
#__END
#		echoMsg '==' $uninstaller -y

    fi;
  fi;


  [[  $stageflags  =~ =PRECONFIG= ]] || exit 0 ;
  echoMsg ++ ====PRECONFIG====

  cd ${tmpDir}
  test 0`mount  | grep noexec | grep  ${tmpDir} | wc -l ` -gt 0 && cd /var/tmp/

  peconf=$PWD/$(find -iname pe.conf)

  cat $peconf  | \
  sed  -E 's/^[^"]+("[^"]+private_key":)(.+)$/            \1 \${gitKey}/g'         | \
  sed  -E 's/^[^"]+("[^"]+r10k_remote":)(.+)$/            \1 \${gitURL}/g'         | \
  \
  sed  -E 's/^[^"]+("[^"]+admin_password":)(.+)$/            \1 \${adminpasswd}/g' | \
  \
  sed  -E 's/^[^"]+("[^"]+dnsaltnames":)(.+)$/            \1 \${dnsaltnames}/g' | \
  \
  sed  -E 's/^[^"]+("[^"]+configure":)(.+)$/            \1 \${codeMgrConf}/g'  >  $peconf.tmp ;

  if [  ! -z  "$puppet_master_host" ] ; then
  	  cp $peconf.tmp  $peconf.tmp1 ;
  	  cat $peconf.tmp1  | \
  	  sed  -E 's/^[^"]+("[^"]+puppet_master_host":)(.+)$/            \1 \${puppet_master_host}/g'  >  $peconf.tmp ;
  	  rm -f $peconf.tmp1   ;
  fi;

  if [ -z "$(ls  `dirname "$peconf"`/pe.conf  )" ] ; then
	echoMsg %% "\n\n\nFATAL Missing pe.conf files.. Please ensure the tar file is not corrupted and extracted in ${tmpDir} " ;
	echoMeNRun ls -l `dirname "$peconf"`/pe.conf
    exit 0;
  fi;

  > $peconf.NEW
  cat  $peconf.tmp | while read line ; do
    if [[  $line =~ \$  ]] ; then
      eval "echo \"    \"\\\"$line  \" #configured Sooyean\"   " |sed -E 's/: /": /g'  >> $peconf.NEW   ;
#                echo ======================================================================================$line  ;
#                echo ====@@=========="echo \"    \"\\\"$line  \" #configured Sooyean\"   " |sed -E 's/: /": /g'
#                eval "echo \"    \"\\\"$line  \" #configured Sooyean\"   "
#                eval "echo \"    \"\\\"$line  \" #configured Sooyean\"   " | sed -E 's/: /": /g'
#                echo ====@@==========
    else
      echo $line   >> $peconf.NEW   ;
    fi;
  done;

  rm -f $peconf.tmp

  catMe $peconf.NEW  ;
  echoMsg %% Changes
  grep Sooyean  $peconf.NEW ;
  echoMsg %%

  sleep 5 ;


  sudo su - << __END
  mkdir -p $(dirname "$gitKey" )
  cp ${srcgitKey}  $(dirname "$gitKey" )
  cd $(dirname "$gitKey" )
  mv $(basename ${srcgitKey}) ./ $(basename "$gitKey" )

    eval "   cp $srcgitKey $gitKey "
    eval "   chown pe-puppet:pe-puppet  $gitKey "
    eval "ls -l  $gitKey"

  exit
__END

  sudo mkdir -p $(dirname "$gitKey" )
  cp ${srcgitKey}  $(dirname "$gitKey" )
  mv $(basename ${srcgitKey}) ./ $(basename "$gitKey" )

	eval "sudo ls -l ${srcgitKey//\"/} " > /dev/null ; errorid=$? ;
	sudo ls -l  ${srcgitKey//\"/} > /dev/null ;
	    test 0$?$errorid -eq 0 || issues[${#issues[@]}]=" @Missing srcgitKey: $srcgitKey "

	eval "sudo ls -l ${gitKey//\"/} "  > /dev/null ; errorid=$? ;
	sudo ls -l  ${gitKey//\"/} > /dev/null;
	    test 0$?$errorid -eq 0 || issues[${#issues[@]}]=" @Missing gitKey: $gitKey "


			     sed -i -E 's/(^.+"-".+$)/#DISABLED BY Sooyean            \1/g'     $peconf.NEW


  if [[  $stageflags  =~ =USEHOCONFVALUES= ]]  ; then
    if [ -e $peconf.NEWCONF ] ; then
	  echoMsg ++ ====USEHOCONFVALUES====

		cp -f $peconf.NEWCONF  $peconf.NEW

		echoMsg :: Customisations
		echoMsg '==' "Running.... grep -E -v '^( *)?#|^\$'   $peconf.NEW"
				      grep -E -v '^( *)?#|^$'   $peconf.NEW

    fi
  fi

  [[  $stageflags  =~ =PRECONFIG2= ]] || exit 0 ;
    echoMsg ++ ====PRECONFIG2====

    tmppeconf=$peconf.NEW.2

    #### Remove } and option which are '-'
    grep -E -v '^}'  $peconf.NEW  |  sed -E 's/("[^"]+"[ ]*:[ ]*[-])/#DISABLED BY Sooyean            \1/g'   > $tmppeconf

    cat >> $tmppeconf <<__EMD
  #------------------------------------------------------------------------------------------------------------------------------
  # CUSTOM CONFIGs from ${tmpDir}/*yaml.conf
  #
  # Added by Sooyean
  #
  # If it is for multi repo, Please run by  configOLDPuppet_r10K
  #
  # The CUSTOM CONFIGs aka *yaml.conf can be generated locally by running configOLDPuppet_r10K in offline mode too.
  #
  #------------------------------------------------------------------------------------------------------------------------------
__EMD
    #cat ${tmpDir}/*yaml.conf |  grep -E -v '^}'  |  grep -E -v '^{'   >> $tmppeconf
    cat ${tmpDir}/*yaml.conf    >> $tmppeconf
    echo  '}'  >> $tmppeconf

		 mv -f $tmppeconf $peconf.NEW   ;

	echoMsg :: Final Version of  $peconf.NEW
	catMe $peconf.NEW ;
	cat $peconf.NEW ;

	  sudo ls -l ${tmpDir}/*yaml.conf > /dev/null || \
			    issues[${#issues[@]}]=" @Missing yaml.conf files: $(ls -l  ${tmpDir}/*yaml.conf)"

      test  0`df  /opt/puppetlabs/ --output=avail | tail -1` -ge $((  1024 * 1024 * 50 )) || \
			    issues[${#issues[@]}]=" @/opt/puppetlabs/ too small : $( df  /opt/puppetlabs/ -h --output=avail | tail -1) < 50GB "

      test  0`df  /var/log/puppetlabs/ --output=avail | tail -1` -ge $((  1024 * 1024 * 24 )) || \
			    issues[${#issues[@]}]=" @/var/log/puppetlabs/ too small : $( df /var/log/puppetlabs/ -h --output=avail | tail -1) < 24GB "

	  test  0`cat /proc/meminfo | grep MemTotal | sed -E 's/[^0-9]//g'` -ge $((  1024 * 1024 * 6 )) || \
			    issues[${#issues[@]}]=" @RAM too small : $( cat /proc/meminfo | grep MemTotal | sed -E 's/^[^0-9]+:[ ]*//g' ) < 6GB "

	  test  0`cat /proc/cpuinfo  | grep processor  | wc -l`  -ge 6 || \
			    issues[${#issues[@]}]=" @Number of CPUs too little : $( cat /proc/cpuinfo  | grep processor  | wc -l ) < 6 "

	  test 0`find  /etc/puppetlabs/ -iname *.pem | grep signed | wc -l` -gt 0 || \
			    issues[${#issues[@]}]=" @Hopefully This is a brand new Puppet Main Server Installation: There is no existing Signed Cert of existing Agent. "

	  test 0`mount  | grep noexec | grep  ${tmpDir} | wc -l ` -le 0 || \
			    issues[${#issues[@]}]=" @ATTENTION: ${tmpDir} is of noexec, so no executable script can be run directly from ${tmpDir}. "


	echoMsg :: Customisations
#	echoMeNRun grep '#configured Sooyean' $peconf.NEW
	#grep '#configured Sooyean' $peconf.NEW
	echoMsg '==' "Running.... grep -E -v '^( *)?#|^\$'   $peconf.NEW"
	              grep -E -v '^( *)?#|^$'   $peconf.NEW


	echoMsg %% ====Issues====
  	echo ${issues[@]} | sed -E 's/@/\n\t/g'
  	echo
  	echo

  if [[  $stageflags  =~ =PREP=   ]] ; then
	echoMsg ++ ====PREP_SUBSTAGE====

	  cd ${tmpDir}
	  test 0`mount  | grep noexec | grep  ${tmpDir} | wc -l ` -gt 0 && cd /var/tmp/

	  installer=$PWD/$(find -iname '*-installer')

	  cd $(dirname "$installer" )
 logtmp=`mktemp`
 ( tee $logtmp | sudo su - ) << __END
 $installer -p -y

__END

  fi ;


  [[  $stageflags  =~ =INSTALL= ]] || exit 0 ;
  echoMsg ++ ====INSTALL====

  cd ${tmpDir}
  test 0`mount  | grep noexec | grep  ${tmpDir} | wc -l ` -gt 0 && cd /var/tmp/

  installer=$PWD/$(find -iname '*-installer')

  cd $(dirname "$installer" )
#  [[  $stageflags  =~ =INSTALLDONE= ]] || exit 0 ;


 logtmp=`mktemp`
 ( tee $logtmp | sudo su - ) << __END
 $installer -c $peconf.NEW

 puppet agent -t && echo ================Puppet Run 1/3 Done
 sleep 10
 puppet agent -t && echo ================Puppet Run 2/3 Done
 sleep 10;
 puppet agent -t && echo ================Puppet Run 3/3 Done
  echo ================
  cat   $gitKey
__END

  [ -s "$logtmp" ] && cat $logtmp  | xargs -I{} $0 echoMsg - == "{}"

[    "$gitKey" = '-'   ] ||
  ( tee $logtmp | cat > ${tmpDir}/installKey.sh ) << __END
    eval '   chmod a+r ${srcgitKey} ' ;
    eval '   mkdir -p  `dirname $gitKey` ' ;
    eval '   cp ${srcgitKey}  $gitKey ' ;
    eval '   chmod 0700   $gitKey ' ;
    eval '   chown pe-puppet:pe-puppet  $gitKey ' ;
    eval '   chown -R pe-puppet:pe-puppet  `dirname $gitKey`' ;
    eval 'ls -l  $gitKey' ;
__END


  [ -s "$logtmp" ] && cat $logtmp  | xargs  $0 catMe -


#[    "$gitKey" = '-'   ] ||
#  cat > ${tmpDir}/installKey.sh << __END
#    eval "   cp ${srcgitKey}  $gitKey "
#    eval "   chown pe-puppet:pe-puppet  $gitKey "
#    eval "   chown -R pe-puppet:pe-puppet  `dirname $gitKey`"
#    eval "ls -l  $gitKey"
#__END

  [    "$gitKey" = '-'   ] || chmod a+x ${tmpDir}/installKey.sh
  [    "$gitKey" = '-'   ] || sudo ${tmpDir}/installKey.sh || sudo bash ${tmpDir}/installKey.sh

  [    "$gitKey" = '-'   ] || ls -l  $gitKey
  echoMeNRun sudo df -h ;
  echoMsg ++ ====ALLDONE====
}
function ping_NC_Test(){
  while [ "$1" = "DEBUG" ] ; do
  		DEBUG=Y ;
  		shift ;
  done;
#### The test below means ......ping_NC_Test.AAAA.4.BBB = run on BBB to see if it can reach AAAA

##ping_NC_Test.MASTER.4.USER     tcp 22:ssh 80:http 443:https 4433:nodeClassifier             8081:puppetDB_TCP 8140:puppetExecutor                                                                                                 8170:puppetCodeManager
##ping_NC_Test.MASTER.4.AGENTS   tcp 8140:puppetExecutor 8142:puppetOrchestratorService
##ping_NC_Test.MASTER.4.COMPILER tcp 4433:nodeClassifier 5432:PostgreSqlDB_4Compilers2Connect 8081:puppetDB_TCP                     8142:puppetOrchestratorService 8143:puppetOrchestratorService
##ping_NC_Test.MASTER.4.GITLAB   tcp                                                                                                                                                                                                8170:puppetCodeManager
##ping_NC_Test.MASTER.4.SELF     tcp                                                                                                                                 8080:puppetDB_STATUS_HTTP_LOCALONLY

##ping_NC_Test.COMPILER.4.AGENT  tcp 8140:puppetExecutor 8142:puppetOrchestratorService
##ping_NC_Test.COMPILER.4.MASTER tcp 8140:puppetExecutor                                      8081:puppetDB_TCP
##ping_NC_Test.COMPILER.4.SELF   tcp                                                                                                                                 8080:puppetDB_STATUS_HTTP_LOCALONLY

##ping_NC_Test.REMOTEACCESS      tcp 22:ssh 3389:rdp 5985:winrm 5986:winrms udp 3389:rdp 5985:winrm 5986:winrms
##ping_NC_Test.PECONSOLE         tcp 22:ssh 80:http 443:https 4433:nodeClassifier 5432:PostgreSqlDB_4Compilers2Connect                                               8080:puppetDB_STATUS_HTTP_LOCALONLY 8081:puppetDB_TCP 8140:puppetServiceStatusEnpoint 8140:puppetExecutor 8142:puppetOrchestratorService  8143:puppetOrchestratorService 8170:puppetCodeManager
##ping_NC_Test.PECOMPILER        tcp 22:ssh                                                                                                                          8080:puppetDB_STATUS_HTTP_LOCALONLY 8081:puppetDB_TCP 8140:puppetServiceStatusEnpoint 8140:puppetExecutor 8142:puppetOrchestratorService  8143:puppetOrchestratorService
##ping_NC_Test.CD4PE             tcp 22:ssh                                                                 7000:puppetServiceEndpoint 8000:puppetBackServiceWebhook 8080:http                                                       8443:https
##ping_NC_Test.PUPPETWINAGENT    tcp 22:ssh 80:http 443:https 3389:rdp 5985:winrm 5986:winrms 8081:puppetDB 7000:puppetCodeManager                                                     udp 3389:rdp 5985:winrm 5986:winrms
##ping_NC_Test.PUPPETNIXAGENT    tcp 22:ssh 80:http 443:https                                                                                                                                                                                    8140:puppetExecutor                                 8143:puppetOrchestratorService 8170:puppetCodeManager

##ping_NC_Test.GITLAB            tcp 22:ssh 80:http 443:https

##ping_NC_Test.PUPPETFORGE       tcp        80:http 443:https

##ping_NC_Test.DEFAULT           tcp 22:ssh 80:http 443:https 3389:rdp 5985:winrm 5986:winrms                                                                        8000:puppetBackService    8081:puppetDB_TCP 8080:puppetDB_STATUS_HTTP 8081:PuppetDB 8140:puppetServer 8143:puppetOrchestratorService 8140:puppetExecutor 8170:puppetCodeManager udp 3389:rdp 5985:winrm 5986:winrms

    ncOpt="" ;
    portType="TCP"

    ip_=$1 ;
    echoMsg '==' "Quick Check access from Bolt"
    echoMeNRun ping -W10 -c3 $ip_  ||
    (
    	echoMsg ping -W10 -c3 $ip_
    	ping -W10 -c3 $ip_
    );
    echoMsg '==' "=="

    shift ;

    checkedPairs=""

    [ -z "$1" ] || {

        #defaultPorts=`getValueHashTags "ping_NC_Test.DEFAULT" ` # "3389:rdp 5985:winrm 5986:winrms 80:http 443:https 22:ssh 8081:PuppetDB 8140:puppetServer 8143:puppetOrchestratorService 8140:puppetExecutor 8170:puppetCodeManager udp 3389:rdp 5985:winrm 5986:winrms"

        #loadPorts="$1"
        #defaultPorts="$@"

        while [ "xxx$1" != "xxx"   ] ; do
          loadPorts="$1"
          defaultPorts="$1"

          [ "-" = "$loadPorts" ] && loadPorts="ping_NC_Test.DEFAULT" ;
          loadPorts=`getValueHashTags "$loadPorts" `
          [ -z "$loadPorts" ] ||  defaultPorts="$loadPorts"
          [  "x$1" = "xtcp" -o  "x$1" = "xudp"    ] && defaultPorts="$@"

          for port in   $defaultPorts ;  do
              #echo =====nc  -zv -w30 $ncOpt $ip_ $port===$port ;
              name="" ;
              if [[    $port =~ :  ]]  ;  then
              	#echo $port | IFS=:  read port name ;
              	name=`echo $port | cut -d: -f2 ` ;
              	port=`echo $port | cut -d: -f1 `
              fi;
              #echo =============$port==$name=====
              [ -z "$name" ] || name=" for ================ $name" ;

              curtag="@$port$ip_:$port@"

              if [[  $checkedPairs =~ $curtag    ]] ; then
                echoMsg '++' "================================================SKIPPED"   > /dev/null   # For Debugging
              else
                checkedPairs="@$checkedPairs$curtag"

                if  [ "$port" = "udp" ] ; then
                    ncOpt="-u" ;
                    portType="UDP" ;
                elif  [ "$port" = "tcp" ] ; then
                    ncOpt="" ;
                    portType="TCP" ;
                else
                  #echo nc  -zv -w30 $ncOpt $ip_ $port  ;
                  outputf=`mktemp`
# Too Complex to Debug.... Simplifying now                  
#                   (\
#      	             ( \
# 	                  	( \
# 	                  	  #((( test -z "$DEBUG" || echo -e "\n\n\n+++++Using nc1"   ) && which nc > /dev/null   &&  (echo HELO | nc  -zv -w10 $ncOpt $ip_ $port                                   2>&1 | tee ${outputf} > /dev/null )) && test   -z "`grep -i -E 'failed|timed out| \([0-9]+\)' ${outputf}`" ) || \
# 	                  	  \
# 	                  	  ((( test -z "$DEBUG" || echo -e "\n\n\n+++++Using curl0" ) && which curl > /dev/null &&  (echo HELO | curl  --max-time 10 --connect-timeout 10  -k https://$ip_:$port  2>&1 | tee ${outputf} > /dev/null )) && test   -z "`grep -i -E 'failed|Connected to ' ${outputf}`"  )         || \
# 	                  	  ((( test -z "$DEBUG" || echo -e "\n\n\n+++++Using curl1" ) && which curl > /dev/null &&  (echo HELO | curl  --max-time 10 --connect-timeout 10     http://$ip_:$port   2>&1 | tee ${outputf} > /dev/null )) && test   -z "`grep -i -E 'failed|Connected to ' ${outputf}`"  )         || \
# 	                      ((( test -z "$DEBUG" || echo -e "\n\n\n+++++Using curl2" ) && which curl > /dev/null &&  (echo HELO | curl  --max-time 10 --connect-timeout 10     telnet://$ip_:$port 2>&1 | tee ${outputf} > /dev/null )) && test   -z "`grep -i -E 'failed|Connected to ' ${outputf}`"  )         || \
# 	                      ((( test -z "$DEBUG" || echo -e "\n\n\n+++++Using nc2"   ) && which nc   > /dev/null &&  (echo HELO | nc -v -w30                                    $ncOpt $ip_ $port  2>&1 | tee ${outputf} > /dev/null )) && test ! -z "`grep -i -E 'succeeded|Connected to ' ${outputf}`" )          \
# 	                    ) || \
# 	                    (   \
#                       	  ( test -z "$DEBUG" || echo -e "\n\n\n+++++Check Curl and NC installation"   ) && \
#                       	  ( echo "curl:$( which curl > /dev/null && echo 'OK' || echo 'NOT installed' )  nc:$( which nc > /dev/null && echo 'OK' || echo 'NOT installed' )" | tee ${outputf} > /dev/null && ( test -z "`grep -i OK ${outputf}`" ) && cat  ${outputf} >&2 && ls -l /aaaaaa/confirmERROR ) \
# 	                    ) \
#                   	) && \
# 	                  echo  "OPEN   $portType : $ip_ $port : OPEN   $portType $name : $( head -n3 ${outputf} | tr '\n' ';' | cut -c1-100 )"  \
# 	              ) || \
#                   echo  "CLOSED $portType : $ip_ $port : CLOSED $portType       : $( head -n3 ${outputf} | tr '\n' ';' | cut -c1-100 )"
                  
                  
              	    (( test -z "$DEBUG" || echo -e "\n\n\n+++++Using curl0" ) && which curl > /dev/null &&  (echo HELO | curl -v --max-time 10 --connect-timeout 10  -k https://$ip_:$port  2>&1 | tee ${outputf} > /dev/null )) 
              	  
              	  test  ! -z "`grep -i -E 'succeeded|Connected to ' ${outputf}`"           || \
              	  	((( test -z "$DEBUG" || echo -e "\n\n\n+++++Using curl1" ) && which curl > /dev/null &&  (echo HELO | curl -v --max-time 10 --connect-timeout 10     http://$ip_:$port   2>&1 | tee ${outputf} > /dev/null ))  
              	  
              	  test  ! -z "`grep -i -E 'succeeded|Connected to ' ${outputf}`"  )         || \
                    ((( test -z "$DEBUG" || echo -e "\n\n\n+++++Using curl2" ) && which curl > /dev/null &&  (echo HELO | curl -v --max-time 10 --connect-timeout 10     telnet://$ip_:$port 2>&1 | tee ${outputf} > /dev/null ))  
                  
                  test  ! -z "`grep -i -E 'succeeded|Connected to ' ${outputf}`"  )         || \
                    ((( test -z "$DEBUG" || echo -e "\n\n\n+++++Using nc2"   ) && which nc   > /dev/null &&  (echo HELO | nc -v -w30                                    $ncOpt $ip_ $port  2>&1 | tee ${outputf} > /dev/null ))  
                  
                  test  ! -z "`grep -i -E 'succeeded|Connected to ' ${outputf}`" )       ||   \
                  	(   \
                  	  ( test -z "$DEBUG" || echo -e "\n\n\n+++++Check Curl and NC installation"   ) && \
                  	  ( echo "curl:$( which curl > /dev/null && echo 'OK' || echo 'NOT installed' )  nc:$( which nc > /dev/null && echo 'OK' || echo 'NOT installed' )" | tee ${outputf} > /dev/null && ( test -z "`grep -i OK ${outputf}`" ) && cat  ${outputf} >&2 && ls -l /aaaaaa/confirmERROR ) \
                    )

                  if  [ ! -z "`grep -i -E 'succeeded|Connected to ' ${outputf}`"  ] ; then 
	                  echo  "OPEN   $portType : $ip_ $port : OPEN   $portType $name : $( head -n3 ${outputf} | tr '\n' ';' | cut -c1-100 )" ;
	              else
    	              echo  "CLOSED $portType : $ip_ $port : CLOSED $portType       : $( head -n3 ${outputf} | tr '\n' ';' | cut -c1-100 )" ;
                  fi;
                 
                  test -z "$DEBUG" || catMe $outputf
                  rm -fr $outputf
                fi;
              fi;

          done;
          shift;
        done;
    }
}
function getValueHashTags(){
    key="$@" ;
    grep -E "^##$key " $0 | sed -E "s/^##$key //";
}
function runChain(){
	d=' '
	cmd2run=$1;
	if [ ${#cmd2run} -eq 1  ] ; then
		d=$cmd2run ;
		shift ;
		cmd2run='';
	fi;

	#echo d=$d    1=$1

	paras="$@";
	while [ ! -z "$paras"  ]  ; do

		if [ "$1" = "$d"  ] ; then
			echoMsg '==' Running.... $cmd2run ;
			$cmd2run
			echoMsg %% $cmd2run ;
			cmd2run="";
			shift;
		else
			cmd2run="$cmd2run $1";
			shift;
		fi;
		paras="$@";


	done;
	if [ ! -z "$cmd2run"  ] ; then
			echoMsg '==' $cmd2run ;
			$cmd2run
			echoMsg %% $cmd2run ;
	fi;
}
function installnvm(){
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash -
  source ~/.bashrc
  nvm install node ;
}
function rungithubactionuse(){
  if [ "$1" = "-" ] ; then
    shift ;
  fi;
  actioname=$1 ;
  
  export RUNNER_TEMP=${RUNNER_TEMP:-/tmp}
  
  giturl=${actioname/@*/}
  giturlbase=${giturl/*\//}
  gitbranch=${actioname/*@/}
  
  set | grep -E '^git|RUNNER_TEMP=' ;
  
  cd $RUNNER_TEMP ;
  git clone https://github.com/${giturl}.git
  cd ${giturlbase}

  which node 2> /dev/null > /dev/null || installnvm ;

  while [ ! -z $2 ] ; do
    echo ${2/*=/} > ./.${2/=*/} ;
    echo   ${2/*=/} = ./.${2/=*/} ;
    shift
  done ;
  grep -A2 runs: ./action.yml  | cut -d: -f2 | tr '\n'  ' ' | sed -E 's/node20/node/g' | bash -

  
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
	echo echo DISABLED: curl  \"https://raw.githubusercontent.com/sooyean-hoo/pe_curl_requests/feature/SYInstallerEnhance/installer/download_pe_tarball.sh\"   | bash - " ;
	cd $tmpDir &&  pwd && \
	echo echo DISABLED: curl  "https://raw.githubusercontent.com/sooyean-hoo/pe_curl_requests/feature/SYInstallerEnhance/installer/download_pe_tarball.sh"   | bash - ;

	ls -ltr ./puppet*.gz
	[ -s ./puppet*.gz ] ||  cd $tmpDir &&  pwd && dlPEConsole $DOWNLOAD_VERSION_REQ

	echoMsg '==' 'cd $tmpDir && tar -tf ./puppet*gz ; ls -ltr ./puppet*.gz  '

	cd $tmpDir && \
	ls -l ;  \
	tar -tf ./puppet*gz ; \
    ls -ltr ./puppet*.gz   ; \

}
 if  [ "loadlib" = "$1" ] ; then
  echo Loading....$0..... ;
  loadlibspuppet_tasks_sh="$loadlibs:$0:"
  return; exit 0;
 fi;
 if  [ "exec" = "$1" ] ; then
  shift ;
  echo Execing....$@..... ;
  $@ ; errorid=$?;
  return; exit $errorid;
 fi;
    tmpDir="${tmpDir:-$PWD}" ;
    export tmpDir="${tmpDir}" ;
    puppet_PuppetEntreprise_download ${DOWNLOAD_VERSION} $@
  
  
tar -tf  $(ls -1  ${tmpDir}/puppet*.gz) > /dev/null && (
      echo "Begin Checking........." ;
      ( tar  -t -f  ${tmpDir}/puppet*.gz    > /dev/null    && echo  "To Continue:  tar -xzvf    $(ls -1  ${tmpDir}/puppet*.gz) "  )  ||         {
        rm   -f         ${tmpDir}/puppet*.gz    ;
        echo " !!!!!!!!!!    ERROROUS DOWNLOAD : $(ls -1  ${tmpDir}/puppet*.gz)    Removed  !!!!!!!!!!!!!!!!!!!" ;  
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
			
			[ -z "$opensourcepuppetversion" ] && \
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
			
			
      osp="( 
       ["rhel"]='https://yum.puppet.com/<PLATFORM_NAME>-release-<OS_ABBREVIATION>-<OS_VERSION>.noarch.rpm'  
       ["ubuntu"]'https://apt.puppet.com/<PLATFORM_VERSION>-release-<VERSION_CODE_NAME>.deb'
      )"
      
      opsversion=( ${DOWNLOAD_VERSION//./ })
      
      if [ "$opensourcepuppetversion" = "L" ] ; then
        opensourcepuppetversion="" ;
      fi;
      opensourcepuppetversion_def=${opsversion[1]} ;
      opensourcepuppetversion=${opensourcepuppetversion:-$opensourcepuppetversion_def} ;
      opsversion1="puppet${opensourcepuppetversion}" ;

      echo '==============OSP==================='
      set | grep -E '^DOWNLOAD'
      echo '===================================='

      if [ "$DOWNLOAD_DIST" = "ubuntu" ] ; then
        echo "For Ubuntu" ;
        pkgurltemplate=$( grep -A4  osp= $0 | grep $DOWNLOAD_DIST | cut -d\'  -f2 ) ;
        if [ -z "$pkgurltemplate" ] ; then
          pkgurltemplate=$( echo $osp | sed -E 's/ /\n/g' | grep $DOWNLOAD_DIST | cut -d\'  -f2 ) ;
        fi;
           
        pkgurl=${pkgurltemplate/\<VERSION_CODE_NAME\>/$VERSION_CODENAME}
        pkgurl=${pkgurl/\<PLATFORM_VERSION\>/$opsversion1}
        
        echo "====OPENSOURCEPUPPET=pkgurl=$pkgurl"
      elif [ "$DOWNLOAD_DIST" = "rhel" ] ; then
        echo "For RedHat" ;
        
        echo "===thisfile=$thisfile" ;
        pkgurltemplate=$( grep -A4  osp= $0 | grep $DOWNLOAD_DIST | cut -d\'  -f2 ) ;
        if [ -z "$pkgurltemplate" ] ; then
          pkgurltemplate=$( echo $osp | sed -E 's/ /\n/g' | grep $DOWNLOAD_DIST | cut -d\'  -f2 ) ;
        fi;
        
        OS_ABB=$(echo $DOWNLOAD_DIST | sed -E 's/^.+([a-z]{2})/\1/g' )
        
        OSMajorversion=${opsversion[1]}
        
        pkgurl=${pkgurltemplate/\<OS_ABBREVIATION\>/$OS_ABB}
        pkgurl=${pkgurl/\<PLATFORM_NAME\>/$opsversion1}
        pkgurl=${pkgurl/\<OS_VERSION\>/$OSMajorversion}
        echo "====OPENSOURCEPUPPET=pkgurl=$pkgurl";
      else
        echo "ERROR: Not Supported" ;
      fi ;
			 
			
			
			
done ;
 rm -f $dlScript
