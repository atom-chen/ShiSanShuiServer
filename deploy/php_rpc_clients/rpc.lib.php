<?php
define ("LanSvrIniPath", "/home/test/pack/GlobalConfig/LanSvr.ini");

class rpclib 
{
    private $inipath;

    function __construct($lansvrini=LanSvrIniPath)
    {
        $this->inipath = $lansvrini;
    }
    private function pack_str($s)
    {
        return pack("na*", strlen($s), $s);
    }
    private function pack_mem($m)
    {
        return pack("na*", strlen($m)+2, $m);
    }
    private function find_server_addr($ini, $server)
    {
        //read LanSvr.ini
        $cmd = "grep $server $ini";
        $fp = @popen ($cmd, "r");
        if ($fp === false) 
        {
            return false;
        }
        $ss = array();
        while ( ($line = fgets($fp)) != false) 
        {
            $one = array();
            $n = sscanf($line, "%[^ \t]%hu%*[ \t]%[^ \t]%hu", $one['svr'], $one['sid'], $one['ip'], $one['port']);
            //echo "line: $line, scanf: ret=$n, ".var_export($one, 1)."\n";
            if ($n != 5) 
            {
                continue;
            }
            $ss[] = $one;
        }
        pclose($fp);

        return $ss;
    }
    private function send_with_resp ($ip, $port, $context)
    {
        $fd = @socket_create(AF_INET, SOCK_STREAM, SOL_TCP);
        // var_dump($fd);
        if ($fd===false) return false;
        $ret = @socket_connect ($fd, $ip, $port);
        if ($ret===false) return false;

        $slen = strlen ($context);
        $ret = @socket_write ($fd, $context);
        if ($ret != $slen) {
            return false;
        }
        $rcvbuf = @socket_read ($fd, 4096);

        @socket_close ($fd);

        return $rcvbuf;
    }
    private function pack_req ($server, $req_param, $fn)
    {
        //开头是全长，各体有各长，字符串也有长
        $head = pack("N", 0) 
            . $this->pack_str("msg.lan.rpc_".$server)
            . pack("N5", 0, 100, 0, 0x3D, 0x3E) 
            . $this->pack_str($fn);
        $reqstr = $req_param->serializeToString();
        $sndbuf = $this->pack_mem($head) . $this->pack_mem($reqstr);
        return $this->pack_mem($sndbuf);
    }
    private function unpack_rsp ($server, $rspbuf, $fn)
    {
        $head = pack("N", 0) 
            . $this->pack_str("msg.lan.rpc_".$server)
            . pack("N5", 0, 100, 0, 0x3D, 0x3E) 
            . $this->pack_str($fn);
	$len = 2 + 2 + strlen($head)+2;
        if (strlen($rspbuf) < $len) {
	    echo "LEN1=".strlen($rspbuf).", LEN2=". $len;
            return false;
        }
        $rspbuf = substr($rspbuf, $len);
        return $rspbuf;
    }
    function call_rpc($server, $fn, $req_param, &$rsp_param)
    {
	    $ss = $this->find_server_addr ($this->inipath, $server);
        if ($ss===false || count($ss) < 1) {
            echo "RPC Not Found SERVER $server in ".$this->inipath."\n";
            return false;
        }
        //var_dump ($ss);
        $ip = $ss[0]['ip'];
        $port = $ss[0]['port'];

        $context = $this->pack_req ($server, $req_param, $fn);
        //var_dump($context);
        $rcvbuf = $this->send_with_resp ($ip, $port, $context);
        //echo "rcvbuf======".var_export($rcvbuf,1)."=====".bin2hex($rcvbuf)."====\n";
        if (!$rcvbuf || strlen($rcvbuf)==0) {
            echo "RPC Failed to send request.\n";
            return false;
        }

        //unpack
        $rsp = $this->unpack_rsp ($server, $rcvbuf, $fn);
        if ($rsp === false) {
            echo "RPC Failed to unpack response.===".bin2hex($rcvbuf)."===\n";
            return false;
        }
	//echo "rsp====".bin2hex($rsp)."====\n";
        $rsp_param->mergeFromString($rsp);
        return true;
    }



    function call_rpc_positive($svrname, $svrnum, $fn, $req_param, &$rsp_param)
    {
        $ss = $this->find_server_addr ($this->inipath, $svrname);
        if ($ss===false || count($ss) < 1) {
            echo "RPC Not Found SERVER $server in ".$this->inipath."\n";
            return false;
        }

        $ip = '';
        $port = '';

        $bRet =  $this->get_ip_by_svrname($svrname, $svrnum, $ss, $ip, $port);
        if(!$bRet)
        {
            return false;
        }

        //var_dump ($ss);
        //$ip = $ss[0]['ip'];
        //$port = $ss[0]['port'];

        $context = $this->pack_req ($svrname, $req_param, $fn);
        //var_dump($context);
        $rcvbuf = $this->send_with_resp ($ip, $port, $context);
        //echo "rcvbuf======".var_export($rcvbuf,1)."=====".bin2hex($rcvbuf)."====\n";
        if (!$rcvbuf || strlen($rcvbuf)==0) {
            echo "RPC Failed to send request.\n";
            return false;
        }

        //unpack
        $rsp = $this->unpack_rsp ($svrname, $rcvbuf, $fn);
        if ($rsp === false) {
            echo "RPC Failed to unpack response.===".bin2hex($rcvbuf)."===\n";
            return false;
        }
    //echo "rsp====".bin2hex($rsp)."====\n";
        $rsp_param->mergeFromString($rsp);
        return true;
    }


