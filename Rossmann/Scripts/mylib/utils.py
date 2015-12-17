# coding: utf-8

# import needed libs
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import time
import pickle
import codecs
import datetime
import dateutil
import random
from sklearn.metrics import confusion_matrix, classification_report, f1_score

# variable definitions
PATH_PROCESSED = './Processed/'
PATH_OUTPUT = './Output/'
PATH_SEED = PATH_PROCESSED + 'seed.txt'


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


def days_passed(date, from_date=None):
    # Get the current date
    now = datetime.datetime.utcnow()
    if not from_date:
        now = now.date()
    else:
        now = from_date

    # Get the difference between the current date and the birthday
    age = dateutil.relativedelta.relativedelta(now, date)
    age = age.days

    return age


def months_passed(date, from_date=None):
    # Get the current date
    now = datetime.datetime.utcnow()
    if not from_date:
        now = now.date()
    else:
        now = from_date

    # Get the difference between the current date and the birthday
    age = dateutil.relativedelta.relativedelta(now, date)
    age = age.months

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
