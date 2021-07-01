/*Query question 1: We want to understand more about the movies that families are watching */

SELECT 	DISTINCT(f.title) AS film_tile, c.name AS category_name, 
		COUNT(r.rental_id) OVER(PARTITION BY f.film_id ORDER BY c.name) AS rental_count
	FROM film AS f
	JOIN film_category AS fc
	ON f.film_id = fc.film_id
	JOIN category AS c
	ON fc.category_id=c.category_id
	JOIN inventory AS i
	ON i.film_id=f.film_id
	JOIN rental AS r
	ON i.inventory_id=r.inventory_id
	WHERE c.name='Animation' OR c.name='Children' OR c.name='Classics' OR c.name='Comedy' OR c.name='Family' OR c.name='Music'

ORDER BY 2,1


/*Query question 2: How rental of family-friendly movies compares to the duration that all movies are rented for? */

SELECT 	t1.is_family, COUNT(t1.is_family) AS qty_movies, AVG(t1.rental_duration) AS average_rentalduration, 
		SUM(t1.rental_count) AS Total_rental, SUM(t1.rental_count)/COUNT(t1.is_family) AS avg_rentalpermovie
	FROM (	SELECT DISTINCT(f.title) AS title, c.name AS name, 
			f.rental_duration AS rental_duration, 
			COUNT(r.rental_id) OVER(PARTITION BY f.title) AS rental_count,
			CASE WHEN c.name='Animation' OR c.name='Children' OR c.name='Classics' OR c.name='Comedy' OR c.name='Family'
			OR c.name='Music' THEN 'family_movie' ELSE 'non_family' END AS is_family

			FROM film AS f
			JOIN film_category AS fc
			ON f.film_id = fc.film_id
			JOIN inventory AS i
			ON i.film_id=f.film_id
			JOIN rental AS r
			ON i.inventory_id=r.inventory_id
			JOIN category AS c
			ON fc.category_id=c.category_id
			ORDER BY 4) t1

GROUP BY 1



/*Query question 3: How the two stores compare in their count of rental orders during every month for all the years we have data? */

SELECT DATE_PART('month',rental_date) AS month,DATE_PART('year',rental_date)AS year, store_id, COUNT(r.rental_id)
FROM rental r
JOIN inventory i
ON r.inventory_id=i.inventory_id
GROUP BY 1,2,3
ORDER BY 4 DESC


/*Query question 4: Who were our top 10 paying customers, how many payments they made on a monthly basis during 2007, and what was the amount of the monthly payments? */

SELECT t1.pay_month,t1.fullname,t1.pay_countpermon,t1.amount
		FROM(
				  SELECT DATE_TRUNC('month',p.payment_date) AS pay_month, c.customer_id AS c_id,CONCAT(c.first_name,' ',c.last_name) AS fullname,
				  COUNT(p.payment_id) AS pay_countpermon, SUM(p.amount) AS amount
				  FROM payment p
				  JOIN rental r
				  ON p.rental_id=r.rental_id
				  JOIN customer c
				  ON r.customer_id=c.customer_id
				  GROUP BY 2,1
				  ORDER BY 2,1)t1

		INNER JOIN
		(
		SELECT c.customer_id AS c_id, CONCAT(c.first_name,' ',c.last_name) AS fullname2, SUM(p.amount) AS amount2
		FROM payment p
		JOIN rental r
		ON p.rental_id=r.rental_id
		JOIN customer c
		ON r.customer_id=c.customer_id
		GROUP BY 1
		ORDER BY 3 DESC
		LIMIT 10
		)t2

ON t1.c_id=t2.c_id
ORDER BY 2,1