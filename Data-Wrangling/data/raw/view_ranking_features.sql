create view musicmood.ranking_features as select
    `musicmood`.`billboard_ranking`.`song`                                                                     AS `song`,
    `musicmood`.`billboard_ranking`.`artist`                                                                   AS `artist`,
    count(
        `musicmood`.`billboard_ranking`.`song`)                                                                AS `weeks_ranked`,
    min(
        `musicmood`.`billboard_ranking`.`ranking`)                                                             AS `highest_rank`,
    max(
        `musicmood`.`billboard_ranking`.`ranking`)                                                             AS `lowest_rank`,
    sum((case when (`musicmood`.`billboard_ranking`.`ranking` = 1)
      then 1
         else 0 end))                                                                                          AS `weeks_top_spot`,
    sum((case when (`musicmood`.`billboard_ranking`.`ranking` <= 10)
      then 1
         else 0 end))                                                                                          AS `weeks_top_10`,
    sum((case when (`musicmood`.`billboard_ranking`.`ranking` <= 20)
      then 1
         else 0 end))                                                                                          AS `weeks_top_20`,
    sum((case when (`musicmood`.`billboard_ranking`.`ranking` <= 30)
      then 1
         else 0 end))                                                                                          AS `weeks_top_30`,
    sum((case when (`musicmood`.`billboard_ranking`.`ranking` <= 40)
      then 1
         else 0 end))                                                                                          AS `weeks_top_40`,
    sum((case when (`musicmood`.`billboard_ranking`.`ranking` <= 50)
      then 1
         else 0 end))                                                                                          AS `weeks_top_50`,
    round((sum(`musicmood`.`billboard_ranking`.`ranking`) / count(`musicmood`.`billboard_ranking`.`song`)),
          0)                                                                                                   AS `average_rank`,
    min(cast(`musicmood`.`billboard_ranking`.`semana` as
             date))                                                                                            AS `first_appearance`,
    min(year(cast(`musicmood`.`billboard_ranking`.`semana` as
                  date)))                                                                                      AS `year_first_appear`,
    max(cast(`musicmood`.`billboard_ranking`.`semana` as
             date))                                                                                            AS `last_appearance`,
    max(year(cast(`musicmood`.`billboard_ranking`.`semana` as
                  date)))                                                                                      AS `year_last_appear`,
    (floor((min(year(cast(`musicmood`.`billboard_ranking`.`semana` as date))) / 10)) *
     10)                                                                                                       AS `decade`
  from `musicmood`.`billboard_ranking`
  group by `musicmood`.`billboard_ranking`.`song`, `musicmood`.`billboard_ranking`.`artist`
  order by `weeks_ranked` desc
;

