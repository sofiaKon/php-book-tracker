<!DOCTYPE html>
<html lang="ru">

<head>
    <meta charset="utf-8">
    <title>Book Tracker</title>
</head>

<body>

    <body>
        <script type="text/javascript" src="check.js"></script>

        <form name="bookinsert" method="post" action="" onsubmit="return joinCheck()">

            Reader name: <input type="text" size="50" name="reader"><br><br>
            Book title: <input type="text" size="50" name="title"><br><br>
            Author: <input type="text" size="50" name="author"><br><br>

            Genre:<br>
            <label><input type="checkbox" name="genre[]" value="Fantasy"> Fantasy</label><br>
            <label><input type="checkbox" name="genre[]" value="Romance"> Romance</label><br>
            <label><input type="checkbox" name="genre[]" value="Thriller"> Thriller</label><br>
            <label><input type="checkbox" name="genre[]" value="Science fiction"> Science fiction</label><br>
            <label><input type="checkbox" name="genre[]" value="Horror"> Horror</label><br>
            <label><input type="checkbox" name="genre[]" value="Other"> Other</label><br><br>

            Number of pages: <input type="number" name="pages"><br><br>
            Finished date: <input type="date" name="finished_date"><br><br>

            <input type="submit" value="Submit"><br><br>
        </form>


        <?php
        if ($_SERVER["REQUEST_METHOD"] == "POST") {
            $reader = trim($_POST["reader"] ?? "");
            $title  = trim($_POST["title"] ?? "");
            $author = trim($_POST["author"] ?? "");
            $genreArr = $_POST["genre"] ?? [];
            $pages  = (int)($_POST["pages"] ?? 0);
            $finished_date = $_POST["finished_date"] ?? null;

            $genre_str = implode(", ", $genreArr);

            mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
            $con = new mysqli("localhost", "root", "1234", "booktracker");
            $con->set_charset("utf8mb4");


            $chk = $con->prepare("SELECT id FROM bookinsert WHERE LOWER(title)=LOWER(?) LIMIT 1");
            $chk->bind_param("s", $title);
            $chk->execute();
            if ($chk->get_result()->fetch_assoc()) {

                die("This book has already entered. <a href='output_list.php'>К списку</a>");
            }

            $stmt = $con->prepare(
                "INSERT INTO bookinsert (reader, title, author, genre, pages, finished_date)
         VALUES (?,?,?,?,?,?)"
            );
            $stmt->bind_param("ssssis", $reader, $title, $author, $genre_str, $pages, $finished_date);

            try {
                $stmt->execute();
                echo "Saved.";
            } catch (mysqli_sql_exception $e) {

                if ($e->getCode() === 1062) {
                    die("The user already exists.");
                }
                throw $e;
            }
        }
        ?>
    </body>

</html>