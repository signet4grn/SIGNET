usage() {
    echo "Usage:"
    echo "  gexp-prep [-g GEXP_FILE] [-p GPOS_FILE]"
    echo -e "\n"
    echo "Description:"
    echo "    -g, set gene expression file"
    echo "    -p, set position file for genes"
    exit -1
}

gexpfile=$($SIGNET_SCRIPT_ROOT/config_controller.sh -l gexp,gexp.file);
gposfile=$($SIGNET_SCRIPT_ROOT/config_controller.sh -l gexp,gpos.file);

while [["$#" -gt 0 ]];
do
   case "${option}"  in
	        g) gexpfile=${OPTARG};;
                p) gposfile=${OPTARG};;
                h) usage;;
	        ?) usage;;
   esac

done

##Directly modify the files in the parameter files
$SIGNET_SCRIPT_ROOT/config_controller.sh -m gexp,gexp.file $gexpfile
$SIGNET_SCRIPT_ROOT/config_controller.sh -m gexp,gpos.file $gposfile

echo "gexp.file: "$gexpfile
echo "gpos.file: "$gposfile

cd ./gexp-prep
./gexp-prep.sh

echo "Gene Expression Preprocessing Finished"
