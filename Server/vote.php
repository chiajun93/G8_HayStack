<?php
include_once 'config.php';

if(isset($_POST["postID"]) && isset($_POST["action"])){
    //Get postID and action
    $postID = $_POST["postID"];
    $userID = $_SESSION['userID'];
    $action = $_POST["action"];



    //Store added vote in an array
    $tmp = array();
    $stmt = $db->query("SELECT * FROM posts WHERE id = '$postID'");
    $row = $stmt->fetch_array();
    if($stmt->num_rows > 0) {

        //Insert postID and action into vote database
        $stmt = $db->prepare("INSERT INTO vote(postID, userID, action) VALUES (?,?,?)");
        $stmt->bind_param("iii", $postID, $userID, $action);
        $stmt->execute();
        $stmt->close();
        $db->commit();

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
    else{
        echo json_encode("Post is not found.");
    }

}

else{
    http_response_code(400);
}

?>