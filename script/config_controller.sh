usage() {

    echo "Usage:"
    echo " config  [-l SECTION,PARAM] [-m SECTION,PARAM VAL]"
    echo "Description:"
    echo "    -l | --list [SECTION,]PARAM		list config"
    echo "    -m | --modify [SECTION,]PARAM VAL	modify config"
    echo "    -h | --help				usage help"
    exit -1
}

# get parameter
get_param (){ 
    local args=$1;
    local params=(${args//,/ }) 
    if [ ${#params[@]} = 1 ]; then
	local param=${params[0]}
	local val=$(sed -nr '/^'${param}'[ ]*=/ { s/.*=[ ]*//; p; q;};' ../config.ini);
    	echo $val;
    elif [ ${#params[@]} = 2 ]; then
	local section=${params[0]}
	local param=${params[1]}
    	local val=$(sed -nr '/^\['${section}'\]/ { :l /^'${param}'[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}' ../config.ini);
    	echo $val;
    fi
}

# set parameter
set_param(){
    local args=$1;
    local params=(${args//,/ }) 
    local val=$2;
    if [ ${#params[@]} = 1 ]; then
	local param=${params[0]}
	local cmd =$(echo '/^\[/ s/^'${param}'[ ]*=.*/'${param} '=' ${val}'/');
	sed -i "${cmd}" ../config.ini;
    elif [ ${#params[@]} = 2 ]; then
	local section=${params[0]}
	local param=${params[1]}
    	local cmd=$(echo '/^\['${section}'\]$/,/^\[/ s/^'${param}'[ ]*=.*/'${param} '=' ${val}'/');
    	sed -i "${cmd}" ../config.ini
    fi
    #local section=$1;
    #local param=$2;
    #local val=$3;
    #local cmd=$(echo '/^\['${section}'\]$/,/^\[/ s/^'${param}'[ ]*=.*/'${param} '=' ${val}'/');
    #sed -i "${cmd}" ./settings.ini
}

case "$1" in
    -l | --list)   get_param   $2 $3;;
    -m | --modify)    set_param   $2 $3 $4;;
    -h | --help)  usage;;
    *)	usage;;

esac
    




