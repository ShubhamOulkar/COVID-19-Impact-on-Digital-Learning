# --------------------District file data preparation---------------------------------------------
library(here)
library(dplyr)
library(tidyr)
library(tidyverse)
library(blogdown)

b<-read.csv("G:\\kaggle project\\districts_info.csv")

#quick check
summary(b)
b$state<-factor(b$state)
b$district_id<-factor(b$district_id)
str(b) #  24 states (including NaN category ) and 233 districts in data set(including 57 NaN districts)
       
b$pct_black.hispanic<-gsub("\\[","",b$pct_black.hispanic)
b$pct_black.hispanic<-gsub(",","",b$pct_black.hispanic)

b[b$pct_black.hispanic =="0 0.2","pct_black.hispanic" ]<-"0-20%"
b[b$pct_black.hispanic =="0.2 0.4","pct_black.hispanic" ]<-"20-40%"
b[b$pct_black.hispanic =="0.4 0.6","pct_black.hispanic" ]<-"40-60%"
b[b$pct_black.hispanic =="0.6 0.8","pct_black.hispanic" ]<-"60-80%"
b[b$pct_black.hispanic =="0.8 1","pct_black.hispanic" ]<-"80-100%"

b$pct_free.reduced<-gsub("\\[","",b$pct_free.reduced)
b$pct_free.reduced<-gsub(",","",b$pct_free.reduced)

b[b$pct_free.reduced =="0 0.2","pct_free.reduced" ]<-"0-20%"
b[b$pct_free.reduced =="0.2 0.4","pct_free.reduced" ]<-"20-40%"
b[b$pct_free.reduced =="0.4 0.6","pct_free.reduced" ]<-"40-60%"
b[b$pct_free.reduced =="0.6 0.8","pct_free.reduced" ]<-"60-80%"
b[b$pct_free.reduced =="0.8 1","pct_free.reduced" ]<-"80-100%"

b$county_connections_ratio<-gsub("\\[","",b$county_connections_ratio)
b$county_connections_ratio<-gsub(",","",b$county_connections_ratio)

b[b$county_connections_ratio =="0.18 1","county_connections_ratio" ]<-"Less internet connections"
b[b$county_connections_ratio =="1 2","county_connections_ratio" ]<-"More internet connections"
b[b$county_connections_ratio=="More internet connections",] #North dakota

b$pp_total_raw<-gsub("\\[","",b$pp_total_raw)
b$pp_total_raw<-gsub(",","",b$pp_total_raw)

b[b$pp_total_raw =="4000 6000","pp_total_raw" ]<-"4K-6K"
b[b$pp_total_raw =="6000 8000","pp_total_raw" ]<-"6K-8K"
b[b$pp_total_raw =="8000 10000","pp_total_raw" ]<-"8K-10K"
b[b$pp_total_raw =="10000 12000","pp_total_raw" ]<-"10K-12K"
b[b$pp_total_raw =="12000 14000","pp_total_raw" ]<-"12K-14K"
b[b$pp_total_raw =="14000 16000","pp_total_raw" ]<-"14K-16K"
b[b$pp_total_raw =="16000 18000","pp_total_raw" ]<-"16K-18K"
b[b$pp_total_raw =="18000 20000","pp_total_raw" ]<-"18K-20K"
b[b$pp_total_raw =="20000 22000","pp_total_raw" ]<-"20K-22K"
b[b$pp_total_raw =="22000 24000","pp_total_raw" ]<-"22K-24K"
b[b$pp_total_raw =="24000 26000","pp_total_raw" ]<-"24K-26K"
b[b$pp_total_raw =="26000 28000","pp_total_raw" ]<-"26K-28K"
b[b$pp_total_raw =="28000 30000","pp_total_raw" ]<-"28K-30K"
b[b$pp_total_raw =="32000 34000","pp_total_raw" ]<-"32K-34K"



summary(b) # state shows 57 NaN's
NAN_district<-b[b$pct_black.hispanic=="NaN",] #57 rows
#we will remove 57 districts in our analysis 




#---------------pct_free_missing values-------------

missing_to_fill_free_reduced<- b  %>%
  select(district_id,state,locale,pct_free.reduced) %>%
  filter(pct_free.reduced=="") #28 missing values
