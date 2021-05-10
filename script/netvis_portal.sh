#!/bin/bash


cmdprefix="./config_controller.sh -l NETVIS,"
freq=$(${cmdprefix}freq);
ncount=$(${cmdprefix}ncount)
ninfo=$(${cmdprefix}ninfo)
ARGS=`getopt -a -o r:,h -l ncount:,freq:,ninfo:,help: -- "$@"`

function usage() {
	echo 'Usage:'
	echo '  netvis [OPTION VAL] ...'
	echo 'Description:'
	echo '  --freq FREQENCY			bootstrap frequecy for the visualization'
	echo '  --ncount NET_COUNT		number of sub-networks'
	echo '  --ninfo NODE_INFO_FILE          node information file'
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


cd netvis
./netvis.sh $freq $ncount $ninfo
