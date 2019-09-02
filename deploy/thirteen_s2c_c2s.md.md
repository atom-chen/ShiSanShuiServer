[TOC]

###2. 协议类型
```
EVENT_TYPE_RSP='rsp'
EVENT_TYPE_REQ='req'
EVENT_TYPE_NTI='nti'
EVENT_TYPE_ERR='err'
```
###3. 协议格式
####3.1 client发给server的 req类型的消息格式
```
host=dstars&uri=/chess/1&msgid=http_req@@@@
{
    "_check": "123456789", -----字符串
    "_ver": 1,
    "_dst": { JSON_OBJECT },
    "_events": [{
        "_cmd": "XXX",
        "_st": "XXX",
        "_para": { JSON_OBJECT }
    }, ----多个event
    ]
}
除非特别说明，本文档后面协议描述中只描述enent内容

服務端回包
{
    "_ver": "1.0.1",
    "_svr_t": "chess",
    "_svr_id": 1,
    "_check": "123456789",  ----客户端带什么回什么
    "_sn": 233, ---- 服务端回发给这个session的流水号，新enter时为1， （但重连不是1），每次加1. 为0表示session已经被删除了（multilogin)，为0xFFF0表示需要重连。
    "_events": [{
        "_cmd": "enter",
        "_para": {
            "_errno": 2003,
            "_errstr": "selectTableByPara Failed:2003"
        },
        "_src": "",
        "_st": "err"
    }]
}



```
####3.2 server发给client的 rsp/nti/err类型的消息格式
```
{
    "_check": "223343",
    "_sn": 1,
    "_ver": 1,
    "_events": [{
        "_cmd": "XXX",
        "_st": "XXX",
        "_src": "XXX",
        "timeo": 10,     ---- 超时时间, 可选字段。
        "_para": { JSON_OBJECT }
    }, ----多个event
    ]
}
本文档后面协议描述中只描述enent内容
```
###4. 协议定义及示例
####4.1 进入
#####1)enter(坐下）
- C2S req:我坐下
注意：协议头参数可带着_dst
```
host=dstars&uri=/chess/1&msgid=http_req@@@@
{
    "_check": "223343",
    "_ver": 1,
    "_dst": {---- 带着这个字段enter，表示想重入
        "_gt": 0,
        "_chair": 1
    },
    "_events": [
        {
            "_cmd": "enter",
            "_st": "req",
            "_para": {
                "_from": "byCard",
                "_gid": "11",
                "_gsc": "default",
                "_gt_key": "",
                "_gt_cfg": {
                    "accountc": {},
                    "cfg": {
						"pnum" : 4,    		 --人数(这个字段必须有，且名字不能改)
						"rounds" : 8,        --局数(这个字段必须有，且名字不能改)
						"nGhostAdd" : 0,     --加鬼牌(0不加，1加)
						"nColorAdd" : 0,     --加色(0不加，1加一色，2加二色)
						"nBuyCode": 0,       --买码(0不买，大于0 是选择的码牌值)(新修改的协议)
						"nWaterBanker": 0,    --水庄：0不是 1是
						"nMaxMult": 1,    	  --水庄，闲家最大倍数
						"nChooseCardTypeTimeOut":300       --摆牌超时时间（新加的协议）
						"nReadyTimeOut":300       --准备时间（新加的协议）					
                    },
                    "clog": {},
                    "cost": "2",
                    "ctime": "1498533736",
                    "expiretime": "1498540936",
                    "gamedir": "G_3",
                    "gid": "11",
                    "log": "",
                    "rid": "1106",
                    "rno": "272251",
                    "status": "0",
                    "uid": "1001",			--房主uid
                    "uri": "/chess/1"
                },
                "ability": {
                    "need_recommand": 1
                }
            }
        }
    ]
}
```
- S2C nti:某人坐下
```
{
   "_cmd" : "enter",
   "_src" : "p1",
   "_st" : "nti",
   "_para" : {
	  "gid": "11",
      "_chair" : 1,
      "_pid" : 2,
      "_uid" : 1001,
      "score" : { 
         "coin" : 0,
         "equ" : 0,
         "lose" : 0,
         "score" : 0,
         "time" : 0,
         "win" : 0
      }
   }
}
```
#####2)session（你的session）
- S2C nti:你的session，后续所有请求都要填充到_dst字段里
```
{
	"_cmd": "session",
	"_para": {
		"_chair": 2,
		"_gid": 18,
		"_glv": "",
		"_gsc": "default",
		"_gt": 0
	},
	"_src": "t",
	"_st": "nti"
}
```

