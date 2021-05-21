.libPaths(c("/depot/bigcare/data/2020/Rlibs","~/R/x86_64-pc-linux-gnu-library/3.6",.libPaths()))

library(igraph)
library(dnet)
library(visNetwork)
get_net <- function(edgelist, high_freq=F, largest=F, top=NULL, search=NULL, name=NULL, string=F, string_n=NULL, interactive=F, compare=F){
  ##If high_freq=T, it will return the network induced by the node with largest frequency
  ##If largest=T, it will return the largest component with plot
  ##If largest=F, it will return exclusive subnetworks in the network
  ##If largest=F, top can be used to top network nodes names to files
  ##If search!=NULL, It can search the network expanded by a gene beining with string search
  ##construct rings
  ##source edge and target edge
  ##name argument is used to construct names of the input nodes
  ##If string=T, show the result from string database
  ##string_n : control the string database output
  ##If interactive=T, use interactive plot
  ##If compare=T, will compare the result with Chen's result
  
  bs_ring <- edgelist[, c(1, 5)]
  bs_freq <- edgelist[, 9]
  bs_ring <- as.matrix(bs_ring)
  net_bs <- graph_from_edgelist(bs_ring)
  nodes_bs <- V(net_bs)$name
  
  
  if(1-is.null(name)){
    filename <- paste(name,"_name.txt", sep="")
    write.table(nodes_bs, filename, row.names = F, col.names = F, quote = F)
  }
  ##construct components
  g_bs <- dNetInduce(net_bs, nodes_query = nodes_bs, knn=1, largest.comp = F)
  ##visualize
  ##visNet(g_bs_)
  
  if(high_freq==T){
    node_high <- names(which.max(table(bs_ring)))[1]
    g_high <- dNetInduce(net_bs, nodes_query = node_high, knn=1)
    visNet(g_high)
  }
  else{
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
            visNet(g_search[[i]])
          }
          return(g_search)
        }
      }
      else{
        comp_len <- NULL
        for(i in 1:length(unodes)){
          g_bs_sub[[i]] <- dNetInduce(g=net_bs, nodes_query = name_bs_sub[[i]], knn=1, largest.comp = F)
          comp_len <- c(comp_len, length(E(g_bs_sub[[i]])))
          ##visNet(g_bs_sub[[i]])
        }
        if(is.null(top)){
          return(g_bs_sub)
        }
        else{
          g_top <- NULL
          g_top_int <-NULL
          vis_g_top <- NULL
          top_idx <- order(comp_len, decreasing = T)[1:top]
          for(i in 1:top){
            if(1-is.null(name)){
              ##compare with Chen's result
              if(compare==T){
              edgename <- paste("Edge", (i+1), "_BF100%.xlsx", sep="")
              edge <- as.matrix(read.xlsx2(edgename, 1))
              edgelist <- matrix(nrow=nrow(edge), ncol=2)
              for(j in 1:nrow(edge)){
                edgelist[j, ] <- unlist(strsplit(edge[j, ], "   "))
              }
              edgegraph <- graph_from_edgelist(edgelist)
              di_edge <- E(edgegraph)
              len1 <- length(E(g_bs_sub[[top_idx[i]]]))
              len2 <- length(di_edge)
              int <- length(E(igraph::union(g_bs_sub[[top_idx[i]]], edgegraph)))
              if((len1==len2)*(len1==int)){
                print("T")
              }else{
                print("F")
              }
              }
              
              filename <- paste("top", i, "_", name, "_name.txt", sep="")
              write.table(name_bs_sub[[top_idx[i]]], filename, row.names = F, col.names = F, quote = F)
              g_top[[i]] <- dNetInduce(net_bs, nodes_query = name_bs_sub[[top_idx[i]]], knn=1)
              g_top_int[[i]] <- toVisNetworkData(g_top[[i]])
              vis_g_top[[i]] <- visNetwork(nodes=g_top_int[[i]]$nodes, edges=g_top_int[[i]]$edges, width="100%", height="1000px")
              if(interactive==F){
              #visnet <-  vis_g_top[[i]]
              #visave <- visSave(visnet, file = paste0("network",i,".html"), background = "white")
              }
              else{
                vis_g_top[[i]]
              }
              
            }
            
          }
          
        } 
      }
      ##largest=F ends
    }
    
    if(largest==T){
      g_bs_largest <- dNetInduce(net_bs, nodes_query = nodes_bs, knn=1)
      nodes_largest <- V(g_bs_largest)$name
      if(1-is.null(name)){
        filename <- paste(name,"_largest_name.txt", sep="")
        write.table(nodes_largest, filename, row.names = F, col.names = F, quote = F)
      }
      visNet(g_bs_largest)
      if(string==T){
        nodes_largest <- as.data.frame(nodes_largest)
        mapped <- string_db$map(nodes_largest, "nodes_largest", removeUnmappedRows = TRUE)
        if(1-is.null(string_n)){
          string_db$plot_network(mapped$STRING_id[1:string_n])
        }
        else{
          string_db$plot_network(mapped$STRING_id)
        }
      }
      return(g_bs_largest)
    }
    else{
      if(string==T){
        
      }
    }
    ##else high frequency ends
  }
  
  
}



##A function to close all the devices (graphics.off())
close_dev <- function(){
  n <- length(dev.list())
  for(i in 1:(n-1)){
    dev.off()
  }
}

setwd('../../data/netvis/')
args = commandArgs(T)
freq = args[1]
ncount = args[2]
edgelist <- read.table(paste0('edgelist_',freq), header=T)
get_net(edgelist, name=paste0("freq_",freq), top=ncount)

