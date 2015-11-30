<?php
session_set_cookie_params(31556926);
session_start([
	'cookie_lifetime' => 31556926,
	]);

/**
* Database config variables
*/
define("DB_HOST", '10.25.71.66');
define("DB_USER", 'dbu309grp08');
define("DB_PASSWORD", 'xAnkfcUckKX');
define("DB_DATABASE", 'db309grp08');
$db = new mysqli(DB_HOST,DB_USER,DB_PASSWORD,DB_DATABASE);
?>