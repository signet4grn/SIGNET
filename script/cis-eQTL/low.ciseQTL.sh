#!/bin/bash

alpha=${1}
nperms=${2}

echo "Cis-eQTL Analyis for low variants [alpha:"$alpha",nperms:"$nperms"]......"

nohup Rscript low.ciseQTL.r $nperms&

cd ../../data/cis-eQTL
## Combine data  
rm low.ciseQTL.weight0
rm low.ciseQTL.weight
rm low.theoP
cat $(find ./ -name 'low.ciseQTL.weight*' | sort -V) > low.ciseQTL.weight0
paste low.cispair.idx low.ciseQTL.weight0 > low.ciseQTL.weight
#Col 1: index of gene, Col 2: index of SNP, Col 3: index of collapsed SNPs for a gene, Col 4: weight of collapsed SNPs for a gene
cat $(find ./ -name 'low.theoP*' | sort -V) > low.theoP

cd ../../script/cis-eQTL
##Select significant ones 
wait
Rscript ./sig.lowcis.r $alpha &&
wait
Rscript ./low.eQTLdata.r  $alpha &

wait
cd ../../data/cis-eQTL
nsig=$(awk 'END{print NR}' low.sig.pValue_${alpha})
ngene=$(awk '{print $1}' low.sig.pValue_${alpha} | sort | uniq | wc -l)
echo "----" $nsig "significant low variants found for "$ngene" genes" 
cd ../../script/cis-eQTL
