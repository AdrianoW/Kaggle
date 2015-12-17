# coding: utf-8
import sklearn.cross_validation as cv
from sklearn.ensemble import ExtraTreesClassifier, \
    GradientBoostingClassifier, RandomForestClassifier
from sklearn.grid_search import GridSearchCV
from sklearn.linear_model import LogisticRegressionCV, RidgeClassifierCV
from sklearn.svm import LinearSVC
from sklearn.svm import SVC
from sklearn.linear_model import SGDClassifier
from sklearn.naive_bayes import GaussianNB
from sklearn.metrics import make_scorer, accuracy_score
from utils import print_time, get_seed, PATH_OUTPUT
import numpy as np
import pandas as pd
import time
import matplotlib.pyplot as plt


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
