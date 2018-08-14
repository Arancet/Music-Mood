select artist, 
		  #count(artist) as 'weekly_appearances',
          sum(case when ranking=1 then 1 else 0 end) as 'weeks_at_number_1',
          count(distinct(song)) as 'number_1s'
from musicmood.billboard_ranking
where ranking='1'

group by artist
order by 3 desc