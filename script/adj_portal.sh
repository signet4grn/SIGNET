#!/bin/bash

usage() {
    echo "Usage:"
    echo "  signet -a [--c CLINICAL_FILE]" 
    echo -e "\n"
    echo "Description:"
    echo " --c | clinical                   set the clinical file for your cohort"
    exit -1
}

clifile=$($SIGNET_ROOT/signet -s --cli.file)

ARGS=`getopt -a -o a:r -l h:,c:,clinical:,help -- "$@"`

eval set -- "${ARGS}"

while [ $# -gt 0 ]
do
case "$1" in
        -h|--help)
		usage
		exit;;
	--c|--clinical)
                clifile=$2
		$SIGNET_ROOT/signet -s --cli.file $clifile
		shift;;
	--)
	     shift
	     break;;
esac
shift
done

mkdir -p $SIGNET_TMP_ROOT/tmpa
mkdir -p $SIGNET_RESULT_ROOT/resa
mkdir -p $SIGNET_DATA_ROOT/adj

$SIGNET_SCRIPT_ROOT/adj/adj.sh $clifile  && echo -e "Gene Expression and Genotype matching Finished\n"
