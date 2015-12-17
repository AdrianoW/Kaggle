# You can write R code here and then click "Run" to run it on our platform
# You can write R code here and then click "Run" to run it on our platform
setwd("~/Documents/Machine Learning/Kaggle/Spring/r")
# The readr library is the best way to read and write CSV files in R
library(readr)

# The competition datafiles are in the directory ../input
# List the files we have available to work with
#system("ls ../input")
my_vars <- c("VAR_1555", "VAR_1541", "VAR_0926", "VAR_0332", "VAR_0513", "VAR_0514", "VAR_0490", "VAR_1536", "VAR_1560", "VAR_0516", "VAR_0795", "VAR_0730", "VAR_0855", "VAR_1080", "VAR_0531", "VAR_0656", "VAR_0343", "VAR_1507", "VAR_0400", "VAR_0520", "VAR_0314", "VAR_0651", "VAR_0905", "VAR_0633", "VAR_1138", "VAR_1747", "VAR_1748", "VAR_0886", "VAR_0227", "VAR_0852", "VAR_0715", "VAR_0241", "VAR_0756", "VAR_0857", "VAR_0711", "VAR_0291", "VAR_0902", "VAR_0228", "VAR_1526", "VAR_1550", "VAR_0632", "VAR_1134", "VAR_0212", "VAR_0754", "VAR_1107", "VAR_0961", "VAR_1160", "VAR_0262", "VAR_1112", "VAR_0294")
my_vars1 <- c("VAR_0730", "VAR_0520", "VAR_0795", "VAR_0490", "VAR_0332", "VAR_1080", "VAR_0513", "VAR_1560", "VAR_0855", "VAR_1507", "VAR_0516", "VAR_0632", "VAR_1555", "VAR_0514", "VAR_0926", "VAR_0531", "VAR_0314", "VAR_1536", "VAR_0343", "VAR_1258", "VAR_0241", "VAR_0715", "VAR_0852", "VAR_0711", "VAR_0651", "VAR_0552", "VAR_1156", "VAR_1112", "VAR_0656", "VAR_0961", "VAR_1020", "VAR_0400", "VAR_0292", "VAR_1157", "VAR_0559", "VAR_1580", "VAR_0212", "VAR_0504", "VAR_1541", "VAR_0003", "VAR_0294", "VAR_0253", "VAR_1113", "VAR_0262", "VAR_0902", "VAR_1398", "VAR_0557", "VAR_1021", "VAR_0962")
my_vars2 <- c("VAR_0332", "VAR_0513", "VAR_1555", "VAR_1560", "VAR_0520", "VAR_0400", "VAR_1541", "VAR_0795", "VAR_0855", "VAR_0003", "VAR_0490", "VAR_1507", "VAR_1080", "VAR_0926", "VAR_0292", "VAR_1536", "VAR_0514", "VAR_1836", "VAR_0857", "VAR_1112", "VAR_1156", "VAR_0632", "VAR_0531", "VAR_1113", "VAR_0228", "VAR_0715", "VAR_0312", "VAR_0856", "VAR_0711", "VAR_1580", "VAR_0651", "VAR_0656", "VAR_0852", "VAR_0516", "VAR_0730", "VAR_0227", "VAR_0262", "VAR_0241", "VAR_0575", "VAR_0939", "VAR_0256", "VAR_0905", "VAR_0944", "VAR_1020", "VAR_0343", "VAR_1157", "VAR_1864", "VAR_0258", "VAR_1258", "VAR_0961")
my_hi_freq <- c("VAR_0228", "VAR_0212", "VAR_0899", "VAR_0543", "VAR_1087", "VAR_1082", "VAR_1180", "VAR_1081", "VAR_1179", "VAR_1181", "VAR_0541", "VAR_0296", "VAR_0891", "VAR_1618", "VAR_1617", "VAR_0297", "VAR_0659", "VAR_0316", "VAR_1494", "VAR_0293", "VAR_1738", "VAR_1690", "VAR_0317", "VAR_0313", "VAR_1685")
my_high_corr = c("VAR_0370", "VAR_0492" ,"VAR_0517" ,"VAR_0551" ,"VAR_1201" ,"VAR_1765" ,"VAR_0335" ,"VAR_0369" ,"VAR_0269" ,"VAR_0877" ,"VAR_1171" )
my_top_imp <- c("VAR_0002", "VAR_0003", "VAR_0004", "VAR_0061", "VAR_0063", "VAR_0064", "VAR_0065", "VAR_0069", "VAR_0070", "VAR_0071", "VAR_0072",
                "VAR_0074", "VAR_0078", "VAR_0079", "VAR_0080", "VAR_0081", "VAR_0082", "VAR_0084", "VAR_0085", "VAR_0087",
                "VAR_0088", "VAR_0089", "VAR_0136", "VAR_0198", "VAR_0212", "VAR_0227", "VAR_0228", "VAR_0233",
                "VAR_0234", "VAR_0235", "VAR_0238", "VAR_0241", "VAR_0242", "VAR_0272", "VAR_0273", "VAR_0302", "VAR_0304", "VAR_0322", "VAR_0361",
                "VAR_0540", "VAR_0544", "VAR_0550", "VAR_0555", "VAR_0579", "VAR_0687", "VAR_0707", "VAR_0708", "VAR_0712", "VAR_0716", "VAR_0720",
                "VAR_0721", "VAR_0722", "VAR_0795", "VAR_0853", "VAR_0860", "VAR_0868", "VAR_0877", "VAR_0880", "VAR_0881", "VAR_0884", "VAR_0885",
                "VAR_0886", "VAR_0899", "VAR_0917", "VAR_0922", "VAR_0968", "VAR_0970", "VAR_1110", "VAR_1114", "VAR_1119", "VAR_1120", "VAR_1123",
                "VAR_1124", "VAR_1125", "VAR_1127", "VAR_1128", "VAR_1129", "VAR_1130", "VAR_1136", "VAR_1144", "VAR_1145", "VAR_1146", "VAR_1147",
                "VAR_1148", "VAR_1149", "VAR_1150", "VAR_1151", "VAR_1154", "VAR_1184", "VAR_1266", "VAR_1329", "VAR_1330", "VAR_1337", "VAR_1358",
                "VAR_1380", "VAR_1495", "VAR_1530", "VAR_1531", "VAR_1823", "VAR_1824")

