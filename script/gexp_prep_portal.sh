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
    echo " --g | --gexp                   gene expression file"
    echo " --p | --pmap                   genecode gtf file "
    echo " --restrict                     restrict to the chromosome of interest"
    echo " --rest                         result prefix"
    exit -1
}


gexpfile=$($SIGNET_ROOT/signet -s --gexp.file|xargs readlink -f)
pmapfile=$($SIGNET_ROOT/signet -s --pmap.file|xargs readlink -f)
restrict=$($SIGNET_ROOT/signet -s --restrict.tcga | sed -r '/^\s*$/d')
rest=$($SIGNET_ROOT/signet -s --rest.tcga | sed -r '/^\s*$/d')
forcerm=$($SIGNET_ROOT/signet -s --forcerm | sed -r '/^\s*$/d')

ARGS=`getopt -a -o a:r -l g:,gexp:,p:,pmap:,h:,rest:,restrict:,help -- "$@"`

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
        --restrict)
                restrict=$2
                $SIGNET_ROOT/signet -s --restrict.tcga $restrict
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
echo "pmap.file: "$pmapfile
echo "restrict on chromosome: "$restrict
echo -e "\n"

file_purge $SIGNET_TMP_ROOT/tmpt $forcerm
mkdir -p $SIGNET_RESULT_ROOT/rest
mkdir -p $SIGNET_DATA_ROOT/gexp-prep
rest=$(dir_check $rest)

if [[ "$rest" == *"doesn't exist"* ]]; then
exit -1 
fi

var="gexpfile pmapfile restrict rest"
for i in $var
do
export "${i}"
done

# check file existence
input_file="gexpfile pmapfile"
for i in $input_file
do
file_check $(eval "$(echo "echo \$${i}")")
done 

$SIGNET_SCRIPT_ROOT/gexp_prep/gexp_prep.sh && echo -e "Gene Expression Preprocessing Finished\nPlease look at PCA\n"

echo -e "Finish time: $(date)"
