
echo -e  "Generating cis pairs with upstream $upstream and downstream $downstream \n" 

cd $SIGNET_TMP_ROOT/tmpc

cut -d " " -f2- $gene_pos > genepos
sed -i 's/chr//' genepos

awk -f rare.snps.idx < $geno 1> rare.Geno.data 2>err_rare &
awk -f low.snps.idx < $geno 1>low.Geno.data 2>err_low &
awk -f common.snps.idx < $geno 1>common.Geno.data 2>err_common &

### SNP position (chr#, SNP pos)
awk '{print $1,$4}' $snps_map > all.SNPpos
awk '{print $1,$4}' rare.Geno.map > rare.SNPpos 
awk '{print $1,$4}' low.Geno.map > low.SNPpos 
awk '{print $1,$4}' common.Geno.map > common.SNPpos 

Rscript $SIGNET_SCRIPT_ROOT/cis-eQTL/rare.cispair.r "upstream='$upstream'" "downstream='$downstream'" &
Rscript $SIGNET_SCRIPT_ROOT/cis-eQTL/common.cispair.r "upstream='$upstream'" "downstream='$downstream'" &
Rscript $SIGNET_SCRIPT_ROOT/cis-eQTL/low.cispair.r "upstream='$upstream'" "downstream='$downstream'" &
wait
