#!/bin/bash
#testing runtime and memeory
echo -e "Testing on the first bootstrap data with the first 10 genes...\n"

Rscript $SIGNET_SCRIPT_ROOT/network/bstest1.r "ncores='$ncores'" "memory='$memory'" "walltime='$walltime'"

rm -f ypre1_1-10

cd $SIGNET_TMP_ROOT/tmpn/stage1
##create the jobs for stage1  
echo "#!/bin/bash" > qsub1.sh
chmod +x qsub1.sh

## remove ypre in the current folder
#rm -f ypre*
#rm -f params.txt
#rm -f sub*.sh
#rm -f qsub1.sh
#rm -f bs*

echo -e "\nCreating jobs for Stage 1...\n" 

gene_trunk1=$(< ../gene_trunk_stage1)

NGENES=$(wc -l ../uniqy_idx | cut -d " " -f1)
NUMJOBS=$(( NGENES / gene_trunk1 ))

for i in $( seq 0 $nboots )
do
for j in $( seq 1 $NUMJOBS )
do
A=`expr $j \* $gene_trunk1 - $(( gene_trunk1 - 1))`
B=`expr $j \* $gene_trunk1`
perl -pe 's/XXbsXX/'$i'/e; s/YYfirstYY/'$A'/e; s/YYlastYY/'$B'/e' < $SIGNET_SCRIPT_ROOT/network/bts1template_cloud.r > bs$i'_'$A'-'$B'.r'
echo 'Rscript bs'$i'_'$A-$B'.r' >> params.txt
done

LEFTOVER=$(( (gene_trunk1 * NUMJOBS) + 1))
if [ $LEFTOVER -le $NGENES ];then
CHUNK=$((NUMJOBS+1))
perl -pe 's/XXbsXX/'$i'/e; s/YYfirstYY/'$LEFTOVER'/e; s/YYlastYY/'$NGENES'/e' < $SIGNET_SCRIPT_ROOT/network/bts1template_cloud.r > bs$i'_'$LEFTOVER'-'$NGENES'.r'
echo 'Rscript bs'$i'_'$LEFTOVER'-'$NGENES'.r' >> params.txt
fi
done


NJOBS=$(wc -l < params.txt)
NSUB=$(( NJOBS / $ncores ))

if [[ $NSUB -eq 0 ]]
then
NSUB=1
for i in $( seq 1 $NSUB )
do
    A=`expr $i \* $ncores - $((ncores - 1))`
    B=`expr $i \* $ncores`
    awk "NR >= $A && NR <= $B {print}" < params.txt > params$i.txt
    perl -pe 's/XXX/'$i'/g' < $SIGNET_SCRIPT_ROOT/network/template.sub > sub$i.sh
done
else
for i in $( seq 1 $NSUB )
do
    A=`expr $i \* $ncores - $((ncores - 1))`
    B=`expr $i \* $ncores`
    awk "NR >= $A && NR <= $B {print}" < params.txt > params$i.txt      
    perl -pe 's/XXX/'$i'/g' < $SIGNET_SCRIPT_ROOT/network/template.sub > sub$i.sh
done

LEFTOVER=$(( ($ncores * NSUB) + 1))
CHUNK=$(( NSUB +1 ))
awk "NR >= $LEFTOVER && NR <= $NJOBS {print}" < params.txt > params$CHUNK.txt      
perl -pe 's/XXX/'$CHUNK'/g' < $SIGNET_SCRIPT_ROOT/network/template.sub > sub$CHUNK.sh
fi

