create view musicmood.artist_number_1s as select
    `musicmood`.`billboard_ranking`.`artist`               AS `artist`,
    sum((case when (`musicmood`.`billboard_ranking`.`ranking` = 1)
      then 1
         else 0 end))                                      AS `weeks_at_number_1`,
    count(distinct `musicmood`.`billboard_ranking`.`song`) AS `number_1s`
  from `musicmood`.`billboard_ranking`
  where (`musicmood`.`billboard_ranking`.`ranking` = '1')
  group by `musicmood`.`billboard_ranking`.`artist`
  order by 3 desc
;