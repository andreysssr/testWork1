--- ==============================================
--- Создание 4 таблиц категории, товары, статистика, заказы
--- ==============================================

CREATE TABLE categories
(
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE products
(
    id  SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price INTEGER NOT NULL,
    category_id INTEGER NOT NULL
);

CREATE TABLE statistics
(
    id SERIAL PRIMARY KEY,
    category_id INTEGER NOT NULL,
    products_id INTEGER NOT NULL,
    products_name VARCHAR(255) NOT NULL,
    quantity INTEGER NOT NULL,
    orders_date DATE NOT NULL
);

ALTER TABLE statistics
    ADD CONSTRAINT statistics_key UNIQUE (category_id, products_id, orders_date);

CREATE TABLE orders
(
    id SERIAL PRIMARY KEY,
    category_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    quantity INTEGER NOT NULL
);

--- ==============================================
--- В таблице Заказы добавить колонку с временем покупки
--- ==============================================
ALTER TABLE orders ADD COLUMN order_date DATE DEFAULT CURRENT_DATE NOT NULL;

--- ==============================================
-- Написать триггер на таблицу с заказами:
-- при добавлении новой строки в таблицу с заказами,
-- собирать статистику сколько товаров и какой категории было куплено за день.
--- ==============================================

-- Образец тригера для MySQL
-- DELIMITER $$
-- CREATE TRIGGER calc_statistics_insert_to_orders AFTER INSERT ON orders
--     FOR EACH ROW
-- BEGIN
--     -- Получаем дату заказа
--     DECLARE var_order_date DATE;
--     SET var_order_date = DATE(NEW.order_date);
--
--     INSERT INTO statistics (category_id, product_id, product_name, quantity, orders_date)
--         (SELECT category_id, product_id, product_name, SUM(quantity), orders_date
--          FROM orders
--          WHERE orders_date = var_order_date)
--         ON CONFLICT (category_id, product_id)
--     DO UPDATE SET quantity = quantity + EXCLUDED.quantity;
-- END $$
-- DELIMITER ;

-- SELECT category_id, product_id, product_name, quantity FROM orders
-- WHERE purchase_date = '2020-08-1'

--- ==============================================
--- Вставка тестовых данных в таблицы
--- ==============================================
INSERT INTO categories (id, name)
VALUES
    (1, 'Компьютерная техника'),
    (2, 'Офис и канцелярия'),
    (3, 'Мелкая бытовая техника');

INSERT INTO products (id, name, price, category_id)
VALUES
    (1, 'Кухонный комбайн KitchenAid 5KSM156', 71, 3),
    (2, 'Видеокарта Asus GeForce GT 1030', 29, 1),
    (3, 'Ноутбук HP ENVY 13-ad000', 486, 1),
    (4, 'Фен Dewal 03-401', 124, 3),
    (5, 'Кофеварка Gastrorag CM-717', 225, 3);

--- ==============================================
--- Вставка тестовых данных в таблицу заказы
--- ==============================================
    INSERT INTO orders (category_id, product_id, product_name, quantity, order_date)
    VALUES (1, 2, 'Видеокарта Asus GeForce GT 1030', 1, '2020-08-1');

--     INSERT INTO orders (category_id, product_id, product_name, quantity)
--     VALUES (1, 2, 'Видеокарта Asus GeForce GT 1030', 4, '2020-08-2');
--
--     INSERT INTO orders (category_id, product_id, product_name, quantity)
--     VALUES (1, 2, 'Видеокарта Asus GeForce GT 1030', 3, '2020-08-2');


-- Написать триггер sql postgres на таблицу с заказами:
-- при добавлении новой строки в таблицу с заказами, собирать статистику сколько товаров и какой категории было куплено за день.
-- DELIMITER $$
-- CREATE TRIGGER calc_statistics_insert_to_orders AFTER INSERT ON orders
--     FOR EACH ROW # создать тригер который будет срабатывать после добавления любой строки в таблице (orders)
-- BEGIN
-- UPDATE users SET balance = get_client_balance(NEW.user_id)  # NEW, при первой вставке старого значения (OLD) ещё не существует
-- WHERE id = NEW.user_id;                                     # NEW - новое значение строки
-- END$$
-- DELIMITER ;
--
-- INSERT INTO accounts (user_id, balance) VALUES (4, 10000);

--- ==============================================
--- Решение конфликта вставки
--  https://www.youtube.com/watch?v=bd4fxUeQIN4
--- ==============================================

-- INSERT INTO employee (id, first_name, last_name, gender, email, date_of_birth, country_of_birth)
-- VALUES (3, 'John', 'Doe', 'Male', 'John.Doe@google.com', '2019-12-10', 'Russia')
-- ON CONFLICT (id)
-- DO UPDATE SET email = EXCLUDED.email, first_name = EXCLUDED.first_name;

--- ==============================================
-- INSERT INTO orders (order_date, product_category, product_count) VALUES ('2023-10-26', 'Авто', 1);

-- CREATE TABLE orders
-- (
--     id SERIAL PRIMARY KEY,
--     order_date DATE DEFAULT CURRENT_DATE NOT NULL,
--     product_category TEXT NOT NULL,
--     product_count INTEGER NOT NULL
-- );
--
-- CREATE TABLE order_stats
-- (
--     product_count INTEGER NOT NULL,
--     order_date DATE,
--     category TEXT
-- );
--
-- ---
--
-- CREATE OR REPLACE FUNCTION update_order_stats()
-- RETURNS TRIGGER AS $$
-- DECLARE
--     order_date DATE;
--     product_category TEXT;
--     product_count INTEGER;
-- BEGIN
--     -- Получаем дату заказа
--     order_date := NEW.order_date;
--
--     -- Обновляем статистику по категориям товаров
-- FOR product_category IN SELECT DISTINCT product_category FROM order_items WHERE order_id = NEW.order_id LOOP
--     UPDATE order_stats
--     SET product_count = product_count + 1
--     WHERE order_date = order_date AND category = product_category;
--
-- -- Если записи для категории не существует, создаем новую
-- IF NOT FOUND THEN
--     INSERT INTO order_stats (order_date, category, product_count)
--     VALUES (order_date, product_category, 1);
-- END IF;
-- END LOOP;
--
-- RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;
--
-- CREATE TRIGGER update_order_stats_trigger
--     AFTER INSERT ON orders
--     FOR EACH ROW EXECUTE PROCEDURE update_order_stats();
--
-- **Описание:**
--
-- 1. **Функция `update_order_stats()`:**
--    - Принимает событие триггера и выполняет действия по обновлению статистики.
--    - `order_date` - дата заказа из новой строки.
--    - `product_category` - категория товара из таблицы `order_items`.
--    - `product_count` - количество товаров каждой категории.
--    - **Цикл по категориям:**
--      - Извлекает уникальные категории товаров из `order_items` для текущего заказа.
--      - Обновляет запись в `order_stats` с учетом количества товаров каждой категории.
--      - Если записи для категории не существует, создает новую запись.
-- 2. **Триггер `update_order_stats_trigger`:**
--    - Вызывается после добавления новой строки в таблицу `orders`.
--    - Выполняет функцию `update_order_stats()` для каждой добавленной строки.
--
-- **Структура таблиц:**
--
-- - `orders`: Таблица заказов (должна содержать столбец `order_date`).
-- - `order_items`: Таблица с товарами в заказах (должна содержать столбцы `order_id` и `product_category`).
-- - `order_stats`: Таблица для хранения статистики (должна содержать столбцы `order_date`, `category` и `product_count`).
--
-- **Важно:**
--
-- - Убедитесь, что таблицы `orders`, `order_items` и `order_stats` существуют и имеют соответствующие столбцы.
-- - Модифицируйте SQL-запросы и имена столбцов в соответствии с вашим реальным кодом.
-- - Этот триггер предполагает, что в таблице `order_items` для каждого заказа есть записи с товарами.
--
-- **Пример использования:**
--
-- ```sql
-- -- Добавление нового заказа
-- INSERT INTO orders (order_date, customer_id, ...) VALUES ('2023-10-26', 123, ...);
--
-- -- Проверка статистики в order_stats
-- SELECT * FROM order_stats WHERE order_date = '2023-10-26';
-- ```
--
-- Этот триггер будет автоматически обновлять таблицу `order_stats` каждый раз, когда в таблицу `orders` добавляется новый заказ.
--- ==============================================



