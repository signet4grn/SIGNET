#!/bin/bash

usage() {
    echo "Usage:"
    echo "  signet -t [--g GEXP_FILE] [--p MAP_FILE]" 
    echo -e "\n"
    echo "Description:"
    echo " --g | --gexp                   set gene expression file"
    echo " --p | --pmap                   set the genecode gtf file "
    exit -1
}


gexpfile=$($SIGNET_ROOT/signet -s --gexp.file)
pmapfile=$($SIGNET_ROOT/signet -s --pmap.file)

ARGS=`getopt -a -o a:r -l g:,gexp:,p:,pmap:,h:,help -- "$@"`

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
        -h|--help)
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

touch $SIGNET_TMP_ROOT/tmpt
touch $SIGNET_RESULT_ROOT/rest
touch $SIGNET_DATA_ROOT/gexp-prep

$SIGNET_SCRIPT_ROOT/gexp_prep/gexp_prep.sh $gexpfile $pmapfile && echo -e "Gene Expression Preprocessing Finished\nPlease look at PCA"
