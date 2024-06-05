<?php

global $statement, $error;
include '../connect.php';
global $connection, $dbHost, $dbName, $dbUsername, $dbPassword, $pdo, $userAccountID, $commentID, $count;

// set database details
$DB_HOST = $dbHost;
$DB_NAME = $dbName;
$DB_USERNAME = $dbUsername;
$DB_PASSWORD= $dbPassword;


// Retrieve inputs from the form
$data = json_decode(file_get_contents("php://input"), true);
$commentID = intval($data['ID_Post']);

// Check if the user account has already liked the post
try {
    $pdo = new PDO("mysql:host=$dbHost;dbname=$dbName", $dbUsername, $dbPassword);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->beginTransaction();

    $statement = $pdo->prepare("
        SELECT 
            lp.ID_Like AS LikeId,
            ua.ID_UserAccount as UserAccountId,
            u.ID_User as UserId,
            u.Firstname as Firstname,
            u.Lastname as Lastname,
            ua.Bio as Bio
        FROM 
            tbl_like_post AS lp 
                JOIN
            tbl_like AS li ON lp.ID_Like = li.ID_Like
                JOIN
            tbl_post AS po ON lp.ID_Post = po.ID_Post
                JOIN
            tbl_user_account AS ua ON li.ID_UserAccount = ua.ID_UserAccount
                JOIN
            tbl_user AS u ON ua.ID_User = u.ID_User
        WHERE 
            lp.ID_Post = ?;
    ");

    $statement->execute([$commentID]);
    $result = $statement->fetchAll(PDO::FETCH_ASSOC);
    $pdo->commit();

    // Return the result
    echo json_encode($result);

    //echo "All posts have been successfully retrieved.";
} catch(PDOException $error) {
    // rollback the transaction on error
    $pdo->rollBack();
    http_response_code(500);
    echo json_encode(["error" => "Post retrieval failed."]);
}

die(mysqli_error($connection));
