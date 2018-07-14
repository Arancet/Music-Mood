ALTER TABLE `song_artist_universe` ADD `artist_kaggle` VARCHAR(300)  NULL; 
ALTER TABLE `song_artist_universe` ADD `song_kaggle` VARCHAR(300)  NULL; 
ALTER TABLE `song_artist_universe` ADD `year_kaggle` int  NULL; 
ALTER TABLE `song_artist_universe` ADD `id_lyrics_kaggle` int  NULL; 

UPDATE song_artist_universe
SET song_kaggle = LOWER(REPLACE(song,' ','-')), artist_kaggle = LOWER(REPLACE(artist,' ','-'))
WHERE id  > 0;

SELECT A.artist, B.artist, A.song, B.song, A.id
FROM lyrics_kaggle A JOIN song_artist_universe B ON A.artist = B.artist_kaggle AND A.song = B.song_kaggle;

UPDATE song_artist_universe B, lyrics_kaggle A
SET year_kaggle = A.year, id_lyrics_kaggle = A.id
WHERE A.artist = B.artist_kaggle AND A.song = B.song_kaggle;

UPDATE song_artist_universe B, year_song A 
SET B.year_kaggle = A.year
WHERE B.year_kaggle IS NULL AND A.song_kaggle = B.song_kaggle;

select count(*) from(
SELECT DISTINCT artist, song FROM billboard_ranking) C;

INSERT INTO `musicmood`.`song_artist_universe`
(`song`,
`artist`)
SELECT DISTINCT song, artist FROM billboard_ranking;

SELECT A.artist, B.artist, A.song, B.song, A.id
FROM lyrics_kaggle A JOIN song_artist_universe B ON soundex(A.artist) = soundex(B.artist) AND soundex(A.song) = soundex(B.song);


INSERT INTO `musicmood`.`year_song`
(`song`,
`year`)
SELECT DISTINCT song, YEAR(SEMANA) FROM billboard_ranking;



ALTER TABLE `year_song` ADD `song_kaggle` VARCHAR(300)  NULL; 

UPDATE year_song
SET song_kaggle = LOWER(REPLACE(song,' ','-'))
WHERE id  > 0;

SELECT A.artist, A.song, B.song, A.Year, A.id
FROM lyrics_kaggle A JOIN year_song B ON A.year = B.year AND A.song = B.song_kaggle;



SELECT * FROM  song_artist_universe;
SELECT * FROM  lyrics_kaggle;
#Query de rangos
SELECT MIN(year_kaggle), MAX(year_kaggle) FROM  song_artist_universe;
SELECT MIN(year) , MAX(year) FROM  lyrics_kaggle where year between 1950 and 2018;

#POPULARITY PER YEAR
SELECT YEAR(semana) anio,LOWER(REPLACE(artist,' ','-')) artist_kaggle,
LOWER(REPLACE(song,' ','-')) song_kaggle, count(*) weeks_per_year,
count(*) * (100-avg(ranking)) popularity    
FROM  billboard_ranking
GROUP BY YEAR(semana), artist,song  
ORDER BY 2,3,5 desc;

#QUERY VALIDACION CRUCE ANIOS
SELECT A.artist, A.song, B.song_kaggle, A.year_kaggle, B.anio, A.id
FROM song_artist_universe A JOIN (
SELECT MIN(YEAR(semana)) anio,
LOWER(REPLACE(artist,' ','-')) artist_kaggle,
LOWER(REPLACE(song,' ','-')) song_kaggle
FROM  billboard_ranking
GROUP BY artist,song ) B ON A.artist_kaggle = B.artist_kaggle AND A.song_kaggle = B.song_kaggle AND A.year_kaggle != B.anio;

