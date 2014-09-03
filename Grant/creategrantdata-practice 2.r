################################################################################
### R code from Applied Predictive Modeling (2013) by Kuhn and Johnson.
### Copyright 2013 Kuhn and Johnson
###
### R code to process the Kaggle grant application data.
###
### Required packages: plyr, caret, lubridate
################################################################################

## The plyr, caret and libridate packages are used in this script. The
## code can also be run using multiple cores using the ddply()
## function. See ?ddply to get more information.
##
## These computations will take a fair amount of time and may consume
## a non-trivial amount of memory in the process.
##

## Load required libraries
library(plyr)
library(caret)
library(lubridate)

## How many cores on the machine should be used for the data
## processing. Making cores > 1 will speed things up (depending on your
## machine) but will consume more memory.
#cores <- 3
#if(cores > 1){
#  library(doParallel)
#  library(foreach)
#  cl <- makeCluster(cores)
#  registerDoParallel(cl)
#}

# Note: when using parallel=T, there are always a couple of warnings: 
# Warning messages:
# 1: <anonymous>: ... may be used in an incorrect context: '.fun(piece, ...)'
# 2: <anonymous>: ... may be used in an incorrect context: '.fun(piece, ...)'
# The issue is open on github: https://github.com/hadley/plyr/issues/203

# It seems to be safe to ignore them

# there are many other parallel backends, (eg doParallel), it might be worth trying them



## Read in the data in it's raw form. Some of the column headings do
## not convert to proper R variable names, so many will contain dots,
## such as "Dept.No" instead of "Dept No"

setwd("Documents/DSR/competition_kaggle_grants")
raw <- read.csv("unimelb_training.csv")
#raw <- read.csv('unimelb_training.csv')

## In many cases, missing values in categorical data will be converted
## to a value of "Unk"
raw$Sponsor.Code <- as.character(raw$Sponsor.Code)
raw$Sponsor.Code[raw$Sponsor.Code == ""] <- "Unk"
raw$Sponsor.Code <- factor(paste("Sponsor", raw$Sponsor.Code, sep = ""))

raw$Grant.Category.Code <- as.character(raw$Grant.Category.Code)
raw$Grant.Category.Code[raw$Grant.Category.Code == ""] <- "Unk"
raw$Grant.Category.Code <- factor(paste("GrantCat", raw$Grant.Category.Code, sep = ""))

raw$Contract.Value.Band...see.note.A <- as.character(raw$Contract.Value.Band...see.note.A)
raw$Contract.Value.Band...see.note.A[raw$Contract.Value.Band...see.note.A == ""] <- "Unk"
raw$Contract.Value.Band...see.note.A <- factor(paste("ContractValueBand", raw$Contract.Value.Band...see.note.A, sep = ""))

## Change missing Role.1 information to Unk
raw$Role.1 <- as.character(raw$Role.1)
raw$Role.1[raw$Role.1 == ""] <- "Unk"

## At this point, the data for investigators is in different
## columns. We'll take this "horizontal" format and convert it to a
## "vertical" format where the data are stacked. This will make some
## of the data processing easier.

## Split up the data by role number (1-15) and add any missing columns
## (roles 1-5 have more columns -20- than the others -16-)
# the difference is "RFCD.Code", "RFCD.Percentage", "SEO.Code", "SEO.Percentage"        

# this loops produces a tmp list of tmpData data.frames, we then rbind them at the end
tmp <- vector(mode = "list", length = 15)
for(i in 1:15)  {
	# get 
    tmpData <- raw[, c("Grant.Application.ID", grep(paste("\\.", i, "$", sep = ""), names(raw), value = TRUE))]
    names(tmpData) <- gsub(paste("\\.", i, "$", sep = ""), "", names(tmpData))
    if(i == 1) nms <- names(tmpData) # only the first one needs to have names, we'll rbind the rest
   
    # add empty columns if they dont exist
    if(all(names(tmpData) != "RFCD.Code")) tmpData$RFCD.Code <- NA
    if(all(names(tmpData) != "RFCD.Percentage")) tmpData$RFCD.Percentage <- NA
    if(all(names(tmpData) != "SEO.Code")) tmpData$SEO.Code <- NA
    if(all(names(tmpData) != "SEO.Percentage")) tmpData$SEO.Percentage <- NA

    tmp[[i]] <- tmpData[,nms]
    rm(tmpData)
  }

