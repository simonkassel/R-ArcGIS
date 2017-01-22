# Spatial Test Set for Logistic Regression
# Author: Simon Kassel

tool_exec <- function(in_params, out_params){
  
  # Install and load necessary packages
  arc.progress_label("Loading packages...")
  for (p in c("caret", "sp", "plyr", "maptools", "ggplot2")) 
  {
    if (!requireNamespace(p, quietly = TRUE))
      install.packages(p)
    suppressMessages(library(p, character.only = TRUE))
  } 
  
  # Load data from list of input parameters
  pointShape <- in_params[[1]]
  indVar  <- in_params[[2]]
  depVars <- in_params[[3]]
  polygonShape <- in_params[[4]]
  polyIdField <- in_params[[5]]
  minimumPoints <- in_params[[6]]
  predThreshold <- in_params[[7]]
  
  # Output parameter
  outPutShape = out_params[[1]]
  
  # Open points shapefile, selecting only relevant fields, 
  # convert to sp object
  spPoints <- arc.data2sp(
    arc.select(
      arc.open(pointShape), c(indVar, depVars)
    )
  )
  
  # Open polygon shapefile, selecting only ID relevant field 
  # convert to sp object
  spPolys <- arc.data2sp(
    arc.select(
      arc.open(polygonShape), polyIdField
    )
  )
  
  # Spatially join polygons to points, returning the bounding polygon
  # ID as field in points data frame
  dat <- cbind(spPoints@data, over(spPoints, spPolys[ , polyIdField]))
  
  # Rename polygon ID field
  names(dat)[c(1, ncol(dat))] <- c("ivar", "id")
  
  # Create vector of unique, non-NA, polygon field IDs
  ids <- unique(as.character(dat$id))
  ids <- ids[which(is.na(ids) == FALSE)]
 
  # Loop over each geographic sub-area, training a model on all but
  # one subset of points and then predicting for that subset. Return 
  # a data frame of predictive accuracy rate for each geographic sub-area
  accuracyTable <- ldply(ids, function(i) 
    
    {
    arc.progress_label("Looping through polygons...")
    arc.progress_pos(round((which(i == ids) / length(ids)  * 100), 0))
    
    # Create raining and test sets
    train <- dat[which(dat$id != i), -ncol(dat)]
    test  <- dat[which(dat$id == i),]
    
    # Train model on all but neighborhood "i"
    # Change out delinquent here
    mod <- glm(formula = ivar ~ ., 
               family="binomial"(link="logit"), data = train)
    
    # Predict for neighborhood "i"
    test$pred <- predict(mod, test, type = "response")
    test$prediction <- ifelse(test$pred > predThreshold, 1, 0)
    
    # Validate model predictions
    test$correct <- ifelse(test$prediction == test$ivar, 1, 0)
    
    # Determine neighborhood accuracy rate
    return(mean(test$correct))
    }
  )
  
  # Add geographic subset ID field
  accuracyTable$V2 <- ids 
  names(accuracyTable) <- c("predAccuracy", polyIdField)
  
  # Add field tabulating points per geographic sub-area
  countData <- as.data.frame(t(table(dat$id)))[, 2:3]  
  names(countData)[1] <- polyIdField 
  subGeographyData <- join(countData, accuracyTable, by = polyIdField, type = "inner")
 
  # Join to spPolygon data frame
  spPolys@data <- join(spPolys@data, subGeographyData, by = polyIdField, type = "left")
  spPolys@data$Freq <- ifelse(is.na(spPolys@data$Freq) == TRUE, 0, spPolys@data$Freq)
  spPolys@data$predAccuracy <- ifelse(spPolys@data$Freq < minimumPoints, NA, spPolys@data$predAccuracy)
  
  # Polygons with over a certain number of points
  spPolysFinal <- spPolys[which(spPolys@data$Freq >= minimumPoints), ]
  
  # Define mean and standard deviation accuracy rate
  meanAcc <- round(mean(spPolysFinal$predAccuracy), 3)
  sdAcc <- round(sd(spPolysFinal$predAccuracy), 3)
  
  # Report mean and standard deviation accuracy rates
  print(paste("Average accuracy rate:", meanAcc, sep = " "))
  print(paste("Standard deviation of accuracy rate:", sdAcc, sep = " "))
  
  # Plot histogram of accuracy rates for geographic subsets
  dev.new()
  hist(spPolysFinal$predAccuracy,
       main = "Distribution of predictive accuracy", 
       xlab = "Accuracy rate (within polygon)", 
       ylab = "Count")
  
  # Return shapefile with sub-geographies and associated predictive accuracies
  arc.write(outPutShape, spPolysFinal)
  return(out_params)
}
