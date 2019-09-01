#!/usr/bin/php
<?php
include_once __DIR__."/rpc.lib.php";
include_once __DIR__."/GPBMetadata/Online.php";
include_once __DIR__."/GPBMetadata/Ecs.php";
include_once __DIR__."/GPBMetadata/Event.php";

include_once(__DIR__."/ecs_svr/Request.php");
include_once(__DIR__."/ecs_svr/Result.php");
include_once(__DIR__."/ecs_svr/Coin_t.php");
include_once(__DIR__."/ecs_svr/Head_t.php");
class grpc{
	private $rpclib = '';
	public function __construct(){
		$this->rpclib = new rpclib('/home/lwh/svn/chess_cpp/deploy/GlobalConfig/LanSvr.ini');
	}
	
	/**
	* 向客户端推送数据
	*/
	public function push($uid, $msg){
		include_once(__DIR__."/online_svr/PushRequest.php");
		include_once(__DIR__."/online_svr/PushResult.php");
		$req = new \Online_svr\PushRequest();
		$rsp = new \Online_svr\PushResult();
		$req->setUid($uid);
		$req->setMsg($msg);
		$ret = $this->rpclib->call_rpc("online", "Push", $req, $rsp);
		if($ret === false){
			return false;
		}
		return ['ret'=> $rsp->getRet(), 'msg'=> $rsp->getRetmsg()];
	}
	
	/**
	* 获取游戏币
	*/
	public function getCoin(){
		
	}
	
	/**
	* 增减游戏币
	*/
	public function addCoin($uid, $coin, $gid){
		
	}
	
	/**
	* 金币类操作
	*/
	public function ecsRequest($uid){
		$req = new \Ecs\Request();
		$rsp = new \Ecs\Result();
		$coinMsg = new \Ecs\Coin_t();
		$coinMsg->setAction(1);
		$coinMsg->setCoin(10);
		
		$headMsg = new \Ecs\Head_t();
		$headMsg->setGid(4);//游戏ID
		$headMsg->setUid($uid);//用户ID
		
		$req->setCoin($coinMsg);
		$req->setHead($headMsg);
		$ret = $this->rpclib->call_rpc ("ecs", "EcsRequest", $req, $rsp);
		//echo "ret===".var_export($ret,1)."==".var_export($rsp,1)."=====\n";
		if($ret === false){
			return false;
		}
		return ['coin'=> $rsp->getCoin(), 'head'=> $rsp->getHead()];
	}
}

$a = new grpc();
var_export($a->ecsRequest(100231));
