#!/bin/bash

cmdprefix="$SIGNET_ROOT/signet -s --"
snps_map=$(${cmdprefix}snps.map | sed -r '/^\s*$/d'| xargs readlink -f)
snps_maf=$(${cmdprefix}snps.maf | sed -r '/^\s*$/d'| xargs readlink -f)
gexp=$(${cmdprefix}matched.gexp | sed -r '/^\s*$/d'| xargs readlink -f)
gexp_withpc=$(${cmdprefix}matched.gexp.withpc | sed -r '/^\s*$/d'| xargs readlink -f)
geno=$(${cmdprefix}matched.geno | sed -r '/^\s*$/d'| xargs readlink -f)
gene_pos=$(${cmdprefix}gene.pos | sed -r '/^\s*$/d'| xargs readlink -f)
alpha=$(${cmdprefix}alpha.cis | sed -r '/^\s*$/d')
nperms=$(${cmdprefix}nperms | sed -r '/^\s*$/d')
upstream=$(${cmdprefix}upstream | sed -r '/^\s*$/d')
downstream=$(${cmdprefix}downstream | sed -r '/^\s*$/d') 
resc=$(${cmdprefix}resc | sed -r '/^\s*$/d')
forcerm=$($SIGNET_ROOT/signet -s --forcerm | sed -r '/^\s*$/d')

function usage() {
	echo 'Usage:'
	echo 'signet -c [OPTION VAL] ...'
	echo -e '\n'
	echo 'Description:'
	echo '  --gexp                        gene expression file after matching with genotype data'
        echo "  --gexp.withpc                 gene expression file without adjusting for principal components, after matching with genotype data"
	echo '  --geno                        genotype file after matching with gene expression data'
    	echo '  --map                         snps map file path'
        echo '  --maf                         snps maf file path'
        echo '  --gene_pos                    gene position file'
	echo '  --alpha | -a			significance level for cis-eQTL'
	echo '  --nperms                 	number of permutations'
	echo '  --upstream               	upstream region to flank the genetic region '
	echo '  --downstram                   downstream region to flank the genetic region'
        echo '  --resc                        result prefix'
	echo '  --help | -h			user guide'
}

[ $? -ne 0 ] && usage

ARGS=`getopt -a -o a:r -l a:,alpha:,map:,maf:,gexp:,gexp.withpc:,geno:,gene_pos:,nperms:,upstream:,downstream:,resc:,help -- "$@"`

eval set -- "${ARGS}"

while true
do
case "$1" in
        --gexp)
                gexp=$2
                gexp=$(readlink -f $gexp)
                ${cmdprefix}matched.gexp $gexp
                shift;;
	--gexp.withpc)
                gexp_withpc=$2
                gexp_withpc=$(readlink -f $gexp_withpc)
                ${cmdprefix}matched.gexp.withpc $gexp_withpc
                shift;;
        --geno)
                geno=$2
                geno=$(readlink -f $geno)
                ${cmdprefix}matched.geno $geno
                shift;;
	--map)
		snps_map=$2
		snps_map=$(readlink -f $snps_map)
		${cmdprefix}snps.map $snps_map
		shift;;
	--maf)
		snps_maf=$2
		snps_maf=$(readlink -f $snps_maf)
		${cmdprefix}snps.maf $snps_maf
		shift;;
	--gene_pos)
                gene_pos=$2
                gene_pos=$(readlink -f $gene_pos)
                ${cmdprefix}gene.pos $gen_pos
                shift;;
	-a|--alpha)
                alpha=$2
                ${cmdprefix}alpha.cis $alpha
                shift;;
        --upstream)
                upstream=$2
		${cmdprefix}upstream $upstream
                shift;;
        --downstream)
	        downstream=$2
		${cmdprefix}downstream $downstream
                shift;;

	--nperms)
		nperms=$2
		${cmdprefix}nperms $nperms
		shift;;
        --resc)
                resc=$2
                $SIGNET_ROOT/signet -s --resc $resc
                shift;;
	-h|--help)
		usage
		exit
              ;;
      --)
              shift
              break
              ;;
      esac
shift
done 

file_purge $SIGNET_TMP_ROOT/tmpc $forcerm
mkdir -p $SIGNET_RESULT_ROOT/resc
mkdir -p $SIGNET_DATA_ROOT/cis-eQTL
resc=$(dir_check $resc)

if [[ "$resc" == *"doesn't exist"* ]]; then
exit -1
fi

var="gexp gexp_withpc geno snps_maf snps_map gene_pos alpha upstream downstream nperms resc"
for i in $var
do
export "${i}"
done

# check file existence
input_file="gexp gexp_withpc geno snps_maf snps_map gene_pos"
for i in $input_file
do
file_check $(eval "$(echo "echo \$${i}")")
done

$SIGNET_SCRIPT_ROOT/cis-eQTL/cis-eQTL.sh

echo -e "Finish time: $(date)"
