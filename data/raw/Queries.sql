#select count(*) from songs_dataset
#where lyrics like "We do not have%";

 
#UPDATE songs_dataset
#set lyrics = 'div_metro' 
#where lyrics = '<div style=height:250px; background-color: transparent;></div>';

select count(*) from songs_dataset where lyrics = 'div_metro';

select count(*) from songs_dataset  where lyrics = '<div style=height:250px; background-color: transparent;></div>';

select * from songs_dataset where Artist = 'Charlie Parker' and song = 'Lover Man'   order by 2 ;


select count(*) from songs_dataset where lyrics = 'codec';


ALTER DATABASE musicmood CHARACTER SET utf8 COLLATE utf8_general_ci;
ALTER DATABASE songs_dataset CHARACTER SET utf8 COLLATE utf8_general_ci;