#Let's check for possibility to fill NA's. We don't want any randomness in any values.If all records
#for particular state matches with missing_to_fill_free frame NA's. Then we will put zeros in place of NA's.
#Because pct_free.reduced may not be  applicable to particular state.

b%>% #21 districts, no records, we cant fill missing 
  filter(state=="Massachusetts")
  
b%>%#3 districts, no records , cant fill missing
  filter(state=="District Of Columbia")

b%>% #1 district, no record
  filter(state=="Arizona")

b%>% #1 district dont have records district id= 2060
  filter(state=="Ohio")

b%>% #2 district, no record
  filter(state=="Missouri")
#verified 28 districts don't have record for pct_free.reduced
#fill empty cell with 0 
b[b$pct_free.reduced=="","pct_free.reduced"]<-0



#---------------internet connection missing values------------------
missing_to_internet<- b  %>%
  select(district_id,state,locale,county_connections_ratio)%>%
  filter(county_connections_ratio=="") #14 missing values
#we will check all possibilities with other variables, then fill that empty raw.  
b%>% #1 district, no record
  filter(state=="Missouri",locale=="Suburb")
# 1 missing filled
b[b$district_id=="1044","county_connections_ratio"]<-"Less internet connections"
  
b%>% #4 district, no record, district_id=5527,2439,2517,9927
  filter(state=="Massachusetts",locale=="Suburb")
#4 mising filled
b[b$district_id %in%c("5527","2439","2517","9927"),"county_connections_ratio"]<-"Less internet connections"

b%>% #2 district, no record, district_id==3936,9140
  filter(state=="Connecticut",locale=="Suburb")
#2 missing filled
b[b$district_id %in%c("3936","9140"),"county_connections_ratio"]<-"Less internet connections"

b%>% #2 district, no record, district_id==6046,5934
  filter(state=="Connecticut",locale=="Rural")
#2 missing filled
b[b$district_id %in%c("6046","5934"),"county_connections_ratio"]<-"Less internet connections"

b%>% #2 district, no record, district_id==2257,2940
  filter(state=="New York",locale %in%c("Suburb","Rural"))
#2missing filled
b[b$district_id %in%c("2257","2940"),"county_connections_ratio"]<-"Less internet connections"

b%>% #2 district, no record, district_id==7970,2991
  filter(state=="Ohio",locale=="Suburb")
#2 missing filled
b[b$district_id %in%c("7970","2991"),"county_connections_ratio"]<-"Less internet connections"

b%>% #1 district, no record, district_id==1791
  filter(state=="Virginia")

#Virginia cell with Less internet connections because maximum districts have this type of connections.
b[b$county_connections_ratio=="","county_connections_ratio"]<-"Less internet connections"


#------------------pp_total_raw missing values--------------
missing_to_total<- b  %>%
  select(district_id,state,locale,pp_total_raw)%>%
  filter(pp_total_raw=="") #58 missing values
#Let's check for possibility to fill NA's. We don't want any randomness in any values.If all records
#for particular state matches with missing_to_total data frame NA's. Then we will put zeros in place of NA's.
#Because pp_total_raw may not be  applicable to particular state.
b%>% #11 district, no record
  filter(state=="Ohio")
b%>% #12 district, no record
  filter(state=="California")
b%>% #30 district, no record
  filter(state=="Connecticut")
b%>% #1 district, no record
  filter(state=="North Dakota")
b%>% #2 district, no record
  filter(state=="New Hampshire")
b%>% #1 district, no record, district id=9536
  filter(state=="New York")
b%>% #1 district, no record, district id=9007
  filter(state=="Arizona")
#total 58 missing values
#fill empty cell with 0
b[b$pp_total_raw=="","pp_total_raw"]<-0


#--------------joining rank and close date data files------

a<-read.csv(here("G:\\kaggle project\\","state_rank_education.csv"))
c<-read.csv(here("G:\\kaggle project\\","close_date.csv"))

state_rank_CloseDate<-c %>%
                     left_join(a,by="state")

district<- b%>%
            left_join(state_rank_CloseDate,by="state")

district<-district %>%
  separate(k.12.close.date,c("year","month","date"),remove = T)%>%
  rename(close_month="month",
         close_date="date")%>%
  rename(education_rank="rank")

district[,"year"]<-NULL # remove year column


str(district)
district$district_id<-factor(district$district_id)

