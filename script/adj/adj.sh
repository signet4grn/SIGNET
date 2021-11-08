clifile=$1
Rscript $SIGNET_SCRIPT_ROOT/adj/adj_gexp.R &&
echo -e "Gene Expression data adjed\n" &&
perl $SIGNET_SCRIPT_ROOT/adj/extractgeno.pl $SIGNET_TMP_ROOT/tmpg/geno_idx $SIGNET_RESULT_ROOT/resg/Geno > $SIGNET_TMP_ROOT/tmpg/adjed.Geno.data &&
$SIGNET_SCRIPT_ROOT/adj/adj_filter.sh &&
$SIGNET_SCRIPT_ROOT/adj/adj_pca.sh &&

echo -e "\n"
echo -e "Please check the pca plots \n"
read -p "Enter the number of PC's you want to use: " pc
echo "The number of pc used will be $pc"
echo -e "\n"

Rscript $SIGNET_SCRIPT_ROOT/adj/adj_adjust.R "clifile='$clifile'" "npc='$pc'" 
scp $SIGNET_TMP_ROOT/tmpg/new.Geno.map $SIGNET_RESULT_ROOT/resa
scp $SIGNET_TMP_ROOT/tmpg/new.Geno.maf $SIGNET_RESULT_ROOT/resa
