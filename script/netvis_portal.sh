#!/bin/bash

cmdprefix="$SIGNET_ROOT/signet -s --"
freq=$(${cmdprefix}freq);
ntop=$(${cmdprefix}ntop)

ARGS=`getopt -a -o r:,h -l ntop:,n:,freq:,f:,h:,help -- "$@"`

function usage() {
	echo 'Usage:'
	echo 'signet -v  [OPTION VAL] ...'
        echo -e '\n'
	echo 'Description:'
        echo '  --freq FREQENCY              bootstrap frequecy for the visualization'
	echo '  --ntop N_TOP                 number of sub-networks'
	echo '  --help                       usage'
	exit
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

mkdir -p $SIGNET_TMP_ROOT/tmpv
mkdir -p $SIGNET_RESULT_ROOT/resv
mkdir -p $SIGNET_DATA_ROOT/netvis

$SIGNET_SCRIPT_ROOT/netvis/netvis.sh $freq $ntop