#####3)game_cfg（游戏配置信息）
- S2C nti: 响应客户端的游戏配置信息请求
```
{
    "_cmd": "game_cfg",
    "_src": "p1",
    "_st": "nti",
    "_para": {
        "chairID": 1,	---- 你的座位
        "_gid": 11,
        "rid": "1106",
        "rno": "272251",	--房号
		"owner_uid": 1001,	---- 房主uid(水庄的时候用到)
        "nCurrJu": 1,		--当前几局
        "nJuNum": 8,		--总共几局
        "nMoneyMode": 3,	--房间模式，1：积分，2：货币，3：房卡
        "nPlayerNum": 2,	--几人桌
        "GameSetting": {
            "bSupportBuyCode": false,		--是否买码
            "bSupportGhostCard": false,		--是否有鬼牌
            "bSupportWaterBanker": false,	--是否是水庄
            "nSupportAddColor": 0,			--加色：0不加 1加一色 2加二色
            "nSupportMaxMult": 1		--闲家加倍:1-5倍
        },
        "TimerSetting": {
			"readyTimeOut": 10,				--准备时间
            "chooseCardTypeTimeOut": 10,	--摆牌时间
			--下面四个是计算比牌时间的主要参数
            "allShootTime": 2,				--全垒打耗时
            "oneCompareTime": 3,			--玩家一对一三墩比牌耗时
            "oneShootTime": 2,				--一次打枪耗时
            "oneSpecialTime": 2,			--特殊牌耗时
			
			"TimeOutLimit": -1,
        }
    }
}
```
####4.2 发牌
#####1)ask_ready（等待举手）
- S2C nti:后台问客户端UI，chair1玩家，你要举手吗？
```
{
    "_cmd": "ask_ready",
    "_st": "nti",
	"_src" : "p1",
    "timeo": -1,    ---- ready超时时间，-1表示永不超时
    "_para": {
    }
}
```
#####2)ready（举手）
- C2S req:我举手
```
{
    "_cmd": "ready",
    "_st": "req",
    "_para": {
    }
}
```
- S2C nti:某人举手
```
{
   "_cmd" : "ready",
   "_src" : "p1",
   "_st" : "nti",
   "_para" : {
      "_chair" : 1,
      "_uid" : 1001
   }
}

```
#####3)game_start(游戏开始)
- S2C nti 通知游戏开始
```
{
   "_cmd" : "game_start",
   "_src" : "p1",
   "_st" : "nti",
   "_para" : {}
}

```
#####4)ask_mult(等待闲家选择倍数)
nti:
```
{
    "_cmd": "ask_mult",
    "_st": "req",
    "timeo": 15, -- 闲家选择倍数超时时间
    "_para": {           
       "optional" : [1,2,3,4,5] -- 有几种选择
    }
}

```
#####5)mult(选择倍数)
- C2S req:我选择倍数
```
{
    "_cmd": "mult",
    "_st": "req",
    "_para": {
       "nBeishu": 1 
    }
}

```
- S2C nti:选择倍数通知(回复自己选择倍数)： 
```
{
    "_cmd": "mult",
    "_st": "nti",
    "_para": {
        "p1": 1
    }
}

```
- S2C nti:选择倍数通知(所有人的选择倍数)： 
```
{
    "_cmd": "all_mult",
    "_st": "nti",
    "_para": [-- 对应每个位置上的选择倍数结果
		1,2,...
    ]
}
#####6)deal(发牌)
- S2C nti
给chair1发消息，通知他自己的牌 以及庄家、骰子 特殊牌型
```
{
    "_cmd": "deal",
    "_src": "p1",
    "_st": "nti",
    "_para": {
		"nNeedRecommend": 0,--是否有服务端下发推荐牌型,0不需要 1需要
        "nSpecialType": 0,	--0表示不是特殊牌型
		"nSpecialScore": 0,	--特殊牌型对应的积分
		"nLeftCardNums":0,  		--剩余牌数
        "stCards": [--牌最好转成16进制
            19,
            8,
            2,
            45,
            38,
            56,
            23,
            50,
            60,
            52,
            43,
            59,
            36
        ]
    }
}
```
- S2C nti
- 通知玩家推荐牌型
```
{
   "_cmd" : "recommend",
   "_src" : "p1",
   "_st" : "nti",
   "_para" : {
   	 "recommendCards": [--牌最好转成16进制
            {"cards":[19,
            8,
            2,
            45,
            38,
            56,
            23,
            50,
            60,
            52,
            43,
            59,
            36], "types":[2,1,2]},{},{}
        ]
   }
}
#####7)ask_choose(选择牌型即摆牌)
- S2C nti
- 通知玩家摆牌
```
{
   "_cmd" : "ask_choose",
   "_src" : "p1",
   "_st" : "nti",
   "timeo" : 10,	-- 摆牌超时时间
   "_para" : {},
}

#####8)choose_normal(选好牌型)
- C2S req:选好牌型
```
{
    "_cmd": "choose_normal",
    "_st": "req",
    "_para": 
	"cards": [----1-5是后墩 6-10是中墩 11-13是前墩
			60,
			59,
			56,
			52,
			50,
			45,
			43,
			8,
			23,
			38,
			36,
			19,
			2
        ],
    }
}
```
- S2C nti:某人已经选好牌型
```
{
    "_cmd": "choose_ok",
    "_st": "nti",
    "_src": "p4",
    "_para": {
    }
}
```

#####9)choose_sp(选特殊牌型)
- C2S req:选特殊牌型
```
{
    "_cmd": "choose_sp",
    "_st": "req",
    "_para": {
		"nSelect": 0	--0不要特殊牌型 1要特殊牌行
    }
}
- S2C nti:某人已经选好牌型
```
{
    "_cmd": "choose_ok",
    "_st": "nti",
    "_src": "p4",
    "_para": {
    }
}
```

