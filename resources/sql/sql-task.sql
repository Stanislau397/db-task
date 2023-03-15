1. Вывести к каждому самолету класс обслуживания и количество мест этого класса

SELECT ad.aircraft_code  AS aircraft_code,
       ad.model::json->'en' AS model,
       ad.range AS range,
       s.fare_conditions AS fare_conditions,
       COUNT(s.seat_no)  AS seats_amount
FROM aircrafts_data ad
JOIN seats s ON ad.aircraft_code = s.aircraft_code
GROUP BY ad.aircraft_code, s.fare_conditions
ORDER BY ad.aircraft_code

2. Найти 3 самых вместительных самолета (модель + кол-во мест)

SELECT ad.model::json->'en' AS model,
       COUNT(s.seat_no) AS seats_amount
FROM aircrafts_data ad
JOIN seats s ON ad.aircraft_code = s.aircraft_code
GROUP BY ad.model
ORDER BY seats_amount DESC
FETCH FIRST 3 ROW ONLY;

3.Вывести код,модель самолета и места не эконом класса для самолета 'Аэробус A321-200' с сортировкой по местам

SELECT ad.aircraft_code AS aircraft_code,
       ad.model::json->'ru' AS model,
       s.fare_conditions AS fare_conditions,
       s.seat_no        AS seat_no
FROM aircrafts_data ad
JOIN seats s ON ad.aircraft_code = s.aircraft_code
WHERE ad.model ->>'ru' = 'Аэробус A321-200'
AND s.fare_conditions != 'Economy'
ORDER BY s.seat_no

4.Вывести города в которых больше 1 аэропорта ( код аэропорта, аэропорт, город)

SELECT ad.airport_code AS airport_code,
       ad.airport_name AS airport_name,
       ad.city         AS city
FROM airports_data ad
WHERE ad.city = ANY (
    SELECT ad.city
    FROM airports_data ad
    GROUP BY ad.city
    HAVING COUNT(ad.airport_code) > 1
)

5. Найти ближайший вылетающий рейс из Екатеринбурга в Москву, на который еще не завершилась регистрация

SELECT f.flight_id           AS flight_id,
       f.flight_no           AS flight_no,
       f.scheduled_departure AS scheduled_departure,
       f.scheduled_arrival   AS scheduled_arrival,
       f.departure_airport   AS departure_airport,
       f.arrival_airport     AS arrival_airport,
       f.status              AS status,
       f.aircraft_code       AS aircraft_code
FROM flights f
JOIN airports_data da ON f.departure_airport = da.airport_code
JOIN airports_data aa ON f.arrival_airport = aa.airport_code
WHERE da.city->>'ru' = 'Екатеринбург'
AND aa.city->>'ru' = 'Москва'
AND f.status IN ('Scheduled', 'On Time', 'Delayed')
ORDER BY f.scheduled_departure
FETCH FIRST 1 ROW ONLY

6. Вывести самый дешевый и дорогой билет и стоимость ( в одном результирующем ответе)

(SELECT ticket_no AS ticket_no,
    flight_id AS flight_id,
    fare_conditions AS fare_conditions,
    amount AS amount
    FROM ticket_flights
    WHERE amount = (
    SELECT MIN (amount)
    FROM ticket_flights
) FETCH FIRST 1 ROW ONLY)
UNION
(SELECT ticket_no AS ticket_no,
    flight_id AS flight_id,
    fare_conditions AS fare_conditions,
    amount AS amount
FROM ticket_flights
WHERE amount = (
    SELECT MAX (amount)
    FROM ticket_flights
) FETCH FIRST 1 ROW ONLY)

7. Написать DDL таблицы Customers , должны быть поля id , firstName, LastName, email , phone.
Добавить ограничения на поля ( constraints)

CREATE TABLE Customers (
id integer PRIMARY KEY,
firstName varchar NOT NULL,
lastName varchar NOT NULL,
email varchar UNIQUE,
phone varchar UNIQUE
)

8. Написать DDL таблицы Orders , должен быть id, customerId, quantity.
Должен быть внешний ключ на таблицу customers + ограничения

CREATE TABLE Orders (
id integer PRIMARY KEY,
customer_id integer NOT NULL
quantity integer DEFAULT 0,
FOREIGN KEY (customer_id) REFERENCES Customers(id)
)

9. Написать 5 insert в эти таблицы

INSERT INTO Customers(id, firstName, lastName, email, phone)
VALUES (1, 'Stanislau', 'Kachan', '123@gamil.com', '111 11 111-11-11'),
       (2, 'Vladislau', 'Sobolev', '234@gmail.com', '222 22 222-22-22'),
       (3, 'Hanna', 'Pashkevich', '345@gmail.com', '333 33 333-33-33'),
       (4, 'Ilya', 'Provornov', '456@gmail.com', '444 44 444-44-44'),
       (5, 'Anastasya', 'Serebrekova', '567@gmail.com', '555 55 555-55-55')

INSERT INTO Orders (id, customer_id, quantity)
VALUES (1, 1, 1),
       (2, 2, 3),
       (3, 3, 2),
       (4, 4, 10),
       (5, 5, 4)

10. удалить таблицы

DROP TABLE Orders
DROP TABLE Customers

11. Написать свой кастомный запрос ( rus + sql)

Вывести (Информацию о рейсе + количество проданных билетов) для каждого рейса из Санкт-Петербурга в Москву
и сортировкой по проданным билетам в обратном порядке

SELECT f.flight_id           AS flight_id,
       f.flight_no           AS flight_no,
       f.scheduled_departure AS scheduled_departure,
       f.scheduled_arrival   AS scheduled_arrival,
       f.departure_airport   AS departure_airport,
       f.arrival_airport     AS arrival_airport,
       f.status              AS status,
       COUNT(tf.ticket_no)   AS sold_tickets
FROM ticket_flights tf
JOIN flights f ON tf.flight_id = f.flight_id
JOIN airports_data departure ON f.departure_airport = departure.airport_code
JOIN airports_data arrival ON f.arrival_airport = arrival.airport_code
WHERE departure.city->>'ru' = 'Санкт-Петербург'
AND arrival.city->>'ru' = 'Москва'
GROUP BY f.flight_id
ORDER BY sold_tickets DESC