#!/bin/bash

echo -e "Begin testing on the first bootstrap data with the first 10 genes\n"

Rscript $SIGNET_SCRIPT_ROOT/network/bstest2.r "ncores='$ncores'" "memory='$memory'" "walltime='$walltime'"
rm -f Adj*
rm -f Coef*


cd $SIGNET_TMP_ROOT/tmpn/stage2
##create the jobs for stage1  
echo "#!/bin/bash" > qsub2.sh
chmod +x qsub2.sh

#rm -f params.txt
#rm -f sub*.sh
#rm -f qsub2.sh
#rm -f bs*
#rm -f Adj*
#rm -f Coef*

echo -e "\nCreating jobs for Stage 2...\n" 

gene_trunk2=$(< ../gene_trunk_stage2)

NGENES=$(awk '{print NF; exit}' ../nety)
NUMJOBS=$(( NGENES / gene_trunk2 ))


for i in $( seq 0 $nboots )
do
for j in $( seq 1 $NUMJOBS )
do
A=`expr $j \* $gene_trunk2 - $(( gene_trunk2 - 1))`
B=`expr $j \* $gene_trunk2`
perl -pe 's/XXbsXX/'$i'/e; s/YYfirstYY/'$A'/e; s/YYlastYY/'$B'/e' < $SIGNET_SCRIPT_ROOT/network/bts2template.r > bs$i'_'$A'-'$B'.r'
echo 'nohup Rscript bs'$i'_'$A-$B'.r &' >> params.txt
done

LEFTOVER=$(( (gene_trunk2 * NUMJOBS) + 1))
if [ $LEFTOVER -le $NGENES ];then
CHUNK=$((NUMJOBS+1))
perl -pe 's/XXbsXX/'$i'/e; s/YYfirstYY/'$LEFTOVER'/e; s/YYlastYY/'$NGENES'/e' < $SIGNET_SCRIPT_ROOT/network/bts2template.r > bs$i'_'$LEFTOVER'-'$NGENES'.r'
echo 'nohup Rscript bs'$i'_'$LEFTOVER'-'$NGENES'.r &' >> params.txt
fi
done


NJOBS=$(wc -l < params.txt)
NSUB=$(( NJOBS / $ncores ))

if [ $NSUB==0 ]
then
NSUB=1
for i in $( seq 1 $NSUB )
do
    A=`expr $i \* $ncores - $((ncores - 1))`
    B=`expr $i \* $ncores`
    awk "NR >= $A && NR <= $B {print}" < params.txt > params$i.txt
    awk {print} $SIGNET_SCRIPT_ROOT/network/template.sub >> sub$i.sh
    awk {print} params$i.txt >> sub$i.sh
    echo 'wait' >> sub$i.sh
    echo "sbatch -W sub$i.sh" >> qsub2.sh
done
else
for i in $( seq 1 $NSUB )
do
    A=`expr $i \* $ncores - $((ncores - 1))`
    B=`expr $i \* $ncores`
    awk "NR >= $A && NR <= $B {print}" < params.txt > params$i.txt      
    awk {print} $SIGNET_SCRIPT_ROOT/network/template.sub >> sub$i.sh
    awk {print} params$i.txt >> sub$i.sh
    echo 'wait' >> sub$i.sh
    echo "sbatch -W sub$i.sh" >> qsub2.sh
done

LEFTOVER=$(( ($ncores * NSUB) + 1))
CHUNK=$(( NSUB +1 ))
awk "NR >= $LEFTOVER && NR <= $NJOBS {print}" < params.txt > params$CHUNK.txt      
awk {print} $SIGNET_SCRIPT_ROOT/network/template.sub >> sub$CHUNK.sh
awk {print} params$CHUNK.txt >> sub$CHUNK.sh
echo 'wait' >> sub$CHUNK.sh
echo "sbatch -W sub$CHUNK.sh" >> qsub2.sh
fi

tmpqueue=($(slist|grep $queue))
echo -e "\nThere are in total" ${tmpqueue[1]} "cores available\n"
echo -e "There are "${tmpqueue[2]}" jobs in queue and "${tmpqueue[3]}" jobs are running\n"
echo -e "Please wait for Stage 2 to complete...\n"

time sh qsub2.sh
wait

echo -e "Checking the number of files\n"

nresult=$(find Adj* | wc -l )

if [ $nresult==$NJOBS ]
then
echo -e "All the jobs are finished !!\n"
else 
echo -e "Please notice that some of the jobs are unfinished. Program will stop and please try to find the problem. \n"
exit
fi 

echo -e "\nStage 2 finished!!! Summarizing the results...\n"

##Simmarize the result
if [ ! -d "output" ];then
mkdir output
fi

for i in $(seq 0 $nboots)
do
  cat $(find ./ -name 'AdjMat'$i'_*' | sort -V) > output/AdjMat$i
  cat $(find ./ -name 'CoeffMat'$i'_*' | sort -V) > output/CoeffMat$i
done
