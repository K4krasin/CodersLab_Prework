/*Zagreguj tabelę payment według następujących reguł:

wyznacz całkowitą kwotę wpływów wypożyczalni,
wyznacz całkowitą kwotę wpływów wypożyczalni w podziale na klientów (na razie nie pisz JOIN, użyj tylko customer_id),
wyznacz całkowitą kwotę wypożyczonych filmów w zależności od pracownika,
używając funkcji date_format wykonaj podpunkty 2. i 3.
dodatkowo w rozbiciu na miesiące kalendarzowe a wyniki posortuj malejąco według klucza:
  customer_id/staff_id rosnąco, amount - malejąco.*/

use sakila3_87;

select sum(amount) from payment;

select * from payment;

select sum(amount) from payment
group by customer_id
order by 1 desc;


select sum(amount) from payment
group by staff_id
order by 1 desc;

select sum(amount) as a, date_format(payment_date,'%M') as d, customer_id from payment
group by customer_id, d
order by customer_id, a desc;


select sum(amount) as a, date_format(payment_date,'%M') as d, staff_id from payment
group by staff_id, d
order by staff_id, a desc;

/*Raport wpłatowy
Przygotuj raport wpłatowy na podstawie odpowiednich tabel z bazy sakila, który wyświetli następujące informacje:

imię klienta,
nazwisko klienta,
email klienta,
kwotę wpłat,
liczbę wpłat,
średnią kwotę wpłat,
datę ostatniej wpłaty.
Wynik zapytania zapisz w bazie używając widoku.

Jak sprawdzisz, czy Twoje zapytanie jest poprawne? Napisz odpowiedną kwerendę (odpowiednie kwerendy).*/

select * from payment;


create view RAPORT_WPŁATOWY as
select
    first_name,
    last_name,
    email,
    sum(p.amount) as 'Sum amount',
    count(p.amount) as Amount,
    avg(p.amount) as 'Avg amount' ,
    max(p.payment_date) as 'Last date'
from customer
join
    payment as p using (customer_id)
group by first_name, last_name, email;

select * from RAPORT_WPŁATOWY;

select sum(`Sum amount`) from RAPORT_WPŁATOWY;


/*Najbardziej kasowy film (cz. 1) - Liczba aktorów w filmie
Napisz kwerendę, która zwróci następujące informacje:

id filmu,
nazwę filmu,
liczbę aktorów występujących w filmie.
Wyniki zapisz do tabeli tymczasowej, np. tmp_film_actors.

Dodatkowo napisz zapytanie, którym zweryfikujesz swoją kwerendę.*/


select * from film;

select * from film_actor;


create temporary table tmp_film_actors as(
select film_id, title,
       count(distinct fa.actor_id) as actors
from film
join film_actor as fa using (film_id)
group by film_id, title
order by actors desc);

select sum(actors) from tmp_film_actors; -- 5462

select sum(actors) from film_analytics; -- 5246

with cte as ( select film_id, count(actor_id) as cnt_actor_check from film_actor group by 1 )
    select * from cte  as c  join tmp_film_actors as t using(film_id) where c.cnt_actor_check != t.actors;


/*Najbardziej kasowy film (cz. 2) - Liczba wypożyczeń filmu
Napisz zapytanie, które zwróci:

id filmu,
tytuł filmu,
liczbę wypożyczeń filmu.
Wyniki zapisz do tabeli tymczasowej, np. tmp_film_rentals.

Dodatkowo napisz kwerendę, którą zweryfikujesz swoje rozwfiązanie.*/

select * from film;
where rental_id is null;

select * from inventory;

drop table if exists tmp_film_rentals;
create temporary table tmp_film_rentals
select film_id, title,
       count( r.inventory_id) as Film_rentals
from film
join inventory as i using (film_id)
join rental as r
on i.inventory_id = r.inventory_id
group by film_id, title
order by Film_rentals desc;

select * from tmp_film_rentals; -- 16044

select * from film_analytics; -- 16004


/**/
/*Najbardziej kasowy film (cz. 3) - Przychody z filmu
Napisz zapytanie, które zwróci kwotę wpłat z filmu w następującym formacie:

id filmu, kwota wpłat z filmu.

Wyniki zapisz do tabeli tymczasowej, np. tmp_film_payments.

Pamiętaj o sprawdzeniu poprawności zadania.*/

