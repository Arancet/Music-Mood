select artist, 
		  count(artist) as 'weekly_appearances',
          sum(case when ranking=1 then 1 else 0 end) as 'number_1s'
from musicmood.billboard_ranking

group by artist
order by 2 desc