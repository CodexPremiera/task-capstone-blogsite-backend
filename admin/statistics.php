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

    // Get count of user-accounts
    $statement = $pdo->prepare(
        "SELECT
                COUNT(*) AS NumberOfAccounts
            FROM
                tbl_user_account ua
                    JOIN 
                tbl_account a ON ua.ID_Account = a.ID_Account
            WHERE
                a.IsActive = true"
    );
    $statement->execute();
    $result1 = $statement->fetch(PDO::FETCH_ASSOC);

    // Get count of posts
    $statement = $pdo->prepare(
        "SELECT
                COUNT(*) AS NumberOfPost
            FROM
                tbl_post 
            WHERE
                IsActive = true"
    );
    $statement->execute();
    $result2 = $statement->fetch(PDO::FETCH_ASSOC);

    // Get author rate
    $statement = $pdo->prepare(
        "SELECT
        ROUND(((SELECT COUNT(*) FROM tbl_user_account) / 
        (SELECT COUNT(*) FROM tbl_author) * 100), 2) AS AuthorRate"
    );
    $statement->execute();
    $result3 = $statement->fetch(PDO::FETCH_ASSOC);

    // Get average react count
    $statement = $pdo->prepare(
        "SELECT
                ROUND(AVG(ReactCount), 2) AS AverageReact
            FROM
                tbl_post 
            WHERE
                IsActive = true"
    );
    $statement->execute();
    $result4 = $statement->fetch(PDO::FETCH_ASSOC);

    // Get average comment count
    $statement = $pdo->prepare(
        "SELECT
                ROUND(AVG(CommentCount), 2) AS AverageComment
            FROM
                tbl_post 
            WHERE
                IsActive = true"
    );
    $statement->execute();
    $result5 = $statement->fetch(PDO::FETCH_ASSOC);


    // Combine the results into a single array
    $combinedResult = array(
        'NumberOfAccounts' => $result1['NumberOfAccounts'],
        'NumberOfPosts' => $result2['NumberOfPost'],
        'AuthorRate' => $result3['AuthorRate'],
        'AverageReact' => $result4['AverageReact'],
        'AverageComment' => $result5['AverageComment']
    );

    // Encode the combined result into a JSON string
    echo json_encode($combinedResult);

    $pdo->commit();
    // Return the result

    //echo "All posts have been successfully retrieved.";
} catch(PDOException $error) {
    // rollback the transaction on error
    $pdo->rollBack();
    http_response_code(500);
    echo "Error: " . $error->getMessage();
    echo json_encode(["error" => "Post retrieval failed."]);
}

die(mysqli_error($connection));
