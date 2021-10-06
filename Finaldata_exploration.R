
library(lubridate)
library(dplyr)
library(tidyr)
library(tidyverse)
library(htmlwidgets)
library(IRdisplay)
library(plotly) 
library(blogdown)
library(ggplot2)
library(tidymodels)
library(reshape2)
library(moderndive)
#install.packages("htmlwidgets")
#install.packages("MASS")

dataset<-read.csv(("G:\\Covid-19 impact on Digital Learning\\output csv files\\final_dataset.csv"),stringsAsFactors = T)
#str(dataset)
#-----------dataset variables--------------------------
#pct_access -> Percentage of students in the district have at least one page-load event of a given product and on a given day
#engagement_index -> Total page-load events per one thousand students of a given product and on a given day
#pct_black/hispanic -> Percentage of students in the districts identified as Black or Hispanic based on 2018-19 NCES data
#pct_free/reduced -> Percentage of students in the districts eligible for free or reduced-price lunch based on 2018-19 NCES data
#county_connections_ratio -> ratio (residential fixed high-speed connections over 200 kbps in at least one direction/households)
# pp_total_raw -> Per-pupil total expenditure (sum of local and federal expenditure). The expenditure data are school-by-school, 
#and we use the median value to represent the expenditure of a given school district. 
# LC = Learning & Curriculum, CM = Classroom Management, and SDO = School & District Operations

# other dataset links #
#https://www.openicpsr.org/openicpsr/project/119446/version/V75/view;jsessionid=851ECB80E6CB42252D396C29564184DC
#https://www.kff.org/coronavirus-covid-19/issue-brief/state-covid-19-data-and-policy-actions/

#distribution of states and products in dataset
# Number of record for each district--------
state_record<-dataset %>%
  group_by(state) %>%
  summarise(count=n()) %>%
  arrange(-count) 
  #	Connecticut highest count(1212161) , North dakota lowest count(1204)
state_record  # kindly consider the record number while calculating mean.

#Number of records for each product--------
product_record<-dataset %>%
  group_by(Product.Name) %>%
  summarise(count=n()) %>%
  arrange(-count) %>%
  slice(1:20) #Google Docs highest count(57345)
product_record


# what are the TOP 20 products by pct_access ?----------
product_access<- dataset %>%
  select(Product.Name, pct_access, Sector.s., Primary.Essential.Function) %>%
  group_by(Product.Name, Sector.s., Primary.Essential.Function) %>%
  summarise(mean_access=round(mean(pct_access),2),.groups = "drop") %>%
  top_n(n=20) %>%
  arrange(desc(mean_access ))#Google Classroom=17.705 % student load single page in all states


exp_1 <- plot_ly(data=product_access,
                        y = ~mean_access,
                        x = ~Product.Name,
                        type = "bar",
                        color = I("black"),
                        text = ~mean_access, 
                        textposition = 'auto',
                        marker = list(color = "orange",
                                      line = list(color = 'white', width = 1.5)),
                        height = 500,
                        width = 1150
              ) %>%
  layout(
    title = "TOP 20 products <br><sup>by mean percentage access on a given day",
    xaxis = list(title = "",
                 categoryorder = "array",
                 categoryarray = ~mean_access),
    yaxis = list(title = "mean pct_access",gridcolor= "white"),
    showlegend=FALSE
  )
exp_1


# what are the TOP 20 products by engagement_index ?------------
product_engagement<- dataset %>%
  select(Product.Name,engagement_index,Sector.s., Primary.Essential.Function) %>%
  group_by(Product.Name,Sector.s., Primary.Essential.Function) %>%
  summarise(mean_engagement=round(mean(engagement_index)),.groups = "drop") %>%
  top_n(n=20) %>%
  arrange(-mean_engagement)

exp_2 <- plot_ly(data=product_engagement,
                 y = ~mean_engagement,
                 x = ~Product.Name,
                 type = "bar",
                 color = I("black"),
                 text = ~mean_engagement, 
                 textposition = 'auto',
                 marker = list(color = "orange",
                               line = list(color = 'white', width = 1.5)),
                 height = 600,
                 width = 1150
          ) %>%
  layout(
    title = "TOP 20 products <br><sup>by mean engagement index on a given day",
    xaxis = list(title = "",
                 categoryorder = "array",
                 categoryarray = ~mean_engagement),
    yaxis = list(title = "mean engagement_index",gridcolor="white"),
    showlegend=FALSE
  )
exp_2


# Are engagement index and percentage access correlated?----------
#Let's select 10000 random rows from dataset.
#sample_dataset1<- sample_n(dataset,10000) #I comment this line because I dont want ro change Cor value---- 
# Another reason to select random sample dataset is that we can easily analyse scatter plots.

select_variable_1 <- sample_dataset %>%
  select(state,Product.Name,pct_access,engagement_index) #selecting required variables

#correlation between pct_access and engagement_index
select_variable_1 %>% 
  get_correlation(formula = pct_access ~ engagement_index)      #cor=   0.7559273 #this value will change every time with random data

regression_1<- lm(data=select_variable_1,pct_access ~ engagement_index) #fit regression model
get_regression_table(regression_1)  #get regression table

#cross check signs and values (cor=  0.7559273,b1=0.001, intercept/constant=0.651)
#scatter plot
y <- select_variable_1$pct_access
X <- select_variable_1$engagement_index

lm_model <- linear_reg() %>% 
  set_engine('lm') %>% 
  set_mode('regression') %>%
  fit(pct_access ~ engagement_index, data = select_variable_1) 

x_range <- seq(min(X), max(X), length.out = 10000)
x_range <- matrix(x_range, nrow=10000, ncol=1)
xdf <- data.frame(x_range)
colnames(xdf) <- c('engagement_index')

