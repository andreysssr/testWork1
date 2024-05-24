--- ==============================================
--- Создание 4 таблиц категории, товары, статистика, заказы
--- ==============================================

CREATE TABLE categories
(
    id   SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE products
(
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(255) NOT NULL,
    price       INTEGER      NOT NULL,
    category_id INTEGER      NOT NULL
);

CREATE TABLE statistics
(
    id           SERIAL PRIMARY KEY,
    category_id  INTEGER      NOT NULL,
    product_id   INTEGER      NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    quantity     INTEGER      NOT NULL,
    order_date   DATE         NOT NULL
);

ALTER TABLE statistics
    ADD CONSTRAINT statistics_key UNIQUE (category_id, product_id, order_date);

CREATE TABLE orders
(
    id           SERIAL PRIMARY KEY,
    category_id  INTEGER      NOT NULL,
    product_id   INTEGER      NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    quantity     INTEGER      NOT NULL
);


--- ==============================================
--- В таблице Заказы добавить колонку с временем покупки
--- ==============================================

ALTER TABLE orders
    ADD COLUMN order_date DATE DEFAULT CURRENT_DATE NOT NULL;


--- ==============================================
--- Вставка тестовых данных в таблицы
--- ==============================================

INSERT INTO categories (id, name)
VALUES (1, 'Компьютерная техника'),
       (2, 'Офис и канцелярия'),
       (3, 'Мелкая бытовая техника');

INSERT INTO products (id, name, price, category_id)
VALUES (1, 'Кухонный комбайн KitchenAid 5KSM156', 71, 3),
       (2, 'Видеокарта Asus GeForce GT 1030', 29, 1),
       (3, 'Ноутбук HP ENVY 13-ad000', 486, 1),
       (4, 'Фен Dewal 03-401', 124, 3),
       (5, 'Кофеварка Gastrorag CM-717', 225, 3);


--- ==============================================
-- Написать триггер на таблицу с заказами:
-- при добавлении новой строки в таблицу с заказами,
-- собирать статистику сколько товаров и какой категории было куплено за день.
--- ==============================================

CREATE OR REPLACE FUNCTION statistics_calculate_to_inserted_orders_fnc()
  RETURNS trigger AS
$$
DECLARE
BEGIN

UPDATE statistics SET quantity = quantity + NEW."quantity"
WHERE category_id = NEW.category_id
  AND product_id = NEW.product_id
  AND order_date = NEW.order_date;
IF NOT FOUND THEN
    INSERT INTO statistics (category_id, product_id, product_name, quantity, order_date)
    VALUES (NEW.category_id, NEW.product_id, NEW.product_name, NEW.quantity, NEW.order_date);
END IF;

RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';

CREATE TRIGGER statistics_calculate_to_inserted_orders_trigger
    AFTER INSERT
    ON orders
    FOR EACH ROW
    EXECUTE PROCEDURE statistics_calculate_to_inserted_orders_fnc();


--- ==============================================
--- Тестовые данные для вставки в таблицу заказы
--- ==============================================

-- INSERT INTO orders (category_id, product_id, product_name, quantity, order_date)
-- VALUES (1, 2, 'Видеокарта Asus GeForce GT 1030', 1, '2020-08-1');
--
-- INSERT INTO orders (category_id, product_id, product_name, quantity, order_date)
-- VALUES (1, 2, 'Видеокарта Asus GeForce GT 1030', 2, '2020-08-1');
--
-- INSERT INTO orders (category_id, product_id, product_name, quantity, order_date)
-- VALUES (1, 2, 'Видеокарта Asus GeForce GT 1030', 2, '2020-08-1');
--
-- -- Видеокарта Asus GeForce GT 1030 - 5 шт. (2020-08-1)
--
--
-- INSERT INTO orders (category_id, product_id, product_name, quantity, order_date)
-- VALUES (1, 2, 'Видеокарта Asus GeForce GT 1030', 2, '2020-08-2');
--
-- INSERT INTO orders (category_id, product_id, product_name, quantity, order_date)
-- VALUES (1, 2, 'Видеокарта Asus GeForce GT 1030', 1, '2020-08-2');
--
-- -- Видеокарта Asus GeForce GT 1030 - 3 шт. (2020-08-2)
--
--
-- INSERT INTO orders (category_id, product_id, product_name, quantity, order_date)
-- VALUES (1, 2, 'Видеокарта Asus GeForce GT 1030', 1, '2020-08-3');
--
-- -- Видеокарта Asus GeForce GT 1030 - 1 шт. (2020-08-3)
--
--
-- INSERT INTO orders (category_id, product_id, product_name, quantity, order_date)
-- VALUES (3, 4, 'Фен Dewal 03-401', 1, '2020-08-1');
--
-- INSERT INTO orders (category_id, product_id, product_name, quantity, order_date)
-- VALUES (3, 4, 'Фен Dewal 03-401', 6, '2020-08-1');
--
-- -- Фен Dewal 03-401 - 7 шт. (2020-08-1)
--
--
-- INSERT INTO orders (category_id, product_id, product_name, quantity, order_date)
-- VALUES (3, 4, 'Фен Dewal 03-401', 5, '2020-08-2');
--
-- INSERT INTO orders (category_id, product_id, product_name, quantity, order_date)
-- VALUES (3, 4, 'Фен Dewal 03-401', 3, '2020-08-2');
--
-- -- Фен Dewal 03-401 - 8 шт. (2020-08-2)
--
--
-- INSERT INTO orders (category_id, product_id, product_name, quantity, order_date)
-- VALUES (3, 4, 'Фен Dewal 03-401', 1, '2020-08-3');
--
-- INSERT INTO orders (category_id, product_id, product_name, quantity, order_date)
-- VALUES (3, 4, 'Фен Dewal 03-401', 1, '2020-08-3');
--
-- INSERT INTO orders (category_id, product_id, product_name, quantity, order_date)
-- VALUES (3, 4, 'Фен Dewal 03-401', 3, '2020-08-3');
--
-- -- Фен Dewal 03-401 - 5 шт. (2020-08-3)


--- ==============================================
--- Таблица statistics
--- ==============================================

-- Видеокарта Asus GeForce GT 1030 (2020-08-1) - 5 шт.
-- Видеокарта Asus GeForce GT 1030 (2020-08-2) - 3 шт.
-- Видеокарта Asus GeForce GT 1030 (2020-08-3) - 1 шт.
-- Фен Dewal 03-401 (2020-08-1) - 7 шт.
-- Фен Dewal 03-401 (2020-08-2) - 8 шт.
-- Фен Dewal 03-401 (2020-08-3) - 5 шт.