#QUERY DE CORRECCION DE ANIOS
UPDATE song_artist_universe A, 
(
SELECT MIN(YEAR(semana)) anio,
LOWER(REPLACE(artist,' ','-')) artist_kaggle,
LOWER(REPLACE(song,' ','-')) song_kaggle
FROM  billboard_ranking
GROUP BY artist,song ) B 
SET A.year_kaggle = B.anio
WHERE A.artist_kaggle = B.artist_kaggle AND A.song_kaggle = B.song_kaggle AND A.year_kaggle != B.anio;

#QUERY DE DISTRIBUCION DE MATCH
SELECT TIPO, COUNT(*) FROM
(
SELECT CASE
	WHEN  id_lyrics_kaggle IS NULL THEN 'PENDING'
    ELSE 'MATCH'
	END TIPO FROM song_artist_universe
) A
GROUP BY TIPO;

#FUZZY LOGIC
SELECT * FROM musicmood.fuzzy_matches;

ALTER TABLE `fuzzy_matches` ADD `id_rank` INT  NULL; 
ALTER TABLE `fuzzy_matches` ADD `id_lyric` INT  NULL; 

UPDATE fuzzy_matches
SET id_rank = CAST(REPLACE(__id_left,'_left','') AS UNSIGNED),
	    id_lyric = CAST(REPLACE(__id_right,'_right','') AS UNSIGNED);
        
UPDATE song_artist_universe A,
(SELECT A.id id_lyric, B.id id_rank 
FROM lyrics_kaggle A 
JOIN fuzzy_matches C ON A.artist = C.artist AND A.song = C.song
JOIN song_artist_universe B on B.artist_kaggle = C.artist_kaggle and B.song_kaggle = C.song_kaggle) M 
SET A.id_lyrics_kaggle = M.id_lyric
WHERE A.id_lyrics_kaggle IS NULL
AND A.id = M.id_rank;

SELECT * FROM song_artist_universe WHERE id = 7550;
SELECT * FROM lyrics_kaggle WHERE id = 238796;

#ELIMINACION DE COMILLAS SIMPLES Y DOBLES
update song_artist_universe
set song_kaggle = REPLACE(song_kaggle,"'"," "),
      artist_kaggle = REPLACE(artist_kaggle,"'"," ")
WHERE id_lyrics_kaggle IS NULL;

#ADD COLUMNS TO SONGS_DATASET 
ALTER TABLE `songs_dataset` ADD `artist_kaggle` VARCHAR(300)  NULL; 
ALTER TABLE `songs_dataset` ADD `song_kaggle` VARCHAR(300)  NULL; 
ALTER TABLE `songs_dataset` ADD `id_lyrics_kaggle` INT  NULL; 

#UPDATE TO POPULATE COMPARISON COLUMNS
UPDATE songs_dataset
SET song_kaggle = LOWER(REPLACE(song,' ','-')), artist_kaggle = LOWER(REPLACE(artist,' ','-'))
WHERE id  > 0;

update songs_dataset
set song_kaggle = REPLACE(REPLACE(song_kaggle,"'"," "),'"',''),
      artist_kaggle = REPLACE(REPLACE(artist_kaggle,"'"," "),'"','')
WHERE id_lyrics_kaggle IS NULL;

#MATCH QUERY BETWEEN songs_dataset AND lyics_kaggle

SELECT COUNT(*)#A.trackid, B.id, A.year, A.artist_kaggle, A.song_kaggle
FROM songs_dataset A,  lyrics_kaggle B
WHERE A.artist_kaggle = B.artist
      AND A.song_kaggle = B.song;

#UPDATE OF MATCHING ID
UPDATE songs_dataset A,  lyrics_kaggle B
SET A.id_lyrics_kaggle = B.id
WHERE A.artist_kaggle = B.artist
      AND A.song_kaggle = B.song;
      
      SELECT MIN(year) from songs_dataset;


#Review of Fuzzy Matches for songs_dataset

select * from fuzzy_match_songs_dataset where match_score >=0;

#MATCHES BETWEEN songs_dataset  and song_Artist_universe
SELECT DISTINCT TRACKID FROM songs_dataset LIMIT 10;
SELECT COUNT(*) FROM song_artist_universe LIMIT 10;

