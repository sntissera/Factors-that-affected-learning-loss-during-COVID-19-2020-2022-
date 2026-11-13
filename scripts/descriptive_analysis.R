###############################################
##                  STATISTICS               ##
##        Learning loss during COVID-19      ##
###############################################

# Research question:
#   "Which factors were strongly associated with the learning loss
#    during COVID-19 across different countries?"
#
# Response variable : loss
# Statistical unit  : the country (1 row = 1 country, n = 41)
#
# IMPORTANT: the dataset has ONE value per country for each variable, so
# n, mean, median, ... cannot be computed "for each country" (n would be 1).
# They are computed ACROSS the countries, one row per variable (factor),
# and then WITHIN groups of countries (region, OECD).
#
# Output files (folder 'results/'):
#   descriptive_table.csv      n, mean, median, S, Q1, Q3, IQR, outliers per variable
#   descriptive_by_region.csv  same statistics within each region
#   descriptive_by_oecd.csv    same statistics within OECD / non-OECD
#   outliers_list.csv          every outlier: country, variable, value, fences
#   outlier_flags.csv          matrix country x variable (1 = outlier, 0 = not, NA = missing)
#   learning_loss_clean.csv    clean data matrix (values NOT modified, outliers NOT removed)
#   boxplots.pdf               all the box plots

###############################################
#          DESCRIPTION OF THE VARIABLES       #
###############################################
# Unit: the country (n = 41). Source: World Bank study on learning loss
# during COVID-19 (see the data dictionary of the World Bank Microdata Library).
#
# --- IDENTIFIERS ---
# country      : name of the country
# wbcode       : ISO 3-letter country code (ARG, AUS, ...)
# region_code  : world region of the country (6 groups, text labels)
#
# --- RESPONSE ---
# loss         : learning loss = decline in test scores due to school closures,
#                in standard deviations (SD), 2021. Higher = worse
#
# --- CANDIDATE FACTORS ---
# weeks        : average weeks of school closure, 2021
# deaths       : COVID death rate, average 2021 (per 100,000 inhabitants)
# gdp          : GDP per capita, 2020 (US$)
# private      : share of private schools in primary education, 2019 (%)
# internet     : internet users (% of the population)
# hlo          : Harmonized Learning Outcomes score (World Bank): quality of the
#                school system before COVID. Higher = better
# vac          : vaccination rate, average of doses per capita (incl. boosters).
#                Max is 115, so most likely doses per 100 inhabitants
# stringency   : stringency of the lockdown measures (index), average 2021.
#                Higher = stricter measures
# union        : trade union density: union members among employees (%)
#                (all workers, not only teachers). Source: ILO
# polity       : democracy index (polity2), 2018. From -10 (autocracy)
#                to +10 (full democracy)
# pop          : population (number of people)
# schooling    : years of schooling (exact definition not given in the dictionary)
#
# --- CATEGORICAL (0/1) ---
# oecd         : 1 = OECD country, 0 = not OECD (Organisation for Economic Co-operation and Development -> 1 se il paese fa parte dell’OCSE e 0 se non ne fa parte -> È utile per confrontare i due gruppi di paesi)
# high         : 1 = high income country, 0 = not high income
#
# --- TRANSFORMATIONS (do not add information) ---
# loggdp       : log(gdp)
# logweeks     : log(weeks)   [NA for Sweden (weeks = 0) and Australia]
# weeks2       : weeks^2
#
# --- DERIVED FROM hlo AND loss (do NOT use as factors) ---
# hlo25        : hlo / 25
# covid        : hlo - 100 * loss  (contains loss itself: circular)
# covid25      : covid / 25
###############################################

#Import the relevant libraries
library(ggplot2) #to install -> install.packages("ggplot2")

#Set working directory and other repositories
rm(list = ls())
graphics.off()
getwd()
setwd("C:/Users/sntis/Documents/Projects/Uni/AY 26-27/Statistics/Project")

options(scipen = 999)                                                            # removes scientific notation
dir.create('results/plots', showWarnings = FALSE)                                      # output folder

########################
## Data Import/Export ##
########################

# Import the file "learning_loss_covid_database.csv"
# (comma separated, dot as decimal, empty cells = missing values)

