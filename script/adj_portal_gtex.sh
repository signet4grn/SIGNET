#!/bin/bash
usage() {
    echo "Usage:"
    echo "  signet -a --pheno" 
    echo -e "\n"
    echo "Description:"
    echo " --pheno                          GTEx phenotype file"
    echo " --resa                           result prefix"  
    exit -1
}

pheno=$($SIGNET_ROOT/signet -s --pheno | sed -r '/^\s*$/d' | xargs readlink -f)
gtf=$($SIGNET_ROOT/signet -s --gtf.file | sed -r '/^\s*$/d' | xargs readlink -f)
tissue=$($SIGNET_ROOT/signet -s --tissue | sed -r '/^\s*$/d')
anno=$($SIGNET_ROOT/signet -s --anno | sed -r '/^\s*$/d' | xargs readlink -f)
resa=$($SIGNET_ROOT/signet -s --resa.gtex | sed -r '/^\s*$/d' | xargs readlink -f)
resg=$($SIGNET_ROOT/signet -s --resg.gtex | sed -r '/^\s*$/d' | xargs readlink -f)
rest=$($SIGNET_ROOT/signet -s --rest.gtex | sed -r '/^\s*$/d' | xargs readlink -f)
forcerm=$($SIGNET_ROOT/signet -s --forcerm | sed -r '/^\s*$/d')

ARGS=`getopt -a -o a:r -l h:,pheno:,resa:,help -- "$@"`

eval set -- "${ARGS}"

while [ $# -gt 0 ]
do
case "$1" in
	--pheno)
                pheno=$2
		pheno=$(readlink -f $pheno)
		$SIGNET_ROOT/signet -s --pheno $pheno
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

file_purge $SIGNET_TMP_ROOT/tmpa $forcerm
mkdir -p $SIGNET_RESULT_ROOT/resa
mkdir -p $SIGNET_DATA_ROOT/adj
resa=$(dir_check $resa)

if [[ "$resa" == *"doesn't exist"* ]]; then
exit -1
fi

var="pheno tissue gtf anno rest resa"
for i in $var
do
export "${i}"
done


# check file existence
input_file="pheno anno"
for i in $input_file
do
file_check $(eval "$(echo "echo \$${i}")")
done

$SIGNET_SCRIPT_ROOT/adj/adj_gtex.sh && echo -e "Adjusting for covariates finished\n" 

echo -e "Finish time: $(date)"
