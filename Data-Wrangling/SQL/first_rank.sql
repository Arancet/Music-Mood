select artist, song, ranking, min(convert(semana, date)) as min_date
    from musicmood.billboard_ranking
    group by artist, song