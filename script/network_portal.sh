#!/bin/bash

cmdprefix="$SIGNET_ROOT/signet -s --"
ncis=$(${cmdprefix}uncor.ncis);
r=$(${cmdprefix}uncor.r);
nboots=$(${cmdprefix}nboots);
nnodes=$(${cmdprefix}nnodes);
ncores=$(${cmdprefix}ncores);
memory=$(${cmdprefix}memory);
walltime=$(${cmdprefix}walltime)

ARGS=`getopt -a -o r: -l ncis:,r:,maxcor:,nnodes:,memory:,walltime:,nboots:,h:,help -- "$@"`

function usage() {
	echo 'Usage:'
	echo '  network [OPTION VAL] ...'
	echo -e "\n"
	echo 'Description:'
	echo '  --ncis NCIS			maximum number of cis-eQTL for each gene'
	echo '  -r MAX_COR		        maximum corr. coeff. b/w cis-eQTL of same gene'
	echo '  --nnodes N_NODE			'
        echo '  --ncores N_CORES		number of cores in each node'
	echo '  --memory MEMORY		memory in each node'
	echo '  --walltime WALLTIME		walltime of the server'
	echo '  --nboots NBOOTS               number of bootstraps'                   
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
	--r)
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
	--h|--help)
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