    function get_ip_by_svrname($svrname, $svrnum, $svrdata, &$strIP, &$strPort)
    {
        $bRet = false;
        foreach($svrdata as $key=>$val)
        {
            if($val['svr'] == $svrname && $val['sid'] == $svrnum )
            {
                $strIP   = $val['ip'];
                $strPort = $val['port'];
                $bRet = true;
                break;
            }
        }
        return $bRet;
    }
}





// function __autoload($class_name)
// {
//     if (file_exists(__DIR__."/".$class_name.".php")) {
//         require_once (__DIR__."/".$class_name.".php");
//     }
// }
require_once(__DIR__."/GPBMetadata/Google/Protobuf/Internal/Descriptor.php");
require_once(__DIR__."/Google/Protobuf/Internal/Message.php");
require_once(__DIR__."/Google/Protobuf/descriptor.php");
require_once(__DIR__."/Google/Protobuf/Internal/DescriptorPool.php");
require_once(__DIR__."/Google/Protobuf/Internal/DescriptorProto_ExtensionRange.php");
require_once(__DIR__."/Google/Protobuf/Internal/DescriptorProto.php");
require_once(__DIR__."/Google/Protobuf/Internal/DescriptorProto_ReservedRange.php");
require_once(__DIR__."/Google/Protobuf/Internal/EnumBuilderContext.php");
require_once(__DIR__."/Google/Protobuf/Internal/EnumDescriptorProto.php");
require_once(__DIR__."/Google/Protobuf/Internal/EnumOptions.php");
require_once(__DIR__."/Google/Protobuf/Internal/EnumValueDescriptorProto.php");
require_once(__DIR__."/Google/Protobuf/Internal/EnumValueOptions.php");
require_once(__DIR__."/Google/Protobuf/Internal/FieldDescriptorProto_Label.php");
require_once(__DIR__."/Google/Protobuf/Internal/FieldDescriptorProto.php");
require_once(__DIR__."/Google/Protobuf/Internal/FieldDescriptorProto_Type.php");
require_once(__DIR__."/Google/Protobuf/Internal/FieldOptions_CType.php");
require_once(__DIR__."/Google/Protobuf/Internal/FieldOptions_JSType.php");
require_once(__DIR__."/Google/Protobuf/Internal/FieldOptions.php");
require_once(__DIR__."/Google/Protobuf/Internal/FileDescriptorProto.php");
require_once(__DIR__."/Google/Protobuf/Internal/FileDescriptorSet.php");
require_once(__DIR__."/Google/Protobuf/Internal/FileOptions_OptimizeMode.php");
require_once(__DIR__."/Google/Protobuf/Internal/FileOptions.php");
require_once(__DIR__."/Google/Protobuf/Internal/GeneratedCodeInfo_Annotation.php");
require_once(__DIR__."/Google/Protobuf/Internal/GeneratedCodeInfo.php");
require_once(__DIR__."/Google/Protobuf/Internal/GPBDecodeException.php");
require_once(__DIR__."/Google/Protobuf/Internal/GPBLabel.php");
require_once(__DIR__."/Google/Protobuf/Internal/GPBType.php");
require_once(__DIR__."/Google/Protobuf/Internal/GPBUtil.php");
require_once(__DIR__."/Google/Protobuf/Internal/GPBWire.php");
require_once(__DIR__."/Google/Protobuf/Internal/InputStream.php");
require_once(__DIR__."/Google/Protobuf/Internal/MapEntry.php");
require_once(__DIR__."/Google/Protobuf/Internal/MapField.php");
require_once(__DIR__."/Google/Protobuf/Internal/MessageBuilderContext.php");
require_once(__DIR__."/Google/Protobuf/Internal/MessageOptions.php");
require_once(__DIR__."/Google/Protobuf/Internal/MethodDescriptorProto.php");
require_once(__DIR__."/Google/Protobuf/Internal/MethodOptions_IdempotencyLevel.php");
require_once(__DIR__."/Google/Protobuf/Internal/MethodOptions.php");
require_once(__DIR__."/Google/Protobuf/Internal/OneofDescriptorProto.php");
require_once(__DIR__."/Google/Protobuf/Internal/OneofField.php");
require_once(__DIR__."/Google/Protobuf/Internal/OneofOptions.php");
require_once(__DIR__."/Google/Protobuf/Internal/OutputStream.php");
require_once(__DIR__."/Google/Protobuf/Internal/RepeatedField.php");
require_once(__DIR__."/Google/Protobuf/Internal/ServiceDescriptorProto.php");
require_once(__DIR__."/Google/Protobuf/Internal/ServiceOptions.php");
require_once(__DIR__."/Google/Protobuf/Internal/SourceCodeInfo_Location.php");
require_once(__DIR__."/Google/Protobuf/Internal/SourceCodeInfo.php");
require_once(__DIR__."/Google/Protobuf/Internal/UninterpretedOption_NamePart.php");
require_once(__DIR__."/Google/Protobuf/Internal/UninterpretedOption.php");
