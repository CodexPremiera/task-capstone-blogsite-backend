<?php

include '../connect.php';
global $connection, $dbHost, $dbName, $dbUsername, $dbPassword;

// Set database details
$DB_HOST = $dbHost;
$DB_NAME = $dbName;
$DB_USERNAME = $dbUsername;
$DB_PASSWORD = $dbPassword;

// Retrieve inputs from the form
$data = json_decode(file_get_contents("php://input"), true);

$commentID = isset($data['commentId']) ? $data['commentId'] : null;
$userAccountID = isset($data['userAccountId']) ? $data['userAccountId'] : null;

if (!$commentID || !$userAccountID) {
    echo json_encode(["error" => "Invalid input"]);
    exit();
}

try {
    $pdo = new PDO("mysql:host=$DB_HOST;dbname=$DB_NAME", $DB_USERNAME, $DB_PASSWORD);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Check and set like count
    $statement = $pdo->prepare("
        SELECT COUNT(*)
        FROM tbl_like_comment
        WHERE ID_Comment = ?
    ");
    $statement->execute([$commentID]);
    $likeCount = (int)$statement->fetchColumn();

    $statement = $pdo->prepare("
        UPDATE tbl_comment
        SET ReactCount = ?
        WHERE ID_Comment = ?
    ");
    $statement->execute([$likeCount, $commentID]);

    // Check if the user has liked the comment
    $likeStatement = $pdo->prepare("
        SELECT lk.ID_Like AS like_id
        FROM tbl_like lk
        JOIN tbl_like_comment lkc ON lk.ID_Like = lkc.ID_Like
        WHERE lk.ID_UserAccount = ? AND lkc.ID_Comment = ?
    ");
    $likeStatement->execute([$userAccountID, $commentID]);
    $userHasLiked = $likeStatement->fetchColumn() ? true : false;

    echo json_encode([
        "hasLiked" => $userHasLiked ? "true" : "false",
        "likeCount" => $likeCount
    ]);
} catch (PDOException $e) {
    echo json_encode(["error" => "Connection failed: " . $e->getMessage()]);
    exit();
}