ydf <- lm_model %>% predict(xdf) 

colnames(ydf) <- c('pct_access')
xy <- data.frame(xdf, ydf) 

cor_1<- plot_ly(select_variable_1, 
                x = ~engagement_index, 
                y = ~pct_access, 
                type = 'scatter', 
                alpha = 0.65, 
                mode = 'markers', 
                name = 'Sample points') %>% 
  add_trace(data = xy, 
            x = ~engagement_index, 
            y = ~pct_access, 
            name = 'Regression Fit', 
            mode = 'lines', alpha = 1) %>%
  add_annotations(x = c(35000,35000),
                  y = c(110,10),
                  text = c("Sample Size = 10000 ","correlation=  0.7559273<br>coeff.=0.001<br>intercept=0.651"),
                  showarrow = F)%>%
  layout( title = ("Correlation Between engagement index<br>and percentage of access"),
          xaxis = list(title = "Engagement index"),
          yaxis = list(title = "Percentage of access"))
cor_1







#choose any one variable for analysis, because both variables will behave similar over time.
#How states engage with TOP 10 products in 2020 ? -----------
products_stats_2<-dataset %>% #this table is for our own visuals verification and analysis 
  select(state,district_id,Product.Name,time,engagement_index) %>%
  filter(Product.Name %in% c("Google Docs","Google Classroom","YouTube","Canvas","Schoology",
                             "Meet","Kahoot!","Google Forms","Google Drive","Seesaw : The Learning Journal")) %>%
  group_by(state,Product.Name,time = week(as.Date(time))) %>%
  summarise(min_engagement=min(engagement_index),
            max_engagement=max(engagement_index),
            record_count=n(),
            sum=sum(engagement_index),
            mean_engagement=mean(engagement_index),
            .groups="drop")
 
trend_products_2<-dataset %>%
  filter(Product.Name %in% c("Google Docs","Google Classroom","YouTube","Canvas","Schoology",
                            "Meet","Kahoot!","Google Forms","Google Drive","Seesaw : The Learning Journal")) %>%   #402748 observations
  group_by(state,education_rank,Product.Name,time = week(as.Date(time))) %>%
  summarise(mean=round(mean(engagement_index),2),
            .groups="drop") # mean is calculated for each product in each state for each district(in state) in a given day.

trend_products_2<-trend_products_2 %>%  # I made this table for our understanding and analysis
  spread(key = Product.Name,value = mean)


#fill NA's with zero
trend_products_2[is.na(trend_products_2)]<-0


# rename in column names
colnames(trend_products_2)[colnames(trend_products_2) == "Google Docs"] <- "GoogleDocs"
colnames(trend_products_2)[colnames(trend_products_2) == "Google Classroom"] <-"GoogleClassroom"
colnames(trend_products_2)[colnames(trend_products_2) == "Google Drive"] <- "GoogleDrive"
colnames(trend_products_2)[colnames(trend_products_2) == "Google Forms"] <- "GoogleForms"
colnames(trend_products_2)[colnames(trend_products_2) == "Seesaw : The Learning Journal"] <- "Journal"
colnames(trend_products_2)[colnames(trend_products_2) == "Kahoot!"] <- "Kahoot"

exp_3<- plot_ly(trend_products_2,
              type = 'scatter',
              mode = 'lines',
              width = 1000,
              hight = 600,
              transforms = list(
                list(
                  type = 'filter',
                  target = ~state,
                  operation = 'in',
                  value = unique(trend_products_2$state),
                  title = 'select state'
                )
              ),
              text = ~paste('week: ', time)
)%>%
  add_trace(x = ~time, y = ~GoogleDocs, name = 'Google Docs') %>%
  add_trace(x = ~time, y = ~GoogleClassroom, name = 'Google Classroom') %>%
  add_trace(x = ~time, y = ~GoogleDrive, name = 'Google Drive') %>%
  add_trace(x = ~time, y = ~GoogleForms, name = 'Google Forms') %>%
  add_trace(x = ~time, y = ~Kahoot, name = 'Kahoot!') %>%
  add_trace(x = ~time, y = ~Canvas, name = 'Canvas') %>%
  add_trace(x = ~time, y = ~Journal, name = 'Seesaw:The Learning Journal') %>%
  add_trace(x = ~time, y = ~Meet, name = 'Meet') %>%
  add_trace(x = ~time, y = ~Schoology, name = 'Schoology') %>%
  add_trace(x = ~time, y = ~YouTube, name = 'YouTube') %>%
  layout(title = 'Statewise engagement index for each week<br><sub>for TOP 10 products',
         legend=list(title=list(text='Click on Products'))
         )
