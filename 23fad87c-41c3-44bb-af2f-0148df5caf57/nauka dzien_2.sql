-- Będzie Joinowane --

use examples3_87;


-- INNER JOIN
select *
from payment_join
inner join rental_join
on payment_join.rental_id = rental_join.rental_id;


-- LEFT JOIN
select *
from payment_join
LEFT JOIN rental_join
on payment_join.rental_id = rental_join.rental_id;

-- LEFT JOIN TYLKO Z TYMI CO NIE PASUJĄ
select *
from payment_join
LEFT JOIN rental_join
on payment_join.rental_id = rental_join.rental_id
WHERE rental_join.rental_id IS NULL; -- DODANIE IS NULL


-- RIGHT JOIN

select *
from payment_join PJ
RIGHT JOIN rental_join RJ
on PJ.rental_id = RJ.rental_id;


-- to jest LEFT JOIN który dał dokładnie te same wyniki co ten RIGHT JOIN wyżej
select *
from rental_join rj
LEFT JOIN payment_join pj
on rj.rental_id = pj.rental_id;

-- RIGHT JOIN W ZASADZIE MOŻE BYĆ NIEUŻYWANY BO WYSTARCZY W ZASADZIE ZAMIENIĆ DANE W LEFT JOINIE I BĘDZIE NA TO SAMO

-- FULL JOIN

select *
from payment_join pj
left join examples3_87.rental_join rj
on pj.rental_id = rj.rental_id
union
select *
from payment_join PJ
RIGHT JOIN rental_join RJ
on PJ.rental_id = RJ.rental_id;

-- USING - do użycia tylko wtedy kiedy nazwa zmiennej po której łączymy ma dokładnie tą samą nazwę
select *
from payment_join
inner join rental_join
using (rental_id);

-- dzięki temu przy tabeli wynikowej nie mamy powtórzenia kolumny zmiennej po której łączymy
-- tabele muszą być równe



-- dodanie tabeli co by mozna yło na niej działać i usuwać
create table examples3_87.film_copy as
select * from sakila3_87.film;


delete from film_copy
where film_id < 5;

select * from film_copy;


-- DELETE

DELETE c
FROM delete_join_customer as c
join delete_join_address as a
using (address_id)
where district = 'England';

select * from delete_join_customer;

-- Update


update update_join_rental as r
left join update_join_payment as p
on r.rental_id = p.rental_id
set r.return_date = NULL
where p.rental_id is null;

select * from update_join_rental;
-- insert


insert into customer_rental_insert
select
    c.first_name,
    c.last_name,
    c.email,
    r.rental_id,
    r.rental_date,
    r.return_date

from sakila3_87.rental r
join sakila3_87.customer c
on r.customer_id = c.customer_id;


select * from customer_rental_insert



-- DELETE CASCADE

CREATE TABLE examples3_87.buildings (
  building_no INT PRIMARY KEY,
  building_name VARCHAR(255),
  address VARCHAR(255)
);

CREATE TABLE examples3_87.rooms (
  room_no INT,
  room_name VARCHAR(255) NOT NULL,
  building_no INT NOT NULL,

  -- Tutaj znajduje się definicja klucza obcego
  FOREIGN KEY (building_no)

  -- do której kolumny oraz tabeli się odnosimy
  REFERENCES examples3_87.buildings (building_no)

  /*
  * poniższy fragment mówi, że gdy rekord zostanie
  * usunięty z buildings,
  * odnoszący się do niego wiersz z rooms - również
  */
  ON DELETE CASCADE
);


INSERT INTO examples3_87.buildings(building_no, building_name, address)
VALUES (1, 'ACME Headquarters','3950 North 1st Street CA 95134'),
  (2, 'ACME Sales','5000 North 1st Street CA 95134');


INSERT INTO examples3_87.rooms(room_no, room_name, building_no)
VALUES(1, 'Amazon',1),
  (2, 'War Room',1),
  (3, 'Office of CEO',1),
  (4, 'Marketing',2),
  (5, 'Showroom',2);


SELECT * FROM buildings;
SELECT * FROM rooms;

DELETE FROM buildings WHERE building_no = 2;

-- Exporty Danych

use sakila3_87;

select * from rental;
select * from film_analytics;
select * from actor_analytics;
select * from film_list;

select * from film_analytics as fa
join film_list as fl
on fa.film_id = fl.FID;



-- SElF JOINy

CREATE TABLE employees (
    id INT auto_increment primary key,
    name VARCHAR(255),
    report_to INT, -- by default nullable (can be NULL)
    FOREIGN KEY (report_to) REFERENCES employees (id)
);

INSERT INTO employees (id, name, report_to) VALUES
    (1, 'Ela', NULL), (2, 'Bartek', 1), (3, 'Monika', 1), (4, 'Tomek', 3);

select * from employees;

SELECT
    e1.name AS superior,
    e2.name AS subordinate -- list of all relations
FROM
        employees AS e1 -- table employees on the left
    JOIN
        employees AS e2 -- and right side of JOIN means SELF JOIN
            ON e2.report_to = e1.id;
