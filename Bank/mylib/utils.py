
# coding: utf-8

# import needed libs
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import time
import pickle
import re
import codecs
import datetime
import dateutil
import sklearn.preprocessing as pp
import sklearn.cross_validation as cv
from sklearn.base import TransformerMixin, BaseEstimator
from sklearn.ensemble import ExtraTreesClassifier, \
    GradientBoostingClassifier, RandomForestClassifier
from sklearn.grid_search import GridSearchCV
from sklearn.linear_model import LogisticRegressionCV, RidgeClassifierCV
from sklearn.svm import LinearSVC
from sklearn.svm import SVC
from sklearn.linear_model import SGDClassifier
from sklearn.naive_bayes import GaussianNB
from sklearn.metrics import accuracy_score, f1_score
from sklearn.metrics import confusion_matrix, classification_report
from sklearn.preprocessing import PolynomialFeatures
from sklearn.metrics import make_scorer
from collections import defaultdict, Counter
from glob import glob
import random

# variable definitions
PATH_PROCESSED = './Processed/'
PATH_OUTPUT = './Output/'
PATH_FINAL = './Final'
PATH_SEED = PATH_PROCESSED + 'seed.txt'


def get_numerical_cols(dataFrame, target_col='target'):
    '''
    Get the numerical and non numerical cols. this can be used to change
    categorical columns to numerical
    :return: list of
        numerical cols
        non numerical cols
    '''
    # definitions of the data
    numeric_cols = dataFrame \
        ._get_numeric_data() \
        .columns.difference([target_col]) \
        .tolist()
    non_numeric_cols = dataFrame \
        .columns.difference(dataFrame._get_numeric_data().columns) \
        .tolist()

    return numeric_cols, non_numeric_cols


def save_submission_no_df(fileName, ids, preds):
    '''
    Saves the predicted DF to a csv
    :param ids:
    :param preds:
    : param fileName: file name to save submission
    '''
    print 'Saving to %s' % fileName
    dfSave = pd.DataFrame({'id': ids, 'target': preds})
    dfSave = dfSave.set_index('id')
    dfSave.to_csv(fileName)


def train_regression(data, target, models=None,
                     scorer=None, verbose=False, seed=None):
    '''
    Helper to split the models always the same
    :return: list of tuples (model id, dict of model)
    :params:
        data: data to be trained, no target values
        target: model target val
        models: models to be trained, inside a list []
        scorer: the scorer to order the best results
        verbose: print information
    '''
    seed = seed if seed else get_seed()

    # get the models to test
    if not models:
        models = [ExtraTreesClassifier(random_state=seed),
                  GradientBoostingClassifier(random_state=seed),
                  RandomForestClassifier(random_state=seed),
                  LogisticRegressionCV(),
                  RidgeClassifierCV(),
                  LinearSVC(random_state=seed),
                  SVC(random_state=seed),
                  SGDClassifier(random_state=seed),
                  GaussianNB()]

    # choose accuracy if no scorer was passed
    if not scorer:
        scorer = accuracy_score

    # split in train and validation set
    X_train, X_val, y_train, y_val = split_data(data, target, seed)
    print_time('Created train and validation')
    print_time('Size train: {} test:{}'.
               format(X_train.shape, X_val.shape))
    return train_all_models(X_train, X_val, y_train, y_val,
                            models, scorer, verbose)


def split_data(data, target, seed=None, test_size=.1):
    '''
    Will split the data and target
    params:
        data: the data to be split
        target: the target dataset that will be split
        seed (optional): seed to split, else will use the common seed
        test_size (optional): test size. Default 10%
    '''
    seed = seed if seed else get_seed()
    return cv.train_test_split(data,
                               target,
                               test_size=test_size,
                               random_state=seed)