options(warn = -1)
exp_3 <- exp_3 %>%
  layout(
    xaxis = list(zerolinecolor = '#ffff',
                 zerolinewidth = 2,
                 gridcolor = 'ffff',
                 title="Weeks in the year 2020"),
    yaxis = list(title="Mean Engagement Index",
                 zerolinecolor = '#ffff',
                 zerolinewidth = 2,
                 gridcolor = 'ffff'),
    plot_bgcolor='#e5ecf6',
    shapes = list(
      list(type = "rect",
           fillcolor = "blue", line = list(color = "blue"), opacity = 0.3,
           x0 = "24", x1 = "30", xref = "x",
           y0 = 0, y1 = 5000, yref = "y"),
      list(type = "rect",
           fillcolor = "blue", line = list(color = "blue"), opacity = 0.3,
           x0 = "10", x1 = "11", xref = "x",
           y0 = 0, y1 = 20000, yref = "y")),
    updatemenus = list(
      list(
        title="Select State",
        type = 'dropdown',
        active = 0,
        buttons = list(
          list(method = "restyle",
               args = list("transforms[0].value", unique(trend_products_2$state)[1]),
               label = unique(trend_products_2$state)[1]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(trend_products_2$state)[2]),
               label = unique(trend_products_2$state)[2]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(trend_products_2$state)[3]),
               label = unique(trend_products_2$state)[3]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(trend_products_2$state)[4]),
               label = unique(trend_products_2$state)[4]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(trend_products_2$state)[5]),
               label = unique(trend_products_2$state)[5]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(trend_products_2$state)[6]),
               label = unique(trend_products_2$state)[6]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(trend_products_2$state)[7]),
               label = unique(trend_products_2$state)[7]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(trend_products_2$state)[8]),
               label = unique(trend_products_2$state)[8]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(trend_products_2$state)[9]),
               label = unique(trend_products_2$state)[9]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(trend_products_2$state)[10]),
               label = unique(trend_products_2$state)[10]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(trend_products_2$state)[11]),
               label = unique(trend_products_2$state)[11]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(trend_products_2$state)[12]),
               label = unique(trend_products_2$state)[12]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(trend_products_2$state)[13]),
               label = unique(trend_products_2$state)[13]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(trend_products_2$state)[14]),
               label = unique(trend_products_2$state)[14]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(trend_products_2$state)[15]),
               label = unique(trend_products_2$state)[15]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(trend_products_2$state)[16]),
               label = unique(trend_products_2$state)[16]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(trend_products_2$state)[17]),
               label = unique(trend_products_2$state)[17]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(trend_products_2$state)[18]),
               label = unique(trend_products_2$state)[18]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(trend_products_2$state)[19]),
               label = unique(trend_products_2$state)[19]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(trend_products_2$state)[20]),
               label = unique(trend_products_2$state)[20]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(trend_products_2$state)[21]),
               label = unique(trend_products_2$state)[21]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(trend_products_2$state)[22]),
               label = unique(trend_products_2$state)[22]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(trend_products_2$state)[23]),
               label = unique(trend_products_2$state)[23])
        )
      )
    )
  ) 
#Build annotation points
holidaypoint <- list(
  x = 28,
  y = 5000,
  text = 'holidays',
  xref = "x",
  yref = "y",
  showarrow = TRUE
)
covidpoint <-list(
  x = 10,
  y = 20000,
  text = 'Covid-19 weeks',
  xref = "x",
  yref = "y",
  showarrow = T,
  font = list (family = 'Arial',
               size = 14,
               color = toRGB("Red"))
)
exp_3 <- exp_3 %>% layout (annotations = holidaypoint) %>% layout(annotations = covidpoint)
exp_3



#Trends  engagement index and percentage of black/Hispanic -------
select_variable_2 <- sample_dataset1 %>%
  select(state,pct_black.hispanic,engagement_index) #selecting required variables

stats2<- lm(engagement_index~pct_black.hispanic,select_variable_2)
get_regression_table(stats2)
# osm,districts with higher population of non white people had positive relation with percentage of access.
# And white people are negatively related to percentage of access.
# why are only non white peoples districts access  positive?
# Lets start with filtering data for black/hispanic.

z1<- dataset %>%
  group_by(state,pct_black.hispanic) %>%
  summarise(count=n(),.groups = "drop") #category 80-100% has less numbers of records 

#outliers will affect our analysis if we calculate mean.
#calculate mean value for a given week
y1<-dataset %>% # this table is for our understanding
  select(time,pct_black.hispanic,engagement_index) %>%
  group_by(time=week(as.Date(time)),pct_black.hispanic) %>%
  summarise(mean_enga=round(mean(engagement_index),2),.groups = "drop") 

y1<-y1 %>%  # I made this table for our understanding and analysis
  spread(key = pct_black.hispanic,value = mean_enga)

# rename in column names
colnames(y1)[colnames(y1) == "0-20%"] <- "p20"
colnames(y1)[colnames(y1) == "20-40%"] <-"p40"
colnames(y1)[colnames(y1) == "40-60%"] <- "p60"
colnames(y1)[colnames(y1) == "60-80%"] <- "p80"
colnames(y1)[colnames(y1) == "80-100%"] <- "p100"


exp_4<- plot_ly(y1,
              type = 'scatter',
              mode = 'line',
              width = 1000,
              hight = 600,
              text = ~paste('week: ', time)
              )%>%
  add_trace(x = ~time, y = ~p40, name = '20-40%') %>%
  add_trace(x = ~time, y = ~p60, name = '40-60%') %>%
  add_trace(x = ~time, y = ~p80, name = '60-80%') %>%
  add_trace(x = ~time, y = ~p20, name = '0-20%') %>%
  add_trace(x = ~time, y = ~p100, name = '80-100%',type='scatter', mode = 'lines',
            fill = 'tonexty', fillcolor='rgba(0,100,80,0.2)',
            showlegend = T) %>%
  layout(title = 'Weekly Black/Hispanic students engagement index',
         legend=list(title=list(text='Select category'))
         )
options(warn = -1)
exp_4 <- exp_4 %>%
  layout(
    xaxis = list(zerolinecolor = '#ffff',
                 zerolinewidth = 2,
                 gridcolor = 'ffff',
                 title="Weeks in the year 2020"),
    yaxis = list(title="Mean Engagement Index",
                 zerolinecolor = '#ffff',
                 zerolinewidth = 2,
                 gridcolor = 'ffff'),
    plot_bgcolor='#e5ecf6')

#point annotation
text<-blackpoint <-list(
  x = 40,
  y = 0,
  text = 'This chart diverging our analysis because<br>only 19 black/hispanic schools in dataset<br>mean value affected by outliers',
  xref = "x",
  yref = "y",
  showarrow = F,
  font = list (family = 'Arial',
               size = 12,
               color = toRGB("grey50")))

