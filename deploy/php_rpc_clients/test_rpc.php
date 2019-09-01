#!/usr/bin/php
<?php

require_once(__DIR__."/rpc.lib.php");

require_once(__DIR__."/GPBMetadata/Online.php");

require_once(__DIR__."/online_svr/PushRequest.php");
require_once(__DIR__."/online_svr/PushResult.php");

$req = new \Online_svr\PushRequest();
$rsp = new \Online_svr\PushResult();

//$req->setPushtype(2);
$req->setPushtype(3);
$req->setSvrname("chess");
$req->setSvrid(1);
$req->setUid(1002);
$req->setMsg("AAAABBBBCCCCDDDDEEEEFFFFGGGGHHHH");

$rpclib = new rpclib("/home/test5/work/chess_cpp/deploy/GlobalConfig/LanSvr.ini");

$ret = $rpclib->call_rpc ("online", "Push", $req, $rsp);
if ($ret === false) {
	echo "Failed to CALL.";
	exit;
}

echo "ret=".$rsp->getRet()."; retmsg=".$rsp->getRetmsg();

var_dump ($rsp);
