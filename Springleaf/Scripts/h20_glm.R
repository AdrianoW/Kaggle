setwd("~/Documents/Machine Learning/Kaggle/Spring/r")
# The readr library is the best way to read and write CSV files in R
library(readr)
library(h2o)
my_h2o <- h2o.init(nthreads = 6)

my_cols  <- c('VAR_0137', 'VAR_0121', 'VAR_0105', 'VAR_0795', 'VAR_0145', 'VAR_1127', 'VAR_0886', 'VAR_0006', 'VAR_0540', 'VAR_0013', 'VAR_1823', 'VAR_1380', 'VAR_0758', 'VAR_1377', 'VAR_0816', 'VAR_1114', 'VAR_0505', 'VAR_0360', 'VAR_0707', 'VAR_0241', 'VAR_1561', 'VAR_0719', 'VAR_0768', 'VAR_0970', 'VAR_1566', 'VAR_0722', 'VAR_1816', 'VAR_0877', 'VAR_1824', 'VAR_0007', 'VAR_1791', 'VAR_0274', 'VAR_0351', 'VAR_0359', 'VAR_1108', 'VAR_1128', 'VAR_1537', 'VAR_0228', 'VAR_0237', 'VAR_0717', 'VAR_0716', 'VAR_0200', 'VAR_0686', 'VAR_0227', 'VAR_0005', 'VAR_0263', 'VAR_0245', 'VAR_0514', 'VAR_0778', 'VAR_0343', 'VAR_0483', 'VAR_0198', 'VAR_0832', 'VAR_0400', 'VAR_1042', 'VAR_0212', 'VAR_1020', 'VAR_0342', 'VAR_1572', 'VAR_1119', 'VAR_0969', 'VAR_1109', 'VAR_1123', 'VAR_0815', 'VAR_0482', 'VAR_1030', 'VAR_0860', 'VAR_0257', 'VAR_0358', 'VAR_1124', 'VAR_0516', 'VAR_1565', 'VAR_1934', 'VAR_1567', 'VAR_1579', 'VAR_0273', 'VAR_0826', 'VAR_1571', 'VAR_1029', 'VAR_0324', 'VAR_1389', 'VAR_0550', 'VAR_1005', 'VAR_0266', 'VAR_1110', 'VAR_1004', 'VAR_0242', 'VAR_1148', 'VAR_1540', 'VAR_0016', 'VAR_1003', 'VAR_1576', 'VAR_0818', 'VAR_0621', 'VAR_1125', 'VAR_1532', 'VAR_1551', 'VAR_0515', 'VAR_0517', 'VAR_0834', 'VAR_0262', 'VAR_0272', 'VAR_0254', 'VAR_0325', 'VAR_1217', 'VAR_1117', 'VAR_0988', 'VAR_1122', 'VAR_1129', 'VAR_0002', 'VAR_0003', 'VAR_1556', 'VAR_1100', 'VAR_0824', 'VAR_0822', 'VAR_0723', 'VAR_0255', 'VAR_0408', 'VAR_0626', 'VAR_1116', 'VAR_0831', 'VAR_0084', 'VAR_0726', 'VAR_0322', 'VAR_0821', 'VAR_0968', 'VAR_1790', 'VAR_0503', 'VAR_0354', 'VAR_0827', 'VAR_1154', 'VAR_1185', 'VAR_1121', 'VAR_0825', 'VAR_0560', 'VAR_0742', 'VAR_0836', 'VAR_1120', 'VAR_0656', 'VAR_0561', 'VAR_1118', 'VAR_0814', 'VAR_1143', 'VAR_0329', 'VAR_0282', 'VAR_0323', 'VAR_0034', 'VAR_1539', 'VAR_0794', 'VAR_1126', 'VAR_0341', 'VAR_1041', 'VAR_0820', 'VAR_1387', 'VAR_0870', 'VAR_1570', 'VAR_0061', 'VAR_0792', 'VAR_0813', 'VAR_0489', 'VAR_0256', 'VAR_0559', 'VAR_1015', 'VAR_0288', 'VAR_0361', 'VAR_0267', 'VAR_0812', 'VAR_0309', 'VAR_0823', 'VAR_0536', 'VAR_0302', 'VAR_1073', 'VAR_1006', 'VAR_1578', 'VAR_0631', 'VAR_1388', 'VAR_1056', 'VAR_0987', 'VAR_0357', 'VAR_0539', 'VAR_0062', 'VAR_1133', 'VAR_1400', 'VAR_1554', 'VAR_1329', 'VAR_1564', 'VAR_1147', 'VAR_1038', 'VAR_1853', 'VAR_0253', 'VAR_0806', 'VAR_0304', 'VAR_0998', 'VAR_0985', 'VAR_1031', 'VAR_1832', 'VAR_1007', 'VAR_0835', 'VAR_1546', 'VAR_0017', 'VAR_1014', 'VAR_1456', 'VAR_0999', 'VAR_1580', 'VAR_0279', 'VAR_1144', 'VAR_0613', 'VAR_1184', 'VAR_0465', 'VAR_0078', 'VAR_1034', 'VAR_1765', 'VAR_0353', 'VAR_1053', 'VAR_0535', 'VAR_0488', 'VAR_0984', 'VAR_0922', 'VAR_0793', 'VAR_0819', 'VAR_1074', 'VAR_0990', 'VAR_0991', 'VAR_0004', 'VAR_1018', 'VAR_0996', 'VAR_1023', 'VAR_0627', 'VAR_1575', 'VAR_1017', 'VAR_0015', 'VAR_1052', 'VAR_1033', 'VAR_1035', 'VAR_1016', 'VAR_0992', 'VAR_0905', 'VAR_1535', 'VAR_0829', 'VAR_0983', 'VAR_0051', 'VAR_0417', 'VAR_0830', 'VAR_0623', 'VAR_1742', 'VAR_0352', 'VAR_1559', 'VAR_1920', 'VAR_0056', 'VAR_0074', 'VAR_1748', 'VAR_1386', 'VAR_0989', 'VAR_1039', 'VAR_0611', 'VAR_0336', 'VAR_0058', 'VAR_0335', 'VAR_0050', 'VAR_1008', 'VAR_0617', 'VAR_0487', 'VAR_1392', 'VAR_1151', 'VAR_1404', 'VAR_1046', 'VAR_1267', 'VAR_0419', 'VAR_1229', 'VAR_1047', 'VAR_1749', 'VAR_1740', 'VAR_0425', 'VAR_1149', 'VAR_1130', 'VAR_1022', 'VAR_0260', 'VAR_0337', 'VAR_0037', 'VAR_0298', 'VAR_1549', 'VAR_1866', 'VAR_0618', 'VAR_0300', 'VAR_0057', 'VAR_0997', 'VAR_0104', 'VAR_0848', 'VAR_0318', 'VAR_1872', 'VAR_1058', 'VAR_0036', 'VAR_0620', 'VAR_1747', 'VAR_0231', 'VAR_0085', 'VAR_0063', 'VAR_1019', 'VAR_1028', 'VAR_1002', 'VAR_0925', 'VAR_0356', 'VAR_0405', 'VAR_0454', 'VAR_1011', 'VAR_0283', 'VAR_1043', 'VAR_0687')
train <- read_csv("../input/train_processed.csv")
test  <- read_csv("../input/test_processed.csv")
h <- sample(nrow(train), 70000)
tr <-train[h,]
val<-train[-h,]
h <- sample(nrow(val), round(0.50*nrow(val)))
val.1  <- val[h,]
val.2  <- val[-h,]
rm(train)

# send to h20
my_h2o_train<-as.h2o(my_h2o,tr)
my_h2o_val<-as.h2o(my_h2o,val.1)
my_h2o_test<-as.h2o(my_h2o,test)

# tansform to factor
my_h2o_train[, "target"] <- as.factor(my_h2o_train[, "target"])
my_h2o_val[, "target"] <- as.factor(my_h2o_val[, "target"])
my_h2o_test[, "target"] <- as.factor(my_h2o_test[, "target"])

# run the glm
glm  <- h2
