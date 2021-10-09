reads=$1
tpm=$2
gtf=$3
tissue=$($SIGNET_ROOT/signet -s --tissue | sed -r '/^\s*$/d')
anno=$($SIGNET_ROOT/signet -s --anno | sed -r '/^\s*$/d')


cd $SIGNET_TMP_ROOT/tmpt

cp $SIGNET_TMP_ROOT/tmpg/subjid_wb_common.txt subjid_wb_common.txt

awk '{print $2}' $reads | tail -n+4 > GTEx_genename

echo -e "Looking for the samples for $tissue tissue \n"

Rscript $SIGNET_SCRIPT_ROOT/gexp_prep/gexp_prep_gtex.R "reads='$reads'" "tpm='$tpm'" "tissue='$tissue'" "anno='$anno'" &&

tabix --list-chroms $SIGNET_TMP_ROOT/tmpg/GTEx_snp.vcf.gz > vcf_chr_list

echo -e "Begin normalizing \n"

$SIGNET_SCRIPT_ROOT/gexp_prep/eqtl_prepare_expression_withoutigt.py $tpm \
	$reads \
        $gtf \
	lookup_sample_subject_tissue.txt \
	vcf_chr_list \
	expression_normalized_withoutigt_GTEx_lung \
	--legacy_mode \
	--sample_id_list sample_ids_tissue.txt


echo -e "Normalizing finished \n"

