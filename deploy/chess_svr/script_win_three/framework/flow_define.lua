STEP_SUCCEED = 0x11
STEP_STOP = 0x10


USER_STATUS = {}


USER_STATUS.sGetOut = 0 -- 0,离开了
USER_STATUS.sFree  = 1             -- 1,在房间站立
USER_STATUS.sSit   = 2             -- 2,坐在椅子上，没按开始
USER_STATUS.sReady = 3            -- 3,同意游戏开始
USER_STATUS.sPlaying = 4          -- 4,正在玩
USER_STATUS.sOffLine = 5          -- 5,断线等待续玩
USER_STATUS.sLookOn = 6            -- 6,旁观
USER_STATUS.sCreateTable = 7        -- 7,创建了房间
USER_STATUS.sCancelCreateTable = 8        -- 7,创建了房间
