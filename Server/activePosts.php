<?php
include_once 'config.php';

//Get user's location
$latitude = $_GET["latitude"];
$longitude = $_GET["longitude"];


//Get all posts within 10 miles of user's location
$stmt = $db->query("SELECT *, 
    ( 3959 * acos( cos( radians('$latitude') ) 
    * cos( radians( latitude ) ) 
    * cos( radians( longitude ) - radians('$longitude') ) 
    + sin( radians('$latitude') ) 
    * sin( radians( latitude ) ) ) ) AS distance FROM posts HAVING distance < 10 ORDER BY distance;");

//Store all posts in an array
$response = array();
if($stmt->num_rows > 0){
    while($row = $stmt->fetch_array()){
        $tmp = array();
        $tmp["id"] = $row["id"];
        $tmp["text"] = $row["text"];
        $tmp["posted"] = $row["posted"];
        $tmp["duration"] = $row["duration"];
        $tmp["status"] = $row["status"];
        $tmp["reward"] = $row["reward"];
        $tmp["latitude"] = $row["latitude"];
        $tmp["longitude"] = $row["longitude"];
        array_push($response, $tmp);
    }
}

//Return response in json format
if($response != false){
  echo json_encode($response);
}
?>