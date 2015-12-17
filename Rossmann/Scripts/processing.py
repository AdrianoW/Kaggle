import pandas as pd
import numpy as np

train = pd.read_csv('./Input/train.csv', parse_dates=[2])
test = pd.read_csv('./Input/test.csv', parse_dates=[3])
store = pd.read_csv('./Input/store.csv')

# join the columns
print("Join with store")
train = pd.merge(train, store, on='Store')
test = pd.merge(test, store, on='Store')

# remove rows with zero sales
# mostly days where closed, but also 54 days when not
train = train.loc[train.Sales > 0]

# remove NaNs from Open
test.loc[ test.Open.isnull(), 'Open' ] = 1

# put in a  new dataset
#train2 = pd.merge( train, medians, on = columns, how = 'left' )
#test2 = pd.merge( test, medians, on = columns, how = 'left' )
#assert( len( test2 ) == len( test ))

#test2.loc[ test2.Open == 0, 'Sales' ] = 0
#assert( test2.Sales.isnull().sum() == 0 )

#test2[[ 'Id', 'Sales' ]].to_csv( './intermediate/mean.csv', index = False )

#print( "Up the leaderboard!" )

def toBinary(featureCol, df):
    values = set(df[featureCol].unique())
    newCol = [featureCol + val for val in values]
    for val in values:
        df[featureCol + val] = df[featureCol].map(lambda x: 1 if x == val else 0)
    return newCol

months = ["0", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
def createPromo2Now(row):
    '''
    Create a flag indicating that the store is having a promo2 now
    '''
    # check if the promo2 is set
    if(row['Promo2']==1):
        curr_year = row['year']
        curr_week = row['weekofyear']
        curr_month = row.get('month', 1000)
        
        # get errors
        if(curr_month == 1000):
            print row
            return 0
        
        # check if there is a week year
        if(curr_year>=row['Promo2SinceYear'] and \
           curr_week>=row['Promo2SinceWeek'] and \
           months[curr_month] in row['PromoInterval']):
            return 1
        else:
            return 0
    
    return 0
    
# Gather some features
def build_features(features, data):
    
    # do not change the raw data
    data = data.copy()
    
    # remove NaNs
    data.fillna(0, inplace=True)
    data.loc[data.Open.isnull(), 'Open'] = 1
    # Use some properties directly
    features.extend(['Store', 'CompetitionOpenSinceMonth',
                     'CompetitionOpenSinceYear', 'Promo', 'CompetitionDistance'])

    # add some more with a bit of preprocessing
    features.append('SchoolHoliday')
    data['SchoolHoliday'] = data['SchoolHoliday'].astype(float)

    # create the dummies for stateholidays
    features.append('StateHoliday')
    data.loc[data['StateHoliday'] == 'a', 'StateHoliday'] = '1'
    data.loc[data['StateHoliday'] == 'b', 'StateHoliday'] = '2'
    data.loc[data['StateHoliday'] == 'c', 'StateHoliday'] = '3'
    data['StateHoliday'] = data['StateHoliday'].astype(float)

    # add date information
    features.append('DayOfWeek')
    features.append('month')
    features.append('day')
    features.append('year')
    features.append('weekofyear')
    data['year'] = data.Date.dt.year
    data['month'] = data.Date.dt.month
    data['day'] = data.Date.dt.day
    data['DayOfWeek'] = data.Date.dt.dayofweek
    data['weekofyear'] = data.Date.dt.weekofyear

    # dummify storetype
    for x in ['a', 'b', 'c', 'd']:
        features.append('StoreType' + x)
        data['StoreType' + x] = data['StoreType'].map(lambda y: 1 if y == x else 0)

    # dummify assortment
    newCol = toBinary('Assortment', data)
    features += newCol
    
    # create flag for promo2 
    promo2now = data[['year','weekofyear','month','Promo2SinceWeek', 'Promo2SinceYear', 'PromoInterval', 'Promo2']].\
                apply(lambda r:createPromo2Now(r), axis = 1)
    data['promo2now'] = promo2now
    features.append('promo2now')
    
    # apply log to the competition distance to better spread the differences
    train.loc[ train.CompetitionDistance.isnull(), 'CompetitionDistance'] = 0
    data['CompetitionDistance'] = np.log1p(data['CompetitionDistance'])
    
    return data
       

## Start of main script
#print("Assume store open, if not provided")
#train.fillna(1, inplace=True)
#test.fillna(1, inplace=True)

print("Consider only open stores for training. Closed stores wont count into the score.")
train = train[train["Open"] != 0]
print("Use only Sales bigger then zero. Simplifies calculation of rmspe")
train = train[train["Sales"] > 0]

features = []

print("augment features")
train1 = build_features(features, train)
test1 = build_features([], test)
print(features)

#print("create statistical features")
# calculate statistical information about the sales of the stores
#columns = ['Store', 'DayOfWeek', 'Promo']
#medians = train.groupby( columns )['Sales']
#medians = medians.agg({'sales_median':np.median, 'sales_mean':np.mean, 'sales_min':min, 'sales_max':max})
#medians = medians.reset_index()

# put in a  new dataset
#train2 = pd.merge( train, medians, on = columns, how = 'left' )
#test2 = pd.merge( test, medians, on = columns, how = 'left' )
#assert( len( test2 ) == len( test ))

#test2.loc[ test2.Open == 0, 'Sales' ] = 0
#assert( test2.Sales.isnull().sum() == 0 )

SAVE_DIR = "./processed"
print("save files to processed")
train1.to_csv(SAVE_DIR+'train.csv', header=True, index=False)
test1.to_csv(SAVE_DIR+'test.csv', header=True, index=False)



