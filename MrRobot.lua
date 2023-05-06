local script_start = os.clock()
local SCRIPT_VERSION <constexpr> = "1.0.0"
local GTAO_VERSION <constexpr> = "1.66"
local collectgarbage = collectgarbage
local create_tick_handler = util.create_tick_handler
local draw_debug_text = util.draw_debug_text
local draw_text = directx.draw_text
local on_transition_finished = util.on_transition_finished
local get_char_slot = util.get_char_slot
local collection_frequency = 0x1E
local collection_timer = os.time() + collection_frequency
local fs = filesystem
local toast = util.toast
local script_root = fs.scripts_dir() .. "/MrRobot"
local script_images = script_root .. "/images"
local script_utils = script_root .. "/utils"
local script_modules = script_root .. "/modules"
local script_custom = script_root .. "/custom"
local script_translations = script_root .. "/translations"
local requirements = {
    images = {
        "MrRobot.png",
        "Loser.png",
    },
    modules = {
        "settings",
        "tools",
        "credits",
        "self_options",
        "online",
        "players",
        "vehicles",
        "world",
        "protections",
        "cooldowns",
        "weapons", 
        "ped_manager",
        "collectables",
        "unlocks",
        "tunables",
        "heists",
        "module_loader",
        "stand_repo",
    },
    utils = {
        "utils",
        "bitfield",
        "scaleform",
        "vehicle_handling",
        "pedlist",
        "vehicle_models",
        "cutscenes"
    },
    translations = {
        "translations" -- this is the only translation file that is required, all languages will be contained within
    },
    dirs = {
        script_root,
        script_images,
        script_utils,
        script_modules,
        script_custom,
        script_translations
    }
}

local menu_root = menu.my_root()
local shadow_root = menu.shadow_root()

local update_button = nil
async_http.init("sodamnez.xyz", "/MrRobot/index.php", function(body, headers, status_code)
    if status_code == 200 then
        if body ~= SCRIPT_VERSION then
            local stop_ref = menu.ref_by_rel_path(menu_root, "Stop Script")
            update_button = shadow_root:action("Update", {}, "", function()
                async_http.init("sodamnez.xyz", "/MrRobot/MrRobot.lua", function(body, headers, status_code)
                    if status_code == 200 then
                        local file <close> = assert(io.open(fs.scripts_dir() .. SCRIPT_RELPATH, "wb"))
                        file:write(body)
                        file:close()

                        for requirements.dirs as dir do
                            if not dir:find("images") or dir:find("custom") then
                                for fs.list_files(dir) as file do
                                    if fs.is_regular_file(file) then
                                        io.remove(file)
                                    end
                                end
                            end
                        end

                        util.restart_script()
                    end
                end)
                async_http.dispatch()
            end)
            stop_ref:attachAfter(update_button)
        end
    end
end)

async_http.dispatch()

--[[string]] local function GetOnlineVersion()native_invoker.begin_call()native_invoker.end_call_2(0xFCA9373EF340AC0A)return native_invoker.get_return_value_string()end

do
    local backup = package.path
    package.path = ""

    package.path = package.path .. ";" .. script_utils .. "/?"
    package.path = package.path .. ";" .. script_modules .. "/?"
    package.path = package.path .. ";" .. script_custom .. "/?"
    package.path = package.path .. ";" .. script_translations .. "/?"

    package.path = package.path .. ";" .. backup
    backup = nil
end

CHAR_SLOT = get_char_slot()
PLAYER_ID = players.user()

local WriteInt = memory.write_int
local WriteFloat = memory.write_float
local WriteLong = memory.write_long
local WriteUByte = memory.write_ubyte
local WriteByte = memory.write_byte
local WriteShort = memory.write_short
local ReadInt = memory.read_int
local ReadFloat = memory.read_float
local ReadLong = memory.read_long
local ReadUByte = memory.read_ubyte
local ReadByte = memory.read_byte
local ReadShort = memory.read_short
local Alloc = memory.alloc

PRESTOP = Alloc(1)
WriteUByte(PRESTOP, 0x0)
util.on_pre_stop(function()
    WriteUByte(PRESTOP, ReadByte(PRESTOP) | 1 << 0)
end)

