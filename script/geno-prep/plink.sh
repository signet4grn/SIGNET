## This sciprt will apply plink commands to the files
ped=$1
map=$2
mind=$3
geno=$4
hwe=$5

echo -e "Preprocessing using Plink\n"



plink --silent --noweb --ped $ped --map $map --geno $geno --hwe $hwe --recode --snps-only --list-duplicate-vars suppress-first --out $SIGNET_TMP_ROOT/tmpg/clean_Genotype &&
plink --silent --noweb --file $SIGNET_TMP_ROOT/tmpg/clean_Genotype --mind $mind --exclude $SIGNET_TMP_ROOT/tmpg/clean_Genotype.dupvar --recode --out $SIGNET_TMP_ROOT/tmpg/clean_Genotype --set-hh-missing &&
echo -e "Plink preprocessing finished\n"
