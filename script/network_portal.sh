#!/bin/bash

cmdprefix="$SIGNET_ROOT/signet -s --"
net_gexp=$(${cmdprefix}net.gexp.data | sed -r '/^\s*$/d' | xargs readlink -f)
net_geno=$(${cmdprefix}net.geno.data | sed -r '/^\s*$/d' | xargs readlink -f)
sig_pair=$(${cmdprefix}sig.pair | sed -r '/^\s*$/d' | xargs readlink -f)
net_genename=$(${cmdprefix}net.genename | sed -r '/^\s*$/d'| xargs readlink -f)
net_genepos=$(${cmdprefix}net.genepos | sed -r '/^\s*$/d'| xargs readlink -f)
ncis=$(${cmdprefix}ncis)
cor=$(${cmdprefix}cor)
nboots=$(${cmdprefix}nboots | sed -r '/^\s*$/d')
ncores=$(${cmdprefix}ncores | sed -r '/^\s*$/d')
queue=$(${cmdprefix}queue | sed -r '/^\s*$/d')
memory=$(${cmdprefix}memory | sed -r '/^\s*$/d')
walltime=$(${cmdprefix}walltime | sed -r '/^\s*$/d')
resn=$($SIGNET_ROOT/signet -s --resn  | sed -r '/^\s*$/d')


function usage() {
	echo 'Usage:'
	echo '  signet -n [OPTION VAL] ...'
	echo -e "\n"
	echo 'Description:'
	echo '  --net.gexp.data               gene expression data for network analysis'
	echo '  --net.geno.data               marker data for network analysis'
        echo '  --sig.pair        	        significant index pairs for gene expression and markers'
	echo '  --net.genename                gene name files for gene expression data'
        echo '  --net.genepos                 gene position files for gene expression data'
        echo '  --ncis                        maximum number of biomarkers for each gene'
        echo '  --cor                         maximum correlation between biomarkers'
        echo '  --nboots NBOOTS               number of bootstraps datasets'
        echo '  --memory MEMEORY	        memory in each node in GB'd
	echo '  --queue QUEUE                 queue name'
        echo '  --ncores                      number of scores for each node'
        echo '  --walltime WALLTIME		maximum walltime of the server in seconds'
        echo "  --resn                        set the result file directory"
	exit -1 
}
[ $? -ne 0 ] && usage

ARGS=`getopt -a -o r: -l net.gexp.data:,net.geno.data:,sig.pair:,net.genepos:,net.genename:,ncis:,r:,cor:,memory:,m:,queue:,q:,walltime:,:w:,nboots:,ncores:,resn:,h:,help -- "$@"`

eval set -- "${ARGS}"

while true
do
case "$1" in
        --net.gexp.data)
                net_gexp=$2
                net_gexp=$(readlink -f $net_gexp)
                ${cmdprefix}net.gexp.data $net_gexp
                shift;;
        --net.geno.data)
                net_geno=$2
                net_geno=$(readlink -f $net_geno)
                ${cmdprefix}net.geno.data $net_geno
                shift;;
        --sig.pair)
                sig_pair=$2
                sig_pair=$(readlink -f $sig_pair)
                ${cmdprefix}sig.pair $sig_pair
                shift;;
        --net.genepos)
                net_genepos=$2
                net_genepos=$(readlink -f $net_genepos)
                ${cmdprefix}net.genepos $net_genepos
                shift;;
        --net.genename)
                net_genename=$2
                net_genename=$(readlink -f $net_genename)
                ${cmdprefix}net.genename $net_genename
                shift;;
        --ncis)
                ncis=$2
                ${cmdprefix}ncis $ncis
                shift;;
        --cor | --r)
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
	--memory | --m)
		memory=$2
                ${cmdprefix}memory $memory
		shift;;
	--queue | --q)
                queue=$2
                ${cmdprefix}queue $queue
                shift;;
        --walltime)
		walltime=$2
		${cmdprefix}walltime $walltime
                shift;;
        --resn)
                resn=$2
                $SIGNET_ROOT/signet -s --resn $resn
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

file_purge $SIGNET_TMP_ROOT/tmpn
resn=$(dir_check $resn)
mkdir -p $SIGNET_RESULT_ROOT/resn
mkdir -p $SIGNET_DATA_ROOT/network

var="net_gexp net_geno sig_pair net_genename net_genepos cor ncis ncores memory nboots queue walltime resn"
for i in $var
do
export "${i}"
done

$SIGNET_SCRIPT_ROOT/network/network.sh

