# The function takes info information and output 
# din, dout, source_bed, target_bed
cat("Loading results for circular plot...\n")

info <- din <- dout <- source_bed <- target_bed <- circ_col <- NULL

for(i in 1:ntop){ 
  info[[i]] <- as.data.frame(get.edge.attribute(g_top[[i]]), check.names = F)  
  
  ## The bed file for source and target genes in the order of edgelist
  source_bed[[i]] <- info[[i]][, c("source chr", "source start", "source end")]
  target_bed[[i]] <- info[[i]][, c("target chr", "target start", "target end")]
  source_bed[[i]]$"source chr" <- paste0("chr", source_bed[[i]]$"source chr")
  target_bed[[i]]$"target chr" <- paste0("chr", target_bed[[i]]$"target chr")
  
  colnames(source_bed[[i]]) <- colnames(target_bed[[i]]) <- c("chr", "start", "end")
  
  source_gene <- as.matrix(info[[i]]$`source gene`)
  target_gene <- as.matrix(info[[i]]$`target gene`)
  v_name <- as.matrix(V(g_top[[i]])$name)
  
  ##data for tracks  
  source_in <- cbind(source_bed[[i]], V(g_top[[i]])$in_degree[match(source_gene, v_name)])
  target_in <- cbind(target_bed[[i]], V(g_top[[i]])$in_degree[match(target_gene, v_name)])
  colnames(source_in)[4] <- colnames(target_in)[4] <- "value"
  din[[i]] <- rbind(source_in, target_in)
  source_out <- cbind(source_bed[[i]], V(g_top[[i]])$out_degree[match(source_gene, v_name)])
  target_out <- cbind(target_bed[[i]], V(g_top[[i]])$out_degree[match(target_gene, v_name)])
  colnames(source_out)[4] <- colnames(target_out)[4] <- "value"
  dout[[i]] <- rbind(source_out, target_out)
  
  din[[i]][, 4]  <- as.integer(din[[i]][, 4])
  dout[[i]][, 4]  <- as.integer(dout[[i]][, 4])
  din[[i]] <- unique(din[[i]])
  dout[[i]] <- unique(dout[[i]])
  din[[i]] <- din[[i]][din[[i]][, 4]>0, ]
  dout[[i]] <- dout[[i]][dout[[i]][, 4]>0, ]

  circ_col[[i]] <- ifelse(info[[i]]$coef>0, "green", "red")  
}
