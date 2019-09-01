#!/bin/lua
package.path = package.path..';'..'../config/?.lua' .. ";" .. '../common/?.lua'
require "debug"
require "extern"
require "build_util"
local json = require "cjson"
local args = {}
local KEY_FLOW = "flow"
local KEY_NAME = "name"


local argVal = {}
for _,field in pairs(arg) do

    local indexV = string.find(field, "=")
    if indexV then
            local key =  string.sub(field, 1, indexV - 1 )
            local value = string.sub(field, indexV + 1)
            argVal[key] = value
    end
end



local function LoadFlowAndMakeFiles(roleName, jsonFileName)
    local from = io.open(jsonFileName, "r")
    local context = from:read("*a")
    from:close()
    local configFlow = json.decode(context)
    if configFlow == nil then
        print ("json decode error")
        return
    end
    local function GetTmpl()
        local STEP_TMPL_FILE_PATH = "logic_step.tmpl"
        local file = io.open(STEP_TMPL_FILE_PATH, "r")
        assert(file, "Open File Failed. Filename: " ..  STEP_TMPL_FILE_PATH)
        local context = file:read("*a")
        file:close()
        return context
    end

    local  function doMakeOne(roleName, config)
        if config.do_script then
            local context = GetTmpl()
            local path  = GetPathDir(config.do_script)
            local name = GetScriptName(config.do_script)
            context = string.gsub(context, "STEP_NAME", name)
            context = string.gsub(context, "OBJECT_NAME", roleName)
            if config.select_type == "event" then
                context = string.gsub(context, "MESSAGE_NAME", "event")
            else
                context = string.gsub(context, "MESSAGE_NAME", "msg")
            end

            writeToFile(path, context)
        else
            if config.child == nil then return end

            for _,child in pairs(config.child) do
                doMakeOne(roleName, child)
            end
        end

    end
    doMakeOne(roleName, configFlow)

end


if argVal[KEY_FLOW] == nil or  argVal[KEY_NAME] == nil  then
    print("Usage: ./make_lua_scripts.lua  name=xxx flow=flow_xxx.json  ")
    for name,val in pairs(argVal) do
        print(name .. " : " .. val)
    end
    return
end


LoadFlowAndMakeFiles(argVal[KEY_NAME], argVal[KEY_FLOW])






