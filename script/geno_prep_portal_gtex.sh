#!/bin/bash

usage() {
    echo "Usage:"
    echo "signet -g [OPTION VAL] ..."
    echo -e "\n"
    echo "Description:"
    echo "  --vcf0                        set the VCF file before phasing"
    echo "  --vcf                         set the VCF file for genotype data"
    echo "  --read                        set the read file for gene expression data"
    echo "  --anno                        set the annotation file"
    echo "  --tissue                      set the tissue type"
    echo "  --tmpg                        set the temporary file directory"
    echo "  --resg                        set the result file directory"
    exit -1
}


vcf0=$($SIGNET_ROOT/signet -s --vcf0)
vcf=$($SIGNET_ROOT/signet -s --vcf.file)
gexpread=$($SIGNET_ROOT/signet -s --read.file)
anno=$($SIGNET_ROOT/signet -s --anno)
tissue=$($SIGNET_ROOT/signet -s --tissue)
cwd=$(pwd)
tmpg=$($SIGNET_ROOT/signet -s --tmpg.gtex)
resg=$($SIGNET_ROOT/signet -s --resg.gtex)

ARGS=`getopt -a -o a:r -l v:,vcf:,vcf0:,r:,read:,a:,anno:,t:,tissue:,h:,tmpg:,resg:,help -- "$@"`

eval set -- "${ARGS}"

while [ $# -gt 0 ]
do
case "$1" in
	--vcf0)
                vcf0=$2
                vcf0=$(readlink -f $vcf0)
                $SIGNET_ROOT/signet -s --vcf0 $vcf0
                shift;;
	--vcf)
		vcf=$2
		vcf=$(readlink -f $vcf)
		$SIGNET_ROOT/signet -s --vcf.file $vcf
		shift;;
        --r|--read) 
		gexpread=$2
		gexpread=$(readlink -f $gexpread)
		$SIGNET_ROOT/signet -s --read.file $gexpread
		shift;;
	--a|--anno)
                anno=$2
                anno=$(readlink -f $anno)
                $SIGNET_ROOT/signet -s --anno $anno
                shift;;
	--t|--tissue)
                tissue=$2
                $SIGNET_ROOT/signet -s --tissue $tissue
                shift;;
	--tmpg)
                tmpg=$2
                $SIGNET_ROOT/signet -s --tmpg.gtex $tmpg
                shift;;
        --resg)
                resg=$2
                $SIGNET_ROOT/signet -s --resg.gtex $resg
	-h|--help)
	        usage
	        exit;;	
	--)
	     shift
	     break;;
esac
shift
done


file_compare $tmpg $resg

## Do a file check
file_check $tmpg $SIGNET_TMP_ROOT/tmpg
file_check $resg $SIGNET_RESULT_ROOT/resg

echo "vcf.file: "$vcf
echo -e "\n"

mkdir -p $SIGNET_TMP_ROOT/tmpg
mkdir -p $SIGNET_RESULT_ROOT/resg
mkdir -p $SIGNET_DATA_ROOT/geno-prep

$SIGGNET_SCRIPT_ROOT/geno_prep/geno_prep_gtex.sh $vcf0 $vcf $gexpread $anno $tissue  && echo "Genotype Preprocessing Finished"

cd $SIGNET_TMP_ROOT/tmpg
file_prefix signet
cd $cwd
file_trans $SIGNET_TMP_ROOT/tmpg/signet $tmpg

cd $SIGNET_RESULT_ROOT/resg
file_prefix signet
cd $cwd
file_trans $SIGNET_RESULT_ROOT/resg/signet $resg

