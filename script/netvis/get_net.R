suppressMessages(library(igraph))
suppressMessages(library(dnet))
suppressMessages(library(visNetwork))
suppressMessages(library(STRINGdb))
suppressMessages(library(TFutils))
suppressMessages(library(shiny))

args <- commandArgs(TRUE)
eval(parse(text=args))

get_net <- function(edgelist, high_freq=F, largest=F, top=NULL, search=NULL, score=400, name=NULL, interactive=T){
  ##If high_freq=T, it will return the network induced by the node with largest frequency
  ##If largest=T, it will return the largest component with plot
  ##If largest=F, it will return exclusive subnetworks in the network
  ##If largest=F, top can be used to write top network nodes names to files
  ##If search!=NULL, It can search the network expanded by a gene beining with string search
  ##construct rings
  ##source edge and target edge
  ##name argument is used to construct names of the input nodes
  ##If interactive=T, use interactive plot
  ##score is the score_threshold for string database, with default 400
  
  ##make graph
  bs_ring <- edgelist[, c("source_gene_symbol", "target_gene_symbol")]
  bs_ring <- as.matrix(bs_ring)
  
  ## Take the coefficient as the weight for edges 
  ## E(net_bs)$coef to check coefficients
  ## Incorporate STRINGdb
  string_db <- STRINGdb$new(version="11", species=9606, input_directory="", score_threshold=score)
  string_proteins <- string_db$get_proteins()
  
  ##set coefficient, degree, and weight for later usage
  net_bs <- graph_from_edgelist(bs_ring) %>% set_edge_attr("coef", value=edgelist[, "coefficient"]) %>%
    set_vertex_attr("degree", value=degree(.)) %>% set_edge_attr("weight", value=1)
  
  nodes_bs <- V(net_bs)$name
  annotation <- string_proteins[match(nodes_bs, string_proteins[, 2]), 4]  
  annotation[is.na(annotation)] <- "Not identified in database"
  
  net_bs <- net_bs %>% set_vertex_attr("annotation", value=annotation)
  
  if(1-is.null(name)){
    filename <- paste(name,"_name.txt", sep="")
    write.table(nodes_bs, filename, row.names = F, col.names = F, quote = F)
  }
  
  ##construct components
  g_bs <- dNetInduce(net_bs, nodes_query = nodes_bs, knn=1, largest.comp = F)
  
  if(high_freq==T){
    node_high <- names(which.max(table(bs_ring)))[1]
    g_high <- dNetInduce(net_bs, nodes_query = node_high, knn=1)
    visNet(g_high)
  }else{
    if(largest==F){
      ##extract a unique nodes in each of the subnetwork and store the name for each components
      unodes_idx <- NULL
      name_bs_sub <- NULL
      
      comp <- V(g_bs)$comp
      
      for(i in 1:length(unique(comp))){
        unodes_idx <- c(unodes_idx, which(comp==i)[1])
        name_bs_sub[[i]] <- V(g_bs)[which(comp==i)]$name
      }
      unodes <- V(g_bs)[unodes_idx]$name
      
      ##store the subnetworks
      g_bs_sub <- NULL 
      
      ##search for a particular gene
      if(1-is.null(search)){
        l <- length(name_bs_sub)
        namespace <- NULL
        comp_idx <- NULL
        for(i in 1:l){
          for(j in 1:length(name_bs_sub[[i]])){
            if(startsWith(name_bs_sub[[i]][j], search))
            {
              namespace <- c(namespace, name_bs_sub[[i]][j])
              comp_idx <- c(comp_idx, i)
            }
          }
        }
        
        if(is.null(namespace)){
          print("no serach record!")
        }
        else{
          len <- length(comp_idx)
          g_search <- NULL
          for(i in 1:len){
            g_search[[i]] <- dNetInduce(net_bs, nodes_query = name_bs_sub[[comp_idx[i]]], knn=1)
            ##   visNet(g_search[[i]])
          }
          return(g_search)
        }
      }else{
        comp_len <- NULL
        for(i in 1:length(unodes)){
          g_bs_sub[[i]] <- dNetInduce(g=net_bs, nodes_query = name_bs_sub[[i]], knn=1, largest.comp = F)
          comp_len <- c(comp_len, length(E(g_bs_sub[[i]])))
        }
        if(is.null(top)){
          return(g_bs_sub)
        }else{
          g_top <- NULL
          g_top_int <-NULL
          g_top_e <- NULL
          vis_g_top <- NULL
          dot <- NULL
          top_idx <- order(comp_len, decreasing = T)[1:top]
          for(i in 1:top){
            cat(paste0("Generating results for network ", i, "\n"))
            if(1-is.null(name)){
              filename <- paste("top", i, "_", name, "_name.txt", sep="")
              write.table(name_bs_sub[[top_idx[i]]], filename, row.names = F, col.names = F, quote = F)
              g_top[[i]] <- dNetInduce(net_bs, nodes_query = name_bs_sub[[top_idx[i]]], knn=1)
              g_top_int[[i]] <- toVisNetworkData(g_top[[i]])
              ## Construct edgelist
              g_top_e[[i]] <- as_edgelist(g_top[[i]])
              ## Construct dot language 
              #dot[[i]] <- paste("dinetwork{", paste(paste(g_top_e[[i]][, 1], g_top_e[[i]][, 2], sep="->"), collapse="; "), "}")
              #vis_g_top[[i]] <- visNetwork(dot = as.character(dot[[i]]), width="100%", height="1000px")
            
              ## Transcription factor
              tf <- unique(TFutils::cisbpTFcat_2.0$TF_Name)
              
              ##Write basics for node and edge, use circle for down regulation
              nodes <- data.frame(
                id = V(g_top[[i]])$name,
                label = V(g_top[[i]])$name,
                value = V(g_top[[i]])$degree,
                title = V(g_top[[i]])$annotation,
                group = ifelse(is.na(match(V(g_top[[i]])$name, tf)), 1, 2)
              )
              edges <- data.frame(
                from = g_top_e[[i]][, 1],
                to = g_top_e[[i]][, 2],
                #color = "black",
                arrows.to.type = ifelse(E(g_top[[i]])$coef>0, "arrow", "circle")
              )
              
              ##modularity clustering 
              net_simp <- simplify(g_top[[i]], edge.attr.comb=list(weight="sum"))
              net_undir <- as.undirected(net_simp, mode="collapse", edge.attr.comb=list(weight="sum"))
              c <- cluster_fast_greedy(net_undir, weights=E(net_undir)$weight)
              nodes$modularity <- membership(c)
            
              # ##STRING PPI 
              mapped <- string_db$map(data.frame(gene=V(g_top[[i]])$name), "gene", removeUnmappedRows = T)
              mapped_id <- mapped$STRING_id
              # ## map edge to string id 
              # string_e <- g_top_e[[i]]
              # string_e[, 1] <- mapped[match(string_e[, 1], mapped[, "gene"]), "STRING_id"]
              # string_e[, 2] <- mapped[match(string_e[, 2], mapped[, "gene"]), "STRING_id"]
              # string_e <- cbind(string_e, "Under 400")
              # colnames(string_e) <- c("from", "to", "combined_score")
              # ppi <- string_db$get_interactions(mapped_id)
              # comb <- rbind(as.data.frame(string_e), ppi[!duplicated(ppi), ])
              # edgesg400 <- comb[duplicated(comb[, c(1, 2)]), ]
              
              
              ##STRING enrichment 
              p_ppi <- string_db$get_ppi_enrichment(mapped_id)$enrichment
              enrich <- string_db$get_enrichment(mapped_id)
              
              ##sort by p value 
              enrichment <- enrich[order(enrich$p_value), ][1:min(10, nrow(enrich)), ]
              
              ## Change the first letter to uppercase 
              enrichment$description <- paste(toupper(substr(enrichment$description, 1, 1)), substr(enrichment$description, 2, nchar(enrichment$description)), sep="")
              
              ## Replace ", and" with "; ", and ", " with "and". Otherwise, it would mix with the group seperator
              enrichment$description <- gsub(", and", "; ", enrichment$description)
              enrichment$description <- gsub(", ", " and ", enrichment$description)
              
              node_enrich <- character(length=length(V(g_top[[i]])$name))
              for(j in 1:nrow(enrichment)){
                ##name list in i th category
                gene_enrich <- as.matrix(unlist(strsplit(enrichment[j, "inputGenes"], split=",")))
                idx <- match(mapped[match(gene_enrich, mapped[, 2]), 1], V(g_top[[i]])$name)
                node_enrich[idx] <- paste(node_enrich[idx], enrichment[j, "description"], " (p val = ", enrichment[j, "p_value"],"),", sep="")
              }
              node_enrich <- gsub(",$", "", node_enrich)
              nodes$enrichment <- node_enrich
              
              ##add hover interaction https://www.rdocumentation.org/packages/visNetwork/versions/2.0.9/topics/visEvents
              vis_g_top[[i]] <- visNetwork(nodes, edges, width="100%", height="1000px") %>% 
              visOptions(selectedBy = list(variable = "enrichment", multiple=T), 
                         highlightNearest = list(enabled = T, degree = 2, hover = T))
              
              if(interactive==F){
                visNet(g_top[[i]])
              }else{
                visSave(vis_g_top[[i]], paste("top", i, "_", name, ".html", sep=""), selfcontained=F)
              }
              
              
            }
          }
        } 
      }
      ##largest=F ends
    }else{
      ##if(largest=T)
      g_bs_largest <- dNetInduce(net_bs, nodes_query = nodes_bs, knn=1)
      nodes_largest <- V(g_bs_largest)$name
      if(1-is.null(name)){
        filename <- paste(name,"_largest_name.txt", sep="")
        write.table(nodes_largest, filename, row.names = F, col.names = F, quote = F)
      }
      visNet(g_bs_largest)
    }
 
    ##else high frequency ends
  }
  
  
}


setwd(paste0(Sys.getenv("SIGNET_RESULT_ROOT"), "/resv"))
edgelist <- read.table(paste0('edgelist_',freq), header=T)
get_net(edgelist, name=paste0("freq_",freq), top=ntop)

