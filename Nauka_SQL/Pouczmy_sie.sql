-- stwórzmy sobie kilka kopii tabel z sakili do testu

use tasks3_87;

create table copy_actor
select * from sakila3_87.actor;


create table copy_payment
select * from sakila3_87.payment;


--
select copy_payment.payment_date,
date_format(payment_date, '%e-%f-%H/%s')
from copy_payment;


select date_format('1982-12-05',get_format(DATE,'eur'));

SELECT DATE_FORMAT('2003-10-03',GET_FORMAT(DATE,'EUR'));

--




/*
CHAT BOTOWE ZADANKA Z UFC
1. **Znajdowanie danych:**
   - Znajdź wszystkich zawodników, którzy mają więcej niż 10 nokautów (kd).
2. **Filtrowanie danych (5 zadań):**
   - Wybierz wszystkich zawodników o wadze powyżej 170 funtów.
   - Wylistuj walki, które odbyły się po 1 stycznia 2020.
   - Znajdź walki, gdzie zawodnicy mieli więcej niż 50 prób poddań.
   - Pokaż dane zawodników, którzy mają więcej niż 2 m wygranych przez KO.
   - Wyfiltruj walki, które były sędziowane przez 'John McCarthy'.
3. **Formatowanie danych wyjściowych:**
   - Wyświetl nazwisko zawodnika i datę walki, używając aliasów 'Zawodnik' i 'Data Walki'.
   - Formatuj daty walk jako 'DD-MM-YYYY'.
   - Użyj funkcji COALESCE do wyświetlenia 'brak danych' jeśli informacje o nokautach są puste.
   - Zastosuj funkcje LEAST i GREATEST do pokazania minimalnej i maksymalnej liczby takedownów wśród walk zawodników.
4. **Zadania z użyciem UNION:**
   - Połącz listy zawodników z wagą poniżej 155 funtów i powyżej 205 funtów w jednym zapytaniu.
5. **Podzapytania:**
   - Znajdź zawodników, którzy mają więcej nokautów niż średnia dla wszystkich zawodników.
   - Wyświetl walki, w których zwycięzca miał więcej takedownów niż średnia takedownów w jego kategorii wagowej.
*/


-- 1. **Znajdowanie danych:**
   -- Znajdź wszystkich zawodników, którzy mają więcej niż 10 nokautów (kd).

SELECT * FROM ufc_fights;
SELECT DISTINCT ufc_fights.win_by FROM ufc_fights;

drop table tmp_winKO;


select * from tmp_winKO;
/*                    UNION all
                    SELECT R_fighter_id FROM ufc_fights
                    WHERE win_by = 'KO/TKO';*/
create temporary table tmp_winKO
select b_fighter_id,win_by from ufc_fights
where win_by = 'KO/TKO'
and winner = 'Blue'
union all
select r_fighter_id,win_by from ufc_fights
where win_by = 'KO/TKO'
and winner = 'Red';

select * from tmp_winKO;

select count(id) as id,
    f.fighter_name as FighterName
from tmp_winKO as twK
join ufc_fighters as f
on b_fighter_id = id
group by FighterName
order by id desc;

-- 9 zawodników

/*2. **Filtrowanie danych (5 zadań):**
   - Wybierz wszystkich zawodników o wadze powyżej 170 funtów.
   - Wylistuj walki, które odbyły się po 1 stycznia 2020.
   - Znajdź walki, gdzie zawodnicy mieli więcej lub równo 5 prób poddań.
   - Pokaż dane zawodników, którzy mają więcej niż 2 m wygranych przez KO.???????????
   - Wyfiltruj walki, które były sędziowane przez 'John McCarthy'.*/

select * from ufc_fighters
where weight_pounds > 170
order by weight_pounds;

select * from ufc_fights
where date > '2020-01-01'
order by date;

select * from ufc_fights
where b_sub_att >= 5
or r_sub_att >= 5;

select * from ufc_fights
where referee = 'John McCarthy';