my_vars <- unique(c(my_vars, my_vars1, my_vars2, my_hi_freq, my_high_corr, my_top_imp))
my_vars_rnd1 <- c(
   "VAR_0795", "VAR_0855", "VAR_0550", "VAR_1100", "VAR_0730", "VAR_0490", "VAR_0503", "VAR_1042", "VAR_0332", "VAR_1160",
   "VAR_0520", "VAR_0926", "VAR_1041", "VAR_0262", "VAR_1080", "VAR_1015", "VAR_0732", "VAR_1536", "VAR_1017", "VAR_1584",
   "VAR_0258", "VAR_0901", "VAR_0781", "VAR_0955", "VAR_1635", "VAR_1507", "VAR_1156", "VAR_1555", "VAR_0531", "VAR_0314",
   "VAR_1108", "VAR_1058", "VAR_0905", "VAR_0770", "VAR_1580", "VAR_0505", "VAR_1110", "VAR_0857", "VAR_0514", "VAR_0862",
   "VAR_0400", "VAR_0760", "VAR_0715", "VAR_1560", "VAR_0517", "VAR_0485", "VAR_1403", "VAR_0632", "VAR_0292", "VAR_0515",
   "VAR_0513", "VAR_1157", "VAR_1260", "VAR_0228", "VAR_0227", "VAR_0291", "VAR_0979", "VAR_1112", "VAR_0978", "VAR_0711",
   "VAR_0852", "VAR_0713", "VAR_1538", "VAR_1113", "VAR_0488", "VAR_1261", "VAR_0548", "VAR_1105", "VAR_0324", "VAR_0486",
   "VAR_0856", "VAR_0245", "VAR_1400", "VAR_0977", "VAR_1636", "VAR_0754", "VAR_1077", "VAR_0256", "VAR_1059", "VAR_0995",
   "VAR_0709", "VAR_0253", "VAR_1454", "VAR_1393", "VAR_0636", "VAR_0967", "VAR_1529", "VAR_0902", "VAR_0850", "VAR_1551",
   "VAR_0980", "VAR_1553", "VAR_0198", "VAR_0981", "VAR_0241", "VAR_0910", "VAR_0484", "VAR_1073", "VAR_0516", "VAR_1526",
   "VAR_0312", "VAR_1541", "VAR_1394", "VAR_1924", "VAR_1704", "VAR_0961", "VAR_0401", "VAR_1258", "VAR_0504", "VAR_1382",
   "VAR_0287", "VAR_1395", "VAR_1455", "VAR_0920", "VAR_0975", "VAR_0260", "VAR_0337", "VAR_1921", "VAR_0982", "VAR_0341",
   "VAR_1579", "VAR_0964", "VAR_1504", "VAR_1550", "VAR_1089", "VAR_1159", "VAR_0651", "VAR_0534", "VAR_0302", "VAR_1102",
   "VAR_0366", "VAR_1088", "VAR_0633", "VAR_0976", "VAR_1143", "VAR_0310", "VAR_1450", "VAR_1107", "VAR_0487", "VAR_1256",
   "VAR_0272", "VAR_0251", "VAR_1050", "VAR_0212", "VAR_0974", "VAR_0267", "VAR_1397", "VAR_0356", "VAR_0756", "VAR_1057",
   "VAR_0656", "VAR_0559", "VAR_0307", "VAR_0962", "VAR_1109", "VAR_1255", "VAR_0549", "VAR_0818", "VAR_1398", "VAR_0357",
   "VAR_0723", "VAR_1024", "VAR_0309", "VAR_1051", "VAR_0329", "VAR_0483", "VAR_0918", "VAR_0717", "VAR_0277", "VAR_0468",
   "VAR_1449", "VAR_0877", "VAR_0540", "VAR_0921", "VAR_1141", "VAR_0308", "VAR_0552", "VAR_1837", "VAR_1391", "VAR_0694",
   "VAR_0482", "VAR_0984", "VAR_1533", "VAR_1509", "VAR_1562", "VAR_0257", "VAR_0304", "VAR_0557", "VAR_1532", "VAR_0966",
   "VAR_0489", "VAR_1012", "VAR_1175", "VAR_0546", "VAR_0367", "VAR_0266", "VAR_0263", "VAR_1055", "VAR_0376", "VAR_1759",
   "VAR_1590", "VAR_1396", "VAR_0322", "VAR_1552", "VAR_1209", "VAR_1650", "VAR_1401", "VAR_0614", "VAR_0994", "VAR_0358",
   "VAR_0745", "VAR_1452", "VAR_0331", "VAR_1923", "VAR_0963", "VAR_0929", "VAR_1753", "VAR_0003", "VAR_1535", "VAR_0939",
   "VAR_1332", "VAR_1060", "VAR_0965", "VAR_1649", "VAR_1010", "VAR_1539", "VAR_0542", "VAR_1104", "VAR_0547", "VAR_0858",
   "VAR_0288", "VAR_0408", "VAR_0359", "VAR_0343", "VAR_0281", "VAR_1328", "VAR_1534", "VAR_1743", "VAR_1134", "VAR_0252",
   "VAR_1578", "VAR_1021", "VAR_0323", "VAR_1453", "VAR_0339", "VAR_1839", "VAR_1558", "VAR_0383", "VAR_0273", "VAR_0838",
   "VAR_1064", "VAR_0465", "VAR_1752", "VAR_0255", "VAR_1137", "VAR_0335", "VAR_0533", "VAR_1758", "VAR_0254", "VAR_1864",
   "VAR_1554", "VAR_1922", "VAR_0635", "VAR_1117", "VAR_1176", "VAR_0750", "VAR_1133", "VAR_1138", "VAR_0321", "VAR_1020",
   "VAR_1710", "VAR_1029", "VAR_1563", "VAR_0538", "VAR_0328", "VAR_1836", "VAR_1106", "VAR_0362", "VAR_0692", "VAR_1451",
   "VAR_0543", "VAR_1506", "VAR_0865", "VAR_1843", "VAR_1527", "VAR_0575", "VAR_0336", "VAR_0726", "VAR_0294", "VAR_0299",
   "VAR_0944", "VAR_1004", "VAR_0873", "VAR_1749", "VAR_0986", "VAR_1402", "VAR_1744", "VAR_1340", "VAR_0874", "VAR_0729",
   "VAR_0334", "VAR_0946", "VAR_0693", "VAR_0773", "VAR_0532", "VAR_0403", "VAR_1103", "VAR_1130", "VAR_1213", "VAR_0701",
   "VAR_1132", "VAR_1023", "VAR_1399", "VAR_1925", "VAR_0368", "VAR_0844", "VAR_1750", "VAR_0316", "VAR_1392", "VAR_1009",
   "VAR_0242", "VAR_0784", "VAR_1013", "VAR_0735", "VAR_0839", "VAR_0535", "VAR_1748", "VAR_0537", "VAR_0846", "VAR_1148",
   "VAR_0736", "VAR_1576", "VAR_0740", "VAR_1135", "VAR_0609", "VAR_1747", "VAR_0319", "VAR_0842", "VAR_1746", "VAR_0653",
   "VAR_0182", "VAR_0734", "VAR_0360", "VAR_0790", "VAR_0620", "VAR_0181", "VAR_0397", "VAR_1525", "VAR_0220", "VAR_0764",
   "VAR_0827", "VAR_0753", "VAR_1561", "VAR_0714", "VAR_0405", "VAR_0886", "VAR_1063", "VAR_1075", "VAR_0545", "VAR_1745",
   "VAR_1867", "VAR_1154", "VAR_0556", "VAR_0942", "VAR_0608", "VAR_1818", "VAR_0763", "VAR_1420", "VAR_0386", "VAR_1003",
   "VAR_0612", "VAR_1099", "VAR_0772", "VAR_0845", "VAR_1508", "VAR_0621", "VAR_0033", "VAR_0699", "VAR_0949", "VAR_1721",
   "VAR_1150", "VAR_0909", "VAR_0268", "VAR_0317", "VAR_1418", "VAR_0948", "VAR_0778", "VAR_1542", "VAR_1427", "VAR_1528",
   "VAR_0864", "VAR_0828", "VAR_0866", "VAR_1098", "VAR_0999", "VAR_1079", "VAR_0791", "VAR_0815", "VAR_1026", "VAR_0695",
   "VAR_0751", "VAR_0973", "VAR_0741", "VAR_0872", "VAR_0908", "VAR_1429", "VAR_0945", "VAR_0746", "VAR_0937", "VAR_1537",
   "VAR_1067", "VAR_1503", "VAR_1383", "VAR_1565", "VAR_0560", "VAR_0859", "VAR_0752", "VAR_1030", "VAR_1263", "VAR_0180",
   "VAR_0762", "VAR_1146", "VAR_0749", "VAR_0851", "VAR_0130", "VAR_0464", "VAR_0289", "VAR_0613", "VAR_1905", "VAR_0521",
   "VAR_0618", "VAR_0785", "VAR_1549", "VAR_0627", "VAR_0558", "VAR_0843", "VAR_0364", "VAR_0138", "VAR_0412", "VAR_1153",
   "VAR_0968", "VAR_1212", "VAR_0700", "VAR_0710", "VAR_0832", "VAR_0755", "VAR_1572", "VAR_0282", "VAR_1926", "VAR_1910",
   "VAR_0338", "VAR_1559", "VAR_0286", "VAR_1546", "VAR_1421", "VAR_0634", "VAR_0449", "VAR_1908", "VAR_0375", "VAR_0340",
   "VAR_1911", "VAR_1002", "VAR_0824", "VAR_0758", "VAR_1933", "VAR_0439", "VAR_0774", "VAR_0628", "VAR_1868", "VAR_1423",
   "VAR_1566", "VAR_0860", "VAR_0261", "VAR_0107", "VAR_0718", "VAR_0893", "VAR_1419", "VAR_0131", "VAR_0275", "VAR_1056",
   "VAR_0320", "VAR_1068", "VAR_0837", "VAR_0587", "VAR_1706", "VAR_1573", "VAR_0428", "VAR_0626", "VAR_0576", "VAR_1556",
   "VAR_0783", "VAR_0494", "VAR_0923", "VAR_0969", "VAR_0707", "VAR_0115", "VAR_0911", "VAR_0300", "VAR_1101", "VAR_1819",
   "VAR_1707", "VAR_1904", "VAR_0631", "VAR_1217", "VAR_1569", "VAR_0099", "VAR_0414", "VAR_0271", "VAR_1169", "VAR_0748",
   "VAR_1177", "VAR_1152", "VAR_0361", "VAR_0413", "VAR_1906", "VAR_0625", "VAR_0719", "VAR_0311", "VAR_0971", "VAR_0816",
   "VAR_1172", "VAR_1930", "VAR_1173", "VAR_0398", "VAR_0825", "VAR_0674", "VAR_1339", "VAR_1111", "VAR_0419", "VAR_0265",
   "VAR_1916", "VAR_0327", "VAR_1919", "VAR_0370", "VAR_0591", "VAR_0492", "VAR_1557", "VAR_0808", "VAR_0697", "VAR_0279",
   "VAR_0114", "VAR_0956", "VAR_0853", "VAR_0351", "VAR_0393", "VAR_1127", "VAR_0987", "VAR_0392", "VAR_0585", "VAR_1139",
   "VAR_1338", "VAR_0574", "VAR_0475", "VAR_1076", "VAR_1184", "VAR_1564", "VAR_1740", "VAR_0912", "VAR_0854", "VAR_1548",
   "VAR_0588", "VAR_0683", "VAR_1917", "VAR_1651", "VAR_1140", "VAR_1005", "VAR_1074", "VAR_0947", "VAR_1144", "VAR_1022",
   "VAR_0389", "VAR_0820", "VAR_0584", "VAR_0318", "VAR_0249", "VAR_0841", "VAR_1166", "VAR_0108", "VAR_0301", "VAR_1264",
   "VAR_0201", "VAR_0285", "VAR_0913", "VAR_0768", "VAR_0139", "VAR_0496", "VAR_1909", "VAR_0098", "VAR_1334", "VAR_1653",
   "VAR_0298", "VAR_0297", "VAR_0350", "VAR_0402", "VAR_0804", "VAR_1390", "VAR_1092", "VAR_0501", "VAR_1927", "VAR_0922",
   "VAR_0231", "VAR_1170", "VAR_0523", "VAR_0882", "VAR_1742", "VAR_0716", "VAR_1078", "VAR_1571", "VAR_0091", "VAR_1410",
   "VAR_0007", "VAR_0248", "VAR_0050", "VAR_1741", "VAR_0244", "VAR_0152", "VAR_0346", "VAR_0471", "VAR_1912", "VAR_1920",
   "VAR_1652", "VAR_1147", "VAR_0506", "VAR_1155", "VAR_0270", "VAR_0145", "VAR_0629", "VAR_0333", "VAR_0904", "VAR_1866",
   "VAR_1751", "VAR_0269", "VAR_1711", "VAR_1540", "VAR_0463", "VAR_0315", "VAR_0799", "VAR_0121", "VAR_0611", "VAR_1066",
   "VAR_1062", "VAR_0469", "VAR_0561", "VAR_0437", "VAR_0016", "VAR_1416", "VAR_0622", "VAR_1333", "VAR_0092", "VAR_1116",
   "VAR_0812", "VAR_1120", "VAR_1817", "VAR_0090", "VAR_1575", "VAR_0928", "VAR_1163", "VAR_0680", "VAR_0290", "VAR_0870",
   "VAR_0554", "VAR_0698", "VAR_0566", "VAR_1065", "VAR_0903", "VAR_0722", "VAR_0345", "VAR_0002", "VAR_0296", "VAR_1714",
   "VAR_1705", "VAR_0761", "VAR_0054", "VAR_0890", "VAR_1914", "VAR_0571", "VAR_0553", "VAR_1913", "VAR_1168", "VAR_0809",
   "VAR_0897", "VAR_0592", "VAR_0883", "VAR_0391", "VAR_1838", "VAR_0363", "VAR_0814", "VAR_1570", "VAR_1407", "VAR_0525",
   "VAR_1412", "VAR_1207", "VAR_0570", "VAR_1907", "VAR_0051", "VAR_0917", "VAR_0623", "VAR_0278", "VAR_0972", "VAR_1086",
   "VAR_0105", "VAR_0988", "VAR_1185", "VAR_0970", "VAR_0459", "VAR_1151", "VAR_0771", "VAR_0129", "VAR_0803", "VAR_0250",
   "VAR_1070", "VAR_0991", "VAR_0863", "VAR_1736", "VAR_0473", "VAR_0004", "VAR_0445", "VAR_1167", "VAR_0344", "VAR_0384",
   "VAR_1414", "VAR_0053", "VAR_0347", "VAR_0355", "VAR_1262", "VAR_1192", "VAR_0056", "VAR_1378", "VAR_1408", "VAR_0696",
   "VAR_1754", "VAR_0819", "VAR_0933", "VAR_0034", "VAR_1426", "VAR_1171", "VAR_1415", "VAR_0186", "VAR_1090", "VAR_1158",
   "VAR_0992", "VAR_1083", "VAR_0387", "VAR_0440", "VAR_1915", "VAR_0187", "VAR_0744", "VAR_0388", "VAR_1413", "VAR_0562",
   "VAR_0161", "VAR_1037", "VAR_0399", "VAR_1713", "VAR_1071", "VAR_0603", "VAR_1084", "VAR_1840", "VAR_1162", "VAR_0151",
   "VAR_1903", "VAR_1820", "VAR_0512", "VAR_1409", "VAR_1131", "VAR_0455", "VAR_0171", "VAR_1719", "VAR_0654", "VAR_1862",
   "VAR_0014", "VAR_0280", "VAR_0577", "VAR_1033", "VAR_1547", "VAR_1093", "VAR_0035", "VAR_1343", "VAR_0742", "VAR_0889",
   "VAR_0798", "VAR_0313", "VAR_1918", "VAR_0348", "VAR_0617", "VAR_1456", "VAR_0555", "VAR_1091", "VAR_1197", "VAR_1219",
   "VAR_0385", "VAR_0264", "VAR_1757", "VAR_0522", "VAR_0185", "VAR_1267", "VAR_0150", "VAR_1567", "VAR_0390", "VAR_0826",
   "VAR_0055", "VAR_0813", "VAR_1035", "VAR_1417", "VAR_0125", "VAR_0829", "VAR_0491", "VAR_0247", "VAR_0983", "VAR_1756",
   "VAR_0094", "VAR_1007", "VAR_1047", "VAR_0365", "VAR_1221", "VAR_1085", "VAR_0822", "VAR_0539", "VAR_1577", "VAR_0330",
   "VAR_1178", "VAR_0782", "VAR_1196", "VAR_1545", "VAR_1928", "VAR_1061", "VAR_0624", "VAR_1860", "VAR_0451", "VAR_0013",
   "VAR_0276", "VAR_1425", "VAR_0243", "VAR_1568", "VAR_0112", "VAR_1703", "VAR_0454", "VAR_0326", "VAR_0109", "VAR_1194",
   "VAR_0093", "VAR_0919", "VAR_1865", "VAR_0679", "VAR_1214", "VAR_0564", "VAR_0672", "VAR_1869", "VAR_1344", "VAR_1115",
   "VAR_0284", "VAR_1899", "VAR_1136", "VAR_1025", "VAR_0834", "VAR_1223", "VAR_1229", "VAR_0058", "VAR_0057", "VAR_1202",
   "VAR_1069", "VAR_0195", "VAR_0924", "VAR_1122", "VAR_0953", "VAR_0788", "VAR_0396", "VAR_0049", "VAR_1853", "VAR_0306",
   "VAR_1387", "VAR_0225", "VAR_1205", "VAR_0835", "VAR_0106", "VAR_1121", "VAR_1755", "VAR_0666", "VAR_0938", "VAR_0411",
   "VAR_1863", "VAR_1386", "VAR_1206", "VAR_0415", "VAR_1203", "VAR_1897", "VAR_1583", "VAR_0737", "VAR_0619", "VAR_1411",
   "VAR_0930", "VAR_0670", "VAR_0600", "VAR_0678", "VAR_1854", "VAR_1543", "VAR_0519", "VAR_1720", "VAR_0885", "VAR_0349",
   "VAR_0120", "VAR_0048", "VAR_1511", "VAR_0568", "VAR_0372", "VAR_1039", "VAR_0303", "VAR_1859", "VAR_1161", "VAR_0371",
   "VAR_1634", "VAR_0934", "VAR_1038", "VAR_0434", "VAR_0154", "VAR_0985", "VAR_0436"
)

