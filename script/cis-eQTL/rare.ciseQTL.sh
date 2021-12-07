#!/bin/bash
ncore=$($SIGNET_ROOT/signet -s --ncore_local)

cd $SIGNET_TMP_ROOT/tmpc

if [ ! -s rare.cispair.idx ]
then
touch ${resc}_rare.sig.pValue_$alpha
touch ${resc}_rare.eQTL.data	
echo -e "No analysis will be conducted for rare variants since there are no cis-pairs detected\n"; exit
fi

echo -e "Cis-eQTL Analyis for rare variants [alpha:"$alpha",nperms:"$nperms"]......\n"

perl -pe "s/nperms/$nperms/g" $SIGNET_SCRIPT_ROOT/cis-eQTL/rare.ciseQTL.r > $SIGNET_SCRIPT_ROOT/cis-eQTL/rare.ciseQTL_2.r

#rm -f rare.qsub.sh*

echo -e "Parallel computing using" $ncore "cores \n" 

NGENES=$(cut -d " " -f1 rare.cispair.idx | sort | uniq | wc -l)
NUMJOBS=$((NGENES / 1000))
for i in $( seq 1 $NUMJOBS )
do
   perl -pe 's/YYstartYY/'$i'*1000-999/e; s/YYendYY/'$i'*1000/e; s/YYY/'$i'/g' < $SIGNET_SCRIPT_ROOT/cis-eQTL/rare.ciseQTL_2.r > rare.ciseQTL$i.r
   echo "Rscript rare.ciseQTL$i.r" >> rare.qsub.sh
done
LEFTOVER=$(( (1000*NUMJOBS) + 1))
CHUNK=$((NUMJOBS+1))
perl -pe 's/YYstartYY/'$LEFTOVER'/e; s/YYendYY/'$NGENES'/e; s/YYY/'$CHUNK'/g' < $SIGNET_SCRIPT_ROOT/cis-eQTL/rare.ciseQTL_2.r > rare.ciseQTL$CHUNK.r
echo "Rscript rare.ciseQTL$CHUNK.r" >> rare.qsub.sh

time ParaFly -c rare.qsub.sh -CPU $ncore

wait 

## Combine data  
#rm -f rare.ciseQTL.weight0
#rm -f rare.ciseQTL.weight
#rm -f rare.theoP

cat $(find ./ -name 'rare.ciseQTL.weight*' | sort -V) > rare.ciseQTL.weight0
paste rare.cispair.idx rare.ciseQTL.weight0 > rare.ciseQTL.weight
#Col 1: index of gene, Col 2: index of SNP, Col 3: index of collapsed SNPs for a gene, Col 4: weight of collapsed SNPs for a gene
cat $(find ./ -name 'rare.theoP*' | sort -V) > rare.theoP

echo -e "\nSummarizing for rare variants \n"
#Select significant pairs
Rscript $SIGNET_SCRIPT_ROOT/cis-eQTL/sig.rarecis.r "alpha='$alpha'" &&
Rscript $SIGNET_SCRIPT_ROOT/cis-eQTL/rare.eQTLdata.r "alpha='$alpha'" 

wait

nsig=$(awk '{print $2}' ${resc}_rare.sig.pValue_${alpha} |sort | uniq |wc -l)
ngene=$(awk '{print $1}' ${res}_rare.sig.pValue_${alpha} | sort | uniq | wc -l)
echo "----" $nsig "significant rare variants enriched regions found for "$ngene" genes" 
