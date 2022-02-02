## This sciprt will apply plink commands to the files

cd $SIGNET_TMP_ROOT/tmpg

echo -e "Extracting genotype data\n"

bcftools query -l $vcf0 > GTEx.vcf_subject.txt

head -90 $vcf0 |tail -1| cut -c14- > GTEx.vcf_sample0.txt

Rscript $SIGNET_SCRIPT_ROOT/geno_prep/gen_sample.R & 

### Truncate to the germline data that have lung tissue gene expression data 
Rscript $SIGNET_SCRIPT_ROOT/geno_prep/extract.R "anno='$anno'" "read='$gexpread'" "tissue='$tissue'"

bcftools view -S'subjid_wb_common.txt' -o'GTEx_wb.vcf' $vcf

##Restrict to biallelic sites
bcftools view -Oz -m2 -M2 -v snps -o'GTEx_snp.vcf.gz' GTEx_wb.vcf

tabix -p vcf GTEx_snp.vcf.gz

bcftools stats GTEx_snp.vcf.gz > GTEx_snps.vcf.stats

gunzip GTEx_snp.vcf.gz

echo -e "Genotype extacted\n"
