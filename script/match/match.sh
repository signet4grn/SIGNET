

#nohup ./codes/splitchr.pl matched.Geno.data ./Genotype/clean_Genotype.sizes 22 &
cd ../../data/match
for i in {1..25} 
do 
	cp ../geno-prep/clean_Genotype_chr$i.map matched.Geno_chr$i.map 
	cp ../geno-prep/clean_Genotype_chr$i.data matched.Geno_chr$i.data 
done

cd ../../script/match

echo "#!/bin/sh" > qsub.sh
chmod +x qsub.sh

for i in {1..22}
do
  perl -pe 's/XXX/'$i'/g' < genosum.m > genosum_chr$i.m
  echo "nohup matlab -nodisplay -nodesktop -nosplash < genosum_chr$i.m > genosum_chr$i.log &" >> qsub.sh
done


sh qsub.sh

cd ../../data/match
find . -name "matched.Geno.ma_chr*"|sort -V|xargs paste -d' ' >matched.Geno.ma

cd ../../script/match
nohup matlab -nodisplay -nodesktop -nosplash < filterma5.m > nohup.out

./maf.sh