my_vars_rnd2<- c("VAR_0098","VAR_0399","VAR_0138","VAR_0463","VAR_0114","VAR_0130","VAR_0392","VAR_0393","VAR_1427","VAR_0411","VAR_0107","VAR_0412","VAR_0459","VAR_0445","VAR_0413","VAR_0181","VAR_0397","VAR_0398","VAR_0195","VAR_0182","VAR_0180","VAR_0449","VAR_0386","VAR_0437","VAR_0414","VAR_0396","VAR_0275","VAR_0795","VAR_0270","VAR_0909","VAR_0521","VAR_0277","VAR_0921","VAR_0920","VAR_0139","VAR_0387","VAR_0428","VAR_0115","VAR_1088","VAR_0264","VAR_1089","VAR_0371","VAR_0099","VAR_0131","VAR_0468","VAR_0918","VAR_1555","VAR_0271","VAR_0513","VAR_0855","VAR_0332","VAR_0730","VAR_0108","VAR_1541","VAR_0415","VAR_0388","VAR_0656","VAR_1560","VAR_0520","VAR_1864","VAR_0490","VAR_0503","VAR_1258","VAR_0905","VAR_0633","VAR_0262","VAR_0330","VAR_0917","VAR_1536","VAR_0496","VAR_0651","VAR_0942","VAR_0531","VAR_0241","VAR_1508","VAR_1137","VAR_0557","VAR_1080","VAR_1507","VAR_0328","VAR_0212","VAR_0314","VAR_0243","VAR_0756","VAR_1160","VAR_0247","VAR_0389","VAR_0400","VAR_0901","VAR_0248","VAR_0003","VAR_0505","VAR_0245","VAR_0926","VAR_1748","VAR_0514","VAR_0517","VAR_0540","VAR_1747","VAR_0292","VAR_0343","VAR_1021","VAR_0961","VAR_0516","VAR_0329","VAR_0253","VAR_0559","VAR_1260","VAR_0552","VAR_0857","VAR_1261","VAR_0258","VAR_0955","VAR_1020","VAR_0711","VAR_1579","VAR_1580","VAR_1086","VAR_0251","VAR_1113","VAR_0272","VAR_1550","VAR_0333","VAR_0902",
                 "VAR_0929","VAR_1383","VAR_0856","VAR_0308","VAR_1509","VAR_0755","VAR_0273","VAR_0339","VAR_0228","VAR_0715","VAR_0852","VAR_0945","VAR_1112","VAR_0310","VAR_0965","VAR_1141","VAR_0227","VAR_0360","VAR_1264","VAR_0632","VAR_1209","VAR_0683","VAR_1159","VAR_0288","VAR_0263","VAR_0963","VAR_1863","VAR_0693","VAR_0289","VAR_0886","VAR_1022","VAR_0256","VAR_1391","VAR_0489","VAR_1859","VAR_0754","VAR_1636","VAR_1156","VAR_1526","VAR_0946","VAR_1256","VAR_1818","VAR_0504","VAR_0962","VAR_0004","VAR_0257","VAR_0362","VAR_1099","VAR_0291","VAR_0309","VAR_1899","VAR_0341","VAR_0636","VAR_0924","VAR_1538","VAR_1105","VAR_1107","VAR_0484","VAR_0266","VAR_0862","VAR_1743","VAR_0719","VAR_0850","VAR_1134","VAR_1529","VAR_0383","VAR_0575","VAR_0692","VAR_0707","VAR_0225","VAR_1838","VAR_0331","VAR_0515","VAR_0276","VAR_0282","VAR_0781","VAR_0732","VAR_1255","VAR_0737","VAR_1836","VAR_1106","VAR_0279","VAR_0556","VAR_0709","VAR_1922","VAR_0287","VAR_0368","VAR_0323","VAR_0315","VAR_1138","VAR_0318","VAR_1840","VAR_0713","VAR_0860","VAR_0944","VAR_1563","VAR_1860","VAR_0560","VAR_0294","VAR_1399","VAR_0753","VAR_0358","VAR_1525","VAR_1897","VAR_0002","VAR_1573","VAR_1504","VAR_1263","VAR_0548","VAR_0483","VAR_0334","VAR_1398","VAR_0405","VAR_1921","VAR_0485","VAR_0482","VAR_0312","VAR_0949","VAR_0717","VAR_0758","VAR_0198","VAR_0877","VAR_1564","VAR_0694","VAR_0939","VAR_1820","VAR_1206","VAR_0695","VAR_0818","VAR_0680","VAR_1537","VAR_1924","VAR_0337","VAR_0752","VAR_0286","VAR_0971","VAR_0760","VAR_1157","VAR_0844","VAR_1923","VAR_1744","VAR_0361","VAR_0390","VAR_0885","VAR_0231","VAR_0336","VAR_0338","VAR_0722","VAR_0547","VAR_0788","VAR_1819","VAR_0549","VAR_0770","VAR_0488","VAR_0306","VAR_1703","VAR_1506","VAR_0372","VAR_1328","VAR_0280","VAR_1558","VAR_0546","VAR_0825","VAR_1382","VAR_0335","VAR_1170","VAR_1169","VAR_1132","VAR_1837","VAR_1745","VAR_0324","VAR_1332","VAR_0311","VAR_0910","VAR_0858","VAR_0261","VAR_0964","VAR_0487","VAR_0367","VAR_0268","VAR_0267","VAR_0244","VAR_0313","VAR_1704","VAR_0281","VAR_1707","VAR_0298","VAR_0486","VAR_0375","VAR_0734","VAR_0970","VAR_0359","VAR_1551","VAR_0653","VAR_0816","VAR_0634","VAR_0614","VAR_1539","VAR_0872","VAR_1635","VAR_1839","VAR_1393","VAR_1817","VAR_0304","VAR_1527","VAR_1752","VAR_0953","VAR_0631","VAR_1102","VAR_0408","VAR_0260","VAR_1571","VAR_0322","VAR_0674","VAR_1651","VAR_1540","VAR_0822","VAR_0908","VAR_1449","VAR_1705","VAR_0033","VAR_1576","VAR_0893",
                 "VAR_0120","VAR_0864","VAR_0635","VAR_0714","VAR_0832","VAR_0654","VAR_1634","VAR_0129","VAR_1758","VAR_1158","VAR_1562","VAR_0242","VAR_0356","VAR_1862","VAR_0300","VAR_0401","VAR_0492","VAR_0558","VAR_0555","VAR_0624","VAR_0296","VAR_0034","VAR_1557","VAR_0299","VAR_1395","VAR_0613","VAR_1554","VAR_1403","VAR_1535","VAR_0351","VAR_0742","VAR_1454","VAR_1176","VAR_1262","VAR_1402","VAR_1394","VAR_0376","VAR_1511","VAR_1753","VAR_0768","VAR_0364","VAR_1378","VAR_0252","VAR_1553","VAR_0220","VAR_0710","VAR_1450","VAR_0625","VAR_0297","VAR_0419","VAR_1930","VAR_0967","VAR_0355","VAR_0307","VAR_0370","VAR_1135","VAR_0475","VAR_0826","VAR_0824","VAR_1759","VAR_0919","VAR_1547","VAR_0451","VAR_0553","VAR_1869","VAR_0290","VAR_0834","VAR_1532","VAR_1104","VAR_1652","VAR_0121","VAR_0812","VAR_0762","VAR_1110","VAR_0718","VAR_1578","VAR_1455","VAR_0494","VAR_1533","VAR_0819","VAR_1108","VAR_0319","VAR_1710","VAR_0966","VAR_1400","VAR_1559","VAR_1042","VAR_0620","VAR_0301","VAR_1127","VAR_1534","VAR_1545","VAR_0357","VAR_0783","VAR_1333","VAR_0726","VAR_0772","VAR_1103","VAR_0327","VAR_0145","VAR_1867","VAR_0870","VAR_0436")