## Stack them up and remove any rows without role information
vertical <- do.call("rbind", tmp)
vertical <- subset(vertical, Role != "")

## Reformat variables: 
# Role
# Year.of.Birth
# Country.of.Birth
# Home.Language
# Dept.No
# Faculty.NO
# RFCD.Code
# RFCD.Percent

## encode missing data or to make the factor levels more descriptive.
## to make complete factors, correctly
vertical$Role <- factor(as.character(vertical$Role))

## Get the unique values of the birth years and department codes. 
bYears <- unique(do.call("c", raw[,grep("Year.of.Birth", names(raw), fixed = TRUE)]))
bYears <- bYears[!is.na(bYears)]
# year of birth, to factor
vertical$Year.of.Birth <- factor(paste(vertical$Year.of.Birth), levels = paste(sort(bYears)))

# fix country of birth, remove empty spaces
vertical$Country.of.Birth <- gsub(" ", "", as.character(vertical$Country.of.Birth))
vertical$Country.of.Birth[vertical$Country.of.Birth == ""] <- NA
vertical$Country.of.Birth <- factor(vertical$Country.of.Birth)

vertical$Home.Language <- gsub("Other", "OtherLang", as.character(vertical$Home.Language))
vertical$Home.Language[vertical$Home.Language == ""] <- NA
vertical$Home.Language <- factor(vertical$Home.Language)

vertical$Dept.No. <- paste("Dept", vertical$Dept.No., sep = "")
vertical$Dept.No.[vertical$Dept.No. == "DeptNA"] <- NA
vertical$Dept.No. <- factor(vertical$Dept.No.)

vertical$Faculty.No. <- paste("Faculty", vertical$Faculty.No., sep = "")
vertical$Faculty.No.[vertical$Faculty.No. == "FacultyNA"] <- NA
vertical$Faculty.No. <- factor(vertical$Faculty.No.)

vertical$RFCD.Code <- paste("RFCD", vertical$RFCD.Code, sep = "")
vertical$RFCD.Percentage[vertical$RFCD.Code == "RFCDNA"] <- NA
vertical$RFCD.Code[vertical$RFCD.Code == "RFCDNA"] <- NA
vertical$RFCD.Percentage[vertical$RFCD.Code == "RFCD0"] <- NA
vertical$RFCD.Code[vertical$RFCD.Code == "RFCD0"] <- NA
vertical$RFCD.Percentage[vertical$RFCD.Code == "RFCD999999"] <- NA
vertical$RFCD.Code[vertical$RFCD.Code == "RFCD999999"] <- NA
vertical$RFCD.Code <- factor(vertical$RFCD.Code)

vertical$SEO.Code <- paste("SEO", vertical$SEO.Code, sep = "")
vertical$SEO.Percentage[vertical$SEO.Code == "SEONA"] <- NA
vertical$SEO.Code[vertical$SEO.Code == "SEONA"] <- NA
vertical$SEO.Percentage[vertical$SEO.Code == "SEO0"] <- NA
vertical$SEO.Code[vertical$SEO.Code  == "SEO0"] <- NA
vertical$SEO.Percentage[vertical$SEO.Code == "SEO999999"] <- NA
vertical$SEO.Code[vertical$SEO.Code== "SEO999999"] <- NA
vertical$SEO.Code <- factor(vertical$SEO.Code)

