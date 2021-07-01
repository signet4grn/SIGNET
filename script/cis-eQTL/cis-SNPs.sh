upstream=$1
downstream=$2

echo -e  "Generating cis pairs with upstream $upstream and downstream $downstream \n" 

cd $SIGNET_TMP_ROOT/tmpc

cut -d " " -f2- $SIGNET_RESULT_ROOT/rest/gene_pos > genepos
sed -i 's/chr//' genepos

awk -f $SIGNET_TMP_ROOT/tmpg/rare.snps.idx < $SIGNET_RESULT_ROOT/resm/geno.data 1> rare.Geno.data 2>err_rare &
awk -f $SIGNET_TMP_ROOT/tmpg/low.snps.idx < $SIGNET_RESULT_ROOT/resm/geno.data 1>low.Geno.data 2>err_low &
awk -f $SIGNET_TMP_ROOT/tmpg/common.snps.idx < $SIGNET_RESULT_ROOT/resm/geno.data 1>common.Geno.data 2>err_common &

### SNP position (chr#, SNP pos)
awk '{print $1,$4}' $SIGNET_TMP_ROOT/tmpg/new.Geno.map > all.SNPpos
awk '{print $1,$4}' $SIGNET_TMP_ROOT/tmpg/rare.Geno.map > rare.SNPpos
awk '{print $1,$4}' $SIGNET_TMP_ROOT/tmpg/low.Geno.map > low.SNPpos
awk '{print $1,$4}' $SIGNET_TMP_ROOT/tmpg/common.Geno.map > common.SNPpos

Rscript $SIGNET_SCRIPT_ROOT/cis-eQTL/rare.cispair.r "upstream='$upstream'" "downstream='$downstream'"
Rscript $SIGNET_SCRIPT_ROOT/cis-eQTL/common.cispair.r "upstream='$upstream'" "downstream='$downstream'"
Rscript $SIGNET_SCRIPT_ROOT/cis-eQTL/low.cispair.r "upstream='$upstream'" "downstream='$downstream'"
