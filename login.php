<?php

global $connection;
include 'connect.php';

// allow all origins
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST");
header("Access-Control-Allow-Headers: Content-Type");

// retrieve email and password from the form
$data = json_decode(file_get_contents("php://input"), true);
$email = $data['email'];
$password = $data['password'];

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
