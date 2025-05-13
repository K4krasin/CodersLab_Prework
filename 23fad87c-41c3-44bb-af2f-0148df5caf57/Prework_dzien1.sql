use sakila3_87;

select inventory_id , film_id from inventory;

select * from actor where first_name = 'penelope';

SELECT * FROM   actor ORDER BY first_name, last_name;

select distinct actor.first_name FROM actor LIMIT 5


SELECT customer.first_name FROM customer WHERE active = 1 order by first_name desc;

select * from sakila3_87.film where length > 60 and rating = 'NC-17'


select * from film where length > 60 or rating = 'NC-17'

select * from film where length > 60 XOR rating = 'NC-17'

SELECT *
FROM film
WHERE NOT rating = 'NC-17';

SELECT amount FROM payment
ORDER BY amount DESC;


SELECT DISTINCT category.category_id from category;

select * from payment where amount > 10 and rental_id < 500;


select * from examples3_87.students;
use examples3_87;

insert into students VALUES (10,'jacek','Kowalski','jacek@mail.com',1)

INSERT INTO students (name, email) VALUES ('Wojtek', 'wojtek@gmail.com');

INSERT INTO students VALUES
   (11, 'Marian', 'Kowalski', 'mariank@gmail.com', 1),
   (12, 'Jarosław', 'Nowak', 'jn@gmail.com', 2);

INSERT INTO examples3_87.students(name, surname, email)
SELECT
    first_name,
    last_name,
   email
FROM sakila3_87.customer
LIMIT 5;


UPDATE examples3_87.students
SET name="Grzesiek"
WHERE id=10;


use sakila3_87



SELECT *
FROM customer
WHERE active = 1

          XOR first_name like 'ANDRE%' order by first_name;



select rental_date from rental;



-- FORMATOWANIE ALIASOWANIE

select  'hello world' as witaj_swienie


select
    actor.first_name as imie,
    actor.last_name as nazwisko
from actor


select rental.rental_date,
date_format(rental_date, '%Y-%m-%d') as nowa_data
from rental


/*
Zbiory i łączenie za pomocą UNIONa
*/


create temporary table tmp_proba(
    first_col text,
    second_col int
)


insert into tmp_proba values
    ('Kot', 2),
    ('pies', 2),
    ('kot', 3);


create temporary table tmp_proba2(
    first_col text,
    second_col int
);

insert into tmp_proba2 values
    ('Niedźwiedź', 2),
    ('pies', 3),
    ('kot', 3);


select first_col,second_col from  tmp_proba
union
select first_col, second_col from tmp_proba2;

/*
update actor
set first_name = 'ZYGZAK'
where last_name = 'MCQUEEN';
*/


select * from actor order by first_name desc;






