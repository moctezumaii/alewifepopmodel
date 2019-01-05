#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#


library(shiny)

fluidPage( 
  tags$h2("App name... logo?"),
  p("this is a short decription of the model, or it can be deleted. This section can be a banner?"),
  hr(),

   mainPanel(width = 12,
               tabsetPanel(id="tabs",
                           ######THIS IS ALL NEW####
            tabPanel(title="Select",value="buttons",
                     fluidPage(
                       wellPanel(
                       h1("Tutorials"),
                       fluidRow(
                         column(4,
                               h4("Youtube video"),
                               actionButton(inputId="youtube",label=NULL,style = "width: 120px; height: 85px;
background: url(yt.png);  background-size: cover; background-position: center center;",onclick="window.open('http://youtube.com', '_blank')")),
                         column(4,
                                h4("PowerPoint Presentation"),
                                actionButton(inputId="powerpoint",label=NULL,style = "width: 100px; height: 100px;
background: url(PP.png);  background-size: cover; background-position: center center;",onclick="window.open('http://office.com', '_blank')")),
                       
                       column(4,
                              h4("Read me document"),
                              actionButton("readme",label=NULL,icon = icon("book", "fa-5x")))
                       
                      
                     ),
                     br(),
                     br(),
                     fluidRow(
                       column(4),
                       column(4,
                              h2("Start using the app"),
                              actionButton("app",label="Go to app",style="
color: rgb(255, 255, 255); font-size: 50px; line-height: 50px; padding: 16px; border-radius: 1px; font-family: Verdana, Geneva, sans-serif; font-weight: 400; text-decoration: none; font-style: normal; font-variant: normal; text-transform: none; background-image: linear-gradient(to right, rgb(28, 110, 164) 0%, rgb(35, 136, 203) 50%, rgb(20, 78, 117) 100%); box-shadow: rgba(0, 0, 0, 0) 0px 0px 0px 0px; border: 2px solid rgb(28, 110, 164); display: inline-block;}
                                           .myButton:hover {
                                           background: #1C6EA4; }
                                           .myButton:active {
                                           background: #144E75"))
                     )
                     ))),               
             tabPanel("Choose or create your river",value="test101",
                      fluidPage(
                        titlePanel("Step 1: Create your River"),
                        selectInput(inputId = "river", label = h3("Choose your system"),
                                    choices = list("St. Croix" = 1, "Create your own system" = 2)),
                        uiOutput("riverout"),
                        
                        
                        
                        conditionalPanel(
                          condition = "input$river == 2",
                          uiOutput("see")
                          
                           

                          
                          
                        ),
                        tags$p("Press button to load river"),
                        actionButton('loadbutton1',"Load"),
                        tags$p(" 'a' tag linking to local file"),
                        tags$a(href='systemcreator2test.Rmd', target='blank',"a", download="systemcreator2test.Rmd")
                        )
                      )
             
             ,
                        


             tabPanel("Comparative model", #if this tab is changed, a reactive tab should be changed too, so that after clicking Input$Run it will change tabs
                      fluidPage(
                        titlePanel("name of river"),
                        fluidRow(
                          column(6, tags$h3("Passage parameters")),
                          column(6, tags$h3("Results"))
                        ),
                        fluidRow(
                          column(6,
                                 wellPanel(
                                  uiOutput("riversinput")
                                   # div(class="option-group",
                                   #   div(class="option-header", tags$h4("PASSAGE")),
                                   #     ####TEST####
                                   # 
                                   # 
                                   # 
                                   #     div(class= "option-header", "Milltown"),
                                   #     flowLayout(
                                   #       column(12,
                                   #              sliderInput("MTAU1", "Adult Upstream",min = 0, max=100, value=50, step = 1)),
                                   #       column(12,
                                   #              sliderInput("MTAD1", "Adult Downstream",min = 0, max=100, value=50, step = 1)),
                                   #       column(12,
                                   #              sliderInput("MTJD1", "Juvenile Downstream",min = 0, max=100, value=50, step = 1))
                                   #     ),
                                   #     div(class= "option-header", "Woodland"),
                                   #     flowLayout(
                                   #       column(12,
                                   #              sliderInput("WLAU1", "Adult Upstream",min = 0, max=100, value=50, step = 1)),
                                   #       column(12,
                                   #              sliderInput("WLAD1", "Adult Downstream",min = 0, max=100, value=50, step = 1)),
                                   #       column(12,
                                   #              sliderInput("WLJD1", "Juvenile Downstream",min = 0, max=100, value=50, step = 1))
                                   #     ),
                                   #     div(class= "option-header", "Grand Falls"),
                                   #     flowLayout(
                                   #       column(12,
                                   #              sliderInput("GFAU1", "Adult Upstream",min = 0, max=100, value=50, step = 1)),
                                   #       column(12,
                                   #              sliderInput("GFAD1", "Adult Downstream",min = 0, max=100, value=50, step = 1)),
                                   #       column(12,
                                   #              sliderInput("GFJD1", "Juvenile Downstream",min = 0, max=100, value=50, step = 1))
                                   #     ),
                                   #     div(class= "option-header", "Spednic"),
                                   #     flowLayout(
                                   #       column(12,
                                   #              sliderInput("SPAU1", "Adult Upstream",min = 0, max=100, value=50, step = 1)),
                                   #       column(12,
                                   #              sliderInput("SPAD1", "Adult Downstream",min = 0, max=100, value=50, step = 1)),
                                   #       column(12,
                                   #              sliderInput("SPJD1", "Juvenile Downstream",min = 0, max=100, value=50, step = 1))
                                   #     ),
                                   #     div(class="option-header", tags$h4("Mortality")),
                                   #     flowLayout(
                                   #       column(12,
                                   #              sliderInput("ocean", "Ocean",min = 0, max=100, value=50, step = 1)),
                                   #       column(12,
                                   #              sliderInput("Juv", "Juvenile",min = 0, max=100, value=50, step = 1)),
                                   #       column(12,
                                   #              sliderInput("DWSTR", "Downstream",min = 0, max=100, value=50, step = 1))
                                   #     ),
                                   # 
                                   # 
                                   #     flowLayout(
                                   #       column(9,
                                   #              numericInput("num",tags$h6("Habitat Size (acres):"),11)),
                                   #       column(9,
                                   #              numericInput("num",tags$h6("Recruitment (YOY per acre):"),3283)),
                                   #       column(9,
                                   #              numericInput("num",tags$h6("lifetime rep. rate (alpha):"),0.0015)),
                                   #       column(9,
                                   #              numericInput("num",tags$h6("Escapement (spawners):"),100))
                                   #     )
                                   # )
                                 )     
                          ),
                          column(6,
                                 wellPanel(
                                   div(class="option-group",
                                       div(class="option-header", tags$h4("PASSAGE2")),
                                       
                                       #if test doesn't work: recomment this!
                                       # div(class= "option-header", "Milltown"),
                                       # flowLayout(
                                       #   column(12,
                                       #          sliderInput("MTAU2", "Adult Upstream",min = 0, max=100, value=50, step = 1)),
                                       #   column(12,
                                       #          sliderInput("MTAD2", "Adult Downstream",min = 0, max=100, value=50, step = 1)),
                                       #   column(12,
                                       #          sliderInput("MTJD2", "Juvenile Downstream",min = 0, max=100, value=50, step = 1))
                                       # ),
                                       # div(class= "option-header", "Woodland"),
                                       # flowLayout(
                                       #   column(12,
                                       #          sliderInput("WLAU2", "Adult Upstream",min = 0, max=100, value=50, step = 1)),
                                       #   column(12,
                                       #          sliderInput("WLAD2", "Adult Downstream",min = 0, max=100, value=50, step = 1)),
                                       #   column(12,
                                       #          sliderInput("WLJD2", "Juvenile Downstream",min = 0, max=100, value=50, step = 1))
                                       # ),
                                       # div(class= "option-header", "Grand Falls"),
                                       # flowLayout(
                                       #   column(12,
                                       #          sliderInput("GFAU1", "Adult Upstream",min = 0, max=100, value=50, step = 1)),
                                       #   column(12,
                                       #          sliderInput("GFAD1", "Adult Downstream",min = 0, max=100, value=50, step = 1)),
                                       #   column(12,
                                       #          sliderInput("GFJD1", "Juvenile Downstream",min = 0, max=100, value=50, step = 1))
                                       # ),
                                       # div(class= "option-header", "Spednic"),
                                       # flowLayout(
                                       #   column(12,
                                       #          sliderInput("SPAU1", "Adult Upstream",min = 0, max=100, value=50, step = 1)),
                                       #   column(12,
                                       #          sliderInput("SPAD1", "Adult Downstream",min = 0, max=100, value=50, step = 1)),
                                       #   column(12,
                                       #          sliderInput("SPJD1", "Juvenile Downstream",min = 0, max=100, value=50, step = 1))
                                       # ),
                                       # div(class="option-header", tags$h4("Mortality")),
                                       # flowLayout(
                                       #   column(12,
                                       #          sliderInput("ocean", "Ocean",min = 0, max=100, value=50, step = 1)),
                                       #   column(12,
                                       #          sliderInput("Juv", "Juvenile",min = 0, max=100, value=50, step = 1)),
                                       #   column(12,
                                       #          sliderInput("DWSTR", "Downstream",min = 0, max=100, value=50, step = 1))
                                       # ),
                                       #flowLayout(
                                        # column(6,
                                                #plotOutput("plot1"))
                                         plotOutput("testtable1"))
                                      # )
                                   #)
                                 )     
                          )
                        )
                        #,
                        #fluidRow(
                          #column(6,
                          #       plotOutput("plot1")
                          #),
                         # column(6,
                          #       plotOutput("plot2")
                          #)
                        #)
                      )
             )
  )
)
)


