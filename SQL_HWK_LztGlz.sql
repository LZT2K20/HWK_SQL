-- 1a. Display the first and last names of all actors from the table actor.
SELECT * FROM sakila.actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. 
-- Name the column Actor Name.
SELECT CONCAT(first_name," ",last_name) AS Actor_Name
FROM sakila.actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only
-- the first name, "Joe." What is one query would you use to obtain this information?
DROP TABLE IF EXISTS temp_actor;
CREATE TEMPORARY TABLE temp_actor SELECT * FROM sakila.actor;
ALTER TABLE temp_actor DROP last_update;
SELECT * FROM temp_actor
WHERE first_name LIKE "JOE";

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT * FROM sakila.actor
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. 
-- This time, order the rows by last name and first name, in that order:
DROP TABLE IF EXISTS temp_actorposition;
CREATE TEMPORARY TABLE temp_actorposition SELECT * FROM sakila.actor;
ALTER TABLE temp_actorposition MODIFY first_name varchar(200) AFTER last_name;
SELECT * FROM temp_actorposition
WHERE last_name LIKE '%LI%';

-- 2d. Using IN, display the country_id and country columns of the following countries:
-- Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM sakila.country
WHERE country IN ("Afghanistan","Bangladesh","China");

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries 
-- on a description, so create a column in the table actor named description and use the data type BLOB 
-- (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE sakila.actor
ADD COLUMN description BLOB;
SELECT * FROM sakila.actor;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. 
-- Delete the description column.
ALTER TABLE sakila.actor
DROP COLUMN description;
SELECT * FROM sakila.actor;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT DISTINCT
	(last_name),
	COUNT(actor_id) AS count_id
FROM sakila.actor	
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names 
-- that are shared by at least two actors
SELECT DISTINCT
	(last_name),
	COUNT(actor_id) AS count_id
FROM sakila.actor	
GROUP BY last_name
HAVING count_id > 1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS.
-- Write a query to fix the record.
SELECT actor_id, last_name, first_name
FROM sakila.actor
WHERE first_name = "GROUCHO";
UPDATE sakila.actor
SET first_name = "HARPO"
WHERE actor_id = 172;
SELECT actor_id, last_name, first_name
FROM sakila.actor
WHERE first_name = "HARPO";

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct
-- name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE sakila.actor
SET first_name = "GROUCHO"
WHERE first_name = "HARPO";
SELECT actor_id, last_name, first_name
FROM sakila.actor
WHERE first_name = "GROUCHO";

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
SHOW DATABASES;
SHOW CREATE DATABASE sakila;
SHOW TABLES FROM sakila;
SHOW CREATE TABLE sakila.address;
SHOW COLUMNS FROM sakila.address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
-- Use the tables staff and address
SELECT * FROM sakila.staff;
SELECT * FROM sakila.address;
SELECT A.first_name, A.last_name, B.address, B.district, B.postal_code
FROM sakila.staff AS A
JOIN sakila.address AS B
ON B.address_id = A.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
-- Use tables staff and payment.
SELECT * FROM sakila.payment;
SELECT A.first_name, A.last_name, sum(B.amount)
FROM sakila.staff AS A
JOIN sakila.payment AS B
ON B.staff_id = A.staff_id
GROUP BY last_name;

-- List each film and the number of actors who are listed for that film. 
-- Use tables film_actor and film. Use inner join
SELECT * FROM sakila.film;
SELECT * FROM sakila.film_actor;
SELECT A.title, count(B.actor_id)
FROM sakila.film AS A
INNER JOIN sakila.film_actor AS B
ON B.film_id = A.film_id
GROUP BY title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT * FROM sakila.film;
SELECT * FROM sakila.inventory;
SELECT A.title, count(B.inventory_id)
FROM sakila.film AS A
INNER JOIN sakila.inventory AS B
ON B.film_id = A.film_id
GROUP BY title HAVING title = "Hunchback Impossible";

-- 6e. Using the tables payment and customer and the JOIN command, 
-- list the total paid by each customer. List the customers alphabetically by last name:
SELECT A.last_name, A.first_name, sum(B.amount)
FROM sakila.customer AS A
JOIN sakila.payment AS B
ON B.customer_id = A.customer_id
GROUP BY last_name ORDER BY last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended 
-- consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT A.title, B.name
FROM sakila.film AS A
INNER JOIN sakila.language AS B
ON B.language_id = A.language_id
WHERE title LIKE "K%" or title LIKE "Q%" and name = "English"

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip
DROP TEMPORARY TABLE IF EXISTS temp_actors_films;
CREATE TEMPORARY TABLE temp_actors_films 
	SELECT B.title, C.first_name, C.last_name
    FROM sakila.film_actor as A
		INNER JOIN sakila.film as B
		ON B.film_id = A.film_id
		INNER JOIN sakila.actor as C
		ON C.actor_id = A.actor_id
;
SELECT * FROM temp_actors_films
WHERE title = "Alone Trip";

-- You want to run an email marketing campaign in Canada, for which you will need the names
-- and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT A.first_name, A.last_name, A.email, B.city_id, C.country_id, D.country
FROM sakila.customer as A
	JOIN sakila.address as B
		ON B.address_id = A.address_id
	JOIN sakila.city as C
		ON C.city_id = B.city_id
	JOIN sakila.country as D
		ON D.country_id = C.country_id
WHERE country = "Canada";

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion
-- Identify all movies categorized as family films.
SELECT A.title, B.category_id, C.name
FROM sakila.film as A
	JOIN film_category as B
		ON B.film_id = A.film_id
	JOIN sakila.category as C
		ON C.category_id = B.category_id
WHERE name = "Family";

-- Display the most frequently rented movies in descending order
DROP TEMPORARY TABLE IF EXISTS temp_rent_table;
CREATE TEMPORARY TABLE temp_rent_table 
	SELECT count(A.rental_id), B.film_id, C.title
    FROM sakila.rental as A
		INNER JOIN sakila.inventory as B
			ON B.inventory_id = A.inventory_id
		INNER JOIN sakila.film as C
			ON C.film_id = B.film_id
	GROUP BY title ORDER BY count(A.rental_id) DESC;
SELECT * FROM temp_rent_table;