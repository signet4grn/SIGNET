if [ ! -f clean_Genotype.ped ]
then
        echo "No SNP listed in your chromosome, program will stop now ..."
        kill -10 $job_id
        exit -1
fi
done
