chr="25"
map="fake.map"
ped="fake.ped"
geno='fake'
cd ../../data/geno-prep

plink --noweb --file $geno --mind 0.1 --geno 0.1 --hwe 0.0001 --recodeA --out clean_Genotype & 

# Split the .map file
for i in `seq 1 ${chr}`
do 
echo $i
awk '/^'"$i"'\t/ {print $0}' $map > clean_Genotype_chr$i.map
done

# Create the file "clean_Genotype.sizes":
for i in `seq 1 ${chr}`
do
echo -n "$i "
n=`wc -l clean_Genotype_chr$i.map | awk '{print $1}'`
echo "$n"
done > clean_Genotype.sizes


cut -d " " -f1-6 $ped > clean_Genotype.fam
cut -d " "  -f 7- $ped > temp && mv temp clean_Genotype.ped


# Split the .raw file: 
nohup tail -n+2 clean_Genotype.raw > clean_Genotype.data & 
nohup ../../script/geno-prep/splitchr.pl clean_Genotype.data clean_Genotype.sizes $chr 
#nohup ../../script/geno-prep/splitchr_ped.pl clean_Genotype.ped clean_Genotype.sizes $chr
