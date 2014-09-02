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

setwd("~/Documents/Box Sync/Box Sync/DSR/Machine Learning/Kaggle/Grant/")
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
raw$Start.date <- lapply(raw['Start.date'], as.Date, format='%d/%m/%y' )

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

# add another column with the start dates into vertical
dates <- rep(raw$Start.date[1], dim(vertical)[1])
for (i in 1:dim(vertical)[1]){
   dates[i] <- raw$Start.date[vertical$Grant.Application.ID[i]]
}
vertical2 <- vertical
vertical2[, "Start.date"] <- dates

# find all the dates in year and after 2008
ind_test <- which(unlist(lapply(vertical2['Start.date'], as.Date, format='%d/%m/%y')) >= as.Date('01/01/08', format = '%d/%m/%y'))

#split up into test and train
train <- vertical2[-ind_test,]
test <- vertical2[ind_test,]


