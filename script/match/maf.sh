

### Map file for SNPs with >=5 minor alleles => "new.Geno.idx" 

Rscript snps5.R

cd ../../data/match
### Convert new.Geno.idx to awk format: {print $ ,...$ } 
sed -i '1s/,$//;1s/^/{print /;1s/$/}/' new.Geno.idx
### Genotype data for SNPs with >=5 minor alleles 
nohup awk -f new.Geno.idx < matched.Geno.data > new.Geno & 


awk 'END {print NR}' matched.Gexp > n 
cd ../../script/match
nohup matlab -nodisplay -nodesktop -nosplash < ./masummary.m > nohup.out

#nohup python -c "import sys; print('\n'.join(' '.join(c) for c in zip(*(l.split() for l in sys.stdin.readlines() if l.strip()))))" < maf5 > new.Geno.maf &
