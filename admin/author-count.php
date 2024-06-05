<?php

include '../connect.php';
global $connection, $dbHost, $dbName, $dbUsername, $dbPassword, $pdo, $userAccountID;

// set database details
$DB_HOST = $dbHost;
$DB_NAME = $dbName;
$DB_USERNAME = $dbUsername;
$DB_PASSWORD= $dbPassword;


// query the database to get all posts
try {
    // create and start a new PDO instance
    $pdo = new PDO("mysql:host=$DB_HOST;dbname=$DB_NAME", $DB_USERNAME, $DB_PASSWORD);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->beginTransaction();

    // retrieve useraccounts from user accounts
    $statement = $pdo->prepare(
        "SELECT
                    ua.ID_UserAccount AS ID_UserAccount,
                    u.Firstname AS Firstname,
                    u.Lastname AS Lastname,
                    COUNT(au.sequence_no) AS PostCount
                FROM
                    tbl_author au
                        JOIN
                    tbl_user_account ua ON au.ID_UserAccount = ua.ID_UserAccount
                        JOIN
                    tbl_user u ON ua.ID_User = u.ID_User
                GROUP BY ua.ID_UserAccount, u.Firstname, u.Lastname 
                ORDER BY PostCount DESC"
    );
    $statement->execute();
    $result = $statement->fetchAll(PDO::FETCH_ASSOC);
    $pdo->commit();

    // Return the result
    echo json_encode($result);

    //echo "All posts have been successfully retrieved.";
} catch(PDOException $error) {
    // rollback the transaction on error
    $pdo->rollBack();
    http_response_code(500);
    echo "Error: " . $error->getMessage();
    echo json_encode(["error" => "Post retrieval failed."]);
}

die(mysqli_error($connection));
