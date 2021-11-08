#!/bin/bash
options=""
for((i=1;i<=$#;i++)); do
    j=${!i}
    options="${options} $j "
done

cohort=$($SIGNET_ROOT/signet -s --cohort | sed -r '/^\s*$/d')

if [[ $cohort == "GTEx" ]];then
echo -e "Preprocessing data for GTEx cohort\n"
$SIGNET_SCRIPT_ROOT/geno_prep_portal_gtex.sh ${options}
exit 1
fi

echo -e "Preprocessing data for TCGA cohort\n"

usage() {
    echo "Usage:"
    echo "signet -g [OPTION VAL] ..."
    echo -e "\n"
    echo "Description:"
    echo "  --p | --ped                   set ped file"
    echo "  --m | --map                   set map file"
    echo "  --mind                        set the missing per individual cutoff"
    echo "  --geno                        set the missing per markder cutoff"
    echo "  --hwe                         set Hardy-Weinberg equilibrium cutoff"
    echo "  --nchr                        set the chromosome number"
    echo "  --r | --ref                   set the reference file for imputation"
    echo "  --gmap                        set the genomic map file"
    echo "  --i | --int                   set the interval length for impute2"
    echo "  --ncores                      set the number of cores"
    echo "  --tmpg                        set the temporary file directory"
    echo "  --resg                        set the result file directory"
    exit -1
}


pedfile=$($SIGNET_ROOT/signet -s --ped.file)
mapfile=$($SIGNET_ROOT/signet -s --map.file)
mind=$($SIGNET_ROOT/signet -s --mind)
geno=$($SIGNET_ROOT/signet -s --geno)
hwe=$($SIGNET_ROOT/signet -s --hwe)
nchr=$($SIGNET_ROOT/signet -s --nchr)
ref=$($SIGNET_ROOT/signet -s --ref)
gmap=$($SIGNET_ROOT/signet -s --gmap)
int=$($SIGNET_ROOT/signet -s --int)
ncore=$($SIGNET_ROOT/signet -s --ncore_local)
cwd=$(pwd)
tmpg=$($SIGNET_ROOT/signet -s --tmpg.tcga)
resg=$($SIGNET_ROOT/signet -s --resg.tcga)

ARGS=`getopt -a -o a:r -l p:,ped:,m:,map:,mind:,geno:,r:,ref:,hwe:,nchr:,gmap:,i:,int:,ncore:,h:,tmpg:,resg:,help -- "$@"`

eval set -- "${ARGS}"

while [ $# -gt 0 ]
do
case "$1" in
	--p|--ped)
		pedfile=$2
		pedfile=$(readlink -f $pedfile)
		$SIGNET_ROOT/signet -s --ped.file $pedfile
		shift;;
        --m|--map) 
		mapfile=$2
		mapfile=$(readlink -f $mapfile)
		$SIGNET_ROOT/signet -s --map.file $mapfile
		shift;;
        --mind)
		mind=$2
                $SIGNET_ROOT/signet -s --mind $mind
		shift;;
        --geno)
		geno=$2
                $SIGNET_ROOT/signet -s --geno $geno
		shift;;
        --hwe)
                hwe=$2
                $SIGNET_ROOT/signet -s --hwe $hwe
                shift;;
	--nchr)
		nchr=$2
		$SIGNET_ROOT/signet -s --nchr $nchr
                shift;;
        --r|--ref)
                ref=$2
		ref=$(readlink -f $ref)
                $SIGNET_ROOT/signet -s --ref $ref
                shift;;
	--gmap)
		gmap=$2 
		gmap=$(readlink -f $gmap)
		$SIGNET_ROOT/signet -s --gmap $gmap
		shift;;
        --int)
                int=$2
                $SIGNET_ROOT/signet -s --int $int
                shift;;
	--ncore) 
		ncore=$2
		$SINGNET_ROOT/signet -s --ncore $ncore
		shift;;
        --tmpg)
                tmpg=$2
                $SIGNET_ROOT/signet -s --tmpg.tcga $tmpg
                shift;;
        --resg)
                resg=$2
                $SIGNET_ROOT/signet -s --resg.tcga $resg
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

file_compare $tmpg $resg

## Do a file check
file_check $tmpg
file_check $resg

echo "ped.file: "$pedfile
echo "map.file: "$mapfile
echo -e "\n"

mkdir -p $SIGNET_TMP_ROOT/tmpg
#rm -rf $SIGNET_TMP_ROOT/tmpg/impute
mkdir $SIGNET_TMP_ROOT/tmpg/impute
mkdir -p $SIGNET_RESULT_ROOT/resg
mkdir -p $SIGNET_DATA_ROOT/geno-prep

$SIGNET_SCRIPT_ROOT/geno_prep/geno_prep.sh $pedfile $mapfile $mind $geno $hwe $nchr $ref $gmap $ncore $int  && echo "Genotype Preprocessing Finished"

cd $SIGNET_TMP_ROOT/tmpg
file_prefix signet
cd $cwd
file_trans $SIGNET_TMP_ROOT/tmpg/signet $tmpg

cd $SIGNET_RESULT_ROOT/resg
file_prefix signet
cd $cwd
file_trans $SIGNET_RESULT_ROOT/resg/signet $resg
