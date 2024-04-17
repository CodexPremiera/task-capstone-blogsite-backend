<?php

global $connection;
include 'connect.php';

// allow all origins
if (isset($_SERVER['HTTP_ORIGIN'])) {
    header("Access-Control-Allow-Origin: {$_SERVER['HTTP_ORIGIN']}");
    header('Access-Control-Allow-Credentials: true');
    header('Access-Control-Max-Age: 86400');    // cache for 1 day
}

// Access-Control headers are received during OPTIONS requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    if (isset($_SERVER['HTTP_ACCESS_CONTROL_REQUEST_METHOD']))
        header("Access-Control-Allow-Methods: GET, POST, OPTIONS");

    if (isset($_SERVER['HTTP_ACCESS_CONTROL_REQUEST_HEADERS']))
        header("Access-Control-Allow-Headers: {$_SERVER['HTTP_ACCESS_CONTROL_REQUEST_HEADERS']}");

    exit(0);
}

// retrieve and validate email and password from the form
$data = json_decode(file_get_contents("php://input"), true);
$email = trim($data['email']);
$password = $data['password'];

if (empty($email) || empty(trim($password)) ) {
    echo json_encode(["error" => "All fields must be supplied"]);
    http_response_code(400);
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
    a.Email = '$email'
    AND a.Password = '$password';
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