#####10)compare_start(比牌开始)
- S2C nti:通知比牌开始
```
{
   "_cmd" : "compare_start",
   "_src" : "p1",
   "_st" : "nti",
   "_para" : {},
}
```
#####11)compare_result(比牌结果)
- S2C nti:比牌结果
```
{
    "_cmd": "compare_result",
    "_src": "p1",
    "_st": "nti",
    "_para": {--玩家p1比牌结果详细数据
        "_chair": "p1",
        "_uid": 1001,
        "nAllShootChairID": 0,	--全垒打玩家椅子id, 0表示没有全垒打
		"stLeftCards":[1,2,3,...]	--剩余牌
        "stAllCompareData": [---所有玩家的牌型、牌墩、打枪列表
            {
                "chairid": 1,		--玩家的椅子id
                "nFirstType": 1,	--前墩牌型
                "nSecondType": 1,	--中墩牌型
				"nThirdType": 6,	--后墩牌型
                "nSpecialType": 0,	--特殊牌型 0表示不是特殊牌型
				"nOpenFirst": 1,	--前墩的翻牌顺序
				"nOpenSecond": 1,	--中墩的翻牌顺序
				"nOpenThird": 1,	--后墩的翻牌顺序
				"nOpenSpecial": 0,	--特殊牌型的翻牌顺序
				"nTotallScore":10,	--最后个人总得分
                "stCards": [----1-5是后墩 6-10是中墩 11-13是前墩
                    60,
                    59,
                    56,
                    52,
                    50,
                    45,
                    43,
                    8,
                    23,
                    38,
                    36,
                    19,
                    2
                ],
                "stShoots": {}--玩家的打枪列表 里面是其他玩家的椅子id
            },
			...		--这里有所有同桌玩家的compareData
        ],
        "stCompareScores": [	--p1和其他玩家的详细比牌积分
            {
				"toChairid": 2,			--和谁比牌 椅子id
                "nFirstScore": -1,		--前墩正常分
                "nFirstScoreExt": 0,	--前墩额外分
                "nSecondScore": -1,
                "nSecondScoreExt": 0,
                "nThirdScore": 1,
                "nThirdScoreExt": 0,
				"nSpecialScore": 0		--特殊牌分
				"nShoot":0,				--打枪：-1我被对方打枪 0双方都没有打枪 1我打对方枪
				"nShootMult":2,			--打枪的倍数
				"nHasCode":0,			--码牌: 0没有 1有
				"nCodeMult":2,			--码牌的倍数
				"nWanterMult":1,		--选择的倍数(水庄的时候用到)
				"nFinalScore":			--和toChairid比最后积分(包括打枪，买码)
            },
			...		--这里有所有同桌玩家的scores
        ]
    }
}
```
#####12)compare_end(比牌结束)
- S2C nti:比牌结束
```
{
    "_cmd": "compare_end",
	"_src" : "p1",
    "_st": "nti",
    "_para": {
    }
}
```
#####13)cancle_compare(取消比牌)
- C2S req:取消比牌
```
{
    "_cmd": "cancle_compare",
    "_st": "req",
    "_para": {
    }
}
```
#####14)room_sum_score(开房以来的累计积分)
- S2C nti:开房以来的累计积分
```
{
    "_cmd": "room_sum_score",
	"_src" : "p1",
    "_st": "nti",
    "_para": {
		"nRoomSumScore":10			--房间累计积分
    }
}
```


