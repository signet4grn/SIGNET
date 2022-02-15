## This sciprt will apply plink commands to the files

cd $SIGNET_TMP_ROOT/tmpg

echo -e "Preprocessing using Plink ...\n"

plink --vcf GTEx_snp.vcf --double-id --make-bed --missing --freq --recode --out Geno_GTEx_$tissue
plink --bfile Geno_GTEx_$tissue --recodeA --mac 5 --out GTEx_$tissue
plink --bfile Geno_GTEx_$tissue --recode --mac 5 --out GTEx_$tissue
plink --file GTEx_$tissue --freq --out GTEx_$tissue

scp GTEx_$tissue.map ${resg}_snps.map
awk {'print $5'} GTEx_$tissue.frq | tail -n+2 > ${resg}_snps.maf
##replace NA with 0
tail -n+2 GTEx_$tissue.raw |cut -d " " -f 7- > clean_Genotype.data
sed -e 's/NA/0/g' clean_Genotype.data > ${resg}_clean_Genotype_repNA.data

echo -e "Plink preprocessing finished\n"
