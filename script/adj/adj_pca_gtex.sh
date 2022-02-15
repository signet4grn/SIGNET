# This script construct pc and provide plot 
cd $SIGNET_TMP_ROOT/tmpa

echo -e "Constructing PCs ...\n" 

enable -n eval

smartpca.perl -i Geno_all_prune.ped -a Geno_all_prune.pedsnp -b Geno_all_prune.pedind -k 10 -o Geno.pca -e Geno.eval -l Geno.log -q NO -m 0 -p Geno.plot > /dev/null &&

Rscript $SIGNET_SCRIPT_ROOT/adj/pca_vis.R
