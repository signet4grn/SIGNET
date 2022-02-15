#!/bin/bash
$SIGNET_SCRIPT_ROOT/adj/ld.sh &&

$SIGNET_SCRIPT_ROOT/adj/adj_pca_gtex.sh &&

echo -e "\n"
echo -e "Please check the pca plots \n"
##pc=3 by default
pc=3
read -p "Enter the number of PC's you want to use: " pc
echo "The number of pc used will be $pc"
echo -e "\n"

cd $SIGNET_ROOT
# Prepare and adjust for covariates
Rscript $SIGNET_SCRIPT_ROOT/adj/pre_cov_gtex.R "npc='$pc'"
$SIGNET_SCRIPT_ROOT/adj/adj_adjust_gtex.sh 
