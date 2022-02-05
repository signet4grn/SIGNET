cat("loading result for sub-networks ...\n")

vis_g_top <- g_top <- g_top_int <- g_top_e <- nodes <- edges <- enrichment <- NULL

if(ntop > length(comp_len)) stop(paste0("Please make ntop less than ", length(comp_len))) 

top_idx <- order(comp_len, decreasing = T)[1:ntop]

## Transcription factor
if(Sys.getenv("id")==9606){
tf <- unique(TFutils::cisbpTFcat_2.0$TF_Name)
}else{
tf <- as.matrix(read.table(Sys.getenv("tf")))
}
cat("Trying hard to summarize the results, this process could take a while if you have many subnetworks ... \n")

for(i in 1:ntop){
cat(paste0("Generating results for network ", i, "\n"))
filename <- paste0(Sys.getenv("resv"), "_top", i ,"_", name, "_name.txt")
write.table(name_bs_sub[[top_idx[i]]], filename, row.names = F, col.names = F, quote = F)
g_top[[i]] <- dNetInduce(net_bs, nodes_query = name_bs_sub[[top_idx[i]]], knn=0)
g_top_int[[i]] <- toVisNetworkData(g_top[[i]])
## Construct edgelist
g_top_e[[i]] <- as_edgelist(g_top[[i]])

## Construct dot language 
#dot[[i]] <- paste("dinetwork{", paste(paste(g_top_e[[i]][, 1], g_top_e[[i]][, 2], sep="->"), collapse="; "), "}")

## Summarize for each node

##Write basics for node and edge, use circle for down regulation
nodes[[i]] <- data.frame(
  id = V(g_top[[i]])$name,
  label = V(g_top[[i]])$name,
  value = V(g_top[[i]])$degree,
  title = V(g_top[[i]])$annotation,
  group = ifelse(is.na(match(V(g_top[[i]])$name, tf)), "non-TF", "TF")
)
edges[[i]] <- data.frame(
  from = g_top_e[[i]][, 1],
  to = g_top_e[[i]][, 2],
  #color = "black",
  arrows.to.type = ifelse(E(g_top[[i]])$coef>0, "arrow", "circle")
)

##modularity clustering 
net_simp <- simplify(g_top[[i]], edge.attr.comb=list(weight="sum"))
net_undir <- as.undirected(net_simp, mode="collapse", edge.attr.comb=list(weight="sum"))
c <- cluster_fast_greedy(net_undir, weights=E(net_undir)$weight)
nodes[[i]]$modularity <- as.character(membership(c))

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
# p_ppi <- string_db$get_ppi_enrichment(mapped_id)$enrichment
## An error would occur where too many genes are consulted at the same time
tryCatch(enrich <- string_db$get_enrichment(mapped_id), error = function(e) print("You may have too many input genes"))


##sort by p value 
nrow_max_enrich <- 15
enrichment[[i]] <- enrich[order(enrich$p_value), ][1:min(nrow_max_enrich, nrow(enrich)), ]

## Change the first letter to uppercase 
enrichment[[i]]$description <- paste(toupper(substr(enrichment[[i]]$description, 1, 1)), substr(enrichment[[i]]$description, 2, nchar(enrichment[[i]]$description)), sep="")

## Replace ", and" with "; ", and ", " with "and". Otherwise, it would mix with the group seperator
enrichment[[i]]$description <- gsub(", and", "; ", enrichment[[i]]$description)
enrichment[[i]]$description <- gsub(", ", " and ", enrichment[[i]]$description)


node_enrich <- character(length=length(V(g_top[[i]])$name))

## Get information for each node
for(j in 1:nrow(enrichment[[i]])){
  ##name list in i th category
  gene_enrich <- as.matrix(unlist(strsplit(enrichment[[i]][j, "inputGenes"], split=",")))
  idx <- match(toupper(mapped[match(gene_enrich, mapped[, 2]), 1]), toupper(V(g_top[[i]])$name))
  node_enrich[idx] <- paste(node_enrich[idx], enrichment[[i]][j, "description"], " (p val = ", enrichment[[i]][j, "p_value"],"),", sep="")
}
node_enrich <- gsub(",$", "", node_enrich)
nodes[[i]]$enrichment <- node_enrich

## sort enrichment by p value
enrichment[[i]] <- as.data.frame(enrichment[[i]])
enrichment[[i]]$description <- factor(enrichment[[i]]$description, levels = unique(enrichment[[i]]$description)[order(enrichment[[i]]$p_value)])

# save html version
vis_g_top[[i]] <- visNetwork(nodes[[i]], edges[[i]], width="100%", height="1000px") %>%
  visOptions(selectedBy = list(variable = "enrichment", multiple=T),
             highlightNearest = list(enabled = T, degree = 2, hover = T)) %>%
  visLayout(randomSeed=1) %>%
  visEdges(arrows = 'to')
visSave(vis_g_top[[i]], paste(Sys.getenv("resv"), "_top", i, "_", name, ".html", sep=""), selfcontained=F) 

## end information 
}

