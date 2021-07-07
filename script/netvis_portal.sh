#!/bin/bash

cmdprefix="$SIGNET_ROOT/signet -v --"
freq=$(${cmdprefix}freq);
ncount=$(${cmdprefix}ncount)

ARGS=`getopt -a -o r:,h -l nsub:,freq:,help: -- "$@"`

function usage() {
	echo 'Usage:'
	echo 'signet -v  [OPTION VAL] ...'
	echo 'Description:'
	echo '  --freq FREQENCY			bootstrap frequecy for the visualization'
	echo '  --ncount NET_COUNT		number of sub-networks'
	echo '  -h | --help                     usage'
	exit
}

[ $? -ne 0 ] && usage

eval set -- "${ARGS}"

while true
do
case "$1" in
	--freq)
		freq=$2
		shift
		;;
	--ncount)
		ncount=$2
		shift
		;;
	--ninfo)
		ninfo=$2
		shift
		;;
	-h|--help)
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


$SIGNET_SCRIPT_ROOT/netvis.sh $freq $ncount $ninfo
