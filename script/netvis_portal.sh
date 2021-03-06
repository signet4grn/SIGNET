#!/bin/bash

cmdprefix="$SIGNET_ROOT/signet -s --"
Afreq=$(${cmdprefix}Afreq | sed -r '/^\s*$/d' | xargs readlink -f )
freq=$(${cmdprefix}freq)
ntop=$(${cmdprefix}ntop)
coef=$(${cmdprefix}coef | sed -r '/^\s*$/d' | xargs readlink -f )
genepos=$(${cmdprefix}vis.genepos | sed -r '/^\s*$/d' | xargs readlink -f )
id=$(${cmdprefix}id | sed -r '/^\s*$/d')
assembly=$(${cmdprefix}assembly | sed -r '/^\s*$/d')
tf=$(${cmdprefix}tf | sed -r '/^\s*$/d' | xargs readlink -f )
resv=$(${cmdprefix}resv | sed -r '/^\s*$/d')
nchr=$(${cmdprefix}nchr)
forcerm=$($SIGNET_ROOT/signet -s --forcerm | sed -r '/^\s*$/d')

function usage() {
        echo -e 'Pre-requisite: \n'
	echo -e 'You should first type "ssh -Y $(hostname)" to a server with DISPLAY if you would like to use the singularity container, and the result can be viewed through a pop up firefox web browser \n'
	echo 'Usage:'
	echo 'signet -v [OPTION VAL] ...'
        echo -e '\n'
	echo 'Description:'
        echo '  --Afreq                      matrix of regulation frequencies from bootstrap results'
        echo '  --freq                       bootstrap frequecy for the visualization'
	echo '  --ntop                       number of top sub-networks to visualize'
        echo '  --coef                       coefficient of estimation for the original dataset'
        echo '  --vis.genepos                gene position file'
        echo '  --id                         NCBI taxonomy id, e.g. 9606 for Homo Sapiens, 10090 for Mus musculus'
        echo '  --assembly                   genome assembly, e.g. hg38 for Homo Sapiens, mm10 for Mus musculus'
        echo '  --tf                         transcirption factor file, only sepecified for non-human data'
        echo '  --resv                       result prefix'
	echo '  --help                       usage'
	exit -1
}

[ $? -ne 0 ] && usage

ARGS=`getopt -a -o r:,h -l ntop:,n:,coef:,c:,g:,vis.genepos:,Afreq:,freq:,f:,id:,assembly:,tf:,resv:,h:,help -- "$@"`

eval set -- "${ARGS}"

while true
do
case "$1" in
        --Afreq)
                Afreq=$2
		Afreq=$(readlink -f $Afreq)
		${cmdprefix}Afreq $Afreq
                shift
                ;;
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
	--coef | --c)
                coef=$2
		coef=$(readlink -f $coef)
                ${cmdprefix}coef $coef
                shift;;
        --vis.genepos | --g)
                genepos=$2
		genepos=$(readlink -f $genepos)
                ${cmdprefix}vis.genepos $genepos
                shift;;
        --id)
                id=$2
                ${cmdprefix}id $id
                shift;;
        --assembly)
                assembly=$2
                ${cmdprefix}assembly $assembly
                shift;;
        --tf)
                tf=$2
                ${cmdprefix}tf $tf
                shift;;
        --resv)
                resv=$2
                ${cmdprefix}resv $resv
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

file_purge $SIGNET_TMP_ROOT/tmpv $forcerm
mkdir -p $SIGNET_RESULT_ROOT/resv
mkdir -p $SIGNET_DATA_ROOT/netvis
resv=$(dir_check $resv)

if [[ "$resv" == *"doesn't exist"* ]]; then
exit -1
fi

var="Afreq freq nchr ntop coef genepos id assembly tf resv"
for i in $var
do
export "${i}"
done

# check file existence
input_file="Afreq genepos"
for i in $input_file
do
file_check $(eval "$(echo "echo \$${i}")")
done

$SIGNET_SCRIPT_ROOT/netvis/netvis.sh

echo -e "Finish time: $(date)"