/*3. **Formatowanie danych wyjściowych:**
   - Wyświetl nazwisko zawodnika i datę walki, używając aliasów 'Zawodnik' i 'Data Walki'.
   - Formatuj daty walk jako 'DD-MM-YYYY'.
   - Użyj funkcji COALESCE do wyświetlenia 'brak danych' jeśli informacje o nokautach są puste.
   - Zastosuj funkcje LEAST i GREATEST do pokazania minimalnej i maksymalnej liczby takedownów wśród walk zawodników.
***/

select * from ufc_fighters;

select
    a.date as 'Data walki' ,
    b.fighter_name as Zawodnik
from ufc_fights as a
join ufc_fighters as b
on a.b_fighter_id = b.id
where fighter_name = 'Shamil Abdurakhimov';


select *, date_format(date,get_format(date,'EUR'))
from ufc_fights;


select fighter_name,
       coalesce(date_of_birth, 'Brak Danych') as 'data urodzenia'
from ufc_fighters;


select least(r_td, b_td) from ufc_fights;
select greatest(r_td, b_td) from ufc_fights;

/*4. **Zadania z użyciem UNION:**
- Połącz listy zawodników z wagą poniżej 155 funtów i powyżej 205 funtów w jednym zapytaniu.*/

select * from ufc_fighters
where weight_pounds < 155
union
select * from ufc_fighters
where weight_pounds > 205
order by weight_pounds desc;


/*5. **Podzapytania:**
   - Znajdź zawodników, którzy mają więcej nokautów niż średnia dla wszystkich zawodników.
  Z czerwonego narożnika bo mam już dość xD
*/
select distinct fighter_name from ufc_fighters
join ufc_fights
on id = r_fighter_id
where r_td > (select avg(ufc_fights.r_td) from ufc_fights);


--    - Wyświetl walki, w których zwycięzca miał więcej takedownów niż średnia takedownów w jego kategorii wagowej.*/

select avg(ufc_fights.r_td) from ufc_fights;
-- 0.15604817594693665

-- ujednolicenie kategorii UFC
update ufc_fights
set fight_type ='UFC Women''s Strawweight'
where fight_type = 'UFC W_Strawweight';

-- select distinct ufc_fights.f from ufc_fights;

select avg(r_td), avg(b_td), fight_type from ufc_fights
group by fight_type;

-- stworzenie tabeli ze zwycięzcami i ich wynikiem td
create temporary table tmp_td_fight
select b_td as td, fight_type from ufc_fights
where winner = 'Blue'
union all
select r_td, fight_type from ufc_fights
where winner = 'Red';

-- tabela do średnich
create temporary table tmp_avg_td_perfight(
    Fight VARCHAR(255) PRIMARY KEY,
    avg_td float
);

-- ibsert danych do tabeli, policzenie średniej dla każdej kategorii
insert into tmp_avg_td_perfight
select fight_type,avg(td) from tmp_td_fight
where fight_type = 'UFC Superheaveweight';

select distinct fight_type from tmp_td_fight;

select * from tmp_avg_td_perfight;


select * from ufc_fights;

select * from ufc_fights as uf
join tmp_avg_td_perfight as avguf
on avguf.Fight = uf.fight_type
where b_td > avguf.avg_td
or r_td > avguf.avg_td;


/*
1. **Złącz tabelę zawierającą dane zawodników z tabelą zawierającą dane walk.**
     Użyj fighter_id jako klucza łączącego. Wyświetl dane takie jak fighter_name, date, win_by, i winner.
2. **Analiza walk po krajach.** Połącz dane walk z danymi lokalizacji używając location_id,
    a następnie zsumuj i porównaj liczbę walk w każdym kraju.
3. **Statystyki zawodników w różnych typach walk.**
    Złącz tabelę zawodników z tabelą walk,
    a następnie zbadaj, jak różne typy walk (fight_type) wpływają na statystyki zawodników takie jak kd, sig_str, czy total_str.
4. **Historia walk zawodnika.**
    Utwórz złączenie tabeli zawodników z tabelą walk dwa razy
    (dla zwycięzcy i przegranego) aby uzyskać historię wszystkich walk danego zawodnika.
*/


