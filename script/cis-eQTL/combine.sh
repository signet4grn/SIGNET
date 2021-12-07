
##This script will combine all the data together
paste -d' ' ${resc}_common.eQTL.data ${resc}_low.eQTL.data ${resc}_rare.eQTL.data > ${resc}_all.eQTL.data

Rscript $SIGNET_SCRIPT_ROOT/cis-eQTL/combine.sigcis.r "alpha='$alpha'"


