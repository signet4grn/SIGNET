Rscript $SIGNET_SCRIPT_ROOT/adj/adj_gexp.R &&
echo -e "Gene Expression data matched\n" &&
perl $SIGNET_SCRIPT_ROOT/adj/extractgeno.pl $SIGNET_TMP_ROOT/tmpg/geno_idx ${resg}_Geno > $SIGNET_TMP_ROOT/tmpg/matched.Geno.data &&
$SIGNET_SCRIPT_ROOT/adj/adj_filter.sh &&
$SIGNET_SCRIPT_ROOT/adj/adj_pca.sh &&

echo -e "\n"
echo -e "You may want to check the PCA plots to determine the number of PCs for population stratification\n"
##pc=3 by default
pc=3
read -p "Enter the number of PCs for population structures: " pc
echo "The number of PCs to be used is $pc"
echo -e "\n"

Rscript $SIGNET_SCRIPT_ROOT/adj/adj_adjust.R "clifile='$clifile'" "npc='$pc'" 
