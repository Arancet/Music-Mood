create view musicmood.first_rank as select
    `musicmood`.`billboard_ranking`.`artist`                    AS `artist`,
    `musicmood`.`billboard_ranking`.`song`                      AS `song`,
    `musicmood`.`billboard_ranking`.`ranking`                   AS `ranking`,
    min(cast(`musicmood`.`billboard_ranking`.`semana` as date)) AS `min_date`
  from `musicmood`.`billboard_ranking`
  group by `musicmood`.`billboard_ranking`.`artist`, `musicmood`.`billboard_ranking`.`song`
;

