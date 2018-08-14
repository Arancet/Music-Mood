SELECT track_id, tempo,
				case 
				when tempo <= 76 then '1'
                when tempo >76 and tempo < 120 then '2'
                else '3'
                end as 'speed_categoryl'
FROM musicmood.songs_new_features

#https://en.wikipedia.org/wiki/Tempo
#1=slow 2=moderate 3=fast