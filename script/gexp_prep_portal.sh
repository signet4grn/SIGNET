#!/bin/bash

usage() {
    echo "Usage:"
    echo "  signet -t [--g GEXP_FILE] [--p MAP_FILE]" 
    echo -e "\n"
    echo "Description:"
    echo "    --g | --gexp, set gene expression file"
    echo "    --p | --pmap, set the USSC xena probemap file "
    exit -1
}


gexpfile=$($SIGNET_ROOT/signet -s --gexp.file)
pmapfile=$($SIGNET_ROOT/signet -s --pmap.file)

ARGS=`getopt -a -o a:r -l g:,p:,h:,help -- "$@"`

eval set -- "${ARGS}"

while [ $# -gt 0 ]
do
case "$1" in
	--g|--gexp)
		gexpfile=$2
		$SIGNET_ROOT/signet -s --gexp.file $gexpfile
		shift;;
        --p|--pmap) 
		pmapfile=$2
		$SIGNET_ROOT/signet -s --pmap.file $pmapfile
		shift;;
        --h|--help)
		usage
		exit;;
	--)
	     shift
	     break;;
esac
shift
done


echo "gexp.file: "$gexpfile
echo "pamp.file: "$pmapfile
echo -e "\n"

$SIGNET_SCRIPT_ROOT/gexp-prep/gexp-prep.sh $gexpfile $pmapfile && echo "Gene Expression Preprocessing Finished"
