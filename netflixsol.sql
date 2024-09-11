-- Netflix Project

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
	show_id varchar(6),
	type varchar(10),
	title varchar(150),
	director varchar(208),
	casts varchar(1000),
	country varchar(150),
	date_added varchar(50),
	release_year int,
	rating varchar(10),
	duration varchar(15),
	listed_in varchar(100),
	description varchar(250)
)

SELECT * from netflix ;

-- Netflix business problems
-- 1. Count the number of Movies vs TV Shows

	SELECT 
		type,
		COUNT(*)
	FROM netflix
	GROUP BY 1

-- 2. Find the most common/max count rating for movies and TV shows

	SELECT 
		type,
		rating
		FROM
		(
			SELECT
				type,
				rating,
				COUNT(*),
				   RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
			FROM netflix
			GROUP BY 1,2
				) as t1
		WHERE
		ranking = 1
		
	
-- 3. List all movies released in a specific year (e.g., 2020)

	SELECT * from netflix;
	SELECT * from netflix
	where 
		type = 'Movie' AND
		release_year = 2020;
	
-- 4. Find the top 5 countries with the most content on Netflix
	SELECT
		UNNEST(STRING_TO_ARRAY(country, ',')) as new_country,
		COUNT(show_id) as total_content
	FROM netflix
	GROUP BY 1
	ORDER BY 2 DESC
	LIMIT 5
	
-- 5. Identify the longest movie

	SELECT * FROM netflix
		WHERE type = 'Movie'
		AND duration IS NOT NULL
		ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC LIMIT 1
		
-- 6. Find content added in the last 5 years
	
	SELECT * FROM netflix
		WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'
	
	
-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

	SELECT * FROM netflix
	WHERE director ILIKE '%Rajiv Chilaka%';
	
-- 8. List all TV shows with more than 5 seasons
	SELECT * FROM netflix
	WHERE type = 'TV Show' AND 
	SPLIT_PART(duration, ' ', 1)::INT > 5 ;
	
-- 9. Count the number of content items in each genre

	SELECT
		UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
		COUNT(show_id) as total_content
	FROM netflix
	GROUP BY 1
	ORDER BY 2 DESC
	
-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!
	SELECT
		EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as year,
		COUNT(*) as yearly_content,
		ROUND(
		COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100
		,2) as avg_content_per_year
	FROM netflix
	WHERE country = 'India'
	GROUP BY 1
	ORDER BY avg_content_per_year DESC LIMIT 5;
	
-- 11. List all movies that are documentaries
	SELECT
	* FROM netflix
	WHERE listed_in ILIKE '%Documentaries%';
	
-- 12. Find all content without a director
	SELECT
	* FROM netflix
	WHERE director IS NULL;
	
-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

	SELECT
	* FROM netflix
	WHERE type = 'Movie' AND
	casts ILIKE '%salman Khan%'
	AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

	
-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

	SELECT
		UNNEST(STRING_TO_ARRAY(casts, ',')) as actors,
		COUNT(show_id) as total_content
	FROM netflix
	WHERE country ILIKE '%India%'
	GROUP BY 1
	ORDER BY 2 DESC LIMIT 10;
	
	/*15.
	Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
	the description field. Label content containing these keywords as 'Bad' and all other 
	content as 'Good'. Count how many items fall into each category.*/


	WITH new_table
	AS
	(SELECT 
	*,
		CASE
		WHEN 
			description ILIKE '%kill%' OR
			description ILIKE '%violence%' THEN 'BAD CONTENT'
			ELSE 'GOOD CONTENT'
		END AS CATEGORY
	FROM netflix
	)		
	SELECT 
		category,
		COUNT(*) as total_content
	FROM new_table
	GROUP BY 1


