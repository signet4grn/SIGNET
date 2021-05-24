#!/bin/bash

usage() {
    echo "Usage:"
    echo "signet -g [OPTION VAL] ..."
    echo -e "\n"
    echo "Description:"
    echo "  --p | --ped,                  set ped file"
    echo "  --m | --map,                  set map file"
    echo "  --mind                        set the missing per individual cutoff"
    echo "  --geno                        set the missing per markder cutoff"
    echo "  --hwe                         set Hardy-Weinberg equilibrium cutoff"
    echo "  --nchr                        set the chromosome number"
    echo "  --r | --ref,                  set the reference file for imputation"
    exit -1
}


pedfile=$($SIGNET_ROOT/signet -s --ped.file)
mapfile=$($SIGNET_ROOT/signet -s --map.file)
mind=$($SIGNET_ROOT/signet -s --mind)
geno=$($SIGNET_ROOT/signet -s --geno)
hwe=$($SIGNET_ROOT/signet -s --hwe)
nchr=$($SIGNET_ROOT/signet -s --nchr)
ref=$($SIGNET_ROOT/signet -s --ref)

ARGS=`getopt -a -o a:r -l p:,ped:,m:,map:,mind:,geno:,r:,ref:,hwe:,nchr:,h:,help -- "$@"`

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

$SIGNET_SCRIPT_ROOT/geno-prep/geno-prep.sh $pedfile $mapfile $mind $geno $hwe $nchr $ref  && echo "Genotype Preprocessing Finished"
