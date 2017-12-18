library(dplyr)
library(ggplot2)
library(reshape2)
library(plotrix)

# --------------------------------------------------------------

shinyServer(function(input, output, session) {

  output$image1 <- renderImage(
    
    {return(list(src = 'Images/pic.jpg', width = 450, height = 250))}, deleteFile = FALSE
  )
 
  
  
  values <- 1:length(levels(data$Region))
  names <- levels(data$Region)
  choices <- as.list(setNames(values, names))

  defaultColors <- c("#3366cc", "#dc3912", "#ff9900", "#109618", "#990099", "#0099c6", "#dd4477")
  
  series <- structure(
    lapply(defaultColors, function(color) { list(color=color) }),
    names = levels(data$Region)
  )
  
  #Get the number of countries
  output$nb_countries <- renderText(toString(length(levels(as.factor(data$Country)))))
  
  #Filter the disired regions in order to adjust x-axis range
  xlim <- reactive({
    selected_regions <- regions[as.numeric(choices())]
    data<-data[data$Region %in% selected_regions,]
    list(
      min = min(data$Health.Expenditure),
      max = max(data$Health.Expenditure) + 30
    )
  })
  
  #Filter the disired regions in order to adjust y-axis range
  ylim <- reactive({
    selected_regions <- regions[as.numeric(choices())]
    data<-data[data$Region %in% selected_regions,]
    list(
      min = min(data$Life.Expectancy),
      max = max(data$Life.Expectancy) + 5
    )
  })
  
  #Dynamically get the selected regions
  choices <- reactive({ 
    input$checkGroup
  })

  #Output choices to displays just to see if "checkGroupInput" is woking
  output$chs <- reactive({ choices() })
  
  yearData <- reactive({    
 
    #Filter the disired regions
    selected_regions <- regions[as.numeric(choices())]
    data<-data[data$Region %in% selected_regions,]
    
    # Filter to the desired year, and put the columns
    # in the order that Google's Bubble Chart expects
    # them (name, x, y, color, size). Also sort by region
    # so that Google Charts orders and colors the regions
    # consistently.
    df <- data %>%
      filter(Year == input$year) %>%
      select(Country, Health.Expenditure, Life.Expectancy,
             Region, Population) %>%
      arrange(Region)
  })
  
  output$chart <- reactive({
    # Return the data and options
    #@Lingani
    #Added the two options "hAxis" and "vAxis" to recompute dynamically axis ranges
    list(
      data = googleDataTable(yearData()),
      options = list(
        title = "Health expenditure vs. life expectancy",
        series = series,
        hAxis = list(
          title = "Health expenditure, per capita ($USD)",
          viewWindow = xlim()
        ),
        vAxis = list(
          title = "Life expectancy (years)",
          viewWindow = ylim()
        )
      )
    )
  })
  
  # Generate a summary of the data
  output$summary <- renderPrint({
    summary(data)
  })
  
  # Generate an HTML table view of the data
  output$table <- renderTable({
    data.frame(data[1:20, ])
  })
  
  
  normalize <- function(x) {
    return ((x - min(x)) / (max(x) - min(x)))
  }
  
 output$expPlot <- renderPlot(
   {
      df <- data %>%
         filter(Country == input$country)
      df <- df[,c(3,4,5,6)]
       
      df$Population <- normalize(df$Population)
      df$Health.Expenditure <- normalize(df$Health.Expenditure)
      df$Life.Expectancy <- normalize(df$Life.Expectancy)
    
      chart_data <- melt(df, id='Year')
      names(chart_data) <- c('x', 'Factor', 'value')
      
      ggplot() +
        geom_line(data = chart_data, aes(x = x, y = value, color = Factor), size = 1)+
        xlab("Year") +
        ylab("")
   })
 
 output$trendPlot <- renderPlotly({
   
   if (length(input$name) == 0) {
     print("Please select at least one country")
   } else {
     df_trend <- data[data$Country == input$name, ]
     ggplot(df_trend) +
       geom_line(aes(x = Year, y = Health.Expenditure, by = Country, color = Country)) +
       labs(x = "Year", y = "Health.Expenditure", title = "Health Expenditure for Countries") +
       scale_colour_hue("clarity", l = 70, c = 150) + ggthemes::theme_few()
   }
   
 })

  output$expPlot_pie <- renderPlot(
   {
         df <- data %>%
           filter(Country == input$country2)
     
         df$Life.Expectancy <- normalize(df$Life.Expectancy)
         df$Population <- normalize(df$Population)
         df$Health.Expenditure <- normalize(df$Health.Expenditure)
         
         
        # layout(matrix(c(1,1,2,3), 2, 2, byrow = TRUE))

         
         pie(df$Life.Expectancy, labels = df$Year, col = rainbow(nrow(df)),
             main="Life Expectancy")
         
        # pie(df$Population, labels = df$Year,col = rainbow(nrow(df)),
         #    main="Population")
         
        # pie(df$Health.Expenditure, labels = df$Year, col = rainbow(nrow(df)),
         #    main="Health Expenditure")
     
     
         #pie3D(df$Life.Expectancy, labels = df$Year, explode=0.2,
         #    main="Life Expectancy",height = 0.03,labelcex = 0.9)
   })
  
})