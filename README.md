# Тестовое задание

### 1. Задание
- Написать любой скрипт на php,
- который будет выполняться 5 секунд.
- Вшить в этот скрипт защиту от повторного запуска, если он еще не отработал. Использовать Redis.

### 2. Задание
- Создать 4 таблицы на postgres:
  (продукты, категории, статистика, заказы), и заполнить стандартными столбцами на ваш выбор.
- В таблице Заказы добавить колонку с временем покупки.
- Вам необходимо написать триггер на таблицу с заказами: при добавлении новой строки в таблицу с заказами, собирать статистику сколько товаров и какой категории было куплено за день.

---

### 1 Решение:

php скрипт находистся по адресу `public/index.php`

Для запуска кода должны быть установлены:
- Docker
- Docker Compose
- Make

### Команды для управления кода через Make:

```shell
make init   # создаёт образы для запуска контейнеров и запускает контейнеры
make up:    # запускает контейнеры
make down   # останавливает и удаляет контейнеры
make reload # запускает команды (make down) и (make init)
make status # выводит список запущенных сервисов
```
### Команды для управления кода через Docker:
```shell
docker compose build --parallel      # создаёт образы для запуска контейнеров
docker compose up -d                 # запускает контейнеры
docker compose down --remove-orphans # останавливает и удаляет контейнеры
docker ps                            # выводит список запущенных сервисов
```


### Запуск скрипта одновременно в двух раздных вкладках:

![запуск скрипта](./doc/1/start.png)
![повторный запуск](./doc/1/work.png)  

---

### 2 Решение:

Для задания создан дамп sql. При поднятии проекта он загружается в базу данных postgres.

Для доступа к базе данных можно войти в браузере.

![запуск adminer](./doc/2/connect-to-postgres.png)

Сам файл sql находится по адресу:  
`docker/postgres/database/pgsql-backup.sql`

```sql
--- ==============================================
--- Тестовые данные для вставки в таблицу заказы
--- ==============================================

INSERT INTO orders (category_id, product_id, product_name, quantity, order_date)
VALUES (1, 2, 'Видеокарта Asus GeForce GT 1030', 1, '2020-08-1');

INSERT INTO orders (category_id, product_id, product_name, quantity, order_date)
VALUES (1, 2, 'Видеокарта Asus GeForce GT 1030', 2, '2020-08-1');

INSERT INTO orders (category_id, product_id, product_name, quantity, order_date)
VALUES (1, 2, 'Видеокарта Asus GeForce GT 1030', 2, '2020-08-1');

-- Видеокарта Asus GeForce GT 1030 - 5 шт. (2020-08-1)


INSERT INTO orders (category_id, product_id, product_name, quantity, order_date)
VALUES (1, 2, 'Видеокарта Asus GeForce GT 1030', 2, '2020-08-2');

INSERT INTO orders (category_id, product_id, product_name, quantity, order_date)
VALUES (1, 2, 'Видеокарта Asus GeForce GT 1030', 1, '2020-08-2');

-- Видеокарта Asus GeForce GT 1030 - 3 шт. (2020-08-2)


INSERT INTO orders (category_id, product_id, product_name, quantity, order_date)
VALUES (1, 2, 'Видеокарта Asus GeForce GT 1030', 1, '2020-08-3');

-- Видеокарта Asus GeForce GT 1030 - 1 шт. (2020-08-3)


INSERT INTO orders (category_id, product_id, product_name, quantity, order_date)
VALUES (3, 4, 'Фен Dewal 03-401', 1, '2020-08-1');

INSERT INTO orders (category_id, product_id, product_name, quantity, order_date)
VALUES (3, 4, 'Фен Dewal 03-401', 6, '2020-08-1');

-- Фен Dewal 03-401 - 7 шт. (2020-08-1)


INSERT INTO orders (category_id, product_id, product_name, quantity, order_date)
VALUES (3, 4, 'Фен Dewal 03-401', 5, '2020-08-2');

INSERT INTO orders (category_id, product_id, product_name, quantity, order_date)
VALUES (3, 4, 'Фен Dewal 03-401', 3, '2020-08-2');

-- Фен Dewal 03-401 - 8 шт. (2020-08-2)


INSERT INTO orders (category_id, product_id, product_name, quantity, order_date)
VALUES (3, 4, 'Фен Dewal 03-401', 1, '2020-08-3');

INSERT INTO orders (category_id, product_id, product_name, quantity, order_date)
VALUES (3, 4, 'Фен Dewal 03-401', 1, '2020-08-3');

INSERT INTO orders (category_id, product_id, product_name, quantity, order_date)
VALUES (3, 4, 'Фен Dewal 03-401', 3, '2020-08-3');

-- Фен Dewal 03-401 - 5 шт. (2020-08-3)
```

В таблице `statistics` должны быть подсчитаны продажи по дням 
```
Видеокарта Asus GeForce GT 1030    - 5 шт.   (2020-08-1) 
Видеокарта Asus GeForce GT 1030    - 3 шт.   (2020-08-2) 
Видеокарта Asus GeForce GT 1030    - 1 шт.   (2020-08-3)
Фен Dewal 03-401                   - 7 шт.   (2020-08-1)
Фен Dewal 03-401                   - 8 шт.   (2020-08-2)
Фен Dewal 03-401                   - 5 шт.   (2020-08-3)
```













