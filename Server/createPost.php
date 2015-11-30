<?php
include_once 'config.php';

if(isset($_POST["text"]) && isset($_POST["duration"]) && isset($_POST["reward"]) && isset($_POST["latitude"]) && isset($_POST["longitude"])){
    $poster = 1;
    $text = $_POST["text"];
    $duration = $_POST["duration"];
    $reward = $_POST["reward"];
    $latitude = $_POST["latitude"];
    $longitude = $_POST["longitude"];
    $stmt = $db->prepare("INSERT INTO posts(poster, text, duration, reward, latitude, longitude) VALUES (?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("isiidd", $poster, $text, $duration, $reward, $latitude, $longitude);
    $stmt->execute();
    $insertId = $stmt->insert_id;
    $stmt->close();
    $db->commit();

    $tmp = array();
    $stmt = $db->query("SELECT * FROM posts WHERE id = '$insertId'");
    $row = $stmt->fetch_array();
    if($stmt->num_rows > 0) {
        $tmp["id"] = $row["id"];
        $tmp["text"] = $row["text"];
        $tmp["posted"] = $row["posted"];
        $tmp["duration"] = $row["duration"];
        $tmp["status"] = $row["status"];
        $tmp["reward"] = $row["reward"];
        $tmp["latitude"] = $row["latitude"];
        $tmp["longitude"] = $row["longitude"];
    }

    if($tmp != false){
        echo json_encode($tmp);
    }

}

else{
  http_response_code(400);
}
?>