my_vars_a1 <- c("VAR_0002", "VAR_0003", "VAR_0070", "VAR_0071", "VAR_0072", "VAR_0080", "VAR_0081", "VAR_0082", "VAR_0087", "VAR_0088", "VAR_0089", "VAR_0147", "VAR_0149", "VAR_0154", "VAR_0155", "VAR_0164", "VAR_0165", "VAR_0174", "VAR_0175", "VAR_0197", "VAR_0198", "VAR_0224", "VAR_0225", "VAR_0233", "VAR_0234", "VAR_0235", "VAR_0242", "VAR_0254", "VAR_0255", "VAR_0279", "VAR_0282", "VAR_0288", "VAR_0302", "VAR_0304", "VAR_0309", "VAR_0322", "VAR_0323", "VAR_0324", "VAR_0329", "VAR_0341", "VAR_0366", "VAR_0367", "VAR_0368", "VAR_0403", "VAR_0408", "VAR_0465", "VAR_0514", "VAR_0515", "VAR_0516", "VAR_0517", "VAR_0545", "VAR_0550", "VAR_0552", "VAR_0553", "VAR_0559", "VAR_0560", "VAR_0689", "VAR_0690", "VAR_0823", "VAR_0836", "VAR_0877", "VAR_0927", "VAR_0952", "VAR_0954", "VAR_0959", "VAR_0969", "VAR_0973", "VAR_0974", "VAR_0975", "VAR_0983", "VAR_0985", "VAR_0989", "VAR_0993", "VAR_1008", "VAR_1011", "VAR_1021", "VAR_1022", "VAR_1074", "VAR_1075", "VAR_1076", "VAR_1077", "VAR_1078", "VAR_1079", "VAR_1080", "VAR_1100", "VAR_1105", "VAR_1110", "VAR_1115", "VAR_1116", "VAR_1117", "VAR_1118", "VAR_1120", "VAR_1121", "VAR_1122", "VAR_1123", "VAR_1124", "VAR_1125", "VAR_1126", "VAR_1127", "VAR_1128", "VAR_1129", "VAR_1192", "VAR_1194", "VAR_1196", "VAR_1197", "VAR_1338", "VAR_1339", "VAR_1449", "VAR_1450", "VAR_1462", "VAR_1575", "VAR_1576", "VAR_1578", "VAR_1579", "VAR_1741", "VAR_1742", "VAR_1743", "VAR_1744", "VAR_1745", "VAR_1746", "VAR_1854", "VAR_1855", "VAR_1856", "VAR_1857", "VAR_1873", "VAR_1874", "VAR_1875", "VAR_1876", "VAR_1877", "VAR_1878", "VAR_1879", "VAR_1880", "VAR_1881", "VAR_1882", "VAR_1883", "VAR_1884", "VAR_1885", "VAR_1886", "VAR_1887", "VAR_1888")
my_vars_d1 <- c("VAR_0546", "VAR_0547", "VAR_0589", "VAR_0590", "VAR_0593", "VAR_0594", "VAR_0595", "VAR_0601", "VAR_0602", "VAR_0603", "VAR_0615", "VAR_0616", "VAR_0644", "VAR_0645", "VAR_0678", "VAR_0679", "VAR_0680", "VAR_0941", "VAR_0957", "VAR_0958", "VAR_1111", "VAR_1155", "VAR_1158", "VAR_1214", "VAR_1240", "VAR_1257", "VAR_1308", "VAR_1309", "VAR_1310", "VAR_1311", "VAR_1324", "VAR_1326", "VAR_1327", "VAR_1329", "VAR_1330", "VAR_1331", "VAR_1358", "VAR_1370", "VAR_1377", "VAR_1379", "VAR_1443", "VAR_1444", "VAR_1445", "VAR_1611", "VAR_1612", "VAR_1613", "VAR_1614", "VAR_1615", "VAR_1616", "VAR_1632", "VAR_1633", "VAR_1634", "VAR_1635", "VAR_1636", "VAR_1637", "VAR_1638", "VAR_1639", "VAR_1640", "VAR_1641", "VAR_1642", "VAR_1643", "VAR_1644", "VAR_1645", "VAR_1646", "VAR_1647", "VAR_1684", "VAR_1702", "VAR_1703", "VAR_1704", "VAR_1705", "VAR_1706", "VAR_1707", "VAR_1708", "VAR_1709", "VAR_1729", "VAR_1734", "VAR_1735", "VAR_1795", "VAR_1796", "VAR_1797", "VAR_1798", "VAR_1799", "VAR_1800", "VAR_1816", "VAR_1821", "VAR_1822", "VAR_1825", "VAR_1826", "VAR_1828", "VAR_1829", "VAR_1830", "VAR_1848", "VAR_1849", "VAR_1850", "VAR_1868", "VAR_1928", "VAR_1930", "VAR_1931")
my_vars_c2 <- c("VAR_0016", "VAR_0056", "VAR_0057", "VAR_0058", "VAR_0059", "VAR_0060", "VAR_0061", "VAR_0062", "VAR_0066", "VAR_0076", "VAR_0083", "VAR_0134", "VAR_0135", "VAR_0136", "VAR_0137", "VAR_0243", "VAR_0245", "VAR_0249", "VAR_0250", "VAR_0253", "VAR_0256", "VAR_0262", "VAR_0266", "VAR_0280", "VAR_0281", "VAR_0303", "VAR_0343", "VAR_0351", "VAR_0360", "VAR_0400", "VAR_0410", "VAR_0482", "VAR_0483", "VAR_0484", "VAR_0485", "VAR_0486", "VAR_0487", "VAR_0488", "VAR_0489", "VAR_0617", "VAR_0618", "VAR_0623", "VAR_0627", "VAR_0717", "VAR_0719", "VAR_0730", "VAR_0742", "VAR_0758", "VAR_0768", "VAR_0778", "VAR_0815", "VAR_0816", "VAR_0818", "VAR_0821", "VAR_0822", "VAR_0824", "VAR_0825", "VAR_0826", "VAR_0827", "VAR_0830", "VAR_0832", "VAR_0834", "VAR_1020", "VAR_1027", "VAR_1029", "VAR_1030", "VAR_1031", "VAR_1033", "VAR_1034", "VAR_1035", "VAR_1037", "VAR_1038", "VAR_1039", "VAR_1045", "VAR_1046", "VAR_1047", "VAR_1386", "VAR_1387", "VAR_1388", "VAR_1389", "VAR_1537", "VAR_1561", "VAR_1566", "VAR_1567", "VAR_1571", "VAR_1572", "VAR_1574", "VAR_1577")
my_vars <- unique(c(my_top_imp, my_vars_a1, my_vars_d1, my_vars_c2, my_high_corr))