####4.4 结算
#####1)rewards(当局结算)
```
{
    "_cmd": "rewards",
    "_src": "p1",
    "_st": "nti",
    "_para": {
        "curr_ju": 1,		--当前几局
        "ju_num": 8,		--总共几局
		"banker": 1,		--这局谁是庄家(水庄)
        "rid": "1106",
        "ts": 1498569113,
        "uri": "/chess/1",
		"discontinue": 1,        -- 中止了，若此字段为1，则rewards数据无效
        "rewards": [	--所有人的结算记录
            {
                "_chair": "p1",		--p1玩家记录
                "_uid": 1001,
                "nFirstType": 1,	--前墩牌型
                "nSecondType": 1,	--中墩牌型
				"nThirdType": 6,	--后墩牌型
				"nSpecialType": 0,	--特殊牌型 0表示不是
				"nSpecialNums": 0,	--特殊牌型数量
                "nShootNums": 0,	--打枪数量
                "nAllShootNums": 0,	--全垒打数量
				"nWinNums": 0,		--赢的数量
                "all_score": -1,	--总积分
                "stCards": [----1-5是后墩 6-10是中墩 11-13是前墩
                    60,
                    59,
                    56,
                    52,
                    50,
                    45,
                    43,
                    8,
                    23,
                    38,
                    36,
                    19,
                    2
                ]
            },
			...		--这里有所有同桌玩家的rewards
        ]
    }
}
```
#####2)gameend(游戏结束)
chair1的游戏结束通知
```
{
    "_cmd": "gameend",
	"_src" : "p1",
    "_st": "nti",
    "_para": {}
}
```
#####3)points_refresh(数据刷新)

