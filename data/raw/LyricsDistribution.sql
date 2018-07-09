select  source , count(*) from songs_dataset 
where lyrics is not null and lyrics != 'NA' 
group by source