district$education_rank<-as.factor(district$education_rank)

str(district) # district_id = 233 levels and ranks 22.

district<-district %>%
  mutate(
    close_month=
      recode(close_month,
             "03"="March"
      )
  )%>%
  mutate(close_week=round(as.numeric(close_date)/7))%>%
  mutate(
    close_week=
      recode(close_week,
             "2"="2nd week",
             "3"="3rd week"
      )
  )%>%
  unite(state_education_rank,state,education_rank,remove=F)
  

district$district_id<-as.character(district$district_id)
#back to character because we need to join data frames of same datatype

#filter NaN rows
district<-district %>%
  filter(state != "NaN")

#Quick checks
summary(district) #176 districts in 23 states
str(district) 

##Number of districts in in each state
district_count<-district %>%
  group_by(state)%>%
  summarise(district_count=n())%>%
  arrange(-district_count)
district_count

#----------------------product file data preparation-----------
p<-read.csv(here("G:\\kaggle project\\","products_info.csv"),stringsAsFactors = T,na.strings = c(""))

#quick check
str(p) # 372 products, 290 companies 
p_NA<-p[!complete.cases(p),] # 20 products have NA's
levels(p$Sector.s.) # 5 sectors
levels(p$Primary.Essential.Function) # 35 categories

#conveting columns to character data type
p$Provider.Company.Name<-as.character(p$Provider.Company.Name)
p$Sector.s.<-as.character(p$Sector.s.)
p$Primary.Essential.Function<-as.character(p$Primary.Essential.Function)
str(p)

#step by step filling missing values
#True North Logic
p[p$LP.ID=="36254","Provider.Company.Name"]<-"True North Logic"
p[p$LP.ID=="36254","Sector.s."]<-"PreK-12"
p[p$LP.ID=="36254","Primary.Essential.Function"]<-"SDO - Learning Management Systems (LMS)"
#Google Science Journal
p[p$LP.ID=="45811","Primary.Essential.Function"]<-"LC - Study Tools"
p[p$LP.ID=="45811","Sector.s."]<-"PreK-12"
#Google Training Center
p[p$LP.ID=="84099","Primary.Essential.Function"]<-"CM - Teacher Resources - Professional Learning"
p[p$LP.ID=="84099","Sector.s."]<-"PreK-12; Higher Ed; Corporate"
#Microsoft Office 365
p[p$LP.ID=="85991","Primary.Essential.Function"]<-"LC - Sites, Resources & Reference - Digital Collection & Repository"
p[p$LP.ID=="85991","Sector.s."]<-"Corporate"
#IXL Language
p[p$LP.ID=="33562","Primary.Essential.Function"]<-"LC - Study Tools - Tutoring"
p[p$LP.ID=="33562","Sector.s."]<-"PreK-12"
#Yelp
p[p$LP.ID=="83394","Primary.Essential.Function"]<-"LC/CM/SDO - Other"
p[p$LP.ID=="83394","Sector.s."]<-"Corporate"
#True North Logic
p[p$LP.ID=="63178","Primary.Essential.Function"]<-"SDO - Data, Analytics & Reporting - Student Information Systems (SIS)"
p[p$LP.ID=="63178","Sector.s."]<-"Corporate"
#Education Genius
p[p$LP.ID=="32340","Primary.Essential.Function"]<-"LC - Digital Learning Platforms"
p[p$LP.ID=="32340","Sector.s."]<-"PreK-12; Higher Ed; Corporate"
#classzone Houghton Mifflin Harcourt
p[p$LP.ID=="37891","Primary.Essential.Function"]<-"LC - Digital Learning Platforms"
p[p$LP.ID=="37891","Sector.s."]<-"PreK-12; Higher Ed"
#classdojo for students
p[p$LP.ID=="45716","Primary.Essential.Function"]<-"CM - Virtual Classroom - Video Conferencing & Screen Sharing"
p[p$LP.ID=="45716","Sector.s."]<-"PreK-12; Higher Ed"
#Flipgrid One- microsoft
p[p$LP.ID=="68845","Primary.Essential.Function"]<-"LC - Digital Learning Platforms"
p[p$LP.ID=="68845","Sector.s."]<-"PreK-12; Higher Ed"
#Adobe Spark Page
p[p$LP.ID=="53399","Primary.Essential.Function"]<-"LC - Content Creation & Curation"
p[p$LP.ID=="53399","Sector.s."]<-"PreK-12; Higher Ed"
#College Compass
p[p$LP.ID=="92918","Primary.Essential.Function"]<-"SDO - Admissions, Enrollment & Rostering"
p[p$LP.ID=="92918","Sector.s."]<-"PreK-12; Higher Ed"
#Grammarly for Chrome
p[p$LP.ID=="87762","Primary.Essential.Function"]<-"LC - Sites, Resources & Reference - Thesaurus & Dictionary"
p[p$LP.ID=="87762","Sector.s."]<-"PreK-12; Higher Ed;Corporate"
#MaxPreps: Connecticut
p[p$LP.ID=="78730","Primary.Essential.Function"]<-"LC - Sites, Resources & Reference - Games & Simulations"
p[p$LP.ID=="78730","Sector.s."]<-"PreK-12; Higher Ed"
#History for Kids
p[p$LP.ID=="69610","Primary.Essential.Function"]<-"LC - Digital Learning Platforms"
p[p$LP.ID=="69610","Sector.s."]<-"PreK-12"
#SafeYouTube
p[p$LP.ID=="35098","Primary.Essential.Function"]<-"SDO - School Management Software - Mobile Device Management"
p[p$LP.ID=="35098","Sector.s."]<-"PreK-12;Higher Ed"
#Studio Code
p[p$LP.ID=="26248","Primary.Essential.Function"]<-"LC - Online Course Providers & Technical Skills Development"
p[p$LP.ID=="26248","Sector.s."]<-"PreK-12"
#Edpuzzle - Free (Basic Plan)
p[p$LP.ID=="87841","Primary.Essential.Function"]<-"LC - Sites, Resources & References - Learning Materials & Supplies"
p[p$LP.ID=="87841","Sector.s."]<-"PreK-12"
#Google Play Music
p[p$LP.ID=="53775","Primary.Essential.Function"]<-"LC/CM/SDO - Other"
p[p$LP.ID=="53775","Sector.s."]<-"PreK-12; Higher Ed; Corporate"

