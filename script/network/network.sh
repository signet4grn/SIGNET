nboots=$1
r=$2
ncis=$3
nnodes=$4
ncores=$5
memory=$6
walltime=$7


echo 'Select uncorrelated SNPs [ncis:'$ncis',r:'$r',nboots:'$nboots']......'
Rscript uncor.R
Rscript gendata.R $nboots

wait
echo 'Stage 1 of 2SPLS [nboots:'$nboots',ncores:'$ncores',memory:'$memory']......'

nohup ./stage1.sh $nboots &

wait
echo 'Stage 2 of 2SPLS [nboots:'$nboots',ncores:'$ncores',memory:'$memory']......'

nohup ./stage2.sh $nboots $ncores $memory &

wait
echo 'Summary......'

./summarize.sh $nboots



