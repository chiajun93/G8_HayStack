<?php

include_once 'config.php';

if(isset($_SESSION['userID'])){
    session_destroy();
    session_set_cookie_params(31556926);
    session_start([
    'cookie_lifetime' => 31556926,
    ]);
}

        // json response array
$response = array("error" => FALSE);
if (isset($_POST['username']) && isset($_POST['password'])) {

    // receiving the post params
    $username = $_POST['username'];
    $password = $_POST['password'];
    
    // get the user by email and password
    $stmt = $db->query("SELECT * FROM users WHERE username= '$username' AND password = '$password'")->fetch_assoc();
    $userID = $stmt['id'];

    if ($userID != false) {
        // use is found
        $_SESSION['userID'] = $userID;
        $response["userID"] = $userID;
        $response["session_userID"] = $_SESSION['userID'];
        echo json_encode($response);

    } else {
        // user is not found with the credentials
        $response["error_msg"] = "Login credentials are wrong. Please try again!";
        http_response_code(400);
        echo json_encode($response);
    }
} else {
    // required post params is missing
    $response["error"] = TRUE;
    $response["error_msg"] = "Required parameters username or password is missing!";
    http_response_code(400);
    echo json_encode($response);
}

// function getUserByEmailAndPassword($username, $password) {
//     $stmt = $db->query("SELECT * FROM users WHERE username= '$username' AND password = '$password'")->fetch_assoc();
//     $userID = $stmt['id'];
//     return $userID;
// }
?>