#!/bin/bash

#testing runtime and memeory
echo -e "Begin testing on the first bootstrap data with the first 10 genes\n"

singularity exec $sif Rscript $SIGNET_SCRIPT_ROOT/network/bstest1.r "ncores='$ncores'" "memory='$memory'" "walltime='$walltime'"

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
perl -pe 's/XXbsXX/'$i'/e; s/YYfirstYY/'$A'/e; s/YYlastYY/'$B'/e' < $SIGNET_SCRIPT_ROOT/network/bts1template.r > bs$i'_'$A'-'$B'.r'
echo 'Rscript bs'$i'_'$A-$B'.r' >> params.txt
done

LEFTOVER=$(( (gene_trunk1 * NUMJOBS) + 1))
if [ $LEFTOVER -le $NGENES ];then
CHUNK=$((NUMJOBS+1))
perl -pe 's/XXbsXX/'$i'/e; s/YYfirstYY/'$LEFTOVER'/e; s/YYlastYY/'$NGENES'/e' < $SIGNET_SCRIPT_ROOT/network/bts1template.r > bs$i'_'$LEFTOVER'-'$NGENES'.r'
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
    echo "sbatch -W sub$i.sh &" >> qsub1.sh
done
else
for i in $( seq 1 $NSUB )
do
    A=`expr $i \* $ncores - $((ncores - 1))`
    B=`expr $i \* $ncores`
    awk "NR >= $A && NR <= $B {print}" < params.txt > params$i.txt      
    perl -pe 's/XXX/'$i'/g' < $SIGNET_SCRIPT_ROOT/network/template.sub > sub$i.sh
    echo "sbatch -W sub$i.sh &" >> qsub1.sh
done

LEFTOVER=$(( ($ncores * NSUB) + 1))
CHUNK=$(( NSUB +1 ))
awk "NR >= $LEFTOVER && NR <= $NJOBS {print}" < params.txt > params$CHUNK.txt      
perl -pe 's/XXX/'$CHUNK'/g' < $SIGNET_SCRIPT_ROOT/network/template.sub > sub$CHUNK.sh
echo "sbatch -W sub$CHUNK.sh &" >> qsub1.sh
fi

echo "wait" >> qsub1.sh

tmpqueue=($(slist|grep $queue))
echo -e "\nThere are in total" ${tmpqueue[1]} "cores available\n"
echo -e "There are "${tmpqueue[2]}" jobs in queue and "${tmpqueue[3]}" jobs are running\n"
echo -e "Please wait for Stage 1 to complete...\n"

grep "^sbatch" qsub1.sh > job1_command
if [[ $interactive == "T" || $interactive == "True" || $interactive == "TRUE" ]];then
sed -i 's/sbatch -W/srun -n1 bash/g;s/&//g' qsub1.sh
echo -e "Running $(wc -l < job1_command) jobs ... \n"
else
echo -e "Submitting $(wc -l < job1_command) jobs ... \n"
fi

time sh qsub1.sh > submit1_log

echo -e "Checking the number of files\n"

nresult=$(find ypre* | wc -l )

if [ $nresult -eq $NJOBS ]
then
echo -e "All the jobs are finished !!\n"
else
echo -e "Please notice that some of the jobs are unfinished. Program will stop and please try to find the problem. \n"
grep -Eo '[0-9]+$' submit1_log | xargs scancel
kill -10 $job_id
exit -1
fi

echo -e "Stage 1 finished!!! Summarizing the results...\n"

if [ ! -d "output" ]; then 
mkdir output 
fi


#summarize the result
for i in $( seq 0 $nboots )
do
  paste -d' ' $(find ./ -name 'ypre'$i'_*' | sort -V) > output/ypre$i
done

