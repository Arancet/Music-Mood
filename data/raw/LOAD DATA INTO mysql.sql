LOAD DATA INFILE "/georgetown/ds/data/songs_dataset.csv"
INTO TABLE songs_dataset
COLUMNS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

#SHOW VARIABLES LIKE "secure_file_priv";


