#!/bin/bash
usage() {
    echo "Usage:"
    echo "signet -t [--r READS_FILE] [--tpm TPM_FILE] [--gtf GTF_FILE]" 
    echo -e "\n"
    echo "Description:"
    echo " --r | --read                    gene reads file in gct format"
    echo " --t | --tpm                     gene tpm file"
    echo " --g | --gtf                     genecode gtf file"
    echo " --rest                          result prefix"
    exit -1
}

cwd=$(pwd)
reads=$($SIGNET_ROOT/signet -s --reads.file | xargs readlink -f)
tpm=$($SIGNET_ROOT/signet -s --tpm.file | xargs readlink -f )
gtf=$($SIGNET_ROOT/signet -s --gtf.file | xargs readlink -f | sed -r '/^\s*$/d')
rest=$($SIGNET_ROOT/signet -s --rest.gtex | sed -r '/^\s*$/d')

ARGS=`getopt -a -o a:r -l r:,read:,t:,tpm:,g:,gtf:,h:,rest:,help -- "$@"`

eval set -- "${ARGS}"

while [ $# -gt 0 ]
do
case "$1" in
	--r|--read)
		reads=$2
	        reads=$(readlink -f $reads)
		$SIGNET_ROOT/signet -s --reads.file $reads
		shift;;
        --t|--tpm) 
		tpm=$2
		tpm=$(readlink -f $tpm)
		$SIGNET_ROOT/signet -s --tpm.file $tpm
		shift;;
	--g|--gtf)
		gtf=$2
                gtf=$(readlink -f $gtf)
		$SIGNET_ROOT/signet -s --gtf.file $gtf
                shift;;
        --rest)
                rest=$2
                $SIGNET_ROOT/signet -s --rest.gtex $rest
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


var="reads tpm gtf rest"
for i in $var
do
export "${i}"
done

file_purge $SIGNET_TMP_ROOT/tmpt
mkdir -p $SIGNET_RESULT_ROOT/rest
mkdir -p $SIGNET_DATA_ROOT/gexp-prep
rest=$(dir_check $rest)

if [[ "$rest" == *"doesn't exist"* ]]; then
exit -1
fi

echo "reads.file: "$reads
echo "tpm.file: "$tpm
echo -e "\n"

$SIGNET_SCRIPT_ROOT/gexp_prep/gexp_prep_gtex.sh  && echo -e "Gene Expression Preprocessing Finished\nPlease look at PCA"

echo -e "Finish time: $(date)"