-- 1. **Złącz tabelę zawierającą dane zawodników z tabelą zawierającą dane walk.**
--     Użyj fighter_id jako klucza łączącego. Wyświetl dane takie jak fighter_name, date, win_by, i winner.

select * from ufc_fights
join ufc_fighters
on r_fighter_id = id
union all
select * from ufc_fights
join ufc_fighters
on b_fighter_id = id;


-- 2. **Analiza walk po krajach.** Połącz dane walk z danymi lokalizacji używając location_id,
--    a następnie zsumuj i porównaj liczbę walk w każdym kraju.

select count(fight.location_id) as times, loc.country from ufc_fights as fight
join ufc_locations as loc
using (location_id)
group by country
order by times desc;

-- 3. **Statystyki zawodników w różnych typach walk.**
--    Złącz tabelę zawodników z tabelą walk, a następnie zbadaj,
-- jak różne typy walk (fight_type) wpływają na statystyki zawodników takie jak kd, sig_str, czy total_str.

drop table tmp_full_table;

create  table full_table
select * from ufc_fights
join ufc_fighters
on r_fighter_id = id
union
select * from ufc_fights
join ufc_fighters
on b_fighter_id = id;


select fight_type, avg(b_kd), avg(r_kd), avg(b_sig_str), avg(r_sig_str),avg(b_total_str), avg(r_total_str)  from tmp_full_table
group by fight_type;


/*4. **Historia walk zawodnika.**
    Utwórz złączenie tabeli zawodników z tabelą walk dwa razy
    (dla zwycięzcy i przegranego) aby uzyskać historię wszystkich walk danego zawodnika. Donald Cerrone*/


select count(id) as lw, id from tmp_full_table
group by id
order by lw desc;


select fighter_name from ufc_fighters
where id = 523;

select r_fighter_id, winner, ufc_fighters.fighter_name from ufc_fights
join ufc_fighters
on r_fighter_id = id
where r_fighter_id = 523 and winner = 'Red'
union all
select b_fighter_id, winner, ufc_fighters.fighter_name from ufc_fights
join ufc_fighters
on b_fighter_id = id
where b_fighter_id = 523 and winner = 'Blue';

-- 23 wierszy więc 23 zwycięstwa


/*
1. **Zadanie z grupowaniem i ROLLUP:**
   - Napisz zapytanie, które zwróci sumę zarobków z wypożyczeń dla każdego gatunku filmu,
a następnie zsumuje te wartości dla całej bazy (użyj ROLLUP).
*/

use sakila3_87;

seleCT sum(payments) as Sum_of_payments,
       rating
FROM film_analytics
group by rating
with rollup ;

/*2. **Zadanie z HAVING:**
   - Utwórz zapytanie, które wyświetli tylko te kategorie filmów,
  gdzie średnia długość filmu przekracza 120 minut.
  Użyj grupowania po kategorii i klauzuli HAVING do filtrowania wyników.*/


select avg(length) as dlugosc, category from film_list
group by category
having dlugosc > 120;


/*3. **Zadanie z funkcjami okna:**
   - Napisz zapytanie, które dla każdego klienta pokaże całkowitą liczbę wypożyczeń oraz ranking
  klientów według liczby wypożyczeń w ramach każdego sklepu (użyj funkcji RANK() z partycjonowaniem po sklepie).*/


select
    customer_id,
    rank() over (partition by store_id) as aaa
from customer;

select * from customer;


/*1. **Podstawowe zapytania SQL**:
   - Wybierz wszystkich zawodników, którzy mają więcej niż 5 zwycięstw.*/
# 2. **Sortowanie i Filtrowanie**:
#    - Wybierz 10 zawodników z największą liczbą zwycięstw, posortowani od największej do najmniejszej.

use tasks3_87;


with cte as (select *, r_fighter_id as r_winner from ufc_fights where winner = 'red')
    select  r_winner,
            count(r_winner) as ilosc_zwyciestw
    from cte
group by r_winner
having ilosc_zwyciestw > 5
order by ilosc_zwyciestw desc;


/*3. **Łączenie tabel**:
   - Połącz tabele zawodników i walk, aby uzyskać informacje o liczbie walk każdego zawodnika.*/

