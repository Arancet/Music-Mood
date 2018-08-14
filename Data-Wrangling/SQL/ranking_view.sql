SELECT 
    song,
    artist,
    COUNT(song) AS 'weeks_ranked',
    MIN(ranking) AS 'top_rank',
    MAX(ranking) AS 'lowest_rank',
    SUM(CASE
        WHEN ranking = 1 THEN 1
        ELSE 0
    END) AS 'weeks_top-spot',
    SUM(CASE
        WHEN ranking <= 10 THEN 1
        ELSE 0
    END) AS 'weeks_top-10',
    SUM(CASE
        WHEN ranking <= 20 THEN 1
        ELSE 0
    END) AS 'weeks_top-20',
    SUM(CASE
        WHEN ranking <= 30 THEN 1
        ELSE 0
    END) AS 'weeks_top-30',
    SUM(CASE
        WHEN ranking <= 40 THEN 1
        ELSE 0
    END) AS 'weeks_top-40',
    SUM(CASE
        WHEN ranking <= 50 THEN 1
        ELSE 0
    END) AS 'weeks_top-50',
    ROUND(SUM(ranking) / COUNT(song), 0) AS 'average_rank',
    MIN(CONVERT( semana , DATE)) AS 'first_appearance',
    MIN(YEAR(CONVERT( semana , DATE))) AS 'year_first_appear',
    MAX(CONVERT( semana , DATE)) AS 'last_appearance',
    MAX(YEAR(CONVERT( semana , DATE))) AS 'year_last_appear'
FROM
    musicmood.billboard_ranking
GROUP BY song , artist
ORDER BY weeks_ranked DESC
