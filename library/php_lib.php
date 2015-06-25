<?php
//include_once( __dir__ . '/config.php' );
/*
$GLOBALS['config']['db']['db_host'] = MYSQL_HOST;
$GLOBALS['config']['db']['db_port'] = MYSQL_PORT;
$GLOBALS['config']['db']['db_user'] = MYSQL_USER;
$GLOBALS['config']['db']['db_pass'] = MYSQL_PASS;
$GLOBALS['config']['db']['db_name'] = MYSQL_DB;
 * */

/*
 * HTTP GET Request
*/
function get($url, $param = null) {
    if($param != null) {
        $query = http_build_query($param);
        $url = $url . '?' . $query;
    }
    $ch = curl_init();
    if(stripos($url, "https://") !== false){
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
    }

    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1 );
    $content = curl_exec($ch);
    $status = curl_getinfo($ch);
    curl_close($ch);
    if(intval($status["http_code"]) == 200) {
        return $content;
    }else{
        echo $status["http_code"];
        return false;
    }
}

/*
 * HTTP POST Request
*/
function post($url, $param) {
    $ch = curl_init();
    if(stripos($url, "https://") !== false) {
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
    }
    $data = array();
    foreach($param as $key=>$val) {
        $data[] = $key . "=" . urlencode($val);
    }
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1 );
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, join("&", $data));
    $content = curl_exec($ch);
    $status = curl_getinfo($ch);
    curl_close($ch);
    if(intval($status["http_code"]) == 200) {
        return $content;
    } else {
        echo $status["http_code"];
        return false;
    }
}

// db function
function _db_connect() {
    $db_host = $GLOBALS['config']['db']['db_host'];
    $db_user = $GLOBALS['config']['db']['db_user'];
    $db_pass = $GLOBALS['config']['db']['db_pass'];
    $db_name = $GLOBALS['config']['db']['db_name'];
    $db_port = $GLOBALS['config']['db']['db_port'];
    $GLOBALS['conn'] = new mysqli($db_host, $db_user, $db_pass, $db_name, $db_port=3306);
    if($GLOBALS['conn']->connect_error) {
        return false;
        exit('Connect Error(' . $GLOBALS['conn']->connect_errno . ')'
            . $GLOBALS['conn']->connect_error);
    }
    $GLOBALS['conn']->set_charset('utf8');
}

function conn() {
    if(!isset($GLOBALS['conn']) || !is_resource($GLOBALS['conn'])) {
        _db_connect();
    }

    if(is_resource($GLOBALS['conn'])) {
        if(!$GLOBALS['conn']->ping()) {
            $GLOBALS['conn']->close();
            _db_connect();
        }
    }

    if(is_resource($GLOBALS['conn'])) {
        return $GLOBALS['conn'];
    }

    return false;
}

function get_data($sql, $conn=null) {
    if($conn == null ) $conn = conn();
    $conn = $GLOBALS['conn'];
    $data = array();
    $i = 0;
    $result = $conn->query($sql);
    if($result) {
        while($row = $result->fetch_array()) {
            $data[] = $row;
        }
    } else {
        return false;
    }
    $result->close();

    if(count($data) > 0) {
        return $data;
    } else {
        return false;
    }
}

function get_line($sql, $conn = null) {
    $data = get_data($sql , $conn);
    return @reset($data);
}

function get_var($sql, $conn = null) {
    $data = get_line($sql , $conn);
    return $data[@reset(@array_keys($data))];
}

function get_var_array($sql, $conn = null) {
    $data=get_data($sql, $conn);
    if(!$data) {
        return false;
    } else {
        $ret = array();
        foreach($data as $d) {
            $ret[] = reset($d);
        }
        return $ret;
    }
}

function get_last_id($conn = null) {
    if($conn == null) $conn = conn();
    return get_var("SELECT LAST_INSERT_ID()", $conn);
}

function run_sql($sql, $conn = null) {
    if($conn == null) $conn = conn();
    $conn = $GLOBALS['conn'];
    return $conn->query($sql);
}

function conn_errno() {
    return conn()->errno;
}

function conn_error() {
    return conn()->error;
}

function conn_close($conn = null) {
    if($conn == null) {
        $conn = $GLOBALS['conn'];
    }

    $conn->close();
}
?>
