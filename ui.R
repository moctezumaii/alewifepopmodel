#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#


library(shiny)
library(shinyWidgets)
library(shinycssloaders)
library(shinyAce)

fluidPage(
  theme="bootstrap.css",
           tags$style(type = "text/css", "
      .irs-bar {width: 100%; height: 25px; background: black; border-top: 1px solid black; border-bottom: 1px solid black;}
                      .irs-bar-edge {background: black; border: 1px solid black; height: 25px; border-radius: 0px; width: 20px;}
                      .irs-line {border: 1px solid black; height: 25px; border-radius: 0px;}
                      .irs-grid-text {font-family: 'arial'; color: white; bottom: 17px; z-index: 1;font-size:0px}
                      .irs-grid-pol {display: none;}
                      .irs-max {font-family: 'arial'; color: black;font-size:16px}
                      .irs-min {font-family: 'arial'; color: black;font-size:16px}
                      .irs-single {color:black; background:#FFF;font-size:18px}
                      .irs-slider {width: 30px; height: 30px; top: 22px;}
                      "),
  tags$h1("Alewife population model *Beta*"),

  
  br(),
  
  tags$head(tags$style(".shiny-notification {position: fixed; top: 30% ;left: 8%;color: rgb(255, 255, 255); font-size: 18px; line-height: 18px; padding: 16px; border-radius: 1px; font-family: Verdana, Geneva, sans-serif; font-weight: 400; text-decoration: none; font-style: normal; font-variant: normal; text-transform: none; background-image: linear-gradient(to right, rgb(28, 110, 164) 0%, rgb(35, 136, 203) 50%, rgb(20, 78, 117) 100%); box-shadow: rgba(0, 0, 0, 0) 0px 0px 0px 0px; border: 2px solid rgb(28, 110, 164); display: inline-block;")
            
            ),

   mainPanel(width = 12,
               tabsetPanel(id="tabs",
                           ######THIS IS ALL NEW####
            tabPanel(title="Select",value="buttons",
                     fluidPage(
                       
                       wellPanel(
                        style= "background: transparent; border:0px",
                      
                       fluidRow(column(1),
                         column(3,
                               h4("Introduction video"),
                               actionButton(inputId="youtube",label=NULL,style = "width: 300px; height: 220px;border: 1px solid #000000;
background: url(IntroductionVideoButton.png);  background-size: cover; background-position: center center;",onclick="window.open('http://youtube.com', '_blank')"),
                               wellPanel(style="width: 300px;background: transparent; border:0px",h5("Background information about the alewife population model, inputs included, and assumptions"))
                               ),
                         column(1),
                         column(3,
                                h4("Tutorial video"),
                                actionButton(inputId="powerpoint",label=NULL,style = "width: 300px; height: 220px;border: 1px solid #000000;
background: url(TutorialVideoButton.png);  background-size: cover; background-position: center center;",onclick="window.open('http://office.com', '_blank')"),
                                wellPanel(style="width: 300px;background: transparent; border:0px",h5("Step-by-step tutorial of the online application using several example management questions"))
                                ),
                       column(1),
                       column(3,
                              h4("Technical Document"),
                              actionButton("readme",label=NULL,style = "width: 300px; height: 220px;border: 1px solid #000000;
background: url(TechDocButton.png);  background-size: cover; background-position: center center;"),
                              wellPanel(style="width: 300px;background: transparent; border:0px",h5("Step-by-step tutorial of the online application using several example management questions"))
                              )
                       
                      
                     ),
                     br(),
                     br(),
                     fluidRow(
                       column(4),
                       column(5,
                                  actionButton("app",label=NULL, style = "width: 544px; height: 370px;border: 1px solid #000000;
background: url(AppStartButton.png);  background-size: cover; background-position: center center;"
                                          ))
                     ),br(),
                     fluidPage(wellPanel(style="background: transparent; border:0.5px",includeMarkdown("assumptionss.Rmd")))
                     ),img(src='AppBottomBanner.png', align = "right", style="width: 1810px; height: 370px"))
                     
                     ),               
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
                        br(),
                        br()
                        #,
                      #  tags$p("app")
                        #tags$a(href='systemcreator2test.Rmd', target='blank',"a", download="systemcreator2test.Rmd")
                        )
                      )
             
             ,
                        


             tabPanel("Comparative model", #if this tab is changed, a reactive tab should be changed too, so that after clicking Input$Run it will change tabs
                      fluidPage(
                       
                        
                        fluidRow(
                          column(6,
                                 tags$h3("Passage parameters")),
                          column(6, tags$h3("Results"))
                        ),
                        fluidRow(
                          column(6,
                                 wellPanel(
                                 style= "background: transparent; border:0px",
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
                                   style= "background: transparent; border:0px",
                                   div(class="option-group",
                                       
                                       
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
                                        withSpinner(plotOutput("testtable1"))
                                       )
                                      # )
                                   #)
                                 )
                                 ,
                                 
                                 fluidRow(column(4,downloadButton('downloadjuv',"Juveniles")),
                                          column(4,downloadButton('downloadocean',"Ocean")),
                                          column(4,downloadButton('downloadspawning',"Spawning"))
                                 )
                                 ,
                                 br(),
                                 fluidPage(tabsetPanel(id="tables",
                                   tabPanel("Juveniles",
                                   tableOutput("testable2")),
                                   tabPanel("Ocean",
                                            tableOutput("testable3")),
                                   tabPanel("Spawning",
                                            tableOutput("testable4")),
                                   tabPanel("Multiple comparisons",value="multiple",
                                            fluidPage(
                                              br(),
                                              fluidRow(column(6,tags$h4("*Start or reset comparisons panel*")),column(3,actionButton('resetorstart','Start or reset')),column(2,dropdownButton(tags$h6("If you get an error message, please run a model and click the 'start or reset' button after the model has run"),circle=T,status="danger", icon=icon("question"))
                                                
                                              )),br(),
                                              fluidRow(column(7,uiOutput("buttons")),column(5,uiOutput("download2"))), 
                                              fluidRow(tableOutput("comparisonstable")),
                                              fluidRow(textOutput("Warning")),
                                              fluidRow(plotOutput("comparisonsplot"))
                                            ))
                                   )
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
             ) ,
            tabPanel("Contact us",
              pageWithSidebar(
                
                headerPanel("Contact us"),
                
                sidebarPanel(
                  textInput("from", "From:", value="from@gmail.com"),
                  selectInput("to", "To:",
                              choices = list("Betsy Barber" = "betsy.barber@maine.edu", "Alejandro Molina-Moctezuma" = "alejandro.molina@maine.edu")),
                  textInput("subject", "Subject:", value=""),
                  actionButton("send", "Send mail"),
                  p("Send email to Betsy Barber for issues or questions regarding the model and results"),
                p("Send email to Alejandro Molina-Moctezuma for issues regarding bugs or app functionality")
                ),
                
                
                mainPanel(    
                  aceEditor("message", value="write message here")
                )
                
              ) 
              
            ),
            tabPanel("about", 
                     pre(includeText("readme.txt")))
            #,
  # ################          
            # tabPanel("Multiple comparisons",value="multiple",
             #         fluidPage(
                      
              #       fluidRow(column(6,tableOutput("comparisonstable")))
              # )
             #)
  ################
            
            ),
  br(),
  hr(),
  tags$h6("A Web Based Tool Designed by: Betsy Barber, Joseph Zydlewski, and Alejandro Molina-Moctezuma")
  
  
)
) 


