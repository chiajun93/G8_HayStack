<?php
include_once 'config.php';

if(isset($_SESSION['userID'])){

    $userID = $_SESSION['userID'];

    if($stmt = $db->prepare("SELECT username FROM users WHERE id = ? LIMIT 1")){
        $stmt->bind_param('i', $userID);
        $stmt->execute();
        $stmt->store_result();

        $stmt->bind_result($username);
        $stmt->fetch();

        $response["userID"] = $userID;
        $response["username"] = $username;
        $response["isLoggedIn"] = "True";

    }
    else{
        $response["isRecordFound"] = "False";
        $response["isLoggedIn"] = "False";
        http_response_code(400);
    }
}

else{
    $response["status"] = "Session userID is not set.";
    $response["isLoggedIn"] = "False";
    http_response_code(400);
}

echo json_encode($response);

?>