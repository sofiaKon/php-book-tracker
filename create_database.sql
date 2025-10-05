CREATE DATABASE booktracker CHARACTER SET utf8mb4;
USE booktracker;

CREATE TABLE books (
  book_id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  author VARCHAR(255) NOT NULL,
  genre VARCHAR(100) NOT NULL,
  pages INT NOT NULL,
  UNIQUE KEY uk_books_title (title),
   KEY idx_books_genre (genre)
) ENGINE=InnoDB;


CREATE TABLE reading_log (
  log_id INT AUTO_INCREMENT PRIMARY KEY,
  reader_name VARCHAR(100) NOT NULL,
  book_id INT NOT NULL,
  finished_date DATE NOT NULL,
  CONSTRAINT fk_log_book FOREIGN KEY (book_id) REFERENCES books(book_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  UNIQUE KEY uq_reader_book_date (reader_name, book_id, finished_date), -- защита от точного дубля
  KEY idx_log_reader (reader_name),
  KEY idx_log_date (finished_date)
) ENGINE=InnoDB;


INSERT INTO books (title, author, genre, pages) VALUES
('Harry Potter and the Philosopher''s Stone', 'J.K. Rowling', 'Fantasy', 309),
('The Witcher: The Last Wish', 'Andrzej Sapkowski', 'Fantasy', 288),
('Summer in a Pioneer Tie', 'Elena Malisova; Katerina Silvanova', 'Romance', 410),
('Dune', 'Frank Herbert', 'Science fiction', 604),
('Roadside Picnic (S.T.A.L.K.E.R.)', 'Arkady Strugatsky; Boris Strugatsky', 'Science fiction', 260),
('The Foxhole Court', 'Nora Sakavic', 'Thriller', 345),
('Metro 2033', 'Dmitry Glukhovsky', 'Science fiction', 460),
('The Master and Margarita', 'Mikhail Bulgakov', 'Fantasy', 480),
('The Lord of the Rings: The Fellowship of the Ring', 'J.R.R. Tolkien', 'Fantasy', 423),
('Five Nights at Freddy''s: The Silver Eyes', 'Scott Cawthon; Kira Breed-Wrisley', 'Horror', 370),

('1984', 'George Orwell', 'Thriller', 328),
('Crime and Punishment', 'Fyodor Dostoevsky', 'Thriller', 545),
('Three Comrades', 'Erich Maria Remarque', 'Romance', 455),
('Martin Eden', 'Jack London', 'Romance', 490),
('Flowers for Algernon', 'Daniel Keyes', 'Science fiction', 310),
('The Little Prince', 'Antoine de Saint-Exupéry', 'Fantasy', 112),
('The Alchemist', 'Paulo Coelho', 'Romance', 208),
('The Picture of Dorian Gray', 'Oscar Wilde', 'Thriller', 252),
('The Catcher in the Rye', 'J.D. Salinger', 'Other', 277),
('A Game of Thrones', 'George R.R. Martin', 'Fantasy', 694),

('Atlas Shrugged', 'Ayn Rand', 'Other', 1168),
('The Shadow of the Wind', 'Carlos Ruiz Zafón', 'Thriller', 487),
('Night Watch', 'Sergey Lukyanenko', 'Fantasy', 460),
('War and Peace', 'Leo Tolstoy', 'Other', 1225),
('Heart of a Dog', 'Mikhail Bulgakov', 'Other', 160),
('Anna Karenina', 'Leo Tolstoy', 'Romance', 864),
('American Gods', 'Neil Gaiman', 'Fantasy', 624),
('Brave New World', 'Aldous Huxley', 'Science fiction', 311),
('The Doomed City', 'Arkady Strugatsky; Boris Strugatsky', 'Science fiction', 420),
('Sherlock Holmes: A Study in Scarlet', 'Arthur Conan Doyle', 'Thriller', 188)
ON DUPLICATE KEY UPDATE pages = VALUES(pages); -- на случай повторного запуска



INSERT INTO reading_log (reader_name, book_id, pages_read, finished_date)
VALUES
('LunaFox',       (SELECT book_id FROM books WHERE title='Harry Potter and the Philosopher''s Stone'), 309, '2024-01-14'),
('NightOwl',      (SELECT book_id FROM books WHERE title='The Witcher: The Last Wish'),                 288, '2024-01-28'),
('SkyDreamer',    (SELECT book_id FROM books WHERE title='Summer in a Pioneer Tie'),                     410, '2024-02-05'),
('LunaFox',       (SELECT book_id FROM books WHERE title='Dune'),                                        604, '2024-02-22'),
('DataWolf',      (SELECT book_id FROM books WHERE title='Roadside Picnic (S.T.A.L.K.E.R.)'),            260, '2024-03-01'),
('BookWhale',     (SELECT book_id FROM books WHERE title='The Foxhole Court'),                           345, '2024-03-15'),
('PixelSoul',     (SELECT book_id FROM books WHERE title='Metro 2033'),                                  460, '2024-03-27'),
('DreamWeaver',   (SELECT book_id FROM books WHERE title='The Master and Margarita'),                    480, '2024-04-10'),
('LunaFox',       (SELECT book_id FROM books WHERE title='The Lord of the Rings: The Fellowship of the Ring'), 423, '2024-04-20'),
('Starling',      (SELECT book_id FROM books WHERE title='Five Nights at Freddy''s: The Silver Eyes'),   370, '2024-05-02'),

('BookWhale',     (SELECT book_id FROM books WHERE title='1984'),                                        328, '2024-05-18'),
('SkyDreamer',    (SELECT book_id FROM books WHERE title='Crime and Punishment'),                         545, '2024-06-01'),
('LunaFox',       (SELECT book_id FROM books WHERE title='Three Comrades'),                               455, '2024-06-10'),
('PixelSoul',     (SELECT book_id FROM books WHERE title='Martin Eden'),                                  490, '2024-06-25'),
('NightOwl',      (SELECT book_id FROM books WHERE title='Flowers for Algernon'),                         310, '2024-07-05'),
('DreamWeaver',   (SELECT book_id FROM books WHERE title='The Little Prince'),                            112, '2024-07-14'),
('DataWolf',      (SELECT book_id FROM books WHERE title='The Alchemist'),                                208, '2024-07-23'),
('Starling',      (SELECT book_id FROM books WHERE title='The Picture of Dorian Gray'),                   252, '2024-08-01'),
('NightOwl',      (SELECT book_id FROM books WHERE title='The Catcher in the Rye'),                       277, '2024-08-11'),
('DreamWeaver',   (SELECT book_id FROM books WHERE title='A Game of Thrones'),                            694, '2024-08-25'),

('PixelSoul',     (SELECT book_id FROM books WHERE title='Atlas Shrugged'),                              1168, '2024-09-02'),
('SkyDreamer',    (SELECT book_id FROM books WHERE title='The Shadow of the Wind'),                       487, '2024-09-14'),
('BookWhale',     (SELECT book_id FROM books WHERE title='Night Watch'),                                  460, '2024-09-25'),
('DataWolf',      (SELECT book_id FROM books WHERE title='War and Peace'),                               1225, '2024-10-06'),
('NightOwl',      (SELECT book_id FROM books WHERE title='Heart of a Dog'),                               160, '2024-10-15'),
('DreamWeaver',   (SELECT book_id FROM books WHERE title='Anna Karenina'),                                864, '2024-10-27'),
('LunaFox',       (SELECT book_id FROM books WHERE title='American Gods'),                                624, '2024-11-05'),
('PixelSoul',     (SELECT book_id FROM books WHERE title='Brave New World'),                               311, '2024-11-18'),
('Starling',      (SELECT book_id FROM books WHERE title='The Doomed City'),                               420, '2024-11-25'),
('SkyDreamer',    (SELECT book_id FROM books WHERE title='Sherlock Holmes: A Study in Scarlet'),          188, '2024-12-03');



/* Add new book */


INSERT INTO books (title, author, genre, pages)
VALUES ('The Hobbit', 'J.R.R. Tolkien', 'Fantasy', 310)
ON DUPLICATE KEY UPDATE book_id = LAST_INSERT_ID(book_id);

SET @book_id := LAST_INSERT_ID();


INSERT INTO reading_log (reader_name, book_id, pages_read, finished_date)
VALUES ('LunaFox', @book_id, 310, '2024-12-12');