def train_all_models(X_train, X_val, y_tr, y_val,
                     models, scorer=None, verbose=False,
                     save_preds=True, run_name='all_predict'):
    '''
    Apply many models to an input set.
    :return: list of tuples (model id, dict of model)
    :params:
        X_train: data to be trained, no target values
        X_val: data to be validated, no target values
        y_tr: model training target val
        y_val: validation target val
        models: models to be trained, inside a list []
        scorer: the scorer to order the best results
        verbose: print information
    '''
    start_time = time.time()
    print '%s - Starting to train models' % time.strftime('%X %x %Z')

    assert scorer is not None, 'No score function passed'

    # train all models, saving the values
    models_dict = {}
    for i, model in enumerate(models):
        # train the model
        if verbose:
            print i, model
        model.fit(X_train, y_tr)

        # predict train and validation to check the difference of them.
        pred_train = model.predict(X_train)
        score_train = scorer(y_tr, pred_train)
        if verbose:
            print 'Score of train ', score_train
        pred_val = model.predict(X_val)
        score_val = scorer(y_val, pred_val)
        if verbose:
            print 'Score of validation ', score_val

        # save results
        models_dict[i] = dict(model=model,
                              X_train=X_train,
                              y_tr=y_tr,
                              pred_train=pred_train,
                              score_train=score_train,
                              X_val=X_val,
                              y_val=y_val,
                              pred_val=pred_val,
                              score_val=score_val)

    print "%s - Took %s seconds" % (time.strftime('%X %x %Z'),
                                    time.time() - start_time)

    # returns a list of tuples ordered by the best model according to score_val
    return sorted(models_dict.items(),
                  key=lambda x: x[1]['score_val'],
                  reverse=True)


def save_predictions_from_all(results, run_name='all_models',
                              output_folder=PATH_OUTPUT,
                              score_threshold=None):
    '''
    Iterate through all models and sabe the predictions to files
    params:
        results: the list from train_all_models
        run_name: string to be added to all files
        output_folder: where to run the files
    '''
    for (rid, dicModel) in results:
        # create a dataframe to properly save the info
        if score_threshold and \
           score_threshold > dicModel['score_val']:
            continue
        save_predictions_from_model(dicModel, run_name,
                                    output_folder)

def save_predictions_from_model(dicModel, 
                                run_name='all_models',
                                output_folder=PATH_OUTPUT):
        # create the filename
        filename = '{}pred_{}_{}_{}.csv'.\
            format(output_folder,
                   run_name,
                   int(dicModel['score_val'] * 1000),
                   dicModel['model'].__class__.__name__)

        #save the predictions
        pd.DataFrame(dict(preds=dicModel['pred_val'])) \
            .to_csv(filename, index=False)
        print_time('Saved {}'.format(filename))


def plot_deviance(gbr, X_val, Y_val):
    '''
    Plots the deviance of a Gradient Boosting algorithm. good for parameter
    tunning
    :param gbr: the GBR model
    :param X_val: validation features
    :param Y_val: validation target
    :return: None. Plots directly.
    '''

    # compute test set deviance
    params = gbr.get_params()
    test_score = np.zeros((params['n_estimators'],), dtype=np.float64)

    # save the deviance development
    for i, y_pred in enumerate(gbr.staged_decision_function(X_val)):
        test_score[i] = gbr.loss_(Y_val, y_pred)

    # plot the figure
    plt.figure(figsize=(12, 6))
    plt.subplot(1, 2, 1)
    plt.title('Deviance')
    plt.plot(np.arange(params['n_estimators']) + 1, gbr.train_score_, 'b-',
             label='Training Set Deviance')
    plt.plot(np.arange(params['n_estimators']) + 1, test_score, 'r-',
             label='Test Set Deviance')
    plt.legend(loc='upper right')
    plt.xlabel('Boosting Iterations')
    plt.ylabel('Deviance')
    plt.show()


class Binarizer(BaseEstimator, TransformerMixin):
    '''
    Binarize only the non numerical. Can be used in a pipeline

    Use:
        bin = Binarizer(list_columns)
        bin.fit(Train)
        train_bin  = bin.transform(Train)
        test_bin  = bin.transform(Test)
    '''

    def __init__(self, non_numerical_col):
        '''
        save the params
        '''
        self.non_numerical_col = non_numerical_col

        # the conversions that were made
        self.convMap = {}

    def fit(self, X, Y=None):
        '''
        Create the dict of the binarizers
        '''
        # convert columns
        for col in self.non_numerical_col:
            self.convMap[col] = pp.LabelBinarizer()
            self.convMap[col].fit(X[col])

        return self

    def transform(self, pData):
        '''
        Return the new data with numerical columns binarized and the old ones
        deleted. Column names will be the original col+value. Ex:
            dept_A, dept_B, etc
        '''
        assert self.convMap != {}

        # make a copy of the data
        data = pData.copy()

        # convert columns
        for col in self.non_numerical_col:
            # use previous fit if there is one
            lb = self.convMap[col]

            # create the new cols names
            new_cols_name = [col + '_' + str(clas) for clas in lb.classes_]
            new_vals = lb.transform(data[col])
            col_num = len(new_cols_name)

            # if it is a real binary, one column, not 2 that is created
            if col_num == 2:
                col_num -= 1

            # create the new DF and append to the original one
            new_df = pd.DataFrame(data=new_vals,
                                  columns=new_cols_name[:col_num])
            data = pd.concat([data, new_df], axis=1)

            # remove the original col
            data.drop(col, axis=1, inplace=True)

        return data