learning_loss <- as.data.frame(read.table('learning_loss_covid_database.csv',
                            header = T, sep = ',', dec = '.',
                            quote = '"', na.strings = c('', 'NA')))               
                                                                                 
# Dimensions and variables names
dim(learning_loss)
dimnames(learning_loss)

# Show the first lines
head(learning_loss)
str(learning_loss)

# Name rows using the country labels
rownames(learning_loss) <- learning_loss$country

###########################
## Types of the variables ##
###########################

# Categorical variables: tell R that they are factors
learning_loss$region_code <- as.factor(learning_loss$region_code)                # region_code, oecd and high are categorical so they must be converted to factors
learning_loss$oecd <- factor(learning_loss$oecd, levels = c(0, 1),
                             labels = c('non-OECD', 'OECD'))
learning_loss$high <- as.factor(learning_loss$high)                              # high income country = 1, else = 0

# Quantitative variables: make them all 'numeric'.
# on large values such as the populations -> NA With numeric there is no problem)
quant_all <- names(learning_loss)[sapply(learning_loss, is.numeric)]             
learning_loss[quant_all] <- lapply(learning_loss[quant_all], as.numeric)         
                                                                                 
# Role of each quantitative variable in the analysis 
resp_var     <- 'loss'                                                          
core_vars    <- c('weeks', 'deaths', 'gdp', 'private', 'internet', 'hlo','vac', 
                  'stringency', 'union', 'polity', 'pop', 'schooling')
transf_vars  <- c('loggdp', 'logweeks', 'weeks2')                                
derived_vars <- c('hlo25', 'covid', 'covid25')                                   

### Validation of the dataset ###

# Relationship between transformed variables and derived variables (if zero the relationship is confirmed).
max(abs(learning_loss$hlo25   - learning_loss$hlo / 25))
max(abs(learning_loss$covid   - (learning_loss$hlo - 100 * learning_loss$loss)))
max(abs(learning_loss$covid25 - learning_loss$covid / 25))
max(abs(learning_loss$loggdp  - log(learning_loss$gdp)))
max(abs(learning_loss$weeks2  - learning_loss$weeks^2))

# Checking for missing values
colSums(is.na(learning_loss))     
rownames(learning_loss)[is.na(learning_loss$logweeks)]                           # Sweden (weeks = 0, log not defined) and Australia

### Division of variables ###

#Quantitative variables
quant_vars <- c(resp_var, core_vars, transf_vars, derived_vars)   

# Categorical variables

# absolute and relative frequencies 
table(learning_loss$region_code) #abs
prop.table(table(learning_loss$region_code)) #relative
countries_per_region <- split(learning_loss$country,learning_loss$region_code) #countries by region
countries_per_region

table(learning_loss$oecd)
rownames(learning_loss[learning_loss$oecd == "OECD", ]) #OECD country names
rownames(learning_loss[learning_loss$oecd == "non-OECD", ]) #non-OECD country names

table(learning_loss$high)
rownames(learning_loss[learning_loss$high == 1, ]) #high income countries
rownames(learning_loss[learning_loss$high == 0, ]) #low income countries


##################################################
#        DESCRIPTIVE ANALYSIS ACROSS COUNTRIES
##################################################

summary(learning_loss$loss) #sumamry statistics for loss

# Countries sorted from lowest to highest learning loss
loss_country <- learning_loss[order(learning_loss$loss),c("country", "loss", "region_code")]
min_loss <- loss_country[1,] #country with the minimum loss
print(min_loss)
max_loss <- loss_country[41,] #country with the maximum loss
print(max_loss)

#Barplot: Learning Loss across each country
barplot_ll <- ggplot(learning_loss, aes(x = reorder(country, loss), y = loss)) +
  geom_col(fill = "steelblue") +
  geom_hline(yintercept = mean(learning_loss$loss), colour = "orange",
             linewidth = 0.5,linetype = "dashed") +
  geom_hline(yintercept = median(learning_loss$loss),colour = "#C0392B",
             linewidth = 0.4,linetype = "dashed") + 
  annotate("text",x = 1, y = mean(learning_loss$loss),label = paste("Mean =", round(mean(learning_loss$loss), 3)),
           colour = "orange",vjust = -0.7, hjust = 0) +
  annotate("text",x = 1, y = median(learning_loss$loss),label = paste("Median =", round(median(learning_loss$loss), 3)),
           colour = "#C0392B",vjust = 1.5, hjust = 0) +
  labs(title = "Learning Loss Across Countries",x = "Country",y = "Learning Loss") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 7),plot.title = element_text(hjust = 0.5))
