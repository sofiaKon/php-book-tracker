<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8">
</head>

<body>
    <?php
    mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

    try {
        $db = new mysqli('localhost', 'root', '1234', 'booktracker');
        $db->set_charset('utf8mb4');
    } catch (mysqli_sql_exception $e) {
        echo 'DB connection error: ' . htmlspecialchars($e->getMessage());
        exit;
    }

    $res = $db->query("
  SELECT id, reader, name, title, author, genre, pages, finished_date, added_at
  FROM bookinsert
  ORDER BY added_at DESC, id DESC
");

    echo "<h1>Book list</h1>\n";
    echo "<table>\n";
    echo "<tr>
        <th>Reader Name</th>
        <th>Title of Book</th>
        <th>Author</th>
        <th>Genre</th>
        <th>Pages</th>
        <th>Finished Date</th>
        <th>Added at</th>
      </tr>\n";

    while ($row = $res->fetch_assoc()) {

        $reader = $row['reader'] ?? $row['name'] ?? '';

        echo "<tr>";
        echo "<td>" . htmlspecialchars($reader, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8') . "</td>";
        echo "<td>" . htmlspecialchars($row['title'] ?? '', ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8') . "</td>";
        echo "<td>" . htmlspecialchars($row['author'] ?? '', ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8') . "</td>";
        echo "<td>" . htmlspecialchars($row['genre'] ?? '', ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8') . "</td>";
        echo "<td>" . (isset($row['pages']) ? (int)$row['pages'] : '') . "</td>";
        echo "<td>" . htmlspecialchars($row['finished_date'] ?? '', ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8') . "</td>";
        echo "<td>" . htmlspecialchars($row['added_at'] ?? '', ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8') . "</td>";
        echo "</tr>\n";
    }

    echo "</table>\n";

    $res->free();
    $db->close();
    ?>
    <br><br><a href="index.php">Add new book</a>
</body>

</html>