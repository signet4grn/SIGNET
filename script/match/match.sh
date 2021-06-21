clifile=$1
Rscript $SIGNET_SCRIPT_ROOT/match/match_gexp.R &&
echo -e "Gene Expression data matched\n" &&
perl $SIGNET_SCRIPT_ROOT/match/extractgeno.pl $SIGNET_TMP_ROOT/tmpm/geno_idx $SIGNET_RESULT_ROOT/resg/Geno > $SIGNET_TMP_ROOT/tmpg/matched.Geno.data &&
$SIGNET_SCRIPT_ROOT/match/match_filter.sh &&
$SIGNET_SCRIPT_ROOT/match/match_pca.sh &&
Rscript $SIGNET_SCRIPT_ROOT/match/match_adjust.R "clifile='$clifile'" 
scp $SIGNET_TMP_ROOT/tmpg/new.Geno.map $SIGNET_RESULT_ROOT/resm
scp $SIGNET_TMP_ROOT/tmpg/new.Geno.maf $SIGNET_RESULT_ROOT/resm
