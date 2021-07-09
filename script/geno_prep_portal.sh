#!/bin/bash

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
    echo "  --ncore                       set the number of cores"
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
ncore=$($SIGNET_ROOT/signet -s --ncore_local)

ARGS=`getopt -a -o a:r -l p:,ped:,m:,map:,mind:,geno:,r:,ref:,hwe:,nchr:,gmap:,ncore:,h:,help -- "$@"`

eval set -- "${ARGS}"

while [ $# -gt 0 ]
do
case "$1" in
	--p|--ped)
		pedfile=$2
		$SIGNET_ROOT/signet -s --ped.file $pedfile
		shift;;
        --m|--map) 
		mapfile=$2
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
                $SIGNET_ROOT/signet -s --ref $ref
                shift;;
	--gmap)
		gmap=$2 
                $SIGNET_ROOT/signet -s --gmap $gmap
		shift;;
	--ncore) 
		ncore=$2
		$SINGNET_ROOT/signet -s --ncore $ncore
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


echo "ped.file: "$pedfile
echo "map.file: "$mapfile
echo -e "\n"

mkdir -p $SIGNET_TMP_ROOT/tmpg
mkdir -p $SIGNET_RESULT_ROOT/resg
mkdir -p $SIGNET_DATA_ROOT/geno-prep

$SIGNET_SCRIPT_ROOT/geno_prep/geno_prep.sh $pedfile $mapfile $mind $geno $hwe $nchr $ref $gmap $ncore  && echo "Genotype Preprocessing Finished"
