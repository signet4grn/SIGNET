#!/bin/bash
freq=$1
ntop=$2

scp $SIGNET_TMP_ROOT/tmpn/net.gene* $SIGNET_TMP_ROOT/tmpv

cd $SIGNET_RESULT_ROOT/resn

echo -e "Extracting edges...\n"
Rscript $SIGNET_SCRIPT_ROOT/netvis/extract.edges.R "freq='$freq'"
Rscript $SIGNET_SCRIPT_ROOT/netvis/get_net.R "freq='$freq'" "ntop='$ntop'"
echo -e "Genes for top "$ntop" networks has been returned to the folder"
echo -e "You can check the visualizing result end with .html in the resv for validation\n"
