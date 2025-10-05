<p align="right">🌐 Languages: <b>English</b> · <a href="README_ko.md">한국어</a></p>

# Book Tracker — PHP/SQL Analitics

Фокус проекта — **запросы и отчёты** по таблице `bookinsert`. PHP используется как минимальный слой для ввода/вывода и графиков на Chart.js.

## Состав репозитория
- `index.php` — форма добавления книги.
- `output_list.php` — список книг (простая таблица).
- `book_edit.php` — редактирование существующей записи. (В разработке)
- `stats.php` — страница с графиками (Chart.js), строит отчёты напрямую из БД.
- `check.js` — клиентская валидация формы.
- `analytics.sql` — набор базовых аналитических SQL (+ пары view).
- `README.md` — этот файл.

## Требования
- XAMPP (PHP 8.x + MariaDB/MySQL), phpMyAdmin.
- Таблица `bookinsert` уже существует и наполняется.
  > Если имя БД отличается от примеров — просто подставь своё.

## Быстрый старт
1. В файлах используется подключение вида:
   ```php
   new mysqli('localhost', 'root', '1234', 'booktracker');

2. Импортируй аналитические запросы.
Открой phpMyAdmin → выбери свою БД → Import → файл analytics.sql → Go.
Альтернатива (CLI): "C:\xampp\mysql\bin\mysql.exe" -u root -p your_db < "C:\Path\analytics.sql"

3. Проверь ввод/вывод.
http://localhost/index.php — добавление записей

http://localhost/output_list.php — список

http://localhost/stats.php — графики

## Что показывается в stats.php (В разработке)

Monthly activity — книги/страницы/среднее по месяцам.

Top authors — топ авторов по числу книг.

Genre breakdown — разбивка по жанрам (поле genre хранится как CSV).

## О данных и допущениях

Жанры сохраняются строкой через запятую (напр. Fantasy, Romance).
Для простых отчётов этого достаточно.

Защита от дублей реализуется клиентской проверкой (JS).
При желании можно включить уникальность в БД (*_norm) — не обязательно для запуска.

## Возможности

  Добавление книг с деталями:
  - Имя читателя
  - Название книги
  - Автор
  - Жанр
  - Количество страниц
  - Дата завершения

 ##  Стек технологий

- PHP 8.x
- MySQL (через XAMPP)
- phpMyAdmin
- JavaScript / Chart.js


##  Структура базы данных

```sql
CREATE DATABASE booktracker CHARACTER SET utf8mb4;
USE booktracker;

CREATE TABLE bookinsert (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  reader        VARCHAR(50)  NOT NULL,
  title         VARCHAR(100) NOT NULL,
  author        VARCHAR(100) NULL,
  pages         SMALLINT UNSIGNED NOT NULL,
  finished_date DATE         NULL,
  added_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  genre         VARCHAR(255) NULL,
  title_norm    VARCHAR(255) GENERATED ALWAYS AS (LOWER(title))  STORED NOT NULL,
  reader_norm   VARCHAR(255) GENERATED ALWAYS AS (LOWER(reader)) STORED NOT NULL,
  UNIQUE KEY uniq_title_norm (title_norm),
  UNIQUE KEY uniq_reader_norm (reader_norm)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


Проект создан как учебный и развиваемый.
# php-book-tracker
