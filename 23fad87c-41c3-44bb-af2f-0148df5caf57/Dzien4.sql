use sakila3_87;

DELIMITER $$
CREATE PROCEDURE delta_example(IN p_delta DOUBLE)
BEGIN
    IF p_delta > 0 THEN
        SELECT 'Równanie ma dokładnie dwa rozwiązania';
    ELSEIF p_delta = 0 THEN
        SELECT 'Równanie ma jedno rozwiązanie';
    ELSE
        SELECT 'Równanie nie ma rozwiązania w liczbach rzeczywistych';
    END IF;
END;$$

-- Przykład wywołania
CALL delta_example(-1);
CALL delta_example(0);
CALL delta_example(10);


--

sELECT
    *
    , CASE
        WHEN films_amount > 20 THEN 'SUPER POPULAR'
        WHEN films_amount BETWEEN 10 AND 20 THEN 'POPULAR'
        WHEN films_amount < 10 THEN 'LOW POPULAR'
        ELSE 'ERROR'
    END AS how_popular
FROM actor_analytics;



-- TRANSAKCJE
-- Przygotowanie danych
DROP TABLE IF EXISTS examples.pln_acc;
CREATE TABLE examples.pln_acc (bal_pln numeric);
INSERT INTO examples.pln_acc VALUES (500);

DROP TABLE IF EXISTS examples.eur_acc;
CREATE TABLE examples.eur_acc (bal_eur numeric);
INSERT INTO examples.eur_acc VALUES (0);

-- Wykonanie transakcji
DELIMITER $$
DROP PROCEDURE IF EXISTS transfer;
CREATE PROCEDURE transfer()  -- tworzymy procedurę
BEGIN  -- rozpoczynamy procedurę
START TRANSACTION; -- rozpoczynamy transakcję
UPDATE examples.pln_acc SET bal_pln = bal_pln - 200 WHERE bal_pln>=200; -- aktualizujemy stan konta
IF ROW_COUNT() > 0 THEN  -- sprawdzamy, czy został zaktualizowany wiersz
  UPDATE examples.eur_acc SET bal_eur = bal_eur+50;  -- aktualizujemy saldo
  COMMIT;  -- zatwierdzamy transakcję
ELSE
  ROLLBACK; -- w przeciwnym przypadku cofamy
END IF;
END; $$ -- kończymy procedurę

--


DELIMITER $$
  CREATE PROCEDURE even_numbers_using_loop()
  BEGIN
      DECLARE x  INT;
      DECLARE str  VARCHAR(255);
      SET x = 1, str =  '';

      loop_label:  LOOP
          IF  x > 10 THEN
              LEAVE  loop_label;
          END  IF;

          SET  x = x + 1;
          IF  (x mod 2) THEN
              ITERATE  loop_label;
          ELSE
              SET  str = CONCAT(str,x,',');
          END  IF;
      END LOOP;
      SELECT str;
  END$$
  DELIMITER;


call even_numbers_using_loop()


-- KURSOR

DELIMITER $$
-- tutaj potrzebujemy dużej liczby aby zmieścić złożone imiona do jednej zmiennej
drop procedure if exists cursor_example;
CREATE PROCEDURE cursor_example(INOUT p_customers varchar(16000))
BEGIN
  DECLARE finished INTEGER DEFAULT 0;
  DECLARE customer varchar(100) DEFAULT "";

  DECLARE cur_customer
      CURSOR FOR
          SELECT DISTINCT
              CONCAT(first_name, ' ',
                  last_name) as name
          FROM customer;

  DECLARE CONTINUE HANDLER
      FOR NOT FOUND SET finished = 1;
OPEN cur_customer;

  get_customer: LOOP
      FETCH cur_customer INTO customer;

      IF finished = 1 THEN
          LEAVE get_customer;
      END IF;

      SET p_customers =
          concat(customer, ';', p_customers);
  END LOOP get_customer;
  CLOSE cur_customer;
END$$
DELIMITER;



SET @customers = '';
call cursor_example(@customers);
select @customers;

