LOAD DATA INFILE "/georgetown/ds/data/artist_song_billboard.csv"
INTO TABLE artist_song_billboard
COLUMNS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

#SHOW VARIABLES LIKE "secure_file_priv";


