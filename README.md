# R-ArcGIS
A couple of years ago, ESRI announced that it was developing a tool that would allow it's users to connect between ArcGIS and R. With the R-ArcGIS Bridge, users can read and write shapefiles and tables to and from ArcGIS from an R console. They can also create ArcGIS tools from R scripts. This package makes it possible to access R's vast array of statistical tools from within ArcGIS.

As a regular user of both R and ArcGIS, I was intrigued by the  potential that this bridge had to improve workflow for spatial analysis. I decided to test it out by building a tool using the new package. I have provided a demo of how the tool works in the post below but if you'd like to see the source code or try it for yourself you can download everything from my GitHub.

**A Spatial Test Set**

When developing predictive models, we often use cross-validation which helps us measure how consistently a model performs when trained and tested on a number of random training and test sets. When the trend we predict for is spatially auto-correlated we may also want to test to see if there is a spatial bias to the model. Ideally, the model will predict as accurately for an outcome at location X as it does for an outcome at location Y, regardless of how far apart they are. To test this, we can use a similar method to the aforementioned cross-validation but instead of randomly generating training and test sets we can create them based on geography. 

**The Tool**

This tool allows its user to perform this exact type of spatial test for logistic regression. The user inputs a point shapefile which includes a binary outcome field that he would like to model. This shapefile should also include predictor variables, including (perhaps) spatial variables that are easy to generate ahead of time in ArcGIS. The other input is a set of polygons to divide the points up spatially.

In the example I show below, I use a points dataset of a random sample of properties in Philadelphia, PA. I create a very simple model to predict whether or not these properties where tax delinquent in the year 2016. I divide them up using a neighborhood polygons shapefile. For each neighborhood, I divide the whole dataset up into a training set comprised of all properties that are not in the neighborhood and a test set of those that are. I train the model on the training set and predict delinquent or not delinquent. Using a user defined threshold, I classify the resulting predicted probabilities into binary outcomes before comparing those outcomes to the know results. Finally, I determine an accuracy rate for the neighborhood based on how many properties I classified correctly.

The tool outputs this set of neighborhoods and their associated rates of predictive accuracy. We can consider the results non-spatially by looking at the histogram of accuracy rates: how consistent are the predictions from neighborhood to neighborhood? We can also consider them spatially by mapping predictive accuracy with the output shapefile. A good model will account for the spatial autocorrelation in tax delinquency and we will see that error is dispersed randomly. If the model does have a spatial bias we will see that error is clustered. The model will predict more accurately in some parts of the city than in others. 

**How to Use It**

If you have never used the R-Bridge you will need to (very easily) install it before adding this tool. After you have done this, you will need to download the toolbox (.tbx file) R script and sample data to your machine. When you unzip the folder and connect to it in ArcGIS, you can navigate to it you will see a toolbox called "Arc-R_Toolbox.tbx" and within it is a "Logistic Regression_Spatial Test Set." You will need to redirect the tool to the R script you have recently downloaded. You can do this by right-clicking on the script in arc-catalog and clicking on "properties." In the window that pops up, click on the "source" tab and under "Script File:" navigate to the file called "Arc-R_spatial_test_set_sk_Jan17.R." The tool is now ready to run. 

You can open up the tool menu by double clicking it. This will reveal the following menu (without the fields completed):

![](https://github.com/simonkassel/R-ArcGIS/blob/master/Images/tool_menu.png)
