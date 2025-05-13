/*Używając tabeli actor_analytics, napisz zapytanie, które pogrupuje aktorów według poniższych kryteriów:

jeśli avg_film_rate < 2 - 'poor acting',
jeśli avg_film_rate jest pomiędzy 2 oraz 2.5 - 'fair acting',
jeśli avg_film_rate jest pomiędzy 2.5 oraz 3.5 - 'good acting',
jeśli avg_film_rate jest powyżej 3.5 - 'superb acting.
Tak stworzoną kolumnę nazwij acting_level i następnie na jej podstawie dokonaj następującej analizy, obliczając:

liczbę wystąpień w każdej grupie,
sumę przychodów każdej grupy,
liczbę filmów w każdej grupie,
średni rating w grupie.*/


use sakila3_87;

select * from actor_analytics;


select  a.acting_level,
       count(acting_level) /*over (partition by a.acting_level)*/ as 'Count by acting level',
       sum(actor_payload) /*over (partition by a.acting_level)*/ as 'sum by films amount',
       sum(films_amount) /*over (partition by a.acting_level)*/ as 'count as films amount',
       avg(avg_film_rate) /*over (partition by a.acting_level)*/ as 'avg film rate by acting lvl'
       from (
select * ,
       case
           when avg_film_rate < 2 then 'poor acting'
           when avg_film_rate between 2 and 2.5 then 'fair acting'
           when avg_film_rate between 2.5 and 3.5 then 'good acting'
           when avg_film_rate > 3.5 then 'super acting'
            else 'ERROR'
        end as acting_level
from actor_analytics)a
group by a.acting_level;




/*Długość filmu
Napisz procedurę, która na podstawie długości trwania filmu (np. kolumna length z film) przypisze rekord do jednej z poniższych grup:

very short - film do 1h,
short - film do 1.5h,
normal - film do 2h,
long - film do 2.5h,
very long - film ponad 2.5h.
Procedurę nazwij film_classification.

Wskazówka:

W powyższym zadaniu na razie nie będziemy odpytywać żadnej tabeli.
Długość trwania filmu będziemy podawać jako parametr w procedurze
*/

DELIMITER $$
CREATE PROCEDURE film_classification(in film_time double)
begin
    if film_time < 60 then
        SELECT 'very short';
    elseif film_time < 90 then
        select 'short';
    elseif film_time < 120 then
        select 'normal';
    elseif film_time < 150 then
        select 'long';
    else
        select 'very long';
    END if;
end;$$



call film_classification(87);



/*Kwota wpłaty
Napisz zapytanie, które zgrupuje wpłaty według następującej klasyfikacji:

fee - wpłaty poniżej 2,
regular - w przeciwnym wypadku.
W celu wykonania zadania użyj tabeli payment.

Wynik pogrupuj i używając SQL, odpowiedz na pytanie: jaki procent wszystkich wpłat stanowią kary (fee)?*/




with cte as
(select
       if(amount < 2, 'Fee', 'reglar') as payment_type,
       sum(amount) as sum_amount
from payment
group by 1)

select *,
    sum_amount/sum(sum_amount) over () * 100
   -- sum(case when RR = 'Fee' then amount else 0 end ) / sum(amount) * 100 as procent_kar
from cte;


/*Wypożyczenie filmu
Bazując na analogii z transakcji bankowej, napisz procedurę film_rental, która sprawdzi na podstawie tabeli trigger_exercise.stock_part_1, czy dany film_id można wypożyczyć – jeśli tak, pomniejsz zapas o jeden i zwróć 1, w przeciwnym wypadku zwróć 0.

Przykład zastosowania:

CALL film_rental(1)

Skorzystaj tutaj z mechanizmu transakcji, wykonując poniższe kroki:

Najpierw napisz kwerendę, która znajdzie film oraz pomniejszy jego inwentarz o 1.
Jeśli film został znaleziony oraz jego liczba jest wystarczająca, by go wypożyczyć, zatwierdź transakcję.
W przeciwnym wypadku wycofaj.*/

USE trigger_exercise3_87;


/*DROP TABLE IF EXISTS examples.pln_acc;
CREATE TABLE examples.pln_acc (bal_pln numeric);
INSERT INTO examples.pln_acc VALUES (500);

DROP TABLE IF EXISTS examples.eur_acc;
CREATE TABLE examples.eur_acc (bal_eur numeric);
INSERT INTO examples.eur_acc VALUES (0);*/

-- Wykonanie transakcji
select * from stock_part_1;



DELIMITER $$
DROP PROCEDURE IF EXISTS film_rental;
CREATE PROCEDURE film_rental(in arg_film_id INT)  -- tworzymy procedurę
BEGIN  -- rozpoczynamy procedurę
START TRANSACTION; -- rozpoczynamy transakcję

UPDATE stock_part_1 SET stock = stock - 1 WHERE stock > 0 and arg_film_id=film_id ; -- aktualizujemy stan konta
IF ROW_COUNT() > 0 THEN  -- sprawdzamy, czy został zaktualizowany wiersz
  select 1 as result,
         stock as films_left from stock_part_1 where film_id = arg_film_id ;
  COMMIT;
