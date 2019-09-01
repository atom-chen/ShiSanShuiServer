
require "extern"
local OutScriptDir = "../"



function IsFileExists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end
function Mkdir(strFullFileName)
    local dirName = ""
    local t = string.split(strFullFileName, "/")
    for i = 1, #t - 1 do
        if i == 1 then
            dirName =  t[i]
        else 
            if t[i] ~= "" then
                dirName = dirName .. "/" .. t[i]
            end
        end
    end
    if dirName ~= "" and IsFileExists(dirName) == false then
        os.execute("mkdir " .. dirName)
    end

end


-- 将 点号分割的path 转成/
function GetPathDir(path)
    local p = "."
     local t = string.split(path, "\\.")
    for i = 1, #t  do
        if t[i] ~= "" then
            p = p .. "/" .. t[i]
        end
    end
    return p
end
function GetScriptName(path)
    local p = "."
    local t = string.split(path, "\\.")
    if #t > 0 then
        return t[#t]
    end
    return ""
end


function GetStepClassTmpl()
    local STEP_TMPL_FILE_PATH = "step_class.tmpl"
    local file = io.open(STEP_TMPL_FILE_PATH, "r")
    assert(file, "Open File Failed. Filename: " ..  STEP_TMPL_FILE_PATH)
    local context = file:read("*a")
    file:close()
    return context
end

function MakeStepFiles(step_config)
    if type(step_config) ~= "table" then return false end
    local strStepTml = GetStepClassTmpl()
    for name, _config in pairs(step_config) do
        local className = ClassName( name)
        local path = GetPathDir(_config.path)
        local context  = strStepTml
        local stageName = ClassName( name)
        context = string.gsub(context, "STEP_NAME", className)
        writeToFile(path, context)

    end
end



function MakeLogicFile_Step(name, stepConfig)
     if type(name) ~= "string" or type(stepConfig) ~= "table" then
        return false
    end
    local function GetTmpl()
        local STEP_TMPL_FILE_PATH = "logic_step.tmpl"
        local file = io.open(STEP_TMPL_FILE_PATH, "r")
        assert(file, "Open File Failed. Filename: " ..  STEP_TMPL_FILE_PATH)
        local context = file:read("*a")
        file:close()
        return context
    end
    local path = GetPathDir(stepConfig.path)
    local context  = GetTmpl()
    local stageName = ClassName( name)
    context = string.gsub(context, "STEP_NAME", name)
    writeToFile(path, context)
    -- write
    return true
end



function writeToFile(fileName, context)

    local path =  OutScriptDir .. "/" .. fileName .. ".lua"
     if IsFileExists(path)  == false then
        Mkdir(path)
        local file = io.open(path, "w+")
        print(path)
        assert(file, "Open File Failed. Filename" ..  path)
        file:write(context)
        file:close()
    end

end

