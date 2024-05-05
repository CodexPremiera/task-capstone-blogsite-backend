<?php

include '../connect.php';
global $connection, $dbHost, $dbName, $dbUsername, $dbPassword, $pdo, $userAccountID;

// set database details
$DB_HOST = $dbHost;
$DB_NAME = $dbName;
$DB_USERNAME = $dbUsername;
$DB_PASSWORD= $dbPassword;


// retrieve inputs from the form
if (!isset($_GET['userAccountId'])) {
    die(mysqli_error($connection));
}

// query the database to get all posts
$userAccountId = $_GET['userAccountId'];

try {
    // create and start a new PDO instance
    $pdo = new PDO("mysql:host=$DB_HOST;dbname=$DB_NAME", $DB_USERNAME, $DB_PASSWORD);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->beginTransaction();

    // insert a new posts into tbl_post
    $statement = $pdo->prepare(
        "SELECT
            COUNT(*) as Count
        FROM
            tbl_admin_account admins
        WHERE
            ID_UserAccount = ?"
    );
    $statement->execute([$userAccountId]);
    $result = $statement->fetch(PDO::FETCH_ASSOC);
    $pdo->commit();

    // Check if the count is greater than 0 and return true
    if ($result['Count'] > 0) {
        echo json_encode(["result" => true]);
    } else {
        echo json_encode(["result" => false]);
    }
} catch(PDOException $error) {
    // rollback the transaction on error
    $pdo->rollBack();
    http_response_code(500);
    echo "Error: " . $error->getMessage();
    echo json_encode(["error" => "Admin retrieval failed."]);
}

// It's better to remove this line as it may not be needed
// die(mysqli_error($connection));

