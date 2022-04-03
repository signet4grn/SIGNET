rm -f IDX* 

cd $SIGNET_ROOT/data/network

#if [ -f "$filter" ];then
#Rscript $SIGNET_SCRIPT_ROOT/network/filter.R
#fi

#Prepare for network analysis
echo -e 'Select uncorrelated SNPs [ncis:'$ncis', r:'$cor', nboots:'$nboots']......\n'
singularity exec $sif Rscript $SIGNET_SCRIPT_ROOT/network/uncor.R "r=$cor"
singularity exec $sif Rscript $SIGNET_SCRIPT_ROOT/network/gendata.R "nboots=$nboots"
singularity exec $sif Rscript $SIGNET_SCRIPT_ROOT/network/rmcons.R "nboots=$nboots" 

##create the template.sub file 
sed "s/walltime/$walltime/g;s/ncores/$ncores/g;s/queue/$queue/g" $SIGNET_SCRIPT_ROOT/network/template.sub.ori > $SIGNET_SCRIPT_ROOT/network/template.sub
sed -i "/SLURM_SUBMIT_DIR/d" $SIGNET_SCRIPT_ROOT/network/template.sub

echo -e 'Stage 1 of 2SPLS [nboots:'$nboots',ncores:'$ncores',memory:'$memory', queue:'$queue']......\n'

##Get job id
trap "exit -1" 10
export job_id="$$"

$SIGNET_SCRIPT_ROOT/network/stage1.sh &&

wait

#begin stage2
echo -e 'Stage 2 of 2SPLS [nboots:'$nboots', ncores:'$ncores', memory:'$memory', queue:'$queue']......\n'

$SIGNET_SCRIPT_ROOT/network/stage2.sh &&

##summarize the result

singularity exec $sif Rscript $SIGNET_SCRIPT_ROOT/network/summarize.r &&

#back up the results, for use in visualization stage
scp $SIGNET_TMP_ROOT/tmpn/stage2/output/CoeffMat0 ${resn}_CoeffMat0
scp $SIGNET_TMP_ROOT/tmpn/net.genepos ${resn}_net.genepos

echo -e "\nNetwork analysis completed!!!\n"
