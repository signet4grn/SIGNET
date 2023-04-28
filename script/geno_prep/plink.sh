## This sciprt will apply plink commands to the files

echo -e "Preprocessing genotype data with PLINK...\n"
if [[ $restrict == "no"  ]]
then 
plink --silent --noweb --ped $pedfile --map $mapfile --geno $geno --hwe $hwe --recode --snps-only --list-duplicate-vars suppress-first --out $SIGNET_TMP_ROOT/tmpg/clean_Genotype &&
else
plink --silent --noweb --ped $pedfile --map $mapfile --chr $restrict --geno $geno --hwe $hwe --recode --snps-only --list-duplicate-vars suppress-first --out $SIGNET_TMP_ROOT/tmpg/clean_Genotype &&
fi
# if no file, stop 
$SIGNET_SCRIPT_ROOT/geno_prep/check_ped.sh &&
plink --silent --noweb --file $SIGNET_TMP_ROOT/tmpg/clean_Genotype --mind $mind --exclude $SIGNET_TMP_ROOT/tmpg/clean_Genotype.dupvar --recode --out $SIGNET_TMP_ROOT/tmpg/clean_Genotype --set-hh-missing &&
plink --silent --noweb --file $SIGNET_TMP_ROOT/tmpg/clean_Genotype --recodeA --out $SIGNET_TMP_ROOT/tmpg/clean_Genotype --set-hh-missing &&
tail -n+2 $SIGNET_TMP_ROOT/tmpg/clean_Genotype.raw > $SIGNET_TMP_ROOT/tmpg/clean_Genotype.data  &&
echo -e "Preprocessing genotype data... completed!\n"