blackpoint <-list(
  x = 35,
  y = 606,
  text = 'Unexpected engagement index for 80-100% category ',
  xref = "x",
  yref = "y",
  showarrow = T,
  font = list (family = 'Arial',
               size = 12,
               color = toRGB("grey50")))
exp_4 <-exp_4 %>% layout(annotations = blackpoint) %>% layout(annotations = text)
exp_4


#lets find out districts with pct_blact.hispanic more than 50%.----
blackhispanic_states<- dataset %>% 
     filter(pct_black.hispanic %in% c("60-80%","80-100%")) %>%
     group_by(state,education_rank,district_id,pct_black.hispanic) %>%
     summarise(mean_enga=mean(engagement_index),count=n(),.groups = "drop") 
#19 districts are black/hispanic out of 176 (9 states)
#it is huge difference so that mean values for 80-100% category got affected.
# The new approach is that just select this 9 states and compare engagement data.
y3<- dataset %>%
     filter(state %in% c("Arizona","California","Connecticut","District Of Columbia","Illinois",
                         "New York","Indiana","Texas","Virginia")) %>%
     select(state, education_rank, pct_black.hispanic, time, engagement_index ) %>%
     group_by(state, education_rank,pct_black.hispanic, time = week(as.Date(time))) %>%
     summarise(mean_enga=round(mean(engagement_index),2),.groups = "drop")

y3<-y3 %>%  # I made this table for our understanding and analysis
  spread(key = pct_black.hispanic,value = mean_enga)

#fill NA's with zero
y3[is.na(y3)]<-0

# rename in column names
colnames(y3)[colnames(y3) == "0-20%"] <- "p20"
colnames(y3)[colnames(y3) == "20-40%"] <-"p40"
colnames(y3)[colnames(y3) == "40-60%"] <- "p60"
colnames(y3)[colnames(y3) == "60-80%"] <- "p80"
colnames(y3)[colnames(y3) == "80-100%"] <- "p100"


exp_5<- plot_ly(y3,
                type = 'scatter',
                mode = 'lines',
                width = 1000,
                hight = 600,
                text = ~paste('week:',time,
                            'Education rank:',education_rank),
                transforms = list(
                  list(
                    type = 'filter',
                    target = ~state,
                    operation = 'in',
                    value = unique(y3$state),
                    title = "title"
                  )
                )
)%>%
  add_trace(x = ~time, y = ~p20, name = '0-20%') %>%
  add_trace(x = ~time, y = ~p40, name = '20-40%') %>%
  add_trace(x = ~time, y = ~p60, name = '40-60%') %>%
  add_trace(x = ~time, y = ~p80, name = '60-80%') %>%
  add_trace(x = ~time, y = ~p100, name = '80-100%',type='scatter', mode = 'lines',
            fill = 'tonexty', fillcolor='rgba(0,100,80,0.2)',
            showlegend = T) %>%
  layout(title = 'Engagement index for black/hispanic states',
         legend=list(title=list(text='Select category'))
  )
options(warn = -1)
exp_5 <- exp_5 %>%
  layout(
    xaxis = list(zerolinecolor = '#ffff',
                 zerolinewidth = 2,
                 gridcolor = 'ffff',
                 title="Weeks in the year 2020"),
    yaxis = list(title="Mean Engagement Index",
                 zerolinecolor = '#ffff',
                 zerolinewidth = 2,
                 gridcolor = 'ffff'),
    plot_bgcolor='#e5ecf6',
    updatemenus = list(
      list(
        type = 'dropdown',
        active = 0,
        buttons = list(
          list(method = "restyle",
               args = list("transforms[0].value", unique(y3$state)[1]),
               label = unique(y3$state)[1]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(y3$state)[2]),
               label = unique(y3$state)[2]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(y3$state)[3]),
               label = unique(y3$state)[3]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(y3$state)[4]),
               label = unique(y3$state)[4]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(y3$state)[5]),
               label = unique(y3$state)[5]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(y3$state)[6]),
               label = unique(y3$state)[6]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(y3$state)[7]),
               label = unique(y3$state)[7]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(y3$state)[8]),
               label = unique(y3$state)[8]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(y3$state)[9]),
               label = unique(y3$state)[9])
        )
      )
    )
  )
exp_5




# Trends by pct_free.reduced------------
z2<- dataset %>%
  filter(pct_free.reduced!="0") %>%
  group_by(state,pct_free.reduced) %>%
  summarise(count=n(),.groups = "drop") #category 80-100% has less numbers of records 

#outliers will affect our analysis if we calculate mean.
#calculate mean value for a given week
y2<-dataset %>%
  filter(pct_free.reduced!="0") %>% # this table is for our understanding
  select(time,pct_free.reduced,engagement_index) %>%
  group_by(time=week(as.Date(time)),pct_free.reduced) %>%
  summarise(mean_enga=round(mean(engagement_index),2),.groups = "drop") 

y2<-y2 %>%  # I made this table for our understanding and analysis
  spread(key = pct_free.reduced,value = mean_enga)

# rename in column names
colnames(y2)[colnames(y2) == "0-20%"] <- "p20"
colnames(y2)[colnames(y2) == "20-40%"] <-"p40"
colnames(y2)[colnames(y2) == "40-60%"] <- "p60"
colnames(y2)[colnames(y2) == "60-80%"] <- "p80"
colnames(y2)[colnames(y2) == "80-100%"] <- "p100"


