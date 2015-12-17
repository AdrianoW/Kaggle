library(data.table)
library(neuralnet)
library(caret)

# centering with 'scale()'
center_scale <- function(x) {
   scale(x)
}

# read the processed files, merge them and delete the customer_id field
target  <- fread('Processed/target.csv')
raw_scores  <- fread('Processed/raw_scores.csv')
personal  <- fread('Processed/personal.csv')
balance  <- fread('Processed/balance.csv')
data  <- merge(raw_scores, balance, by='customer_id')
data  <- merge(data, personal, by='customer_id')
data[, customer_id:=NULL]
centered  <- data.table(scale(data))
final  <- cbind2(centered, target)

rm(target); rm(raw_scores); rm(personal); rm(balance)
# create train and test set
trainset  <- final[1:550, ]
testset  <- final[551:634, ]

## build the neural network (NN)
creditnet <- neuralnet(target ~ raw_serasa_score + raw_unit4_score + raw_lexisnexis_score + raw_TU_score +
                          raw_FICO_money_score + Facebook_profile_duration_1_year_or_more + Facebook_profile_duration_3_months_or_less +
                          Facebook_profile_duration_4_12_months +
                          residence_duration_1_2_years + residence_duration_3_years +
                          residence_duration_6_months_or_less + residence_duration_7_12_months +
                          home_phone_type_Home + home_phone_type_Mobile + home_phone_type_Work +
                          other_phone_type_Home + other_phone_type_Mobile + other_phone_type_NI +
                          other_phone_type_Work + Gender_facebook_female + Gender_facebook_male + Title_Dr. +
                          Title_Mr. + Title_Mrs. + Title_Ms. + age + age_money_ratio_class +
                          residence_rent_or_own + monthly_rent_amount + monthly_income_amount +
                          rent_income_ratio + bank_account_duration_1_2_years + bank_account_duration_3_years
                       + bank_account_duration_6_months_or_less + bank_account_duration_7_12_months + bank_account_duration_NI,
                       data=trainset,
                     hidden = c(50,50), lifesign = "minimal",
                     linear.output = FALSE, threshold = 0.01)

plot(creditnet, rep = "best")

# get the columns and run the prediction
## test the resulting output
temp_test <- testset[, .(raw_serasa_score , raw_unit4_score , raw_lexisnexis_score , raw_TU_score ,
                            raw_FICO_money_score , Facebook_profile_duration_1_year_or_more , Facebook_profile_duration_3_months_or_less ,
                            Facebook_profile_duration_4_12_months ,
                            residence_duration_1_2_years , residence_duration_3_years ,
                            residence_duration_6_months_or_less , residence_duration_7_12_months ,
                            home_phone_type_Home , home_phone_type_Mobile , home_phone_type_Work ,
                            other_phone_type_Home , other_phone_type_Mobile , other_phone_type_NI ,
                            other_phone_type_Work , Gender_facebook_female , Gender_facebook_male , Title_Dr. ,
                            Title_Mr. , Title_Mrs. , Title_Ms. , age , age_money_ratio_class ,
                            residence_rent_or_own , monthly_rent_amount , monthly_income_amount ,
                            rent_income_ratio , bank_account_duration_1_2_years , bank_account_duration_3_years
                         , bank_account_duration_6_months_or_less , bank_account_duration_7_12_months , bank_account_duration_NI
                         )]
# calculate the prediction using the neural network
creditnet.results<- compute(creditnet, temp_test)
results <- data.frame(actual = testset$target,
                      prediction = creditnet.results$net.result)
# check the prediction
results$prediction <- round(results$prediction)
sum(results$prediction == results$actual)/length(results$actual)
confusionMatrix(results$prediction, results$actual)

# get the columns
names(data)

