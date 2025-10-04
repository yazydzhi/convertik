<?php

// Определяем параметры для соединения с базой данных
// $host = "h304122827.mysql";
// $username = "h304122827_mysql";
// $password = "kW1tipd_";
// $database = "h304122827_db";
$host = "172.18.0.1";
$username = "root";
$password = "xsW@3edc";
$database = "convertik";

// Устанавливаем соединение с базой данных
$mysqli = new mysqli($host, $username, $password, $database);

// Проверяем, удалось ли установить соединение
if ($mysqli->connect_errno) {
   echo "Failed to connect to MySQL: " . $mysqli->connect_error;
    exit();
}

// Устанавливаем заголовок, чтобы браузер интерпретировал ответ как JSON
header('Content-Type: application/json');
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// echo "\n[DEBUG: script reached]\n";
// error_log("[DEBUG] Starting exchange rate update");

function downloadExchangeRates($mysqli) {
    // Задаем параметры для запроса к API
    $base_currency = 'RUB';
    $api_key = "6rOLEhF1PKO8tbicWoLG9wCXSRwlE3hk";
    $api_url = "http://api.apilayer.com/exchangerates_data/latest";

    // Проверяем, прошло ли 6 часов с момента последнего обновления
    $result = $mysqli->query("SELECT update_date FROM exchange_rates ORDER BY id DESC LIMIT 1");
    $row = $result->fetch_assoc();
    $last_update_time = strtotime($row["update_date"]);
    $current_time = time();
    if ($current_time - $last_update_time < 6 * 60 * 60) { // Если не прошло 6 часов, то выходим из функции
        return;
    }

    // Выполняем запрос к API
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $api_url . "?base=" . $base_currency);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_TIMEOUT, 10);
    curl_setopt($ch, CURLOPT_HTTPHEADER, array("apikey: $api_key"));
    // error_log("[DEBUG] Fetching API: " . $api_url . "?base=" . $base_currency);
    $response = curl_exec($ch);
    if (curl_errno($ch)) { // Если возникла ошибка при выполнении запроса, выводим сообщение об ошибке и выходим из функции
        echo 'Error:' . curl_error($ch);
        return;
    }
    curl_close($ch);

    // Парсим полученный JSON
    // $rates = json_decode($response, true);
    $rates = json_decode($response, true)["rates"];

    if (!$rates || !is_array($rates)) {
        echo json_encode([
            "status" => "error",
            "message" => "API response invalid or empty",
            "raw_response" => $response
        ]);
        return;
    }

    $update_date = date("Y-m-d H:i:s"); // Добавляем текущую дату

    // Сохраняем курсы валют в БД
    $json_data = json_encode($rates); // Получаем JSON-представление всех курсов валют
    $stmt = $mysqli->prepare("INSERT INTO exchange_rates (update_date, json_data, json_version) VALUES (?, ?, 1)");
    // Добавляем параметры в запрос
    $stmt->bind_param("ss", $update_date, $json_data); // остаётся без изменений, т.к. json_version — константа
    // Выполняем запрос
    $stmt->execute();
    // Закрываем prepared statement
    $stmt->close();
    // error_log("[DEBUG] Inserted exchange rates into database at " . $update_date);
    echo json_encode([
        "status" => "success",
        "message" => "Exchange rates updated and saved to database",
        "fetched_at" => $update_date,
        "sample_rate" => array_slice($rates, 0, 5)
    ]);
}

// Выполняем скачивание курса валют и сохранение в БД
downloadExchangeRates($mysqli);
// error_log("[DEBUG] Completed exchange rate update");

// Выполняем запрос на выборку последней строки
$result = $mysqli->query("SELECT update_date,json_data FROM exchange_rates WHERE json_version = 1 ORDER BY id DESC LIMIT 1");
// error_log("[DEBUG] Selecting latest exchange rate row");

// Получаем данные из последней строки
$row = $result->fetch_assoc();
// error_log("[DEBUG] Fetched row: " . json_encode($row));
$json_data_ext = $row["json_data"];
$update_date = $row["update_date"];

// Безопасный отладочный вывод, если нет данных или json_data пустое
if (!$row || !$json_data_ext) {
    echo json_encode([
        "status" => "error",
        "message" => "No data found or empty json_data",
        "row" => $row,
    ]);
    exit();
}

// Возвращаем результат в формат JSON
echo $json_data_ext;


?>