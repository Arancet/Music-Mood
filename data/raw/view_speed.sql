create view musicmood.speed as select
    `musicmood`.`songs_new_features`.`track_id` AS `track_id`,
    `musicmood`.`songs_new_features`.`tempo`    AS `tempo`,
    (case when (`musicmood`.`songs_new_features`.`tempo` <= 76)
      then '1'
     when ((`musicmood`.`songs_new_features`.`tempo` > 76) and (`musicmood`.`songs_new_features`.`tempo` < 120))
       then '2'
     else '3' end)                              AS `speed_general`
  from `musicmood`.`songs_new_features`
;

