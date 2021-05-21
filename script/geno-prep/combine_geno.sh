

cd ../../data/geno-prep

### Combine genotype data 
paste -d' ' $(find ./ -name "clean_Genotype_chr*.data" | sort -V) > imputed_Genotype.data
### Sample ID 
awk '{print $2}' clean_Genotype.data > Genotype.sampleID
### Combine sample ID with genotype data 
paste -d' ' Genotype.sampleID imputed_Genotype.data > Geno 
