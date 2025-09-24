### More detail on the analysis process

1. First created a folder to hold the final cleaning file and a readme file to document the EDA process
- created a python notebook file
- imported all the necessary libraries for the project
- read the modify zip-code csv file using pandas(pd.read_csv)
2. CREATED A NEW FEATURE (Borough)
- using the actual ACE violation dataset Joined to another dataset I found on the NYC open-data that represent all the zip-code by borough in NYC. Next I used the two csv’s and the .map() python to replace the actual borough for each bus_route_id. The new feature will help to find more insights in the analysis. for example I can use the new column to count the number of violation for each borough or find if there is a correlation between the borough and the time of the violation.
[Modified_Zip_Code_Tabulation_Areas__MODZCTA__20250919_csvfile](https://data.cityofnewyork.us/Health/Modified-Zip-Code-Tabulation-Areas-MODZCTA-/pri4-ifjk/data_preview)
3. handling missing values
- I first check the numbers of missing values and next decided to delete them because i didn’t have a lot of data missing, in a total of 3M rows i had only around 66k of missing ess in the vehicule_id column and around 10k in the bus_route_id column, all that data represent less than 5% of the total data in the dataset so even deleted i will not affect our analysis or skew the data or introduce bias.
