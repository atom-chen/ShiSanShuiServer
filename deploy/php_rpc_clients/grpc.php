#!/usr/bin/php
<?php
include_once __DIR__."/rpc.lib.php";
include_once __DIR__."/GPBMetadata/Online.php";
include_once __DIR__."/GPBMetadata/Ecs.php";
include_once __DIR__."/GPBMetadata/Event.php";
include_once __DIR__."/GPBMetadata/Chess.php";
class grpc{
	private $rpclib = '';
	private $try = 2;//重试2次
	public function __construct(){
		$this->rpclib = new rpclib('../GlobalConfig/LanSvr.ini');
	}
	
	/**
	* 公用的call方法
	*/
	private function _call($server, $method, $req, $rsp){
		$i = 0;
		while($i < $this->try){
			$i++;
			$ret = $this->rpclib->call_rpc($server, $method, $req, $rsp);
			if($ret !== false){
				break;
			}
		}
		if($ret === false){
			return false;
		}
		return true;
	}
	
	private function _callbyid($server_name, $server_id, $method, $req, $rsp){
		$i = 0;
		while($i < $this->try){
			$i++;
			$ret = $this->rpclib->call_rpc_positive($server_name, $server_id, $method, $req, $rsp);
			if($ret !== false){
				break;
			}
		}
		if($ret === false){
			return false;
		}
		return true;
	}

	/**
	* @access public
    * @param $uid 用户ID
	* @param $msg 发送的数据
    * @return array
	* 向客户端推送数据
	*/
	public function push($uid, $msg){
		include_once(__DIR__."/online_svr/PushRequest.php");
		include_once(__DIR__."/online_svr/PushResult.php");
		$req = new \Online_svr\PushRequest();
		$rsp = new \Online_svr\PushResult();
		if($uid){
			$req->setPushtype(1);
			$req->setUid($uid);
		}else{
			$req->setPushtype(3);
		}
		$req->setSvrname("chess");
		$req->setSvrid(1);
		$req->setMsg($msg);
		if($this->_call("online", "Push", $req, $rsp)){
			return ['ret'=> $rsp->getRet(), 'msg'=> $rsp->getRetmsg()];
		}
		return false;
	}
	
		/**
	* @access public
    * @param $uid 用户ID
	* @param $msg 发送的数据
    * @return array
	* 向客户端推送数据
	*/
	public function pushById($server_id, $msg){
		include_once(__DIR__."/chess_svr/MonitorRequest.php");
		include_once(__DIR__."/chess_svr/MonitorResult.php");
		$req = new \Chess\MonitorRequest();
		$rsp = new \Chess\MonitorResult();

		$req->setMsg($msg);
		if($this->_callbyid("chess", $server_id, "Monitor", $req, $rsp)){
			return ['ret'=> $rsp->getRet(), 'msg'=> $rsp->getRetmsg()];
		}
		return false;
	}

	/**
	* @access public
    * @param $uid 用户ID
	* @param $gid 游戏 ID
	* @param $coin 操作的游戏币 0 获取 负数 减 正数 + 
    * @return array
	* 金币类操作
	*   E_RET_SUCC = 0;
	*	E_RET_FAIL = 1;
	*	E_RET_NO_DATA = 2;//服务端没有查到相关数据
	*	E_RET_REQ_ERR = 3;//请求信息有错误
	*	E_RET_ERR  = 4;  //服务端出错
	*/
	public function doCoin($uid, $gid, $coin=0, $wmode=9999, $desc='', $cop=0){
		$uid = (int)$uid;
		$gid = (int)$gid;
		$coin = (int)$coin;
		if(!$uid || !$gid){
			return false;
		}
		$this->_ecsLoad();
		$req = new \Ecs\Request();
		$rsp = new \Ecs\Result();
		$coinMsg = new \Ecs\Coin_t();
		$headMsg = new \Ecs\Head_t();
		
		$coinMsg->setOpcode($wmode);
		$coinMsg->setOpcodeSub($cop);
		$coinMsg->setDesc($desc);
		if($coin > 0){//给用户增加游戏币
			$coinMsg->setAction(2);
			$coinMsg->setCoin($coin);
		}elseif($coin < 0){//给用户减游戏币
			$coinMsg->setAction(2);
			$coinMsg->setCoin($coin);
		}else{//获取游戏币
			$coinMsg->setAction(1);
		}
		$headMsg->setGid($gid);//游戏ID
		$headMsg->setUid($uid);//用户ID
		
		$req->setCoin($coinMsg);
		$req->setHead($headMsg);
		if($this->_call("ecs", "EcsRequest", $req, $rsp)){
			$ret = $rsp->getCoin();
			$code = $ret->getRet();
			if($code != 1){
				var_dump($code);
				//oo::oerror()->logs(date('Y-m-d H:i:s'). json_encode(array($uid, $gid, $coin, $code)) , 'grpc.coin', 10);
				return false;
			}
			return $ret->getCoin();
		}
		return false;
	}