#quick check 
p_NA<-p[!complete.cases(p),] # 0 products have NA's, no NA's. Mission is completed ;)-

p[,2]<-NULL #deleting URL column

product<-p
str(product)
#write.csv(product,"product.csv")


#-------------------engagement_data directory preparation--------------------------

engagement_list<-list.files("G:\\kaggle project\\engagement_data",full.names = TRUE)
files_list<-lapply(engagement_list,
                   function(x) {data_temp <- read.csv(x,header=TRUE)
                   districts <-rep(str_sub(x,-8,-5),nrow(data_temp))
                   cbind(districts, data_temp)
                   }
)
engagement<-do.call("rbind",files_list)

#write.csv(engagement,"engagement.csv")

#finding NA's
NA_engagement<-engagement[!complete.cases(engagement),] 

# 5378889 rows have NA,s
#if you see pct_access column is all zero's,So we don't need to fill NA's with median value.
#it is write approach because if product is not used in particular state on 
#particular date, then there is no engagement_index. Let's delete all rows contain NA's. 
#This approach helps machine to perform tasks, because it is large data set.
engagement<-engagement[complete.cases(engagement),] 

str(engagement)

p_engagement<-p %>%
  left_join(engagement,by=c("LP.ID"="lp_id")) #9414271 rows

str(p_engagement)
p_engagement$LP.ID<-factor(p_engagement$LP.ID)
str(p_engagement)# verify 372 products ID 

#district_engagement<-district %>%
#  left_join(engagement,by=c("district_id"="districts")) #13138040 rows



final_dataset<-district %>%
  left_join(p_engagement,by=c("district_id"="districts"))#7313765 rows

final_dataset$district_id<-factor(final_dataset$district_id)
final_dataset$state<-factor(final_dataset$state)
str(final_dataset)

#conclusions
#total states =23
#total districts =176
#total products =372

#final_dataset[!complete.cases(final_dataset),]
#7964 = district of columbia,50 states in usa but our data set has 51 state as District of columbia
# I added close date and rank of each state in dataset. Obviously it cause NA's.
# question is why our data set contain district of columbia ?
#na_7964<-final_dataset[final_dataset$district_id=="7964",]


































