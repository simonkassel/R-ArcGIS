**How to Use It**

If you have never used the R-Bridge you will need to (very easily) [install it] (https://github.com/R-ArcGIS/r-bridge-install) before adding this tool. After you have done this, you will need to download the toolbox (.tbx file) R script and sample data to your machine. When you unzip the folder and connect to it in ArcGIS, you can navigate to it you will see a toolbox called "Arc-R_Toolbox.tbx" and within it is a "Logistic Regression_Spatial Test Set." You will need to redirect the tool to the R script you have recently downloaded. You can do this by right-clicking on the script in arc-catalog and clicking on "properties." In the window that pops up, click on the "source" tab and under "Script File:" navigate to the file called "Arc-R_spatial_test_set_sk_Jan17.R." The tool is now ready to run. 

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
