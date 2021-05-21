#!/bin/bash

cmdprefix="./config_controller.sh -l CISEQTL,"
snps_map=$(${cmdprefix}snps.map);
snps_maf=$(${cmdprefix}snps.maf);
gexp=$(${cmdprefix}gexp.file);
gene_pos=$(${cmdprefix}gene.pos);
matched_geno=$(${cmdprefix}matched.geno);
alpha_cis=$(${cmdprefix}alpha.cis);
uncor_ncis=$(${cmdprefix}alpha.cis)
uncor_r=$(${cmdprefix}uncor.r)
nperms=$(${cmdprefix}nperms)
upstream=$(${cmdprefix}upstream)
downstream=$(${cmdprefix}downstream)

ARGS=`getopt -a -o a:r -l alpha:,map:,maf:,gexp:,geno:,ncis:,nperms:,upstream:,downstream:,help -- "$@"`

function usage() {
	echo 'Usage:'
	echo '  cis-eqtl [OPTION VAL] ...'
	echo 'Description:'
	echo '  --alpha | -a			significant level for cis-eQTL'
	echo '  --ncis NCIS			maximum number of cis-eQTL for each gene'
	echo '  --maxcor MAX_COR		maximum corr. coeff. b/w cis-eQTL of same gene'
	echo '  --nperms N_PERMS		numer of permutations'
	echo '  --upstream UP_STREAM		upstream region to flank the genetic region '
	echo '  --downstram DOWN_STREAM	downstream region to flank the genetic region'
	echo '  --map MAP_FILE		snps map file path'
	echo '  --maf MAF_FILE		snps maf file path'
	echo '  --gexp GEXP_FILE		gene expression file path'
	echo '  --geno GENO_FILE		genotype file path'
	echo '  --help | -h			user guide'
}
[ $? -ne 0 ] && usage

eval set -- "${ARGS}"

while true
do
case "$1" in
	-a|--alpha)
		alpha_cis=$2
		shift
              ;;
	--map)
		snps_map=$2
		shift;;
	--maf)
		snps_maf=$2
		shift;;
	--gexp)
		gexp=$2
		shift;;
	--geno)
		geno=$2
		shift;;
	--nperms)
		nperms=$2
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


cd ./cis-eQTL
./ciseQTL.sh $gene_pos $gexp $snps_maf $snps_map $alpha_cis $upstream $downstream $nperms
