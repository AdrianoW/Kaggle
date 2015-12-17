## Predict if a client will default

The task is distributed along a series of IPython Notebooks.

The following technologies were used:

- Python, Scikit-learn, Ipython Notebook (Jupyter), Lasagne, NoLearn
- Vowpal Wabbit
- R Studio

### COMMAND LINE

A simple python script, based on the ipython Notebook
was created to do the processing in the command line.
The syntax is:

    python process.py command

list of commands:

- run - run all
- preprocess - run only the preprocessing
- ML_Search - do the algorithm search. preprocess is necessary
- VW - do the Vowpal Wabbit trainig. If the result is not .733, 
    - run "./go_wh.sh 15" in the command line
- bagging - do the weighting of the files on the output.


### NOTEBOOKS
List of Notebook created and description
0 - Analysis.ipynb
    The code for the data analysis presented
1 - Preprocess.ipynb
    Preprocess of the files, creation of features, cleaning and creation of seed
2 - ML Search.ipynb
    Execute the combination of the column groups over a set of Classifiers
2.x – execution of the ml search over a specific set of columns
3 – Vowpal Wabbit.ipynb
    Execution of the Vowpal Wabbit over the dataset
4 – Neural Networks
    R and Lasagne/NoLearn
5 – Bagging.ipynb
    The bagging procedures. 
6 – Validation and test set.ipynb
    Search procedure using Train, Validation and Test

### FOLDERS
- Input - original xls
- mylib - library created for the task
- Output - the prediction from all the models will be stored here.
    The final prediction are bagged_pred.csv and bagged_pred_no_vw.csv
- Presentation - the presentation and files used.
- Processed - store the files from the preprocess stage

### FILES
- go_vw.sh - shell to call the Vowpal Wabbit
- predict_vw.sh - called by the python notebook and script to predict according to the model created
- process.py - explained above, in command line
- README - this file

during the execution of VW, some files will be created with .vw. they may be removed after execution.
