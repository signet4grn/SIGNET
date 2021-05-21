
cd ../../data/geno-prep
chr=22

for i in {1..25} 
do 
	sed -i -e 's/NA/0/g' clean_Genotype_chr$i.data 
done 