vertical$No..of.Years.in.Uni.at.Time.of.Grant <- as.character(vertical$No..of.Years.in.Uni.at.Time.of.Grant)
vertical$No..of.Years.in.Uni.at.Time.of.Grant[vertical$No..of.Years.in.Uni.at.Time.of.Grant == ""] <- "DurationUnk"
vertical$No..of.Years.in.Uni.at.Time.of.Grant[vertical$No..of.Years.in.Uni.at.Time.of.Grant == ">=0 to 5"] <- "Duration0to5"
vertical$No..of.Years.in.Uni.at.Time.of.Grant[vertical$No..of.Years.in.Uni.at.Time.of.Grant == ">5 to 10"] <- "Duration5to10"
vertical$No..of.Years.in.Uni.at.Time.of.Grant[vertical$No..of.Years.in.Uni.at.Time.of.Grant == ">10 to 15"] <- "Duration10to15"
vertical$No..of.Years.in.Uni.at.Time.of.Grant[vertical$No..of.Years.in.Uni.at.Time.of.Grant == "more than 15"] <- "DurationGT15"
vertical$No..of.Years.in.Uni.at.Time.of.Grant[vertical$No..of.Years.in.Uni.at.Time.of.Grant == "Less than 0"] <- "DurationLT0"
vertical$No..of.Years.in.Uni.at.Time.of.Grant <- factor(vertical$No..of.Years.in.Uni.at.Time.of.Grant)

write.table(vertical, 'vertical.csv', sep='\t', row.names=F)

######################################################################
## A function to shorten the role titles

shortNames <- function(x, pre = "")
  {
    x <- gsub("EXT_CHIEF_INVESTIGATOR",  "ECI", x)
    x <- gsub("STUD_CHIEF_INVESTIGATOR", "SCI", x)
    x <- gsub("CHIEF_INVESTIGATOR",      "CI", x)
    x <- gsub("DELEGATED_RESEARCHER",    "DR", x)
    x <- gsub("EXTERNAL_ADVISOR",        "EA", x)
    x <- gsub("HONVISIT",                "HV", x)
    x <- gsub("PRINCIPAL_SUPERVISOR",    "PS", x)
    x <- gsub("STUDRES",                 "SR", x)
    x <- gsub("Unk",                     "UNK", x)
    other <- x[x != "Grant.Application.ID"]
    c("Grant.Application.ID", paste(pre, other, sep = ""))
  }

## A function to find and remove zero-variance ("ZV") predictors
noZV <- function(x)
  {
    keepers <- unlist(lapply(x, function(x) length(unique(x)) > 1))
    x[,keepers,drop = FALSE]
  }


#========================================================
# Split
#========================================================

#extended_vertical <- merge(raw[,1:26],vertical, by='Grant.Application.ID')

# find all the dates in year and after 2008
#ind_test <- which(unlist(lapply(extended_vertical['Start.date'], as.Date, format='%d/%m/%y')) >= as.Date('01/01/08', format = '%d/%m/%y'))

#split up into test and train
#train <- extended_vertical[-ind_test,]
#test <- extended_vertical[ind_test,]


#library('psych')

#pairs.panels(train[,1:10])


# call function with dat

#dat <- train
dat <- vertical
library('reshape2') # melt and cast
library('stringi')
######################################################################
## Calculate the total number of people identified per the grant
#t <- as.data.frame(table(train$Grant.Application.ID))
#tt <- count(df = train, vars =c("Grant.Application.ID", "Person.ID"))
people <- ddply(dat, .(Grant.Application.ID), function(x) c(numPeople = nrow(x)))

######################################################################
## Calculate the number of people per role
# that is, a table with Grant.Application.ID NumCI NumDR NumECI NumEA NumHV NumPS NumSCI NumSR NumUNK ... etc

tt <- count(df = dat, vars =c("Grant.Application.ID","Role"))
tmp <- dcast(tt, Grant.Application.ID ~ Role, fill=0, value.var='freq')

out <- merge(people, tmp, by='Grant.Application.ID')
######################################################################
## For each role, calculate the frequency of people in each age group 
# that is, a table with Grant.Application.ID CI.1900 CI.1925 CI.1930 CI.1935 CI.1940 DR.1940 etc

