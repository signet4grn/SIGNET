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
    echo "  signet -t [--g GEXP_FILE] [--p MAP_FILE]" 
    echo -e "\n"
    echo "Description:"
    echo " --g | --gexp                   set gene expression file"
    echo " --p | --pmap                   set the genecode gtf file "
    echo " --tmpt                         set the temporary file directory"
    echo " --rest                         set the result file directory"
    exit -1
}


gexpfile=$($SIGNET_ROOT/signet -s --gexp.file)
pmapfile=$($SIGNET_ROOT/signet -s --pmap.file)

cwd=$(pwd)
tmpt=$($SIGNET_ROOT/signet -s --tmpt.tcga)
rest=$($SIGNET_ROOT/signet -s --rest.tcga)

ARGS=`getopt -a -o a:r -l g:,gexp:,p:,pmap:,h:,tmpt:,rest:,help -- "$@"`

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
	--tmpt)
                tmpt=$2
                $SIGNET_ROOT/signet -s --tmpt.tcga $tmpt
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

file_compare $tmpt $rest

## Do a file check
file_check $tmpt $SIGNET_TMP_ROOT/tmpt
file_check $rest $SIGNET_RESULT_ROOT/rest

echo -e "\n"
echo "gexp.file: "$gexpfile
echo "pamp.file: "$pmapfile
echo -e "\n"

mkdir -p $SIGNET_TMP_ROOT/tmpt
mkdir -p $SIGNET_RESULT_ROOT/rest
mkdir -p $SIGNET_DATA_ROOT/gexp-prep

$SIGNET_SCRIPT_ROOT/gexp_prep/gexp_prep.sh $gexpfile $pmapfile && echo -e "Gene Expression Preprocessing Finished\nPlease look at PCA"

cd $SIGNET_TMP_ROOT/tmpt
file_prefix signet
cd $cwd
file_trans $SIGNET_TMP_ROOT/tmpt/signet $tmpt

cd $SIGNET_RESULT_ROOT/rest
file_prefix signet
cd $cwd
file_trans $SIGNET_RESULT_ROOT/rest/signet $rest

