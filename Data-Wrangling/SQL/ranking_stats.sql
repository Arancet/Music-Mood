#add as view

select 
		  song, 
          artist, 
          count(song) as "weeks_ranked",
          min(ranking) as "top_rank",
          max(ranking) as "lowest_rank",
          sum(case when ranking = 1 then 1 else 0 end) as "weeks_top-spot",
          sum(case when ranking <= 10 then 1 else 0 end) as "weeks_top-10",
          sum(case when ranking <= 20 then 1 else 0 end) as "weeks_top-20",
          sum(case when ranking <= 30 then 1 else 0 end) as "weeks_top-30",
          sum(case when ranking <= 40 then 1 else 0 end) as "weeks_top-40",
          sum(case when ranking <= 50 then 1 else 0 end) as "weeks_top-50",
          round(sum(ranking)/count(song), 0) as "average_rank",
          MIN(CONVERT(semana, date)) as "first_appearance",
		  MIN(YEAR(CONVERT(semana, date))) as "year_first_appear",
          MAX(CONVERT(semana, date)) as "last_appearance",
          MAX(YEAR(CONVERT(semana, date))) as "year_last_appear",
           (FLOOR(MIN(YEAR(CONVERT(semana, date))) /10) * 10) as 'decade'

          
          
          
from musicmood.billboard_ranking

group by  song, artist

Order by weeks_ranked desc



