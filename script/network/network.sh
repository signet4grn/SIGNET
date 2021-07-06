module load r/4.0.0

nboots=$1
cor=$2
queue=$3
ncores=$4
memory=$5
walltime=$6
loc=$7

rm -f IDX* 

cd $SIGNET_ROOT/data/network

#Prepare for network analysis
echo -e 'Select uncorrelated SNPs [ncis:'$ncis',r:'$r',nboots:'$nboots']......\n'
#Rscript $SIGNET_SCRIPT_ROOT/network/uncor.R "r=$cor"
#Rscript $SIGNET_SCRIPT_ROOT/network/gendata.R "nboots=$nboots"
#Rscript $SIGNET_SCRIPT_ROOT/network/rmcons.R "nboots=$nboots" 

##create the template.sub file
sed -i "s/queue/$queue/g" $SIGNET_SCRIPT_ROOT/network/template.sub
sed -i "s/ncores/$ncores/g" $SIGNET_SCRIPT_ROOT/network/template.sub
sed -i "s/walltime/$walltime/g" $SIGNET_SCRIPT_ROOT/network/template.sub

#begin stage1
echo -e 'Stage 1 of 2SPLS [nboots:'$nboots',ncores:'$ncores',memory:'$memory', queue:'$queue']......\n'

#$SIGNET_SCRIPT_ROOT/network/stage1.sh $nboots $memory $walltime $ncores $queue

wait

#begin stage2
echo -e 'Stage 2 of 2SPLS [nboots:'$nboots',ncores:'$ncores',memory:'$memory', queue:'$queue']......\n'

$SIGNET_SCRIPT_ROOT/network/stage2.sh $nboots $memory $walltime $ncores $queue

wait
echo -e 'Summary......\n'

$SIGNET_SCRIPT_ROOT/network/summarize.sh $nboots




