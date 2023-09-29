/*NOTE: I used notepad++ to format the queries. Please view with notepad++ if notepad does not show the proper format. */

/*--Query-1: Solution to SLide 1-- */

WITH sub AS (SELECT f.title AS film_title,
		    c.name category_name,
		    COUNT(r.*) rental_count
		FROM category c
		JOIN film_category fc
		ON c.category_id = fc.category_id
		JOIN film f
		ON f.film_id = fc.film_id
		JOIN inventory i
		ON f.film_id = i.film_id
		JOIN rental r
		ON i.inventory_id = r.inventory_id
	       WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
	       GROUP BY 1,2
	       ORDER BY 2)

SELECT category_name, 
       COUNT(*) number_of_movies ,
       SUM(rental_count) AS total_rental_count
    FROM sub
   GROUP BY 1;



/*--Query-2: Solution to SLide 2-- */

WITH sub AS (SELECT DATE_TRUNC('month', r.rental_date) AS rental_date,
		    store.store_id, COUNT(r.*) AS rental_count
				FROM store
				JOIN staff
				ON store.store_id = staff.store_id
				JOIN rental r
				ON staff.staff_id = r.staff_id
			   GROUP BY 1,2
			   ORDER BY 2, 1)

SELECT TO_CHAR(s1.rental_date, 'MONTH, YYYY') AS rental_date, 
		s1.rental_count rental_count_1, 
		s2.rental_count rental_count_2
	FROM sub s1
	JOIN sub s2
	ON s1.rental_date = s2.rental_date AND s1.store_id = 1 AND s2.store_id = 2;



/*--Query-3: Solution to SLide 3-- */ 

WITH payment_table AS (SELECT DATE_TRUNC('month', p.payment_date) payment_date,
								CONCAT(c.first_name, ' ', c.last_name) AS full_name,
								SUM(p.amount) AS payment_amount,
					   			COUNT(*) AS payment_count_per_month
							FROM customer c
							JOIN payment p
							ON c.customer_id = p.customer_id
						   GROUP BY 1,2
						   ORDER BY 1,2),

top_10_table AS (SELECT full_name, 
				 		SUM(payment_amount)
					FROM payment_table
				   GROUP BY 1
				   ORDER BY 2 DESC
				   LIMIT 10)

SELECT TO_CHAR(payment_date, 'MONTH, YYYY') AS payment_date,
		full_name,
		payment_amount,
		payment_count_per_month
	FROM payment_table
	WHERE full_name IN (SELECT full_name
					   	  FROM top_10_table);



/*--Query-4: Solution to SLide 4-- */

WITH sub AS (SELECT f.title,
		c.name,
		f.rental_duration,
		NTILE(4) OVER (ORDER BY f.rental_duration) standard_quartile
	FROM film f
	JOIN film_category fc
	ON f.film_id = fc.film_id
	JOIN category c
	ON c.category_id = fc.category_id
   WHERE name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music'))

SELECT name,
		standard_quartile AS rental_duration_category,
		COUNT(*) AS number_of_movies
	FROM sub
   GROUP BY 1,2
   ORDER BY 2,1;
   
   
   