#!/bin/bash
echo -e "Combining results in stage1...\n"
# summarize the result in stage1

mkdir -p $SIGNET_TMP_ROOT/tmpn/stage1/output
for i in $( seq 0 $nboots )
do
  paste -d' ' $(find ./ -name '$SIGNET_TMP_ROOT/tmpn/stage1/*ypre'$i'_*' | sort -V) > $SIGNET_TMP_ROOT/tmpn/stage1/output/ypre$i
done

echo -e "Combining finished...\n"

echo -e "Testing on the first bootstrap data with the first 10 genes...\n"

# test time
Rscript $SIGNET_SCRIPT_ROOT/network/bstest2.r "ncores='$ncores'" "memory='$memory'" "walltime='$walltime'"

rm -f Adj*
rm -f Coef*

cd $SIGNET_TMP_ROOT/tmpn/stage2
##create the jobs for stage2 
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
echo 'Rscript bs'$i'_'$A-$B'.r' >> params.txt
done

LEFTOVER=$(( (gene_trunk2 * NUMJOBS) + 1))
if [ $LEFTOVER -le $NGENES ];then
CHUNK=$((NUMJOBS+1))
perl -pe 's/XXbsXX/'$i'/e; s/YYfirstYY/'$LEFTOVER'/e; s/YYlastYY/'$NGENES'/e' < $SIGNET_SCRIPT_ROOT/network/bts2template.r > bs$i'_'$LEFTOVER'-'$NGENES'.r'
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


#nresult=$(find Adj* | wc -l )

#if [ $nresult -eq $NJOBS ]
#then
#echo -e "All the jobs are completed!\n"
#email_note $email "Stage 2" "Completed!"
#else 
#echo -e "Warning: Some jobs are incomplete! Please find the problem and retry...\n"
#email_note $email "Stage 2" "Failed..."
#grep -Eo '[0-9]+$' submit2_log | xargs scancel
#kill -10 $job_id
#exit -1
#fi 

#echo -e "\nStage 2 is completed! Summarizing the results...\n"

##Simmarize the result
#if [ ! -d "output" ];then
#mkdir output
#fi

#for i in $(seq 0 $nboots)
#do
#  cat $(find ./ -name 'AdjMat'$i'_*' | sort -V) > output/AdjMat$i
#  cat $(find ./ -name 'CoeffMat'$i'_*' | sort -V) > output/CoeffMat$i
#:done