tt <- count(df = dat, vars =c("Grant.Application.ID","Role","Year.of.Birth"))
tmp2 <- dcast(tt, Grant.Application.ID ~ Role + Year.of.Birth, fill=0, value.var='freq')

#out <- merge(out, tmp2, by='Grant.Application.ID')
######################################################################
## For each role, calculate the frequency of people from each country
# that is: names(investCountry)
# [1] "Grant.Application.ID"   "CI.AsiaPacific"         "DR.AsiaPacific"        
# [4] "PS.AsiaPacific"         "CI.Australia"           "DR.Australia"          
# [7] "ECI.Australia"          "HV.Australia"           "PS.Australia", etc


tt <- count(df = dat, vars =c("Grant.Application.ID","Role","Country.of.Birth"))
tmp3 <- dcast(tt, Grant.Application.ID ~ Role + Country.of.Birth, fill=0, value.var='freq')

out <- merge(out, tmp3, by='Grant.Application.ID')

######################################################################
## For each role, calculate the frequency of people for each language
# that is: names(investLang)
# [1] "Grant.Application.ID" "CI.English"           "DR.English"          
# [4] "ECI.English"          "PS.English"           "CI.OtherLang"        
# [7] "DR.OtherLang"  

tt <- count(df = dat, vars =c("Grant.Application.ID","Role","Home.Language"))
tmp4 <- dcast(tt, Grant.Application.ID ~ Role + Home.Language, fill=0, value.var='freq')

out <- merge(out, tmp4, by='Grant.Application.ID')

######################################################################
## For each role, determine who as a Ph.D.
# that is: > names(investPhD)
# [1] "Grant.Application.ID" "CI.PhD"               "DR.PhD"              
# [4] "ECI.PhD"              "HV.PhD"               "PS.PhD"              
# [7] "SR.PhD"

tt <- count(df = dat, vars =c("Grant.Application.ID","Role","With.PHD"))
ind_phd <- which(unclass(tt$With.PHD) == 2)
tt <- tt[ind_phd,]
levels(tt$With.PHD) <- c('','PhD') 
tmp5 <- dcast(tt, Grant.Application.ID ~ Role + With.PHD, fill=0, value.var='freq')

out <- merge(out, tmp5, by='Grant.Application.ID', all.x=T)
out[is.na(out)] <- 0

######################################################################
## For each role, calculate the number of successful and unsuccessful
## grants (**)
# that is:  names(investGrants)
# [1] "Grant.Application.ID" "Success.CI"           "Unsuccess.CI"        
# [4] "Success.DR"           "Unsuccess.DR"         "Success.ECI"         
# [7] "Unsuccess.ECI"        "Success.PS"           "Unsuccess.PS"        
# [10] "Success.HV"           "Unsuccess.HV"         "Success.SR"          
# [13] "Unsuccess.SR"  


tt <- count(df = dat, vars =c("Grant.Application.ID", "Role", "Number.of.Successful.Grant"))
tmp6 <- dcast(tt, Grant.Application.ID ~ Role, fill=0, sum, value.var='Number.of.Successful.Grant')
tmp6[is.na(tmp6)] <- 0
colnames(tmp6)[2:length(colnames(tmp6))]<- stri_paste(colnames(tmp6[2:length(colnames(tmp6))]), '_SucGrant') 


tt2 <- count(df = dat, vars =c("Grant.Application.ID", "Role", "Number.of.Unsuccessful.Grant"))
tmp7 <- dcast(tt2, Grant.Application.ID ~ Role, fill=0, sum, value.var='Number.of.Unsuccessful.Grant')
tmp7[is.na(tmp7)] <- 0
colnames(tmp7)[2:length(colnames(tmp7))]<- stri_paste(colnames(tmp7[2:length(colnames(tmp7))]), '_UnSucGrant') 


out <- merge(out, tmp6, by='Grant.Application.ID')
out <- merge(out, tmp7, by='Grant.Application.ID')

######################################################################
## Create variables for each role/department combination
# that is:  head(names(investDept))
# [1] "Grant.Application.ID" "CI.Dept1013"          "CI.Dept1033"         
# [4] "DR.Dept1033"          "HV.Dept1033"          "PS.Dept1033"  

