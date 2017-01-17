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

- The **Points** field identifies the point dataset that you will model. In this case it is a dataset of properties in Philadelphia.
- Specify which variable you will predict for using the **Independent Variable** field. This must be a binary numeric variable in which 0 indicates one outcome and 1 indicates another. In this case it identifies whether a property was tax delinquent (1) or not tax delinquent (0).
- In the **Dependent Variables** field you will indicate which variable(s) to use as predictors. All of these variables must not include any incomplete cases. In this simple model we will predict tax delinquency using the property's distance to the Central Business District and the vacancy rate in a property's Census Tract.
- The **Polygons** field indicates which geography you will use to group points. In this case it is the neighborhoods of Philadelphia.
- You will specify which field to group polygons by with the **Polygon ID** Field. If each polygon is distinct (as is the case in this example) you will use a unique identifier field (like "NAME"). However you can choose to group them by any field, regardless of if the groups are contiguous or not.
- The **Minimum Points** field allows you to specify the threshold for the minimum number of points that fall into a polygon for it to be included in the test set. Given that some "neighborhoods" in Philadelphia are comprised of exclusively park space of a few industrial properties, there may be very few points in a given polygon. If this is the case the resulting accuracy rate for that neighborhood may not be meaningful. 
- In the **Prediction Threshold** field you will specify a cutoff point that will determine how you classify predicted outcomes from probabilities. In this case properties that have a predicted probability of 0.25 or higher will be predicted to be tax delinquent and those with a probability below it will be classified as not tax delinquent.
- Finally, in the **Output Polygon** Shapefile field, you will specify the location and name of the shapefile that includes an accuracy rate field.

![](https://github.com/simonkassel/R-ArcGIS/blob/master/Images/histogram.png)

After running the script, the tool reports the average and standard deviation accuracy rates among the spatial test set of polygons. In this case the average rate among neighborhoods was 63.4% and the set had a standard deviation of 22.4%.  It also plots a histogram of these accuracy rates. Given that this sample model was exceedingly simple, it's no surprise that predictive accuracy was inconsistent from neighborhood to neighborhood.

![](https://github.com/simonkassel/R-ArcGIS/blob/master/Images/accuracy_map.png)

The tool also outputs a polygon shapefile that includes fields for predictive accuracy as well as the number of points within each polygon. Note that some neighborhoods from the original shapefile are not included in the output. As I mentioned before, these neighborhoods have very few properties within them and as a result we did not calculate an accuracy rate for them. We can look at the spatial pattern of predictive by mapping these neighborhoods by accuracy rate. At first glance we can see that the model performs much better in the northern-most neighborhoods of the city while it is fairly dispersed in South and West Philadelphia. Applying spatial statistics tools in ArcGIS would allow us to analyze theses patterns with added rigor.
