SELECT count(*)
FROM musicmood.songs_per_year A
JOIN musicmood.songs_dataset B ON A.name_song = B.song
WHERE A.name_language = 'English'
AND A.date_year = B.year
--LIMIT 100;