	/**
	* 检查用户是否在桌子上
	*/
	public function doLock($uid, $gid){
		$uid = (int)$uid;
		$gid = (int)$gid;
		$coin = (int)$coin;
		if(!$uid || !$gid){
			return false;
		}
		$this->_ecsLoad();
		$req = new \Ecs\Request();
		$rsp = new \Ecs\Result();
		
		$headMsg = new \Ecs\Head_t();
		$headMsg->setGid($gid);//游戏ID
		$headMsg->setUid($uid);//用户ID
		$lockMsg = new \Ecs\Lock_t();
		$lockMsg->setAction(1);
		$req->setLock($lockMsg);
		$req->setHead($headMsg);
		if($this->_call("ecs", "EcsRequest", $req, $rsp)){
			$ret = $rsp->getLock();
			$code = $ret->getRet();
			if($code == 2){//没有锁住
				return false;
			}else{
				$svrt = $ret->getSvrT();
				$svid = $ret->getSvrId();
				$gid = $ret->getGid();
				$glv = $ret->getGlv();
				$gsc = $ret->getGsc();
				$action = $ret->getAction();
				$opt = $ret->getOpt();
				$gt = $ret->getGt();
				$chair = $ret->getChair();
				$time= $ret->getTime();
				$ext = $ret->getExt();
				$uri = '/'.$svrt.'/'.$svid;
				$aCser = array('_chair'=>$chair,'_gid'=>$gid, '_glv'=>$glv, '_gsc'=>$gsc, '_gt'=>$gt, '_svr_id'=>$svid, '_svr_t' =>$svrt, 'action'=>$action, 'ext'=>$ext,'opt'=>$opt, 'time'=>$time, 'uri'=>$uri );
				return $aCser;
			}
		}
		return false;
	}

	private $_escHasLoad = false;
	private function _ecsLoad(){
		if(!$this->_escHasLoad){
			include_once(__DIR__."/ecs_svr/Request.php");
			include_once(__DIR__."/ecs_svr/Result.php");
			include_once(__DIR__."/ecs_svr/Coin_t.php");
			include_once(__DIR__."/ecs_svr/Head_t.php");
			include_once(__DIR__."/ecs_svr/Lock_t.php");
			include_once(__DIR__."/ecs_svr/Score_t.php");
			$this->_escHasLoad = true;
		}
	}
	
	//事件 
	//更新桌子 array('_act'=>'modify','_table'=>'game_hnmj','_db'=>'dstars','_idfield'=>'uid','uid'=>5)
	public function event(){
		
	}
}

$rpc = new grpc();
$server_id = 1;
$msg = "{\"cmd\":\"kick_player\", \"uid\":1}";
$msg2 = "{\"cmd\":\"dissolution_room\", \"trid\":100}";
var_dump($rpc->pushById($server_id, $msg2));
//var_dump($rpc->doCoin($uid,1 ,10));


