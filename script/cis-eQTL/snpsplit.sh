#split snps

cd $SIGNET_TMP_ROOT/tmpc

## Seperate the map files and generate indices for different variants categories
Rscript $SIGNET_SCRIPT_ROOT/cis-eQTL/grpsnps.R

### Genotype data

### add '{print ' to the begining of *.snps.idx file and '}' to the end of *.snps.idx file
sed -i '1s/,$//;1s/^/{print /;1s/$/}/' rare.snps.idx
sed -i '1s/,$//;1s/^/{print /;1s/$/}/' low.snps.idx
sed -i '1s/,$//;1s/^/{print /;1s/$/}/' common.snps.idx

echo -e "\n"