barplot_ll

ggsave(filename = "results/plots/learning_loss_barplot.png",plot = barplot_ll,width = 12,
       height = 7,dpi = 300)

#Calculate the iqr and quantiles for the boxplots
fences <- function(x) {                                                           
  q   <- quantile(x, c(0.25, 0.75), na.rm = TRUE)
  iqr <- unname(q[2] - q[1])                                                      
  c(Q1 = unname(q[1]), Q3 = unname(q[2]), IQR = iqr,
    lower = unname(q[1]) - 1.5 * iqr, upper = unname(q[2]) + 1.5 * iqr)
}

#Identify outliers (TRUE if outlier else FALSE. NA if x is missing)
is_outlier <- function(x) {          
  f <- fences(x)
  x < f['lower'] | x > f['upper']
}

#summary statistics
desc_stats <- function(x) {             
  f <- fences(x)
  c(n       = sum(!is.na(x)),                                                    #Number of countries
    mean     = mean(x, na.rm = TRUE),                                            #mean for each variable
    median   = median(x, na.rm = TRUE),                                          #median for each variable
    S        = sd(x, na.rm = TRUE),                                              #standard deviation for each variable
    Q1       = f['Q1'],
    Q3       = f['Q3'],
    IQR      = f['IQR'],
    n_out    = sum(is_outlier(x), na.rm = TRUE))                                 #number of outliers
}

desc_table <- t(sapply(learning_loss[quant_vars], desc_stats))    
colnames(desc_table) <- c('n', 'mean', 'median', 'S', 'Q1', 'Q3', 'IQR', 'n_outliers')
desc_table <- data.frame(variable = rownames(desc_table), round(desc_table, 4), row.names = NULL)

# Add the type of the variable and countries that are outliers to the summary statistics table(desc table)
desc_table$type <- ifelse(desc_table$variable == resp_var, 'response',
                   ifelse(desc_table$variable %in% core_vars, 'factor',
                   ifelse(desc_table$variable %in% transf_vars, 'transformation', 'derived')))
desc_table$outlier_countries <- sapply(quant_vars, function(v) {
  flag <- is_outlier(learning_loss[[v]])
  paste(rownames(learning_loss)[which(flag)], collapse = ', ')
})
write.table(desc_table, file = 'results/summary_statistics.csv', sep = ';', row.names = FALSE)


#Check if the outlier countries coincide with the outliers found using IQR
same_as_boxplot <- sapply(quant_vars, function(v) {
  x <- learning_loss[[v]]
  identical(sort(x[which(is_outlier(x))]), sort(boxplot(x, plot = FALSE)$out))
})
same_as_boxplot          # if all TRUE then it coincides
if (!all(same_as_boxplot)) warning('Outliers differ from boxplot() for: ',
                                   paste(names(same_as_boxplot)[!same_as_boxplot], collapse = ', ')) #else return a warning message

###############################################################
#     SUMMARY STATISTICS FOR DIFFERENT GROUPS OF COUNTRIES   #
#############################################################

#Calculate the summary statistics for each group of country(region_code, OECD, income)
group_table <- function(group, group_name) {    
  out <- NULL                                   
  for (g in levels(group)) {                    
    for (v in quant_vars) {                     
      x <- learning_loss[[v]][group == g]       
      if (sum(!is.na(x)) < 2) next
      out <- rbind(out, data.frame(group_var = group_name, group = g,
                                   variable = v, t(desc_stats(x))))
    }
  }
  colnames(out)[4:11] <- c('n', 'mean', 'median', 'S', 'Q1', 'Q3', 'IQR', 'n_outliers')
  out[4:11] <- round(out[4:11], 4)
  rownames(out) <- NULL
  out
}

#loss within each region OECD / non-OECD country, high and low income countries
by_region <- group_table(learning_loss$region_code, 'region_code')
by_oecd   <- group_table(learning_loss$oecd, 'oecd')
by_income <- group_table(learning_loss$high,"high")

