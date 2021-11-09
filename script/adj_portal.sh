#!/bin/bash

usage() {
    echo "Usage:"
    echo "  signet -a [--c CLINICAL_FILE]" 
    echo -e "\n"
    echo "Description:"
    echo " --c | clinical                   set the clinical file for your cohort"
    echo "  --tmpa                          set the temporary file directory"
    echo "  --resa                          set the result file directory"  
    exit -1
}

clifile=$($SIGNET_ROOT/signet -s --cli.file)
cwd=$(pwd)
tmpa=$($SIGNET_ROOT/signet -s --tmpa)
resa=$($SIGNET_ROOT/signet -s --resa)

ARGS=`getopt -a -o a:r -l h:,c:,clinical:,tmpa:,resa:,help -- "$@"`

eval set -- "${ARGS}"

while [ $# -gt 0 ]
do
case "$1" in
	--c|--clinical)
                clifile=$2
		$SIGNET_ROOT/signet -s --cli.file $clifile
		shift;;
	--tmpa)
                tmpa=$2
                $SIGNET_ROOT/signet -s --tmpa $tmpa
                shift;;
        --resa)
                resa=$2
                $SIGNET_ROOT/signet -s --resa $resa
                shift;;
        -h|--help)
                usage
                exit;;
	--)
	     shift
	     break;;
esac
shift
done

file_compare $tmpa $resa

## Do a file check
file_check $tmpa
file_check $resa

mkdir -p $SIGNET_TMP_ROOT/tmpa
mkdir -p $SIGNET_RESULT_ROOT/resa
mkdir -p $SIGNET_DATA_ROOT/adj

$SIGNET_SCRIPT_ROOT/adj/adj.sh $clifile  && echo -e "Gene Expression and Genotype matching Finished\n" 

cd $SIGNET_TMP_ROOT/tmpa
file_prefix signet
cd $cwd
file_trans $SIGNET_TMP_ROOT/tmpa/signet $tmpa

cd $SIGNET_RESULT_ROOT/resa
file_prefix signet
cd $cwd
file_trans $SIGNET_RESULT_ROOT/resa/signet $resa
