select rf.song,
		  rf.artist,
          rf.weeks_ranked,
          rf.highest_rank,
          rf.lowest_rank,
		  fr.ranking as 'first_rank',
          rf.weeks_top_spot,
          rf.weeks_top_10,
		  rf.weeks_top_20,
          rf.weeks_top_30,
          rf.weeks_top_40,
          rf.weeks_top_50,
          rf.average_rank,
          rf.first_appearance,
          rf.year_first_appear,
          rf.last_appearance,
          rf.year_last_appear,
          rf.decade,
          ca.artist,
          ca.chart_appearances as 'chart_appearances_by_artist',
          ca.number_1s as 'artist_weeks_in_top_spot'


from musicmood.ranking_features rf
join chart_appearances ca on (rf.artist=ca.artist)
join first_rank fr on (rf.artist=fr.artist and rf.song=fr.song)