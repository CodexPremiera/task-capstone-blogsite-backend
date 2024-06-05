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

$commentID = isset($data['commentId']) ? $data['commentId'] : null;
$userAccountID = isset($data['userAccountId']) ? $data['userAccountId'] : null;

if (!$commentID || !$userAccountID) {
    echo json_encode(["error" => "Missing commentId or userAccountId"]);
    exit();
}

try {
    $pdo = new PDO("mysql:host=$DB_HOST;dbname=$DB_NAME", $DB_USERNAME, $DB_PASSWORD);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Check if the comment exists and the user is an author of the post
    $pdo->beginTransaction();

    $statement = $pdo->prepare(
        "SELECT COUNT(*)
         FROM tbl_user_account ua
         JOIN tbl_comment co ON ua.ID_UserAccount = co.ID_UserAccount
         WHERE co.ID_Comment = ?
           AND ua.ID_UserAccount = ?"
    );
    $statement->execute([$commentID, $userAccountID]);
    $count = $statement->fetchColumn();

    $pdo->commit();

    if ($count == 1) {
        try {
            $pdo->beginTransaction();

            $deleteStatement = $pdo->prepare(
                "DELETE FROM tbl_comment
                 WHERE ID_Comment = ?
                   AND ID_UserAccount = ?"
            );
            $deleteStatement->execute([$commentID, $userAccountID]);

            $pdo->commit();

            echo json_encode(["message" => "Deletion done"]);
        } catch (PDOException $e) {
            $pdo->rollBack();
            echo json_encode(["error" => "Deletion failed: " . $e->getMessage()]);
        }
    } else {
        echo json_encode(["error" => "Comment or user not found"]);
    }
} catch (PDOException $e) {
    echo json_encode(["error" => "Connection failed: " . $e->getMessage()]);
}

