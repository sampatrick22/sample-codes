<?php
require_once('_Database.php');
require_once('_chingChong.php');
require_once('addLogs.php');

date_default_timezone_set('Asia/Hong_Kong');

$chechong = new chingChong();
if($chechong->getSYSCODE()!=INFOSYSCODE){
  echo "session expired pls login again...";
  echo "<script> location.reload(true); </script>";
  exit;
  die();
}
$rtc = $chechong->getRTCLOGIN();
$userType = $chechong->getUserType();


$conn = mysqli_connect(_HOST, _USER ,_PASS, _DBNAME);


$query = '';
if($userType == _SUPER_ADMIN_){

  $query = "SELECT
    rtc,
    training_code,
    training_title,
    training_date,
    training_venue,
    training_type,
    vol1 AS objective,
    vol2 AS methodology,
    vol3 AS content,
    vol4 AS resource_speaker,
    vol5 AS time_allocation,
    vol6 AS venue_and_facilities,
    vol7 AS comments_and_recommendations,
    vol8 AS name,
    vol9 AS office


  FROM tbl_evalii WHERE tacr_validated='TRUE'";
}else{
  $query = "SELECT
    rtc,
    training_code,
    training_title,
    training_date,
    training_venue,
    vol1 AS objective,
    vol2 AS methodology,
    vol3 AS content,
    vol4 AS resource_speaker,
    vol5 AS time_allocation,
    vol6 AS venue_and_facilities,
    vol7 AS comments_and_recommendations,
    vol8 AS name,
    vol9 AS office


   FROM tbl_evalii WHERE tbl_evalii.rtc='$rtc' AND tbl_evalii.tacr_validated='TRUE'";
}




$result = mysqli_query($conn, $query);



$num_column = mysqli_num_fields($result);


$csv_header = '';
for($i=0;$i<$num_column;$i++) {
    $csv_header .= '"' . mysqli_fetch_field_direct($result,$i)->name . '",';
}

$csv_header .= "\n";

$csv_row ='';
while($row = mysqli_fetch_row($result)) {
	for($i=0;$i<$num_column;$i++) {
		$csv_row .= '"' . $row[$i] . '",';
	}
	$csv_row .= "\n";
}


/*#######################-logs-######################################*/
$user=$chechong->getUSERNAME();
$userfull=$chechong->getFULLNAME();
$office=$chechong->getRTCLOGIN();
$finaluser = $user." ($userfull) ";

$thingsdone = $finaluser.
              ' DOWNLOADED PARTICIPANTS EVAL ';

$thingsdidin = "-DOWNLOAD_PARTICIPANTS_EVAL-";

$logs=new Logs();
$logs->insertLogs($finaluser, $office, $thingsdone, $thingsdidin);
/*#######################-logs-######################################*/

header('Content-type: application/csv');
header('Content-Disposition: attachment; filename=PARTICIPANTSEVAL.csv');
echo $csv_header . $csv_row ."\n"."\n"."\n". '-- ';

exit;
?>
