echo ::
	echo Running as Bash CMD FakeMake
	target=$1 ; \
	runfile=/tmp/test.sh ;  \
	> $runfile  ;  \
	pwd ; \
	while [ ! -z "$1" ] ; do  \
		echo  "$1" | grep '=' &&  echo  $1 >> $runfile ; \
		shift ;  \
	done;  \
	execution=`egrep  -h -A100 ^$target    $(dirname $0)/./Makefile  |  egrep -v ^$target  | egrep -m 1  -h  -B100 '^[a-zA-Z0-9]+:' |    sed -E  's/[$][{](.+)[}]/$\1/g' | sed -E 's/[$]{2}/$/g' ` ; \
	echo Command to Execute @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@;  \
	echo "$execution" ; \
	echo Execution @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@;   \
	echo "$execution" >>  $runfile ;  \
	echo "" >>  $runfile ;  \
	cat $runfile ;     \
	bash $runfile  ;   returnerr=$? ; \
	echo Execution DONE with err=${returnerr}@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@; \
	rm -f $runfile ; \
	exit ${returnerr};

help::
	if [ "${t}" = "" ] ; then \
		grep -E "^[a-zA-Z0-9_ ]+[:]+" Makefile   | awk -F":" '{print $$1}' ;  \
			 [[   $$PWD   =~   valentepuppet  ]]  || grep -E "^[a-zA-Z0-9_ ]+[:]+" ~/mym/valentepuppet/Makefile   | awk -F":" '{print $$1}'   ; \
	else \
		grep -E "^[a-zA-Z0-9_ ]+[:]+" Makefile   | grep -i "${t}"  | tr ";:\043" " "  ;   \
			 [[   $$PWD   =~   valentepuppet  ]]  ||   grep -E "^[a-zA-Z0-9_ ]+[:]+" ~/mym/valentepuppet/Makefile   | grep -i "${t}"  | tr ";:\043" " "   ;      \
	fi;

globalvariablestarthere::
	echo a Marker for Start of Global Variable

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
dmkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))
makefilepath:=${shell ps -af  -p $$$$ | grep Makefile | grep -v grep | grep -v sed |sed -E 's/^.+ ([^ ]+Makefile) .+$$/\1/g' }

all_:
	pwd ;
	env;



####### GitHub Release #### START
include /Users/valente/Dropbox/bin/valentepuppet/Makefile
####### GitHub Release #### END

regen:
	cd ./installer/ && eval $$(./download_pe_tarball.sh regen)

