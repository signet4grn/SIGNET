Rscript orderge.R

cd ../../data/match
### Extract genotype data that match Gexp Sample ID 
echo 'Extract genotype data that match Gexp Sample ID ......'
cut -d' ' -f1 ../gexp-prep/Gexp > GexpID 
#awk '{print $1}' ../gexp-prep/Gexp > GexpID 
../../script/match/extractrows.pl GexpID ../geno-prep/Geno > EGeno
echo 'Extract gene expression data that match Geno Sample ID ......'
### Extract gene expression data that match Geno Sample ID 
cut -d' ' -f1 ../geno-prep/Geno > GenoID 
../../script/match/extractrows.pl GenoID ../gexp-prep/Gexp > EGexp

### Extracted Geno Sample ID 
echo 'Extracted Geno Sample ID ......'
cut -d' ' -f1 EGeno > EGenoID

### Order extracted gene expression data by extracted Geno Sample ID in R 
echo 'Order extracted gene expression data by extracted Geno Sample ID in R ...... '
cd ../../script/match
Rscript orderge.R
cd ../../data/match

echo 'Rename matched gene expression data and genotype data ......'
### Rename matched gene expression data and genotype data 
mv MGexp matched.Gexp #?: mv EGexp matched.Gexp
mv EGeno matched.Geno.data #?: mv MGeno matched.Geno
