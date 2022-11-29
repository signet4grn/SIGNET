library(data.table)
library(ggplot2)

eps <- .Machine$double.eps

########################################################
### edge list with gene symbol
Afreq=as.matrix(read.table(Sys.getenv("Afreq"), sep=","))
#threlist=c(0.8,0.9,0.95)
genePOS <- read.table(Sys.getenv("genepos"))
genePOS=as.matrix(genePOS)
freq <- as.numeric(Sys.getenv("freq"))

Coeff=as.matrix(fread(Sys.getenv("coef")))

#for (thre in threlist){
  A=(Afreq > (freq-eps) )
    
  edgeidx=which(A!=0,arr.ind=T)
  target=genePOS[edgeidx[,1],]
  source=genePOS[edgeidx[,2],]
  
  edgefreq=Afreq[edgeidx]
  edgecoeff=Coeff[edgeidx]

  edgelist_genesymbol=cbind(source,target,edgefreq,edgecoeff) #Col 1-4 is source, Col 5-8 is target, Col 9 is frequency

  write.table(edgelist_genesymbol,paste0(Sys.getenv("resv"), "_edgelist_", freq, ".txt"),row.names=F,col.names=c("source_gene_symbol","source_chr","source_start","source_end","target_gene_symbol","target_chr","target_start","target_end","frequency","coefficient"),quote=F,sep=",")
#}

## Plot the summary 

cat("Generating summary plot ... \n")

node_sum <- NULL
edge_sum <- NULL
freq_sum <- NULL

freq <- c(0.8, 0.85, 0.9, 0.95, 1)#0.98, 0.99, 1)
for(freqi in freq){
  freq_count <- matrix(0, nrow(Afreq), ncol(Afreq))
  freq_count[Afreq > (freqi-eps) ] <- 1
  edge_count <- sum(freq_count)
  node <- which(freq_count!=0, arr.ind=T)
  node_count <- length(unique((c(node[, 1], node[, 2]))))
  cat(paste0("There are ", node_count, " genes and  ", edge_count, " connections in the network with bootstrap frequency at least ", freqi, "\n"))
  freq_sum <- c(freq_sum, freqi)
  edge_sum <- c(edge_sum, edge_count)
  node_sum <- c(node_sum, node_count)
  gc()
}

boot <- cbind(node_sum, edge_sum, freq_sum)
boot <- as.data.frame(boot)
boot$node_sum <- as.integer(boot$node_sum)
boot$edge_sum <- as.integer(boot$edge_sum)
colnames(boot) <- c("Number of nodes", "Number of edges", "Bootstrap frequency")

# plot 
bs_plot <- data.frame(count=c(boot[, 1], boot[, 2]), 
                      freq=rep(boot[, 3], 2), 
                      group=c(rep("node", length(boot[, 3])), 
                              rep("edge", length(boot[, 3]))),
                      idx=c(rep(1, length(boot[, 3])), 
                            rep(-1, length(boot[, 3])))
                      )
                      
pdf(file=paste0(Sys.getenv("resv"),"/count_vs_freq.pdf"), height=8.3, width=12.5)

ggplot(bs_plot, aes(x=freq, y=count, group=group, fill=group)) + 
  geom_col(position="dodge") +
  scale_y_continuous(labels=function(x) format(x, big.mark = ",", scientific = FALSE)) + 
  theme_classic() + 
  geom_text(aes(x=freq+idx*0.0115, y=count, label=count),
            vjust=-0.4, size=5, fontface="bold") +
  theme(text = element_text(size=40, face="bold")) +
  xlab("bootstrap frequency cutoff") + 
  ylab("counts") + 
  scale_fill_discrete(name="Label", labels=c("Edges count", "Nodes count"))
  # change legend
## output 12.5 * 8.33 mannually 

dev.off()

ggsave(file=paste0(Sys.getenv("resv"),"/count_vs_freq.eps"), device="eps")



