data <- readRDS("healthexp.Rds")


data$Region <- as.factor(data$Region)

#Getting region's  names for subsetting by region purposes
#The initial choices are all the regions. 

regions <- levels(data$Region)

values <- 1:length(levels(data$Region))
names <- levels(data$Region)
choices <- as.list(setNames(values, names))