exp_6<- plot_ly(y2,
                type = 'scatter',
                mode = 'line',
                width = 1000,
                hight = 600,
                text = ~paste('week: ', time)
)%>%
  add_trace(x = ~time, y = ~p40, name = '20-40%') %>%
  add_trace(x = ~time, y = ~p60, name = '40-60%') %>%
  add_trace(x = ~time, y = ~p80, name = '60-80%') %>%
  add_trace(x = ~time, y = ~p20, name = '0-20%') %>%
  add_trace(x = ~time, y = ~p100, name = '80-100%',type='scatter', mode = 'lines',
            fill = 'tonexty', fillcolor='rgba(0,100,80,0.2)',
            showlegend = T) %>%
  layout(title = 'Weekly free/reduced students engagement index',
         legend=list(title=list(text='Select category'))
  )
options(warn = -1)
exp_6 <- exp_6 %>%
  layout(
    xaxis = list(zerolinecolor = '#ffff',
                 zerolinewidth = 2,
                 gridcolor = 'ffff',
                 title="Weeks in the year 2020"),
    yaxis = list(title="Mean Engagement Index",
                 zerolinecolor = '#ffff',
                 zerolinewidth = 2,
                 gridcolor = 'ffff'),
    plot_bgcolor='#e5ecf6')
exp_6
#point annotation
text<-blackpoint <-list(
  x = 40,
  y = 0,
  text = 'This chart diverging our analysis because<br>only 19 black/hispanic schools in dataset<br>mean value affected by outliers',
  xref = "x",
  yref = "y",
  showarrow = F,
  font = list (family = 'Arial',
               size = 12,
               color = toRGB("grey50")))

blackpoint <-list(
  x = 35,
  y = 606,
  text = 'Unexpected engagement index for 80-100% category ',
  xref = "x",
  yref = "y",
  showarrow = T,
  font = list (family = 'Arial',
               size = 12,
               color = toRGB("grey50")))
exp_6 <-exp_6 %>% layout(annotations = blackpoint) %>% layout(annotations = text)
exp_6


# 80-100% showing higher engagement because of outliers in dataset
# let find states and districts with higher free/reduced students.----
freereduced<-dataset %>%
              select(state,district_id, pct_free.reduced,engagement_index)%>%
              filter(pct_free.reduced %in% c("60-80%","80-100%"))%>%
              group_by(state, district_id, pct_free.reduced) %>%
              summarise(c=n(),.groups = "drop")# distribution is not good. # verify by ggplot
#9 states and 17 districts are in higher free/reduced category
#Let's do analysis at school level
#find schools with higher pct_free.reduced
freereduced1<- dataset %>%
                filter(district_id %in% c("4550","7164","7975","3248","5042","8784",
                                    "9043","2870","3222","4808","6144","3550","9536",
                                    "6584","7767","1791","2130")) %>%
                group_by(district_id,pct_free.reduced,time=week(as.Date(time))) %>%
                summarise(mean_enga=round(mean(engagement_index),2),.groups = "drop") 

freereduced1<-freereduced1 %>%  # I made this table for our understanding and analysis
  spread(key = pct_free.reduced,value = mean_enga)

#fill NA's with zero
freereduced1[is.na(freereduced1)]<-0

# rename in column names
colnames(freereduced1)[colnames(freereduced1) == "60-80%"] <- "p80"
colnames(freereduced1)[colnames(freereduced1) == "80-100%"] <- "p100"
str(freereduced1)
freereduced1$district_id<-as.factor(freereduced1$district_id)

exp_7<- plot_ly(freereduced1,
               type = 'scatter',
               mode = 'line',
               width = 1000,
               hight = 600,
               text = ~paste('week: ', time),
               transforms = list(
                 list(
                   type = 'filter',
                   target = ~district_id,
                   operation = 'in',
                   value = unique(freereduced1$district_id),
                   title = "title"
                 )
               )
)%>%
  add_trace(x = ~time, y = ~p80, name = '60-80%') %>%
  add_trace(x = ~time, y = ~p100, name = '80-100%',type='scatter', mode = 'lines',
            fill = 'tonexty', fillcolor='rgba(0,100,80,0.2)',
            showlegend = T) %>%
  layout(title = 'Engagement index for higher free/reduced Schools',
         legend=list(title=list(text='Select category'))
  )
options(warn = -1)
exp_7 <- exp_7 %>%
  layout(
    xaxis = list(zerolinecolor = '#ffff',
                 zerolinewidth = 2,
                 gridcolor = 'ffff',
                 title="Weeks in the year 2020"),
    yaxis = list(title="Mean Engagement Index",
                 zerolinecolor = '#ffff',
                 zerolinewidth = 2,
                 gridcolor = 'ffff'),
    plot_bgcolor='#e5ecf6')
