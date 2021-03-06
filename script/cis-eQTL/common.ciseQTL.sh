#!/bin/bash
cd $SIGNET_TMP_ROOT/tmpc

echo -e "Mapping cis-eQTL with common variants [alpha:"$alpha"]...\n"

Rscript $SIGNET_SCRIPT_ROOT/cis-eQTL/common.ciseQTL.r  

echo -e "\nSummarizing the result for common variants...\n"

##select significant ones 
Rscript $SIGNET_SCRIPT_ROOT/cis-eQTL/sig.commoncis.r "alpha='$alpha'"

### Obtain genotype for eQTL data
Rscript $SIGNET_SCRIPT_ROOT/cis-eQTL/common.eQTLdata.r "alpha='$alpha'"

wait

nsig=$(awk '{print $2}' ${resc}_common.sig.pValue_${alpha} | sort | uniq | wc -l)
ngene=$(awk '{print $1}' ${resc}_common.sig.pValue_${alpha} | sort | uniq | wc -l)
echo -e "----" $nsig "significant common variants found for "$ngene" genes!\n" 
