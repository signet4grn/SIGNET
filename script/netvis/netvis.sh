#!/bin/bash

cd $SIGNET_RESULT_ROOT/resv

echo -e "Extracting directed regulations...\n"
Rscript $SIGNET_SCRIPT_ROOT/netvis/extract_edges.R &&

echo -e "Loading results into Shiny app...\n"
Rscript $SIGNET_SCRIPT_ROOT/netvis/netshiny.R &&
#Rscript -e 'shiny::runApp(paste0(Sys.getenv("SIGNET_SCRIPT_ROOT"), "/netvis/netshiny.R"), launch.browser = TRUE)' &&

echo -e "Genes for top "$ntop" networks has been returned to the folder" &&
echo -e "You can check the summary in Shiny dashboard with web browser or the visualizing results in .html files inside folder resv\n"
