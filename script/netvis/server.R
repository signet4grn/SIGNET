server <- function(input, output) {
  
  options(warn = -1)
  
  ##dialogue
  showModal(modalDialog(
    title = "Important message",
    " Note that large networks may take a while to load.\n", 
    "All the plots could be zoomed to full screen mode by click when opened in browser.",
    footer=modalButton("Start Exploring"),
    size="l"
  ))
  
  ## PPi score summary
  output$ppi <- renderDT({
    datatable(ppi_sort, options(list(pageLength=20)))
  })
  
  
  # Network Summary  
  # Top nodes summarize
  output$top_nodes <- renderPlotly({
    ##sort according to degree
    top_nodes <- sort(igraph::degree(net_bs), decreasing = T)
    tn_frame <- data.frame(gene_name=names(top_nodes), degree=top_nodes)
    nrow_max_nodes <- min(50, nrow(tn_frame))
    tn_frame_reduce <- tn_frame[1:nrow_max_nodes, ]
    tn_frame_reduce$gene_name <- factor(tn_frame_reduce$gene_name, levels = unique(tn_frame_reduce$gene_name)[order(tn_frame_reduce$degree)])
    # name of gene in the order of comp
    sub_idx <- comp[match(tn_frame_reduce$gene_name, as.matrix(V(g_bs)$name))]
    sub_net_num <- match(sub_idx, idx_tot)
    note <- paste0("subnetwork number:", sub_net_num)
    # ggplot2 code
    # p <- ggplot(tn_frame_reduce, aes(x=gene_name, y=degree, fill=degree)) +
    #   geom_bar(stat="identity") +     
    #   scale_x_discrete(limits=rev(names(top_nodes)[1:nrow_max_nodes])) +
    #   scale_fill_distiller(palette = "Oranges", trans = "reverse") +
    #   xlab("gene name")+
    #   coord_flip() + 
    #   theme_bw() + 
    #   theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
    # ggplotly(p)
    
    color_node <- rev(heat.colors(nrow_max_nodes, alpha=0.4))
    p <- plot_ly(tn_frame_reduce, x=~degree, y=~gene_name,
                 text=note,
                 color=~gene_name,
                 colors=color_node,
                 type='bar') %>%
      layout(# title="Top nodes",
        xaxis=list(showticklabels = FALSE,title=""),
        yaxis=list(title="gene name"),
        #plot_bgcolor='rgb(239, 242, 247)',
        #paper_bgcolor='rgb(239, 242, 247)',
        showlegend=F)
    
    p 
    
  })
  

  ## Network summary
  # JSON color panel reference 
  #https://github.com/visjs/vis-network/blob/4879d7caf2a02e34e7936dc3da2101d342a0b2ae/lib/network/modules/Groups.js#L13
  # node_legend <- data.frame(label=c("non TF", "TF", "Input genes"), 
  #                           value=rep(20, 3),
  #                           color=c("#97C2FC", "#FFFF00", "#FB7E81")  # blue, yellow, red
  #                           #shape=rep("circle", 3)
  #                           )
  edge_legend <- data.frame(label=c("non-TF up regulation", "TF up regulation", "non-TF down regulation", "TF down regulation"),
                            arrows=list(to=list(enabled=T, type=c("arrow", "arrow", "circle", "circle"))),
                            #arrows.to.type=c("arrow", "arrow", "circle", "circle"),
                            color=c("#2B7CE9", "#FFA500", "#2B7CE9", "#FFA500"))
  
  output$network <- renderVisNetwork({
    #req(1<=input$net_num1 && input$net_num1<=ntop)
    validate(need(try(input$net_num1>=1 && input$net_num1<=ntop), paste0("Please input a range from ", 1, " to ", ntop)))
    ##add hover interaction https://www.rdocumentation.org/packages/visNetwork/versions/2.0.9/topics/visEvents
    vis_g_top <- visNetwork(nodes[[input$net_num1]], edges[[input$net_num1]], width="100%", height="100%") %>% 
      visOptions(selectedBy = list(variable = "enrichment", style = 'width: 200px; height: 26px;', sort=T, multiple=T), 
                 highlightNearest = list(enabled = T, degree = 2, hover = T)) %>%
      #  visGroups(groupname="non-TF", color="#97C2FC") %>%
      #  visGroups(groupname="TF", color="#FFFF00") %>%
      #visNodes(value=nodes[[input$net_num1]]$value) %>%      
      visEdges(arrows = 'to') %>% 
      #visLegend(addEdges=edge_legend, addNodes=NULL, main="Legend", useGroups=T) %>% node legend
      visLegend(addEdges=edge_legend, addNodes=NULL, main="Edge Legend", useGroups=F, width=0.3) %>%
      visLayout(randomSeed=1)
    
    vis_g_top
    
  })
  ##end rendervisNetwork 
  
  ## Upload gene list 
  observeEvent(input$file1, {
    ## Handle input files
    file <- input$file1
    ext <- tools::file_ext(file$datapath)
    
    req(file)
    validate(need(ext == "txt", "Please upload a txt file"))
    
    gene_input <- as.matrix(read.table(file$datapath, header=F))
    visNetworkProxy("network") %>% 
      visUpdateNodes(nodes=data.frame(id=as.vector(gene_input), color="#FB7E81"))
  })
  
  # Cancel gene list
  observeEvent(input$action1,{
    visNetworkProxy("network")  %>%
      visUpdateNodes(nodes=data.frame(id = V(g_top[[input$net_num1]])$name,
                                      group = ifelse(is.na(match(V(g_top[[input$net_num1]])$name, tf)), "non-TF", "TF")))
  })
  
  # Used proxy to speed up
  observeEvent(input$radio1,{
    if(input$radio1=="enrichment"){
      visNetworkProxy("network") %>%
        visOptions(selectedBy = list(variable = "enrichment", style = 'width: 200px; height: 26px;', sort=T, multiple=T),
                   highlightNearest = list(enabled = T, degree = 2, hover = T))
      
    }
    if(input$radio1=="modularity"){
      visNetworkProxy("network") %>%
        visOptions(selectedBy = list(variable = "modularity", style = 'width: 200px; height: 26px;', sort=T, multiple=T),
                   highlightNearest = list(enabled = T, degree = 2, hover = T))
    }
  })
  
  # Plot Pathways
  
  output$pathway <- renderPlotly({
    #req(1<=input$net_num1 && input$net_num1<=ntop)
    color_enrich <- heat.colors(nrow_max_enrich, alpha=0.4)
    validate(need(try(input$net_num1>=1 && input$net_num1<=ntop), paste0("Please input a range from ", 1, " to ", ntop)))
    if(is.null(enrichment[[input$net_num1]])){
      p <- plotly_empty() %>%
        layout(title="No enrichment detected",
               xaxis=list(showticklabels = FALSE,title=""),
               yaxis=list(showticklabels = FALSE,title=""),
               plot_bgcolor='rgb(239, 242, 247)',
               paper_bgcolor='rgb(239, 242, 247)',
               showlegend=F)
    }else{
    enrich_gene_grp <- paste0("Related genes: ", enrichment[[input$net_num1]]$preferredNames)
    color_count <- nrow(enrichment[[input$net_num1]])
    p <- plot_ly(enrichment[[input$net_num1]], x=~description, y=~-log10(p_value),
                 text=enrich_gene_grp,
                 color=~description,
                 colors=color_enrich,
                 type='bar') %>%
      layout(title="Enrichment by p value",
             xaxis=list(showticklabels = FALSE,title=""),
             yaxis=list(title="-log p value"),
             plot_bgcolor='rgb(239, 242, 247)',
             paper_bgcolor='rgb(239, 242, 247)',
             showlegend=F)
    }
    p 
  }
  )
  
  ##Finish network parts
 
  
  
  # Circular Plots and summary
  output$circular <- renderCachedPlot({
    #req(1<=input$net_num2 && input$net_num2<=ntop)
    validate(need(try(input$net_num2>=1 && input$net_num2<=ntop), paste0("Please input a range from ", 1, " to ", ntop)))
    ##Circular plot  
    ##initialize, be careful about the genome build  
    ##only autochromosome
    #circos.initializeWithIdeogram(species = "hg38", chromosome.index = paste0("chr", 1:22))
    # adapt to sex chromosomes 
    tryCatch(circos.initializeWithIdeogram(species = Sys.getenv("assembly"), chromosome.index = paste0("chr", c(1:Sys.getenv("nchr"), "X", "Y"))),
             error = function(e) circos.initializeWithIdeogram(species = Sys.getenv("assembly"), chromosome.index = paste0("chr", 1:Sys.getenv("nchr")))) 
    circos.genomicTrack(dout[[input$net_num2]], track.height=0.1, 
                        panel.fun = function(region, value, ...) {
                          circos.genomicPoints(region, value, col = 1, pch=20, cex=0.5)
                        })
    circos.genomicTrack(din[[input$net_num2]], track.height=0.1, 
                        panel.fun = function(region, value, ...) {
                          circos.genomicPoints(region, value, col = 1, pch=20, cex=0.5)
                        })
    circos.genomicLink(source_bed[[input$net_num2]], target_bed[[input$net_num2]], directional=1, arr.length=0.2, arr.type = "triangle")
  },
  # Put in Cache to save time
  cacheKeyExpr = {input$net_num2} )
  
  
  output$table <- renderDT({
    #req(1<=input$net_num2 && input$net_num2<=ntop)
    validate(need(try(input$net_num2>=1 && input$net_num2<=ntop), paste0("Please input a range from ", 1, " to ", ntop)))
    datatable(info[[input$net_num2]][, 1:8], options(list(pageLength=20)))
  }
  )
  
}
