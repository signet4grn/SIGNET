gexpfile=$1
pmapfile=$2

Rscript $SIGNET_SCRIPT_ROOT/gexp_prep/gexp_prep.R "file='$gexpfile'" &&
Rscript $SIGNET_SCRIPT_ROOT/gexp_prep/gpos.R "file='$pmapfile'" 
