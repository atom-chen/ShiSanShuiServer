

_GameModule = _GameModule or {}
_GameModule.log = _GameModule.log or  {}
_GameModule.log.tracetable = _GameModule.log.tracetable or function (...) print("no _GameModule.log.tracetable") end
_GameModule.log.traceplayer = _GameModule.log.traceplayer or function (...) print("no _GameModule.log.traceplayer") end
_GameModule.log.debug = _GameModule.log.debug or function (...) print("no _GameModule.log.debug") end
_GameModule.log.error = _GameModule.log.error or function (...) print("no _GameModule.log.error") end
_GameModule.log.smslog = _GameModule.log.smslog or function (...) print("no _GameModule.log.smslog") end

local function toTableLog(str)
    -- str = "[gid:" .. G_TABLEINFO._gid .. ",gsc:" .. G_TABLEINFO._gsc .. ",glv:" .. G_TABLEINFO._glv .. ",seat:" .. G_TABLEINFO._seat .. "] " .. str
    return str
end

function LOG_TABLE(format, ...)
    local str = nil
    if #arg > 0  then
            str = string.format(format, unpack(arg))
    else
        str = format
    end
    local info = debug.getinfo(2)
    local src = info.short_src ..":" .. info.linedefined .. "  "

    str = toTableLog(str)
    _GameModule.log.tracetable(G_TABLEINFO.tableid, src ..str)
end

function LOG_USER(uid, format, ...)
    local str = nil
    if #arg > 0  then
            str = string.format(format, unpack(arg))
    else
        str = format
    end

    
    str = "[LogUser:" .. uid .. "] " .. str

    local info = debug.getinfo(2)
    local src = info.short_src ..":" .. info.linedefined .. "  "

    str = toTableLog(str)
    _GameModule.log.tracetable(G_TABLEINFO.tableid, src ..str)
end

function LOG_DEBUG(format, ...)
    local str = nil
    if #arg > 0  then
            str = string.format(format, unpack(arg))
    else
        str = format
    end
    local info = debug.getinfo(2)
    local src = info.short_src ..":" .. info.linedefined .. "  "
    --_GameModule.log.debug(src ..str)
    str = toTableLog(str)
    _GameModule.log.tracetable(G_TABLEINFO.tableid, src ..str)
end

function LOG_ERROR(format, ...)
    local str = nil
    if #arg > 0  then
            str = string.format(format, unpack(arg))
    else
        str = format
    end
    local info = debug.getinfo(2)
    local src = info.short_src ..":" .. info.linedefined .. "  "

    str = toTableLog(str)

    _GameModule.log.tracetable(G_TABLEINFO.tableid, src ..str)
    _GameModule.log.error(src ..str)
end

function LOG_SMS(format, ...)
    local str = nil
    if #arg > 0  then
            str = string.format(format, unpack(arg))
    else
        str = format
    end
    local info = debug.getinfo(2)
    local src = info.short_src ..":" .. info.linedefined .. "  "

    str = toTableLog(str)
    _GameModule.log.tracetable(G_TABLEINFO.tableid, src ..str)
    _GameModule.log.smslog(src ..str)
end


