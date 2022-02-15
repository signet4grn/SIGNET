cd $SIGNET_TMP_ROOT/tmpa

echo -e 'LD pruning ... \n'

enable -n eval

plink --vcf $SIGNET_TMP_ROOT/tmpg/GTEx_snp.vcf --double-id --make-bed --missing --freq --recode --out Geno_all

plink --bfile Geno_all --indep-pairwise 200 100 0.1 --maf 0.05 --recode --make-bed --out Geno_all_0.05

plink --bfile Geno_all_0.05 --exclude Geno_all_0.05.prune.out --recode --make-bed --out Geno_all_prune

scp Geno_all_prune.map Geno_all_prune.pedsnp
scp Geno_all_prune.fam Geno_all_prune.pedind
