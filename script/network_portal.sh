#!/bin/bash

cmdprefix="$SIGNET_ROOT/signet -s --"
loc=$(${cmdprefix}cis.loc);
ncis=$(${cmdprefix}ncis);
cor=$(${cmdprefix}cor);
nboots=$(${cmdprefix}nboots);
ncores=$(${cmdprefix}ncores);
queue=$(${cmdprefix}queue);
memory=$(${cmdprefix}memory);
walltime=$(${cmdprefix}walltime)

ARGS=`getopt -a -o r: -l loc:,l:,ncis:,r:,maxcor:,memory:,m:,walltime:,:w:,nboots:,h:,help -- "$@"`

function usage() {
	echo 'Usage:'
	echo '  signet -s [OPTION VAL] ...'
	echo -e "\n"
	echo 'Description:'
	echo '  --loc CIS.LOC                 location of the result after the cis-eQTL analysis'
        echo '  --ncis NCIS		        maximum number of cis-eQTL for each gene'
	echo '  --cor MAX_COR 		        maximum corr. coeff. b/w cis-eQTL of same gene'
        echo '  --ncores N_CORE		number of cores in each node'
	echo '  --memory MEMEORY	        memory in each node in GB'
	echo '  --queue QUEUE                 queue name'
        echo '  --walltime WALLTIME		maximum walltime of the server in seconds'
	echo '  --nboots NBOOTS               number of bootstraps datasets'                   
	exit
}
[ $? -ne 0 ] && usage

eval set -- "${ARGS}"

while true
do
case "$1" in
	--loc)
                loc=$2
                ${cmdprefix}cis.loc $loc
                shift
              ;;
        --ncis)
		ncis=$2
		${cmdprefix}ncis $ncis
                shift
              ;;
	--r)
		cor=$2
		${cmdprefix}cor $cor
                shift;;
	--nboots)
		nboots=$2
		${cmdprefix}nboots $nboots
                shift;;
	--ncores)
		ncores=$2
		${cmdprefix}ncores $ncores
                shift;;
	--memory)
		memory=$2
                ${cmdprefix}memory $memory
		shift;;
	--walltime)
		walltime=$2
		${cmdprefix}walltime $walltime
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

$SIGNET_SCRIPT_ROOT/network/network.sh $nboots $cor $ncis $queue $ncores $memory $walltime $loc
