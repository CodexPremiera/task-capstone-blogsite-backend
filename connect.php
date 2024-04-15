<?php

// database connection parameters
$dbHost = 'localhost';
$dbName = 'dbcomandaof1';
$dbUsername = 'root';
$dbPassword = '';

$connection = new mysqli($dbHost, $dbUsername, $dbPassword, $dbName);

if ($connection->connect_error) {
    die("Connection failed: " . $connection->connect_error);
}