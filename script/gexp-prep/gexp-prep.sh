cd ../

gexpfile=$(./config_controller.sh -l gexp,gexp.file);
gposfile=$(./config_controller.sh -l gexp,gpos.file);

cd ../data/gexp-prep

Rscript ../../script/gexp-prep/gexp_prep.R "file='$gexpfile'"
Rscript ../../script/gexp-prep/gpos.R "file='$gposfile'"

