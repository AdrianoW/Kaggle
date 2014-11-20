__author__ = 'adrianowalmeida'

import sys
import importlib


def load(flow, file):
    # check
    module = flow['model']
    loader = getattr(importlib.import_module(module), 'load')
    return loader(flow, file)

def input_analyses(flow):
    # read the input file
    train = load(flow, 'train_file')
    return train

def input_transform():
    pass

def _usage_and_exit():
    print "Usage: {} function-name config-filename".format(sys.argv[0])
    sys.exit(0)


def _load_flow(filename):
    return eval(open(filename).read())

if __name__ == '__main__':
    # if len(sys.argv) < 3:
    #     _usage_and_exit()
    #
    # func = globals().get(sys.argv[1])
    # if func is None:
    #     _usage_and_exit()
    #
    #config = _load_config(sys.argv[2])
    flow = _load_flow('flow_sentimentKaggle.py')
    # func(config, *sys.argv[3:])
    input_analyses(flow)
