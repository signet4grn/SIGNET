cat("Generating pathway radar plot ... \n")

set.seed(1)
# https://r-graph-gallery.com/142-basic-radar-chart.html
# https://www.datanovia.com/en/blog/beautiful-radar-chart-in-r-using-fmsb-and-ggplot-packages/
radar_max <- 10

# Study -log10 p value
enrich <- read.table(paste0(Sys.getenv("resv"), "_enrich_", cat, "_info_top", i, "_", name, ".txt"), sep="@", header=T)
if(nrow(enrich) <=3){
  print("There is no enough pathways for radar plot")
}else{
enrich_radar <- as.data.frame(t(-log10(enrich$p_value)))
colnames(enrich_radar) <- lapply(enrich$description, function(x) unlist(strsplit(x, ","))[1])
## re-arrange for better plot
#if(ncol(enrich_radar)>5){
if(ncol(enrich_radar)>radar_max){
  enrich_radar <- enrich_radar[, 1:radar_max]
}
#enrich_radar <- cbind(enrich_radar[, -c(1:5)], enrich_radar[, 1:5])
#}

max <- max(enrich_radar)
min <- min(enrich_radar)
rmax <- round(max, 2)
rmin <- round(min, 2)
rdiff <- round((rmax-rmin)/5, 2)

enrich_radar <- rbind(rep(max, ncol(enrich_radar)), rep(min, ncol(enrich_radar)), enrich_radar)

pdf(file=paste0(Sys.getenv("resv"), "_enrichment_radar_top", i, "_", name, ".pdf"), height = 8.3, width = 12.5)
par(font=2)
color_radar <- "#00AFBB"
radarchart(enrich_radar, 
           axistype = 1, 
           axislabcol="black", 
           # polygon
           pcol=color_radar, pfcol=scales::alpha(color_radar, 0.5), plwd=2, 
           # grid
           cglcol="grey", cglty=1,
           caxislabels=seq(rmin, rmax, length.out=5), cglwd=1,
           # label
           vlcex=1)
dev.off()
}