#11958 exact matches, DUPLICATES FOUND 6743 UNIQUES
SELECT  DISTINCT A.TRACKID, A.artist, A.song   FROM 
songs_dataset A JOIN song_artist_universe B ON A.artist = B.artist AND A.song = B.song;

#11925
SELECT COUNT(*) FROM 
songs_dataset A JOIN song_artist_universe B ON A.artist_kaggle = B.artist_kaggle AND A.song_kaggle = B.song_kaggle;

#ALTER TABLE TO ADD COLUMN TRACKID
ALTER TABLE `song_artist_universe` ADD `trackid` VARCHAR(50) NULL; 

#UPDATE TRACKID (6743 MATCHES)
UPDATE song_artist_universe B,songs_dataset A 
SET B.trackid = A.trackid
WHERE A.artist = B.artist AND A.song = B.song;

#LYRICS AND TRACKID
SELECT COUNT(*) FROM song_artist_universe A
WHERE A.trackid IS NOT NULL AND A.id_lyrics_kaggle IS NOT NULL;

#DISTRIBUTION
SELECT year_kaggle, count(*) 
FROM song_artist_universe
WHERE trackid IS  NOT NULL
GROUP BY year_kaggle;

#FUZZY MATCHES WITH SONG_DATASET
SELECT * FROM fuzzy_match_song_artist_universe
where match_score >= 0.90;

SELECT distinct artist_right, song_right FROM fuzzy_match_song_artist_universe
where match_score >= 0.90;

#ALTER LYRICS kaggle
ALTER TABLE `lyrics_kaggle` ADD `artist_normal` VARCHAR(300)  NULL; 
ALTER TABLE `lyrics_kaggle` ADD `song_normal` VARCHAR(300)  NULL; 

UPDATE lyrics_kaggle
SET artist_normal = REPLACE(artist,'-',' '),
song_normal = REPLACE(song,'-',' ')
WHERE id > 0;

SELECT * FROM lyrics_kaggle order by id desc LIMIT 100;

#UPDATE TRACKID FROM FUZZY MATCHES
SELECT DISTINCT A.trackid, 
U.id #, F.* 
FROM songs_dataset A,
song_artist_universe U,
fuzzy_match_song_artist_universe F
WHERE U.trackid IS NULL
AND F.artist_left = A.artist 
AND F.artist_right = U.artist
AND F.song_left = A.song
AND F.song_right = U.song;

SELECT TIPO, COUNT(*) FROM
(
SELECT CASE 
	WHEN trackid is null THEN 'N/A'
    ELSE 'MATCH'
END TIPO
FROM song_artist_universe
) M
GROUP BY TIPO;
#6983 MATCHES



#ENGINEERING FEATURES

#POPULARITY PER YEAR
SELECT YEAR(semana) anio,LOWER(REPLACE(artist,' ','-')) artist_kaggle,
LOWER(REPLACE(song,' ','-')) song_kaggle, count(*) weeks_per_year,
count(*) * (100-avg(ranking)) popularity    
FROM  billboard_ranking
GROUP BY YEAR(semana), artist,song  
ORDER BY 2,3,5 desc;
#NUMBER OF WEEKS
ALTER TABLE `song_artist_universe` ADD `num_weeks` INT  NULL;

UPDATE song_artist_universe A,
(SELECT song, artist, count(*) num_weeks
FROM billboard_ranking
GROUP BY song,artist) W
SET A.num_weeks = W.num_weeks
WHERE A.song = W.song AND A.artist = W.artist;


#BILLBOARD POPULARITY
ALTER TABLE `song_artist_universe` ADD `bill_popularity` float  NULL; 

UPDATE song_artist_universe A,
(SELECT song, artist, count(*) * (100-avg(ranking)) popularity  
FROM billboard_ranking
GROUP BY song,artist) W
SET A.bill_popularity = W.popularity
WHERE A.song = W.song AND A.artist = W.artist






