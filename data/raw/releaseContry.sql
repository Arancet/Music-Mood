SELECT q.release,
    q.date_year,
    q.date_month,
    q.date_day,
    q.country
   FROM
   (
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
    ) q;
