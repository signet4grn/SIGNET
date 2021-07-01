alpha=$1

##This script will combine all the data together
cd $SIGNET_RESULT_ROOT/resc

paste -d' ' common.eQTL.data low.eQTL.data rare.eQTL.data > all.eQTL.data

Rscript $SIGNET_SCRIPT_ROOT/cis-eQTL/combine.sigcis.r "alpha='$alpha'"


