library(ggplot2)
evec <- read.table('Geno.pca.evec')
evec[, 1] <- as.character(evec[, 1])
evec <- as.matrix(evec[, 2:11])
for(i in 1:9){
pc_data_plot <- qplot(evec[,i], evec[,(i+1)], alpha=0.8, xlab=paste0("PC",i), ylab=paste0("PC", (i+1)), main='PC plot of the genotype data') + scale_color_manual(values=c("green", "red", "blue"))
ggsave(paste0("pc_data_plot_",i,"vs",(i+1),".png"), pc_data_plot, "png")
}

eval <- read.table("Geno.eval")
elbow <- qplot(1:15, eval[1:15, ], xlab="PC index", ylab="Eigenvalue", main="Elbow plot") + theme(plot.title = element_text(hjust = 0.5))
ggsave("elbow plot.png", elbow, "png")

cat("\n")

eigen <- eval[1:15, ]
eigen <- cbind(eigen, eigen/sum(eval))
colnames(eigen) <- c("Eigen value", "Proportion")
print(eigen)