print(length(my_vars))

my_target <- "target"

# Read competition data files:
train <- read_csv("../I/train_proce.csv")

# Write to the log:
cat(sprintf("Training set has %d rows and %d columns\n", nrow(train), ncol(train)))

# Generate output files with write_csv(), plot() or ggplot()
# Any files you write to the current directory get shown as outputs
require(dplyr)
library(h2o)

# H2O Deep Learning


my_h2o <- h2o.init(nthreads = 6)
set.seed(87996786)
train10k <- train[sample(nrow(train), round(0.60*nrow(train))), c("ID", my_vars, my_target) ]
test <- anti_join(train, train10k)
test  <- test[,c("ID", my_vars, my_target)]
cat(sprintf("Training train10k set has %d rows and %d columns\n", nrow(train10k), ncol(train10k)))
#train10k <- train[, c("ID", my_vars, my_target) ]
my_h2o_train<-as.h2o(my_h2o,train10k)
my_h2o_test<-as.h2o(my_h2o,test)

#-----------------------------------------
train.80 <- train[sample(nrow(train), round(0.80*nrow(train))),  ]
test.80 <- anti_join(train, train.80)
cat(sprintf("Training train.70 set has %d rows and %d columns\n", nrow(train.80), ncol(train.80)))
my_h2o_train<-as.h2o(my_h2o,train.80)
my_h2o_test<-as.h2o(my_h2o,test.80)
features_full  <- setdiff(colnames(my_h2o_train), c('ID', 'target'))


