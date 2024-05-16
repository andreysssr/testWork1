<?php


$message = sprintf(
    'From service %s',
    getenv('SERVICE_ID')
);

//echo json_encode(compact('message')), "<br><br>";
echo $message, "<br><br>";

ob_start();

$seconds = 5;

// Устанавливаем соединение с Redis-сервером
$redis = new Redis();
$redis->connect('redis', 6379);

// Генерируем уникальный ключ для скрипта
$key = 'lock:' . basename(__FILE__);

// Проверяем, запущен ли скрипт в данный момент
$locked = $redis->setnx($key, 1);
if (!$locked) {
    // Скрипт уже выполняется, выходим
    exit('Скрипт уже выполняется.');
}

// Устанавливаем срок жизни ключа на несколько секунд
$redis->expire($key, $seconds);

echo 'Начинаем работу', "<br><br>";
echo str_pad('',8192)."\n";

for ($i=1, $count = $seconds + 1; $i < $count; $i++) {
    echo $i .'<br>';

    echo str_pad('',8192)."\n";

    ob_flush();
    flush();

    sleep(1);
}

echo "<br>", 'Закончили работу';
