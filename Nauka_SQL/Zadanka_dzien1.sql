use sakila3_87

select * from rental
order by rental_date desc;

-- wypożyczenia w 2005
select * from sakila3_87.rental
where rental_date like '2005%'
order by rental_date desc;


-- wypożycznie 24 maja 2005
select * from sakila3_87.rental
where rental_date like '2005-05-24%' order by rental_date desc;

-- wypożyczenia po 2005-06-30
select *
from rental
where rental_date > '2005-06-31' order by rental_date;

-- odnalezienie Jona
select staff_id from staff
where first_name = 'Jon';

-- sprawdzenie wydajnośici Jona
select * from rental
where rental_date between '2005-06-30' and '2005-09-01'
and staff_id = 2
order by rental_date desc;


-- aktywni lub andre
select * from customer
where active = 1
xor first_name like 'ANDRE%';

-- nie ma nieaktywego andre
select * from customer
where active = 1
and first_name like 'ANDRE%';

-- id == 1 nieaktywnych
select * from customer
where active = 0
and store_id = 1;

-- email sakila
select * from customer
where email not like '%sakilacustomer.org';


select distinct create_date from customer;


-- aktorzy
-- grali powyżej 25 filmach

select * from actor_analytics
where films_amount > 25 order by films_amount;

-- grali w 20 filmach i są nieźli
select * from actor_analytics
where films_amount > 20
and avg_film_rate > 3.3;

-- wyświetlą aktorów, którzy grali w ponad 20 filmach i ich średni rating przekracza 3.3 lub wpływy z wypożyczeń (actor_payload) przekroczyły 2000.

select * from actor_analytics
where films_amount > 20
and avg_film_rate > 3.3 or actor_payload > 2000 order by films_amount; -- może nie zagrał dobrze ale zarobił



select * from actor_analytics



-- ALIASOWANIE



SELECT
    rental_id, inventory_id, customer_id,
    rental_date AS date_of_rental,
    return_date as date_of_rental_return
from rental;

-- zmiana na polski
select
    rental.rental_id as 'id wypożyczenia',
    rental.inventory_id as 'id przedmiotu',
    rental.rental_date 'data wypożyczenia',
    rental.return_date as 'data zwrotu'
from rental;


-- DATY
-- rok/miesiąc/dzień'
select payment.payment_date,
    date_format(payment_date, '%Y/%m/%d') as 'rok/miesiąc/dzień',
    date_format(payment_date, '%Y-%M-%d_%w') as 'rok-nazwa_miesiąca-dzień_tygodnia',
    date_format(payment_date, '%Y_%u') as 'rok-numer_tygodnia',
    date_format(payment_date, '%Y/%m/%d@%W') as 'rok/miesiąc/dzień@nazwa_dnia_tygodnia',
    date_format(payment_date, '%Y/%m/%d@%w') as 'rok/miesiąc/dzień@numer_dnia_tygodnia'
from payment



-- Predefiniowanie

select payment_date,
    date_format(payment_date, GET_FORMAT(DATE,'USA')) as 'payment_date_usa_formatted'
from payment;



-- least

select * from film_list;

SELECT price, length, LEAST(length, price) FROM film_list;
SELECT price, length, rating,LEAST(length, price), LEAST(length, price, rating) FROM film_list;


SELECT price, length, greatest(length, price) FROM film_list;
SELECT price, length, rating,greatest(length, price), greatest(length, price, rating) FROM film_list





-- Tabelki

select first_name from customer
union
select first_name from actor
union
select first_name from staff;



SELECT category FROM nicer_but_slower_film_list
union
SELECT category FROM nicer_but_slower_film_list;


-- Sprzedaż sklepu

select * from sales_by_store

select store
from sales_by_store
where total_sales > (select total_sales / 2
                     from sales_total);


select * from  rating_analytics;

select rating from rating_analytics
where avg_rental_rate >
      (select sum(avg_rental_rate)/6 from rating_analytics);

--        (select count(avg_rental_rate) from rating_analytics as a);

select rating from rating_analytics
where avg_rental_duration >
      (select sum(avg_rental_duration)/6 from rating_analytics);


select * from  rating;

select rating, avg_rental_duration, avg_rental_rate, rentals, avg_film_length from rating_analytics
where rating in
(select rating from rating
          where id_rating = 3
          or id_rating = 2
          or id_rating = 5);


select rating, avg_rental_duration, avg_rental_rate, rentals, avg_film_length from rating_analytics
where rating in
(select rating from rating
          where id_rating = 3);

/*
6. Napisz kwerendę, która powie, który rating cieszy się największą popularnością,
7. Napisz kwerendę, która odpowie, z którego ratingu filmy są średnio najkrótsze.
*/


select * FROM actor_analytics

select * from actor_analytics
where actor_id in(
select actor_id from actor
where first_name = 'Zero'
and last_name = 'CAGE');


select * from actor
where actor_id in(
select actor_id from actor_analytics
where films_amount >= 30);


select * from film
where length in (184,174,176,164)
    and film_id in(
select film_id from film_actor
where actor_id in(
select actor_id from actor_analytics
where longest_movie_duration in (184,174,176,164)));


select * from film_actor;

select * from film
where length in (184,174,176,164);



-- FILMY

/*
Używając sakila.film_list:

Napisz kwerendę, która wyświetli filmy z kategorii Horror, Documentary, Family o ratingu R lub NC-17.
Używając wyników poprzedniego zadania oraz sakila.film_text, wyświetl opisy tych filmów.
Dodatkowo:
3. Posortuj sakila.film_list według klucza Category - rosnąco, Price - malejąco.
4. Posortuj sakila.film_list według klucza Rating - rosnąco, Length - malejąco.*/

select * from film_list
where category in ('Horror', 'Documentary', 'Family')
and rating  = 'R'
or rating = 'NC-17';

SELECT * FROM film_text;

select * from film_text
where film_id in(
select FID from film_list
where category in ('Horror', 'Documentary', 'Family')
and rating in ('R','NC-17'));



select * from film_list order by category, price desc;

select * from film_list order by rating, length desc;