#my_h2o_val <- as.h2o(my_h2o,val10k)
my_h2o_train[, "target"] <- as.factor(my_h2o_train[, "target"])
my_h2o_test[, "target"] <- as.factor(my_h2o_test[, "target"])

dropout  <- c(runif(3, 0, 0.6))

sl.dl <- h2o.deeplearning(x = my_vars, y = my_target,
                          training_frame = my_h2o_train,
                          variable_importances = TRUE,
                          hidden=c(1000,1000, 200),
                          # hidden_dropout_ratios=dropout
)
summary(sl.dl)
#write_csv(h2o.varimp(sl.dl), "varImpDL.csv")
my_pr <- as.data.frame(h2o.predict(sl.dl, my_h2o_train))
# Extract the relevant variables from the dataset.
sdata <- subset(train10k[,], select=c("ID", "target"))
output_train <- cbind(sdata, my_pr)

my_pr <- as.data.frame(h2o.predict(sl.dl, my_h2o_test))
# Extract the relevant variables from the dataset.
sdata <- subset(test[,], select=c("ID", "target"))
output_test <- cbind(sdata, my_pr)

library(ROCR)
prob  <- output_train$predict
pred  <- prediction(output_train$predict, output_train$target)
perf <- performance(pred, measure = "tpr", x.measure = "fpr")
auc <- performance(pred, measure = "auc")
auc <- auc@y.values[[1]]
roc.data <- data.frame(fpr=unlist(perf@x.values),
                       tpr=unlist(perf@y.values),
                       model="GLM")
