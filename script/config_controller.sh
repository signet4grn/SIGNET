usage() {
    echo "Usage:"
    echo "signet -s [--PARAM] [PARAM VAL]"
    echo -e "\n"
    echo "Description:"
    echo "    --PARAM                                      list the value of parameter PARAM"
    echo "    --PARAM [PARAM VAL]      modify the value of parameter PARAM to be [PARAM VAL]"
    exit -1
}

# get parameter
get_param (){
        local args=$1	
	local param=${args/--/}
	local val=$(sed -nr '/^'${param}'[ ]*=/ { s/.*=[ ]*//; p; q;};' "$SIGNET_ROOT/config.ini")

	if [[ -z $val ]];then	
        echo "Please check the file name";else
    	echo $val;
        fi
}

# set parameter
set_param(){
    local args=$1;
     
    if [[ $args == "--d" ]];then
    scp $SIGNET_DATA_ROOT/config.ini.default $SIGNET_ROOT/config.ini    
    echo "Set all the parameters to default"
    exit
    elif [[ $args == --* ]];then
    local param=(${args/--/});else
    usage
    exit 1
    fi 
    local val=$2;

    if [[ -z $val ]]; then
    get_param $args; else
    local cmd=$(echo 's@^'${param}'[ ]*=.*@'${param} '=' ${val}'@')
    sed -i "${cmd}" "$SIGNET_ROOT/config.ini"
    echo  "Modification applied to ${param}"
    fi
}

if [[ -z $1 ]];then
cat $SIGNET_ROOT/config.ini;else
set_param $1 $2
fi
