# COVID-19 Impact on Digital Learning (Sept.2021) 

# Problem Statement
The COVID-19 Pandemic has disrupted learning for more than 56 million students in the United States. In the Spring of 2020, most states and local governments across the U.S. closed educational institutions to stop the spread of the virus. In response, schools and teachers have attempted to reach students remotely through distance learning tools and digital platforms. Until today, concerns of the exacaberting digital divide and long-term learning loss among America’s most vulnerable learners continue to grow.


A. Data Preparation
Objectives of Data preparation:-

1. Cleaning provided datasets

2. Process the data (e.g., merging) and additional data sources accurately

3. Using the right methodologies for deleting rows

4. Increasing data integrity

5. Write an easy and reproducible code

Data preparation starts from importing data into the Kaggle notebook. Data sets used in this notebook are from Learn platform. Some additional data sets used here are state education rank and closing dates for state schools in the USA. Named these files as external datasets. How to join these data sets and What are the keys for connecting them, everything is shown in the Data joining diagram.

District info data file Preparation:- This dataset contains 233 rows 7 columns. Columns are ranges for each sub-category. In the cleaning process, brackets are removed and assigned variables that we can understand. This file also contains 57 NaN rows (57 schools hide by data provider). These rows are deleted from our dataset. Percentage of free/reduced, Percentage of black/Hispanic, Expenditure total, connection ratio columns contains missing values. As we know some of these variables do not apply to all states in the USA. So that if there is a missing value for a particular state then we fill these missings by zeros. This makes sense because some states are well developed, there is the possibility that these variables are not applicable. After processing this file contain 176 schools with all variable.

The distribution of districts(Schools) shows that Connecticut has 30 schools whereas North Dakota, Minnesota, etc has only one school. This may create a discrepancy in our analysis. So make a note that whenever I aggregate data at the state level it won't diverge my analysis.

Product info data file Preparation:- Only product URL variable is deleted from dataset.

Engagement file Preparation:-

It is a list of the percentage of access and engagement index for each product in schools. From the data set, we assume that if the percentage of access is zero then engagement is also zero. So that product with zero percentage of access is deleted in the engagement file. We use this approach because this data set is quite large. Deleting rows makes our processing bit a faster. In simple words, we are helping our machines to reduce processing time.

B. Data Exploration
Objectives Of Data exploration:-

Distribution of states and products in table format.
Number of record for each state by district.
Number of records for each product.
what are the TOP 20 products by pct_access ?
what are the TOP 20 products by engagement_index ?
How TOP 10 products engage with their audience in 2020 by state ?
Are engagement index and percentage access correlated?
How states engage with TOP 10 products in 2020 ?

B.1. Distribution of variables in the dataset
In the final data set, many records are unevenly distributed across all states. Connecticut has the highest number of records whereas North Dakota has a thousand records. This may increase data visualization discrepancy if we calculate mean values for states.
In the final data set, records for the TOP 20 products are evenly distributed. Google Docs has the highest number of records, which means this product is used mostly by students. Let's do analysis for TOP 20 products

B.2. What are the TOP 23 products by access/engagement index?
I choose TOP 23 products because last 4 product has same percentage access. It might be helpful in our analysis.
