gexpfile=$1
pmapfile=$2

Rscript $SIGNET_SCRIPT_ROOT/gexp-prep/gexp_prep.R "file='$gexpfile'" && 
Rscript $SIGNET_SCRIPT_ROOT/gexp-prep/gpos.R "file='$pmapfile'"