class Scaler(BaseEstimator, TransformerMixin):
    '''
    Scale only the non numerical to mean of 0 and sd of 1.
    Can be used in a pipeline.

    Use:
        bin = Scaler(list_columns)
        bin.fit(Train)
        train_bin  = bin.transform(Train)
        test_bin  = bin.transform(Test)
    '''

    def __init__(self, numerical_col):
        '''
        save the params
        '''
        self.numerical_col = numerical_col
        self.mn = 0
        self.st = 0

    def fit(self, X, Y=None):
        '''
        Create the dict of the binarizers
        '''
        num_data = X[self.numerical_col]
        self.mn = np.mean(num_data, axis=0)
        self.st = np.std(num_data, axis=0)

        return self

    def transform(self, pData):
        '''
        Return the columns normalized
        '''
        assert type(self.mn) != int
        assert type(self.st) != int

        # make a copy of the data
        data = pData.copy()

        # get the fields to be converted and normalize them
        num_data = data[self.numerical_col]
        num_data = (num_data-self.mn)/(self.st)
        data[self.numerical_col] = num_data

        return data


class PolyFeature(BaseEstimator, TransformerMixin):
    '''
    Create polynomial features. Can be used in a pipeline

    Use:
        bin = PolyFeature(list_columns)
        bin.fit(Train)
        train_bin  = bin.transform(Train)
        test_bin  = bin.transform(Test)
    '''

    def __init__(self, numerical_col, degree=2,
                 interaction_only=False, include_bias=True):
        '''
        save the params
        '''
        self.numerical_col = numerical_col
        self.degree = degree
        self.interaction_only = interaction_only
        self.include_bias = include_bias

    def fit(self, X, Y=None):
        '''
        Create the dict of the binarizers
        '''

        return self

    def transform(self, pData):
        '''
        Return the new data with numerical columns encoded
        '''

        # make a copy of the data
        data = pData.copy()

        # create the polynomial features
        pf = PolynomialFeatures(
            self.degree,
            self.interaction_only,
            self.include_bias)
        new_cols = pf.fit_transform(data[self.numerical_col])
        new_df = pd.DataFrame(data=new_cols,
                              columns=['pf_' + str(i)
                                       for i in range(pf.n_output_features_)])

        data.reset_index(inplace=True)
        data = pd.concat([data, new_df], axis=1)

        return data


def print_best(models, best_num=3):
    '''
    Prints the best model with the R2 score
    :params:
        :models: models returned by train_all_models
        :best_num: number of top models to print
    '''
    for i in range(min(best_num, len(models))):
        print '------------------------------------------------- '
        print '%i Model - Score: val - %f :: train - %f' % \
            (i, models[i][1]['score_val'], models[i][1]['score_train'])
        print models[i][1]['model']
        print '------------------------------------------------- '


def print_time(msg):
    '''
    Print the message with a time before iter
    '''
    print '%s - %s' % (time.strftime('%X %x %Z'), msg)


def years_passed(date):
    # Get the current date
    now = datetime.datetime.utcnow()
    now = now.date()

    # Get the difference between the current date and the birthday
    age = dateutil.relativedelta.relativedelta(now, date)
    age = age.years

    return age


def days_passed(date):
    # Get the current date
    now = datetime.datetime.utcnow()
    now = now.date()

    # Get the difference between the current date and the birthday
    age = dateutil.relativedelta.relativedelta(now, date)
    age = age.days

    return age


def save_fields_dict(cols, path='Processed/cols_dic.pck'):
    '''
    Pickles the dictionary to a specific file
    params:
        cols: dictionary(file name, list of fields)
    '''
    with open(path, 'wb') as f:
        pickle.dump(cols, f)


def load_fields_dict(path='Processed/cols_dic.pck'):
    '''
    Load the dictionary of the fields
    '''
    with open(path, 'rb') as f:
        return pickle.load(f)


def load_file_data(group, files_path='Processed/'):
    '''
    Load the information from one file, based on group name
    params:
        group: name of the group (file without csv) to load
    return:
        dataframe with data
    '''
    return pd.read_csv(files_path+group+'.csv', encoding='utf-8')


