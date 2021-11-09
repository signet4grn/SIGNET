#!/bin/bash

cmdprefix="$SIGNET_ROOT/signet -s --"
freq=$(${cmdprefix}freq)
ntop=$(${cmdprefix}ntop)
tmpv=$(${cmdprefix}tmpv)
resv=$(${cmdprefix}resv)

ARGS=`getopt -a -o r:,h -l ntop:,n:,freq:,f:,tmpv:,resv:,h:,help -- "$@"`

function usage() {
	echo 'Usage:'
	echo 'signet -v  [OPTION VAL] ...'
        echo -e '\n'
	echo 'Description:'
        echo '  --freq FREQENCY              bootstrap frequecy for the visualization'
	echo '  --ntop N_TOP                 number of sub-networks'
        echo '  --tmpv                       set the temporary file directory'
        echo '  --resv                       set the result file directory'
	echo '  --help                       usage'
	exit -1
}

[ $? -ne 0 ] && usage

eval set -- "${ARGS}"

while true
do
case "$1" in
	--freq | --f)
		freq=$2
		${cmdprefix}freq $freq
                shift
		;;
	--ntop | --n)
		ntop=$2
                ${cmdprefix}ntop $ntop
		shift
		;;
	--tmpv)
                tmpv=$2
                $SIGNET_ROOT/signet -s --tmpv $tmpv
                shift;;
        --resv)
                resv=$2
                $SIGNET_ROOT/signet -s --resv $resv
                shift;;
	--h | --help)
		usage
		exit
              ;;
      --)
              shift
              break
              ;;
      esac
shift
done 

file_compare $tmpv $resv

## Do a file check
file_check $tmpv
file_check $resv

mkdir -p $SIGNET_TMP_ROOT/tmpv
mkdir -p $SIGNET_RESULT_ROOT/resv
mkdir -p $SIGNET_DATA_ROOT/netvis

$SIGNET_SCRIPT_ROOT/netvis/netvis.sh $freq $ntop  

cd $SIGNET_TMP_ROOT/tmpv
file_prefix signet
cd $cwd
file_trans $SIGNET_TMP_ROOT/tmpv/signet $tmpv

cd $SIGNET_RESULT_ROOT/resv
file_prefix signet
cd $cwd
file_trans $SIGNET_RESULT_ROOT/resv/signet $resv
