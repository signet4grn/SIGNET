rm -f IDX* 

cd $SIGNET_ROOT/data/network

#Prepare for network analysis
echo -e 'Select uncorrelated SNPs [ncis:'$ncis',r:'$r',nboots:'$nboots']......\n'
Rscript $SIGNET_SCRIPT_ROOT/network/uncor.R "r=$cor"
Rscript $SIGNET_SCRIPT_ROOT/network/gendata.R "nboots=$nboots"
Rscript $SIGNET_SCRIPT_ROOT/network/rmcons.R "nboots=$nboots" 

##create the template.sub file 
sed "s/walltime/$walltime/g;s/ncores/$ncores/g;s/queue/$queue/g" $SIGNET_SCRIPT_ROOT/network/template.sub.ori > $SIGNET_SCRIPT_ROOT/network/template.sub

#begin stage1
echo -e 'Stage 1 of 2SPLS [nboots:'$nboots',ncores:'$ncores',memory:'$memory', queue:'$queue']......\n'

$SIGNET_SCRIPT_ROOT/network/stage1.sh &&

wait

#begin stage2
echo -e 'Stage 2 of 2SPLS [nboots:'$nboots',ncores:'$ncores',memory:'$memory', queue:'$queue']......\n'

$SIGNET_SCRIPT_ROOT/network/stage2.sh &&

##summarize the result

Rscript $SIGNET_SCRIPT_ROOT/network/summarize.r
echo -e "\nNetwork analysis completed!!!\n"
