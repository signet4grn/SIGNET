ui <- dashboardPage(
  dashboardHeader(title="Visualization of SIGNET results"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Network Summary", tabName = "net_summary", icon = icon("line-chart")),
      menuItem("Enrichment Analysis", tabName = "enrichment", icon = icon("dna")),
      menuItem("Circular Plot", tabName = "circ", icon = icon("circle"))
    )
  # br(),
  # br(),
  #  sliderInput("boot_freq", "Bootstrap frequency cutoff:",
  #              min = 0, max = 1, step=0.01, value = freq_default, ticks=F)
    
  ),
  
  
  dashboardBody(
    ## Network Enrichment
    tabItems(
      tabItem(tabName="enrichment",
              sidebarLayout(
                sidebarPanel(
                  numericInput("net_num1", "Choose subnetwork by size:", 1, min=1, max=min(100, ntop)),
                  hr(),
                  fileInput("file1", "Choose a text file of gene list", accept = ".txt"),
                  actionButton("action1", "Clear gene list"),
                  hr(),
                  radioButtons("radio1", "Choose a criteria for clustering",
                               choices=list("Cluster by enrichment"="enrichment", 
                                            "Cluster by modularity"="modularity"),
                               selected="modularity"),
                  width=3
                ),
                mainPanel(
                  withLoader(fullscreen_this(visNetworkOutput("network"))),
                  br(),
                  br(),
                  withLoader(fullscreen_this(plotlyOutput("pathway")))
                )
              )
      ),
      
      ## Network Summary
      tabItem(tabName="net_summary",
              h3(HTML(paste("</b>", "There are in total", "<b>", net_number, "</b>","subnetworks with", 
                            "<b>", vertex_number, "</b>","genes and",
                            "<b>", edge_number, "</b>","regulation effects in the network", sep=" "))),
              
              br(),
              br(),
              
              fluidRow(
                box(
                  width = 6,
                  title = "Top Nodes",
                  withLoader(fullscreen_this(plotlyOutput("top_nodes", height=816))),
                  helpText("Node with the largest degrees in the network")
                ),
                box(
                  width = 6,
                  title = "Top Edges",
                  withLoader(DTOutput("ppi"))
                )
              )
      ),
      
      ## Circular Plots
      tabItem(tabName="circ",
              fluidRow(
                box(
                  width = 6,
                  title = "Cirular Plot",
                  numericInput("net_num2", "Choose subnetwork by size:", 1, min=1, max=min(100, ntop)),
                  br(), br(), br(),
                  withLoader(fullscreen_this(plotOutput("circular", height="736px")))
                ),
                box(
                  width = 6,
                  title = "Nodes and regulation information summary",
                  withLoader(DTOutput("table")) 
                )
              )
      )
      
    )
  )
  #body ends
  
)
