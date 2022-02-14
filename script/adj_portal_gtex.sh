#!/bin/bash
usage() {
    echo "Usage:"
    echo "  signet -a [--c CLINICAL_FILE]" 
    echo -e "\n"
    echo "Description:"
    echo " --c | clinical                   clinical file for your cohort"
    echo " --resa                           result prefix"  
    exit -1
}

clifile=$($SIGNET_ROOT/signet -s --cli.file | sed -r '/^\s*$/d')
resa=$($SIGNET_ROOT/signet -s --resa.gtex | sed -r '/^\s*$/d')
resg=$($SIGNET_ROOT/signet -s --resg.gtex | sed -r '/^\s*$/d')
rest=$($SIGNET_ROOT/signet -s --rest.gtex | sed -r '/^\s*$/d')

ARGS=`getopt -a -o a:r -l h:,c:,clinical:,resa:,help -- "$@"`

eval set -- "${ARGS}"

while [ $# -gt 0 ]
do
case "$1" in
	--c|--clinical)
                clifile=$2
		$SIGNET_ROOT/signet -s --cli.file $clifile
		shift;;
        --resa)
                resa=$2
                $SIGNET_ROOT/signet -s --resa.gtex $resa
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

file_purge $SIGNET_TMP_ROOT/tmpa
resa=$(dir_check $resa)
mkdir -p $SIGNET_RESULT_ROOT/resa
mkdir -p $SIGNET_DATA_ROOT/adj

var="clifile rest resg resa"
for i in $var
do
export "${i}"
done

$SIGNET_SCRIPT_ROOT/adj/adj_gtex.sh && echo -e "Gene Expression and Genotype matching Finished\n" 

