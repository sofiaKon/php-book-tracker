-- Book Tracker — Basic Analytics (MySQL/MariaDB)
-- This file contains baseline analytical queries for the `bookinsert` table.
-- Expected columns (at minimum):
--   id, reader, title, author, genre, pages, finished_date, added_at
-- Optional generated columns:
--   title_norm = LOWER(TRIM(title)), reader_norm = LOWER(TRIM(reader))
-- Notes:
--   * These queries are read-only and safe to run.
--   * Replace LIMIT values as you wish.
--   * `genre` is stored as a comma-separated string. For precise genre analytics,
--     consider a junction table; here we show string-based approaches.


-- Book Tracker — базовая аналитика (MySQL/MariaDB)
-- Этот файл содержит базовые аналитические запросы для таблицы `bookinsert`.
-- Ожидаемые столбцы (минимум):
--   id, reader, title, author, genre, pages, finished_date, added_at
-- Необязательные вычисляемые столбцы:
--   title_norm = LOWER(TRIM(title)), reader_norm = LOWER(TRIM(reader))
-- Примечания:
--   * Эти запросы только для чтения и безопасны для выполнения.
--   * При необходимости меняйте значения LIMIT.
--   * `genre` хранится как строка со значениями, разделёнными запятой. Для точной аналитики по жанрам
--     рассмотрите использование таблицы-связки; здесь показаны строковые подходы.

/* ---------------------------------------------------------
   1) Monthly reading activity (books + pages + average pages)
    Ежемесячная статистика чтения (количество книг, страниц и среднее число страниц).
   --------------------------------------------------------- */
SELECT
      DATE_FORMAT(rl.finished_date, '%Y-%m')AS ym,
      COUNT(*)                            AS sessions,
      COALESCE(SUM(rl.pages_read), 0)     AS pages_sum,
      ROUND(AVG(rl.pages_read), 1)        AS pages_avg
FROM reading_log rl
GROUP BY ym
ORDER BY ym



/* ---------------------------------------------------------
   2) Reader activity (books & pages per reader).
   Активность по читателям (число книг и страниц на каждого читателя).
   --------------------------------------------------------- */
SELECT
      COALESCE(b.author, 'Unknown')       AS author,
      COALESCE(SUM(rl.pages_read),0)      AS pages_sum
FROM reading_log rl
LEFT JOIN books b 
ON b.book_id = rl.book_id   
GROUP BY author
ORDER BY pages_sum DESC, author
LIMIT 20;

/* ---------------------------------------------------------
   3) Page-count buckets (distribution).
   Диапазоны количества страниц (распределение).
   --------------------------------------------------------- */
SELECT
      CASE
        WHEN pages IS NULL THEN 'unknown'
        WHEN pages < 150 THEN '<150'
        WHEN pages < 300 THEN '150–299'
        WHEN pages < 500 THEN '300–499'
        ELSE '500+'
      END AS bucket,
    COUNT(*)                              AS books
FROM books
GROUP BY bucket
ORDER BY
      CASE bucket
        WHEN 'unknown' THEN 0
        WHEN '<150' THEN 1
        WHEN '150–299' THEN 2
        WHEN '300–499' THEN 3
        ELSE 4
      END;

/* ---------------------------------------------------------
   4) Genre counts (string-based; genre stored as CSV)
   - Removes spaces and uses FIND_IN_SET.
   - Examples shown for common genres; add more as needed.
   Подсчёт по жанрам (строковый подход; жанры хранятся как CSV)
    - Удаляются пробелы и используется функция FIND_IN_SET.
    - Примеры приведены для распространённых жанров; при необходимости добавьте другие.
   --------------------------------------------------------- */
-- Total rows that have ANY genre at all
SELECT 
      COUNT(*)                          AS with_any_genre
FROM books
WHERE COALESCE(TRIM(genre), '') <> '';

-- One row per configured genre (Fantasy, Romance, Thriller, Science fiction, Horror, Other)
SELECT
      'Fantasy'                         AS genre,
      COUNT(*)                          AS books
FROM books
WHERE FIND_IN_SET('Fantasy', REPLACE(genre, ' ', '')) > 0
UNION ALL
SELECT 
      'Romance',
      COUNT(*) 
FROM books 
WHERE FIND_IN_SET('Romance', REPLACE(genre, ' ', '')) > 0

UNION ALL
SELECT
     'Thriller',
      COUNT(*) 
FROM books 
WHERE FIND_IN_SET('Thriller', REPLACE(genre, ' ', '')) > 0
UNION ALL
SELECT 
      'Sciencefiction', 
      COUNT(*) 
FROM books 
WHERE FIND_IN_SET('Sciencefiction', REPLACE(REPLACE(genre, ' ', ''), '-', '')) > 0
UNION ALL
SELECT 
      'Horror',
      COUNT(*) 
FROM books 
WHERE FIND_IN_SET('Horror', REPLACE(genre, ' ', '')) > 0
UNION ALL
SELECT 
      'Other',      
      COUNT(*) 
FROM books 
WHERE FIND_IN_SET('Other', REPLACE(genre, ' ', '')) > 0;

-- Tip: If your stored genre values contain spaces/dashes (e.g., 'Science fiction'),
-- consider storing canonical values without spaces (e.g., 'ScienceFiction') for easier counting,
-- or normalize genres into a separate table with a many-to-many link.

/* ---------------------------------------------------------
   5) Recently finished books (latest completion per book).
   Недавно завершённые книги (ппоследнее завершение каждой книги).
   --------------------------------------------------------- */
SELECT
      b.book_id, 
      b.title,
      b.author,
      b.genre,
      MAX(rl.finished_date)               AS finished_date
FROM reading_log rl
JOIN books b
ON b.book_id = rl.book_id
WHERE rl.finished_date IS NOT NULL
GROUP BY b.book_id, b.title, b.author, b.genre
ORDER BY finished_date DESC
LIMIT 10;


/* ---------------------------------------------------------
   6) Duplicate checks (should be empty if UNIQUE(title_norm), UNIQUE(reader_norm) exist).
   Проверка дубликатов (должно быть пусто, если существуют UNIQUE(title_norm) и UNIQUE(reader_norm)).
   --------------------------------------------------------- */
-- Possible duplicates by title (case-insensitive)
SELECT 
      LOWER(TRIM(title))                  AS t,
      COUNT(*)                            AS c
FROM books
GROUP BY t
HAVING c > 1;


/* ---------------------------------------------------------
   7) Views for quick reporting.
   Представления для быстрых отчётов.
   --------------------------------------------------------- */
-- Monthly activity view
CREATE OR REPLACE VIEW v_monthly_activity AS
SELECT
    DATE_FORMAT(rl.finished_date, '%Y-%m')AS ym,
    COUNT(*)                              AS sessions,
    COALESCE(SUM(rl.pages_read), 0)       AS pages_sum,
    ROUND(AVG(rl.pages_read), 1)          AS pages_avg
FROM reading_log rl
WHERE finished_date IS NOT NULL
GROUP BY ym
  

-- Reader totals view
CREATE OR REPLACE VIEW v_reader_totals    AS
SELECT
      reader_name,
      COUNT(*)                            AS book,
      SUM(pages_read)                     AS pages_sum,
      MIN(finished_date)                  AS first_finished,
      MAX(finished_date)                  AS last_finished
FROM reading_log
GROUP BY reader_name;

/* ---------------------------------------------------------
   8) Examples of using the views.
   Примеры использования представлений.
   --------------------------------------------------------- */
SELECT * FROM v_monthly_activity ORDER BY ym;
SELECT * FROM v_reader_totals ORDER BY pages_sum DESC, book DESC;