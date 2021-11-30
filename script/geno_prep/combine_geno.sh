cd $SIGNET_TMP_ROOT/tmpg/impute

echo -e 'Combining imputated results \n'
for i in `seq 1 ${nchr}`
do
   cat $(find 'impute_chr'$i'chunk'* ! -name "*[0-9]_*"  | sort -V) > 'imputed_chr'$i'.gen'
done

for i in `seq 1 ${nchr}`
do
    cp ../$i.sample imputed_chr$i.sample
done

for i in `seq 1 ${nchr}`
do
    plink --silent --data 'imputed_chr'$i --recodeA --out 'clean_Genotype_chr'$i    
    plink --silent --data 'imputed_chr'$i --recode --out 'clean_Genotype_chr'$i
done

for i in `seq 1 22`
do
echo -n "$i "
n=`wc -l clean_Genotype_chr$i.map | awk '{print $1}'`
echo "$n"
done > impute_Genotype.sizes


for i in `seq 1 ${nchr}`
do 
    tail -n+2 'clean_Genotype_chr'$i'.raw' | cut -d " " -f 7- > 'clean_Genotype_chr'$i'.data'
done

for i in `seq 1 ${nchr}`
do
        sed -i -e 's/NA/0/g' clean_Genotype_chr$i.data
done

### Combine genotype data 
paste -d' ' $(find ./ -name "clean_Genotype_chr*.data" | sort -V) > imputed_Genotype.data
### Sample ID i

awk '{print $2}' ../clean_Genotype.data > ${resg}_Genotype.sampleID
### Combine sample ID with genotype data

scp imputed_Genotype.data ${resg}_Geno
