use sakila3_87;

-- Wypłaty i wypożyczenia

select payment_id, pay.rental_id, amount, rental_date, payment_date
from payment as pay
join rental as ren
on pay.rental_id = ren.rental_id;

-- Wypożyczenia i stany magazynowe

select inv.inventory_id, rental_id, film_id
from rental as ren
join inventory as inv
on ren.inventory_id = inv.inventory_id;


-- wypożyczania filmu

select inventory_id, f.film_id, title, description, release_year
from film as f
join inventory as i
    on f.film_id = i.film_id;

-- Raport wypożyczeń
/*
id wypożyczenia, - DONE
id filmu, - DONE
tytuł filmu, - DONE
opis filmu, - DONE
rating filmu, - DONE
ocenę wypożyczenia,
datę wypożyczenia, - DONE
datę płatności,
kwotę płatności.*/

select * from rental;


select
    f.film_id AS "ID Filmu",
    f.title AS "Tytuł Filmu",
    f.rating AS "Rating Filmu",
    f.description AS "Opis Filmu",
    r.rental_id AS "ID Wypożyczenia",
    rental_rate AS "Ocena Wypożyczenia",
    r.rental_date AS "Data Wypożyczenia",
    p.payment_date AS "Data Płatności",
    p.amount AS "Kwota"
from film as f
join inventory as i
using (film_id)
join rental as r
using(inventory_id)
join payment as p
using (rental_id);




-- Używając tabel tasks.payment oraz sakila.rental znajdź te wypożyczenia, które nie zostały opłacone (nie posiadają płatności).
 -- Jakiego typu JOIN należy tutaj użyć? Czy umiesz znaleźć więcej niż jedno rozwiązanie tego zadania?


select *
from tasks3_87.payment as p
right join rental as r
using (rental_id)
where p.rental_id is null;

-- -------------------------------------------------------------

-- UPDATE --

select * from tasks3_87.city_country;

select * from country;

update tasks3_87.city_country as cc
join sakila3_87.country AS c
    on cc.country_id = c.country_id
set cc.country = c.country
where cc.country_id = c.country_id;

select * from tasks3_87.city_country;





-- DELETE --

insert into tasks3_87.films_to_be_cleaned
select * from film;

SELECT * FROM tasks3_87.films_to_be_cleaned;
-- jest 1000 filmów

select * from film_category;

SELECT * FROM tasks3_87.films_to_be_cleaned as fc
join film_category as c
on fc.film_id = c.film_id
where category_id in (1,5,7,9)
and length < 60
and rating not in ('NC-17','PG');

-- po zapytaniu select wychodzi mi 16 wierszy


delete fc
from tasks3_87.films_to_be_cleaned as fc
join film_category as c
on fc.film_id = c.film_id
where category_id in (1,5,7,9)
or length < 60
or rating in ('NC-17','PG');

select * from tasks3_87.films_to_be_cleaned order by length;

-- i teraz jest 984 wierszy



-- INSERT
SELECT * FROM tasks3_87.california_payments;
-- szukanie danych
SELECT * FROM payment;
select * from customer;
SELECT * FROM address;

-- sprawdzenie JOINÓW czy wszystko jest.
SELECT * FROM payment AS p
JOIN customer as c
on p.customer_id = c.customer_id
join address AS a
on c.address_id = a.address_id
WHERE a.district not in ('California');


insert into tasks3_87.california_payments
SELECT
    p.payment_id,
    p.customer_id,
    p.staff_id,
    p.rental_id,
    p.amount,
    p.payment_date,
    p.last_update
FROM payment AS p
JOIN customer as c
on p.customer_id = c.customer_id
join address AS a
on c.address_id = a.address_id
WHERE a.district = 'California';



select * from tasks3_87.california_payments;


-- DELETE CASCADE


SELECT
    UNIQUE_CONSTRAINT_SCHEMA,
    TABLE_NAME,
    REFERENCED_TABLE_NAME
FROM
    information_schema.
WHERE delete_rule = 'CASCADE';

use tasks3_87;

select * from school;
select * from class;
-- 20 class
select * from child;
-- 119 dzieci

delete from school where  school_name = 'School 3';


SELECT
    UNIQUE_CONSTRAINT_SCHEMA,
    TABLE_NAME,
    REFERENCED_TABLE_NAME
FROM
    information_schema.REFERENTIAL_CONSTRAINTS
WHERE delete_rule = 'CASCADE'
and UNIQUE_CONSTRAINT_SCHEMA = 'tasks3_87';

