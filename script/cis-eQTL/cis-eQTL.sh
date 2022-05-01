#!/bin/bash
echo -e "Splitting the SNPs by maf\n"

$SIGNET_SCRIPT_ROOT/cis-eQTL/snpsplit.sh &&

$SIGNET_SCRIPT_ROOT/cis-eQTL/cis-SNPs.sh && 

# Cis-eQTL Analysis
wait
$SIGNET_SCRIPT_ROOT/cis-eQTL/common.ciseQTL.sh && 
$SIGNET_SCRIPT_ROOT/cis-eQTL/low.ciseQTL.sh &&
$SIGNET_SCRIPT_ROOT/cis-eQTL/rare.ciseQTL.sh &&
wait

#Combine the results
echo -e "Begin to summarize the results\n"
$SIGNET_SCRIPT_ROOT/cis-eQTL/combine.sh &&

#
#echo -e "\nBegin to find the uncorrelated SNPs and fit a ridge regression to genes that has more than one cis-eQTL region\n"

echo -e "\nCis-eQTL analysis completed!\n"
echo -e "Please copy the following files into research cluster for computing:\n"

echo -e "1. ${resc}_all.sig.pValue_$alpha\n"
echo -e "2. ${resc}_net.gexp.data\n"
echo -e "3. ${resc}_all.eQTL.data\n"
echo -e "4. ${resc}_net.genepos\n"
echo -e "5. ${resc}_net.genename\n"
