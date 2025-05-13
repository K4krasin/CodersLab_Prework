/*Historia udzielanych kredytów
Napisz zapytanie, które przygotuje podsumowanie z udzielanych kredytów w następujących wymiarach:

rok, kwartał, miesiąc,
rok, kwartał,
rok,
sumarycznie.
Jako wynik podsumowania wyświetl następujące informacje:

sumaryczna kwota pożyczek,
średnia kwota pożyczki,
całkowita liczba udzielonych pożyczek.*/


use financial3_87;


select count(loan_id) as wszystkie_pozyczki,
       sum(amount) as Kwota_pozyczki,
       avg(amount) as srednia_kwota,
       year(date) as rok,
       quarter(date) as kwartal,
       month(date) as miesiac
       from loan
group by rok, kwartal, miesiac
with rollup;

/*Na stronie bazy danych możemy znaleźć informację, że w bazie znajdują się w sumie 682 udzielone kredyty,
  z czego 606 zostało spłaconych, a 76 nie.

Załóżmy, że nie posiadamy informacji o tym, który status odpowiada pożyczce spłaconej, a który nie.
  W takiej sytuacji musimy te informacje wywnioskować z danych.

W tym celu napisz kwerendę, za pomocą której spróbujesz odpowiedzieć na pytanie,
  które statusy oznaczają pożyczki spłacone, a które oznaczają pożyczki niespłacone.*/

select count(status), status from loan group by status;


select count(status) as a from loan
         where status = 'B' or status = 'D';


/*Napisz kwerendę, która uszereguje konta według następujących kryteriów:

liczba udzielonych pożyczek (malejąco),
kwota udzielonych pożyczek (malejąco),
średnia kwota pożyczki.
Pod uwagę bierzemy tylko spłacone pożyczki.*/

select count(loan_id) over (PARTITION BY account_id) as xd,
       sum(amount) over (partition by account_id) as xxd,
       avg(amount) over () as xxd
       from loan
       where status = 'A' or status = 'C'
       order by xd ;


/*Sprawdź, saldo pożyczek spłaconych w podziale na płeć klienta.

Dodatkowo w wybrany przez siebie sposób sprawdź, czy kwerenda jest poprawna.*/
drop table if exists tmp_saldo;
create temporary table tmp_saldo
select * from loan
-- join account as a using (account_id)
join disp as d using(account_id)
join client as c using (client_id)
WHERE True
    AND status IN ('A', 'C')
    AND d.type = 'OWNER';

select * from tmp_saldo;


select  sum(amount) as suma, c.gender from loan
join account as a using (account_id)
join disp as d using(account_id)
join client as c using (client_id)
WHERE True
    AND status IN ('A', 'C')
    AND d.type = 'OWNER'
group by c.gender;


select 43256388 + 44425200;
-- 87681588

select sum(distinct(amount)), status from loan where status = 'A' or status = 'C' group by status ;
select 69078372 + 18603216;
-- 87681588

/*Analiza klienta cz. 1
Modyfikując zapytania z zadania dot. spłaconych pożyczek, odpowiedz na poniższe pytania:

kto posiada więcej spłaconych pożyczek – kobiety czy mężczyźni?
jaki jest średni wiek kredytobiorcy w zależności od płci?*/
select avg(datediff('2011-01-01', birth_date)/365) as avg_age, gender
from tmp_saldo group by gender ;


/*Analiza klienta cz. 2
Dokonaj analiz, które odpowiedzą na pytania:

w którym rejonie jest najwięcej klientów,
w którym rejonie zostało spłaconych najwięcej pożyczek ilościowo,
w którym rejonie zostało spłaconych najwięcej pożyczek kwotowo.
Jako klienta wybierz tylko właścicieli kont.*/

drop table if exists tmp_all;
create temporary table tmp_all
select * from loan
-- join account as a using (account_id)
join disp as d using(account_id)
join client as c using (client_id);


select district_id,
       count(client_id) as region,
       count(loan_id) as dada,
       sum(amount) as sum_in_region
       from tmp_all
where type = 'OWNER'
group by district_id order by sum_in_region desc;

/*Analiza klienta cz. 3
Używając kwerendy otrzymanej w poprzednim zadaniu, dokonaj jej modyfikacji w taki sposób, aby wyznaczyć procentowy udział każdego regionu w całkowitej kwocie udzielonych pożyczek.

Przykładowy wynik:*/

with cte as(
select district_id,
       count(district_id) as region,
       count(amount) as dada,
       sum(amount) as sum_in_region
       from tmp_saldo
group by district_id order by sum_in_region desc)
select *,
       sum_in_region / sum(sum_in_region) over () as share from cte
order by share desc;

/*Selekcja klientów
Sprawdź, czy w bazie występują klienci spełniający poniższe warunki:

saldo konta przekracza 1000,
mają więcej niż pięć pożyczek,
są urodzeni po 1990 r.
Przy czym zakładamy, że saldo konta to kwota pożyczki - wpłaty.*/

select * from loan where amount - payments*duration = 0;

select * from client where extract(year from birth_date) 1990;


/*Napisz procedurę, która będzie odświeżać stworzoną przez Ciebie tabelę (możesz nazwać ją np. cards_at_expiration)
zawierającą następujące kolumny:

id klienta,
id_karty,
data wygaśnięcia – załóż, że karta może być aktywna przez 3 lata od wydania,
adres klienta (wystarczy kolumna A3).*/
select * from card;
drop table if exists cards_at_expiration;
create table cards_at_expiration(client_id int, card_id int primary key, date_end date, adress varchar(255));


delimiter $$
drop procedure if exists add_card;
create procedure add_card(in client_id int)
begin

    declare x int;
    declare w int;
    declare y date;
    declare z varchar(255);
    select date_add(current_date, interval 3 year ) into y;
    set x = 1;
    select count(card_id) into w from cards_at_expiration;

    select * from cards_at_expiration;
    add_id_loop: loop
        if w < x then

            leave add_id_loop;
        end if;

            set x = x+1;
    end loop;

    with cte as(
select * from district
join account using (district_id))
select  concat(a2,', ',a3,', ',a4) into z from cte
where account_id = client_id;

    insert into cards_at_expiration values (client_id, x,y,z);
select * from cards_at_expiration;
end;

delimiter;

call add_card(3);

select * from cards_at_expiration;


drop table if exists tmp_addid;
create table tmp_addid(client_id int, card_id int);


with cte as(
select * from district
join account using (district_id))
select  concat(a2,', ',a3,', ',a4) from cte
where account_id = 3;

select * from account
