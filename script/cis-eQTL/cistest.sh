
gene_pos_file="./data/cis-eQTL/prostate_gene_pos"
gexp_file="./data/cis-eQTL/gexp_prostate"
snps_maf_file="./data/cis-eQTL/snps.maf"
snps_map_file="./data/cis-eQTL/snps.map"

echo $gene_pos_file

## Sort gene by position
Rscript sort.gene.r $gene_pos_file $gexp_file

## Seperate files for gene name and gene position
cd ../../data/cis-eQTL
cut -d',' -f1 final.genePOS > final.genename   ##80
cut -d',' -f2- final.genePOS > final.genepos   ##80 * 3
perl -pe 's/,/\t/g' < final.genepos > temp 
mv temp final.genepos

# Split SNPs by MAF
cd  ../../script/cis-eQTL
echo "Spliting SNPS by MAF......"
Rscript split.snp.r $snps_map_file $snps_maf_file