数据有更新时，后台发给客户端。 
积分 
胜局数 
败局数 
平局数 
逃跑数
```
向chair1玩家通知分数类的数据更新
{
    "_cmd": "points_refresh",
	"_src" : "p1",
    "_st": "nti",
    "_para": {
        "win":1, 	----胜利次数
        "lose":1,	----失败次数
        "equ":1,	----平局次数
        "esc":1,	----逃跑次数
        "coin":0,	----金币
		"score":100,----积分
    }
}
```
####4.5 玩家重入
玩家重入，需要先query_state取uri及_dst，再enter；重入成功则S会回发：
1. 各家enter
2. 各家ready
3. 各家选择倍数
4. 各家摆牌情况
5. 各家比牌情况
5. sync_table
注意，当前状态仅在ask_XXX时会下问

#####1)query_state(状态查询)
- C2S req:查询
注意：协议头参数不一样
```
host=dstars&uri=/online/1&msgid=http_req@@@@ ---- 注意，参数与chess不一样
{
    "_check": "223343",
    "_ver": 1,
    "_events": [{
        "_cmd": "query_state",
        "_st": "req",
        "_para": {
          "_gids": [1, 22, ...] ---- 客户端支持的游戏id列表
        }
    }]
}
```
- S2C rsp: 回复
```
离线回复
{
    "_cmd": "query_state",
    "_para": {
        "_dst": {}
    },
    "_src": "online",
    "_st": "rsp"
}
在线回复 重入请求时需带上 _dst 和 para 字段信息
{
    "_check": "0",
    "_events": [
        {
            "_cmd": "query_state",
            "_para": {
                "_dst": {
                    "_chair": 1,             -- 桌内位置号
                    "_gid": 18,              -- gameid
                    "_gsc": "default",       -- gsc
                    "_gt": 0,                -- 桌子号
                    "_svr_id": 1,            
                    "_svr_t": "chess",
                    "action": 2,
                    "ext": "{\"_from\":1}\n",
                    "host": "dstars",        -- host
                    "opt": 1,
                    "ret": 1,
                    "status": "enter",    
                    "time": 1500342381,
                    "uri": "/chess/1"        -- uri
                }
            },
            "_src": "online",
            "_st": "rsp"
        }
    ],
    "_svr_id": 1,
    "_svr_t": "online"
}
```
#####2)enter(重入）
与4.1的enter一致，但需要带着_dst
#####3)sync_begin(重入同步开始)
- S2C nti:
```
{
   "_cmd" : "sync_begin",
   "_para" : {},
   "_src" : "p1",
   "_st" : "nti"
}
```
#####4)sync_table(重入同步表)
- S2C nti
```
{
	"_cmd": "sync_table",
	"_src": "p1",
	"_st": "nti"
	"_para": {
		"sCurrStage": "choose",		--游戏当前处于哪个阶段  mult  choose compare
		"nWaterBanker": 1,			--水庄：0不是 1是
		"banker": 1,				--庄家(水庄有效)
		"nChoose": 0,				--自己的摆牌状态：0没摆，1已出牌，2出特殊牌
		"nMult": 1,					--自己是否已经选择倍数(对庄家无效), -1表示没有选
		"nSpecialType": 0,			--自己特殊牌型：0不是
		"nSpecialScore": 0,			--特殊牌型对应的积分
		"stCardTypes":[ 			--自己的牌墩牌型(依次为后墩，中墩，前墩)
			9,
			6,
			1
		],
		"stCards": [				--自己的牌墩信息，根据摆牌状态来确定nChoose==0或2则是原始牌, nChoose==1已出牌(1-5是后墩,6-11是中墩,11-13后墩)				
			19,
			8,
			2,
			45,
			38,
			56,
			23,
			50,
			60,
			52,
			43,
			59,
			36
		],
		"recommendCards": [--推荐牌型数据(目前由客户端处理 服务端发空)（摆牌阶段还没有出牌nChoose==0会发送）
            {"cards":[19,
            8,
            2,
            45,
            38,
            56,
            23,
            50,
            60,
            52,
            43,
            59,
            36], "types":[2,1,2]},{},{}
        ],
		"stCompare": {	--自己与其他玩家的比牌详细信息(比牌阶段compare才会下发)
			
		},
		"stPlayerState": [	--玩家状态列表：0没人, 1坐着, 2已准备
			2,
			2
		],
		"stPlayerUid": [	--玩家uid列表
			1001,
			1002
		],
		"stPlayerChoose": [         --玩家摆牌阶段玩家的摆牌状态：0没摆，1已摆
			0,
			1
		],
		"stLeftCards":[1,2,3,...],	--剩余牌(在sCurrStage=="compare"  才会下发)
		"nLeftCardNums":0			--剩余牌数量
	}
}
```
#####5)sync_end(重入同步结束)
- S2C nti:
```
{
   "_cmd" : "sync_end",
   "_para" : {},
   "_src" : "p1",
   "_st" : "nti"
}
```
####4.6 申请退出
#####1)vote_draw（请求和局）
情景1、玩家拉起一轮求和投票过程。 
后台收到vote_draw，并检查到当前不存在投票过程，则会向所有客户端广播发送vote_draw_start，表明是新一轮投票 
情景2、已存在一个投票过程，玩家同意/拒绝求和
```
{
  "_cmd": "vote_draw"
  "_src":"",
  "_st":"req",
  "_para":{
    "accept": true //值定义, true:同意，false:拒绝
   }
}
```
通知p1投票动作，p1同意求和
```
{
  "_cmd": "vote_draw"
  "_src":"p1",  
  "_st":"nti",
  "_para":{
    "accept": true //值定义, true:同意，false:拒绝
   }
}
```
#####2)vote_draw_start(和局投票过程开始)
通知所有人，某个玩家拉起了投票过程
```
{
  "_cmd": "vote_draw_start"
  "_src":"",  
  "_st":"nti",
  "_para":{
       "timeout":60
   }
}
```
#####3)vote_draw_end(和局投票过程结束)
通知所有人，投票过程已结束
```
{
  "_cmd": "vote_draw_end"
  "_src":"",  
  "_st":"nti",
  "_para":{
       "confirm": true //true: 协商和局成立； false:协商和局失败或超时
   }
}
```
#####4)leave(玩家退出)
- C2S req:退出
 
