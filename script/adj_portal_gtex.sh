#!/bin/bash
usage() {
    echo "Usage:"
    echo "  signet -a --pheno" 
    echo -e "\n"
    echo "Description:"
    echo " --pheno                          GTEx phenotype file"
    echo " --resa                           result prefix"  
    exit -1
}

pheno=$($SIGNET_ROOT/signet -s --pheno | sed -r '/^\s*$/d')
tissue=$($SIGNET_ROOT/signet -s --tissue | sed -r '/^\s*$/d')
anno=$($SIGNET_ROOT/signet -s --anno | sed -r '/^\s*$/d')
resa=$($SIGNET_ROOT/signet -s --resa.gtex | sed -r '/^\s*$/d')
resg=$($SIGNET_ROOT/signet -s --resg.gtex | sed -r '/^\s*$/d')
rest=$($SIGNET_ROOT/signet -s --rest.gtex | sed -r '/^\s*$/d')

ARGS=`getopt -a -o a:r -l h:,pheno:,resa:,help -- "$@"`

eval set -- "${ARGS}"

while [ $# -gt 0 ]
do
case "$1" in
	--pheno)
                pheno=$2
		$SIGNET_ROOT/signet -s --pheno $pheno
		shift;;
        --resa)
                resa=$2
                $SIGNET_ROOT/signet -s --resa.gtex $resa
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

file_purge $SIGNET_TMP_ROOT/tmpa
resa=$(dir_check $resa)
mkdir -p $SIGNET_RESULT_ROOT/resa
mkdir -p $SIGNET_DATA_ROOT/adj

var="pheno tissue anno rest resa"
for i in $var
do
export "${i}"
done

$SIGNET_SCRIPT_ROOT/adj/adj_gtex.sh && echo -e "Gene Expression and Genotype matching Finished\n" 

echo -e "Finish time: $(date)"
