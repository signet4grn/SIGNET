#!/bin/bash

gene_pos_file=$1
gexp_file=$2
snps_maf_file=$3
snps_map_file=$4
alpha=$5
upstream=$6
downstream=$7
nperms=$8

## Sort gene by position
echo "Sorting gene by position......"
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


##Convert snps.idx to awk format: {print $1,$2,...$n} 


cd ../../data/cis-eQTL

sed -i '$ s/.$//' rare.snps.idx
perl -pe 'BEGIN {print "{print ";} s/,/,\n/g; END {print "}\n"}' < rare.snps.idx > temp 
mv temp rare.snps.idx

sed -i '$ s/.$//' low.snps.idx
perl -pe 'BEGIN {print "{print ";} s/,/,\n/g; END {print "}\n"}' < low.snps.idx > temp 
mv temp low.snps.idx

sed -i '$ s/.$//' common.snps.idx
perl -pe 'BEGIN {print "{print ";} s/,/,\n/g; END {print "}\n"}' < common.snps.idx > temp
 

mv temp common.snps.idx

nohup awk -f rare.snps.idx < ../match/new.Geno > rare.snpsdata0 & ## 3
nohup awk -f low.snps.idx < ../match/new.Geno > low.snpsdata0 & ## 15712
nohup awk -f common.snps.idx < ../match/new.Geno > common.snpsdata0 & ##256849

# Creating cis pairs

echo "Creating cis pairs [upstream:"$upstream", downstream:"$downstream"]......"

### SNP position (chr#, SNP pos)
awk '{print $1,$4}' ../match/new.Geno.map > all.SNPpos
awk '{print $1,$4}' rare.snps.map > rare.SNPpos
awk '{print $1,$4}' low.snps.map > low.SNPpos
awk '{print $1,$4}' common.snps.map > common.SNPpos

cd ../../script/cis-eQTL

perl -pe 's/rare/common/g' < rare.cispair.r > common.cispair.r
perl -pe 's/rare/low/g' < rare.cispair.r > low.cispair.r
perl -pe 's/rare/all/g' < rare.cispair.r > all.cispair.r

Rscript rare.cispair.r $upstream $downstream 
Rscript common.cispair.r $upstream $downstream 
Rscript low.cispair.r $upstream $downstream 
Rscript all.cispair.r $upstream $downstream 


# Cis-eQTL Analysis


## for common variants
wait
./common.ciseQTL.sh $alpha
./low.ciseQTL.sh $alpha $nperms
./all.ciseQTL.sh $alpha
wait
echo 'Finished!'

