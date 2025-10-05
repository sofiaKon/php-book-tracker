<p align="right">🌐 Languages: <b>English</b> · <a href="README_ko.md">한국어</a></p>

# Book Tracker — PHP/SQL Analitics

# Book Tracker — PHP/SQL Analytics

The project focuses on **queries and reports** for the `bookinsert` table. PHP is used as a lightweight layer for input/output and Chart.js charts.

## Repository contents
- `index.php` — book submission form.
- `output_list.php` — book list (simple table).
- `book_edit.php` — edit an existing record. *(In progress)*
- `stats.php` — charts page (Chart.js), builds reports directly from the DB.
- `check.js` — client-side input validation.
- `analytics.sql` — a set of basic analytical SQL queries (+ a couple of views).
- `README.md` — this file.

## Requirements
- XAMPP (PHP 8.x + MariaDB/MySQL), phpMyAdmin.
- The `bookinsert` table already exists and is being populated.  
  > If your DB name differs from the examples, just substitute your own.

## Quick start
1. The scripts use a connection like:
   ```php
   new mysqli('localhost', 'root', '1234', 'booktracker');

2. Import the analytical queries.
Open phpMyAdmin → select your DB → Import → choose analytics.sql → Go.
Alternative (CLI):
"C:\xampp\mysql\bin\mysql.exe" -u root -p your_db < "C:\Path\analytics.sql"

3. Verify input/output.

http://localhost/index.php — add records

http://localhost/output_list.php — list

http://localhost/stats.php — charts

## What stats.php shows (In progress)
Monthly activity — books/pages/average per month.
Top authors — top authors by number of books.
Genre breakdown — distribution by genres (the genre field is stored as CSV).

## Data & assumptions

Genres are stored as a comma-separated string (e.g., Fantasy, Romance).
This is sufficient for simple reports.

Duplicate protection is implemented on the client side (JS).
If desired, you can enable DB-level uniqueness via *_norm — not required to run.

## Features 

-- Adding books with details:
Reader name
Book title
Author
Genre
Page count
Finished date

## Tech stack
PHP 8.x
MySQL (via XAMPP)
phpMyAdmin

JavaScript / Chart.js
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
