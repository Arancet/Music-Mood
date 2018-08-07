/*
Update table: musicmood.songs_instance
Field: speed_general
Source: musicmood.speed (view)
*/

SELECT count(*)
FROM musicmood.speed S
JOIN musicmood.songs_instance I ON S.track_id = trackid
limit 100;
-- 12464

SELECT *
FROM musicmood.songs_instance
-- WHERE speed_general is null;
;
-- 12464
--

-- UPDATE musicmood.songs_instance, musicmood.speed
-- SET musicmood.songs_instance.speed_general = musicmood.speed.speed_general
-- WHERE musicmood.songs_instance.trackid = musicmood.speed.track_id

-- select (FLOOR(MIN(1981) / 10) * 10)

-- select count(*)
-- from musicmood.songs_instance
-- where year_first_appear  <> 0

-- SELECT SI.trackid, RF.first_appearance
-- FROM musicmood.ranking_features RF
-- JOIN musicmood.songs_instance SI ON RF.song = SI.song AND SI.artist = RF.artist
-- WHERE SI.origin_source is not null


-- select *
-- from musicmood.songs_instance
-- WHERE first_appearance = 0
-- AND origin_source IS NOT NULL;

-- UPDATE musicmood.songs_instance, musicmood.ranking_features
-- SET musicmood.songs_instance.year_added = YEAR(musicmood.ranking_features.first_appearance)
-- WHERE musicmood.ranking_features.song = musicmood.songs_instance.song
-- AND musicmood.songs_instance.artist = musicmood.ranking_features.artist

SELECT *
FROM musicmood.ranking_features
where song like '%Novgorod%'

-- UPDATE musicmood.songs_instance
-- SET origin_source = 'ORIGINAL'
-- WHERE origin_source is NULL

SELECT COUNT(*)
FROM musicmood.songs_instance
WHERE origin_source IS NULL;

SELECT COUNT(*)
FROM musicmood.songs_instance A
JOIN musicmood.songs_dataset B ON A.trackid = B.trackid

-- UPDATE musicmood.songs_instance, musicmood.songs_dataset
-- SET musicmood.songs_instance.year_added = musicmood.songs_dataset.year
-- WHERE musicmood.songs_instance.trackid = musicmood.songs_dataset.trackid
-- AND musicmood.songs_instance.origin_source = 'ADDED'

-- UPDATE musicmood.songs_instance, musicmood.songs_dataset
-- SET musicmood.songs_instance.year_added = musicmood.songs_dataset.year
-- WHERE musicmood.songs_instance.trackid = musicmood.songs_dataset.trackid
-- AND musicmood.songs_instance.origin_source = 'ADDED'

-- UPDATE musicmood.songs_instance
-- SET musicmood.songs_instance.decade = (FLOOR(musicmood.songs_instance.year_added / 10) * 10)
-- WHERE musicmood.songs_instance.origin_source = 'ADDED'

-- SELECT COUNT(*)
-- FROM musicmood.songs_instance
-- where year_first_appear =0
-- and origin_source = 'ADDED'

-- UPDATE musicmood.songs_instance A,
-- (
--   SELECT artist a_artist, AVG(artist_hotttnesss) avg_hotttnesss
--   FROM musicmood.songs_instance
--   where artist_hotttnesss is not null
--   AND artist IN
--   (
--     SELECT distinct artist
--     FROM musicmood.songs_instance
--     where artist_hotttnesss is null
--   )
--   GROUP BY artist
-- ) B
-- SET A.artist_hotttnesss = B.avg_hotttnesss
-- WHERE A.artist = B.a_artist
-- AND A.artist_hotttnesss is null
--and A.artist = 'Anggun'

-- SELECT count(*)
-- FROM musicmood.songs_instance
-- where artist_hotttnesss is null

-- UPDATE musicmood.songs_instance A,
-- (
--   SELECT artist a_artist, AVG(artist_familiarity) avg_familiarity
--   FROM musicmood.songs_instance
--   where artist_familiarity is not null
--   AND artist IN
--   (
--     SELECT distinct artist
--     FROM musicmood.songs_instance
--     where artist_familiarity is null
--   )
--   GROUP BY artist
-- ) B
-- SET A.artist_familiarity = B.avg_familiarity
-- WHERE A.artist = B.a_artist
-- AND A.artist_familiarity is null

-- SELECT *
-- FROM songs_instance
-- WHERE number_1s IS NOT NULL
-- LIMIT 100;

SELECT count(*)
FROM songs_instance
where number_1s IS NOT NULL
and origin_source = 'ORIGINAL';

-- UPDATE songs_instance
-- SET weeks_at_number_1 = 0
-- where weeks_at_number_1 IS NULL