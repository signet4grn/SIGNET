#!/bin/bash

cmdprefix="$SIGNET_ROOT/signet -s --"
Afreq=$(${cmdprefix}Afreq)
freq=$(${cmdprefix}freq)
ntop=$(${cmdprefix}ntop)
coef=$(${cmdprefix}coef | sed -r '/^\s*$/d' | xargs readlink -f )
genepos=$(${cmdprefix}vis.genepos | sed -r '/^\s*$/d' | xargs readlink -f )
resv=$(${cmdprefix}resv | sed -r '/^\s*$/d')

function usage() {
        echo -e 'Pre-requisite: \n'
        echo -e 'You should first SSH -XY to a server with DISPLAY if you would like to use the singularity container \n'
	echo 'Usage:'
	echo 'signet -v  [OPTION VAL] ...'
        echo -e '\n'
	echo 'Description:'
        echo '  --Afreq EDGE_FREQ            matrix of edge frequencies from bootstrap result'
        echo '  --freq FREQENCY              bootstrap frequecy for the visualization'
	echo '  --ntop N_TOP                 number of top sub-networks'
        echo '  --coef COEF                  coefficient of estimation for the original dataset'
        echo '  --vis.genepos                gene position file'
        echo '  --resv                       set the result file directory'
	echo '  --help                       usage'
	exit -1
}

[ $? -ne 0 ] && usage

ARGS=`getopt -a -o r:,h -l ntop:,n:,coef:,c:,g:,vis.genepos:,Afreq:,freq:,f:,resv:,h:,help -- "$@"`

eval set -- "${ARGS}"

while true
do
case "$1" in
        --Afreq)
                Afreq=$2
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
                ${cmdprefix}coef $coef
                shift;;
        --vis.genepos | --g)
                genepos=$2
                ${cmdprefix}vis.genepos $genepos
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

file_purge $SIGNET_TMP_ROOT/tmpv
resv=$(dir_check $resv)
mkdir -p $SIGNET_RESULT_ROOT/resv
mkdir -p $SIGNET_DATA_ROOT/netvis

var="Afreq freq ntop coef genepos resv"
for i in $var
do
export "${i}"
done

$SIGNET_SCRIPT_ROOT/netvis/netvis.sh
