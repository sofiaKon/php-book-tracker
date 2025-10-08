<!DOCTYPE html>
<html lang="ru">

<head>
    <meta charset="utf-8">
    <title>Book Tracker</title>
</head>

<body>

    <body>
        <script type="text/javascript" src="check.js"></script>

        <form name="log" method="post" action="" onsubmit="return joinCheck()">

            Reader name: <input type="text" size="50" name="reader_name"><br><br>
            Book title: <input type="text" size="50" name="title"><br><br>
            Author: <input type="text" size="50" name="author"><br><br>

            Genre:<br>
            <label><input type="checkbox" name="genre[]" value="Fantasy"> Fantasy</label><br>
            <label><input type="checkbox" name="genre[]" value="Romance"> Romance</label><br>
            <label><input type="checkbox" name="genre[]" value="Thriller"> Thriller</label><br>
            <label><input type="checkbox" name="genre[]" value="Science fiction"> Science fiction</label><br>
            <label><input type="checkbox" name="genre[]" value="Horror"> Horror</label><br>
            <label><input type="checkbox" name="genre[]" value="Other"> Other</label><br><br>

            Number of pages you have read: <input type="number" name="pages_read"><br><br>
            Finished date: <input type="date" name="finished_date"><br><br>

            <input type="submit" value="Submit"><br><br>
        </form>
        <?php
        if ($_SERVER["REQUEST_METHOD"] === "POST") {
            $reader_name = trim($_POST["reader_name"] ?? "");
            $title  = trim($_POST["title"] ?? "");
            $author = trim($_POST["author"] ?? "");
            $genreArr = $_POST["genre"] ?? [];
            $pages_read  = max(0, (int)($_POST["pages_read"] ?? 0));
            $finished_date = trim($_POST["finished_date"] ?? "");


            if (!is_array($genreArr)) $genreArr = [$genreArr];
            $genre_str = implode(", ", array_map('trim', $genreArr));

            if ($finished_date === "") $finished_date = null;

            mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
            $con = new mysqli("localhost", "root", "1234", "booktracker");
            $con->set_charset("utf8mb4");



            $con->begin_transaction();
            try {

                $sqlBook = "
            INSERT INTO books AS b (title, author, genre)
            VALUES (?, ?, ?)
            ON DUPLICATE KEY UPDATE
              id    = LAST_INSERT_ID(b.id),
              genre = b.genre            
        ";
                $stmtBook = $con->prepare($sqlBook);
                $stmtBook->bind_param("sss", $title, $author, $genre_str);
                $stmtBook->execute();


                $book_id = $con->insert_id;


                $sqlLog = "
            INSERT INTO reading_log (reader_name, book_id, pages_read, finished_date)
            VALUES (?, ?, ?, ?)
        ";
                $stmtLog = $con->prepare($sqlLog);

                $stmtLog->bind_param("siis", $reader_name, $book_id, $pages_read, $finished_date);
                $stmtLog->execute();

                $con->commit();


                $stmtLog->close();
                $stmtBook->close();
                $con->close();

                echo "OK";
            } catch (Throwable $e) {
                $con->rollback();

                throw $e;
            }
        }
        ?>
    </body>

</html>