print(by_region[by_region$variable == 'loss', ], digits = 3, row.names = FALSE)
print(by_oecd[by_oecd$variable == 'loss', ], digits = 3, row.names = FALSE)
print(by_income[by_income$variable == 'loss', ], digits = 3, row.names = FALSE)

write.table(by_region, file = 'results/descriptive_by_region.csv', sep = ';', row.names = FALSE)
write.table(by_oecd,   file = 'results/descriptive_by_oecd.csv',   sep = ';', row.names = FALSE)
write.table(by_income, file = 'results/descriptive_by_income.csv', sep = ';', row.names = FALSE)


##################################################
#                    OUTLIERS                    #
##################################################

# Countries that are outliers for each variable
outlier_flags <- sapply(learning_loss[quant_vars], function(x) as.integer(is_outlier(x))) 
rownames(outlier_flags) <- rownames(learning_loss)
outlier_flags <- data.frame(country = rownames(outlier_flags), outlier_flags, row.names = NULL)
write.table(outlier_flags, file = 'results/outlier_flags.csv', sep = ';', row.names = FALSE)

#The observations that are outliers and their extremities 
outliers_list <- NULL
for (v in quant_vars) {
  x <- learning_loss[[v]]
  f <- fences(x)
  idx <- which(is_outlier(x))
  if (length(idx) > 0) {
    outliers_list <- rbind(outliers_list,
      data.frame(variable = v, country = rownames(learning_loss)[idx], value = unname(x[idx]),
                 lower_fence = round(unname(f['lower']), 4), upper_fence = round(unname(f['upper']), 4),
                 side = ifelse(x[idx] > f['upper'], 'high', 'low')))
  }
}
rownames(outliers_list) <- NULL
print(outliers_list, digits = 4)
write.table(outliers_list, file = 'results/outliers_list.csv', sep = ';', row.names = FALSE)

##################################################
#                   BOX PLOTS                    #
##################################################

#Learning loss in each region
box_region <- function() {
  boxplot(loss ~ region_code, data = learning_loss, las = 1, cex.axis = 0.6,
          xlab = '', ylab = 'loss', main = 'Learning loss by region', 
          col = c("#8ECAE6", "#219EBC", "#90BE6D","#577590", "#B8C0D9", "#A8DADC"))
  stripchart(loss ~ region_code, data = learning_loss, vertical = T,
             method = 'jitter', pch = 16,cex=0.6,col="grey30", add = T)}

#Learning loss in OECD and non-OECD countries
box_oecd <-function(){
  boxplot(loss ~ oecd, data = learning_loss, las = 1,
          xlab = '', ylab = 'loss', main = 'Learning loss: OECD vs non-OECD',
          col = c('plum2', 'slateblue'))
  stripchart(loss ~ oecd, data = learning_loss, vertical = T,
             method = 'jitter', pch = 16, cex=0.6,col="grey30",add = T)
}

#Learning loss in high income and low income countries
box_income <- function(){
  boxplot(loss ~ high, data = learning_loss, las = 1,
          xlab = '', ylab = 'loss', main = 'Learning loss: High vs Low income countries',
          names = c("Low income countries", "High income countries"),col = c("#A8C5B5", "#D89B85"))
  stripchart(loss ~ high, data = learning_loss, vertical = T,
             method = 'jitter', pch = 16, cex=0.6,col="grey30",add = T)
  
}

#Distribution of loss in different regions
png(filename = "results/plots/box_region.png",width = 14,height = 9,units = "in",res = 300)
box_region()
dev.off()

#Distribution of loss in OECD/ non-OECD countries
png(filename = "results/plots/box_oecd.png",width = 14,height = 9,units = "in",res = 300)
box_oecd()
dev.off()

#Distribution of loss in high and low income countries
png(filename = "results/plots/box_income.png",width = 14,height = 9,units = "in",res = 300)
box_income()
dev.off()

#Cleaned data for bivariate analysis
learning_loss_clean <- learning_loss[, c('country', 'wbcode', 'region_code', 'oecd', 'high',resp_var, core_vars, transf_vars, derived_vars)]
write.table(learning_loss_clean, file = 'results/learning_loss_clean.csv',sep = ';', row.names = FALSE)



