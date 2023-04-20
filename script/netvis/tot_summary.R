edgelist <- read.table(paste0(Sys.getenv("resv"), "_edgelist_", freq, ".txt"), sep=",", header=T)
# remove "chr"
edgelist$'source_chr' <- substring(edgelist$'source_chr', 4)
edgelist$'target_chr' <- substring(edgelist$'target_chr', 4)

bs_ring <- edgelist[, c("source_gene_symbol", "target_gene_symbol")]
bs_ring <- as.matrix(bs_ring)


## Take the coefficient as the weight for edges
## E(net_bs)$coef to check coefficients

##set coefficient, degree, weight and position for later usage
net_bs <- graph_from_edgelist(bs_ring) %>%
  set_vertex_attr("degree", value=igraph::degree(.)) %>%
  set_vertex_attr("in_degree", value=igraph::degree(., mode="in")) %>%
  set_vertex_attr("out_degree", value=igraph::degree(., mode="out")) %>%
  set_edge_attr("source gene", value=edgelist$source_gene_symbol) %>%
  set_edge_attr("source chr", value=edgelist$source_chr) %>%
  set_edge_attr("source start", value=edgelist$source_start) %>%
  set_edge_attr("source end", value=edgelist$source_end) %>%
  set_edge_attr("target gene", value=edgelist$target_gene_symbol) %>%
  set_edge_attr("target chr", value=edgelist$target_chr) %>%
  set_edge_attr("target start", value=edgelist$target_start) %>%
  set_edge_attr("target end", value=edgelist$target_end) %>%
  set_edge_attr("coef", value=edgelist$coefficient) %>%
  set_edge_attr("weight", value=1) %>%
  set_edge_attr("freq", value=edgelist$freq)

## node annotation
nodes_bs <- V(net_bs)$name
annotation <- string_proteins[match(nodes_bs, string_proteins[, "preferred_name"]), "annotation"]
annotation[is.na(annotation)] <- "Not identified in database"
net_bs <- net_bs %>% set_vertex_attr("annotation", value=annotation)

## convert edge to string id
bs_ring_string <- bs_ring
bs_ring_string[, 1] <- string_proteins[match(bs_ring[, 1], string_proteins[, "preferred_name"]), "protein_external_id"]
bs_ring_string[, 2] <- string_proteins[match(bs_ring[, 2], string_proteins[, "preferred_name"]), "protein_external_id"]
bs_ring_string <- bs_ring_string[complete.cases(bs_ring_string), ]

bs_ppi <- apply(bs_ring_string, 1, string_db$get_interactions)
if(!exists("bs_ppi")) bs_ppi <- apply(bs_ring_string, 1, string_db$get_interactions)

bs_ppi <- do.call(rbind, bs_ppi)
if(nrow(bs_ppi)==0) stop("No gene is found in the database\n")
unique_bs_ppi <- unique(bs_ppi)
unique_bs_ppi_oriname <- unique_bs_ppi
unique_bs_ppi_oriname[, 1] <- string_proteins[match(unique_bs_ppi[, 1], string_proteins[, "protein_external_id"]), "preferred_name"]
unique_bs_ppi_oriname[, 2] <- string_proteins[match(unique_bs_ppi[, 2], string_proteins[, "protein_external_id"]), "preferred_name"]
ppi_sort <- unique_bs_ppi_oriname[order(unique_bs_ppi_oriname$combined_score, decreasing = T), ]
names(ppi_sort) <- c("Protein 1", "Protein 2", "Combined Score")
ppi_sort <- as.data.frame(ppi_sort)

# write the names for all the nodes
filename <- paste(Sys.getenv("resv"), "_", name, "_name.txt", sep="")
write.table(nodes_bs, filename, row.names = F, col.names = F, quote = F)

##construct components
g_bs <- dNetInduce(net_bs, nodes_query = nodes_bs, knn=1, largest.comp = F)

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

## record the component length for each components
comp_len <- NULL
for(i in 1:length(unodes)){
  g_bs_sub[[i]] <- dNetInduce(g=net_bs, nodes_query = name_bs_sub[[i]], knn=0, largest.comp = F)
  comp_len <- c(comp_len, length(E(g_bs_sub[[i]])))
}


## Summary statistics for the whole network
net_number <- length(unique(comp))
vertex_number  <- length(V(g_bs))
edge_number <- length(E(g_bs))

cat(paste('There are a total of ', net_number, ' subnetworks with ', vertex_number, " genes and ", edge_number, " regulatory relationships \n"))

gc()
