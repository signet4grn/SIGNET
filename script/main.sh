#!/bin/bash

operate=${1}
#echo "${0}"

options=""
for((i=2;i<=$#;i++)); do 
    j=${!i}
    options="${options} $j "
done

#Set directories
cd $(dirname $0)

SIGNET_ROOT=$(/bin/pwd)
SIGNET_DATA_ROOT="$SIGNET_ROOT/data"
SIGNET_TMP_ROOT="$SIGNET_ROOT/tmp"
SIGNET_RESULT_ROOT="$SIGNET_ROOT/res"
SIGNET_SCRIPT_ROOT="$SIGNET_ROOT/script"
echo -n The directory that stores data is:
echo $SIGNET_DATA_ROOT
echo -n The directory that stores the temporary files is:
echo $SIGNET_TMP_ROOT
echo -n The directory that stores the results is:
echo $SIGNET_RESULT_ROOT
echo -n The directory that stores the scripts is:
echo $SIGNET_SCRIPT_ROOT
export SIGNET_ROOT=$SIGNET_ROOT
export SIGNET_DATA_ROOT=$SIGNET_DATA_ROOT
export SIGNET_TMP_ROOT=$SIGNET_TMP_ROOT
export SIGNET_RESULT_ROOT=$SIGNET_RESULT_ROOT
export SIGNET_SCRIPT_ROOT=$SIGNET_SCRIPT_ROOT


cd script

./config_controller.sh -m basic,root $SIGNET_ROOT
./config_controller.sh -m basic,data_root $SIGNET_DATA_ROOT
./config_controller.sh -m basic,tmp_root $SIGNET_TMP_ROOT
./config_controller.sh -m basic,script_root $SIGNET_SCRIPT_ROOT

cd ..

geno_prep(){
	$SINET_SCRIPT_ROOT/geno_prep_portal.sh ${options};
}

gexp_prep(){
	$SIGNET_SCRIPT_ROOT/gexp_prep_portal.sh ${options};
}


config(){
    $SINET_SCRIPT_ROOT/config_controller.sh ${options};
}

network(){
	$SINET_SCRIPT_ROOT/network_portal.sh ${options};
}

cis_eqtl(){
	$SINET_SCRIPT_ROOT/cis_portal.sh ${options};
}
netvis(){
	$SINET_SCRIPT_ROOT/netvis_portal.sh ${options};
}
match(){
	$SINET_SCRIPT_ROOT/match_portal.sh ${options};
}
echo -e ""


case "$operate" in
    g)
        geno_prep ;;
    t)
        gexp_prep;;
    n)
        network;;
    c)
        cis_eqtl;;
    s)
	config
	;;
    v)
	netvis;;
    m)
	match;;
    *)
        echo -e "Usage params: g|t|n|c|s|v|m"
        ;;
esac        

echo -e ""

exit 0
