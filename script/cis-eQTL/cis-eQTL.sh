#!/bin/bash
gene_pos_file=$1
gexp_file=$2
snps_maf_file=$3
snps_map_file=$4
alpha=$5
upstream=$6
downstream=$7
nperms=$8

##Find cis-SNPs
$SIGNET_SCRIPT_ROOT/cis-eQTL/cis-SNPs.sh $upstream $downstream 

# Cis-eQTL Analysis
wait
$SIGNET_SCRIPT_ROOT/cis-eQTL/common.ciseQTL.sh $alpha
$SIGNET_SCRIPT_ROOT/cis-eQTL/low.ciseQTL.sh $alpha $nperms
$SIGNET_SCRIPT_ROOT/cis-eQTL/rare.ciseQTL.sh $alpha $nperms
wait

#Combine the results
echo -e "Begin to summarize the results\n"
$SIGNET_SCRIPT_ROOT/cis-eQTL/combine.sh $alpha

#
#echo -e "\nBegin to find the uncorrelated SNPs and fit a ridge regression to genes that has more than one cis-eQTL region\n"

echo -e "\nCis-eQTL analysis completed!\n"
echo -e "Please copy the following files into research cluster for computing:\n"

echo -e "1. all.sig.pValue_$alpha\n"
echo -e "2. net.Gexp.data\n"
echo -e "3. all.eQTL.data\n"
echo -e "4. net.genepos\n"
echo -e "5. net.genename\n"