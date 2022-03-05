cd $SIGNET_TMP_ROOT/tmpg/impute

echo -e 'Combining imputated results \n'
for i in `seq 1 ${nchr}`
do
if [ $(find 'impute_chr'$i'chunk'* ! -name "*[0-9]_*" 2>/dev/null | wc -l) -gt 0 ]
then
   cat $(find 'impute_chr'$i'chunk'* ! -name "*[0-9]_*"  | sort -V) > 'imputed_chr'$i'.gen'
fi
done

for i in `seq 1 ${nchr}`
do
if [ -f ../$i.sample ] 
then
    cp ../$i.sample imputed_chr$i.sample
fi
done

for i in `seq 1 ${nchr}`
do
if [ -f imputed_chr$i.sample ]
then
    plink --silent --data 'imputed_chr'$i --recodeA --out 'clean_Genotype_chr'$i    
    plink --silent --data 'imputed_chr'$i --recode --out 'clean_Genotype_chr'$i
fi
done

for i in `seq 1 ${nchr}`
do
echo -n "$i "
if [ -f clean_Genotype_chr$i.map ]
then
n=`wc -l clean_Genotype_chr$i.map | awk '{print $1}'`
echo "$n"
else echo 0
fi
done > impute_Genotype.sizes


for i in `seq 1 ${nchr}`
do
if [ -f 'clean_Genotype_chr'$i'.raw' ] 
then
    tail -n+2 'clean_Genotype_chr'$i'.raw' | cut -d " " -f 7- > 'clean_Genotype_chr'$i'.data'
fi
done

for i in `seq 1 ${nchr}`
do
if [ -f 'clean_Genotype_chr'$i'.data' ] 
then
        sed -i -e 's/NA/0/g' 'clean_Genotype_chr'$i'.data'
fi
done

### Combine genotype data 
paste -d' ' $(find ./ -name "clean_Genotype_chr*.data" | sort -V) > imputed_Genotype.data
### Sample ID i

awk '{print $2}' ../clean_Genotype.data > ${resg}_Genotype.sampleID
### Combine sample ID with genotype data

scp imputed_Genotype.data ${resg}_Geno
