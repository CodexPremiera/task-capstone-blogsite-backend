<?php

include '../connect.php';
global $connection, $dbHost, $dbName, $dbUsername, $dbPassword, $pdo, $userAccountID;

// set database details
$DB_HOST = $dbHost;
$DB_NAME = $dbName;
$DB_USERNAME = $dbUsername;
$DB_PASSWORD= $dbPassword;

// retrieve inputs from the form
$data = json_decode(file_get_contents("php://input"), true);
$firstname = $data['firstname'];
$lastname = $data['lastname'];
$gender = $data['gender'];
$birthdate = $data['birthdate'];
$username = $data['username'];
$email = $data['email'];
$password = $data['password'];

// check if inputs are not null
if ($firstname == null || $lastname == null || $gender == null || $birthdate == null ||
    $username == null || $email == null || $password == null)
{
    echo json_encode(["error" => "All fields are required"]);
    http_response_code(400);
    die(mysqli_error($connection));
}

// check if inputs are not empty
$firstname = trim($firstname);
$lastname = trim($lastname);
$gender = trim($gender);
$birthdate = trim($birthdate);
$username = trim($username);
$email = trim($email);
$password = trim($password);

// check if inputs are not empty
if (empty($firstname) || empty($lastname) || empty($gender) || empty($birthdate) ||
    empty($username) || empty($email) || empty($password))
{
    echo json_encode(["error" => "All fields must be supplied"]);
    http_response_code(400);
    die(mysqli_error($connection));
}

// check if the email already exist
try {
    $pdo = new PDO("mysql:host=$DB_HOST;dbname=$DB_NAME", $DB_USERNAME, $DB_PASSWORD);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $emailStatement = $pdo->prepare("
        SELECT COUNT(*) AS user_count
        FROM tbl_user_account ua
                 JOIN
             tbl_user u ON ua.ID_User = u.ID_User
                 JOIN
             tbl_account a ON ua.ID_Account = a.ID_Account
        WHERE a.Email = ?;
    ");

    $emailStatement->execute([$email]);
    $emailExists = $emailStatement->fetchColumn();

    if ($emailExists) {
        echo json_encode(["error" => "Email already exist"]);
        http_response_code(409);
        die(mysqli_error($connection));
    }
} catch(PDOException $e) {
    echo "Connection failed: " . $e->getMessage();
}


// query the database to insert the new user account
try {
    // create and start a new PDO instance
    $pdo = new PDO("mysql:host=$DB_HOST;dbname=$DB_NAME", $DB_USERNAME, $DB_PASSWORD);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->beginTransaction();

    // insert a new user into tbl_user
    $statement = $pdo->prepare(
        "INSERT INTO tbl_user (Firstname, Lastname, Gender, Birthdate, Age) 
                VALUES (?, ?, ?, ?, TIMESTAMPDIFF(YEAR, Birthdate, CURDATE()))"
    );
    $statement->execute([$firstname, $lastname, $gender, $birthdate]);
    $userID = $pdo->lastInsertId(); // retrieve the ID of the newly inserted user

    // insert a new account into tbl_account
    $statement = $pdo->prepare(
        "INSERT INTO tbl_account (Username, Email, Password, UserType, CreateTime, IsActive) 
                VALUES (?, ?, ?, 'Regular', CURRENT_TIMESTAMP, true)"
    );
    $statement->execute([$username, $email, $password]);
    $accountID = $pdo->lastInsertId(); // Retrieve the ID of the newly inserted account

    // insert a new record into tbl_user_account
    $statement = $pdo->prepare(
        "INSERT INTO tbl_user_account (ID_User, ID_Account, TotalPosts, TotalLikes, TotalReads, Bio) 
                VALUES (?, ?, 0, 0, 0, '')"
    );
    $statement->execute([$userID, $accountID]);
    $userAccountID = $pdo->lastInsertId(); // Retrieve the ID of the newly inserted user-account

    // commit the transaction
    $pdo->commit();
    //echo "New user account for $firstname $lastname has been successfully inserted.";
} catch(PDOException $error) {
    // rollback the transaction on error
    $pdo->rollBack();
    http_response_code(500);
    echo "Error: " . $error->getMessage();
    echo json_encode(["error" => "User registration failed."]);
    die(mysqli_error($connection));
}


// query the database to find the user account
$getUserAccountQuery = "
    SELECT
        ua.ID_UserAccount AS ID_UserAccount,
        u.Firstname AS Firstname,
        u.Lastname AS Lastname,
        u.Gender AS Gender,
        u.Birthdate AS Birthdate,
        u.Age AS Age,
        a.Username AS Username,
        a.Email AS Email,
        a.UserType AS UserType,
        a.CreateTime AS CreateTime,
        a.IsActive AS IsActive,
        ua.TotalPosts AS TotalPosts,
        ua.TotalLikes AS TotalLikes,
        ua.TotalReads AS TotalReads,
        ua.Bio AS Bio
    FROM
        tbl_user_account ua
            JOIN
        tbl_user u ON ua.ID_User = u.ID_User
            JOIN
        tbl_account a ON ua.ID_Account = a.ID_Account
    WHERE
        ua.ID_UserAccount = $userAccountID;
";
$result = mysqli_query($connection, $getUserAccountQuery);

// handle failed query
if (!$result) {
    // User found, return user data
    http_response_code(401);
    echo json_encode(["error" => "Invalid email or password"]);
    die(mysqli_error($connection));
}

// return user data
$user = mysqli_fetch_assoc($result);
echo json_encode($user);

