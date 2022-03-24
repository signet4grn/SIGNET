#!/bin/bash

usage() {
    echo "Usage:"
    echo "signet -g [OPTION VAL] ..."
    echo -e "\n"
    echo "Description:"
    echo "  --vcf0                        VCF file before phasing"
    echo "  --vcf                         VCF file for genotype data after phasing"
    echo "  --read                        read file for gene expression data"
    echo "  --anno                        annotation file"
    echo "  --tissue                      tissue type"
    echo "  --resg                        result prefix"
    exit -1
}

cwd=$(pwd)
vcf0=$($SIGNET_ROOT/signet -s --vcf0)
vcf=$($SIGNET_ROOT/signet -s --vcf.file)
gexpread=$($SIGNET_ROOT/signet -s --read.file)
anno=$($SIGNET_ROOT/signet -s --anno)
tissue=$($SIGNET_ROOT/signet -s --tissue)
resg=$($SIGNET_ROOT/signet -s --resg.gtex)

ARGS=`getopt -a -o a:r -l v:,vcf:,vcf0:,r:,read:,a:,anno:,t:,tissue:,h:,resg:,help -- "$@"`

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
        --resg)
                resg=$2
                $SIGNET_ROOT/signet -s --resg.gtex $resg
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

file_purge $SIGNET_TMP_ROOT/tmpg
mkdir -p $SIGNET_RESULT_ROOT/resg
mkdir -p $SIGNET_DATA_ROOT/geno-prep
resg=$(dir_check $resg)

if [[ "$resg" == *"doesn't exist"* ]]; then
exit -1
fi

var="vcf0 vcf gexpread anno tissue resg"
for i in $var
do
export "${i}"
done

# check file existence
input_file="vcf0 vcf gexpread anno"
for i in $input_file
do
file_check $(eval "$(echo "echo \$${i}")")
done

echo "vcf.file: "$vcf
echo -e "\n"

$SIGNET_SCRIPT_ROOT/geno_prep/geno_prep_gtex.sh && echo "Genotype Preprocessing Finished"

echo -e "Finish time: $(date)"
