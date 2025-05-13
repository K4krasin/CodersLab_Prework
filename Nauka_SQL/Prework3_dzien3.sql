use sakila3_87;

SELECT
    a.first_name as actor_name,
    a.last_name as actor_last_name,
    f.title as film_title,
    f.description as film_description
FROM
        actor as a
    INNER JOIN
        film_actor fa on a.actor_id = fa.actor_id
    INNER JOIN
        film f on fa.film_id = f.film_id;


CREATE VIEW actor_film AS
SELECT
    a.first_name as actor_name,
    a.last_name as actor_last_name,
    f.title as film_title,
    f.description as film_description
FROM
       actor as a
    INNER JOIN
        film_actor fa on a.actor_id = fa.actor_id
    INNER JOIN
        film f on fa.film_id = f.film_id;


SELECT * FROM actor_film;

SET @imie = 'XYZ';  -- definiowanie nowej zmiennej
SET @nazwisko = 'TMMNB';

SELECT @imie; -- zwrócenie zawartości pojedyńczej zmiennej
SELECT @imie, @nazwisko; -- możemy zwrócić też wiele zmiennych

SET @count = (SELECT COUNT(*) FROM payment); -- liczba wierszy w tabeli payment
SELECT @count;


DELIMITER $$

CREATE PROCEDURE set_counter(
    INOUT counter INT,  -- zmienna counter zostanie wyświetlona po modyfikacji; typ zmiennej INT
    IN inc INT -- parametr wejściowy
)
BEGIN
    -- kod SQL
    SET counter = counter + inc;
END$$

DELIMITER ;



SET @counter = 1;
CALL set_counter(@counter, 1); -- 2, nowa wartość zmiennej @counter
CALL set_counter(@counter, 1); -- 3, nowa wartość zmiennej @counter
CALL set_counter(@counter, 5); -- 8, nowa wartość zmiennej @counter
SELECT @counter; -- 8


select actor_id, count(distinct film_id) AS pli
from film_actor
group by actor_id
order by pli;


select
    a.first_name as 'Actor Name',
    a.last_name as 'Actor Last name',
    actor_id, count(distinct film_id) AS pli
from film_actor as fa
join actor as a using (actor_id)
group by actor_id
order by pli desc;



-- -------------------------------

SELECT
    rating,
    release_year,
    sum(payments) as payments
    FROM film_analytics
    GROUP BY rating, release_year
UNION ALL
    SELECT
    RATING,
    NULL,
    sum(payments) as payments
    FROM film_analytics
    GROUP by rating
UNION ALL
    SELECT
    NULL,
    NULL,
    sum(payments)
    FROM film_analytics;




SELECT
    rating,
    release_year,
    sum(payments) as payments,
    count(payments) as count_pay
    FROM film_analytics
    GROUP BY rating, release_year
with rollup;





SELECT
    customer_id,
    amount,
    SUM(amount) OVER (PARTITION BY customer_id) as total_amount
    FROM payment;



sELECT
    customer_id,
    AVG(amount) OVER (customer_window) as payment_amount,
    MIN(amount) OVER (customer_window) as min_payment,
    MAX(amount) OVER (customer_window) as max_payment
FROM payment
WINDOW customer_window As (PARTITION BY customer_id);