select * from payment;
select sum(payment.amount) from payment; -- 67416,51

DROP TABLE tmp_film_payments;

create temporary table tmp_film_payments
select
    i.film_id as film,
    sum( p.amount) as rent
from payment as p
join rental as r using (rental_id)
join inventory as i using (inventory_id)
group by film;

select * from tmp_film_payments
order by rent desc ;

/*Najbardziej kasowy film - Podsumowanie
Przygotuj raport, który wyświetli top 10 najchętniej wypożyczanych filmów. Przyjmij następujące założenia biznesowe do przygotowania raportu:

nazwa filmu,
liczba aktorów, którzy w nim grali,
kwota przychodu filmu,
liczba wypożyczeń filmu.
Dodatkowo upewnij się, że kwota, którą otrzymasz, dla wszystkich filmów będzie poprawna (jeszcze zanim ograniczysz wyniki).*/

select * from tmp_film_actors;

select actors,
       tfr.Film_rentals,
       tfp.rent,
       tfr.title
from tmp_film_actors
         join tmp_film_rentals tfr on tmp_film_actors.film_id = tfr.film_id
         join tmp_film_payments tfp on tfp.film = tfr.film_id
order by Film_rentals desc, rent desc
limit 10;



/*
Napisz zapytanie, które wygeneruje raport o:

 - sumie sprzedaży danego sklepu oraz jego pracownikach,
 - całkowitej sumie sprzedaży danego sklepu (bez podziału na pracowników),
 - całkowitej sumie sprzedaży.
Dodatkowo – posortuj wiersze w wybrany przez siebie sposób.*/

select * from rental; -- staff id, rental id

select * from inventory; -- rental store id inv id

select * from staff; -- amount rental id

# moje rozwiązanie - źle bo pracownicy w 2 sklepach a jest po jednym na sklep

select r.staff_id,
       i.store_id,
       sum(p.amount)
       from rental as r
join payment as p using (rental_id)
join inventory as i using (inventory_id)
group by i.store_id, r.staff_id
with rollup;

# poprawne
SELECT s.store_id, s2.staff_id,  sum(p.amount) as sales
FROM
    inventory as i
        INNER JOIN
    rental as r   USING (inventory_id)
        INNER JOIN
    payment as p USING (rental_id)
        INNER JOIN
    store as s USING (store_id)
        INNER JOIN
    staff as s2 USING (store_id)
GROUP BY
    s.store_id,
    s2.staff_id with rollup
ORDER BY 1, 2;

select *
from sales_by_store;
-- 33726.77
-- 33679.79


select sum(amount),
       customer_id,
       staff_id
from payment
where customer_id <4
group by customer_id, staff_id
with rollup
having sum(amount) > 70;



--

/*Ranking aktorów
Napisz kwerendę, która stworzy ranking aktorów na podstawie średniego ratingu z filmów, w których grali.
  W celu wykonania zadania przyjmij następujące założenia:

użyj widoku actor_analytics,
do stworzenia rankingu posłuż się funkcją ROW_NUMBER().
Posortuj aktorów od najlepszego do najgorszego, tj. 1 - najwyższy rating.

Dodatkowo przejrzyj tabelę i zobacz, jak traktowane są wiersze, które mają takie same wartości*/

select first_name, last_name, avg_film_rate,
       rank() over (order by avg_film_rate desc) as Best_actor
from actor_analytics;


/*Kumulanta
Kumulanta, jak sama nazwa wskazuje, określa wartość narastającą, funkcje okna dają nam możliwość policzenia według ustalonego porządku – służy do tego klauzula ORDER BY.

W pewnym sensie ROW_NUMBER() był cicho przemyconym przykładem kumulanty w sensie liczebności elementów w partycji. W statystyce to podejście można zastosować do wyznaczenia np. dystrybuanty.

Naszym zadaniem będzie napisanie klauzuli, która wyznaczy następujące narastające wartości:

MIN dla avg_film_rate,
SUM dla actor_payload,
MAX dla longest_movie_duration.
Jako klucza do sortowania użyj actor_id – rosnąco.*/


