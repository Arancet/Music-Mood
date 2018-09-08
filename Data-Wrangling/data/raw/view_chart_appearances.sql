create view musicmood.chart_appearances as select
    `musicmood`.`billboard_ranking`.`artist`        AS `artist`,
    count(`musicmood`.`billboard_ranking`.`artist`) AS `chart_appearances`,
    sum((case when (`musicmood`.`billboard_ranking`.`ranking` = 1)
      then 1
         else 0 end))                               AS `artist_weeks_at_number_1`
  from `musicmood`.`billboard_ranking`
  group by `musicmood`.`billboard_ranking`.`artist`
  order by 2 desc
;

