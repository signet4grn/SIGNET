#!/bin/bash
ncore=$($SIGNET_ROOT/signet -s --ncore_local)

cd $SIGNET_TMP_ROOT/tmpc

if [ ! -s low.cispair.idx ]
then 
touch ${resc}_low.sig.pValue_$alpha
touch ${resc}_low.eQTL.data
echo -e "No analysis will be conducted for low variants since there are no cis-pairs detected\n"; exit
fi

echo -e "Cis-eQTL Analyis for low variants [alpha:"$alpha",nperms:"$nperms"]......\n"

perl -pe "s/nperms/$nperms/g" $SIGNET_SCRIPT_ROOT/cis-eQTL/low.ciseQTL.r > $SIGNET_SCRIPT_ROOT/cis-eQTL/low.ciseQTL_2.r

#rm -f low.qsub.sh*

echo -e "Parallel computing using" $ncore "cores \n" 

NGENES=$(cut -d " " -f1 low.cispair.idx | sort | uniq | wc -l)
NUMJOBS=$((NGENES / 1000))
for i in $( seq 1 $NUMJOBS )
do
   perl -pe 's/YYstartYY/'$i'*1000-999/e; s/YYendYY/'$i'*1000/e; s/YYY/'$i'/g' < $SIGNET_SCRIPT_ROOT/cis-eQTL/low.ciseQTL_2.r > low.ciseQTL$i.r
   echo "Rscript low.ciseQTL$i.r" >> low.qsub.sh
done
LEFTOVER=$(( (1000*NUMJOBS) + 1))
CHUNK=$((NUMJOBS+1))
perl -pe 's/YYstartYY/'$LEFTOVER'/e; s/YYendYY/'$NGENES'/e; s/YYY/'$CHUNK'/g' < $SIGNET_SCRIPT_ROOT/cis-eQTL/low.ciseQTL_2.r > low.ciseQTL$CHUNK.r
echo "Rscript low.ciseQTL$CHUNK.r" >> low.qsub.sh

time ParaFly -c low.qsub.sh -CPU $ncore

wait 

## Combine data  
#rm -f low.ciseQTL.weight0
#rm -f low.ciseQTL.weight
#rm -f low.theoP

cat $(find ./ -name 'low.ciseQTL.weight*' | sort -V) > low.ciseQTL.weight0
paste low.cispair.idx low.ciseQTL.weight0 > low.ciseQTL.weight
#Col 1: index of gene, Col 2: index of SNP, Col 3: index of collapsed SNPs for a gene, Col 4: weight of collapsed SNPs for a gene
cat $(find ./ -name 'low.theoP*' | sort -V) > low.theoP

echo -e "\nSummarizing for low variants \n"
#Select significant pairs
Rscript $SIGNET_SCRIPT_ROOT/cis-eQTL/sig.lowcis.r "alpha='$alpha'" &&
Rscript $SIGNET_SCRIPT_ROOT/cis-eQTL/low.eQTLdata.r "alpha='$alpha'" 

wait

nsig=$(awk '{print $2}' ${resc}_low.sig.pValue_${alpha} |sort | uniq |wc -l)
ngene=$(awk '{print $1}' ${resc}_low.sig.pValue_${alpha} | sort | uniq | wc -l)
echo -e "----" $nsig "significant low variants enriched regions found for "$ngene" genes\n" 
