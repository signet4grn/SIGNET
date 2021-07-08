#!/bin/bash

cmdprefix="$SIGNET_ROOT/signet -s --"
freq=$(${cmdprefix}freq);
nsubs=$(${cmdprefix}nsubs)

ARGS=`getopt -a -o r:,h -l nsub:,n:,freq:,f:,h:,help -- "$@"`

function usage() {
	echo 'Usage:'
	echo 'signet -v  [OPTION VAL] ...'
        echo -e '\n'
	echo 'Description:'
        echo '  --freq FREQENCY              bootstrap frequecy for the visualization'
	echo '  --nsubs N_SUBS               number of sub-networks'
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
	--nsubs | --n)
		nsubs=$2
                ${cmdprefix}nsubs $nsubs
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

touch $SIGNET_TMP_ROOT/tmpv
touch $SIGNET_RESULT_ROOT/resv
touch $SIGNET_DATA_ROOT/netvis

$SIGNET_SCRIPT_ROOT/netvis.sh $freq $nsubs
