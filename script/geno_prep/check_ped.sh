if [ ! -f $SIGNET_TMP_ROOT/tmpg/clean_Genotype.ped ]
then
        echo -e "\nNo SNP listed in your chromosome input, program will stop now ... \n"
        kill -10 $job_id
        exit -1
fi