exp_7 <- exp_7 %>%
  layout(
    xaxis = list(zerolinecolor = '#ffff',
                 zerolinewidth = 2,
                 gridcolor = 'ffff',
                 title="Weeks in the year 2020"),
    yaxis = list(title="Mean Engagement Index",
                 zerolinecolor = '#ffff',
                 zerolinewidth = 2,
                 gridcolor = 'ffff'),
    plot_bgcolor='#e5ecf6',
    shapes = list(
      list(type = "rect",
           fillcolor = "grey", line = list(color = "grey"), opacity = 0.5,
           x0 = "24", x1 = "30", xref = "x",
           y0 = 0, y1 = 100, yref = "y"),
      list(type = "rect",
           fillcolor = "grey", line = list(color = "grey"), opacity = 0.5,
           x0 = "10",x1 = "11", xref = "x",
           y0 = 0, y1 = 100, yref = "y")),
    updatemenus = list(
      list(
        type = 'dropdown',
        active = 0,
        buttons = list(
          list(method = "restyle",
               args = list("transforms[0].value", unique(freereduced1$district_id)[1]),
               label = unique(freereduced1$district_id)[1]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(freereduced1$district_id)[2]),
               label = unique(freereduced1$district_id)[2]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(freereduced1$district_id)[3]),
               label = unique(freereduced1$district_id)[3]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(freereduced1$district_id)[4]),
               label = unique(freereduced1$district_id)[4]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(freereduced1$district_id)[5]),
               label = unique(freereduced1$district_id)[5]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(freereduced1$district_id)[6]),
               label = unique(freereduced1$district_id)[6]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(freereduced1$district_id)[7]),
               label = unique(freereduced1$district_id)[7]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(freereduced1$district_id)[8]),
               label = unique(freereduced1$district_id)[8]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(freereduced1$district_id)[9]),
               label = unique(freereduced1$district_id)[9]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(freereduced1$district_id)[10]),
               label = unique(freereduced1$district_id)[10]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(freereduced1$district_id)[11]),
               label = unique(freereduced1$district_id)[11]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(freereduced1$district_id)[12]),
               label = unique(freereduced1$district_id)[12]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(freereduced1$district_id)[13]),
               label = unique(freereduced1$district_id)[13]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(freereduced1$district_id)[14]),
               label = unique(freereduced1$district_id)[14]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(freereduced1$district_id)[15]),
               label = unique(freereduced1$district_id)[15]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(freereduced1$district_id)[16]),
               label = unique(freereduced1$district_id)[16]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(freereduced1$district_id)[17]),
               label = unique(freereduced1$district_id)[17])
        )
      )
    )
  )
#Build annotation points
holidaypoint2 <- list(
  x = 28,
  y = 100,
  text = 'holidays',
  xref = "x",
  yref = "y",
  showarrow = T
)
covidpoint2 <-list(
  x = 10,
  y = 100,
  text = 'Covid-19 weeks',
  xref = "x",
  yref = "y",
  showarrow = T,
  font = list (family = 'Arial',
               size = 14,
               color = toRGB("Red"))
)
exp_7 <- exp_7 %>% layout (annotations = holidaypoint2) %>% layout(annotations = covidpoint2)
exp_7 <- exp_7 %>% layout( annotations = freepoint)
exp_7
#point annotation
freepoint <-list(
  x = 10,
  y = 250,
  text = 'Number of states: 9<br>Number of schools: 17',
  xref = "x",
  yref = "y",
  showarrow = F,
  font = list (family = 'Arial',
               size = 12,
               color = toRGB("grey50")))




#find schools with lower pct_free.reduced-----
freereduced2<- dataset %>%
  filter(!district_id %in% c("4550","7164","7975","3248","5042","8784",
                            "9043","2870","3222","4808","6144","3550","9536",
                            "6584","7767","1791","2130")) %>%
  group_by(pct_free.reduced,time=week(as.Date(time))) %>%
  summarise(mean_enga=round(mean(engagement_index),2),.groups = "drop") %>%
  filter(pct_free.reduced!="0")

freereduced2<-freereduced2 %>%  # I made this table for our understanding and analysis
  spread(key = pct_free.reduced,value = mean_enga)

#fill NA's with zero
freereduced2[is.na(freereduced2)]<-0

# rename in column names
colnames(freereduced2)[colnames(freereduced2) == "0-20%"] <- "p20"
colnames(freereduced2)[colnames(freereduced2) == "20-40%"] <-"p40"
colnames(freereduced2)[colnames(freereduced2) == "40-60%"] <- "p60"

exp_8<- plot_ly(freereduced2,
                type = 'scatter',
                mode = 'line',
                width = 1000,
                hight = 600,
                text = ~paste('week: ', time)
)%>%
  add_trace(x = ~time, y = ~p20, name = '0-20%') %>%
  add_trace(x = ~time, y = ~p40, name = '20-40%') %>%
  add_trace(x = ~time, y = ~p60, name = '40-60%') %>%
  layout(title = 'Engagement index for lower free/reduced Schools',
         legend=list(title=list(text='Select category'))
  )
options(warn = -1)
exp_8 <- exp_8 %>%
  layout(
    xaxis = list(zerolinecolor = '#ffff',
                 zerolinewidth = 2,
                 gridcolor = 'ffff',
                 title="Weeks in the year 2020"),
    yaxis = list(title="Mean Engagement Index",
                 zerolinecolor = '#ffff',
                 zerolinewidth = 2,
                 gridcolor = 'ffff'),
    plot_bgcolor='#e5ecf6'
    )
exp_8<- exp_8 %>% layout(annotations = freepoint1)
exp_8
#point annotation
freepoint1 <-list(
  x = 10,
  y = 450,
  text = 'Number of states: 23<br>Number of schools: 131',
  xref = "x",
  yref = "y",
  showarrow = F,
  font = list (family = 'Arial',
               size = 12,
               color = toRGB("grey50")))




#Trends in pp_total_raw (expenditure sum for each school  )---------------
y4<-dataset %>%
  filter(pp_total_raw !="0")  %>%
  group_by(pp_total_raw) %>%
  summarise(c=n())
#let do analysis by expenditure categories
totalraw1<-dataset %>% 
              filter (pp_total_raw!="0") %>%
              select(pp_total_raw,engagement_index,time) %>%
              group_by(pp_total_raw,time=week(as.Date(time))) %>%
              summarise(mean_enga=round(mean(engagement_index),2),.groups = "drop") 