select first_name, last_name, avg_film_rate,actor_payload,
       min(avg_film_rate) over (order by actor_id) as minimum_avg,
       sum(actor_payload) over (order by actor_id) AS sum_payload,
       max(longest_movie_duration) over (order by actor_id) as Longest_movie

from actor_analytics;


/*Reguła Pareta
Reguła Pareta w skrócie mówi o tym, że 20% społeczeństwa posiada 80% bogactwa.

W kontekście wypożyczalni video chcemy przeprowadzić podobną analizę - w tym celu wykorzystamy funkcje okna. Posłużymy się jeszcze raz danymi o aktorach z widoku actor_analytics i zbadamy jaki % aktorów odpowiada za jaki % wpływów wypożyczalni.

Jak należy podejść do tego zadania?

Stwórz funkcję okna używając ROW_NUMBER,
Używając COUNT oraz pustego okna (OVER ()) zlicz liczbę wierszy w tabeli,
Dzieląc pkt 1./2. otrzymasz rosnący ciąg odpowiadający % aktorów,
Wykorzystaj wiedzę z podpunktów 1-3, aby wykonać analogiczne działanie dla % wpływów.
Dokonaj interpretacji wyników zapytania dla przykładowego aktora.*/


select * from actor_analytics;


select actor_id, actor_payload,
       row_number() over (order by actor_payload desc ) / count(*) over () as ac,
       sum(actor_payload) over (order by actor_payload desc) / sum(actor_payload) over () as XD
from actor_analytics
group by actor_id, actor_payload;


select aa.actor_id,
       row_number() over (order by actor_payload desc ) / count(*) over () pareto_count,
       sum(actor_payload) over (order by actor_payload desc) / sum(actor_payload) over ()  pareto_payload
from actor_analytics aa
group by aa.actor_id



/*Rankowanie
Używając RANK, DENSE_RANK oraz ROW_NUMBER stwórz rankowanie filmów według liczby wypożyczeń.

Zwróć uwagę na wyniki poszczególnych funkcji.

Wykonaj to zadanie dodatkowo partycjonując według rating.

W tym zadaniu możesz skorzystać z tabeli sakila.film_analytics*/

select *
from film_analytics;


select * from (
select title, rentals,rating,
       rank() over (partition by rating order by rentals desc) as rank_rental,
       dense_rank() over (partition by rating order by rentals desc) as drank_rentals,
       row_number() over (partition by rating order by rentals desc) as rn
from film_analytics)a
where rn < 3;



-- DATY

select datediff('2000-01-01', '2030-12-31'); -- 11322

drop table Calendar;

create TABLE Calendar
select
    adddate('2000-01-01', rn -1 ) as date as
    (select date,
    extract(year from date) as year,
    extract(month from date) as month,
    extract(day from date) as day,
    dayofweek(date) as week,
    weekofyear(date)
from Calendar)

from(
select
       row_number() over () as rn
from payment
limit 11322)a;

select date,
    extract(year from date) as year,
    extract(month from date) as month,
    extract(day from date) as day,
    dayofweek(date) as week,
    weekofyear(date)
from Calendar;


/*drop table if exists calendar;
CREATE table  if not exists calendar as (
with cte as ( select adddate('2000-01-01', row_number() over ()-1 ) as origin_date from payment limit 11322)

select origin_date,
        extract(year from origin_date) as date_year,
       extract(month from origin_date) as date_month,
       extract(day from origin_date) as date_day,
       dayofweek(origin_date) as day_of_week,
       weekofyear(origin_date) as week_of_year,
        now(),
       UTC_DATE()

from cte);

select * from calendar;*/




/*Używając tabeli payment, stwórz widok, który wyświetli następujące podsumowania:

suma wpłat w roku kalendarzowym - tę kolumnę nazwij payment_year,
suma wpłat w miesiącach kalendarzowych - tę kolumnę nazwij payment_month,
całkowita suma wpłat.
Dodatkowo zadbaj o logiczne wyświetlenie wyniku używając ORDER BY.*/




select
       extract(year from payment_date) as p_year,
       extract(month from payment_date) as p_month,
       sum(amount) as total_sum
from payment
group by 1,2
with rollup
order by 1,2;



