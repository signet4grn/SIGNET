usage() {
    echo "Usage:"
    echo "  gexp-prep [-g GEXP_FILE] [-p GPOS_FILE]"
    echo "Description:"
    echo "    -g, set gene expression file"
    echo "    -p, set position file for genes"
    exit -1
}

gexpfile=$(./config_controller.sh -l gexp,gexp.file);
gposfile=$(./config_controller.sh -l gexp,gpos.file);

while getopts g:p:h:? option
do
   case "${option}"  in
                g) gexpfile=${OPTARG};;
                p) gposfile=${OPTARG};;
                h) usage;;
                ?) usage;;
   esac

done

##Directly modify the files in the parameter files
./config_controller.sh -m gexp,gexp.file $gexpfile
./config_controller.sh -m gexp,gpos.file $gposfile

echo "gexp.file: "$gexpfile
echo "gpos.file: "$gposfile

cd ./gexp-prep
./gexp-prep.sh

echo "Gene Expression Preprocessing Finished"
