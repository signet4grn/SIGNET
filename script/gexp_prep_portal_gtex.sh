#!/bin/bash
usage() {
    echo "Usage:"
    echo "  signet -t [--r READS_FILE] [--tpm TPM_FILE]" 
    echo -e "\n"
    echo "Description:"
    echo " --r | --reads                   set the GTEx gene reads file in gct format"
    echo " --t | --tpm                     set the gene tpm file"
    echo " --g | --gtf                     set the genecode gtf file"
    echo " --tmpt                          set the temporary file directory"
    echo " --rest                          set the result file directory"
    exit -1
}


reads=$($SIGNET_ROOT/signet -s --reads.file)
tpm=$($SIGNET_ROOT/signet -s --tpm.file)
gtf=$($SIGNET_ROOT/signet -s --gtf.file | sed -r '/^\s*$/d')

cwd=$(pwd)
tmpt=$($SIGNET_ROOT/signet -s --tmpt.gtex)
rest=$($SIGNET_ROOT/signet -s --rest.gtex)

ARGS=`getopt -a -o a:r -l r:,reads:,t:,tpm:,g:,gtf:,h:,tmpt:,rest:,help -- "$@"`

eval set -- "${ARGS}"

while [ $# -gt 0 ]
do
case "$1" in
	--r|--reads)
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
        --tmpt)
                tmpt=$2
                $SIGNET_ROOT/signet -s --tmpt.gtex $tmpt
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

file_compare $tmpt $rest

## Do a file check
file_check $tmpt $SIGNET_TMP_ROOT/tmpt
file_check $rest $SIGNET_RESULT_ROOT/rest

echo "reads.file: "$reads
echo "tpm.file: "$tpm
echo -e "\n"

mkdir -p $SIGNET_TMP_ROOT/tmpt
mkdir -p $SIGNET_RESULT_ROOT/rest
mkdir -p $SIGNET_DATA_ROOT/gexp-prep


$SIGNET_SCRIPT_ROOT/gexp_prep/gexp_prep_gtex.sh $reads $tpm $gtf && echo -e "Gene Expression Preprocessing Finished\nPlease look at PCA"

cd $SIGNET_TMP_ROOT/tmpt
file_prefix signet
cd $cwd
file_trans $SIGNET_TMP_ROOT/tmpt/signet $tmpt

cd $SIGNET_RESULT_ROOT/rest
file_prefix signet
cd $cwd
file_trans $SIGNET_RESULT_ROOT/rest/signet $rest
