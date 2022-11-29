cat("Generating pathway histogram ... \n")

nrow_max_enrich <- 30
#color_enrich <- heat.colors(nrow_max_enrich, alpha=0.4)

enrich <- read.table(paste0(Sys.getenv("resv"), "_enrich_", cat, "_info_top", i, "_", name, ".txt"), sep="@", header=T)

if(nrow(enrich) < 5) {
 print("There is no enough pathways for histogram plot")
}else{

# remove Term
enrich$description <- apply(as.matrix(enrich$description), 1, function(x) unlist(strsplit(x, ","))[1])
enrich$description <- paste0(enrich$description, " (", enrich$number_of_genes, "/", enrich$number_of_genes_in_background, ")")
enrich$description <- factor(enrich$description, levels = unique(enrich$description)[order(enrich$p_value, decreasing = T)])
# add percentage of genes 

len <- length(enrich$p_value)

enrich_gene_grp <- paste0("Related genes: ", enrich$preferredNames)
#color_count <- nrow(enrich)

pdf(file=paste0(Sys.getenv("resv"), "_enrichment_hist_top", i, "_", name, ".pdf"), height = 8.3, width = 12.5)
#ggplot(enrich, aes(fill=color_enrich)) +
plot <- ggplot(enrich, aes(fill=-log10(p_value))) +
geom_bar(aes(x=description, y=-log10(p_value)), stat="identity") +
geom_text(aes(x=description, y=1, label=description), stat="identity", hjust=0, fontface="bold") +
coord_flip() + 
theme_classic() + 
theme(legend.position="none", text = element_text(size=40, face="bold"),
    # axis.text.x = element_blank(), 
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank()
    ) + 
labs(x="Process",
     y="-log10 p value") +
#scale_fill_manual(values=color_enrich)
scale_fill_gradient(low = "yellow", high = "red", na.value = NA)
print(plot)
dev.off()

}
