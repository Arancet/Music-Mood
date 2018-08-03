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
#7772 MATCHES



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
WHERE A.song = W.song AND A.artist = W.artist;

#COMPLETE MDS
SELECT count(*) FROM musicmood.songs_metadata WHERE year = '';

INSERT INTO `musicmood`.`songs_dataset`
(`trackid`,
`song`,
`artist`)
SELECT track_id, title, artist_name FROM musicmood.songs_metadata WHERE year = '';

SELECT  DISTINCT A.TRACKID, A.artist, A.song   FROM 
songs_dataset A JOIN song_artist_universe B ON A.artist = B.artist AND A.song = B.song
where B.trackid IS NULL;

#739 more matches
UPDATE song_artist_universe B,songs_dataset A 
SET B.trackid = A.trackid
WHERE A.artist = B.artist AND A.song = B.song AND B.trackid IS NULL;

select * from all_songs_boxes;

#OBTAINING YEAR FROM SONGS_PER_YEAR
SELECT count(*) FROM 
songs_dataset A JOIN songs_per_year B ON A.song = B.name_song
where A.year is null;

UPDATE songs_dataset A , songs_per_year B
SET  A.year = B.date_year
WHERE A.song = B.name_song
AND A.year is null;


SELECT COUNT(*) FROM  fuzzy_match_song_artist_universe2 WHERE MATCH_RANK = 1;

#UPDATE TRACKID FROM FUZZY MATCHES
SELECT DISTINCT A.trackid, 
U.id #, F.* 
FROM songs_dataset A,
song_artist_universe U,
fuzzy_match_song_artist_universe2 F
WHERE U.trackid IS NULL
AND F.match_rank = 1
AND F.artist_left = A.artist 
AND F.artist_right = U.artist
AND F.song_left = A.song
AND F.song_right = U.song;


UPDATE song_artist_universe U,
songs_dataset A,
fuzzy_match_song_artist_universe2 F
SET U.trackid = A.trackid
WHERE U.trackid IS NULL
AND F.match_rank = 1
AND F.artist_left = A.artist 
AND F.artist_right = U.artist
AND F.song_left = A.song
AND F.song_right = U.song;

#QUERY DE DISTRIBUCION DE MATCH MDS
SELECT TIPO, COUNT(*) FROM
(
SELECT CASE
	WHEN  trackid IS NULL THEN 'PENDING'
    ELSE 'MATCH'
	END TIPO FROM song_artist_universe
) A
GROUP BY TIPO;

#Matches Genre Popularity
select count(*) from  song_artist_universe B,genre_popularity_time A
where  concat(B.artist,B.song) = A.unique_id; 

select distinct B.artist, B.song, A.unique_id
from  song_artist_universe B,genre_popularity_time A
where  concat(B.artist,B.song) = A.unique_id; 

#Matches Genre Popularity
select count(*) from  songs_dataset B,genre_popularity_time A
where  concat(B.artist,B.song) = A.unique_id ;

select B.trackid, B.artist, B.song, A.unique_id 
from  songs_dataset B,genre_popularity_time A
where  concat(B.artist,B.song) = A.unique_id ;

update  genre_popularity_time A,songs_dataset B
set A.trackid = B.trackid
where  concat(B.artist,B.song) = A.unique_id ;


select * from genre_popularity_time;

#MATCHES ALL SONGS BOXES
select count(*) from all_songs_boxes where trackid is not null;

update  all_songs_boxes A,songs_dataset B
set A.trackid = B.trackid
where  concat(B.artist,B.song) = A.unique_id ;

