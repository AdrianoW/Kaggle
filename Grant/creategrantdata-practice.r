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
cores <- 3
if(cores > 1){
  library(doParallel)
  library(foreach)
  cl <- makeCluster(cores)
  registerDoParallel(cl)
}

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

setwd("~/SkyDrive/DSR-docs/dsrteach/grants/data")
raw <- read.csv("unimelb_training.csv")

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


######################################################################
## Calculate the total number of people identified per the grant

######################################################################
## Calculate the number of people per role
# that is, a table with Grant.Application.ID NumCI NumDR NumECI NumEA NumHV NumPS NumSCI NumSR NumUNK ... etc

######################################################################
## For each role, calculate the frequency of people in each age group 
# that is, a table with Grant.Application.ID CI.1900 CI.1925 CI.1930 CI.1935 CI.1940 DR.1940 etc

######################################################################
## For each role, calculate the frequency of people from each country
# that is: names(investCountry)
# [1] "Grant.Application.ID"   "CI.AsiaPacific"         "DR.AsiaPacific"        
# [4] "PS.AsiaPacific"         "CI.Australia"           "DR.Australia"          
# [7] "ECI.Australia"          "HV.Australia"           "PS.Australia", etc

######################################################################
## For each role, calculate the frequency of people for each language
# that is: names(investLang)
# [1] "Grant.Application.ID" "CI.English"           "DR.English"          
# [4] "ECI.English"          "PS.English"           "CI.OtherLang"        
# [7] "DR.OtherLang"  


######################################################################
## For each role, determine who as a Ph.D.
# that is: > names(investPhD)
# [1] "Grant.Application.ID" "CI.PhD"               "DR.PhD"              
# [4] "ECI.PhD"              "HV.PhD"               "PS.PhD"              
# [7] "SR.PhD"

######################################################################
## For each role, calculate the number of successful and unsuccessful
## grants (**)
# that is:  names(investGrants)
# [1] "Grant.Application.ID" "Success.CI"           "Unsuccess.CI"        
# [4] "Success.DR"           "Unsuccess.DR"         "Success.ECI"         
# [7] "Unsuccess.ECI"        "Success.PS"           "Unsuccess.PS"        
# [10] "Success.HV"           "Unsuccess.HV"         "Success.SR"          
# [13] "Unsuccess.SR"  


######################################################################
## Create variables for each role/department combination
# that is:  head(names(investDept))
# [1] "Grant.Application.ID" "CI.Dept1013"          "CI.Dept1033"         
# [4] "DR.Dept1033"          "HV.Dept1033"          "PS.Dept1033"  

######################################################################
## Create variables for each role/faculty #
# head(names(investFaculty))
# [1] "Grant.Application.ID" "CI.Faculty1"          "DR.Faculty1"         
# [4] "ECI.Faculty1"         "HV.Faculty1"          "PS.Faculty1" , etc


######################################################################
## Create dummy variables for each tenure length
# head(names(investDuration))
# [1] "Grant.Application.ID" "Duration0to5"         "Duration10to15"      
# [4] "Duration5to10"        "DurationGT15"         "DurationLT0"  


######################################################################
## Create variables for the number of publications per journal
## type. Note that we also compute the total number, which should be
## removed for models that cannot deal with such a linear dependency


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

######################################################################
## Create variables for each RFCD code
# head(names(RFCDcount))
# [1] "Grant.Application.ID" "RFCD210000"           "RFCD230101"          
# [4] "RFCD230102"           "RFCD230105"           "RFCD230107" etc

######################################################################
## Create variables for each SEO code
# head(names(SEOcount))
# [1] "Grant.Application.ID" "SEO610101"            "SEO610102"           
# [4] "SEO610103"            "SEO610104"            "SEO610199"           
# > 


######################################################################
### Make dummy vars out of grant-specific data

grantData <- raw[, c("Sponsor.Code", "Contract.Value.Band...see.note.A", "Grant.Category.Code")]

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
summarized <- merge(investCount, investDOB)
summarized <- merge(summarized, investCountry)
summarized <- merge(summarized, investLang)
summarized <- merge(summarized, investPhD)
summarized <- merge(summarized, investGrants)
summarized <- merge(summarized, investDept)
summarized <- merge(summarized, investFaculty)
summarized <- merge(summarized, investDuration)
summarized <- merge(summarized, investPub)
summarized <- merge(summarized, totalPub)
summarized <- merge(summarized, people)
summarized <- merge(summarized, RFCDcount)
summarized <- merge(summarized, SEOcount)
summarized <- merge(summarized, grantData)
## Remove the ID column
summarized$Grant.Application.ID <- NULL
print(str(summarized))