select * from ufc_fights
join ufc_fighters on r_fighter_id = id;


/*4. **Funkcje agregujące**:
   - Oblicz średnią liczbę zwycięstw zawodników w każdej kategorii wagowej.*/


select count(r_fighter_id) from ufc_fights;

with cta as (select *,
                    if(winner= 'red', r_fighter_id, b_fighter_id) as winners
                    from ufc_fights )
select count(winners)/5729*100 as a,
       fight_type from cta
group by fight_type ;

/*5. **Grupowanie danych**:
   - Wyświetl liczbę zawodników w poszczególnych kategoriach wagowych.*/
create table ufc_fights_2
    select *,
                    if(winner= 'red', r_fighter_id, b_fighter_id) as winners
                    from ufc_fights;
with cte as(
select id, fighter_name, uf.fight_type
       from ufc_fighters
join ufc_fights as uf on r_fighter_id = id
union distinct
select id,fighter_name, uf2.fight_type from ufc_fighters
join ufc_fights as uf2 on b_fighter_id = id)
select count(id) as id, fight_type from cte
group by 2;


/*6. **Podzapytania**:
   - Znajdź zawodnika z największą liczbą zwycięstw, a następnie wybierz wszystkie jego walki.*/

select * from ufc_fights
    where b_fighter_id = 2113 or r_fighter_id = 523;


select r_fighter_id, count(winners) as best
from ufc_fights_2 group by r_fighter_id order by best desc limit 1;



/*7. **Funkcje okna**:
- Używając funkcji okna, oblicz bieżącą sumę zwycięstw każdego zawodnika w kolejności chronologicznej ich walk.*/

select winners,
       count(winners)  as win
from ufc_fights_2
group by winners order by win desc;


select date,winners,
    count(winners) over (partition by  winners) as wins,
    rank() over (order by winners) as wtf
from ufc_fights_2;

select * from ufc_fights;