def load_target_data(target_file='target',
                     files_path=PATH_PROCESSED,
                     del_key=True):
    '''
    Load the information from one file, based on group name
    params:
        group: name of the group (file without csv) to load
    return:
        dataframe with data
    '''
    final = pd.read_csv(files_path+target_file+'.csv', encoding='utf-8')

    # delete customer_id if needed
    if del_key:
        del final['customer_id']
    return final


def load_data(groups_list,
              dir_path=PATH_PROCESSED+'cols_dic.pck',
              files_path=PATH_PROCESSED,
              del_key=True):
    '''
    Load the data from disk according to group of information.
    params:
        info_list: List with the group of information to load. they will be
        concatenated into a dataframe
    return:
        Data frame with information
    '''
    # load the file info
    assert len(groups_list) > 0, 'At least 1 group needs to be defined'
    final = load_file_data(groups_list[0])
    for group in groups_list[1:]:
        final = pd.merge(final, load_file_data(group), on='customer_id')
        print_time('Loaded info group {}, current shape of data {}'.
                   format(group, final.shape))

    # delete customer_id if needed
    if del_key:
        del final['customer_id']
    return final


def bag_results(glob_files, loc_outfile, method="average",
                weights="uniform", score_filter=None):
    '''
    Get all files from a folder, read them and by vote get to the final results
    from:https://github.com/MLWave/Kaggle-Ensemble-Guide
    param:
        glob_files: the string to find the files ex: 'test/*.csv'
        loc_outfile: path to the output file
    '''
    if method == "average":
        scores = defaultdict(list)

    # open the output file
    with open(loc_outfile, "wb") as outfile:
        # for each file in the folder, read the value and save in the scores
        for i, glob_file in enumerate(glob(glob_files)):
            # check the score that this file had. If above threshold
            result = re.search('\d+', glob_file)
            score = int(result.group(0))
            if score_filter and score_filter > score:
                continue

            # parse the file
            print "parsing:", glob_file
            for e, line in enumerate(open(glob_file)):
                if i == 0 and e == 0:
                    outfile.write(line)
                if e > 0:
                    row = line.strip().split(",")
                    scores[(e)].append(row[0])
        # for all the values, do the voting saving in the file
        for j in sorted(scores):
            outfile.write("%s\n" %
                         (Counter(scores[(j)]).most_common(1)[0][0]))
    print("wrote to %s" % loc_outfile)


def binarize(col, bins=10):
    '''
    Binarize a column
    '''
    # create bins
    max_ = int(np.max(col))
    min_ = int(np.min(col))
    step = (max_ - min_)/bins+1 if (max_ - min_) % bins > 0 \
        else (max_ - min_)/bins

    # create the bins
    return np.digitize(col, range(min_, max_, step))


def classification_report_matrix(real, pred):
    '''
    Prints classification report and confusion confusion_matrix
    '''
    print_time('\n {}'.format(classification_report(real, pred)))
    print_time('\n {}'.format(confusion_matrix(real, pred)))


def df_to_vw(df, output_dir, target_col, id_col=None):
    '''
    Converts a Pandas DataFrame to a Vowpal Wabbit file
    params:
        df: dataframe to convert
        output_dir: place output the file to
        target_col: the target column. The converter will try to infer if it is
            regression or classification
        id_col (optional): the column that represents the id. if 'index' is
            passed, the index is considered the id
    '''
    # internal function to get the proper splitter
    def splitter(value):
        try:
            float(v)
            return ':'
        except:
            return '='

    # check if params are there
    assert type(df) == type(pd.DataFrame()), 'Df is not a dataframe'
    assert target_col in df, \
        'Target column "%s" not present in the DataFrame' % target_col

    # do not make changes to the original df
    new_df = df.copy()

    with codecs.open(output_dir, 'w', "utf-8") as out:
        # check the target variable
        target_vals = pd.unique(new_df[target_col])
        if new_df[target_col].dtype == int and len(target_vals) == 2:
            # int and 2 values. Probably a binary classification.
            # the first value becomes -1
            min_val = min(target_vals)
            max_val = max(target_vals)
            new_df[target_col].replace(min_val, -1, inplace=True)
            new_df[target_col].replace(max_val, 1, inplace=True)

        # write the lines
        for index, row in new_df.iterrows():
            # id according to function param
            if id_col:
                # get the id and delete the column from the row
                row_id = row[id_col]
                del row[id_col]
            else:
                # simple index as ID
                row_id = index

            # get the target and write the line
            target = row[target_col]
            del row[target_col]
            data = ' '.join([u'{}{}{}'.format(k.replace(' ', '_'),
                                              splitter(v), v)
                             for k, v in row.to_dict().iteritems()])

            out.write(u"{} '{} | {} \n".format(target, row_id, data))

    # communicate user
    print_time('File written {}'.format(output_dir))


