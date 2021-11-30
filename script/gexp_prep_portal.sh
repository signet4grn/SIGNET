#!/bin/bash
options=""
for((i=1;i<=$#;i++)); do
    j=${!i}
    options="${options} $j "
done

cohort=$($SIGNET_ROOT/signet -s --cohort | sed -r '/^\s*$/d')

if [[ $cohort == "GTEx" ]];then
echo -e "Preprocessing data for GTEx cohort\n"
$SIGNET_SCRIPT_ROOT/gexp_prep_portal_gtex.sh ${options}
exit 1
fi


usage() {
    echo "Usage:"
    echo "  signet -t [--g GEXP_FILE] [--p MAP_FILE] " 
    echo -e "\n"
    echo "Description:"
    echo " --g | --gexp                   set gene expression file"
    echo " --p | --pmap                   set the genecode gtf file "
    echo " --rest                   set the result name"
    exit -1
}


gexpfile=$($SIGNET_ROOT/signet -s --gexp.file)
pmapfile=$($SIGNET_ROOT/signet -s --pmap.file)
rest=$($SIGNET_ROOT/signet -s --rest.tcga | sed -r '/^\s*$/d')

ARGS=`getopt -a -o a:r -l g:,gexp:,p:,pmap:,h:,rest:,help -- "$@"`

eval set -- "${ARGS}"

while [ $# -gt 0 ]
do
case "$1" in
	--g|--gexp)
		gexpfile=$2
		gexpfile=$(readlink -f $gexpfile)
		$SIGNET_ROOT/signet -s --gexp.file $gexpfile
		shift;;
        --p|--pmap) 
		pmapfile=$2
		pmapfile=$(readlink -f $pmapfile)
		$SIGNET_ROOT/signet -s --pmap.file $pmapfile
		shift;;
        --rest)
                rest=$2
		$SIGNET_ROOT/signet -s --rest.tcga $rest
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

echo -e "\n"
echo "gexp.file: "$gexpfile
echo "pamp.file: "$pmapfile
echo -e "\n"

file_purge $SIGNET_TMP_ROOT/tmpt
dir_check $rest
mkdir -p $SIGNET_RESULT_ROOT/rest
mkdir -p $SIGNET_DATA_ROOT/gexp-prep

var="gexpfile pmapfile rest"
for i in $var
do
export "${i}"
done

$SIGNET_SCRIPT_ROOT/gexp_prep/gexp_prep.sh && echo -e "Gene Expression Preprocessing Finished\nPlease look at PCA"

