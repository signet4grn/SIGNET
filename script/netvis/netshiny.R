# Please ensure your network is stable since it would make use of online database 
suppressMessages(library(igraph))
suppressMessages(library(dnet))
suppressMessages(library(visNetwork))
suppressMessages(library(STRINGdb))
suppressMessages(library(TFutils))
suppressMessages(library(shiny))
suppressMessages(library(shinyfullscreen))
suppressMessages(library(shinycustomloader))
suppressMessages(library(shinydashboard))
suppressMessages(library(plotly))
suppressMessages(library(DT))
suppressMessages(library(circlize))

project_path = paste0(Sys.getenv("SIGNET_SCRIPT_ROOT"), "/netvis")
freq <- as.numeric(Sys.getenv("freq"))

#input 
name <- paste0("freq", freq)
ntop <- as.numeric(Sys.getenv("ntop"))

## E(net_bs)$coef to check coefficients
## Incorporate STRINGdb
string_db <- STRINGdb$new(version="11.5", species=as.numeric(Sys.getenv("id")), input_directory="")
#string_db_graph <- string_db$get_graph()
#string_score <- E(string_db_graph)$combined_score
string_proteins <- string_db$get_proteins()

source(paste0(project_path, "/tot_summary.R"))   # summarize total
source(paste0(project_path, "/ui.R"))     
source(paste0(project_path, "/sub_summary.R"))   # summarize subnetwork
source(paste0(project_path, "/circular.R"))      # summarize circular plot
source(paste0(project_path, "/server.R"))

shinyApp(ui = ui, server = server, options=list(launch.browser=T))

