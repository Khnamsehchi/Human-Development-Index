#   devtools::install_github("jcheng5/googleCharts")
library(googleCharts)
library(plotly)

# --------------------------------------------------------------------

xlim <- list(
  min = min(data$Health.Expenditure),
  max = max(data$Health.Expenditure)
)
ylim <- list(
  min = min(data$Life.Expectancy),
  max = max(data$Life.Expectancy)
)

# --------------------------------------------------------------------

shinyUI(fluidPage(
  navbarPage( tags$b("Human Development Index (HDI)"),
             tabPanel("Description",
                      fluidRow(
                        tags$div(
                          tags$h3(tags$b("Human Development Index (HDI)")),
                            div(
                              tags$h4("Clarification"),
                              
                            tags$h4(p("Life expectancy has increased rapidly since the Enlightenment."),
                                    p("Estimates suggest that in a pre-modern, poor world,life "),
                                    absolutePanel(right = 15, imageOutput("image1")),
                                    p("expectancy was around 30 years in all regions of the world "),
                                    p("in the early 19th century, life expectancy started to increase"),
                                    p("in the countires which advanced into industrial, era while " ),
                                    p("it stayed low in the rest of the world. Rich countries are "),
                                    p("showered with healthier life than those countries that remained"),
                                    p("poor, persistantly in bad health. But over the last decades,"),
                                    p("this global inequality has significantly decreased."),
                                    p("On the other hand, health expenditureis another scope of "),
                                    p("challenge in the world. In this project,life expectancy"),
                                    p("and health expenditure are the focused domain.")
                                    
                                     )
                              
                             
                            )
                          )
                      )
             ),
             tabPanel("Visualization",
                  tabsetPanel(type = "tabs",
                        tabPanel("Comparison by Region",
                          sidebarLayout(
                            sidebarPanel(
                              checkboxGroupInput("checkGroup", label = h3("Select Regions"), 
                                                 choices = choices,
                                                 #@Lingani
                                                 #By default select all the regions
                                                 selected = 1:length(regions)
                              ),
                              sliderInput("year", "Year",
                                          min = min(data$Year), max = max(data$Year),
                                          value = min(data$Year), animate = TRUE)
                            ),
                            mainPanel(
                                       # Loads the Google Charts JS library
                                       googleChartsInit(),
                                       
                                       # Use the Google webfont "Source Sans Pro"
                                       tags$link(
                                         href=paste0("http://fonts.googleapis.com/css?",
                                                     "family=Source+Sans+Pro:300,600,300italic"),
                                         rel="stylesheet", type="text/css"),
                                       tags$style(type="text/css",
                                                  "body {font-family: 'Source Sans Pro'}"
                                       ),
                                       googleBubbleChart("chart",
                                                         width="100%", height = "475px",
                                                         options = list(
                                                           fontName = "Source Sans Pro",
                                                           fontSize = 13,
                                                           # Set axis labels and ranges
                                                           hAxis = list(
                                                             title = "Health expenditure, per capita ($USD)",
                                                             viewWindow = xlim
                                                           ),
                                                           vAxis = list(
                                                             title = "Life expectancy (years)",
                                                             viewWindow = ylim
                                                           ),
                                                           # The default padding is a little too spaced out
                                                           chartArea = list(
                                                             top = 50, left = 75,
                                                             height = "75%", width = "75%"
                                                           ),
                                                           # Allow pan/zoom
                                                           explorer = list(),
                                                           # Set bubble visual props
                                                           bubble = list(
                                                             opacity = 0.4, stroke = "none",
                                                             # Hide bubble label
                                                             textStyle = list(
                                                               color = "none"
                                                             )
                                                           ),
                                                           # Set fonts
                                                           titleTextStyle = list(
                                                             fontSize = 16
                                                           ),
                                                           tooltip = list(
                                                             textStyle = list(
                                                               fontSize = 12
                                                             )
                                                           )
                                                         )
                                             )
                                      )
                              )
                        ),            
                        tabPanel("Information for each contry",
                             sidebarLayout(
                               sidebarPanel(
                                 selectInput('country', 
                                             label = "Country Name(s) as your desire",
                                             choices = unique(data$Country))
                               ),
                               mainPanel(
                                 plotOutput("expPlot")
                               )
                             )
                        ),
                        tabPanel("Health Expenditure",
                                 # Application title
                                 #titlePanel("Health Expenditure"),
                                 
                                 sidebarPanel(
                                   h3("Points Estimation"),
                                   # Select Justices name here
                                   selectizeInput("name",
                                                  label = "Country Name(s) as your desire",
                                                  choices = unique(data$Country),
                                                  multiple = T,
                                                  options = list(maxItems = 5, placeholder = 'Select a name'),
                                                  selected = "Albania"),
                                   # Term plot
                                   plotOutput("termPlot", height = 200)
                                   #,helpText("By Kh.namsehchi ")
                                 ),
                                 
                                 # Show a plot of the generated distribution
                                 mainPanel(
                                   plotlyOutput("trendPlot")
                                 )
                        ),
                        tabPanel("Life Expectancy",
                                 sidebarLayout(
                                   sidebarPanel(
                                     selectInput('country2', 
                                                 label = "Country Name(s) as your desire",
                                                 choices = unique(data$Country))
                                   ),
                                   mainPanel(
                                     plotOutput("expPlot_pie")
                                   )
                                 )
                        )
                  )
             ),
             tabPanel("Summary",
                       withTags({
                         div(class="header", checked=NA,
                             p("Below find a summary of the data used for the ploting."),
                             verbatimTextOutput("summary"),
                             p("Go to Data Information Tab to see an overview of the data.")
                         )                      
                       })
              ), 
              tabPanel("Data Information",                  
                       withTags({
                         div(class="header", checked=NA,
                             p("Just displayed the first 20 rows of the data"),
                             tableOutput("table")
                         )           
                       })
              ),
             tabPanel("Documentation",
                      withTags({
                        div(class="header", checked=NA,
                            p(h3("Project Information")),
                            
                            tags$h3("Objective"),
                            tags$h4(tags$p("To understand and compare the average of countries' 
                                   health expenditure versus the average citizen's life expectancy ")),
                            tags$br(),
                            tags$h3("Motivation "),
                            tags$h4( tags$p("Each countries has their fair share of medical expenditures that are given to their people and, 
                                   different countries have different costs that the people has to bear. 
                                   Medical expenditures are one of the necessity in one person's life, 
                                   and almost everyone has to spend part of their earnings to pay medical bills in order to survive. 
                                   However, some countries provide full coverage or impose minimum charges in the government hospitals. 
                                   We are here to find out how much the nation has to spend on the healthcare.")),
                            tags$br(),
                            tags$h3("Dataset"),
                            tags$h4(tags$p("1- The dataset contain 6 attributes - Country, Region, Year, Population, Life Expectancy, Health Expenditure"), 
                            tags$p("2- The dataset contain 3030 rows"),
                            tags$p("3- The dataset contain 175 countries, since 1995 until 2011"),
                            tags$p("4- The dataset contain 7 regions")),
                            
                            tags$br(),
                            tags$h3("Process"),
                            tags$h4(tags$p("--Found dataset from Kaggle which matches our targeted domain of healthcare "),
                            tags$p("--Studied the dataset for possible objectives and questions that we can come out with"),
                            tags$p("--Doing data preprocessing of the dataset"),
                            tags$p("--Take sample of the dataset to test in a selected plot model - Google Chart, Histogram, Term plot, Pie Chart"),
                            tags$br(),
                            tags$p("1- Google Chart - Health Expenditure vs, Life Expectancy of Selected Year, Section Visualization -- Comparison by Region "),
                            tags$p("2- Histogram - Incrementation (by yearly) of Population, Life Expectancy, Health Expenditure of Selected Country, Section Visualization -- Information for each contry"),
                            tags$p("3- Term plot - Health expenditure of Selected country one by one or compare countries up to 5 selection, Section Visualization -- Health Expenditure"),
                            tags$p("4- Pie Chart - Life Expectancy of Selected Country, Section Visualization -- Life Expectancy "),
                            tags$p("Thank you!"))
                                   
                            
                        )
                        
                      })
             ),
             
              tabPanel("About Us",
                       withTags({
                         div(class="header", checked=NA,
                             p(h3("Provid by")),
                             tags$br(),
                             tags$h4("WQD170026     Saeid Joneidi Yekta"),
                             tags$br(),
                             tags$h4("WQD170034     Khashayar Namsehchi "),
                             tags$br(),
                             tags$h4("WQD170025     Moi Chee Hui"),
                             tags$br(),
                             tags$h4("WQD170053     Minhajul Abedin Forhad ")
                             )
                         
                       })
              )
  
  )
)
)