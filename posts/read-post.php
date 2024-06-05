<?php

include '../connect.php';
global $connection, $dbHost, $dbName, $dbUsername, $dbPassword, $pdo, $userAccountID;

// set database details
$DB_HOST = $dbHost;
$DB_NAME = $dbName;
$DB_USERNAME = $dbUsername;
$DB_PASSWORD= $dbPassword;


// retrieve inputs from the form
if(!isset($_GET['postId']))
    die(mysqli_error($connection));
$postId = $_GET['postId'];

$data = json_decode(file_get_contents("php://input"), true);
$userAccountID = isset($data['userAccountId']) ? $data['userAccountId'] : null;


// get read count
try {
    $pdo = new PDO("mysql:host=$DB_HOST;dbname=$DB_NAME", $DB_USERNAME, $DB_PASSWORD);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);


    // Check if the user has read the post
    $readStatement = $pdo->prepare("
        SELECT *
        FROM tbl_read_post
        WHERE ID_UserAccount = ?
            AND ID_Post = ?;
    ");
    $readStatement->execute([$userAccountID, $postId]);
    $userHasRead = $readStatement->fetchColumn() ? true : false;

    if (!$userHasRead) {
        try {
            $pdo->beginTransaction(); // Start a transaction

            // Insert a new like into tbl_like
            $insertReadStatement = $pdo->prepare("
                INSERT INTO tbl_read_post (ID_UserAccount, ID_Post) 
                VALUES (?, ?)
            ");
            $insertReadStatement->execute([$userAccountID, $postId]);
            $count = $pdo->lastInsertId(); // Retrieve the ID of the newly inserted like

            $pdo->commit(); // Commit the transaction
        } catch (PDOException $error) {
            $pdo->rollBack(); // Rollback the transaction on error
            http_response_code(500);
            echo json_encode(["error" => "Like failed. " . $error->getMessage()]);
            exit(); // Terminate script execution after encountering an error
        }
    }

    // get read count
    $statement = $pdo->prepare("
        SELECT COUNT(*)
        FROM tbl_read_post
        WHERE ID_Post = ?
    ");
    $statement->execute([$postId]);
    $readCount = (int)$statement->fetchColumn();

    // update post read count
    $statement = $pdo->prepare("
        UPDATE tbl_post
        SET ReadCount = ?
        WHERE ID_Post = ?
    ");
    $statement->execute([$readCount, $postId]);
} catch (PDOException $e) {
    echo json_encode(["error" => "Connection failed: " . $e->getMessage()]);
    exit();
}


// query the database to get post
try {
    // create and start a new PDO instance
    $pdo = new PDO("mysql:host=$DB_HOST;dbname=$DB_NAME", $DB_USERNAME, $DB_PASSWORD);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->beginTransaction();

    // insert a new posts into tbl_post
    $statement = $pdo->prepare(
        "SELECT
                    po.ID_Post as ID_Post,
                    po.Title as Title,
                    po.Content as Content,
                    po.PhotoURL as PhotoURL,
                    po.PostDate as PostDate,
                    po.ReadCount as ReadCount,
                    po.ReactCount as ReactCount,
                    po.CommentCount as CommentCount,
                    ua.ID_UserAccount AS ID_UserAccount,
                    u.Firstname AS Firstname,
                    u.Lastname AS Lastname,
                    a.Username AS Username
                FROM
                    tbl_author au
                        JOIN
                    tbl_post po ON au.ID_Post = po.ID_Post
                        JOIN
                    tbl_user_account ua ON au.ID_UserAccount = ua.ID_UserAccount
                        JOIN
                    tbl_user u ON ua.ID_User = u.ID_User
                        JOIN
                    tbl_account a ON ua.ID_Account = a.ID_Account
                WHERE
                    po.ID_Post = ?
                    AND a.IsActive = true
                    AND po.IsActive = true"
    );
    $statement->execute([$postId]);
    $result = $statement->fetchAll(PDO::FETCH_ASSOC);
    $pdo->commit();

    // Return the result
    echo json_encode($result);

    //echo "The post has been successfully retrieved.";
} catch(PDOException $error) {
    // rollback the transaction on error
    $pdo->rollBack();
    http_response_code(500);
    echo "Error: " . $error->getMessage();
    echo json_encode(["error" => "Post retrieval failed."]);
}

die(mysqli_error($connection));
