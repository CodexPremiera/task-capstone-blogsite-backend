<?php

global $statement;
include '../connect.php';
global $connection, $dbHost, $dbName, $dbUsername, $dbPassword, $pdo, $userAccountID, $commentID, $count;

// set database details
$DB_HOST = $dbHost;
$DB_NAME = $dbName;
$DB_USERNAME = $dbUsername;
$DB_PASSWORD= $dbPassword;


// Retrieve inputs from the form
$data = json_decode(file_get_contents("php://input"), true);
$commentID = $data['postId'];
$userAccountID = $data['userAccountId'];

// Check if the user account has already liked the post
try {
    $pdo = new PDO("mysql:host=$dbHost;dbname=$dbName", $dbUsername, $dbPassword);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // check like count
    $statement = $pdo->prepare("
        SELECT COUNT(*)
        FROM tbl_like_posT       
        WHERE ID_Post = ?;
    ");
    $statement->execute([$commentID]);
    $count = $statement->fetchColumn();

    $statement = $pdo->prepare("
            UPDATE tbl_post
            SET ReactCount = ?
            WHERE ID_Post = ?
        ");
    $statement->execute([$count, $commentID]);

    // check user has liked
    $likeStatement = $pdo->prepare("
        SELECT lk.ID_Like AS like_id
        FROM tbl_like lk
                 JOIN
             tbl_like_post lkp ON lk.ID_Like = lkp.ID_Like 
        WHERE lk.ID_UserAccount = ? AND lkp.ID_Post = ?;
    ");
    $likeStatement->execute([$userAccountID, $commentID]);
    $count = $likeStatement->fetchColumn();
    $likeStatement->closeCursor();

} catch (PDOException $e) {
    echo json_encode(["error" => "Connection failed"]);
    exit(); // Terminate script execution after encountering a connection failure
}

if ($count) {
    echo json_encode(["hasLiked" => "true"]);
} else {
    echo json_encode(["hasLiked" => "false"]);
}