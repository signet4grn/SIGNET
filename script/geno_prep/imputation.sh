nchr=$1
ref=$2
gmap=$3
ncores=$4
ped=$SIGNET_TMP_ROOT/tmpg/clean_Genotype.ped
map=$SIGNET_TMP_ROOT/tmpg/clean_Genotype.map

cd $SIGNET_TMP_ROOT/tmpg

echo -e "Split the genotype data by chromosomes \n"

# Split the .map file by chromosome
for i in `seq 1 ${nchr}`
do
echo $i
awk '/^'"$i"'\t/ {print $0}' $map > $SIGNET_TMP_ROOT/tmpg/clean_Genotype_chr$i.map
done

# Create the file "clean_Genotype.sizes":
for i in `seq 1 ${nchr}`
do
echo -n "$i "
n=`wc -l $SIGNET_TMP_ROOT/tmpg/clean_Genotype_chr$i.map | awk '{print $1}'`
echo "$n"
done > $SIGNET_TMP_ROOT/tmpg/clean_Genotype.sizes


cut -d " " -f1-6 $ped > $SIGNET_TMP_ROOT/tmpg/clean_Genotype.fam
cut -d " "  -f 7- $ped > $SIGNET_TMP_ROOT/tmpg/temp && mv $SIGNET_TMP_ROOT/tmpg/temp $SIGNET_TMP_ROOT/tmpg/clean_Genotype_nofam.ped


# Split the .ped file:
$SIGNET_SCRIPT_ROOT/geno_prep/splitchr_ped.pl $SIGNET_TMP_ROOT/tmpg/clean_Genotype_nofam.ped $SIGNET_TMP_ROOT/tmpg/clean_Genotype.sizes $nchr &&

##Add family info  
for i in `seq 1 ${nchr}`
do 
    paste -d ' ' $SIGNET_TMP_ROOT/tmpg/clean_Genotype.fam $SIGNET_TMP_ROOT/tmpg/clean_Genotype_nofam_chr$i.ped  > $SIGNET_TMP_ROOT/tmpg/clean_Genotype_chr$i.ped
done

##begin to impute
echo -e "\n"
echo -e "Begin to impute the genotype data using impute2 \n"


for i in `seq 1 ${nchr}`
do
plink --silent --file 'clean_Genotype_chr'$i --recode oxford --out $i
done

[ -e impute_params.txt ] && rm impute_params.txt
rm -f impute_params.txt.completed


##make a dummy file to exclude untyped SNP
echo 0 > empty


## begin to impute 
for i in `seq 1 ${nchr}`
do 
  START=$(head -n 1 'clean_Genotype_chr'$i'.map' | cut -f 4)
  END=$(tail -n 1 'clean_Genotype_chr'$i'.map' | cut -f 4)
  NUMJOBS=$(( (END - START) / 5000000))
  for j in $( seq 1 $NUMJOBS )
  do
     A=`expr $j \* 5000000 - 4999999 + $START - 1`
     B=`expr $j \* 5000000 + $START - 1`
     echo 'impute2 -pgs_miss -g '$i'.gen -g_ref '$ref''$i'.gen -m '$gmap''$i'.map -include_snps empty -int '$A' '$B' -Ne 20000 -o impute/impute_chr'$i'chunk'$j >> impute_params.txt
  done
  LEFTOVER=$(( (5000000*NUMJOBS) + $START))
  CHUNK=$((NUMJOBS+1))
  echo 'impute2 -pgs_miss -g '$i'.gen -g_ref '$ref''$i'.gen -m '$gmap''$i'.map -include_snps empty -int '$LEFTOVER' '$END' -Ne 20000 -o impute/impute_chr'$i'chunk'$CHUNK >> impute_params.txt
done

## employ parallel computing for imputation 
time ParaFly -c impute_params.txt -CPU $ncores
