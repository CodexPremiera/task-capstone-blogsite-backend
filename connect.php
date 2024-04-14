<?php

$connection = new mysqli('localhost', 'root', '', 'dbcomandaof1');

if ($connection->connect_error) {
    die("Connection failed: " . $connection->connect_error);
}