ELSE select 0 as result;
  ROLLBACK;
END IF;
END; $$

select * from stock_part_1;

call film_rental(4);

select * from stock_part_1
where film_id=3;



/*Wypożyczenia filmu 2
Napisz procedurę film_rental_store, która sprawdzi, czy jest możliwe wypożyczenie filmu w danej wypożyczalni
  (tabela stock_part_2).

Gdy można to zrobić (film jest dostępny), procedura powinna:

zwrócić informację o stanie magazynu po wypożyczeniu
oraz informację, że można wypożyczyć.
W przeciwnej sytuacji procedura powinna:

zwrócić informację, że dana wypożyczalnia nie posiada już stanów magazynowych,
zwrócić informację, czy możliwe jest wypożyczenie w drugiej. Jeśli tak to tam dokonać rezerwacji,
czyli pomniejszenia stanu magazynowego.
Jakie parametry musi przyjąć procedura, aby mogła zostać wykonana?*/

DELIMITER $$
drop procedure if exists film_rental_store;
create procedure film_rental_store(IN arg_film_id INT, IN arg_store_id INT)
BEGIN
    set @available_stock = (select count(*) from trigger_exercise1_87.stock_part_2 where film_id = arg_film_id and arg_store_id = store_id );

    START TRANSACTION;
    DELETE FROM trigger_exercise1_87.stock_part_2 WHERE film_id=arg_film_id and store_id=arg_store_id limit 1;

    if row_count() > 0 then
        select 'Udało się wypożyczyć' as result,
               arg_store_id as store_id,
               @available_stock - 1 as stock_left,
               arg_film_id as film_id;
        COMMIT;
    else
        set @other_store = (select store_id from trigger_exercise1_87.stock_part_2 where film_id=arg_film_id limit 1);
        set @other_store_left = (select count(*) from trigger_exercise1_87.stock_part_2 where film_id=arg_film_id and store_id=@other_store);

        if @other_store is not null then
            DELETE FROM trigger_exercise1_87.stock_part_2 WHERE film_id=arg_film_id and store_id=@other_store limit 1;
            select 'Wypożyczono z innej wypożyczalni' as result,
                   @other_store as store_id,
                   @other_store_left-1 as stock_left,
                   arg_film_id as film_id;
        end if;
    end if;

end $$

call film_rental_store(4, 1);

-- PĘTLE

/*Mnożenie
Stwórz w bazie procedurę o dowolnej nazwie, która dla danych parametrów:
podstawa oraz liczba_elementów zwróci tyle kolejnych wielokrotności podstawy, ile wynosi liczba elementów.
*/

DELIMITER $$

drop procedure if exists MNOZENIE;
CREATE PROCEDURE MNOZENIE(IN PODSTAWA INT, IN L_ELEM INT)
BEGIN
    declare x int;
    declare str varchar(255) default '';
    set x = 1;
    LOOP_MNOZ: while x <= L_ELEM DO
         set str = concat(str, cast(PODSTAWA * x as char(10)), ', ');
         set x = x+1;
        end while;
    select str;
end $$


call MNOZENIE(8,5);


/*
Losowanie
Napisz procedurę, która najpierw stworzy tabelę o nazwie randomizer,
a następnie uzupełni ją losowymi wartościami (ile tych wartości ma być w tabeli,
powinno być parametrem procedury).
*/



DELIMITER $$

drop procedure if exists randomizer;
CREATE PROCEDURE randomizer(IN elem INT)
BEGIN
    declare x int default 1; -- declare between 0 and 1 --;
    declare value float default 0;
drop table if exists porazka;
create temporary table porazka(id int, value float);

    rand_loop: while x <= elem do
        set value = rand();
        insert into porazka values(x, value);
        set x = x+1;
    end while;
    select * from porazka;
end $$

call randomizer(9);



/*
Newsletter
Używając kursorów napisz procedurę, która dla aktywnych klientów z obrębu
Buenos Aires zwróci emaila do wysyłki newslettera.

Poszczególne elementy oddziel ;.
*/

use sakila3_87;

delimiter $$
drop procedure if exists newsletter;
create procedure newsletter(INOUT newsletter_list varchar(16000))
begin
    declare finished INTEGER DEFAULT 0;
    DECLARE customer varchar(100) DEFAULT '';
    declare cur_customer cursor for
        select email from customer join  address using(address_id) where district ='Buenos Aires';
    declare continue handler for not found set finished = 1;
    open cur_customer;
    loop_label: LOOP
        FETCH cur_customer into customer;
        if finished = 1 then
            leave loop_label;
        end if;
        set newsletter_list = concat(newsletter_list, ';', customer);
    end loop loop_label;
    close cur_customer;
end $$
set @newsletter_list = '';
select @newsletter_list;
call newsletter(@newsletter_list);
select @newsletter_list;




