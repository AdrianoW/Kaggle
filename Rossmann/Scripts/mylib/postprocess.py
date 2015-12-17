# coding: utf-8
import pandas as pd
from collections import defaultdict, Counter
from glob import glob
import re


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