def print_distributions(data, x_cols=None, num_cols=3):
    '''
    Print the histogram o data
    '''
    sns.set(style="white", palette="muted", color_codes=True)

    # check if the print is from some columns
    if not x_cols:
        # no cols, get the numerical to plot
        x_cols = data._get_numeric_data().columns

    # print distribution of the plots
    # Set up the matplotlib figure
    lines = (len(x_cols)+(num_cols-1))/(num_cols)
    f, axes = plt.subplots(lines, num_cols, figsize=(15, lines*3.5))

    # plot all distributions
    for i, col in enumerate(x_cols):
        # Plot a historgram and kernel density estimate
        sns.distplot(data[col], ax=axes[int(i/num_cols), i % num_cols])

    plt.setp(axes, yticks=[])
    plt.tight_layout()


def print_correlations(data, y, num_cols=3):
    '''
    Print the correlation between cols and the output
    '''
    # print distribution of the plots
    # Set up the matplotlib figure
    x_cols = data.columns
    lines = (len(x_cols)+(num_cols-1))/(num_cols)
    f, axes = plt.subplots(lines, num_cols, figsize=(15, lines*3.5))

    # plot all distributions
    for i, col in enumerate(x_cols):
        # Plot a historgram and kernel density estimate
        sns.violinplot(data[col], y, jitter=0.05,
                       ax=axes[int(i/num_cols), i % num_cols])

    plt.setp(axes, yticks=[])
    plt.tight_layout()


def f1_scorer(y_true, y_pred):
    '''
    Helper to set the default of the f1_score
    '''
    return np.mean(f1_score(y_true, y_pred, average=None))


def save_seed(seed=None):
    '''
    Save a seed that will be used by all.
    params:
        seed (optional): seed for the random generator. If None
            one will be crated
    returns:
        the seed
    '''
    # generate a random number and save
    if not seed:
        seed = random.randint(1, 100000)

    # save the seed for use by all
    with open(PATH_SEED, 'w') as f:
        f.write(str(seed))

    print_time('Common seed saved: {}'.format(seed))
    return seed


def get_seed():
    '''
    Get the seed from the file.
    '''
    with open(PATH_SEED, 'r') as f:
        return int(f.read())


def grid_search(train_data, test_data, y_train, y_test, model,
                seed=0, scorer=None, verbose=False, n_jobs=1,
                val_size=.1):
    '''
    Grid Search the model. As the parameters are usually the same
    in a grid search, they are stored here already, easing the use.
    params:
        train_data: train data. Will be split into train and validation
        test_data: final test data
        y_train: labels for train data
        y_test: labels for the test data
        model: model to be grid searched
    '''
    results = None
    # split the train and validation data
    X_train, X_val, y_train, y_val = cv.train_test_split(train_data,
                                                         y_train,
                                                         test_size=val_size,
                                                         random_state=seed)

    # call the function according to model name
    model_name = model.__class__.__name__
    if model_name in ('GradientBoostingClassifier'):
        param_grid = {'learning_rate': [0.1, 0.3],
                      'n_estimators': [200],
                      'max_depth': [3, 9, 18],
                      'subsample': [1],
                      'min_samples_leaf': [1, 7, 14, 20],
                      'max_features': [.4, .9, None],
                      }

        # grid search Gradient Boosting
        print_time('Starting grid search')
        gbr_cv = GradientBoostingClassifier()
        gs_cv = GridSearchCV(gbr_cv, param_grid,
                             verbose=verbose, n_jobs=n_jobs,
                             scoring=make_scorer(scorer)).\
            fit(X_train, np.ravel(y_train))
        gbr = gs_cv.best_estimator_

        # validation dataset
        pred_val = gbr.predict(X_val)
        score_val = scorer(y_val, pred_val)
        print_time('Validation prediction score: {}'.format(score_val))

        # check the performance against the test data
        pred_test = gbr.predict(test_data)
        score_test = scorer(y_test, pred_test)
        print_time('Test prediction score: {}'.format(score_test))
        results = {'search': gs_cv, 'pred_test': pred_test,
                   'score_test': score_test, 'pred_val': pred_val,
                   'score_val': score_val}
        print_time('Finished grid search')

    return results


class VowpalWabbit():
    '''
        Still just bogus for saving the output with a name
    '''
    None
