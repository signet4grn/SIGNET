#!/bin/bash

cd $SIGNET_RESULT_ROOT/resn

echo -e "Extracting edges...\n"

Rscript $SIGNET_SCRIPT_ROOT/netvis/extract_edges.R "freq='$freq'" &&
Rscript -e 'shiny::runApp("paste0(Sys.getenv("SIGNET_SCRIPT_ROOT"), "/netvis/netshiny.R"), launch.browser = TRUE)' &&

echo -e "Genes for top "$ntop" networks has been returned to the folder" &&
echo -e "You can check the summary in shiny dashboard using web browser or the visualizing result end with .html in the resv foldern"
