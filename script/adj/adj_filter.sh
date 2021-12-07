##This script filter out SNPs with allele count <5
nchr=$($SIGNET_ROOT/signet -s --nchr)
ncore=$($SIGNET_ROOT/signet -s --ncore_local)

cd $SIGNET_TMP_ROOT/tmpg

echo -e "Splitting genotype data \n"
$SIGNET_SCRIPT_ROOT/geno_prep/splitchr.pl matched.Geno.data impute/impute_Genotype.sizes $nchr 


for i in `seq 1 ${nchr}`
do
  scp impute/clean_Genotype_chr$i.map matched.Geno_chr$i.map
done

rm -f qsub.sh

rm -f qsub.sh.completed

for i in `seq 1 ${nchr}`
do
  perl -pe 's/XXX/'$i'/g' < $SIGNET_SCRIPT_ROOT/adj/genosum.R > $SIGNET_SCRIPT_ROOT/adj/genosum_chr$i.R
  echo "Rscript $SIGNET_SCRIPT_ROOT/adj/genosum_chr$i.R" >> qsub.sh
done

time ParaFly -c qsub.sh -CPU $ncore &&

find . -name "matched.Geno.ma_chr*"|sort -V|xargs paste -d' ' >matched.Geno.ma

Rscript $SIGNET_SCRIPT_ROOT/adj/filterma5.R

cat $(find ./ -name 'matched.Geno_chr*.map' | sort -V) > matched_Genotype.map
Rscript $SIGNET_SCRIPT_ROOT/adj/snps5.R

sed -i '1s/,$//;1s/^/{print /;1s/$/}/' new.Geno.idx

$SIGNET_SCRIPT_ROOT/adj/extractsnp.pl snps5.idx  matched.Geno.data > ${resa}_new.Geno

[ -e sz ] && rm sz
## Summarize minor allele frequency for SNPs in new.Geno output to new.Geno.maf
echo $(wc -l < ${resa}_new.Geno) >> sz

Rscript $SIGNET_SCRIPT_ROOT/adj/masummary.R
