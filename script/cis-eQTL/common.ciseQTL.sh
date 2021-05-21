#!/bin/bash


alpha=${1}
echo "Cis-eQTL Analyis for common variants [alpha:"$alpha"]......"

#Rscript ./common.ciseQTL.r 

##select significant ones 
Rscript ./sig.commoncis.r $alpha

### Obtain genotype for eQTL data
Rscript ./common.eQTLdata.r $alpha

wait


cd ../../data/cis-eQTL
nsig=$(awk 'END{print NR}' common.sig.pValue_${alpha})
ngene=$(awk '{print $1}' common.sig.pValue_${alpha} | sort | uniq | wc -l)
echo "----" $nsig "significant common variants found for "$ngene" genes" 
cd ../../script/cis-eQTL

