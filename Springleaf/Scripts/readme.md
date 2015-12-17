## Springleaf Competition

Detect whether a client will open an email or not. Bunch of scripts used during the competition.

With an ensemble of predictions from XGBOOST models, I managed to stay in the top 25% of the competition.

Scripts from the Springleaf competitions:

### R scripts:

 - h2o_grid_gbm.r:H20 grid search from gbm
 - h2o_glm.r: Simple h2o glm processing
 - h20.r: Data preprocessing with Deeplearning model using h2o
 - r_xboost.r: Script used to generated the winning predictions
 - r_xboost2.r: Script used to generated the winning predictions

### Ipython notebooks

 - ModelSearch.ipynb: Searching for the best algorithm for the data.
 - Cols removal.ipynb: Remove columns based on the number of rows that contain values in this columns
 
### Python

 - csv_to_vw.py: Convert csv to a Vowppal Wabbit format
 - xboost.py: xboost from python. From Kaggle forum
 

