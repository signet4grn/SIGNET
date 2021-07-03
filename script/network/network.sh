cd $SIGNET_TMP_ROOT/tmpn

module load r/4.0.0

nboots=$1
cor=$2
ncis=$3
queue=$4
ncores=$5
memory=$6
walltime=$7
loc=$8

rm -f IDX* 

echo -e 'Select uncorrelated SNPs [ncis:'$ncis',r:'$r',nboots:'$nboots']......\n'
Rscript $SIGNET_SCRIPT_ROOT/network/uncor.R "r=$cor"
Rscript $SIGNET_SCRIPT_ROOT/network/gendata.R "nboots=$nboots"

wait
echo -e 'Stage 1 of 2SPLS [nboots:'$nboots',ncores:'$ncores',memory:'$memory']......\n'

nohup ./stage1.sh $nboots &

wait
echo -e 'Stage 2 of 2SPLS [nboots:'$nboots',ncores:'$ncores',memory:'$memory']......\n'

nohup ./stage2.sh $nboots $ncores $memory &

wait
echo -e 'Summary......\n'

./summarize.sh $nboots