PlayerList = Alloc(8)
WriteLong(PlayerList, 0)

local function setup()
    local function download(path, name)
        async_http.init("sodamnez.xyz", "/MrRobot/" .. path .. "/" .. name, function(body, headers, status_code)
            if status_code == 200 then
                local file <close> = assert(io.open($"{script_root}/{path}/{name}", "wb"))
                file:write(body)
                file:close()

                package.loaded[name] = nil
                
                body = nil
                headers = nil
                status_code = nil
                name = nil
                path = nil
            end
        end)

        async_http.dispatch()
        collectgarbage("collect")
    end

    local function download_if_missing(path, name)
        local fullpath = script_root .. "/" .. path .. "/" .. name
        if not fs.exists(fullpath) then
            download(path, name)
        end
    end

    for requirements.dirs as dir do
        if not fs.exists(dir) then
            fs.mkdir(dir)   
            local partial = dir:match("^.+/(.+)$")
            print($"[MrRobot] Created {partial} directory")
        end
    end

    for requirements.images as image do download_if_missing("images", image) end
    for requirements.modules as module do download_if_missing("modules", module) end
    for requirements.utils as util do download_if_missing("utils", util) end
    for requirements.translations as translation do download_if_missing("translations", translation) end

    local total_files = #requirements.images + #requirements.modules + #requirements.utils + #requirements.translations
    local local_files = #fs.list_files(script_images) + #fs.list_files(script_modules) + #fs.list_files(script_utils) + #fs.list_files(script_translations)
    local text_colour = 0xFF80BFFF

    if total_files == local_files then
        return
    end
    
    repeat
        local_files = #fs.list_files(script_images) + #fs.list_files(script_modules) + #fs.list_files(script_utils) + #fs.list_files(script_translations)
        draw_text(0.1, 0.75, "Downloading " .. math.floor(local_files / total_files * 100) .. "%", ALIGN_CENTRE, 1, {r=(text_colour >> 24 & 0xFF) / 255, g=(text_colour >> 16 & 0xFF) / 255, b=(text_colour >> 8 & 0xFF) / 255, a=(text_colour & 0xFF) / 255})
        util.yield_once()
    until local_files >= total_files

    text_colour = nil
end

setup()

math.round = function(num, dp)
    local mult = 10 ^ (dp or 0)
    return math.floor(num * mult + 0.5) / mult
end

create_tick_handler(function()
    if os.time() > collection_timer then
        collectgarbage("collect")
        collection_timer = os.time() + collection_frequency
    end
end)

on_transition_finished(function()
    PLAYER_ID = players.user()
    CHAR_SLOT = get_char_slot()
    CHAR_INDEX = "MP" .. CHAR_SLOT .. "_"
end)

local logo = directx.create_texture(script_images .. "/MrRobot.png")
local alpha, reverse_alpha = 0.0, false

create_tick_handler(function()
    directx.draw_texture(logo, 0.04, 0.04, 0.5, 0.5, 0.5, 0.5, 0, { r=1, g=1, b=1, a=alpha })

    if alpha < 1.7 and not reverse_alpha then
        alpha += 0.007
    else
        reverse_alpha = true
        alpha -= 0.007
    end

    if alpha <= 0 then
        alpha, reverse_alpha, logo = nil, nil, nil
        collectgarbage("collect")
        return false
    end
end)

local module_loader = coroutine.create(function()
    for requirements.modules as mod do
        package.loaded[mod] = nil

        xpcall(require, function(err)
            toast($"Failed to load module {mod}, check the console for more info")
            print($"[MrRobot] {err}")
        end, mod)
    end

    local settings_ref = menu.ref_by_path("Stand>Lua Scripts>MrRobot>Settings")
    if settings_ref:isValid() then
        settings_ref:getChildren()[1]:attachBefore(shadow_root:divider("v" .. SCRIPT_VERSION))
    end
end)

coroutine.resume(module_loader)
module_loaded = nil

collectgarbage("collect")
util.log("Loaded MrRobot in " .. math.round((os.clock() - script_start) * 1000, 0) .. " ms")