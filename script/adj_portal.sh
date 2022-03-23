#!/bin/bash
options=""
for((i=1;i<=$#;i++)); do
    j=${!i}
    options="${options} $j "
done

cohort=$($SIGNET_ROOT/signet -s --cohort | sed -r '/^\s*$/d')

if [[ $cohort == "GTEx" ]];then
echo -e "Preprocessing data for GTEx cohort\n"
$SIGNET_SCRIPT_ROOT/adj_portal_gtex.sh ${options}
exit 1
fi


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
resa=$($SIGNET_ROOT/signet -s --resa.tcga | sed -r '/^\s*$/d')
resg=$($SIGNET_ROOT/signet -s --resg.tcga | sed -r '/^\s*$/d')
rest=$($SIGNET_ROOT/signet -s --rest.tcga | sed -r '/^\s*$/d')

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
                $SIGNET_ROOT/signet -s --resa.tcga $resa
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
mkdir -p $SIGNET_RESULT_ROOT/resa
mkdir -p $SIGNET_DATA_ROOT/adj
resa=$(dir_check $resa)

if [[ "$resa" == *"doesn't exist"* ]]; then
exit -1
fi

var="clifile rest resg resa"
for i in $var
do
export "${i}"
done

$SIGNET_SCRIPT_ROOT/adj/adj.sh && echo -e "Gene Expression and Genotype matching Finished\n" 

echo -e "Finish time: $(date)"
