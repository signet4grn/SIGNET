cd $SIGNET_TMP_ROOT/tmpa

echo -e "Constructing PCs...\n" 

Rscript $SIGNET_SCRIPT_ROOT/adj/pca_prepare.R &&
enable -n eval
smartpca.perl -i new.Geno.eigenstratgeno -a new.Geno.snp -b new.Geno.ind -k 15 -o Geno.pca -e Geno.eval -l Geno.log -q NO -m 1 -p Geno.plot > /dev/null &&
Rscript $SIGNET_SCRIPT_ROOT/adj/pca_vis.R
