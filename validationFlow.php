<?php
  require_once('_Database.php');
	require_once('_chingChong.php');

  /*$tacrStatus = $TACRDETAILS->tacr_validated;*/

function sabakUser($TACRDETAILS){
  $accHunter=new \stdClass();
  $chechong = new chingChong;


  switch( $TACRDETAILS->tacr_validated ){
    case _TACR_NEW_:
      /*if($chechong->getUSERTYPE()!=_PO_ && $chechong->getUSERTYPE()!=_MNE_){
        $accHunter->requiredAcc="PO OR MNE";
        $accHunter->message="-CHANGE-ACC-TO-PROCEED-";
        echo json_encode($accHunter);
        exit;
        die();
      }*/
      $creator = $chechong->getUSERNAME().'-'.$chechong->getRTCLOGIN();

      if($TACRDETAILS->tacr_region != $chechong->getRTCLOGIN()){
        $accHunter->requiredAcc=$TACRDETAILS->tacr_region;
        $accHunter->message="-CHANGE-ACC-TO-PROCEED-";
        echo json_encode($accHunter);
        exit;
        die();
      }
      if($creator!=$TACRDETAILS->tacr_createdby){
        $accHunter->requiredAcc=$TACRDETAILS->tacr_createdby;
        $accHunter->message="-CHANGE-ACC-TO-PROCEED-";
        echo json_encode($accHunter);
        exit;
        die();
      }
    break;
    case _TACR_SUBMITTED_:
      if($chechong->getUSERTYPE()!=_MNE_ && $chechong->getUSERTYPE()!=_SUPER_ADMIN_){
        $accHunter->requiredAcc="MNE";
        $accHunter->message="-CHANGE-ACC-TO-PROCEED-";
        echo json_encode($accHunter);
        exit;
        die();
      }
    break;
    case _TACR_REVIEWED_:
      if($chechong->getUSERTYPE()!=_CHIEF_OR_DIRECTOR_){
        $accHunter->requiredAcc="CHIEF OR DIRECTOR";
        $accHunter->message="-CHANGE-ACC-TO-PROCEED-";
        echo json_encode($accHunter);
        exit;
        die();
      }
    break;
    case _TACR_APPROVED_:
      if($chechong->getUSERTYPE()!=_SUPER_ADMIN_){
        $accHunter->requiredAcc="SUPER-ADMIN";
        $accHunter->message="-CHANGE-ACC-TO-PROCEED-";
        echo json_encode($accHunter);
        exit;
        die();
      }
    break;
    case _TACR_VALIDATED_:
      if($chechong->getUSERTYPE()!=_SUPER_ADMIN_){
        $accHunter->requiredAcc="SUPER-ADMIN";
        $accHunter->message="-CHANGE-ACC-TO-PROCEED-";
        echo json_encode($accHunter);
        exit;
        die();
      }
    break;
  }
}