#THE MEG
INSERT INTO  songs_instance 
SELECT  A.trackid,  A.bill_popularity,
F.song, F.artist, F.weeks_ranked, F.highest_rank,
F.lowest_rank, F.weeks_top_spot, F.weeks_top_10,
F.weeks_top_20, F.weeks_top_30, F.weeks_top_40,
F.weeks_top_50, F.average_rank, F.first_appearance,
F.year_first_appear, F.last_appearance, F.year_last_appear, F.decade,
B.danceability, B.duration, B.end_of_fade_in, B.energy,
B.key_confidence, B.key_song, B.loudness, B.mode,
B.mode_confidence, B.start_of_fade_out, B.tempo,
B.time_signature, B.time_signature_confidence, 
C.GrossDomesticProduct, C.PersonalIncome, C.Unemployment_Rate_Year_AVG, C.Adjusted_CPI_Year_AVG,
C.Misery_Index_Year_AVG, D.genre,
E.Blues, E.Cumulative_Weeks, E.Unique_Song_Count, E.Unique_Artist_Count, E.Chart_Count as_chart_count, E.Total_Songs, 
E.Find_Duplicate_Titles, E.First_Year_on_Chart, E.Years_on_Chart, 
E.Points, E.Random, E.ChildrensMusic, E.Christian_Gospel, E.Christmas, 
E.Classical, E.Comedy, E.Country_, E.Folk, E.House_Electronic_Trance, 
E.Jazz, E.Last_Position, E.Latin, E.Latitude, E.Longitude, E.Metal, E.Neighborhood, 
E.Number_of_Records, E.Peak_Position, E.Pop_Standards, E.Pop, E.Punk, E.R_And_B, E.Rank as_rank, 
E.Rap_Hip_Hop, E.Rock_And_Roll, E.Rock, E.Ska_Reggae_Dancehall, E.Soul, E.Soundtrack, 
E.Spoken_Word, E.Weeks_on_Chart, E.Primary_Genre as_primary_genre,
G.number_1s, G.weeks_at_number_1,
H.chart_appearances, H.artist_weeks_at_number_1,
I.tempo, I.speed_general,
A.num_weeks
FROM song_artist_universe A 
LEFT OUTER JOIN songs_ranking_features F ON A.trackid = F.trackid
LEFT OUTER JOIN songs_new_features B ON A.trackid = B.track_id
LEFT OUTER JOIN US_Economic_Indicators_1948_2018 C ON A.year_kaggle = C.Year
LEFT OUTER JOIN  songs_genre D ON A.trackid = D.trackid
LEFT OUTER JOIN  songs_boxes E ON A.trackid = E.trackid
LEFT OUTER JOIN  artist_number_1s G ON A.artist = G.artist
LEFT OUTER JOIN  chart_appearances H ON A.artist = H.artist
LEFT OUTER JOIN  speed I ON A.trackid = I.track_id
WHERE A.trackid IS NOT NULL;




SELECT D.trackid, COUNT(*)
FROM genre_popularity_time D
WHERE trackid IS NOT NULL
GROUP BY D.trackid
HAVING COUNT(*) > 1;

SELECT * FROM genre_popularity_time 
WHERE trackid = 'TRAJBSL128F428A021';


SELECT E.trackid, COUNT(*)
FROM all_songs_boxes E
WHERE trackid IS NOT NULL
GROUP BY E.trackid
HAVING COUNT(*) > 1;

SELECT * FROM all_songs_boxes 
WHERE trackid = 'TRAJBSL128F428A021';


#OBTAIN TRACK ID 

SELECT A.trackid FROM 
song_artist_universe A join songs_ranking_features B
ON A.artist = B.artist AND A.song = B.song 
where A.trackid is not null;

UPDATE songs_ranking_features B, song_artist_universe A 
SET B.trackid = A.trackid
WHERE A.artist = B.artist AND A.song = B.song 
AND A.trackid is not null;


#populate songs_genre
INSERT INTO songs_genre (trackid, genre)
SELECT trackid, MAX(primary_genre) 
FROM genre_popularity_time
WHERE trackid IS NOT NULL
group by trackid;





SELECT trackid from songs_instance 
where genre is null and artist in 
(select distinct artist from songs_instance 
where genre is not null);

select I. artist, I.song, I.genre, I.as_primary_genre, I.trackid from songs_instance I
where I.genre is null and I.as_primary_genre is not null;

update songs_instance 
set genre = 'Soul'
where trackid = 'TRLRPRK128F92DF7EB';

UPDATE songs_instance I, (select distinct artist, genre from songs_instance 
where genre is not null) J
set I.genre = J.genre
where I.artist = J.artist
and I.genre is null;


select * from songs_instance I, lyrics_kaggle J
where I.artist = J.artist
and I.genre	 is null
and J.genre is not null;


UPDATE songs_instance I, (select distinct artist, genre from lyrics_kaggle 
where genre is not null) J
set I.genre = J.genre
where I.artist = J.artist
and I.genre is null;

delete from songs_instance where duration is null;

SELECT genre, count(*)  from songs_instance
group by genre;

update songs_instance 
set genre = 'Rock and Roll'
where genre = 'Rock_And_Roll';

