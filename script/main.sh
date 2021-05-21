#!/bin/bash


#!/bin/bash
export APP_PATH=/usr/local/SmartDataStack
operate=${1}
#echo "${0}"
APP_NAME="sds"

options=""
for((i=2;i<=$#;i++)); do 
    j=${!i}
    options="${options} $j "
done


geno_prep(){
	./geno_prep_portal.sh ${options};
}

gexp_prep(){
	./gexp_prep_portal.sh ${options};
}


config(){
    ./config_controller.sh ${options};
}

network(){
	./network_portal.sh ${options};
}

cis_eqtl(){
	./cis_portal.sh ${options};
}
netvis(){
	./netvis_portal.sh ${options};
}
match(){
	./match_portal.sh ${options};
}
echo -e ""


case "$operate" in
    geno-prep)
        geno_prep ;;
    gexp-prep)
        gexp_prep;;
    network)
        network;;
    cis-eqtl)
        cis_eqtl;;
    config)
	config
	;;
    netvis)
	netvis;;
    match)
	match;;
    *)
        echo -e "Usage params: geno-prep|gexp-prep|network|cis-eqtl|config|netvis|match"
        ;;
esac        

echo -e ""

exit 0
