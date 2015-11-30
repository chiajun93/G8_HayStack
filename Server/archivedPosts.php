<?php
include_once 'config.php';

//Get user's location
$latitude = $_GET["latitude"];
$longitude = $_GET["longitude"];

date_default_timezone_set('America/Chicago');

//Get all posts within 5 miles of user's location
 $stmt = $db->query("SELECT *,
     ( 3959 * acos( cos( radians('$latitude') )
     * cos( radians( latitude ) )
     * cos( radians( longitude ) - radians('$longitude') )
         + sin( radians('$latitude') )
     * sin( radians( latitude ) ) ) ) AS distance FROM posts HAVING distance < 10 ORDER BY distance;");

$stmt = $db->query("SELECT * FROM posts");

//Store all posts in an array
$response = array();
if($stmt->num_rows > 0){
    while($row = $stmt->fetch_array()){
        // echo "Posted On:".$row["posted"]."<br>";
        $time = time() - strtotime($row["posted"]);

        $time = ($time<1)? 1 : $time;

        $timeInMin = $time/60;
        
        if($timeInMin <= $row["duration"]){
            // echo "Hours: ".$timeInMin."\xA";
            // echo "Duration: ".$row["duration"]."\xA";
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
}

//Return response in json format
if($response != false){
  echo json_encode($response);
}
?>