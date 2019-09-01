-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_chat(stPlayer, msg)
    LOG_DEBUG("Run LogicStep do_chat")
    local content = msg._para.content
    --信息类型，1字符串，2快速表情，3语音,4 互动表情
    local contenttype = msg._para.contenttype

    if type(content) ~= 'string' then
        LOG_DEBUG("Run LogicStep do_chat=type==%s",type(content))
        LOG_DEBUG("Run LogicStep do_chat=err==%s",content)
        CSMessage.NotifyError(stPlayer, ERROR_PARAM_ERR)
        return STEP_FAILED
    end
    LOG_DEBUG("Run LogicStep do_chat===%s",content)
    local givewho
    if contenttype ==4 then
        givewho = msg._para.givewho
    end
    CSMessage.SendChatMessageToOther(stPlayer,content,contenttype,givewho)

    return STEP_SUCCEED
end


return logic_do_chat
