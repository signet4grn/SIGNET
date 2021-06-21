$SIGNET_SCRIPT_ROOT/geno_prep/plink.sh  $1 $2 $3 $4 $5 && 
$SIGNET_SCRIPT_ROOT/geno_prep/imputation.sh $6 $7 $8 $9 &&
$SIGNET_SCRIPT_ROOT/geno_prep/combine_geno.sh $6
