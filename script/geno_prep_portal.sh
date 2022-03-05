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
    echo "  --p | --ped                   ped file"
    echo "  --m | --map                   map file"
    echo "  --mind                        missing rate per individual cutoff"
    echo "  --geno                        missing rate per markder cutoff"
    echo "  --hwe                         Hardy-Weinberg equilibrium cutoff"
    echo "  --nchr                        chromosome number"
    echo "  --r | --ref                   reference file for imputation"
    echo "  --gmap                        genomic map file"
    echo "  --i | --int                   interval length for impute2"
    echo "  --ncores                      number of cores"
    echo "  --resg                        result prefix"
    exit -1
}


pedfile=$($SIGNET_ROOT/signet -s --ped.file | sed -r '/^\s*$/d'|xargs readlink -f)
mapfile=$($SIGNET_ROOT/signet -s --map.file | sed -r '/^\s*$/d'|xargs readlink -f)
mind=$($SIGNET_ROOT/signet -s --mind)
geno=$($SIGNET_ROOT/signet -s --geno)
hwe=$($SIGNET_ROOT/signet -s --hwe)
nchr=$($SIGNET_ROOT/signet -s --nchr)
ref=$($SIGNET_ROOT/signet -s --ref)
gmap=$($SIGNET_ROOT/signet -s --gmap)
int=$($SIGNET_ROOT/signet -s --int)
ncores=$($SIGNET_ROOT/signet -s --ncore_local)
resg=$($SIGNET_ROOT/signet -s --resg.tcga)

ARGS=`getopt -a -o a:r -l p:,ped:,m:,map:,mind:,geno:,r:,ref:,hwe:,nchr:,gmap:,i:,int:,ncores:,h:,resg:,help -- "$@"`

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
	--ncores) 
		ncores=$2
		$SINGNET_ROOT/signet -s --ncore $ncore
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

echo -e "\n"
echo "ped.file: "$pedfile
echo "map.file: "$mapfile
echo -e "\n"

file_purge $SIGNET_TMP_ROOT/tmpg
mkdir $SIGNET_TMP_ROOT/tmpg/impute
resg=$(dir_check $resg)
mkdir -p $SIGNET_RESULT_ROOT/resg
mkdir -p $SIGNET_DATA_ROOT/geno-prep

var="pedfile mapfile mind geno hwe nchr ref gmap ncores int resg"
for i in $var
do
export "${i}"
done

$SIGNET_SCRIPT_ROOT/geno_prep/geno_prep.sh && echo "Genotype Preprocessing Finished"

echo -e "Finish time: $(date)"
