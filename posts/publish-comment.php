<?php

include '../connect.php';
global $connection, $dbHost, $dbName, $dbUsername, $dbPassword, $pdo, $userAccountID;

// set database details
$DB_HOST = $dbHost;
$DB_NAME = $dbName;
$DB_USERNAME = $dbUsername;
$DB_PASSWORD= $dbPassword;

// retrieve inputs from the form
$data = json_decode(file_get_contents("php://input"), true);
$content = $data['comment'];
$postID = $data['postId'];
$userAccountID = $data['userAccountId'];

// check if inputs are not null
if ($content == null) {
    echo json_encode(["error" => "All fields are required"]);
    http_response_code(400);
    die(mysqli_error($connection));
}

// check if inputs are not empty
$content = trim($content);
if (empty($content)) {
    echo json_encode(["error" => "Post title and content must be supplied"]);
    http_response_code(400);
    die(mysqli_error($connection));
}


// check if the user account exists
try {
    $pdo = new PDO("mysql:host=$DB_HOST;dbname=$DB_NAME", $DB_USERNAME, $DB_PASSWORD);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $accountStatement = $pdo->prepare("
        SELECT COUNT(*) AS user_count
        FROM tbl_user_account ua
        WHERE ua.ID_UserAccount = ?;
    ");

    $accountStatement->execute([$userAccountID]);
    $accountExists = $accountStatement->fetchColumn();

    if (!$accountExists) {
        echo json_encode(["error" => "Invalid account"]);
        http_response_code(409);
        die(mysqli_error($connection));
    }
} catch(PDOException $e) {
    echo "Connection failed: " . $e->getMessage();
}


// query the database to insert the new posts
try {
    // create and start a new PDO instance
    $pdo = new PDO("mysql:host=$DB_HOST;dbname=$DB_NAME", $DB_USERNAME, $DB_PASSWORD);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->beginTransaction();

    // insert a new posts into tbl_post
    $statement = $pdo->prepare(
        "INSERT INTO tbl_comment (ID_UserAccount, ID_Post, Content) 
                VALUES (?, ?, ?)"
    );
    $statement->execute([$userAccountID, $postID, $content]);

    // update comment count
    $statement = $pdo->prepare("
            SELECT COUNT(*) AS user_count
            FROM tbl_comment
            WHERE ID_Post = ?
        ");
    $statement->execute([$postID]);
    $postCount = $statement->fetchColumn();

    // update comment count
    $statement = $pdo->prepare("
            UPDATE tbl_post
            SET CommentCount = ?
            WHERE ID_Post = ?
        ");
    $statement->execute([$postCount, $postID]);

    // commit the transaction
    $pdo->commit();
} catch(PDOException $error) {
    // rollback the transaction on error
    $pdo->rollBack();
    http_response_code(500);
    echo "Error: " . $error->getMessage();
    echo json_encode(["error" => "User registration failed."]);
    die(mysqli_error($connection));
}

die(mysqli_error($connection));