SELECT
  b_fighter_id,
  date,
  b_td,
  AVG(b_td) OVER (PARTITION BY b_fighter_id ORDER BY date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_hits
FROM
  ufc_fights
ORDER BY
  b_fighter_id,
  date;

/*1. Oblicz średnią liczbę znaczących ciosów (sig_str) dla każdego zawodnika
  w porównaniu do średniej ogólnej w danej kategorii wagowej.
*/

select r_fighter_id,
       avg(r_sig_str) over (partition by r_fighter_id),
       avg(r_sig_str) over (partition by fight_type)

    from ufc_fights;

/*2. Znajdź medianę czasu kontroli (ctrl) dla walk w każdej rundzie.
*/

with cte as(
select *, time_to_sec(last_round_time) as time
       from ufc_fights)
select last_round_time, fight_type,
        avg(time) over (partition by format)
       from cte;

/*3. Oblicz kumulatywną liczbę zwycięstw dla każdego zawodnika w kolejności chronologicznej.
*/

select winners,
       dense_rank() over (order by winners)

       from ufc_fights_2;


/*4. Ustal, który zawodnik miał najwięcej takedownów (td) w każdym roku.
*/


select date_format(date, '%Y') as year, r_td, ufc_fights_2.r_fighter_id,
       count(r_td) over (partition by date_format(date, '%Y') order by r_fighter_id) as td_year
from ufc_fights_2;



/*6. Oblicz różnicę w liczbie prób poddania (sub_att) między kolejnymi walkami każdego zawodnika.

*/




select r_distance, cast(r_distance as double) - cast(lag(r_distance,1) over (partition by r_fighter_id) as double) as diff_distance, r_fighter_id
       from ufc_fights_2;


-- nie wiem czemu nie działą

/*7. Wylicz średnią liczbę knockdownów (kd) na walkę dla każdego zawodnika,
  używając funkcji okien z podziałem na kategorie wagowe.
*/


select avg(r_kd) over (partition by fight_type order by r_fighter_id) as adada, r_fighter_id, r_kd, fight_type

from ufc_fights_2;


/*1. **Procedura sprawdzająca wiek zawodników UFC**: Stwórz procedurę,
  która przyjmuje jako parametr ID zawodnika i sprawdza, czy zawodnik jest pełnoletni (18 lat lub więcej).
  Użyj wyrażenia warunkowego IF.*/

select * from full_table;

SELECT date_of_birth, date, id,timestampdiff(year , date_of_birth, date) as age FROM full_table order by age ;


delimiter $$

drop procedure if exists check_age;
create procedure check_age (in fighterid int)
begin

declare age int;
declare y date;
declare z date;

select date into y from full_table where id = fighterid limit 1;
select date_of_birth into z from full_table where id = fighterid limit 1;

set age =timestampdiff(year ,z,y);

    if age > 18 then
        select 'zawodnik pełnoletni';
    elseif age <= 18 then
        select 'zawodnik niepełnoletni';
    else
        select 'kosmita';
    end if;

end $$

call check_age(1755);


/*2. **Procedura aktualizująca ranking zawodnika**:
  Stwórz procedurę,która aktualizuje ranking zawodnika na podstawie liczby wygranych walk.
  Jeśli zawodnik wygrał więcej niż 20 walk, zwiększ jego ranking o 2 punkty, jeśli mniej,
  zwiększ o 1 punkt. Użyj wyrażenia CASE. nie! użyję ifa*/

select count(winner)
from full_table
where id = 134;

-- drop table ranking;
create table ranking(id int, ranking int, wins int);

delimiter $$
drop procedure if  exists fighters_ranking;
create procedure fighters_ranking(in fid int)
begin
declare y int;
declare x int default 1;
select count(winner) into y
from full_table
where id = fid;

if y >= 20 then
    set x = y*2;
    else set x = y;
end if;


delete from ranking where id = fid;
insert into ranking values(fid,x, y);

select * from ranking
order by ranking desc;
end $$

call fighters_ranking(253);




/*3. **Procedura do obliczania średniego czasu walki**:
  Stwórz procedurę, która oblicza średni czas walki zawodnika na podstawie dostępnych danych.
  Jeżeli średni czas ostatniej rundy przekracza 3 minut, procedura powinna zwrócić komunikat, że zawodnik ma dobrą wy w MySQL.
  Powodzenia!trzymałość. Użyj wyrażenia IF-ELSE.*/


select last_round_time from ufc_fights where r_fighter_id = 134 or b_fighter_id = 134;


select avg(time_to_sec(last_round_time)/60) from ufc_fights where r_fighter_id = 134 or b_fighter_id = 134;


delimiter $$
drop procedure if exists avg_fight;
create procedure avg_fight(in fid int)
begin
declare y int;
select avg(time_to_sec(last_round_time)) into y
        from ufc_fights
            where r_fighter_id = fid or b_fighter_id = fid;

if y > 180 then
    select fid, y, 'Wytrzymały skurczybyk';
else select fid, y, 'Miękka faja';
end if;

end $$


call avg_fight(1642);

/*
1. **Procedura zliczająca walki zawodników**:
Stwórz procedurę, która przyjmuje jako parametr ID zawodnika i zlicza, ile walk stoczył.
Użyj wyrażenia warunkowego, aby sprawdzić, czy zawodnik stoczył więcej niż 10 walk, jeśli tak,
procedura powinna zwrócić komunikat "Doświadczony zawodnik", w przeciwnym razie "Nowicjusz".*/


select count(r_fighter_id)+count(b_fighter_id) from ufc_fights where b_fighter_id = 245 or r_fighter_id = 245;


delimiter $$
drop procedure if exists fighter_experience;
create procedure fighter_experience(in fid int)
begin
declare y int default 1;
select count(r_fighter_id)+count(b_fighter_id) into y from ufc_fights where b_fighter_id = fid or r_fighter_id = fid;

if y > 10 then
    select 'Stary wyga' as Experience, y as all_fights;
else select 'Młodziak'as Experience, y as all_fights;
end if ;


end $$

call fighter_experience(1326)


/*2. **Procedura sprawdzająca rekord zawodnika**:
  Stwórz procedurę, która przyjmuje ID zawodnika i zwraca jego rekord wygranych i przegranych.
  Użyj wyrażeń warunkowych do określenia, czy zawodnik ma więcej wygranych niż przegranych,
  i na tej podstawie zwróć odpowiedni komunikat.*/

select count(r_fighter_id) from ufc_fights where winner = 'Red' and r_fighter_id = 1652 or winner = 'Blue' and b_fighter_id = 1652;


delimiter $$
drop procedure if exists win_lose;
create procedure win_lose(in fid int)
begin
    declare y int;
    declare x int;
select count(r_fighter_id) into y from ufc_fights where  winner = 'Red' and r_fighter_id = fid or winner = 'Blue' and b_fighter_id = fid;
select count(r_fighter_id) into x from ufc_fights where  winner = 'Red' and b_fighter_id = fid or winner = 'Blue' and r_fighter_id = fid;

if y > x then
    select y as wins, x as loses, 'More wins';
elseif y < x then
    select y as wins, x as loses, 'More loses';
else select y as wins, x as loses, 'draw';
end if;

end $$

call win_lose(109);


/*3. **Procedura aktualizująca status zawodnika**:
  Stwórz procedurę, która aktualizuje status zawodnika na podstawie jego ostatnich pięciu walk. Jeśli wygrał co najmniej trzy,
  status powinien być aktualizowany na "Wzrastająca gwiazda".
  Użyj wyrażeń warunkowych do sprawdzenia wyników i zaktualizowania statusu.*/



SELECT * FROM ufc_fights
WHERE r_fighter_id = 134 or b_fighter_id = 134
ORDER BY date DESC
LIMIT 5;


delimiter $$
drop procedure if exists last_5;
create procedure last_5(in fid int)
begin
declare y int;
declare x int;

drop table if exists last_5_fights;
create temporary table last_5_fights
SELECT * FROM ufc_fights
WHERE r_fighter_id = fid or b_fighter_id = fid
ORDER BY date DESC
LIMIT 5;


select count(r_fighter_id) into y from last_5_fights where  winner = 'Red' and r_fighter_id = fid or winner = 'Blue' and b_fighter_id = fid;
select count(r_fighter_id) into x from last_5_fights where  winner = 'Red' and r_fighter_id != fid or winner = 'Blue' and b_fighter_id != fid;

if y > x then
    select y as wins, x as loses, 'He has talent';
elseif y < x then
    select y as wins, x as loses, 'Loooser';
else select y as wins, x as loses, 'draw? in  last 5 cannot be draw';
end if;

end $$


call last_5(1344);


-- TRANSAKCJE

/*1. **Aktualizacja rekordu zawodnika**:
  Stwórz transakcję, która aktualizuje dane takie jak waga czy wzrost dla wybranego zawodnika.
  Transakcja powinna zapewnić, że wszystkie zmiany są spójne i zostaną zapisane tylko wtedy,
  gdy wszystkie operacje się powiodą.*/

select * from ufc_fighters;

DELIMITER $$
DROP PROCEDURE IF EXISTS weight_high_fighter;
CREATE PROCEDURE weight_high_fighter(in fid INT,in height_f int,in height_i int,in weight int)
BEGIN
START TRANSACTION;

update ufc_fighters set height_feet = height_f,height_inches = height_i,weight_pounds =  weight where id = fid;
if row_count() > 0 then
    select 'succes' as result, id, weight_pounds from ufc_fighters where id = fid;
commit ;
    else select 0 as result;
end if;

end; $$


call weight_high_fighter(42,5,2,157);

select * from ufc_fighters where id = 42;



/*2. **Dodawanie nowej walki**:
  Podczas dodawania nowej walki,
  transakcja może obejmować dodanie rekordu walki oraz aktualizację statystyk zawodników.
  Jeżeli którekolwiek z tych działań się nie powiedzie, cała transakcja zostanie cofnięta.*/

drop table if exists tmp_fights;
create temporary table tmp_fights
select r_fighter_id, b_fighter_id,last_round_time, format_rounds, fight_type, location_id, winner from ufc_fights;


delimiter $$
drop procedure if exists new_fight;
create procedure new_fight(in r_id int,in b_id int,in round_time_insec int,in for_rounds int,in f_type varchar(50),in loc_id int,in win varchar(10))
begin
    start transaction ;

    insert into tmp_fights values (r_id, b_id, sec_to_time(round_time_insec), for_rounds, f_type, loc_id, win);
    if row_count() > 0 then
        select * from tmp_fights where r_fighter_id =  r_id and b_fighter_id = b_id ;
    commit ;
    else select 'nie wyszło';
end if;
end $$

call new_fight(134, 2217,319, 3, 'UFC Welterweight', 41, 'Red');


select *
from tmp_fights where r_fighter_id = 215;


/*3. **Usuwanie zawodnika**: Usuwanie zawodnika z bazy danych może wymagać usunięcia wszystkich powiązanych z nim walk.
  Transakcja zapewni, że albo wszystkie powiązane rekordy zostaną usunięte, albo żaden, jeśli wystąpią jakieś problemy.*/
drop table if exists copy_fighters;
create  table copy_fighters
select * from ufc_fighters;


delimiter $$
drop procedure if exists drop_fighter;
create procedure drop_fighter(in fid int)
begin
declare y varchar(100);
select fighter_name into y from tmp_copy_fighters where id = fid;
    start transaction ;
delete from tmp_copy_fighters where id = fid;
    if row_count() > 0 then
        delete from tmp_fights where r_fighter_id = fid or b_fighter_id = fid;
            if row_count() > 0 then
             select 'Deleted fighter: ' as fighter, y as fighter_name;
             else select 'Ten zawodnik nie odbył żadnej walki! - został wykreślony z listy zawodników';
             end if;
    else select 'Nie ma takiego zawodnika!';

    end if;

end $$


select * from tmp_copy_fighters where id = 32;
select * from tmp_fights where r_fighter_id = 32 or b_fighter_id = 32;

call drop_fighter(32);


/*5. **Przeniesienie zawodnika do innej kategorii wagowej**:
  Jeśli zawodnik zmienia kategorię wagową, możesz potrzebować zaktualizować jego rekord oraz rekordy jego przyszłych walk.
  Transakcja umożliwi wykonanie tych zmian w sposób atomowy, zapewniając spójność danych.*/

select * from copy_fighters;

alter table copy_fighters
add fight_type varchar(100);


delimiter $$
drop procedure if exists act_fight_type;
create procedure act_fight_type()
begin
declare x int default 1;
declare y double;
declare w double;
declare z int;
select count(id) into z from copy_fighters;
select weight_pounds * 0.45359237 into y from copy_fighters where id = x;


    start transaction;

    loop_fight_type: loop
        if y < 56.7 then
            update copy_fighters set fight_type = 'Waga Musza' where id = x;
        elseif y < 61.2 then
            update copy_fighters set fight_type = 'Waga Kogucia' where id = x;
        elseif y < 65.8 then
            update copy_fighters set fight_type = 'Waga Piórkowa' where id = x;
        elseif y < 70.3 then
            update copy_fighters set fight_type = 'Waga Lekka' where id = x;
        elseif y < 77.1 then
            update copy_fighters set fight_type = 'Waga Półśrednia' where id = x;
        elseif y < 83.9 then
            update copy_fighters set fight_type = 'Waga Średnia' where id = x;
        elseif y < 93.0 then
            update copy_fighters set fight_type = 'Waga Półśrednia' where id = x;
        elseif y < 120.2 then
            update copy_fighters set fight_type = 'Waga Ciężka' where id = x;
        else
            update copy_fighters set fight_type = 'Waga Superciężka' where id = x;
        end if;

        set x= x + 1;


        if x = z + 1 then
            leave loop_fight_type;
        else
            select weight_pounds * 0.45359237 into w from copy_fighters where id = x;
            set y= w;
        end if;
        end loop;
--    select * from copy_fighters;

end $$
call act_fight_type();

select avg(weight_pounds), fight_type from copy_fighters
group by fight_type ;

select *,
       sum(weight_pounds) over (partition by fight_type) as suma_wagi
       from copy_fighters;



