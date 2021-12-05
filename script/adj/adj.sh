Rscript $SIGNET_SCRIPT_ROOT/adj/adj_gexp.R &&
echo -e "Gene Expression data matched\n" &&
perl $SIGNET_SCRIPT_ROOT/adj/extractgeno.pl $SIGNET_TMP_ROOT/tmpg/geno_idx ${resg}_Geno > $SIGNET_TMP_ROOT/tmpg/matched.Geno.data &&
$SIGNET_SCRIPT_ROOT/adj/adj_filter.sh &&
$SIGNET_SCRIPT_ROOT/adj/adj_pca.sh &&

echo -e "\n"
echo -e "Please check the pca plots \n"
##pc=3 by default
pc=3
read -p "Enter the number of PC's you want to use: " pc
echo "The number of pc used will be $pc"
echo -e "\n"

Rscript $SIGNET_SCRIPT_ROOT/adj/adj_adjust.R "clifile='$clifile'" "npc='$pc'" 
scp $SIGNET_TMP_ROOT/tmpg/new.Geno.map ${resa}_new.Geno.map
scp $SIGNET_TMP_ROOT/tmpg/new.Geno.maf ${resa}_new.Geno.maf