exp_9<- plot_ly(totalraw1,
                x = ~time,
                y = ~mean_enga,
                type = 'scatter',
                mode = 'line',
                fill = 'tonexty', 
                fillcolor='rgba(0,100,80,0.2)',
                width = 1000,
                hight = 500,
                text = ~paste('week: ', time),
                transforms = list(
                  list(
                    type = 'filter',
                    target = ~pp_total_raw,
                    operation = 'in',
                    value = unique(totalraw1$pp_total_raw)
                  )
                )
)
options(warn = -1)
exp_9 <- exp_9 %>%
  layout(title = 'Engagement index by expenditure of schools',
    xaxis = list(zerolinecolor = '#ffff',
                 zerolinewidth = 2,
                 gridcolor = 'ffff',
                 title="Weeks in the year 2020"),
    yaxis = list(title="Mean Engagement Index",
                 zerolinecolor = '#ffff',
                 zerolinewidth = 2,
                 gridcolor = 'ffff'),
    plot_bgcolor='#e5ecf6',
    updatemenus = list(
      list(
        title="Select State",
        type = 'dropdown',
        active = 0,
        buttons = list(
          list(method = "restyle",
               args = list("transforms[0].value", unique(totalraw1$pp_total_raw)[1]),
               label = unique(totalraw1$pp_total_raw)[1]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(totalraw1$pp_total_raw)[2]),
               label = unique(totalraw1$pp_total_raw)[2]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(totalraw1$pp_total_raw)[3]),
               label = unique(totalraw1$pp_total_raw)[3]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(totalraw1$pp_total_raw)[4]),
               label = unique(totalraw1$pp_total_raw)[4]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(totalraw1$pp_total_raw)[5]),
               label = unique(totalraw1$pp_total_raw)[5]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(totalraw1$pp_total_raw)[6]),
               label = unique(totalraw1$pp_total_raw)[6]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(totalraw1$pp_total_raw)[7]),
               label = unique(totalraw1$pp_total_raw)[7]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(totalraw1$pp_total_raw)[8]),
               label = unique(totalraw1$pp_total_raw)[8]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(totalraw1$pp_total_raw)[9]),
               label = unique(totalraw1$pp_total_raw)[9]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(totalraw1$pp_total_raw)[10]),
               label = unique(totalraw1$pp_total_raw)[10]),
          list(method = "restyle",
               args = list("transforms[0].value", unique(totalraw1$pp_total_raw)[11]),
               label = unique(totalraw1$pp_total_raw)[11]),
          list(method = "restyle")
        )
      )
    )
  )
exp_9



#calculating engagement index increase or decrease  by expenditure in 2020
lower_expenditure_schools<-dataset %>% 
  select(pp_total_raw,engagement_index,time) %>%
  group_by(pp_total_raw,time=week(as.Date(time))) 
  
lower_march_eng<-lower_expenditure_schools%>% #calculating mean from march to may 
  filter(time %in% c("8","9","10","11","12","13","14","15","16","17","18","19","20"),pp_total_raw!="0")%>%
  group_by(pp_total_raw) %>%
  summarise(mean_mar=round(mean(engagement_index),2)) 

lower_sept_eng<-lower_expenditure_schools%>% #calculating mean from mid sept to mid november
  filter(time %in% c("34","35","36","37","38","39","40","41","42","43","44","45"),pp_total_raw!='0')%>%
  group_by(pp_total_raw)%>%
  summarise(mean_sept=round(mean(engagement_index),2))

join1<-lower_march_eng %>% inner_join(lower_sept_eng,"pp_total_raw")

join1<-join1%>%mutate(difference_enga_percentage=round(((mean_sept-mean_mar)/mean_mar)*100,2))

exp_10 <- plot_ly(data=join1,
                 y = ~difference_enga_percentage,
                 x = ~pp_total_raw,
                 type = "bar",
                 color = I("black"),
                 text = ~difference_enga_percentage, 
                 textposition = 'auto',
                 marker = list(color = c('rgba(219, 64, 82, 0.7)','rgba(50, 171, 96, 1.0)',
                                         'rgba(50, 171, 96, 1.0)','rgba(50, 171, 96, 1.0)',
                                         'rgba(50, 171, 96, 1.0)','rgba(50, 171, 96, 1.0)',
                                         'rgba(219, 64, 82, 0.7)','rgba(50, 171, 96, 1.0)',
                                         'rgba(219, 64, 82, 0.7)','rgba(50, 171, 96, 1.0)',
                                         'rgba(50, 171, 96, 1.0)'),
                               line = list(color = 'white', width = 1.5)),
                 height = 500,
                 width = 800
) %>%
  layout(
    title = "Effect of COVID-19 on engagement<br> index by expenditure of schools",
    xaxis = list(title = "Expenditure category",
                 categoryorder = "array",
                 categoryarray = ~difference_enga_percentage),
    yaxis = list(title = "Percentage of <br>mean engagement index",gridcolor= "white"),
    showlegend=FALSE
  )
#point annotation
freepoint3 <-list(
  x = c('10K-12K','4K-6K','22K-24K'),
  y = c(-20,-25,-35),
  text = c('schools From<br>Illinois<br>Michigan<br>North Carolina<br>Utah<br>Virginia<br>Wisconsin','Schools From Utah','Schools From<br>New York and <br>Massachusetts'),
  xref = "x",
  yref = "y",
  showarrow = F,
  font = list (family = 'Arial',
               size = 12,
               color = toRGB("black")))
exp_10<- exp_10 %>% layout(annotations = freepoint3)
exp_10

#why 22K-24K, 4K-6K, 10K-12K  affected more ?
k22K24<-dataset %>%
        filter(pp_total_raw %in% c("22K-24K")) %>%
        select(state,education_rank,district_id,pct_black.hispanic,pct_free.reduced)%>%
        group_by(state,education_rank,district_id,pct_black.hispanic,pct_free.reduced)%>%
        summarise(count=n(),.groups = "drop")%>%
  select(state,education_rank,district_id,pct_black.hispanic,pct_free.reduced)