ggplot(roc.data, aes(x=fpr, ymin=0, ymax=tpr)) +
   geom_ribbon(alpha=0.2) +
   geom_line(aes(y=tpr)) +
   ggtitle(paste0("ROC Curve w/ AUC=", auc))
#---------------------------------------------------------------
prob  <- output_test$predict
pred  <- prediction(output_test$predict, output_test$target)
perf <- performance(pred, measure = "tpr", x.measure = "fpr")
auc <- performance(pred, measure = "auc")
auc <- auc@y.values[[1]]
roc.data <- data.frame(fpr=unlist(perf@x.values),
                       tpr=unlist(perf@y.values),
                       model="GLM")
ggplot(roc.data, aes(x=fpr, ymin=0, ymax=tpr)) +
   geom_ribbon(alpha=0.2) +
   geom_line(aes(y=tpr)) +
   ggtitle(paste0("ROC Curve w/ AUC=", auc))

write_csv(my_output, "train10k_validate_h20_dl.csv")

c(runif(2, 0, 0.6))
train <- NULL
train10k <- NULL
my_h2o_train <- NULL

gc()
date()

test <- read_csv("../input/test.csv")
cat(sprintf("Test set has %d rows and %d columns\n", nrow(test), ncol(test)))
if(FALSE) {
   cat("making predictions\n")
   my_h2o_test <- as.h2o(my_h2o,test[, my_vars])
   my_pr <- as.data.frame(h2o.predict(sl.dl, my_h2o_test))
   my_output <- cbind(test[,"ID"],  my_pr[, "p1"])
   colnames(my_output)  <-  c("ID","target")

   write_csv( data.table(my_output), "H20DeepLearning.csv")
}

