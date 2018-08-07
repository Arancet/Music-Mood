#POSTGRES DB

--SELECT t.* FROM musicbrainz.release_event t LIMIT 501;

SELECT q.date_year, q.date_month,q.date_day,
a2.name as country,
r.name as song,
l.name as lang
FROM (
    SELECT release_country.release,
            release_country.date_year,
            release_country.date_month,
            release_country.date_day,
            release_country.country
    FROM release_country
    UNION ALL
    SELECT release_unknown_country.release,
            release_unknown_country.date_year,
            release_unknown_country.date_month,
            release_unknown_country.date_day,
            NULL::integer
    FROM release_unknown_country
    ) q
join country_area a on q.country = a.area
join area a2 on a.area = a2.id
join release r on q.release = r.id
join "language" l on r."language" = l.id
;