```
{
    "_cmd": "leave",
    "_st": "req",
    "_para": {
    }
}
```
- S2C nti
```
{
   "_cmd": "leave",
    "_src": "p1",
	"_st": "nti",
    "_para": {
		"active": 1,
        "_chair": 1,
        "_uid": 2384853,
        "_pid": 1,
        "gid": 18,
        "score": {
            "equ": 0,
            "win": 0,
            "coin": 0,
            "score": 0,
            "time": 0,
            "lose": 0
        },
		reason = 7
	}
}
```
#####5)dissolution(房主解散桌子)
- C2S req:退出
 房主p1请求解散桌子
```
{
	"_cmd": "dissolution",
	"_src":"p1",  
	"_st":"req",
	"_para":{
		"gid": "11",		--游戏gid
		"gsc":"default"		--
	}
}
```
- S2C nti
通知所有人，房主p1解散桌子
```
{
	"_cmd": "dissolution"
	"_src":"p1",  
	"_st":"nti",
	"_para":{}
}
```
####4.7 其它
#####1)player_info(暂时不用)
玩家个人信息
- S2C nti:某人的个人信息
```
{
    "_cmd": "player_info",
    "_st": "nti",
    "_src": "p4",
    "_para": {
        "point": 1, --积分
    }
}
```
#####2)offline(玩家断线)
- S2C nti
```
{
    "_cmd": "offline",
    "_src": "p1",
	"_st": "nti",
    "_para": {
		"active": 1,
        "_chair": 1,
        "_uid": 2384853,
        "_pid": 1,
        "gid": 18,
        "score": {
            "equ": 0,
            "win": 0,
            "coin": 0,
            "score": 0,
            "time": 0,
            "lose": 0
        }
	}
}
```
#####3)autoplay(托管）
C2S  req: 我请求设置托管状态
```
{
    "_cmd": "autoplay",
    "_st": "req",
    "_para": {
          "setStatus" : true  ----true：设置为托管状态；false：设置为非托管状态
    }
}
```
S2C  nti:某人(chair1)修改了他的托管状态设置
```
{
    "_cmd": "autoplay",
    "_st": "nti",
    "_src": "p4",
    "_para": {
           "setStatus" : true  ----true：设置为托管状态；false：设置为非托管状态
    }
}
```

