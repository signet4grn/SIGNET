#!/bin/bash


cmdprefix="./config_controller.sh -l NETWORK,"
ncis=$(${cmdprefix}uncor.ncis);
r=$(${cmdprefix}uncor.r);
nboots=$(${cmdprefix}nboots);
nnodes=$(${cmdprefix}nnodes);
ncores=$(${cmdprefix}ncores);
memory=$(${cmdprefix}memory);
walltime=$(${cmdprefix}walltime)
ARGS=`getopt -a -o r: -l ncis:,maxcor:,nnodes:,memory:,walltime:,help:,nboots: -- "$@"`

function usage() {
	echo 'Usage:'
	echo '  network [OPTION VAL] ...'
	echo 'Description:'
	echo '  --ncis NCIS			maximum number of cis-eQTL for each gene'
	echo '  -r MAX_COR		maximum corr. coeff. b/w cis-eQTL of same gene'
	echo '  --nnodes N_NODE			'
echo '  --ncores N_CORES			'
	echo '  --memory MEMORY			'
	echo '  --walltime WALLTIME		'
	echo '  --nboots NBOOTS'
	exit
}
[ $? -ne 0 ] && usage

eval set -- "${ARGS}"

while true
do
case "$1" in
	--ncis)
		ncis=$2
		shift
              ;;
	-r)
		r=$2
		shift;;
	--nboots)
		nboots=$2
		shift;;
	--nnodes)
		nnodes=$2
		shift;;
	--ncores)
		ncores=$2
		shift;;
	--memory)
		memory=$2
		shift;;
	--walltime)
		walltime=$2
		shift;;
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


cd network
./network.sh $nboots $r $ncis $nnode $ncores $memory $walltime 
