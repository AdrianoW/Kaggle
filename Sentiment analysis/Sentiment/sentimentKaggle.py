__author__ = 'adrianowalmeida'

import csv

def load(flow, ):
    # read the tsv
    tsvin = csv.reader(flow['train_filename'], delimiter='\t')