cat("making predictions in batches due to 8GB memory limitation\n")
submission <- data.frame(ID=test$ID)
submission$target <- NA
submission$p0 <- NA
submission$p1 <- NA
itersize = 10000
startIter=0
Iter = 1
for (rows in split(startIter*itersize+1:nrow(test), ceiling((startIter*itersize+1:nrow(test))/itersize))) {
   fname <- sprintf("H2O_pred%d.csv", Iter)
   cat(sprintf("Running %d Iteration fname %s\n", Iter, fname))
   my_h2o_test<-as.h2o(my_h2o, test[rows, my_vars])
   #cat(rows)
   submission[rows, c("target", "p0","p1")] <- as.data.frame(h2o.predict(sl.dl, my_h2o_test)[, c("predict", "p0", "p1")])
   #write_csv(submission[rows, ], fname)
   Iter = Iter + 1
   date()
}
write_csv(submission, "H20DeepLearning450Vars.csv")


train <- read_csv("../input/train_processed.csv")
test  <- read_csv("../input/test_processed.csv")
h <- sample(nrow(train), 120000)
tr <-train[h,]
val<-train[-h,]
h <- sample(nrow(val), round(0.50*nrow(val)))
val.1  <- val[h,]
val.2  <- val[-h,]
rm(train)
feature.names <- names(tr)[2:ncol(tr)-1]

my_h2o_train<-as.h2o(my_h2o,tr)
my_h2o_val<-as.h2o(my_h2o,val.1)
my_h2o_val.2<-as.h2o(my_h2o,val.2)
my_h2o_test<-as.h2o(my_h2o,test)
#features_full  <- setdiff(colnames(my_h2o_train), c('ID', 'target'))


#my_h2o_val <- as.h2o(my_h2o,val10k)
my_h2o_train[, "target"] <- as.factor(my_h2o_train[, "target"])
my_h2o_val[, "target"] <- as.factor(my_h2o_val[, "target"])
my_h2o_val.2[, "target"] <- as.factor(my_h2o_val.2[, "target"])
my_h2o_train <- h2o.removeVecs(my_h2o_train, "ID")
my_h2o_val <- h2o.removeVecs(my_h2o_val, "ID")
my_h2o_val.2 <- h2o.removeVecs(my_h2o_val.2, "ID")

ntrees_opt <- c(150)
maxdepth_opt <- c(3, 5, 7)
learnrate_opt <- c(0.01,0.01)
balance_classes <- c(FALSE)
nbins  <-  c(5, 10)
nbins_cats  <-  c(5,40)
min_rows  <- c(5,10,15)
hyper_parameters <- list(ntrees=ntrees_opt, max_depth=maxdepth_opt, learn_rate=learnrate_opt,
                         balance_classes=balance_classes, nbins=nbins, nbins_cats=nbins_cats,
                         min_rows=min_rows)

grid <- h2o.grid("gbm", hyper_params = hyper_parameters,
                 y = "target",
                 x = feature.names, distribution="bernoulli",
                 training_frame = my_h2o_train,
                 validation_frame =my_h2o_val)

# print grid search
grid_models <- lapply(grid@model_ids, function(model_id) { model = h2o.getModel(model_id) })
for (i in 1:length(grid_models)) {
   print ("==============================================================")
   auc  <-  calculate_auc(grid_models[[i]], my_h2o_val, val.1)
   print(sprintf("auc val1: %f", h2o.auc(grid_models[[i]])))
   print(sprintf("auc val1: %f", auc))

   auc2  <-  calculate_auc(grid_models[[i]], my_h2o_val.2, val.2)
   print(sprintf("auc val2: %f", auc2))

   print(sprintf("DIFF auc: %f", auc-auc2))
}
# calculate the metric for validation and the parameters used
calculate_auc  <- function(model, newdata, val_data) {

   params <- model@allparameters
   print(sprintf("bins_cat:%f
                 balance_class:%f
                 max_depth: %f
                 min_rows:%f
                 learn_rate:%f,
                 nbins:%f ",params$nbins_cat,
                 params$balance_classes,
                 params$max_depth,
                 params$min_rows,
                 params$learn_rate,
                 params$nbins))

   print(h2o.varimp(model)$variable[(1:10)])

   my_pr <- as.data.frame(h2o.predict(model, newdata=newdata))
   # Extract the relevant variables from the dataset.
   sdata <- subset(val_data[,], select=c("ID", "target"))
   output_test <- cbind(sdata, my_pr)

   pred  <- prediction(output_test$p1, val_data$target)
   perf <- performance(pred, measure = "tpr", x.measure = "fpr")
   auc <- performance(pred, measure = "auc")
   auc <- auc@y.values[[1]]
}

a  <- h2o.varimp(grid_models[[4]])
a$variable[(1:3)]

my_pr <- as.data.frame(h2o.predict(grid_models[[4]], newdata=my_h2o_val.2))
# Extract the relevant variables from the dataset.
sdata <- subset(val.2[,], select=c("ID", "target"))
output_test <- cbind(sdata, my_pr)

pred  <- prediction(output_test$p1, val.2$target)
perf <- performance(pred, measure = "tpr", x.measure = "fpr")
auc <- performance(pred, measure = "auc")
auc <- auc@y.values[[1]]
roc.data <- data.frame(fpr=unlist(perf@x.values),
                       tpr=unlist(perf@y.values),
                       model="GLM")
ggplot(roc.data, aes(x=fpr, ymin=0, ymax=tpr)) +
   geom_ribbon(alpha=0.2) +
   geom_line(aes(y=tpr)) +
   ggtitle(paste0("ROC Curve w/ AUC=", auc))

my_pr <- as.data.frame(h2o.predict(grid_models[[4]], newdata=my_h2o_test))
# Extract the relevant variables from the dataset.
sdata <- subset(test[,], select=c("ID"))
output_test <- cbind(sdata, my_pr)[,c("ID", "p1")]
colnames(output_test) <- c("ID", "target")
write_csv(output_test, '../Out/h20_gbm_grid_4.csv')


grid_models[[2]]
