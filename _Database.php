<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require_once ('_Globalls.php');

	/*
		if(!session_id())
		session_start();
	*/


class Database {
	private $host = _HOST;
	private $user = _USER;
	private $pass = _PASS;
	private $dbname = _DBNAME;

	private $dbh;
	private $error;
	private $stmt;

	public function __construct() {
		// Set DSN
		/* UPDATED JUNE2019 FIXED ERRORS WITH "ñ" SHIT*/

		$dsn = 'mysql:host=' . $this->host . ';dbname=' . $this->dbname.';charset=utf8;';
		// Set options
		$options = array (
				PDO::ATTR_PERSISTENT => true,
				// PDO::ATTR_EMULATE_PREPARES => true,
				PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
				PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8"
		);
		// Create a new PDO instanace
		try {
			$this->dbh = new PDO ($dsn, $this->user, $this->pass, $options);
		}		// Catch any errors
		catch ( PDOException $e ) {
			$this->error = $e->getMessage();
			echo $this->error;
		}
	}


	public function prepareQuery($query) {
		$this->stmt = $this->dbh->prepare($query);
	}


	public function bind($param, $value, $type = null) {
		if (is_null ( $type )) {
			switch (true) {
				case is_int ( $value ) :
					$type = PDO::PARAM_INT;
					break;
				case is_bool ( $value ) :
					$type = PDO::PARAM_BOOL;
					break;
				case is_null ( $value ) :
					$type = PDO::PARAM_NULL;
					break;
				default :
					$type = PDO::PARAM_STR;
			}
		}
		$this->stmt->bindValue ( $param, $value, $type );
	}


	public function execute(){
		// var_dump($this->stmt);die();
		return $this->stmt->execute();
	}

	public function closeCursor(){
		// var_dump($this->stmt);die();
		return $this->stmt->closeCursor();
	}
	//public function exec(){
	//	return $this->stmt->exec();
	//}

	public function resultset(){

		try {
			$this->stmt->execute();

			return $this->stmt->fetchAll(PDO::FETCH_OBJ);
		}
		finally {
			$this->closeCursor();
		}

	}


	public function singleRow(){
		try {
			$this->stmt->execute();

			return $this->stmt->fetch(PDO::FETCH_OBJ);
		}
		finally {
			$this->closeCursor();
		}
		$this->stmt->execute();

		return $this->stmt->fetch(PDO::FETCH_OBJ);
	}

	public function singleColumn(){
		try {
			$this->stmt->execute();

			return $this->stmt->fetchColumn(PDO::FETCH_OBJ);
		}
		finally {
			$this->closeCursor();
		}

	}

	public function rowCount(){

		return $this->stmt->rowCount();
	}


	public function lastInsertId(){

		return $this->dbh->lastInsertId();
	}


	public function beginTransaction(){

		return $this->dbh->beginTransaction();
	}


	public function endTransaction(){

		return $this->dbh->commit();
	}


	public function cancelTransaction(){

		return $this->dbh->rollBack();
	}

	public function superNinja(){
		 return $this->stmt->debugDumpParams();
	}
}


/*
dbName: projCdmdScholar
user:   cdmdUser
pass:   Y5b*7ou3


	private $host = 'localhost';
	private $user = 'cdmdUser';
	private $pass = 'Y5b*7ou3';
	private $dbname = 'projCdmdScholar';

[database]
dbhost = "localhost"
dbname = "atidb"
dbuname = "bonakid3plus"
dbpass = "3pataas"

[hash]
userkey = "testinghash"
*/