tt <- count(df = dat, vars =c("Grant.Application.ID", "Dept.No."))
tmp8 <- dcast(tt, Grant.Application.ID ~ Dept.No., fill=0, value.var='freq')
colnames(tmp8)[length(tmp8)] <- 'Dept_Unk'

out <- merge(out, tmp8, by='Grant.Application.ID')

######################################################################
## Create variables for each role/faculty #
# head(names(investFaculty))
# [1] "Grant.Application.ID" "CI.Faculty1"          "DR.Faculty1"         
# [4] "ECI.Faculty1"         "HV.Faculty1"          "PS.Faculty1" , etc

#tt <- count(df = dat, vars =c("Grant.Application.ID", "Role", "Faculty.No."))
#tmp9 <- dcast(tt, Grant.Application.ID ~ Role + Faculty.No., fill=0, value.var='freq')

tt <- count(df = dat, vars =c("Grant.Application.ID", "Faculty.No."))
tmp9 <- dcast(tt, Grant.Application.ID ~ Faculty.No., fill=0, value.var='freq')

colnames(tmp9)[length(tmp9)] <- 'Fac_Unk'



out <- merge(out, tmp9, by='Grant.Application.ID')

######################################################################
## Create dummy variables for each tenure length
# head(names(investDuration))
# [1] "Grant.Application.ID" "Duration0to5"         "Duration10to15"      
# [4] "Duration5to10"        "DurationGT15"         "DurationLT0"  

tt <- count(df = dat, vars =c("Grant.Application.ID", "No..of.Years.in.Uni.at.Time.of.Grant"))
investDuration <- dcast(tt, Grant.Application.ID ~ No..of.Years.in.Uni.at.Time.of.Grant, fill=0, value.var='freq')

out <- merge(out, investDuration, by='Grant.Application.ID')

######################################################################
## Create variables for the number of publications per journal
## type. Note that we also compute the total number, which should be
## removed for models that cannot deal with such a linear dependency

# first create bins for the publication numbers: 0, 1-4, 5-10, MT10, NA
org_A. <- dat$A.
dummy_A. <- dat$A.
dummy_A.[dat$A. == 0] <- 'A.0'
dummy_A.[dat$A. > 0 & dat$A. < 5] <- 'A.1-4'
dummy_A.[dat$A. > 4 & dat$A. < 11] <- 'A.5-10'
dummy_A.[dat$A. > 10] <- 'A._MT10'
dummy_A.[is.na(dat$A.)] <- 'A._NA'
dat$A. <- dummy_A.

org_A <- dat$A
dummy_A <- dat$A
dummy_A[dat$A == 0] <- 'A0'
dummy_A[dat$A > 0 & dat$A < 5] <- 'A1-4'
dummy_A[dat$A > 4 & dat$A < 11] <- 'A5-10'
dummy_A[dat$A > 10] <- 'A_MT10'
dummy_A[is.na(dat$A)] <- 'A_NA'
dat$A <- dummy_A

org_B <- dat$B
dummy_B <- dat$B
dummy_B[dat$B == 0] <- 'B0'
dummy_B[dat$B > 0 & dat$B < 5] <- 'B1-4'
dummy_B[dat$B > 4 & dat$B < 11] <- 'B5-10'
dummy_B[dat$B > 10] <- 'B_MT10'
dummy_B[is.na(dat$B)] <- 'B_NA'
dat$B <- dummy_B


org_C <- dat$C
dummy_C <- dat$C
dummy_C[dat$C == 0] <- 'C0'
dummy_C[dat$C > 0 & dat$C < 5] <- 'C1-4'
dummy_C[dat$C > 4 & dat$C < 11] <- 'C5-10'
dummy_C[dat$C > 10] <- 'C_MT10'
dummy_C[is.na(dat$C)] <- 'C_NA'
dat$C <- dummy_C

