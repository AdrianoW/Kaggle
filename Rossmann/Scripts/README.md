## ROSSMANN

Predict the amount sold for a 3 month period for a 1000 stores, daily, with the data given for the previous 2 years.

I managed to be among the top 25% using a XGBOOST based prediction

## Preprocess and Analysis

- Analysis.ipynb: basic analysis of data
- Preprocessing.ipynb: preprocessing and prediction using XGBOOST
- Analysis.r: Analysis done in R. Searching for trends in data
- datatablepreprocess.R: Preprocessing usind Data.table lib
- processing.py: creates processed files used on the model training


## Training, predicting and tunning

- evolutionary.py: evolutionary search for the best parameters. From Kaggle forums
- rossman.r: predicion using XGBOOST