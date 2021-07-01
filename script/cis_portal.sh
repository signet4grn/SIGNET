#!/bin/bash

cmdprefix="$SIGNET_ROOT/signet -s --"
snps_map=$(${cmdprefix}snps.map);
snps_maf=$(${cmdprefix}snps.maf);
gexp=$(${cmdprefix}gexp.file);
gene_pos=$(${cmdprefix}gene.pos);
alpha_cis=$(${cmdprefix}alpha.cis);
uncor_ncis=$(${cmdprefix}alpha.cis)
uncor_r=$(${cmdprefix}uncor.r)
nperms=$(${cmdprefix}nperms)
upstream=$(${cmdprefix}upstream)
downstream=$(${cmdprefix}downstream)

ARGS=`getopt -a -o a:r -l alpha:,map:,maf:,gexp:,geno:,ncis:,nperms:,upstream:,downstream:,help -- "$@"`

function usage() {
	echo 'Usage:'
	echo 'signet -c [OPTION VAL] ...'
	echo -e '\n'
	echo 'Description:'
	echo '  --alpha | -a			significant level for cis-eQTL'
	echo '  --nperms N_PERMS		numer of permutations'
	echo '  --upstream UP_STREAM		upstream region to flank the genetic region '
	echo '  --downstram DOWN_STREAM	downstream region to flank the genetic region'
	echo '  --map MAP_FILE		snps map file path'
	echo '  --maf MAF_FILE		snps maf file path'
	echo '  --help | -h			user guide'
}
[ $? -ne 0 ] && usage

eval set -- "${ARGS}"

while true
do
case "$1" in
	-a|--alpha)
		alpha_cis=$2
		${cmdprefix}alpha_cis $alpha_cis
		shift
              ;;
	--map)
		snps_map=$2
		${cmdprefix}snps_map $snps_map
		shift;;
	--maf)
		snps_maf=$2
		${cmdprefix}snps.maf $snps_maf
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


$SIGNET_SCRIPT_ROOT/cis-eQTL/cis-eQTL.sh $gene_pos $gexp $snps_maf $snps_map $alpha_cis $upstream $downstream $nperms
