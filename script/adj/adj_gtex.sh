
##combine them 
../codes/combine_covariates.py --genotype_pcs="pc_lung.txt" \
--add_covariates="explicit_cov_lung.txt"  \
expression_normalized_withoutigt_GTEx_lung.PEER_covariates.txt \
all_covs_withoutigt_lung_with_peer

# prepare empty PEER covariates
head -n1 expression_normalized_withoutigt_GTEx_lung.PEER_covariates.txt > \
expression_normalized_withoutigt_lung.PEER_covariates_empty.txt

# combine covariates with empty PEER covariates(PEER covariates no included!)
../codes/combine_covariates.py --genotype_pcs="pc_lung.txt" \
--add_covariates="explicit_cov_lung.txt" \
expression_normalized_withoutigt_lung.PEER_covariates_empty.txt \
all_covs_withoutigt_lung_no_peer
  
## adjust expression by the covariates: top 2 pcs, without PEER factors, Sex, Platform, Protocol
nohup ../codes/gexp_cov_adjust.py --expr expression_normalized_withoutigt_GTEx_lung.expression.bed.gz \
--covf all_covs_withoutigt_lung_no_peer.combined_covariates.txt \
--prefix expression_normalized_withoutigt_lung_adjusted_no_peer > log_lung_withoutigt_no_peer &