#####4)chat(聊天信息)
- C2S req: chair1发出聊天消息
```
{
    "_cmd": "chat",
    "_st": "nti",
    "_para": {
        "contenttype": 1, ---- 信息类型，1字符串，2快速表情，3语音
         "content":"hello, i'm robot" ----客户端需要过滤特殊字符，防止json格式被破坏
    }
}
```
- S2C nti:
```
{
    "_cmd": "chat",
    "_st": "nti",
    "_src": "p4",
    "_para": {
         "content":"hello, i'm robot", ----客户端需要过滤特殊字符，防止json格式被破坏
         "contenttype": 1               -- 内容类型
    }
}
```
#####5)multilogin（多处登录通知）
```
{
    "_cmd": "multilogin"
}

```

#####6)heart_beat(心跳)
```
{
    "_cmd": "heart_beat"
}
```
- S2C nti
```
{
    "_cmd": "heart_beat"
}
```
#####7)pushmsg（信息推送）
- S2C nti
```
{
    "_cmd": "pushmsg",
    "_para": {
        "uid": "4343", //接收人的uid
        "msg": "信息", //推送的信息
    }
}
```

####8)error (错误)
- S2C nti
```
{
   "_cmd" : "error",
   "_para" : {
      "id" : 10000
   },
   "_src" : "p1",
   "_st" : "nti"
}
```

ecs::E_RET_SUCC
####5. 错误码定义
```
enum ChessSvr_Error
{
  //system error
  TE_System = 1001,
  TE_TimeOut = 1002,
  TE_JsonError = 1003, //post的数据json解析失败

  //error on enter
  TE_Enter_NotOnTable = 2001, //重回坐下时候,没有找到指定的桌子,或者不再桌上
  
  TE_Enter_ServerFull = 2002, //服务器已满
  TE_Enter_NoTable =2003, //桌子已经用完了
  TE_Enter_ServerBusy =2004, //服务器繁忙,创建transaction失败

  TE_Enter_OnOtherTable = 2005, //玩家坐下的时候已经在玩同APPID的其他GameCfg游戏, 无法重新坐下
  TE_Enter_LockFailed = 2006,
  TE_Enter_GetInfoFailed = 2007,
  TE_Enter_OnLogin = 2008, //坐下时候注册失败, 可能是更新路由失败


  TE_Enter_TableFull = 2009, //选定的桌子上人数已满, 或者座位上已经有人

  TE_Enter_LevelLimit = 2010, //场次限制无法进入

  TE_Enter_NoGame = 2011, //没有对应的游戏玩法
  TE_Enter_NoKey = 2012, //bykey坐下, 但是又没带KEY
  TE_Enter_NoContainer = 2013, //坐下时候没有找到对应的模式

  //error  on GameEvent
  TE_Event_NotOnTable =3001,
  TE_Event_NetChanged =3002, //网络已经断线了, 需要重回

  //error on Leave
  TE_Leave_InGame = 4001,


  TE_Count
};
```
