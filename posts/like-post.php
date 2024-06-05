<?php

global $statement;
include '../connect.php';
global $connection, $dbHost, $dbName, $dbUsername, $dbPassword, $pdo, $userAccountID, $postID, $count;

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
    $count = $likeStatement->fetchColumn();
    $likeStatement->closeCursor();
} catch (PDOException $e) {
    echo json_encode(["error" => "Connection failed"]);
    exit(); // Terminate script execution after encountering a connection failure
}

if ($count) {
    try {
        $deleteStatement = $pdo->prepare("
            DELETE FROM tbl_like_post
            WHERE ID_Like = ?;

            DELETE FROM tbl_like
            WHERE ID_Like = ?;

            UPDATE tbl_post
            SET ReactCount = ReactCount - 1
            WHERE ID_Post = ?
        ");
        $deleteStatement->execute([$count, $count, $postID]);
    } catch (PDOException $e) {
        echo json_encode(["error" => "Deletion failed"]);
        exit(); // Terminate script execution after encountering a deletion failure
    }
} else {
    try {
        $pdo->beginTransaction(); // Start a transaction

        // Insert a new like into tbl_like
        $insertLikeStatement = $pdo->prepare("
            INSERT INTO tbl_like (ID_UserAccount) 
            VALUES (?)
        ");
        $insertLikeStatement->execute([$userAccountID]);
        $count = $pdo->lastInsertId(); // Retrieve the ID of the newly inserted like

        // Insert a new entry into tbl_like_post
        $insertLikePostStatement = $pdo->prepare("
            INSERT INTO tbl_like_post (ID_Like, ID_Post) 
            VALUES (?, ?)
        ");
        $insertLikePostStatement->execute([$count, $postID]);

        // Increment react count
        $updatePostReactCountStatement = $pdo->prepare("
            UPDATE tbl_post
            SET ReactCount = ReactCount + 1
            WHERE ID_Post = ?
        ");
        $updatePostReactCountStatement->execute([$postID]);

        $pdo->commit(); // Commit the transaction
    } catch (PDOException $error) {
        $pdo->rollBack(); // Rollback the transaction on error
        http_response_code(500);
        echo json_encode(["error" => "Like failed. " . $error->getMessage()]);
        exit(); // Terminate script execution after encountering an error
    }
}
