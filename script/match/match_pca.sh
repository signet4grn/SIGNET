cd $SIGNET_TMP_ROOT/tmpm

Rscript $SIGNET_SCRIPT_ROOT/match/pca_prepare.R &&
smartpca.perl -i new.Geno.eigenstratgeno -a new.Geno.snp -b new.Geno.ind -k 15 -o Geno.pca -e Geno.{$eval} -l Geno.log -q NO -m 1 -p Geno.plot > /dev/null &&
Rscript $SIGNET_SCRIPT_ROOT/match/pca_vis.R
