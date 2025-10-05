<?php
// === DB connect (исправь пароль и имя БД под себя) ===
mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
$db = new mysqli('localhost', 'root', '1234', 'sofiatest'); // <-- поменяй при необходимости
$db->set_charset('utf8mb4');

// --- 1) Monthly activity: books + pages + avg ---
$qMonthly = "
  SELECT
    DATE_FORMAT(finished_date, '%Y-%m') AS ym,
    COUNT(*)                            AS books,
    COALESCE(SUM(pages), 0)             AS pages_sum,
    ROUND(AVG(pages), 1)                AS pages_avg
  FROM bookinsert
  WHERE finished_date IS NOT NULL
  GROUP BY ym
  ORDER BY ym
";
$monthly = $db->query($qMonthly)->fetch_all(MYSQLI_ASSOC);

// --- 2) Top authors (by books) ---
$qAuthors = "
  SELECT author, COUNT(*) AS books
  FROM bookinsert
  WHERE COALESCE(author,'') <> ''
  GROUP BY author
  ORDER BY books DESC, author
  LIMIT 10
";
$topAuthors = $db->query($qAuthors)->fetch_all(MYSQLI_ASSOC);

// --- 3) Genre breakdown (CSV в поле genre) ---
$genres = ['Fantasy', 'Romance', 'Thriller', 'Science fiction', 'Horror', 'Other']; // значения, которые у тебя пишутся в БД
$counter = array_fill_keys($genres, 0);

$res = $db->query("SELECT genre FROM bookinsert WHERE COALESCE(TRIM(genre),'') <> ''");
while ($r = $res->fetch_assoc()) {
    $parts = array_map('trim', explode(',', $r['genre']));
    foreach ($parts as $p) {
        if ($p === '') continue;
        foreach ($genres as $g) {
            if (mb_strtolower($p) === mb_strtolower($g)) {
                $counter[$g]++;
                break;
            }
        }
    }
}

// --- Подготовка массивов для JS ---
$monthly_labels = array_column($monthly, 'ym');
$monthly_books  = array_map('intval',  array_column($monthly, 'books'));
$monthly_pages  = array_map('intval',  array_column($monthly, 'pages_sum'));
$monthly_avg    = array_map('floatval', array_column($monthly, 'pages_avg'));

$authors_labels = array_column($topAuthors, 'author');
$authors_data   = array_map('intval', array_column($topAuthors, 'books'));

$genre_labels   = array_keys($counter);
$genre_data     = array_values($counter);
?>
<!doctype html>
<html lang="en">

<head>
    <meta charset="utf-8">
    <title>Book Tracker — Stats</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- Chart.js v4 -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>

<body>
    <h1>Book Tracker — Stats</h1>

    <h3>Monthly activity</h3>
    <canvas id="monthly" width="1000" height="360"></canvas>

    <h3>Top authors</h3>
    <canvas id="authors" width="1000" height="360"></canvas>

    <h3>Genre breakdown</h3>
    <canvas id="genres" width="1000" height="360"></canvas>

    <script>
        // Данные из PHP
        const monthlyLabels = <?php echo json_encode($monthly_labels, JSON_UNESCAPED_UNICODE); ?>;
        const monthlyBooks = <?php echo json_encode($monthly_books,  JSON_UNESCAPED_UNICODE); ?>;
        const monthlyPages = <?php echo json_encode($monthly_pages,  JSON_UNESCAPED_UNICODE); ?>;
        const monthlyAvg = <?php echo json_encode($monthly_avg,    JSON_UNESCAPED_UNICODE); ?>;

        const authorsLabels = <?php echo json_encode($authors_labels, JSON_UNESCAPED_UNICODE); ?>;
        const authorsData = <?php echo json_encode($authors_data,   JSON_UNESCAPED_UNICODE); ?>;

        const genreLabels = <?php echo json_encode($genre_labels,   JSON_UNESCAPED_UNICODE); ?>;
        const genreData = <?php echo json_encode($genre_data,     JSON_UNESCAPED_UNICODE); ?>;

        // 1) Monthly: столбцы (Books) + линии (Pages sum, Pages avg)
        new Chart(document.getElementById('monthly').getContext('2d'), {
            type: 'bar',
            data: {
                labels: monthlyLabels,
                datasets: [{
                        label: 'Books',
                        data: monthlyBooks,
                        type: 'bar',
                        yAxisID: 'yBooks'
                    },
                    {
                        label: 'Pages (sum)',
                        data: monthlyPages,
                        type: 'line',
                        yAxisID: 'yPages'
                    },
                    {
                        label: 'Pages (avg)',
                        data: monthlyAvg,
                        type: 'line',
                        yAxisID: 'yPages'
                    }
                ]
            },
            options: {
                responsive: false,
                interaction: {
                    intersect: false,
                    mode: 'index'
                },
                scales: {
                    x: {
                        title: {
                            display: true,
                            text: 'Month (YYYY-MM)'
                        }
                    },
                    yBooks: {
                        position: 'left',
                        beginAtZero: true,
                        title: {
                            display: true,
                            text: 'Books'
                        }
                    },
                    yPages: {
                        position: 'right',
                        beginAtZero: true,
                        title: {
                            display: true,
                            text: 'Pages'
                        },
                        grid: {
                            drawOnChartArea: false
                        }
                    }
                }
            }
        });

        // 2) Top authors
        new Chart(document.getElementById('authors').getContext('2d'), {
            type: 'bar',
            data: {
                labels: authorsLabels,
                datasets: [{
                    label: 'Books',
                    data: authorsData
                }]
            },
            options: {
                responsive: false,
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });

        // 3) Genres
        new Chart(document.getElementById('genres').getContext('2d'), {
            type: 'doughnut',
            data: {
                labels: genreLabels,
                datasets: [{
                    label: 'Books',
                    data: genreData
                }]
            },
            options: {
                responsive: false
            }
        });
    </script>
</body>

</html>