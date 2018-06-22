SELECT * FROM eso.songs_dataset;

#UPDATE eso.songs_dataset
#set lyrics = NULL, source = 0
#WHERE ID between 80 AND 100
#AND LYRICS = 'NA'


SELECT * from songs_dataset 
where id between 1000 and 1010 #and lyrics IS NOT NULL 
order by year desc

#QUERY FOR CHECKING COMPLETION
SELECT A.TIPO, COUNT(*) FROM
(
SELECT 
CASE 
	WHEN LYRICS='NA' THEN 'NOT AVAILABLE' 
	WHEN LYRICS IS NULL THEN 'PENDING'
	ELSE 'FOUND' end  as Tipo 
FROM songs_dataset
WHERE id BETWEEN 386686 AND 515580) A
GROUP BY A.TIPO

#POSSIBLE SQL EXCEPTIONS
SELECT DISTINCT ID,ARTIST, SONG
FROM songs_dataset
 WHERE 
id BETWEEN 501000 AND 510000
and LYRICS IS NULL

#POSSIBLE NAME ARTIST SONG PROBLEMS
SELECT DISTINCT ID,ARTIST, SONG
FROM songs_dataset
 WHERE 
id BETWEEN 386686 AND 515580
and LYRICS = 'NA' 


#UPDATE songs_dataset set lyrics = null where id = 496406











