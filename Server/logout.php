<?php
include_once 'config.php';

if(isset($_SESSION['userID'])){
  session_destroy();
  $response["status"] = "Session is destroyed.";
}

else{
  $response["status"] = "Session is not set.";
}

echo json_encode($response);
?>