<?php
include_once 'config.php';

if(!empty($_POST['username']) && !empty($_POST['password'])){
    $username = $_POST["username"];
    $password = $_POST["password"];

    $stmt = $db->query("SELECT * FROM users WHERE username = '$username'");

    if($stmt->num_rows > 0) {
        $response['status'] = 'Username is already exist';
        http_response_code(400);
    }
    else{
        $stmt = $db->prepare("INSERT INTO users(username, password) VALUES (?, ?)");
        $stmt->bind_param("ss", $username, $password);
        $stmt->execute();
        $insertId = $stmt->insert_id;
        $stmt->close();
        $db->commit();s
        $response['status'] = 'New user is created.';
    }

}

else{
    $response['status'] = 'Username or password is missing.';
    http_response_code(400);
}

echo json_encode($response);
?>