tt <- count(df = dat, vars =c("Grant.Application.ID", "A."))
tmp10 <- dcast(tt, Grant.Application.ID ~ A., fill=0, value.var='freq')
tt <- count(df = dat, vars =c("Grant.Application.ID", "A"))
tmp11 <- dcast(tt, Grant.Application.ID ~ A, fill=0, value.var='freq')
tt <- count(df = dat, vars =c("Grant.Application.ID", "B"))
tmp12 <- dcast(tt, Grant.Application.ID ~ B, fill=0, value.var='freq')
tt <- count(df = dat, vars =c("Grant.Application.ID", "C"))
tmp13 <- dcast(tt, Grant.Application.ID ~ C, fill=0, value.var='freq')

tmp14 <- merge(merge(merge(tmp10, tmp11, by='Grant.Application.ID'),tmp12,by='Grant.Application.ID'),tmp13, by='Grant.Application.ID')

out <- merge(out, tmp14, by='Grant.Application.ID')

dat$A. <- org_A.
dat$A <- org_A
dat$B <- org_B
dat$C <- org_C
######################################################################
## Create variables for the number of publications per journal
## type per role. (**)
# names(investPub)
# [1] "Grant.Application.ID" "Astar.CI"             "A.CI"                
# [4] "B.CI"                 "C.CI"                 "Astar.DR"            
# [7] "A.DR"                 "B.DR"                 "C.DR"                
# [10] "Astar.ECI"            "A.ECI"                "B.ECI"               
# [13] "C.ECI"                "Astar.PS"             "A.PS"                
# [16] "B.PS"                 "C.PS"                 "Astar.HV"            
# [19] "A.HV"                 "B.HV"                 "C.HV"                
# [22] "Astar.SR"             "A.SR"                 "B.SR"                
# [25] "C.SR"       

tt <- count(df = dat, vars =c("Grant.Application.ID", "Role", "A."))
tmp15 <- dcast(tt, Grant.Application.ID ~ Role, fill=0, sum,value.var='A.')
colnames(tmp15)[2:length(colnames(tmp15))]<- stri_paste(colnames(tmp15[2:length(colnames(tmp15))]), '_A.') 

tt <- count(df = dat, vars =c("Grant.Application.ID", "Role", "A"))
tmp16 <- dcast(tt, Grant.Application.ID ~ Role, fill=0, sum,value.var='A')
colnames(tmp16)[2:length(colnames(tmp16))]<- stri_paste(colnames(tmp16[2:length(colnames(tmp16))]), '_A') 

tt <- count(df = dat, vars =c("Grant.Application.ID", "Role", "B"))
tmp17 <- dcast(tt, Grant.Application.ID ~ Role, fill=0, sum,value.var='B')
colnames(tmp17)[2:length(colnames(tmp17))]<- stri_paste(colnames(tmp17[2:length(colnames(tmp17))]), '_B') 

tt <- count(df = dat, vars =c("Grant.Application.ID", "Role", "C"))
tmp18 <- dcast(tt, Grant.Application.ID ~ Role, fill=0, sum,value.var='C')
colnames(tmp18)[2:length(colnames(tmp18))]<- stri_paste(colnames(tmp18[2:length(colnames(tmp18))]), '_C') 


tmp19 <- merge(merge(merge(tmp15, tmp16, by='Grant.Application.ID'),tmp17,by='Grant.Application.ID'),tmp18, by='Grant.Application.ID')
tmp19[is.na(tmp19)] <- 0

out <- merge(out, tmp19, by='Grant.Application.ID')

######################################################################
## Create variables for each RFCD code
# head(names(RFCDcount))
# [1] "Grant.Application.ID" "RFCD210000"           "RFCD230101"          
# [4] "RFCD230102"           "RFCD230105"           "RFCD230107" etc

bob <- data.frame(lapply(dat$RFCD.Code, as.character), stringsAsFactors=FALSE)

#store data in dummy variable
d <- dat$RFCD.Code
h <- unlist(stri_extract_all_regex(unlist(bob), "RFCD.{2}"))

