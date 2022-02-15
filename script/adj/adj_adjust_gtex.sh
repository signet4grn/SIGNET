#!/bin/bash
##combine them 
# prepare empty PEER covariates
cd $SIGNET_TMP_ROOT/tmpa

head -n1 pc.txt > empty.txt

# combine covariates with empty PEER covariates(PEER covariates not included!)
$SIGNET_SCRIPT_ROOT/adj/combine_covariates.py --genotype_pcs="pc.txt" \
--add_covariates="explicit_cov.txt" \
empty.txt \
all_covs_withoutigt_${tissue}_no_peer &&

$SIGNET_SCRIPT_ROOT/adj/combine_covariates.py --genotype_pcs="empty.txt" \
--add_covariates="explicit_cov.txt" \
empty.txt \
all_covs_withoutigtpc_${tissue}_no_peer &&

echo -e 'Begin Preprocessing ...\n'
cd $SIGNET_ROOT
## adjust expression by the covariates: top  pcs, without PEER factors, Sex, Platform, Protocol
$SIGNET_SCRIPT_ROOT/adj/gexp_cov_adjust.py --expr ${rest}_expression_normalized_igt2log_GTEx_${tissue}.expression.bed.gz \
--covf $SIGNET_TMP_ROOT/tmpa/all_covs_withoutigt_${tissue}_no_peer.combined_covariates.txt \
--prefix ${resa}_rmpc > log_lung_withoutigt_no_peer

$SIGNET_SCRIPT_ROOT/adj/gexp_cov_adjust.py --expr ${rest}_expression_normalized_igt2log_GTEx_${tissue}.expression.bed.gz \
--covf $SIGNET_TMP_ROOT/tmpa/all_covs_withoutigtpc_${tissue}_no_peer.combined_covariates.txt \
--prefix ${resa} > log_lung_withoutigt_no_peer

