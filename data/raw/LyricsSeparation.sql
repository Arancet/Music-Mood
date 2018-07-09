CREATE TABLE `song_lyrics_found` (
  `trackid` varchar(50) DEFAULT NULL,
  `song` varchar(300) DEFAULT NULL,
  `artist` varchar(300) DEFAULT NULL,
  `year` int(11) DEFAULT NULL,
  `lyrics` text,
  `source` int(11) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;


CREATE TABLE `song_lyrics_pending` (
  `trackid` varchar(50) DEFAULT NULL,
  `song` varchar(300) DEFAULT NULL,
  `artist` varchar(300) DEFAULT NULL,
  `year` int(11) DEFAULT NULL,
  `lyrics` text,
  `source` int(11) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;


INSERT INTO song_lyrics_found
SELECT trackid, song, artist, year, lyrics, source, id 
FROM songs_dataset
WHERE lyrics IS NOT NULL AND lyrics != 'NA' 

INSERT INTO song_lyrics_pending
SELECT trackid, song, artist, year, lyrics, source, id 
FROM songs_dataset
WHERE lyrics IS  NULL OR lyrics = 'NA' 

