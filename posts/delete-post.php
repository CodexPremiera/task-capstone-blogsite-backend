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

// Debug input data
if (!$data) {
    echo json_encode(["error" => "Invalid input"]);
    exit();
}

$postID = isset($data['postId']) ? $data['postId'] : null;
$userAccountID = isset($data['userAccountId']) ? $data['userAccountId'] : null;

if (!$postID || !$userAccountID) {
    echo json_encode(["error" => "Missing postId or userAccountId"]);
    exit();
}

try {
    $pdo = new PDO("mysql:host=$DB_HOST;dbname=$DB_NAME", $DB_USERNAME, $DB_PASSWORD);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Check if the post exists and the user is an author of the post
    $pdo->beginTransaction();

    $statement = $pdo->prepare(
        "SELECT COUNT(*)
         FROM tbl_author au
         JOIN tbl_post po ON au.ID_Post = po.ID_Post
         WHERE po.ID_Post = ?
           AND au.ID_UserAccount = ?"
    );
    $statement->execute([$postID, $userAccountID]);
    $count = $statement->fetchColumn();

    $pdo->commit();

    if ($count == 1) {
        try {
            $pdo->beginTransaction();

            $deleteStatement = $pdo->prepare(
                "DELETE po
                 FROM tbl_post po
                 JOIN tbl_author au ON po.ID_Post = au.ID_Post
                 WHERE po.ID_Post = ?
                   AND au.ID_UserAccount = ?"
            );
            $deleteStatement->execute([$postID, $userAccountID]);

            $pdo->commit();

            echo json_encode(["message" => "Deletion done"]);
        } catch (PDOException $e) {
            $pdo->rollBack();
            echo json_encode(["error" => "Deletion failed: " . $e->getMessage()]);
        }
    } else {
        echo json_encode(["error" => "Post not found or user is not an author"]);
    }
} catch (PDOException $e) {
    echo json_encode(["error" => "Connection failed: " . $e->getMessage()]);
}
?>
