trap "exit -1" 10
export job_id="$$"
$SIGNET_SCRIPT_ROOT/geno_prep/plink.sh  && 
$SIGNET_SCRIPT_ROOT/geno_prep/imputation.sh  
$SIGNET_SCRIPT_ROOT/geno_prep/combine_geno.sh 
