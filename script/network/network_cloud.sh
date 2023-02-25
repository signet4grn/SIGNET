rm -f IDX*

cd $SIGNET_ROOT/data/network

#if [ -f "$filter" ];then
#Rscript $SIGNET_SCRIPT_ROOT/network/filter.R
#fi

#Prepare for network analysis
echo -e 'Select uncorrelated SNPs [ncis:'$ncis', r:'$cor', nboots:'$nboots']......\n'
Rscript $SIGNET_SCRIPT_ROOT/network/uncor.R "r=$cor"
Rscript $SIGNET_SCRIPT_ROOT/network/gendata.R "nboots=$nboots"
Rscript $SIGNET_SCRIPT_ROOT/network/rmcons.R "nboots=$nboots"

sed "s/walltime/$walltime/g;s/ncores/$ncores/g;s/queue/$queue/g" $SIGNET_SCRIPT_ROOT/network/template.sub.cloud.ori > $SIGNET_SCRIPT_ROOT/network/template.sub.cloud

echo -e 'Stage 1 of 2SPLS [nboots:'$nboots',ncores:'$ncores',memory:'$memory', queue:'$queue']......\n'

##Get job id

if [[ "$stage" -eq 1 ]];then
$SIGNET_SCRIPT_ROOT/network/stage1_cloud.sh 
else
$SIGNET_SCRIPT_ROOT/network/stage2_cloud.sh 
fi




