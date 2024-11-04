CREATE TABLE IF NOT EXISTS top5_genres_per_year AS (
	WITH GenreInflatedValues AS (
	    SELECT
	        year,
	        genre,
	        AVG(inflated_values) AS total_inflated_values
	    FROM
			(SELECT itd.tconst, itd."year", g.genre, bodi.inflated_values, bodi.country
			FROM "IMDB_tickets_data" itd
			INNER JOIN genres g 
			ON itd.tconst = g.tconst
			INNER JOIN box_office_data_inflated bodi 
			ON itd.tconst = bodi.tconst
			WHERE g.genre IS NOT NULL AND bodi.country = 'World') AS movies
	    GROUP BY
	        year,
	        genre
	),
	RankedMovies AS (
	    SELECT
	        year,
	        genre,
	        total_inflated_values,
	        ROW_NUMBER() OVER (PARTITION BY year ORDER BY total_inflated_values DESC) AS rank
	    FROM
	        GenreInflatedValues
	)
	SELECT
	    year,
	    genre,
	    total_inflated_values,
	    "rank"
	FROM
	    RankedMovies
	ORDER BY
	    year,
	    rank
)
