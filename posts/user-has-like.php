<?php

global $statement;
include '../connect.php';
global $connection, $dbHost, $dbName, $dbUsername, $dbPassword, $pdo, $userAccountID, $postID, $likeId;

// set database details
$DB_HOST = $dbHost;
$DB_NAME = $dbName;
$DB_USERNAME = $dbUsername;
$DB_PASSWORD= $dbPassword;


// Retrieve inputs from the form
$data = json_decode(file_get_contents("php://input"), true);
$postID = $data['postId'];
$userAccountID = $data['userAccountId'];

// Check if the user account has already liked the post
try {
    $pdo = new PDO("mysql:host=$dbHost;dbname=$dbName", $dbUsername, $dbPassword);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $likeStatement = $pdo->prepare("
        SELECT lk.ID_Like AS like_id
        FROM tbl_like lk
                 JOIN
             tbl_like_post lkp ON lk.ID_Like = lkp.ID_Like 
        WHERE lk.ID_UserAccount = ? AND lkp.ID_Post = ?;
    ");

    $likeStatement->execute([$userAccountID, $postID]);
    $likeId = $likeStatement->fetchColumn();
    $likeStatement->closeCursor();
} catch (PDOException $e) {
    echo json_encode(["error" => "Connection failed"]);
    exit(); // Terminate script execution after encountering a connection failure
}

if ($likeId) {
    echo json_encode(["hasLiked" => "true"]);
} else {
    echo json_encode(["hasLiked" => "false"]);
}

/*

// query the database to find the user account
try {
    $pdo = new PDO("mysql:host=$DB_HOST;dbname=$DB_NAME", $DB_USERNAME, $DB_PASSWORD);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $getLikeQuery = "
        SELECT
            ua.ID_UserAccount as userAccountId,
            po.Title as PostTitle
        FROM tbl_like_post lkp
                JOIN
             tbl_like lk ON lk.ID_Like = lkp.ID_Like
                JOIN
             tbl_user_account ua ON lk.ID_UserAccount = ua.ID_UserAccount
                JOIN
             tbl_post po ON lkp.ID_Post = po.ID_Post
        WHERE lkp.ID_Like = 1;
    ";

    $statement = $pdo->prepare($getLikeQuery);
    $statement->execute();

    $user = $statement->fetch(PDO::FETCH_ASSOC);
    $statement->closeCursor();

    echo json_encode($user);

} catch(PDOException $e) {
    http_response_code(500);
    echo json_encode(["error" => "Invalid email or password"]);
    die($e->getMessage());
}*/