dat$RFCD.Code <- h
tt <- count(df = dat, vars =c("Grant.Application.ID", "RFCD.Code"))
tmp20 <- dcast(tt, Grant.Application.ID ~ RFCD.Code, fill=0, value.var='freq')
names(tmp20)[length(tmp20)] <- 'RFCD_Other'

out <- merge(out, tmp20, by='Grant.Application.ID', suffixes = c("",""))

dat$RFCD.Code <- d
rm(d,bob)
######################################################################
## Create variables for each SEO code
# head(names(SEOcount))
# [1] "Grant.Application.ID" "SEO610101"            "SEO610102"           
# [4] "SEO610103"            "SEO610104"            "SEO610199"           
# > 
bob <- data.frame(lapply(dat$SEO.Code, as.character), stringsAsFactors=FALSE)

#store data in dummy variable
d <- dat$SEO.Code
h <- unlist(stri_extract_all_regex(unlist(bob), "SE.{4}"))

dat$SEO.Code <- h
tt <- count(df = dat, vars =c("Grant.Application.ID", "SEO.Code"))
tmp21 <- dcast(tt, Grant.Application.ID ~ SEO.Code, fill=0, value.var='freq')
names(tmp21)[length(tmp21)] <- 'SE_Other'
out <- merge(out, tmp21, by='Grant.Application.ID')

dat$SEO.Code <- d
rm(d,bob)
######################################################################
### Make dummy vars out of grant-specific data

grantData <- raw[, c("Sponsor.Code", "Contract.Value.Band...see.note.A", "Grant.Category.Code")]
#grantData <- raw[, c("Contract.Value.Band...see.note.A", "Grant.Category.Code")]


## Make a lubridate object for the time, then derive the day, week and month info
startTime <- dmy(raw$Start.date)

grantData$Month <- factor(as.character(month(startTime, label = TRUE)))
grantData$Weekday <- factor(as.character(wday(startTime, label = TRUE)))
grantData$Day <- day(startTime)
grantYear <- year(startTime)

######################################################################
### Use the dummyVars function to create binary variables for
### grant-specific variables

dummies <- dummyVars(~., data = grantData, levelsOnly = TRUE)
grantData <- as.data.frame(predict(dummies, grantData))
names(grantData) <- gsub(" ", "", names(grantData))

grantData$Grant.Application.ID <- raw$Grant.Application.ID
grantData$Class <- factor(ifelse(raw$Grant.Status, "successful", "unsuccessful"))
grantData$Grant.Application.ID <- raw$Grant.Application.ID

grantData$is2008 <- year(startTime) == 2008
grantData <- noZV(grantData)

######################################################################
### Merge all the predictors together, remove zero variance columns
### and merge in the outcome data
#summarized <- merge(investCount, investDOB)
#summarized <- merge(summarized, investCountry)
#summarized <- merge(summarized, investLang)
#summarized <- merge(summarized, investPhD)
#summarized <- merge(summarized, investGrants)
#summarized <- merge(summarized, investDept)
#summarized <- merge(summarized, investFaculty)
#summarized <- merge(summarized, investDuration)
#summarized <- merge(summarized, investPub)
#summarized <- merge(summarized, totalPub)
#summarized <- merge(summarized, people)
#summarized <- merge(summarized, RFCDcount)
#summarized <- merge(summarized, SEOcount)
#summarized <- merge(summarized, grantData)
## Remove the ID column
#summarized$Grant.Application.ID <- NULL
#print(str(summarized))

final_data <- merge(grantData, out, by='Grant.Application.ID')
write.csv(final_data, file="grants_tidy_all_2.csv")
#final_data$Grant.Application.ID <- NULL

ind_test <- which(final_data$is2008)
test <- final_data[ind_test,]
write.csv(test, file="grants_test_2.csv")
train <- final_data[-ind_test,]
write.csv(train, file="grants_train_2.csv")

#fit1 <- lm(Class ~ ., data = train)
#res <- predict(fit1, newdata=test, type='response')