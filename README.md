# A Statistical Analysis of the factors that affected learning loss during COVID – 19 (2020-2022).

Research Question: Which factors were strongly associated with the learning loss during COVID-19 across different countries?

## Dataset

Dataset: [Argentina, Australia, Bangladesh...and 38 more \- Learning Loss COVID-19 2020-2022](https://microdata.worldbank.org/catalog/5367/study-description)**

**Citation:** Patrinos, H., & . (2023). *Learning Loss COVID-19 2020-2022* \[Dataset\]. World Bank, Development Data Group. https\://doi.org/10.48529/WBNM-CN45

## Stakeholders (people or organizations who are affected by the issue or could use the results)

* Education policy makers

* Governments

* Schools

* Universities

## Data Analysis

1. **Explorative Analysis** \-\> Descriptive statistics ***Deadline: Nov 16th***

2. **Inferential Analysis** \-\> Hypothesis Testing/ Regression ***Deadline: Dec 30th***

 **Responsibilities:**

* Antonietta \- Data preparation and descriptive analysis  
* Alessandro \- Bivariate Exploratory analysis  
* Saraya \-   
* Michela \- 

**Presentation**

1. Introduction

2. Research question

3. Stakeholders

4. Explorative Analysis

5. Inferential Analysis

6. Discussion and Conclusion

**Data preparation and descriptive analysis**

*What to do:* 

* *Import the data*  
* *Calculate the mean, median and standard deviation for each variable.*  
* *Create boxplots for each variable across different countries and compare them.*

#### **General information about the dataset**

Response variable \- loss  
Statistical unit \-  country  
Number of samples \- 41  
Number of variables \- 24

Variable names:

1. Identifiers  
* **country**: name of the country  
* **wbcode**: ISO 3-letter country code (ARG, AUS, ...)  
* **region\_code**: world region of the country (6 groups, text labels)


2. Response  
* **loss:** learning loss \= decline in test scores due to school closures in standard deviations (2021). \[Higher \= worse\]

3. Candidate factors  
   3.1 Core variables  
* **weeks**: average weeks of school closure (2021)   
* **deaths**: average COVID death rate (2021) (per 100,000 inhabitants)  
* **gdp**: GDP per capita (2020) (USD)  
* **private**: share of private schools in primary education (2019) (%)  
* **internet** : internet users (% of the population)  
* **hlo**: Harmonized Learning Outcomes score (World Bank): quality of the school system before COVID \[Higher \= better\]  
* **vac**: vaccination rate (average of doses per capita incl. boosters. Max is 115, so most likely doses per 100 inhabitants)  
* **stringency**: average stringency of the lockdown measures (index) (2021).\[Higher \= stricter measures\]  
*  **union:** trade union density: union members among employees (%) (all workers, not only teachers). Source: ILO  
* **polity**: democracy index (polity2) (2018). \[-10 (autocracy) to \+10 (full democracy)\]  
*  **pop:** population (number of people)  
* **schooling:** years of schooling (exact definition not given in the dictionary)

       
3.2 Categorical

* **oecd :** 1 \= OECD country, 0 \= not OECD (Organisation for Economic Co-operation and Development)  
* **high** : 1 \= high income country, 0 \= not high income

3.3 Transformed variables (data that were transformed from original data)

* **loggdp**: log(gdp)  
* **logweeks**: log(weeks)   \[NA for Sweden (weeks \= 0\) and Australia\]  
* **weeks2**: weeks^2 


3.4 Derived variables from **hlo** and **loss**

* **hlo25**: hlo / 25  
* **covid**: hlo \- 100 \* loss   
* **covid25:** covid / 25

***Don’t use gdp, logweeks, weeks, hlo25, covid, covid25 as factors when doing the analysis.*** 

### **Results**

**Data import and cleaning**

1. **Missing values:** logweeks \= NA for Australia and Sweden  
2. **Absolute and relative frequencies by region\_code (Number of countries per region):**

| Region\_code | Countries | Abs. Freq  | Rel. Freq |
| :---- | :---- | ----- | ----- |
| Advanced Economies | Australia, Belgium, Canada, Denmark, England, Finland, France, Germany, Greece, Italy, Japan, Netherlands, Norway, Spain, Sweden, Switzerland, Turkey, United States | 18 | 0.43902439 |
| East Asia and the Pacific | Cambodia, China, Indonesia, Korea | 4 | 0.09756098 |
| Europe and Central Asia | Czech, Hungary, Poland, Russia | 4 | 0.09756098 |
| Latin America and the Caribbean | Argentina, Brazil, Chile, Colombia, Mexico | 5 | 0.12195122 |
| South Asia | Bangladesh, India, Nepal | 3 | 0.07317073 |
| Sub-Saharan Africa | Botswana, Ethiopia, Ghana, Kenya, Malawi, South Africa, Uganda | 7 | 0.17073171 |

3. **Countries by OECD or not:**  
* Non \- OECD countries: 17 (Argentina, Bangladesh, Botswana, Brazil, Cambodia, China, Colombia, Ethiopia, Ghana, India, Indonesia, Kenya, Malawi, Nepal, Russia, South Africa, Uganda).    
* OECD countries: 24 (Australia, Belgium, Canada, Chile, Czech, Denmark, England, Finland, France, Germany, Greece, Hungary, Italy, Japan, Korea, Mexico, Netherlands, Norway, Poland, Spain, Sweden, Switzerland, Turkey, United States)  
4. **Countries by income:**   
* High income: 17 (Australia, Belgium, Canada, Denmark, England, Finland, France, Germany, Greece, Italy, Japan, Netherlands, Norway, Spain, Sweden, Switzerland, United States)  
* Low income: 24 (Argentina, Bangladesh, Botswana, Brazil, Cambodia, Chile, China, Colombia, Czech, Ethiopia, Ghana, Hungary, Indonesia, India, Kenya, Korea, Malawi, Mexico, Nepal, Poland, Russia, South Africa, Turkey, Uganda)

**Descriptive Analysis across countries**

**![][image1]**

**\*** loss  \= decline in test scores due to school closures in standard deviations.

* Highest loss was experienced by Nepal with a loss of 0.8.  
* The lowest loss was experienced by Sweden with a loss of 0\.  
* Italy ranked 18th on the scale with a loss of 0.19 which is relatively less with respect to the median value so it's placed on the low learning loss side.  
* The distribution of the loss is heterogenous as we can see that the loss across each country was different among each other

**![][image2]**

| Region | Mean  | Median  | Standard deviation |
| :---- | :---- | :---- | :---- |
| Advanced Economies | 0.1506 | 0.1750 | 0.1041 |
| East Asia and the Pacific | 0.2050 | 0.1650 | 0.1794 |
| Europe and Central Asia | 0.1775 | 0.1650 | 0.0911 |
| Latin America and the Caribbean | 0.3240 | 0.3200 | 0.0838 |
| South Asia | 0.5333 | 0.5200 | 0.2603 |
| Sub-Saharan Africa | 0.2629 | 0.2500 | 0.1249 |

* The highest learning loss among the 6 different regions was experienced by South Asian countries with a median of 0.5200 and lowest loss was for the countries in East Asia and the Pacific Region and Europe and Central Asia regions with a median of 0.165.  
* However a significant variation was observed between the two countries from the standard deviations where East Asian and the Pacific experienced a higher variability than Europe and Central Asia.  
* The impact of COVID 19 was not uniform across different regions of the world as some regions experienced higher loss, where some lower loss and others a moderate loss.

**![][image3]**

| Category | Mean | Median | Standard deviation |
| :---- | :---- | :---- | :---- |
| Non-OECD | 0.3171 | 0.2800 | 0.1772 |
| OECD | 0.1629 | 0.1750 | 0.1100 |

* Countries that are not part of OECD experienced the highest loss with a median of 0.2800. Their variability in loss was also high among its countries  
* Countries that are a part of OECD experienced a lower loss with a median of 0.1750. The variability was low among the countries.

| Income | Mean | Median | Standard deviation |
| :---- | :---- | :---- | :---- |
| Non-high income | 0.2900 | 0.2650 | 0.1685 |
| High income | 0.1376 | 0.1700 | 0.0912 |

* Countries with lower income experienced the highest loss with a median of 0.2650 and a high variability among its countries.  
* Countries with high income experienced a lower loss with a median of 0.1700 and it shows a lower variability among its countries, so the impact of the pandemic was less uniform across these countries.

*Outliers are only FLAGGED, not removed: with 41 real countries, removing them is a decision to take in the bivariate analysis (e.g. Nepal for 'loss').*

**Changes made to the code:**

1\. Edited some comments and cleaned the code to look better and readable.

2\. The data structure for the dataset was not defined initially so it was converted to a dataframe (learning\_loss \<- as.dataframe….)

3\. Added a code to retrieve country names based on region, oecd and income.

4\. Added a barplot for learning loss across countries.

5\. Changed the file name of descriptive\_table.csv to summary\_statistics.csv since it made more sense.

6\. Created a descriptive table for high and low income countries since the numbers of countries in each category looked correlated with the OECD non OECD countries. We can look into it in the bivariate analysis.

7.Removed the individual boxplots for each variable since we can’t extract much information from them individually.

8\. Separated the boxplots that were together for each region and OECD/ NON OECD. Also I added another boxplot for Loss vs high and low income.

9\. Created a folder called plots inside results so that all the plots are saved as .png individually. In this way its easy to add images to the presentation than having the plots in a pdf.

10\. Summary loss was moved to the top before the barplot since its important and removed the countries \<= first quartile since its not very important. I also added a code to extract the countries with minimum and maximum loss.

**Bivariate Analysis**

*What to do:*

1. *Create scatter plots for loss vs the 12 candidate core variables. Add a linear trend line for each plot.*  
2. *Carry out a correlation analysis using Pearson correlation coefficient for each pair of variables.*   
3. *Describe the direction and strength of the observed linear association and its relationship (linear or not) in a tabular format.*

Note:

1. Response: Loss, Candidate variables: core\_vars. Therefore be sure to plot the scatter plots for the 12 core variables. Check [general information about the dataset]() to understand about the variables.  
2. **DO NOT USE** 'covid', 'covid25', 'hlo25', 'hlo', loggdp', 'logweeks' and 'weeks2'' as they are derived and transformed variables from the above core variables.  
3. Use learning\_loss\_clean.csv file to carry out the analysis since it contains the cleaned data.

**Results:**

| Variable | Pearson Correlation | Spearman Correlation | P value | Direction | Association | Nature |
| :---- | :---- | :---- | :---- | :---- | :---- | :---- |
| weeks | 0.644 | 0.605 | 0.000 | \+ | Strong | Linear (slight concavity for high values; influential India) |
| deaths | \-0.087 | 0.011 | 0.5868 | Negligible | weak | No evident relationship |
| loggdp | \-0.517 | \-0.466 | 0.0005 | \- | moderate | broadly decreasing association  |
| private | 0.101 | 0.104 | 0.5293 | Negligible | weak | No evident relationship |
| internet | \-0.438 | \-0.408 | 0.0042 | \- | moderate | Approximately linear with some dispersion |
| hlo | \-0.311 | \-0.371 | 0.0478 | \- | weak | Weakly linear with high dispersion |
| vac | \-0.322 | \-0.264 | 0.0400 | \- | weak | Weakly linear with high dispersion |
| stringency | 0.177 | 0.181 | 0.2677 | \+ | Very weak | No evident relationship, very weak |
| union | \-0.119 | \-0.078 | 0.4591 | \- | Very weak | No linear relationship, heterogenous dispersion |
| polity | \-0.222 | \-0.413 | 0.1623 | \- | weak | Non linear, less informative |
| pop | 0.204 | 0.166 | 0.2018 | \+ | weak | No relationship but dominated by China and India (outlier) |
| schooling | \-0.565 | \-0.563 | 0.0001 | \- | Moderate | Linear |

* **Loss vs weeks** showed the strongest positive association. Countries with longer school closures tend to have greater learning loss.   
* **Loss vs schooling** showed the strongest negative associations. Countries with more years of schooling tend to have lower learning loss.   
* **Loss vs gdp** showed a moderate negative, broadly decreasing association.  
* **Loss vs internet** showed a moderate negative and linear association.Countries with greater internet access tend to have lower learning loss.   
* The variables showed little to no evident relationship between loss.

**Changes made to the code:**

1. Used log gdp and log pops values instead of just gdp and pops as they resulted in better results.  
2. Changed a line in a code that plotted the scatter plot to indicate the standard error.

**Discussion (Answer to the research question):**

**Explorative Analysis:**

* Learning loss is not distributed uniformly across countries.  
* Learning loss varied considerably across geographical regions and socioeconomic classifications.  
* The results for the loss among OECD membership groups and income group comparison were consistent with each other. Non high income countries and non OECD countries displayed a higher median loss and greater variability than their comparative group. Both comparisons suggest a similar pattern but they are not two completely independent pieces of evidence.  
* The exploratory analysis identified four variables showing relatively strong associations with learning loss which are school closure duration, GDP per capita, internet access and years of schooling. Longer school closures were positively associated with learning loss, whereas GDP, internet access and schooling showed negative associations. These variables were therefore selected as candidates for further investigation using linear regression. 

**What to expect in the inferential analysis:**

* Fit a multiple linear regression model using the four selected variables to test the overall association between the selected variables across all the countries and also across each geographic region.  
* Chi-square test of independence to test whether OECD and income status classification are associated.

\*t-test to test whether learning loss is distributed equally in each category (OECD and income)

**Inferential Analysis:**

* **Linear  Regression**  
* **Hypothesis Testing**


