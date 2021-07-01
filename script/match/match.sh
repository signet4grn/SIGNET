clifile=$1
Rscript $SIGNET_SCRIPT_ROOT/match/match_gexp.R &&
echo -e "Gene Expression data matched\n" &&
perl $SIGNET_SCRIPT_ROOT/match/extractgeno.pl $SIGNET_TMP_ROOT/tmpm/geno_idx $SIGNET_RESULT_ROOT/resg/Geno > $SIGNET_TMP_ROOT/tmpg/matched.Geno.data &&
$SIGNET_SCRIPT_ROOT/match/match_filter.sh &&
$SIGNET_SCRIPT_ROOT/match/match_pca.sh &&
echo -e "\n"
echo -e "Please check the pca plots \n"
read -p "Enter the number of PC's you want to use: " pc
echo "The number of pc used will be $pc"
echo -e "\n"
Rscript $SIGNET_SCRIPT_ROOT/match/match_adjust.R "clifile='$clifile'" "npc='$pc'" 
scp $SIGNET_TMP_ROOT/tmpg/new.Geno.map $SIGNET_RESULT_ROOT/resm
scp $SIGNET_TMP_ROOT/tmpg/new.Geno.maf $SIGNET_RESULT_ROOT/resm
