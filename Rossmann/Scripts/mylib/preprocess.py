# coding: utf-8
import pandas as pd
import numpy as np
from sklearn.base import TransformerMixin, BaseEstimator
import sklearn.preprocessing as pp


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


def binner(col, bins=10):
    '''
    Create bins of a column
    '''
    # create bins
    max_ = int(np.max(col))
    min_ = int(np.min(col))
    step = (max_ - min_)/bins+1 if (max_ - min_) % bins > 0 \
        else (max_ - min_)/bins

    # create the bins
    return np.digitize(col, range(min_, max_, step))


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
        pf = pp.PolynomialFeatures(
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