#new york and Massachusetts affected more due to Covid-19.

k4K6<-dataset %>%
  filter(pp_total_raw %in% c("4K-6K")) %>%
  select(state,education_rank,district_id,pct_black.hispanic,pct_free.reduced)%>%
  group_by(state,education_rank,district_id,pct_black.hispanic,pct_free.reduced)%>%
  summarise(count=n(),.groups = "drop")%>%
  select(state,education_rank,district_id,pct_black.hispanic,pct_free.reduced)
#schools from utah affect due to covid-19.

k10K12<-dataset %>%
  filter(pp_total_raw %in% c("10K-12K")) %>%
  select(state,education_rank,district_id,pct_black.hispanic,pct_free.reduced)%>%
  group_by(state,education_rank,district_id,pct_black.hispanic,pct_free.reduced)%>%
  summarise(count=n(),.groups = "drop")%>%
  select(state,education_rank,district_id,pct_black.hispanic,pct_free.reduced)





#How many products gain or loose engagement index throughout the pandemic COVID-19?----

products_covid_march<-dataset %>% 
  filter(week(as.Date(time)) %in% c("8","9","10","11","12","13","14","15","16","17","18","19","20")) %>%
  select(Product.Name,engagement_index) %>% 
  group_by(Product.Name) %>% 
  summarise(mean_enga_march=round(mean(engagement_index),2)) %>%
  arrange(desc(mean_enga_march)) #351 products were used by students (period march to may) 
  
products_covid_sept<-dataset %>% 
  filter(week(as.Date(time)) %in% c("34","35","36","37","38","39","40","41","42","43","44","45")) %>%
  select(Product.Name,engagement_index) %>% 
  group_by(Product.Name) %>% 
  summarise(mean_enga_sept=round(mean(engagement_index),2)) %>%
  arrange(desc(mean_enga_sept)) #368 products were used by students (period mid-Sept to mid-Nov) 
# 17 New products launched/don't have records for period march during pandemic :-)

#join dataframes
products_covid<- products_covid_sept %>%
                 left_join(products_covid_march,"Product.Name")
#368 products, this data set contains NA's, because some products dont have records for period march. 
#fill NA's with zero
products_covid[is.na(products_covid)]<-0

#Lets find products having no records in march
products_norecord_launched<-products_covid[products_covid$mean_enga_march=="0",]
#17 products check.

products_covid<-products_covid %>%
                filter(mean_enga_march!="0") %>%
                mutate(incresed_engagement=round((mean_enga_sept-mean_enga_march)/mean_enga_march*100,2))
products_covid<-products_covid %>% arrange(desc(Product.Name))                

#products_covid$Product.Name<-as.character(products_covid$Product.Name)

#Let's filter Our 23 favorite products and show some charts
my_product_covid_positive<- products_covid %>%
  filter(Product.Name %in% c("Google Docs","Canvas","Schoology","Meet",
                             "Seesaw : The Learning Journal","Zoom","i-Ready",
                             "ST Math","Google Sheets","Epic! - Unlimited Books for Kids",
                             "Big Ideas Math"))
my_product_covid_negative<- products_covid %>%
  filter(Product.Name %in% c("Google Classroom","Kahoot!","Google Forms","Google Drive","ClassLink","Clever",
                             "Google Sites","Securly Anywhere Filter","Lexia Core5 Reading","PowerSchool",
                             "Quizlet","Edpuzzle"))


exp_11 <- my_product_covid_positive %>% 
  plot_ly(width = 800, height = 500,hoverinfo = 'text',
          text = ~paste('</br> March-May: ', mean_enga_march,
                        '</br> Sept.-Nov.: ', mean_enga_sept,
                        '</br> Percentage increase in engagement: ', incresed_engagement)) %>% 
  add_trace(x = ~Product.Name, y = ~mean_enga_march, type = 'bar',
                         name = "March-May<br>engagement index",
                         marker = list(color = 'rgb(158,202,225)',
                                       line = list(color = 'rgb(8,48,107)', width = 1.5))) %>% 
  add_trace(x = ~Product.Name, y = ~mean_enga_sept, type = 'bar',
                         name = "Sept.-Nov.<br>engagement index",
                         marker = list(color = 'rgb(58,200,225)',
                                       line = list(color = 'rgb(8,48,107)', width = 1.5))) %>% 
  layout(title = "Products with increased engagement index",
                      barmode = 'group',
                      xaxis = list(title = "Products"),
                      yaxis = list(title = "Mean Engagement index"),
                      legend = list(x = 0.5, y = 0.9))
exp_11

exp_12 <- my_product_covid_negative %>% 
  plot_ly(width = 800, height = 500,hoverinfo = 'text',
          text = ~paste('</br> March-May: ', mean_enga_march,
                        '</br> Sept.-Nov.: ', mean_enga_sept,
                        '</br> Percentage decrease in engagement: ', incresed_engagement)) %>% 
  add_trace(x = ~Product.Name, y = ~mean_enga_march, type = 'bar',
            name = "March-May<br>engagement index",
            marker = list(color = 'rgba(50, 171, 96, 1.0)',
                          line = list(color = 'rgb(8,48,107)', width = 1.5))) %>% 
  add_trace(x = ~Product.Name, y = ~mean_enga_sept, type = 'bar',
            name = "Sept.-Nov.<br>engagement index",
            marker = list(color = 'rgba(219, 64, 82, 0.7)',
                          line = list(color = 'rgb(8,48,107)', width = 1.5))) %>% 
  layout(title = "Products with decreased engagement index",
         barmode = 'group',
         xaxis = list(title = "Products"),
         yaxis = list(title = "Mean Engagement index"),
         legend = list(x = 0.5, y = 0.9))
exp_12













