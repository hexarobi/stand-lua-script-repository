-- LANCESCRIPT
script_version = 11.2
all_used_cameras = {}
natives_version = "1676318796"
util.require_natives(natives_version)
ocoded_for = 1.66
is_loading = true
ls_debug = false
all_vehicles = {}
all_objects = {}
all_players = {}
all_peds = {}
all_pickups = {}
local _math = 6663*32707
handle_ptr = memory.alloc(13*8)
player_cur_car = 0
good_guns = {0, 453432689, 171789620, 487013001, -1716189206, 1119849093}
util_alloc = memory.alloc(8)

notify_mode = 2
notify_sounds = true 

store_dir = filesystem.store_dir() .. '\\lancescript\\'
lyrics_dir = store_dir .. '\\lyrics\\'
translations_dir = store_dir .. '\\translations\\'
resources_dir = filesystem.resources_dir() .. '\\lancescript\\'
relative_translations_dir = "./store/lancescript/translations/"

if not filesystem.is_dir(store_dir) then
    filesystem.mkdirs(store_dir)
end

if not filesystem.is_dir(translations_dir) then 
    filesystem.mkdirs(translations_dir)
end

if not filesystem.is_dir(lyrics_dir) then 
    filesystem.mkdirs(lyrics_dir)
end

local function table_size(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

-- credit http://lua-users.org/wiki/StringRecipes
local function ends_with(str, ending)
    return ending == "" or str:sub(-#ending) == ending
 end

local translations = {}
setmetatable(translations, {
    __index = function (self, key)
        return key
    end
})

local translation_dir_files = {}
local just_translation_files = {}
for i, path in ipairs(filesystem.list_files(translations_dir)) do
    local file_str = path:gsub(translations_dir, '')
    translation_dir_files[#translation_dir_files + 1] = file_str
    if ends_with(file_str, '.lua') then
        just_translation_files[#just_translation_files + 1] = file_str
    end
end

local updated = false
if not table.contains(translation_dir_files, 'last_version.txt') then 
    updated = true
    local file = io.open(translations_dir .. "/last_version.txt",'w')
    file:write(script_version)
    file:close()
end

-- get version from file
local f = io.open(translations_dir .. "/last_version.txt",'r')
version_from_file = f:read('a')
f:close()
if tonumber(version_from_file) < script_version then
    local file = io.open(translations_dir .. "/last_version.txt",'w')
    file:write(script_version)
    file:close()
    updated = true
end

-- do not play with this unless you want shit breakin!
local need_default_translation
local fallback = false
if not table.contains(translation_dir_files, 'english.lua') or updated then 
    need_default_translation = true
    async_http.init('gist.githubusercontent.com', '/stakonum/302f8534e2fca83db59f07cff8a7bbf4/raw', function(data)
        local file = io.open(translations_dir .. "/english.lua",'w')
        file:write(data)
        file:close()
        need_default_translation = false
    end, function()
        util.toast('!!! Failed to retrieve default translation table. All options that would be translated will look weird. Please check your connection to GitHub.')
        fallback = true
    end)
    async_http.dispatch()
else
    need_default_translation = false
end

-- BEGIN ANONYMOUS USAGE TRACKING 
async_http.init('pastebin.com', '2JtCCekD', function() end)
async_http.dispatch()
-- END ANONYMOUS USAGE TRACKING 

while need_default_translation and not fallback do 
    util.toast("Looks like there was an update! Installing default/english translation now.")
    util.yield()
end

local selected_lang_path = translations_dir .. 'selected_language.txt'
if not table.contains(translation_dir_files, 'selected_language.txt') then
    local file = io.open(selected_lang_path, 'w')
    file:write('english.lua')
    file:close()
end

-- read selected language 
if not fallback then
    local selected_lang_file = io.open(selected_lang_path, 'r')
    local selected_language = selected_lang_file:read()
    if not table.contains(translation_dir_files, selected_language) then
        util.toast(selected_language .. ' was not found. Defaulting to English.')
        translations = require(relative_translations_dir .. "english")
    else
        translations = require(relative_translations_dir .. '\\' .. selected_language:gsub('.lua', ''))
    end
end


function notify(text)
    util.toast('[' .. translations.script_name_pretty .. '] ' .. text)
end

if PED == nil then
    util.show_corner_help(translations.natives_error .. 'natives-' .. natives_version .. '.lua\n' .. translations.natives_error_2)
    menu.focus(menu.ref_by_path("Stand>Lua Scripts>Repository>natives-" .. natives_version))
    util.stop_script()
end

function get_user_primary_color()
    local color = {}
    color.r = menu.get_value(menu.ref_by_command_name("primaryred")) / 100
    color.g = menu.get_value(menu.ref_by_command_name("primarygreen")) / 100
    color.b = menu.get_value(menu.ref_by_command_name("primaryblue")) / 100
    color.a = menu.get_value(menu.ref_by_command_name("primaryopacity")) / 100
    return color
end

current_toasts = {}

-- toast renderer
util.create_tick_handler(function()
    local current_y_pos = 0.00
    local text_scale = 0.6
    for index, toast in pairs(current_toasts) do
        -- if a notif has expired, delete it
        if current_y_pos == 0.00 then 
            current_y_pos = 0.04 
        else
            current_y_pos += 0.07
        end
        if ((os.clock() - toast.start_time) >= toast.display_time) then
            table.remove(current_toasts, index)
            return
        end

        local scale_x, scale_y = directx.get_text_size(toast.text, text_scale)
        local min_scale_x, min_scale_y = directx.get_text_size(translations.script_name_pretty, 0.6)

        scale_x += 0.05
        scale_y += 0.02

        directx.draw_rect(0.5 - (scale_x / 2), current_y_pos, scale_x, scale_y, {r=0, g=0, b=0, a=0.7})
        directx.draw_rect(0.5 - (scale_x / 2), current_y_pos - (scale_y/2), scale_x, 0.025, {r = 0, g = 0, b = 0, a = 1})
        directx.draw_text(0.5, current_y_pos + (scale_y / 2), toast.text, 5, text_scale, {r=1, g=1, b=1, a=1}, false)
        directx.draw_text(0.5, current_y_pos - (scale_y / 2), translations.script_name_pretty, 1, 0.6, {r=1, g=1, b=1, a=1}, false)
    end
    current_y_pos = 0.00
end)


-- holiday
local today = os.date('%m/%d')
if not SCRIPT_SILENT_START then 
    if today == "10/31" then 
        notify(translations.happy_halloween)
    elseif today == '11/24' then
        notify(translations.happy_thanksgiving)
    elseif today == '12/25' then 
        notify(translations.merry_christmas)
    elseif today == '12/31' then
        notify(translations.new_years_eve)
    elseif today == '01/01' then
        notify(translations.new_years_day)
    end
end

-- log if verbose/debug mode is on
local function ls_log(content)
    if ls_debug then
        notify(content)
        util.log(translations.script_name_for_log .. content)   
    end
end

-- filesystem handling and logo 
if not filesystem.is_dir(resources_dir) then
    notify(translations.resource_dir_missing)
end

-- logo display
if SCRIPT_MANUAL_START then
    lancescript_logo = directx.create_texture(resources_dir .. 'lancescript_logo.png')
    AUDIO.PLAY_SOUND(-1, "OPEN_WINDOW", "LESTER1A_SOUNDS", 0, 0, 1)
    logo_alpha = 0
    logo_alpha_incr = 0.01
    logo_alpha_thread = util.create_thread(function (thr)
        while true do
            logo_alpha = logo_alpha + logo_alpha_incr
            if logo_alpha > 1 then
                logo_alpha = 1
            elseif logo_alpha < 0 then 
                logo_alpha = 0
                util.stop_thread()
            end
            util.yield()
        end
    end)

    logo_thread = util.create_thread(function (thr)
        starttime = os.clock()
        local alpha = 0
        while true do
            directx.draw_texture(lancescript_logo, 0.08, 0.08, 0.5, 0.5, 0.5, 0.5, 0, 1, 1, 1, logo_alpha)
            timepassed = os.clock() - starttime
            if timepassed > 3 then
                logo_alpha_incr = -0.01
            end
            if logo_alpha == 0 then
                util.stop_thread()
            end
            util.yield()
        end
    end)
end

-- start organizing the MAIN lists (ones just at root level/right under it)
-- BEGIN SELF SUBSECTIONS

local self_root = menu.list(menu.my_root(), translations.me, {translations.me_cmd}, translations.me_desc)
local chauffeur_root = menu.list(self_root, translations.chauffeur, {translations.chauffeur}, translations.chauffeur_desc)
local rideable_animals_root = menu.list(self_root, translations.rideable_animals, {"rideableanimals"}, "")
local my_vehicle_root = menu.list(self_root, translations.my_vehicle, {translations.my_vehicle_cmd}, translations.my_vehicle_desc)
local combat_root = menu.list(self_root, translations.combat, {translations.combat_cmd}, translations.combat_desc)

-- END SELF SUBSECTIONS
-- BEGIN ONLINE SUBSECTIONS
local online_root = menu.list(menu.my_root(), translations.online, {translations.online_cmd}, translations.online_desc)
local players_root = menu.list(menu.my_root(), translations.players, {"lanceplayers"}, "")
local friends_in_this_session = {}
local modders_in_this_session = {}
local friends_in_session_list = menu.list_action(players_root, translations.friends_in_session, {"friendsinsession"}, "", friends_in_this_session, function(pid, name) menu.trigger_commands("p" .. players.get_name(pid)) end)
local modders_in_session_list = menu.list_action(players_root, translations.modders_in_session, {"moddersinsession"}, "", modders_in_this_session, function(pid, name) menu.trigger_commands("p" .. players.get_name(pid)) end)
local recoveries_root = menu.list(online_root, translations.recoveries, {"lsrecoveries"}, "")
local detections_root = menu.list(online_root, translations.detections, {translations.detections_cmd}, "")
local protections_root = menu.list(online_root, translations.protections, {translations.protections_cmd}, translations.protections_desc)
local randomizer_root = menu.list(online_root, translations.randomizer, {translations.randomizer_cmd}, translations.randomizer_desc)
local speedrun_root = menu.list(online_root, translations.speedrun, {translations.speedrun_cmd}, translations.speedrun_desc)
local chat_presets_root = menu.list(online_root, translations.chatpresets, {translations.chatpresets_cmd}, translations.chatpresets_desc)
local players_shortcut_command = menu.ref_by_path('Players', 37)
menu.action(players_root, translations.stand_players_shortcut, {}, "", function(click_type)
    menu.trigger_command(players_shortcut_command)
end)

local function get_stat_by_name(stat_name, character)
    if character then 
        stat_name = "MP" .. tostring(util.get_char_slot()) .. "_" .. stat_name 
    end
    local out = memory.alloc(8)
    STATS.STAT_GET_INT(MISC.GET_HASH_KEY(stat_name), out, -1)
    return memory.read_int(out)
end

local function get_prostitutes_solicited(pid)
    return memory.read_int(memory.script_global(1853910 + 1 + (pid * 862) + 205 + 54))
end

local function get_lapdances_amount(pid) 
    return memory.read_int(memory.script_global(1853910 + 1 + (pid * 862) + 205 + 55))
end
local ap_root = menu.list(online_root, translations.all_players, {translations.all_players_cmd}, "")
local apfriendly_root = menu.list(ap_root, translations.all_players_friendly, {translations.all_players_friendly_cmd}, "")
local aphostile_root = menu.list(ap_root, translations.all_players_hostile, {translations.all_players_hostile_cmd}, "")
local apneutral_root = menu.list(ap_root, translations.all_players_neutral, {translations.all_players_neutral_cmd}, "")
-- END ONLINE SUBSECTIONS
-- BEGIN ENTITIES SUBSECTION
local entities_root = menu.list(menu.my_root(), translations.entities, {translations.entities_cmd}, translations.entities_desc)
local peds_root = menu.list(entities_root, translations.peds, {translations.peds_cmd}, translations.peds_desc)
local vehicles_root = menu.list(entities_root, translations.vehicles, {translations.vehicles_cmd}, translations.vehicles_desc)
local pickups_root = menu.list(entities_root, translations.pickups, {translations.pickups_cmd}, translations.pickups_desc)
-- END ENTITIES SUBSECTION
local world_root = menu.list(menu.my_root(), translations.world, {translations.world_cmd}, translations.world_desc)
local train_root = menu.list(world_root, translations.train_control, {"traincontrol"})
local tweaks_root = menu.list(menu.my_root(), translations.gametweaks, {translations.gametweaks_cmd}, translations.gametweaks_desc)
local god_graphics_root = menu.list(tweaks_root, translations.god_graphics, {""}, translations.god_graphics_desc)
local lancescript_root = menu.list(menu.my_root(), translations.misc, {translations.misc_cmd}, translations.misc_desc)
menu.action(menu.my_root(), translations.disclaimer, {}, translations.disclaimer_text, function() end)

--async_http.init("gist.githubusercontent.com", "/stakonum/d4e2f55f6f72d2cf7ec490b748099091/raw", function(result)
--    menu.hyperlink(menu.my_root(), translations.discord, result, "")
--end)
--async_http.dispatch()

-- entity-pool gathering handling
vehicle_uses = 0
ped_uses = 0
pickup_uses = 0
player_uses = 0
object_uses = 0
robustmode = false

local function mod_uses(type, incr)
    -- this func is a patch. every time the script loads, all the toggles load and set their state. in some cases this makes the _uses optimization negative and breaks things. this prevents that.
    if incr < 0 and is_loading then
        -- ignore if script is still loading
        ls_log("Not incrementing use var of type " .. type .. " by " .. incr .. "- script is loading")
        return
    end
    ls_log("Incrementing use var of type " .. type .. " by " .. incr)
    if type == "vehicle" then
        if vehicle_uses <= 0 and incr < 0 then
            return
        end
        vehicle_uses = vehicle_uses + incr
    elseif type == "pickup" then
        if pickup_uses <= 0 and incr < 0 then
            return
        end
        pickup_uses = pickup_uses + incr
    elseif type == "ped" then
        if ped_uses <= 0 and incr < 0 then
            return
        end
        ped_uses = ped_uses + incr
    elseif type == "player" then
        if player_uses <= 0 and incr < 0 then
            return
        end
        player_uses = player_uses + incr
    elseif type == "object" then
        if object_uses <= 0 and incr < 0 then
            return
        end
        object_uses = object_uses + incr
    end
end

-- UTILTITY FUNCTIONS

local alphabet = "abcdefghijklmnopqrstuvwxyzABCEDFGHIJKLMNOPQRSTUVWXYZ0123456789"

function is_user_a_stand_user(pid)
    if pid == players.user() then
        return true
    end
    if players.exists(pid) then
        for _, cmd in ipairs(menu.player_root(pid):getChildren()) do
            if cmd:getType() == COMMAND_LIST_CUSTOM_SPECIAL_MEANING and (cmd:refByRelPath("Stand User"):isValid() or cmd:refByRelPath("Stand User (Co-Loading"):isValid()) then
                return true
            end
        end
    end
    return false
end

function random_string(length)
    local res = {}
    for i=1, length do 
        res[i] = alphabet[math.random(#alphabet)]
    end
    return table.concat(res)
end

function random_ip_address()
    local ip = {}
    for i=1, 4 do 
            ip[i] = tostring(math.random(1, 255)) 
    end
    return table.concat(ip, '.')
end


local function request_anim_dict(dict)
    while not STREAMING.HAS_ANIM_DICT_LOADED(dict) do
        STREAMING.REQUEST_ANIM_DICT(dict)
        util.yield()
    end
end

local function request_anim_set(set)
    while not STREAMING.HAS_ANIM_SET_LOADED(set) do
        STREAMING.REQUEST_ANIM_SET(set)
        util.yield()
    end
end


local function exportstring( s )
    return string.format("%q", s)
end

function table.save(  tbl,filename )
   local charS,charE = "   ","\n"
   local file,err = io.open( filename, "wb" )
   if err then return err end
   -- initiate variables for save procedure
   local tables,lookup = { tbl },{ [tbl] = 1 }
   file:write( "return {"..charE )
   for idx,t in ipairs( tables ) do
      file:write( "-- Table: {"..idx.."}"..charE )
      file:write( "{"..charE )
      local thandled = {}
      for i,v in ipairs( t ) do
         thandled[i] = true
         local stype = type( v )
         -- only handle value
         if stype == "table" then
            if not lookup[v] then
               table.insert( tables, v )
               lookup[v] = #tables
            end
            file:write( charS.."{"..lookup[v].."},"..charE )
         elseif stype == "string" then
            file:write(  charS..exportstring( v )..","..charE )
         elseif stype == "number" then
            file:write(  charS..tostring( v )..","..charE )
         end
      end
      for i,v in pairs( t ) do
         -- escape handled values
         if (not thandled[i]) then
            local str = ""
            local stype = type( i )
            -- handle index
            if stype == "table" then
               if not lookup[i] then
                  table.insert( tables,i )
                  lookup[i] = #tables
               end
               str = charS.."[{"..lookup[i].."}]="
            elseif stype == "string" then
               str = charS.."["..exportstring( i ).."]="
            elseif stype == "number" then
               str = charS.."["..tostring( i ).."]="
            end
            if str ~= "" then
               stype = type( v )
               -- handle value
               if stype == "table" then
                  if not lookup[v] then
                     table.insert( tables,v )
                     lookup[v] = #tables
                  end
                  file:write( str.."{"..lookup[v].."},"..charE )
               elseif stype == "string" then
                  file:write( str..exportstring( v )..","..charE )
               elseif stype == "number" then
                  file:write( str..tostring( v )..","..charE )
               end
            end
         end
      end
      file:write( "},"..charE )
   end
   file:write( "}" )
   file:close()
end

function table.load( sfile )
   local ftables,err = loadfile( sfile )
   if err then return _,err end
   local tables = ftables()
   for idx = 1,#tables do
      local tolinki = {}
      for i,v in pairs( tables[idx] ) do
         if type( v ) == "table" then
            tables[idx][i] = tables[v[1]]
         end
         if type( i ) == "table" and tables[i[1]] then
            table.insert( tolinki,{ i,tables[i[1]] } )
         end
      end
      -- link indices
      for _,v in ipairs( tolinki ) do
         tables[idx][v[2]],tables[idx][v[1]] =  tables[idx][v[1]],nil
      end
   end
   return tables[1]
end

function request_model_load(hash)
    util.request_model(hash, 2000)
end

function request_anim_dict(dict)
    request_time = os.time()
    if not STREAMING.DOES_ANIM_DICT_EXIST(dict) then
        return
    end
    STREAMING.REQUEST_ANIM_DICT(dict)
    while not STREAMING.HAS_ANIM_DICT_LOADED(dict) do
        if os.time() - request_time >= 10 then
            break
        end
        util.yield()
    end
end

function request_ptfx_asset(asset)
    local request_time = os.time()
    STREAMING.REQUEST_NAMED_PTFX_ASSET(asset)
    while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(asset) do
        if os.time() - request_time >= 10 then
            break
        end
        util.yield()
    end
end

-- credit to vsus

local function is_script_running(str)
    return SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(util.joaat(str)) > 0
end

local function request_game_script(str)
    if not SCRIPT.DOES_SCRIPT_EXIST(str) or is_script_running(str) then
        return false
    end
    if is_script_running(str) then
        return true
    end
    SCRIPT.REQUEST_SCRIPT(str)
    while not SCRIPT.HAS_SCRIPT_LOADED(str) do
        util.yield()
    end
end

-- CREDIT TO NOWIRY
local function get_entity_owner(entity)
	local pEntity = entities.handle_to_pointer(entity)
	local addr = memory.read_long(pEntity + 0xD0)
	return (addr ~= 0) and memory.read_byte(addr + 0x49) or -1
end

local function world_to_screen_coords(x, y, z)
    sc_x = memory.alloc(8)
    sc_y = memory.alloc(8)
    GRAPHICS.GET_SCREEN_COORD_FROM_WORLD_COORD(x, y, z, sc_x, sc_y)
    local ret = {
        x = memory.read_float(sc_x),
        y = memory.read_float(sc_y)
    }
    return ret
end

local function is_entity_a_projectile(hash)
    local all_projectile_hashes = {
        util.joaat("w_ex_vehiclemissile_1"),
        util.joaat("w_ex_vehiclemissile_2"),
        util.joaat("w_ex_vehiclemissile_3"),
        util.joaat("w_ex_vehiclemissile_4"),
        util.joaat("w_ex_vehiclem,tar"),
        util.joaat("w_ex_apmine"),
        util.joaat("w_ex_arena_landmine_01b"),
        util.joaat("w_ex_birdshat"),
        util.joaat("w_ex_grenadefrag"),
        util.joaat("w_ex_grenadesmoke"),
        util.joaat("w_ex_molotov"),
        util.joaat("w_ex_pe"),
        util.joaat("w_ex_pipebomb"),
        util.joaat("w_ex_snowball"),
        util.joaat("w_lr_rpg_rocket"),
        util.joaat("w_lr_homing_rocket"),
        util.joaat("w_lr_firew,k_rocket"),
        util.joaat("xm_prop_x17_silo_rocket_01")
    }
    return table.contains(all_projectile_hashes, hash)
end

timed_thread = util.create_thread(function (thr)
    tlightstate = 0
    while true do
        if tlightstate < 3 then
            tlightstate = tlightstate + 1
        else
            tlightstate = 0
        end
        util.yield(100)
    end
end)

rgb_thread = util.create_thread(function (thr)
    local r = 255
    local g = 0
    local b = 0
    rgb = {255, 0, 0}
    while true do
        if not custom_rgb then
            if r > 0 and g < 255 and b == 0 then
                r = r - 1
                g = g + 1
            elseif r == 0 and g > 0 and b < 255 then
                g = g - 1
                b = b + 1
            elseif r < 255 and b > 0 then
                r = r + 1
                b = b - 1
            end
            rgb[1] = r
            rgb[2] = g
            rgb[3] = b
        else 
            rgb = {custom_r, custom_g, custom_b}
        end
        util.yield()
    end
end)


--https://stackoverflow.com/questions/34618946/lua-base64-encode
local b='/+9876543210zyxwvutsrqponmlkjihgfedcbaZYXWVUTSRQPONMLKJIHGFEDCBA'
local function b64_enc(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end
--https://stackoverflow.com/questions/34618946/lua-base64-encode

-- decoding
local function b64_dec(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
            return string.char(c)
    end))
end

-- detections
detection_lance = true
menu.toggle(detections_root, translations.lance_detection, {translations.lance_detection_cmd}, translations.lance_detection_desc, function(on)
    detection_lance = on
end, true)

detection_teleports = false
menu.toggle(detections_root, translations.teleport_detection, {translations.teleport_detection_cmd}, translations.teleport_detection_desc, function(on)
    detection_teleports = on
end)

detection_follow = false
menu.toggle(detections_root, translations.follow_detection, {translations.follow_detection_cmd}, translations.follow_detection_desc, function(on)
    detection_follow = on
end)


detection_bslevel = false
menu.toggle(detections_root, translations.bullshit_level_detection, {translations.bullshit_level_detection_cmd}, translations.bullshit_level_detection_desc, function(on)
    detection_bslevel = on
end, false)


detection_money = false
menu.toggle(detections_root, translations.money_detection, {translations.money_detection_cmd}, translations.money_detection_desc, function(on)
    detection_money = on
end, false)

local admin_bail = true
menu.toggle(protections_root, translations.admin_bail, {translations.admin_bail_cmd}, translations.admin_bail_desc, function(on)
    admin_bail = on
    while admin_bail do
        if util.is_session_started() then
            for _, pid in players.list(false, true, true) do 
                if players.is_marked_as_admin(pid) then 
                    notify(translations.admin_detected)
                    menu.trigger_commands("quickbail")
                end    
            end
        end
        util.yield()
    end
end, true)

local function get_random_joke()
    local joke = 'WIP'
    local in_progress = true
    async_http.init('icanhazdadjoke.com', '', function(data)
        joke = data
    end, function()
        joke = 'FAIL'
    end)
    async_http.add_header('Accept', 'text/plain')
    async_http.dispatch()
    while joke == "WIP" do 
        util.yield()
    end
    return joke
end

menu.action(chat_presets_root, translations.dox, {}, translations.dox_desc, function(click_type)
    chat.send_message("${name}: ${ip} | ${geoip.city}, ${geoip.region}, ${geoip.country}", false, true, true)
end)

local function shuffle_in_place(t)
    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
end

function first_to_upper(str)
    return (str:gsub("^%l", string.upper))
end

local function chat_bullshit_data(pid)
    local first_names = {"JAMES", "JOHN", "ROBERT", "MICHAEL", "WILLIAM", "DAVID", "RICHARD", "CHARLES", "JOSEPH", "THOMAS", "CHRISTOPHER", "DANIEL", "PAUL", "MARK", "DONALD", "GEORGE", "KENNETH", "STEVEN", "EDWARD", "BRIAN", "RONALD", "ANTHONY", "KEVIN", "JASON", "MATTHEW", "GARY", "TIMOTHY", "JOSE", "LARRY", "JEFFREY", "FRANK", "SCOTT", "ERIC", "STEPHEN", "ANDREW", "RAYMOND", "GREGORY", "JOSHUA", "JERRY", "DENNIS", "WALTER", "PATRICK", "PETER", "HAROLD", "DOUGLAS", "HENRY", "CARL", "ARTHUR", "RYAN", "ROGER", "JOE", "JUAN", "JACK", "ALBERT", "JONATHAN", "JUSTIN", "TERRY", "GERALD", "KEITH", "SAMUEL", "WILLIE", "RALPH", "LAWRENCE", "NICHOLAS", "ROY", "BENJAMIN", "BRUCE", "BRANDON", "ADAM", "HARRY", "FRED", "WAYNE", "BILLY", "STEVE", "LOUIS", "JEREMY", "AARON", "RANDY", "HOWARD", "EUGENE", "CARLOS", "RUSSELL", "BOBBY", "VICTOR", "MARTIN", "ERNEST", "PHILLIP", "TODD", "JESSE", "CRAIG", "ALAN", "SHAWN", "CLARENCE", "SEAN", "PHILIP", "CHRIS", "JOHNNY", "EARL", "JIMMY", "ANTONIO"}
    local last_names = {"smith" , "johnson" , "williams" , "brown" , "jones" , "miller" , "davis" , "garcia" , "rodriguez" , "wilson" , "martinez" , "anderson" , "taylor" , "thomas" , "hernandez" , "moore" , "martin" , "jackson" , "thompson" , "white" , "lopez" , "lee" , "gonzalez" , "harris" , "clark" , "lewis" , "robinson" , "walker" , "perez" , "hall" , "young" , "allen" , "sanchez" , "wright" , "king" , "scott" , "green" , "baker" , "adams" , "nelson" , "hill" , "ramirez" , "campbell" , "mitchell" , "roberts" , "carter" , "phillips" , "evans" , "turner" , "torres" , "parker" , "collins" , "edwards" , "stewart" , "flores" , "morris" , "nguyen" , "murphy" , "rivera" , "cook" , "rogers" , "morgan" , "peterson" , "cooper" , "reed" , "bailey" , "bell" , "gomez" , "kelly" , "howard" , "ward" , "cox" , "diaz" , "richardson" , "wood" , "watson" , "brooks" , "bennett" , "gray" , "james" , "reyes" , "cruz" , "hughes" , "price" , "myers" , "long" , "foster" , "sanders" , "ross" , "morales" , "powell" , "sullivan" , "russell" , "ortiz" , "jenkins" , "gutierrez" , "perry" , "butler" , "barnes" , "fisher"}
    local addresses = {"777 Brockton Avenue, Abington MA 2351" , "30 Memorial Drive, Avon MA 2322" , "250 Hartford Avenue, Bellingham MA 2019" , "700 Oak Street, Brockton MA 2301" , "66-4 Parkhurst Rd, Chelmsford MA 1824" , "591 Memorial Dr, Chicopee MA 1020" , "55 Brooksby Village Way, Danvers MA 1923" , "137 Teaticket Hwy, East Falmouth MA 2536" , "42 Fairhaven Commons Way, Fairhaven MA 2719" , "374 William S Canning Blvd, Fall River MA 2721" , "121 Worcester Rd, Framingham MA 1701" , "677 Timpany Blvd, Gardner MA 1440" , "337 Russell St, Hadley MA 1035" , "295 Plymouth Street, Halifax MA 2338" , "1775 Washington St, Hanover MA 2339" , "280 Washington Street, Hudson MA 1749" , "20 Soojian Dr, Leicester MA 1524" , "11 Jungle Road, Leominster MA 1453" , "301 Massachusetts Ave, Lunenburg MA 1462" , "780 Lynnway, Lynn MA 1905" , "70 Pleasant Valley Street, Methuen MA 1844" , "830 Curran Memorial Hwy, North Adams MA 1247" , "1470 S Washington St, North Attleboro MA 2760" , "506 State Road, North Dartmouth MA 2747" , "742 Main Street, North Oxford MA 1537" , "72 Main St, North Reading MA 1864" , "200 Otis Street, Northborough MA 1532" , "180 North King Street, Northhampton MA 1060" , "555 East Main St, Orange MA 1364" , "555 Hubbard Ave-Suite 12, Pittsfield MA 1201" , "300 Colony Place, Plymouth MA 2360" , "301 Falls Blvd, Quincy MA 2169" , "36 Paramount Drive, Raynham MA 2767" , "450 Highland Ave, Salem MA 1970" , "1180 Fall River Avenue, Seekonk MA 2771" , "1105 Boston Road, Springfield MA 1119" , "100 Charlton Road, Sturbridge MA 1566" , "262 Swansea Mall Dr, Swansea MA 2777" , "333 Main Street, Tewksbury MA 1876" , "550 Providence Hwy, Walpole MA 2081" , "352 Palmer Road, Ware MA 1082" , "3005 Cranberry Hwy Rt 6 28, Wareham MA 2538" , "250 Rt 59, Airmont NY 10901" , "141 Washington Ave Extension, Albany NY 12205" , "13858 Rt 31 W, Albion NY 14411" , "2055 Niagara Falls Blvd, Amherst NY 14228" , "101 Sanford Farm Shpg Center, Amsterdam NY 12010" , "297 Grant Avenue, Auburn NY 13021" , "4133 Veterans Memorial Drive, Batavia NY 14020" , "6265 Brockport Spencerport Rd, Brockport NY 14420" , "5399 W Genesse St, Camillus NY 13031" , "3191 County rd 10, Canandaigua NY 14424" , "30 Catskill, Catskill NY 12414" , "161 Centereach Mall, Centereach NY 11720" , "3018 East Ave, Central Square NY 13036" , "100 Thruway Plaza, Cheektowaga NY 14225" , "8064 Brewerton Rd, Cicero NY 13039" , "5033 Transit Road, Clarence NY 14031" , "3949 Route 31, Clay NY 13041" , "139 Merchant Place, Cobleskill NY 12043" , "85 Crooked Hill Road, Commack NY 11725" , "872 Route 13, Cortlandville NY 13045" , "279 Troy Road, East Greenbush NY 12061" , "2465 Hempstead Turnpike, East Meadow NY 11554" , "6438 Basile Rowe, East Syracuse NY 13057" , "25737 US Rt 11, Evans Mills NY 13637" , "901 Route 110, Farmingdale NY 11735" , "2400 Route 9, Fishkill NY 12524" , "10401 Bennett Road, Fredonia NY 14063" , "1818 State Route 3, Fulton NY 13069" , "4300 Lakeville Road, Geneseo NY 14454" , "990 Route 5 20, Geneva NY 14456" , "311 RT 9W, Glenmont NY 12077" , "200 Dutch Meadows Ln, Glenville NY 12302" , "100 Elm Ridge Center Dr, Greece NY 14626" , "1549 Rt 9, Halfmoon NY 12065" , "5360 Southwestern Blvd, Hamburg NY 14075" , "103 North Caroline St, Herkimer NY 13350" , "1000 State Route 36, Hornell NY 14843" , "1400 County Rd 64, Horseheads NY 14845" , "135 Fairgrounds Memorial Pkwy, Ithaca NY 14850" , "2 Gannett Dr, Johnson City NY 13790" , "233 5th Ave Ext, Johnstown NY 12095" , "601 Frank Stottile Blvd, Kingston NY 12401" , "350 E Fairmount Ave, Lakewood NY 14750" , "4975 Transit Rd, Lancaster NY 14086" , "579 Troy-Schenectady Road, Latham NY 12110" , "5783 So Transit Road, Lockport NY 14094" , "7155 State Rt 12 S, Lowville NY 13367" , "425 Route 31, Macedon NY 14502" , "3222 State Rt 11, Malone NY 12953" , "200 Sunrise Mall, Massapequa NY 11758" , "43 Stephenville St, Massena NY 13662" , "750 Middle Country Road, Middle Island NY 11953" , "470 Route 211 East, Middletown NY 10940" , "3133 E Main St, Mohegan Lake NY 10547" , "288 Larkin, Monroe NY 10950" , "41 Anawana Lake Road, Monticello NY 12701" , "4765 Commercial Drive, New Hartford NY 13413" , "1201 Rt 300, Newburgh NY 12550" , "255 W Main St, Avon CT 6001" , "120 Commercial Parkway, Branford CT 6405" , "1400 Farmington Ave, Bristol CT 6010" , "161 Berlin Road, Cromwell CT 6416" , "67 Newton Rd, Danbury CT 6810" , "656 New Haven Ave, Derby CT 6418" , "69 Prospect Hill Road, East Windsor CT 6088" , "150 Gold Star Hwy, Groton CT 6340" , "900 Boston Post Road, Guilford CT 6437" , "2300 Dixwell Ave, Hamden CT 6514" , "495 Flatbush Ave, Hartford CT 6106" , "180 River Rd, Lisbon CT 6351" , "420 Buckland Hills Dr, Manchester CT 6040" , "1365 Boston Post Road, Milford CT 6460" , "1100 New Haven Road, Naugatuck CT 6770" , "315 Foxon Blvd, New Haven CT 6513" , "164 Danbury Rd, New Milford CT 6776" , "3164 Berlin Turnpike, Newington CT 6111" , "474 Boston Post Road, North Windham CT 6256" , "650 Main Ave, Norwalk CT 6851" , "680 Connecticut Avenue, Norwalk CT 6854" , "220 Salem Turnpike, Norwich CT 6360" , "655 Boston Post Rd, Old Saybrook CT 6475" , "625 School Street, Putnam CT 6260" , "80 Town Line Rd, Rocky Hill CT 6067" , "465 Bridgeport Avenue, Shelton CT 6484" , "235 Queen St, Southington CT 6489" , "150 Barnum Avenue Cutoff, Stratford CT 6614" , "970 Torringford Street, Torrington CT 6790" , "844 No Colony Road, Wallingford CT 6492" , "910 Wolcott St, Waterbury CT 6705" , "155 Waterford Parkway No, Waterford CT 6385" , "515 Sawmill Road, West Haven CT 6516" , "2473 Hackworth Road, Adamsville AL 35005" , "630 Coonial Promenade Pkwy, Alabaster AL 35007" , "2643 Hwy 280 West, Alexander City AL 35010" , "540 West Bypass, Andalusia AL 36420" , "5560 Mcclellan Blvd, Anniston AL 36206" , "1450 No Brindlee Mtn Pkwy, Arab AL 35016" , "1011 US Hwy 72 East, Athens AL 35611" , "973 Gilbert Ferry Road Se, Attalla AL 35954" , "1717 South College Street, Auburn AL 36830" , "701 Mcmeans Ave, Bay Minette AL 36507" , "750 Academy Drive, Bessemer AL 35022" , "312 Palisades Blvd, Birmingham AL 35209" , "1600 Montclair Rd, Birmingham AL 35210" , "5919 Trussville Crossings Pkwy, Birmingham AL 35235" , "9248 Parkway East, Birmingham AL 35206" , "1972 Hwy 431, Boaz AL 35957" , "10675 Hwy 5, Brent AL 35034" , "2041 Douglas Avenue, Brewton AL 36426" , "5100 Hwy 31, Calera AL 35040" , "1916 Center Point Rd, Center Point AL 35215" , "1950 W Main St, Centre AL 35960" , "16077 Highway 280, Chelsea AL 35043" , "1415 7Th Street South, Clanton AL 35045" , "626 Olive Street Sw, Cullman AL 35055" , "27520 Hwy 98, Daphne AL 36526" , "2800 Spring Avn SW, Decatur AL 35603" , "969 Us Hwy 80 West, Demopolis AL 36732" , "3300 South Oates Street, Dothan AL 36301" , "4310 Montgomery Hwy, Dothan AL 36303" , "600 Boll Weevil Circle, Enterprise AL 36330" , "3176 South Eufaula Avenue, Eufaula AL 36027" , "7100 Aaron Aronov Drive, Fairfield AL 35064" , "10040 County Road 48, Fairhope AL 36533" , "3186 Hwy 171 North, Fayette AL 35555" , "3100 Hough Rd, Florence AL 35630" , "2200 South Mckenzie St, Foley AL 36535" , "2001 Glenn Bldv Sw, Fort Payne AL 35968" , "340 East Meighan Blvd, Gadsden AL 35903" , "890 Odum Road, Gardendale AL 35071" , "1608 W Magnolia Ave, Geneva AL 36340" , "501 Willow Lane, Greenville AL 36037" , "170 Fort Morgan Road, Gulf Shores AL 36542" , "11697 US Hwy 431, Guntersville AL 35976" , "42417 Hwy 195, Haleyville AL 35565" , "1706 Military Street South, Hamilton AL 35570" , "1201 Hwy 31 NW, Hartselle AL 35640" , "209 Lakeshore Parkway, Homewood AL 35209" , "2780 John Hawkins Pkwy, Hoover AL 35244" , "5335 Hwy 280 South, Hoover AL 35242" , "1007 Red Farmer Drive, Hueytown AL 35023" , "2900 S Mem PkwyDrake Ave, Huntsville AL 35801" , "11610 Memorial Pkwy South, Huntsville AL 35803" , "2200 Sparkman Drive, Huntsville AL 35810" , "330 Sutton Rd, Huntsville AL 35763" , "6140A Univ Drive, Huntsville AL 35806" , "4206 N College Ave, Jackson AL 36545" , "1625 Pelham South, Jacksonville AL 36265" , "1801 Hwy 78 East, Jasper AL 35501" , "8551 Whitfield Ave, Leeds AL 35094" , "8650 Madison Blvd, Madison AL 35758" , "145 Kelley Blvd, Millbrook AL 36054" , "1970 S University Blvd, Mobile AL 36609" , "6350 Cottage Hill Road, Mobile AL 36609" , "101 South Beltline Highway, Mobile AL 36606" , "2500 Dawes Road, Mobile AL 36695" , "5245 Rangeline Service Rd, Mobile AL 36619" , "685 Schillinger Rd, Mobile AL 36695" , "3371 S Alabama Ave, Monroeville AL 36460" , "10710 Chantilly Pkwy, Montgomery AL 36117" , "3801 Eastern Blvd, Montgomery AL 36116" , "6495 Atlanta Hwy, Montgomery AL 36117" , "851 Ann St, Montgomery AL 36107" , "15445 Highway 24, Moulton AL 35650" , "517 West Avalon Ave, Muscle Shoals AL 35661" , "5710 Mcfarland Blvd, Northport AL 35476" , "2453 2Nd Avenue East, Oneonta AL 35121  205-625-647" , "2900 Pepperrell Pkwy, Opelika AL 36801" , "92 Plaza Lane, Oxford AL 36203" , "1537 Hwy 231 South, Ozark AL 36360" , "2181 Pelham Pkwy, Pelham AL 35124" , "165 Vaughan Ln, Pell City AL 35125" , "3700 Hwy 280-431 N, Phenix City AL 36867" , "1903 Cobbs Ford Rd, Prattville AL 36066" , "4180 Us Hwy 431, Roanoke AL 36274" , "13675 Hwy 43, Russellville AL 35653" , "1095 Industrial Pkwy, Saraland AL 36571" , "24833 Johnt Reidprkw, Scottsboro AL 35768" , "1501 Hwy 14 East, Selma AL 36703" , "7855 Moffett Rd, Semmes AL 36575" , "150 Springville Station Blvd, Springville AL 35146" , "690 Hwy 78, Sumiton AL 35148" , "41301 US Hwy 280, Sylacauga AL 35150" , "214 Haynes Street, Talladega AL 35160" , "1300 Gilmer Ave, Tallassee AL 36078" , "34301 Hwy 43, Thomasville AL 36784" , "1420 Us 231 South, Troy AL 36081" , "1501 Skyland Blvd E, Tuscaloosa AL 35405" , "3501 20th Av, Valley AL 36854" , "1300 Montgomery Highway, Vestavia Hills AL 35216" , "4538 Us Hwy 231, Wetumpka AL 36092" , "2575 Us Hwy 43, Winfield AL 35594"}
    local rand_words = {"car", "cartoon", "fun", "boy", "girl", "spaghetti", "pizza", "guitar", "music", "ratio", "dog", "cat", "password"}
    local password = rand_words[math.random(#rand_words)] .. math.random(10, 99)
    local name = first_to_upper(string.lower(first_names[math.random(#first_names)])) .. ' ' .. first_to_upper(string.lower(last_names[math.random(#last_names)]))
    local ssn = math.random(100, 999) .. '-' .. math.random(10, 99) .. '-' .. math.random(1000, 9999)
    local phone_num = '+1 (' .. math.random(100, 999) .. ')' .. '-' .. math.random(100, 999) .. '-' .. math.random(1000, 9999)
    local ip = math.random(255) .. '.' .. math.random(255) .. '.' .. math.random(255) .. '.' .. math.random(255)
    local blood_types = {'A+', 'B+', 'AB+', 'A-', 'B-', 'AB-', 'O+', 'O-'}
    chat.send_targeted_message(pid, players.user(), players.get_name(pid) .. ' DOX:', false, true, true)
    chat.send_targeted_message(pid, players.user(), 'Real name: ' .. name .. ' • Address: ' .. addresses[math.random(#addresses)] .. ' •  SSN: ' .. ssn .. ' • SC Password: ' .. password, false, true, true)
    chat.send_targeted_message(pid, players.user(), 'Phone: ' .. phone_num .. ' • Mother\'s maiden name: ' .. first_to_upper(string.lower(last_names[math.random(#last_names)])) .. ' • IP: ' .. ip .. ' • Blood type: ' .. blood_types[math.random(#blood_types)], false, true, true)
end

menu.action(chat_presets_root, translations.ultra_dox, {}, translations.ultra_dox_desc, function(click_type)
    -- now we have the request
    for _, pid in pairs(players.list(true, true, true)) do
        local data = chat_bullshit_data(pid)
    end
end)

function fake_chat_with_percentage_and_target(action)
    chat.send_message(action .. " ${name}. [||||            ] (25%)", false, true, true)
    util.yield(math.random(500, 3000))
    chat.send_message(action .. " ${name}. [||||||||        ] (50%)", false, true, true)
    util.yield(math.random(500, 3000))
    chat.send_message(action .. " ${name}. [||||||||||||    ] (75%)", false, true, true)
    util.yield(math.random(500, 3000))
    chat.send_message(action .. " ${name}. [||||||||||||||| ] (89%)", false, true, true)
    util.yield(math.random(3000, 5000))
end

menu.action(chat_presets_root, translations.fake_crash, {}, translations.fake_crash_desc, function(click_type)
    fake_chat_with_percentage_and_target(translations.crashing)
    chat.send_message(translations.failed_to_crash .. " ${name}. " .. translations.reason_unknown, false, true, true)
end)

menu.action(chat_presets_root, translations.fake_hack, {}, translations.fake_hack_desc, function(click_type)
    fake_chat_with_percentage_and_target(translations.hacking)
    chat.send_message(translations.failed_to_hack .. " ${name}. " .. translations.reason_unknown, false, true, true)
end)


menu.action(chat_presets_root, translations.random_joke, {translations.random_joke_cmd}, translations.random_joke_desc, function(click_type)
    local joke = get_random_joke()
    if joke ~= "FAIL" then
        chat.send_message(joke, false, true, true)
    end
end)

menu.toggle_loop(chat_presets_root, translations.random_joke_loop, {translations.random_joke_loop_cmd}, translations.random_joke_loop_desc, function(click_type)
    if util.is_session_started() then
        local joke = get_random_joke()
        if joke ~= "FAIL" then
            chat.send_message(joke, false, true, true)
        end
        util.yield(5000)
    end
end)




--https://icanhazdadjoke.com/

local chat_presets = {
    [translations.chat_preset_1_name] = translations.chat_preset_1_content,
    [translations.chat_preset_2_name] = translations.chat_preset_2_content,
    [translations.chat_preset_3_name] = translations.chat_preset_3_content
}
for k,v in pairs(chat_presets) do
    menu.action(chat_presets_root, k, {}, "\"" .. v .. "\"", function(click_type)
        chat.send_message(v, false, true, true)
    end)
end


memory.write_string(util_alloc, b64_dec("nZqek5CRmv=="))

local function pid_to_handle(pid)
    NETWORK.NETWORK_HANDLE_FROM_PLAYER(pid, handle_ptr, 13)
    return handle_ptr
end

local function get_model_size(hash)
    local minptr = memory.alloc(24)
    local maxptr = memory.alloc(24)
    local min = {}
    local max = {}
    MISC.GET_MODEL_DIMENSIONS(hash, minptr, maxptr)
    min.x, min.y, min.z = v3.get(minptr)
    max.x, max.y, max.z = v3.get(maxptr)
    local size = {}
    size.x = max.x - min.x
    size.y = max.y - min.y
    size.z = max.z - min.z
    size['max'] = math.max(size.x, size.y, size.z)
    return size
end

-- creative rgb vector from params (unused func??)
local function to_rgb(r, g, b, a)
    local color = {}
    color.r = r
    color.g = g
    color.b = b
    color.a = a
    return color
end

-- credit to nowiry
local function set_entity_face_entity(entity, target, usePitch)
    local pos1 = ENTITY.GET_ENTITY_COORDS(entity, false)
    local pos2 = ENTITY.GET_ENTITY_COORDS(target, false)
    local rel = v3.new(pos2)
    rel:sub(pos1)
    local rot = rel:toRot()
    if not usePitch then
        ENTITY.SET_ENTITY_HEADING(entity, rot.z)
    else
        ENTITY.SET_ENTITY_ROTATION(entity, rot.x, rot.y, rot.z, 2, 0)
    end
end

-- pre-made rgb's
black = to_rgb(0.0,0.0,0.0,1.0)
white = to_rgb(1.0,1.0,1.0,1.0)
red = to_rgb(1,0,0,1)
green = to_rgb(0,1,0,1)
blue = to_rgb(0.0,0.0,1.0,1.0)


-- RAYCAST SHIT

local function interpolate(y0, y1, perc)
	perc = perc > 1.0 and 1.0 or perc
	return (1 - perc) * y0 + perc * y1
end


local function get_health_colour(perc)
	local result = {a = 255}
	local r, g, b
	if perc <= 0.5 then
		r = 1.0
		g = interpolate(0.0, 1.0, perc/0.5)
		b = 0.0
	else
		r = interpolate(1.0, 0, (perc - 0.5)/0.5)
		g = 1.0
		b = 0.0
	end
	result.r = math.ceil(r * 255)
	result.g = math.ceil(g * 255)
	result.b = math.ceil(b * 255)
	return result
end


local function draw_marker(type, pos, dir, rot, scale, rotate, colour, txdDict, txdName)
    txdDict = txdDict or 0
    txdName = txdName or 0
    colour = colour or {r = 255, g = 255, b = 255, a = 255}
    GRAPHICS.DRAW_MARKER(type, pos.x, pos.y, pos.z, dir.x, dir.y, dir.z, rot.x, rot.y, rot.z, scale.x, scale.y, scale.z, colour.r, colour.g, colour.b, colour.a, false, true, 2, rotate, txdDict, txdName, false)
end


local function get_distance_between_entities(entity, target)
	if not ENTITY.DOES_ENTITY_EXIST(entity) or not ENTITY.DOES_ENTITY_EXIST(target) then
		return 0.0
	end
	local pos = ENTITY.GET_ENTITY_COORDS(entity, true)
	return ENTITY.GET_ENTITY_COORDS(target, true):distance(pos)
end


local function get_offset_from_gameplay_camera(distance)
    local cam_rot = CAM.GET_GAMEPLAY_CAM_ROT(0)
    local cam_pos = CAM.GET_GAMEPLAY_CAM_COORD()
    local direction = v3.toDir(cam_rot)
    local destination = 
    { 
        x = cam_pos.x + direction.x * distance, 
        y = cam_pos.y + direction.y * distance, 
        z = cam_pos.z + direction.z * distance 
    }
    return destination
end

-- credit to nowiry i think
local function get_offset_from_camera(distance, camera)
    local cam_rot = CAM.GET_CAM_ROT(camera, 0)
    local cam_pos = CAM.GET_CAM_COORD(camera)
    local direction = v3.toDir(cam_rot)
    local destination = 
    { 
        x = cam_pos.x + direction.x * distance, 
        y = cam_pos.y + direction.y * distance, 
        z = cam_pos.z + direction.z * distance 
    }
    return destination
end

-- also credit to nowiry i believe
local function raycast_gameplay_cam(flag, distance)
    local ptr1, ptr2, ptr3, ptr4 = memory.alloc(), memory.alloc(), memory.alloc(), memory.alloc()
    local cam_rot = CAM.GET_GAMEPLAY_CAM_ROT(0)
    local cam_pos = CAM.GET_GAMEPLAY_CAM_COORD()
    local direction = v3.toDir(cam_rot)
    local destination = 
    { 
        x = cam_pos.x + direction.x * distance, 
        y = cam_pos.y + direction.y * distance, 
        z = cam_pos.z + direction.z * distance 
    }
    SHAPETEST.GET_SHAPE_TEST_RESULT(
        SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(
            cam_pos.x, 
            cam_pos.y, 
            cam_pos.z, 
            destination.x, 
            destination.y, 
            destination.z, 
            flag, 
            players.user_ped(), 
            1
        ), ptr1, ptr2, ptr3, ptr4)
    local p1 = memory.read_int(ptr1)
    local p2 = memory.read_vector3(ptr2)
    local p3 = memory.read_vector3(ptr3)
    local p4 = memory.read_int(ptr4)
    return {p1, p2, p3, p4}
end

-- i think nowiry gets credit here
local function raycast_cam(flag, distance, cam)
    local ptr1, ptr2, ptr3, ptr4 = memory.alloc(), memory.alloc(), memory.alloc(), memory.alloc()
    local cam_rot = CAM.GET_CAM_ROT(cam, 0)
    local cam_pos = CAM.GET_CAM_COORD(cam)
    local direction = v3.toDir(cam_rot)
    local destination = 
    { 
        x = cam_pos.x + direction.x * distance, 
        y = cam_pos.y + direction.y * distance, 
        z = cam_pos.z + direction.z * distance 
    }
    SHAPETEST.GET_SHAPE_TEST_RESULT(
        SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(
            cam_pos.x, 
            cam_pos.y, 
            cam_pos.z, 
            destination.x, 
            destination.y, 
            destination.z, 
            flag, 
            -1, 
            1
        ), ptr1, ptr2, ptr3, ptr4)
    local p1 = memory.read_int(ptr1)
    local p2 = memory.read_vector3(ptr2)
    local p3 = memory.read_vector3(ptr3)
    local p4 = memory.read_int(ptr4)
    return {p1, p2, p3, p4}
end

-- set a player into a free seat in a vehicle, if any exist
local function set_player_into_suitable_seat(ent)
    local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(ent, -1)
    if not PED.IS_PED_A_PLAYER(driver) or driver == 0 then
        if driver ~= 0 then
            entities.delete_by_handle(driver)
        end
        PED.SET_PED_INTO_VEHICLE(players.user_ped(), ent, -1)
    else
        for i=0, VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(ent) do
            if VEHICLE.IS_VEHICLE_SEAT_FREE(ent, i) then
                PED.SET_PED_INTO_VEHICLE(players.user_ped(), ent, -1)
            end
        end
    end
end

-- aim info
local ent_types = {translations.ped_type_1, translations.ped_type_2, translations.ped_type_3, translations.ped_type_4}
local function get_aim_info()
    local outptr = memory.alloc(4)
    local success = PLAYER.GET_ENTITY_PLAYER_IS_FREE_AIMING_AT(players.user(), outptr)
    local info = {}
    if success then
        local ent = memory.read_int(outptr)
        if not ENTITY.DOES_ENTITY_EXIST(ent) then
            info["ent"] = 0
        else
            info["ent"] = ent
        end
        if ENTITY.GET_ENTITY_TYPE(ent) == 1 then
            local veh = PED.GET_VEHICLE_PED_IS_IN(ent, false)
            if veh ~= 0 then
                if VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, -1) then
                    ent = veh
                    info['ent'] = ent
                end
            end
        end
        info["hash"] = ENTITY.GET_ENTITY_MODEL(ent)
        info["health"] = ENTITY.GET_ENTITY_HEALTH(ent)
        info["type"] = ent_types[ENTITY.GET_ENTITY_TYPE(ent)+1]
        info["speed"] = math.floor(ENTITY.GET_ENTITY_SPEED(ent))
    else
        info['ent'] = 0
    end
    return info
end

-- shorthand for running commands
local function kick_from_veh(pid)
    menu.trigger_commands("vehkick" .. players.get_name(pid))
end

-- npc carjack algorithm 3.0
local function npc_jack(target, nearest)
    npc_jackthr = util.create_thread(function(thr)
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(target)
        local last_veh = PED.GET_VEHICLE_PED_IS_IN(player_ped, true)
        kick_from_veh(target)
        local st = os.time()
        while not VEHICLE.IS_VEHICLE_SEAT_FREE(last_veh, -1) do 
            if os.time() - st >= 10 then
                notify(translations.failed_to_free_seat)
                util.stop_thread()
            end
            util.yield()
        end
        local hash = 0x9C9EFFD8
        request_model_load(hash)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, -2.0, 0.0, 0.0)
        local ped = entities.create_ped(28, hash, coords, 30.0)
        ENTITY.SET_ENTITY_INVINCIBLE(ped, true)
        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
        PED.SET_PED_FLEE_ATTRIBUTES(ped, 0, false)
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true)
        PED.SET_PED_INTO_VEHICLE(ped, last_veh, -1)
        VEHICLE.SET_VEHICLE_ENGINE_ON(last_veh, true, true, false)
        TASK.TASK_VEHICLE_DRIVE_TO_COORD(ped, last_veh, math.random(1000), math.random(1000), math.random(100), 100, 1, ENTITY.GET_ENTITY_MODEL(last_veh), 786996, 5, 0)
        util.stop_thread()
    end)
end

-- gets a random pedestrian
local function get_random_ped()
    peds = entities.get_all_peds_as_handles()
    npcs = {}
    valid = 0
    for k,p in pairs(peds) do
        if p ~= nil and not PED.IS_PED_A_PLAYER(p) then
            table.insert(npcs, p)
            valid = valid + 1
        end
    end
    return npcs[math.random(valid)]
end

local function spawn_object_in_front_of_ped(ped, hash, ang, room, zoff, setonground)
    coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, room, zoff)
    request_model_load(hash)
    hdng = ENTITY.GET_ENTITY_HEADING(ped)
    new = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, coords['x'], coords['y'], coords['z'], true, false, false)
    ENTITY.SET_ENTITY_HEADING(new, hdng+ang)
    if setonground then
        OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(new)
    end
    return new
end

-- entity ownership forcing
local function request_control_of_entity(ent)
    if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(ent) and util.is_session_started() then
        local netid = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(ent)
        NETWORK.SET_NETWORK_ID_CAN_MIGRATE(netid, true)
        local st_time = os.time()
        while not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(ent) do
            -- intentionally silently fail, otherwise we are gonna spam the everloving shit out of the user
            if os.time() - st_time >= 5 then
                ls_log("Failed to request entity control in 5 seconds (entity " .. ent .. ")")
                break
            end
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(ent)
            util.yield()
        end
    end
end

local function request_control_of_entity_once(ent)
    if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(ent) and util.is_session_started() then
        local netid = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(ent)
        NETWORK.SET_NETWORK_ID_CAN_MIGRATE(netid, true)
        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(ent)
    end
end

-- model load requesting, very important
local function request_model_load(hash)
    request_time = os.time()
    if not STREAMING.IS_MODEL_VALID(hash) then
        return
    end
    STREAMING.REQUEST_MODEL(hash)
    while not STREAMING.HAS_MODEL_LOADED(hash) do
        if os.time() - request_time >= 10 then
            break
        end
        util.yield()
    end
end

-- texure loading
local function request_texture_dict_load(dict_name)
    request_time = os.time()
    GRAPHICS.REQUEST_STREAMED_TEXTURE_DICT(dict_name, true)
    while not GRAPHICS.HAS_STREAMED_TEXTURE_DICT_LOADED(dict_name) do
        if os.time() - request_time >= 10 then
            break
        end
        util.yield()
    end
end

-- get where the ground is (very broken func tbh)
local function get_ground_z(coords)
    local start_time = os.time()
    while true do
        if os.time() - start_time >= 5 then
            ls_log("Failed to get ground Z in 5 seconds.")
            return nil
        end
        local success, est = util.get_ground_z(coords['x'], coords['y'], coords['z']+2000)
        if success then
            return est
        end
        util.yield()
    end
end
-- ME/SELF
ped_flags = {}

local ls_driveonair
walkonwater = false
menu.toggle(self_root, translations.walk_on_water, {translations.walk_on_water_cmd}, translations.walk_on_water_desc, function(on)
    walkonwater = on
    if on then
        menu.set_value(ls_driveonair, false)
    end
end)


menu.action(self_root, translations.set_ped_flag, {translations.set_ped_flag_cmd}, translations.set_ped_flag_desc, function(click_type)
    notify(translations.ped_input_flag_int)
    menu.show_command_box(translations.set_ped_flag_cmd .. " ")
end, function(on_command)
    local pflag = tonumber(on_command)
    if ped_flags[pflag] == true then
        ped_flags[pflag] = false
        notify(translations.ped_flag_false)
    else
        ped_flags[pflag] = true
        notify(translations.ped_flag_true)
    end
end)

local burning_man_ptfx_asset = "core"
local burning_man_ptfx_effect = "fire_wrecked_plane_cockpit"
request_ptfx_asset(burning_man_ptfx_asset)

local trail_bones = {0xffa, 0xfa11, 0x83c, 0x512d, 0x796e, 0xb3fe, 0x3fcf, 0x58b7, 0xbb0}
local looped_ptfxs = {}
local was_burning_man_on = false
self_root:toggle(translations.burning_man, {"burningman"}, "", function(on)
    if not on then 
        for _, p in pairs(looped_ptfxs) do
            GRAPHICS.REMOVE_PARTICLE_FX(p, false)
            GRAPHICS.STOP_PARTICLE_FX_LOOPED(p, false)
        end
    else
        request_ptfx_asset(burning_man_ptfx_asset)
        for _, bone in pairs(trail_bones) do
            GRAPHICS.USE_PARTICLE_FX_ASSET(burning_man_ptfx_asset)
            local bone_id = PED.GET_PED_BONE_INDEX(players.user_ped(), bone)
            fx = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE(burning_man_ptfx_effect, players.user_ped(), 0.0, 0.0, 0.0, 0.0, 0.0, 90.0, bone_id, 0.5, false, false, false, 0, 0, 0, 0)
            looped_ptfxs[#looped_ptfxs+1] = fx
            GRAPHICS.SET_PARTICLE_FX_LOOPED_COLOUR(fx, 100, 100, 100, false)
        end
    end
end)


tpf_units = 1
menu.action(self_root, translations.tp_forward, {translations.tp_forward_cmd}, translations.tp_forward_desc, function(on_click)
    local pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 0, tpf_units, 0)
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(PLAYER.PLAYER_PED_ID(), pos['x'], pos['y'], pos['z'], true, false, false)
end)

menu.slider(self_root, translations.tp_forward_units, {translations.tp_forward_units_cmd}, translations.tp_forward_units_desc, 1, 100, 1, 1, function(s)
    tpf_units = s
end)

self_root:toggle_loop(translations.laser_eyes, {"lasereyes"}, translations.laser_eyes_desc, function(on)
    local weaponHash = util.joaat("weapon_heavysniper_mk2")
    local dictionary = "weap_xs_weapons"
    local ptfx_name = "bullet_tracer_xs_sr"
    local camRot = CAM.GET_FINAL_RENDERED_CAM_ROT(2)
    if PAD.IS_CONTROL_PRESSED(51, 51) then
        -- credits to jinxscript
        local inst = v3.new()
        v3.set(inst,CAM.GET_FINAL_RENDERED_CAM_ROT(2))
        local tmp = v3.toDir(inst)
        v3.set(inst, v3.get(tmp))
        v3.mul(inst, 1000)
        v3.set(tmp, CAM.GET_FINAL_RENDERED_CAM_COORD())
        v3.add(inst, tmp)
        camAim_x, camAim_y, camAim_z = v3.get(inst)
        local ped_model = ENTITY.GET_ENTITY_MODEL(players.user_ped())
        local left_eye_id = 0
        local right_eye_id = 0
        pluto_switch ped_model do 
            case 1885233650:
            case -1667301416:
                left_eye_id = 25260
                right_eye_id = 27474
                break
            -- michael / story mode character
            case 225514697:
            -- imply they're using a story mode ped i guess. i dont know what else to do unless i have data on every single ped
            default:
                left_eye_id = 5956
                right_eye_id = 6468
        end
        local boneCoord_L = ENTITY.GET_WORLD_POSITION_OF_ENTITY_BONE(players.user_ped(), PED.GET_PED_BONE_INDEX(players.user_ped(), left_eye_id))
        local boneCoord_R = ENTITY.GET_WORLD_POSITION_OF_ENTITY_BONE(players.user_ped(), PED.GET_PED_BONE_INDEX(players.user_ped(), right_eye_id))
        camRot.x += 90
        request_ptfx_asset(dictionary)
        GRAPHICS.USE_PARTICLE_FX_ASSET(dictionary)
        GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(ptfx_name, boneCoord_L.x, boneCoord_L.y, boneCoord_L.z, camRot.x, camRot.y, camRot.z, 2, 0, 0, 0, false)
        GRAPHICS.USE_PARTICLE_FX_ASSET(dictionary)
        GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(ptfx_name, boneCoord_R.x, boneCoord_R.y, boneCoord_R.z, camRot.x, camRot.y, camRot.z, 2, 0, 0, 0, false)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(boneCoord_L.x, boneCoord_L.y, boneCoord_L.z, camAim_x, camAim_y, camAim_z, 100, true, weaponHash, players.user_ped(), false, true, 100, players.user_ped(), 0)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(boneCoord_R.x, boneCoord_R.y, boneCoord_R.z, camAim_x, camAim_y, camAim_z, 100, true, weaponHash, players.user_ped(), false, true, 100, players.user_ped(), 0)
    end
end)

local entity_held = 0
local are_hands_up = false
self_root:toggle_loop(translations.throw_cars, {"throwcars"}, translations.throw_cars_desc, function(on)
    if PAD.IS_CONTROL_JUST_RELEASED(38, 38) and not PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), true)  then
        if entity_held == 0 then
            if not are_hands_up then 
                local closest = get_closest_veh(ENTITY.GET_ENTITY_COORDS(players.user_ped()))
                local veh = closest[1]
                if veh ~= nil then 
                    local dist = closest[2]
                    if dist <= 5 then 
                        request_anim_dict("missminuteman_1ig_2")
                        TASK.TASK_PLAY_ANIM(players.user_ped(), "missminuteman_1ig_2", "handsup_enter", 8.0, 0.0, -1, 50, 0, false, false, false)
                        util.yield(500)
                        are_hands_up = true
                        ENTITY.SET_ENTITY_ALPHA(veh, 100)
                        ENTITY.SET_ENTITY_HEADING(veh, ENTITY.GET_ENTITY_HEADING(players.user_ped()))
                        ENTITY.SET_ENTITY_INVINCIBLE(veh, true)
                        request_control_of_entity_once(veh)
                        ENTITY.ATTACH_ENTITY_TO_ENTITY(veh, players.user_ped(), 0, 0, 0, get_model_size(ENTITY.GET_ENTITY_MODEL(veh)).z / 2, 180, 180, -180, true, false, true, false, 0, true)
                        entity_held = veh
                    end 
                end
            else
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(players.user_ped())
                are_hands_up = false
            end
        else
            if ENTITY.IS_ENTITY_A_VEHICLE(entity_held) then
                ENTITY.DETACH_ENTITY(entity_held)
                VEHICLE.SET_VEHICLE_FORWARD_SPEED(entity_held, 100.0)
                VEHICLE.SET_VEHICLE_OUT_OF_CONTROL(entity_held, true, true)
                ENTITY.SET_ENTITY_ALPHA(entity_held, 255)
                ENTITY.SET_ENTITY_INVINCIBLE(veh, false)
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(players.user_ped())
                ENTITY.FREEZE_ENTITY_POSITION(players.user_ped(), true)
                ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(entity_held, players.user_ped(), false)
                request_anim_dict("melee@unarmed@streamed_core")
                TASK.TASK_PLAY_ANIM(players.user_ped(), "melee@unarmed@streamed_core", "heavy_punch_a", 8.0, 8.0, -1, 0, 0.3, false, false, false)
                util.yield(500)
                ENTITY.FREEZE_ENTITY_POSITION(players.user_ped(), false)
                entity_held = 0
                are_hands_up = false
            end
            -- toss
        end
    end
end)

local ped_held = 0
self_root:toggle_loop(translations.throw_peds, {"throwpeds"}, translations.throw_peds_desc, function(on)
    if PAD.IS_CONTROL_JUST_RELEASED(38, 38) and not PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), true) then
        if entity_held == 0 then
            if not are_hands_up then 
                local closest = get_closest_ped_new(ENTITY.GET_ENTITY_COORDS(players.user_ped()))
                if closest ~= nil then
                    local ped = closest[1]
                    if ped ~= nil then
                        local dist = closest[2]
                        if dist <= 5 then 
                            request_anim_dict("missminuteman_1ig_2")
                            TASK.TASK_PLAY_ANIM(players.user_ped(), "missminuteman_1ig_2", "handsup_enter", 8.0, 0.0, -1, 50, 0, false, false, false)
                            util.yield(500)
                            are_hands_up = true
                            ENTITY.SET_ENTITY_ALPHA(ped, 100)
                            ENTITY.SET_ENTITY_HEADING(ped, ENTITY.GET_ENTITY_HEADING(players.user_ped()))
                            request_control_of_entity_once(ped)
                            ENTITY.ATTACH_ENTITY_TO_ENTITY(ped, players.user_ped(), 0, 0, 0, 1.3, 180, 180, -180, true, false, true, true, 0, true)
                            entity_held = ped
                        end 
                    end
                end
            else
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(players.user_ped())
                are_hands_up = false
            end
        else
            if ENTITY.IS_ENTITY_A_PED(entity_held) then
                ENTITY.DETACH_ENTITY(entity_held)
                ENTITY.SET_ENTITY_ALPHA(entity_held, 255)
                PED.SET_PED_TO_RAGDOLL(entity_held, 10, 10, 0, false, false, false)
                --ENTITY.SET_ENTITY_VELOCITY(entity_held, 0, 100, 0)
                ENTITY.SET_ENTITY_MAX_SPEED(entity_held, 100.0)
                ENTITY.APPLY_FORCE_TO_ENTITY(entity_held, 1, 0, 100, 0, 0, 0, 0, 0, true, false, true, false, false)
                AUDIO.PLAY_PAIN(entity_held, 7, 0, 0)
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(players.user_ped())
                ENTITY.FREEZE_ENTITY_POSITION(players.user_ped(), true)
                ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(entity_held, players.user_ped(), false)
                request_anim_dict("melee@unarmed@streamed_core")
                TASK.TASK_PLAY_ANIM(players.user_ped(), "melee@unarmed@streamed_core", "heavy_punch_a", 8.0, 8.0, -1, 0, 0.3, false, false, false)
                util.yield(500)
                ENTITY.FREEZE_ENTITY_POSITION(players.user_ped(), false)
                entity_held = 0
                are_hands_up = false
            end
            -- toss
        end
    end
end)

self_root:toggle_loop(translations.keep_me_clean, {"keepmeclean"}, translations.keep_me_clean_desc, function()
    PED.CLEAR_PED_BLOOD_DAMAGE(players.user_ped())
    PED.CLEAR_PED_WETNESS(players.user_ped())
    PED.CLEAR_PED_ENV_DIRT(players.user_ped())
end)

self_root:action(translations.front_flip, {"frontflip"}, "", function()
    local hash = util.joaat("prop_ecola_can")
    request_model_load(hash)
    local prop = entities.create_object(hash, players.get_position(players.user()))
    ENTITY.FREEZE_ENTITY_POSITION(prop)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(players.user_ped(), prop, 0, 0, 0, 0, 0, 0, 0, true, false, false, false, 0, true)
    local hdg = CAM.GET_GAMEPLAY_CAM_ROT(0).z
    ENTITY.SET_ENTITY_ROTATION(prop, 0, 0, hdg, 1)
    for i=1, -360, -8 do
        ENTITY.SET_ENTITY_ROTATION(prop, i, 0, hdg, 1)
        util.yield()
    end
    ENTITY.DETACH_ENTITY(players.user_ped())
    entities.delete_by_handle(prop)
end)

local function max_out_car(veh)
    for i=0, 47 do
        num = VEHICLE.GET_NUM_VEHICLE_MODS(veh, i)
        VEHICLE.SET_VEHICLE_MOD(veh, i, num -1, true)
    end
end

-- gets coords of waypoint
local function get_waypoint_coords()
    local coords = HUD.GET_BLIP_COORDS(HUD.GET_FIRST_BLIP_INFO_ID(8))
    if coords['x'] == 0 and coords['y'] == 0 and coords['z'] == 0 then
        return nil
    else
        local estimate = get_ground_z(coords)
        if estimate then
            coords['z'] = estimate
        end
        return coords
    end
end


local taxi_ped = 0
local taxi_veh = 0
local taxi_blip = -1

local chauffeur_car_options = {translations.stretch, translations.t20, translations.kuruma}
menu.list_action(chauffeur_root, translations.summon, {translations.summon_chauffeur_cmd}, "", chauffeur_car_options, function(index, value, click_type)

    local vhash = util.joaat(value)
    local phash = util.joaat("s_m_y_casino_01")

    if taxi_veh ~= 0 then
        entities.delete_by_handle(taxi_veh)
    end

    if taxi_ped ~= 0 then
        util.remove_blip(taxi_blip)
        entities.delete_by_handle(taxi_ped)
    end 

    local plyr = players.user_ped()
    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(plyr, 0.0, 5.0, 0.0)
    request_model_load(vhash)
    request_model_load(phash)
    taxi_veh = entities.create_vehicle(vhash, coords, ENTITY.GET_ENTITY_HEADING(plyr))
    max_out_car(taxi_veh)
    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(taxi_veh, "LANCE")
    VEHICLE.SET_VEHICLE_COLOURS(taxi_veh, 145, 145)
    ENTITY.SET_ENTITY_INVINCIBLE(taxi_veh, true)
    --local my_rel_hash = PED.GET_PED_RELATIONSHIP_GROUP_HASH(players.user_ped())
    taxi_ped = entities.create_ped(32, phash, coords, ENTITY.GET_ENTITY_HEADING(plyr))
    PED.SET_PED_RELATIONSHIP_GROUP_HASH(taxi_ped, util.joaat("rgFM_AiLike"))
    taxi_blip = HUD.ADD_BLIP_FOR_ENTITY(taxi_ped)
    HUD.SET_BLIP_COLOUR(taxi_blip, 7)
    ENTITY.SET_ENTITY_INVINCIBLE(taxi_ped, true)
    PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(taxi_ped, true)
    PED.SET_PED_FLEE_ATTRIBUTES(taxi_ped, 0, false)
    PED.SET_PED_CAN_BE_DRAGGED_OUT(taxi_ped, false)
    VEHICLE.SET_VEHICLE_EXCLUSIVE_DRIVER(taxi_veh, taxi_ped, -1)
    PED.SET_PED_INTO_VEHICLE(taxi_ped, taxi_veh, -1)
    ENTITY.SET_ENTITY_INVINCIBLE(taxi_ped, true)
    PED.SET_PED_INTO_VEHICLE(players.user_ped(), taxi_veh, 0)
    notify(translations.chauffeur_created)
end)

menu.action(chauffeur_root, translations.drive_to_waypoint, {}, "", function(click_type)
    if taxi_ped == 0 then
        notify(translations.no_active_chauffeur)
    else
        local goto_coords = get_waypoint_coords()
        if goto_coords ~= nil then
            TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(taxi_ped, taxi_veh, goto_coords['x'], goto_coords['y'], goto_coords['z'], 300.0, 786996, 5)
        end
    end
end)


menu.action(chauffeur_root, translations.teleport_into_cab, {}, "", function(click_type)
    if taxi_ped == 0 then
        notify(translations.no_active_chauffeur)
    else
        PED.SET_PED_INTO_VEHICLE(players.user_ped(), taxi_veh, 0)
    end
end)

menu.action(chauffeur_root, translations.self_destruct, {}, "", function(click_type)
    if taxi_ped == 0 then
        notify(translations.no_active_chauffeur)
    else
        local ped_copy = taxi_ped
        local veh_copy = taxi_veh
        taxi_ped = 0
        taxi_veh = 0
        local coords = ENTITY.GET_ENTITY_COORDS(veh_copy)
        ENTITY.SET_ENTITY_INVINCIBLE(veh_copy, false)
        FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], 7, 100.0, true, false, 1.0)
        ENTITY.SET_ENTITY_HEALTH(veh_copy, 0)
        ENTITY.SET_ENTITY_INVINCIBLE(ped_copy, false)
        ENTITY.SET_ENTITY_HEALTH(ped_copy, 0)
        if math.random(5) == 3 then
            notify(translations.he_had_a_wife)
        end
        util.yield(3000)
        entities.delete_by_handle(ped_copy)
        entities.delete_by_handle(veh_copy)
    end
end)





-- MY VEHICLE
local drift_root = menu.list(my_vehicle_root, translations.drifting, {"lsdrifting"}, "")
my_vehicle_movement_root = menu.list(my_vehicle_root, translations.movement, {translations.movement_cmd}, translations.movement_desc)
vehicle_workshop_root = menu.list(my_vehicle_root, translations.vehicle_workshop, {translations.vehicle_workshop_cmd}, "")

speedometer_plate_root = menu.list(my_vehicle_root, translations.speed_plate_root, {translations.speed_plate_root_cmd}, translations.speed_plate_desc)
mph_plate = false
menu.toggle(speedometer_plate_root, translations.speed_plate_root, {translations.speed_plate_cmd}, translations.speed_plate_desc, function(on)
    mph_plate = on
    if on then
        if player_cur_car ~= 0 then
            original_plate = VEHICLE.GET_VEHICLE_NUMBER_PLATE_TEXT(player_cur_car)
        else
            notify(translations.sp_not_in_veh)
            original_plate = translations.lance
        end
    else
        if player_cur_car ~= 0 then
            if original_plate == nil then
                original_plate = translations.lance
            end
            VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(player_cur_car, original_plate)
        end
    end
end)

mph_unit = translations.kph
local unit_options = {translations.kph, translations.mph}
menu.list_action(speedometer_plate_root, translations.speed_unit, {translations.speed_unit_cmd}, "", unit_options, function(index, value, click_type)
    mph_unit = value
end)

-- BEGIN MOVEMENT ROOT
dow_block = 0
driveonwater = false
local ls_driveonwater = menu.toggle(my_vehicle_movement_root, translations.drive_on_water, {translations.drive_on_water_cmd}, "", function(on)
    driveonwater = on
    if on then
        if driveonair then
            menu.set_value(ls_driveonair, false)
            notify(translations.drive_on_air_autooff)
        end
    else
        if not driveonair and not walkonwater then
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(dow_block, 0, 0, 0, false, false, false)
        end
    end
end)

doa_ht = 0
driveonair = false
ls_driveonair = menu.toggle(my_vehicle_movement_root, translations.drive_on_air, {translations.drive_on_air_cmd}, "", function(on)
    driveonair = on
    if on then
        local pos = players.get_position(players.user())
        doa_ht = pos['z']
        notify(translations.drive_on_air_instructions)
        if driveonwater then
            menu.set_value(ls_driveonwater, false)
            notify(translations.drive_on_water_autooff)
        end
    end
end)

menu.toggle_loop(my_vehicle_movement_root, translations.vehicle_strafe, {translations.vehicle_strafe_cmd}, translations.vehicle_strafe_desc, function(toggle)
    if player_cur_car ~= 0 then
        local rot = ENTITY.GET_ENTITY_ROTATION(player_cur_car, 0)
        if PAD.IS_CONTROL_PRESSED(175, 175) then
            ENTITY.APPLY_FORCE_TO_ENTITY(player_cur_car, 1, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
            ENTITY.SET_ENTITY_ROTATION(player_cur_car, rot['x'], rot['y'], rot['z'], 0, true)
        end
        if PAD.IS_CONTROL_PRESSED(174, 174) then
            ENTITY.APPLY_FORCE_TO_ENTITY(player_cur_car, 1, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
            ENTITY.SET_ENTITY_ROTATION(player_cur_car, rot['x'], rot['y'], rot['z'], 0, true)
        end
    end
end)

vjumpforce = 20
vslamforce = 20
menu.toggle_loop(my_vehicle_movement_root, translations.vehicle_jump, {translations.vehicle_jump_cmd}, translations.vehicle_jump_desc, function(toggle)
    if player_cur_car ~= 0 then
        if PAD.IS_CONTROL_JUST_PRESSED(86,86) then
            ENTITY.APPLY_FORCE_TO_ENTITY(player_cur_car, 1, 0.0, 0.0, vjumpforce, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
        end
    end
end)


menu.toggle_loop(my_vehicle_movement_root, translations.vehicle_slam, {translations.vehicle_slam_cmd}, translations.vehicle_slam_desc, function(toggle)
    if player_cur_car ~= 0 then
        if PAD.IS_CONTROL_JUST_PRESSED(36,36) then
            ENTITY.APPLY_FORCE_TO_ENTITY(player_cur_car, 1, 0.0, 0.0, -vslamforce, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
        end
    end
end)


menu.slider(my_vehicle_movement_root, translations.vehicle_jump_force, {translations.vehicle_jump_force_cmd}, "", 1, 300, 20, 1, function(s)
    vjumpforce = s
  end)


menu.slider(my_vehicle_movement_root, translations.vehicle_slam_force, {translations.vehicle_slam_force_cmd}, "", 1, 300, 50, 1, function(s)
    vslamforce = s
  end)

menu.toggle_loop(my_vehicle_movement_root, translations.stick_to_ground, {translations.stick_to_ground_cmd}, translations.stick_to_ground_desc, function(on)
    if player_cur_car ~= 0 then
        local vel = ENTITY.GET_ENTITY_VELOCITY(player_cur_car)
        vel['z'] = -vel['z']
        ENTITY.APPLY_FORCE_TO_ENTITY(player_cur_car, 2, 0, 0, -50 -vel['z'], 0, 0, 0, 0, true, false, true, false, true)
        --ENTITY.SET_ENTITY_VELOCITY(player_cur_car, vel['x'], vel['y'], -0.2)
    end
end)

menu.action(my_vehicle_movement_root, translations.vehicle_180, {translations.vehicle_180_cmd}, translations.vehicle_180_desc, function(click_type)
    if player_cur_car ~= 0 then
        local rot = ENTITY.GET_ENTITY_ROTATION(player_cur_car, 0)
        local vel = ENTITY.GET_ENTITY_VELOCITY(player_cur_car)
        ENTITY.SET_ENTITY_ROTATION(player_cur_car, rot['x'], rot['y'], rot['z']+180, 0, true)
        ENTITY.SET_ENTITY_VELOCITY(player_cur_car, -vel['x'], -vel['y'], vel['z'])
    end
end)

v_f_previous_car = 0
vflyspeed = 100
v_fly = false
v_f_plane = 0

menu.slider(my_vehicle_movement_root, translations.vehicle_fly_speed, {translations.vehicle_fly_speed_cmd}, "", 1, 3000, 100, 1, function(s)
    vflyspeed = s
end)

local ls_vehiclefly = menu.toggle_loop(my_vehicle_movement_root, translations.vehicle_fly, {translations.vehicle_fly_cmd}, translations.vehicle_fly_desc, function(on)
    if player_cur_car ~= 0 and PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), true) then
        ENTITY.SET_ENTITY_MAX_SPEED(player_cur_car, vflyspeed)
        local c = CAM.GET_GAMEPLAY_CAM_ROT(0)
        CAM.DISABLE_CINEMATIC_BONNET_CAMERA_THIS_UPDATE()
        ENTITY.SET_ENTITY_ROTATION(player_cur_car, c.x, 0, c.z, 0, true)
        any_c_pressed = false
        --W
        local x_vel = 0.0
        local y_vel = 0.0
        local z_vel = 0.0
        if PAD.IS_CONTROL_PRESSED(32, 32) then
            x_vel = vflyspeed
        end 
        --A
        if PAD.IS_CONTROL_PRESSED(63, 63) then
            y_vel = -vflyspeed
        end
        --S
        if PAD.IS_CONTROL_PRESSED(33, 33) then
            x_vel = -vflyspeed
        end
        --D
        if PAD.IS_CONTROL_PRESSED(64, 64) then
            y_vel = vflyspeed
        end
        if x_vel == 0.0 and y_vel == 0.0 and z_vel == 0.0 then
            ENTITY.SET_ENTITY_VELOCITY(player_cur_car, 0.0, 0.0, 0.0)
        else
            local angs = ENTITY.GET_ENTITY_ROTATION(player_cur_car, 0)
            local spd = ENTITY.GET_ENTITY_VELOCITY(player_cur_car)
            if angs.x > 1.0 and spd.z < 0 then
                z_vel = -spd.z 
            else
                z_vel = 0.0
            end
            ENTITY.APPLY_FORCE_TO_ENTITY(player_cur_car, 3, y_vel, x_vel, z_vel, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
        end
    end
end, function()
    if player_cur_car ~= 0 then
        ENTITY.SET_ENTITY_HAS_GRAVITY(player_cur_car, true)
    end
end
)

-- END MOVEMENT ROOT

menu.action(my_vehicle_root, translations.force_leave_vehicle, {translations.force_leave_vehicle_cmd}, translations.force_leave_vehicle_desc, function(click_type)
    TASK.CLEAR_PED_TASKS_IMMEDIATELY(players.user_ped())
    TASK.TASK_LEAVE_ANY_VEHICLE(players.user_ped(), 0, 16)
end)

menu.click_slider(my_vehicle_root, translations.set_dirt_level, {translations.set_dirt_level_cmd}, "", 0, 15, 0, 1, function(s)
    if player_cur_car ~= 0 then
        VEHICLE.SET_VEHICLE_DIRT_LEVEL(player_cur_car, s)
    end
end)

menu.click_slider(my_vehicle_root, translations.stack_vertically, {translations.stack_vertically_cmd}, "", 1, 10, 3, 1, function(s)
    if player_cur_car ~= 0 then
        old_veh = player_cur_car
        for i=1, s do
            local c = ENTITY.GET_ENTITY_COORDS(old_veh, false)
            local mdl = ENTITY.GET_ENTITY_MODEL(player_cur_car)
            local size = get_model_size(mdl)
            local r = ENTITY.GET_ENTITY_ROTATION(old_veh, 0)
            new_veh = entities.create_vehicle(mdl, players.get_position(players.user()), ENTITY.GET_ENTITY_HEADING(old_veh))
            ENTITY.ATTACH_ENTITY_TO_ENTITY(new_veh, old_veh, 0, 0.0, 0.0, size.z, 0.0, 0.0, 0.0, true, false, falsmy_e, false, 0, true)
            old_veh = new_veh
        end
    end
end)

menu.click_slider(my_vehicle_root, translations.stack_horizontally, {translations.stack_horizontally_cmd}, "", 1, 10, 3, 1, function(s)
    if player_cur_car ~= 0 then
        for i=1, s do
            main_veh = player_cur_car
            local c = ENTITY.GET_ENTITY_COORDS(main_veh, false)
            local mdl = ENTITY.GET_ENTITY_MODEL(main_veh)
            local size = get_model_size(mdl)
            local r = ENTITY.GET_ENTITY_ROTATION(main_veh, 0)
            left_new = entities.create_vehicle(mdl, players.get_position(players.user()), ENTITY.GET_ENTITY_HEADING(main_veh))
            ENTITY.ATTACH_ENTITY_TO_ENTITY(left_new, main_veh, 0, -size.x*i, 0.0, 0.0, 0.0, 0.0, 0.0, true, false, false, false, 0, true)
            right_new = entities.create_vehicle(mdl, players.get_position(players.user()), ENTITY.GET_ENTITY_HEADING(main_veh))
            ENTITY.ATTACH_ENTITY_TO_ENTITY(right_new, main_veh, 0, size.x*i, 0.0, 0.0, 0.0, 0.0, 0.0, true, false, false, false, 0, true)
        end
    end
end)

cinematic_autod = false
menu.toggle(my_vehicle_root, translations.cinematic_auto_drive, {translations.cinematic_auto_drive_cmd}, translations.cinematic_auto_drive_desc, function(on)
    cinematic_autod = on
end)

menu.action(my_vehicle_root, translations.break_rudder, {translations.break_rudder_cmd}, translations.break_rudder_desc, function(click_type)
    if player_cur_car ~= 0 then
        VEHICLE.SET_VEHICLE_RUDDER_BROKEN(player_cur_car, true)
    end
end)

menu.toggle_loop(my_vehicle_root, translations.force_spawn_countermeasures, {translations.force_spawn_countermeasures_cmd}, translations.force_spawn_countermeasures_desc, function(on)
    if PAD.IS_CONTROL_PRESSED(46, 46) then
        local target = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), math.random(-5, 5), -30.0, math.random(-5, 5))
        --MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(target['x'], target['y'], target['z'], target['x'], target['y'], target['z'], 300.0, true, -1355376991, players.user_ped(), true, false, 100.0)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(target['x'], target['y'], target['z'], target['x'], target['y'], target['z'], 100.0, true, 1198879012, players.user_ped(), true, false, 100.0)
    end
end)

--SET_VEHICLE_DOOR_CONTROL

tesla_ped = 0
menu.action(my_vehicle_root, translations.tesla_summon, {translations.tesla_summon_cmd}, translations.tesla_summon_desc, function(click_type)
    lastcar = PLAYER.GET_PLAYERS_LAST_VEHICLE()
    if lastcar ~= 0 then
        local plyr = PLAYER.PLAYER_PED_ID()
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(plyr, 0.0, 5.0, 0.0)
        local phash = -67533719
        request_model_load(phash)
        tesla_ped = entities.create_ped(32, phash, coords, ENTITY.GET_ENTITY_HEADING(plyr))
        tesla_blip = HUD.ADD_BLIP_FOR_ENTITY(tesla_ped)
        HUD.SET_BLIP_COLOUR(tesla_blip, 7)
        ENTITY.SET_ENTITY_VISIBLE(tesla_ped, false, 0)
        ENTITY.SET_ENTITY_INVINCIBLE(tesla_ped, true)
        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(tesla_ped, true)
        PED.SET_PED_FLEE_ATTRIBUTES(tesla_ped, 0, false)
        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(lastcar, true)
        PED.SET_PED_INTO_VEHICLE(tesla_ped, lastcar, -1)
        TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(tesla_ped, lastcar, coords['x'], coords['y'], coords['z'], 300.0, 786996, 5)
    end
end)


menu.toggle_loop(my_vehicle_root, translations.horn_spam, {translations.horn_spam_cmd}, "", function(toggle)
    if player_cur_car ~= 0 and  PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), true) then
        VEHICLE.SET_VEHICLE_MOD(player_cur_car, 14, math.random(0, 51), false)
        PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 86, 1.0)
        util.yield(50)
        PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 86, 0.0)
    end
end)

local seat_shifter_list = menu.list_action(my_vehicle_root, translations.shift_seat, {translations.shift_seat_cmd}, "", {translations.no_active_veh}, function(index, value)
    if player_cur_car ~= 0 and value ~= translations.no_active_veh then
        if VEHICLE.IS_VEHICLE_SEAT_FREE(player_cur_car, tonumber(value), true) then 
            PED.SET_PED_INTO_VEHICLE(players.user_ped(), player_cur_car, tonumber(value))
        else
            notify(translations.seat_taken)
        end
    end
end)
menu.click_slider(my_vehicle_root, translations.drop_bombs, {translations.drop_bombs_cmd}, "", 1, 100, 10, 1, function(num_bombs)
    if player_cur_car ~= 0 then 
        for i=0, num_bombs do
            local veh_size = get_model_size(ENTITY.GET_ENTITY_MODEL(player_cur_car))
            local bomb_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_cur_car, 0.0, 0.0, - (veh_size.y - 3.0))
            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(bomb_pos.x, bomb_pos.y, bomb_pos.z, bomb_pos.x, bomb_pos.y, bomb_pos.z-0.1, 100.0, true, -1312131151, players.user_ped(), true, false, 100, player_cur_car)
            util.yield(100)
        end
    end
end)

menu.action(my_vehicle_root, translations.set_veh_engine_sound, {"customenginesound"}, "", function(on_click)
    if player_cur_car ~= 0 then
        notify(translations.set_veh_engine_sound_instr)
        menu.show_command_box("customenginesound ")
    end
end, function(veh)
    if player_cur_car ~= 0 then
        local hash = util.joaat(veh)
        if not STREAMING.IS_MODEL_VALID(hash) then 
            notify(translations.invalid_veh_name)
            return
        end
        if VEHICLE.IS_THIS_MODEL_A_CAR(hash) then
            AUDIO.FORCE_USE_AUDIO_GAME_OBJECT(player_cur_car, veh)
            notify(translations.engine_sound_set ..  veh)
        else
            notify(translations.not_a_car)
        end
    end
end)

menu.action(my_vehicle_root, translations.dewheel, {"dewheel"}, "", function(on_click)
    if player_cur_car ~= 0 then
        for i=0,47 do
            entities.detach_wheel(entities.get_user_vehicle_as_pointer(false), i)
        end
    end
end)

menu.action(my_vehicle_root, translations.dewindow, {"dewindow"}, "", function(on_click)
    if player_cur_car ~= 0 then
        for i=0,7 do
            VEHICLE.SMASH_VEHICLE_WINDOW(player_cur_car, i)
        end
    end
end)


menu.toggle_loop(my_vehicle_root, translations.rainbow_headlights, {"rgbhdlights"}, "", function(on)
    if player_cur_car ~= 0 then 
        VEHICLE.TOGGLE_VEHICLE_MOD(player_cur_car, 22, true)
        for i=1, 12 do
            VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(player_cur_car, i)  
            util.yield(500)
        end
    end
end)

local country_flags = {"apa_prop_flag_argentina", "apa_prop_flag_australia", "apa_prop_flag_austria", "apa_prop_flag_belgium", "apa_prop_flag_brazil", "apa_prop_flag_canada_yt", "apa_prop_flag_china", "apa_prop_flag_columbia", "apa_prop_flag_croatia", "apa_prop_flag_czechrep", "apa_prop_flag_denmark", "apa_prop_flag_england", "apa_prop_flag_eu_yt", "apa_prop_flag_finland", "apa_prop_flag_france", "apa_prop_flag_german_yt", "apa_prop_flag_hungary", "apa_prop_flag_ireland", "apa_prop_flag_israel", "apa_prop_flag_italy", "apa_prop_flag_jamaica", "apa_prop_flag_japan_yt", "apa_prop_flag_lstein", "apa_prop_flag_malta", "apa_prop_flag_mexico_yt", "apa_prop_flag_netherlands", "apa_prop_flag_newzealand", "apa_prop_flag_nigeria", "apa_prop_flag_norway", "apa_prop_flag_palestine", "apa_prop_flag_poland", "apa_prop_flag_portugal", "apa_prop_flag_puertorico", "apa_prop_flag_russia_yt", "apa_prop_flag_scotland_yt", "apa_prop_flag_script", "apa_prop_flag_slovakia", "apa_prop_flag_slovenia", "apa_prop_flag_southafrica", "apa_prop_flag_southkorea", "apa_prop_flag_spain", "apa_prop_flag_sweden", "apa_prop_flag_switzerland", "apa_prop_flag_turkey", "apa_prop_flag_uk_yt", "apa_prop_flag_us_yt", "apa_prop_flag_wales"}
local flags_fmt = {}
for _, flag in pairs(country_flags) do 
    table.insert(flags_fmt, first_to_upper(flag:gsub('apa_prop_flag_', ''):gsub('_yt', '')))
end

menu.list_action(my_vehicle_root, translations.attach_flag, {"attachflagtocar"}, "", flags_fmt, function(index, val)
    if player_cur_car ~= 0 then 
        local hash = util.joaat(country_flags[index])
        request_model_load(hash)
        local flag = entities.create_object(hash, players.get_position(players.user()))
        local ht = get_model_size(ENTITY.GET_ENTITY_MODEL(player_cur_car)).z
        ENTITY.ATTACH_ENTITY_TO_ENTITY(flag, player_cur_car, 0, 0, 0, ht, 0, 0, 0, true, false, false, false, 0, true)
    end
end)

menu.toggle_loop(drift_root, translations.draw_car_angle, {"carangle"}, "", function()
    if player_cur_car ~= 0 and PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), true) then
        local ang = math.abs(math.ceil(math.abs(ENTITY.GET_ENTITY_ROTATION(player_cur_car, 0).z) - math.abs(CAM.GET_GAMEPLAY_CAM_ROT(0).z)))
        directx.draw_text(0.5, 1.0, tostring(ang) .. '°', 5, 1.4, {r=1, g=1, b=1, a=1}, true)
    end
end)

menu.toggle_loop(my_vehicle_root, translations.draw_control_values, {"drawcontrolvalues"}, translations.draw_control_values_desc, function()
    if player_cur_car ~= 0 and PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), true) then
        local center_x = 0.8
        local center_y = 0.8
        -- main underlay
        directx.draw_rect(center_x - 0.062, center_y - 0.125, 0.12, 0.13, {r = 0, g = 0, b = 0, a = 0.2})
        -- throttle
        directx.draw_rect(center_x, center_y, 0.005, -PAD.GET_CONTROL_NORMAL(87, 87)/10, {r = 0, g = 1, b = 0, a =1 })
        -- brake 
        directx.draw_rect(center_x - 0.01, center_y, 0.005, -PAD.GET_CONTROL_NORMAL(72, 72)/10, {r = 1, g = 0, b = 0, a =1 })
        -- steering
        directx.draw_rect(center_x - 0.0025, center_y - 0.115, math.max(PAD.GET_CONTROL_NORMAL(146, 146)/20), 0.01, {r = 0, g = 0.5, b = 1, a =1 })
    end
end)


local m_shift_up_this_frame = false 
local m_shift_down_this_frame = false 

local manual_transmission_list = my_vehicle_root:list(translations.manual_transmission, {}, translations.manual_mode_desc)
local manual_mode = false 
menu.toggle(manual_transmission_list, translations.manual_mode, {}, translations.manual_mode_desc, function(on)
    manual_mode = on
    while true do 
        if player_cur_car ~= 0 then 
            local addr = entities.get_user_vehicle_as_pointer()
            local cur_gear = entities.get_current_gear(addr)
            local next_gear = entities.get_next_gear(addr)
            if not manual_mode then 
                entities.set_next_gear(addr, next_gear)
                break 
            end
            if m_shift_up_this_frame then
                if cur_gear ~= 6 then
                    entities.set_next_gear(addr, cur_gear + 1)
                end
                m_shift_up_this_frame = false 
            elseif m_shift_down_this_frame then 
                if cur_gear > 1 then 
                    entities.set_next_gear(addr, cur_gear - 1)
                end
                m_shift_down_this_frame = false 
            else
                entities.set_next_gear(addr, cur_gear)
            end
        end
        util.yield()
    end
end)

menu.action(manual_transmission_list, translations.next_gear, {}, translations.next_gear, function()
    if player_cur_car ~= 0 then 
        m_shift_up_this_frame = true 
    end
end)

menu.action(manual_transmission_list, translations.previous_gear, {}, translations.previous_gear, function()
    if player_cur_car ~= 0 then 
        m_shift_down_this_frame = true 
    end
end)



function get_vehicle_handling_value(veh, offset)
    local v_ptr = entities.handle_to_pointer(veh)
    local handling = memory.read_long(v_ptr + 0x918)
    return memory.read_float(handling + offset)
end

function set_vehicle_handling_value(veh, offset, value)
    local v_ptr = entities.handle_to_pointer(veh)
    local handling = memory.read_long(v_ptr + 0x918)
    memory.write_float(handling + offset, value)
end

-- i used some offsets from nowiry so credit to them

local last_vehicle_handling_data = {}
function set_vehicle_into_drift_mode(veh)
    local handling_values = {
        [0x0C] = 1900.0, -- fmass
        [0x20] = 0.0, -- vec com off x
        [0x24] = 0.0, -- vec com off y
        [0x28] = 0.0, -- vec com off z
        [0x30] = 1.0, -- vec inertia mult x
        [0x34] = 1.0, -- vec inertia mult y
        [0x38] = 1.0, -- vec inertia mult z
        [0x10] = 15.5, -- initial drag coeff
        [0x40] = 85.0, -- percent submerged
        [0x48] = 0.0,-- drive bias front
        [0x50] = 0.0,-- initial drive gears
        [0x60] = 1.9,-- initial drive force
        [0x54] = 1.0,-- fdrive interia
        [0x58] = 5.0,-- clutch change rate scale up
        [0x5C] = 5.0,-- clutch change rate scale down
        [0x68] = 200.0, -- initial drive max flat vel
        [0x6C] = 4.85, --  brake force
        [0x74] = 0.67, -- brake bias front
        [0x7C] = 3.5, -- handbrake force
        [0x80] = 1.2, -- steering lock
        [0x88] = 1.0, -- traction curve max
        [0x88] = 1.45, -- traction curve min
        [0x98] = 35.0, -- traction curve lateral
        [0xA0] = 0.15, -- traction curve spring delta max
        [0xA8] = 0.0, -- low speed traction loss mult
        [0xAC] = 0.0, -- camber stiffness
        [0xB0] = 0.45, -- traction bias front
        [0xB8] = 1.0, -- traction loss mult
        [0xBC] = 2.8, -- suspension force
        [0xC0] = 1.4, -- suspension comp damp
        [0xC4] = 2.2, -- suspension rebound damp
        [0xC8] = 0.06, -- suspension upper limit
        [0xCC] = -0.05, -- suspension lower limit
        [0xBC] = 2.8, -- suspension force
        [0xD0] = 0.0, -- suspension raise
        [0xD4] = 0.5, -- suspension bias front
        [0xD4] = 0.5, -- suspension bias front
    }
    for offset, value in pairs(handling_values) do 
        last_vehicle_handling_data[offset] = get_vehicle_handling_value(veh, offset)
        set_vehicle_handling_value(veh, offset, value)
    end
end

initial_d_mode = false
initial_d_score = false
function on_user_change_vehicle(vehicle)
    if vehicle ~= 0 then
        if initial_d_mode then 
            set_vehicle_into_drift_mode(vehicle)
        end

        local deez_nuts = {}
        local num_seats = VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(ENTITY.GET_ENTITY_MODEL(vehicle))
        for i=1, num_seats do
            if num_seats >= 2 then
                deez_nuts[#deez_nuts + 1] = tostring(i - 2)
            else
                deez_nuts[#deez_nuts + 1] = tostring(i)
            end
        end
        menu.set_list_action_options(seat_shifter_list, deez_nuts)

        if true then 
            native_invoker.begin_call()
            native_invoker.push_arg_int(vehicle)
            native_invoker.end_call("76D26A22750E849E")
        end

    end
end

function initial_d_score_thread()
    util.create_thread(function()
        local drift_score = 0
        local is_drifting = false
        while true do
            if not initial_d_mode or not initial_d_score then 
                util.stop_thread()
            end
            if player_cur_car ~= 0 and PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), true) then 
                if math.abs(ENTITY.GET_ENTITY_SPEED_VECTOR(player_cur_car, true).x) > 2 then 
                    is_drifting = true
                    drift_score = drift_score + 1
                    local c = ENTITY.GET_ENTITY_COORDS(player_cur_car)
                    c.z = c.z + 0.3
                    local score_pos = world_to_screen_coords(c.x, c.y, c.z)
                    directx.draw_text(score_pos.x, score_pos.y, "DRIFT SCORE: " .. tostring(drift_score), 5, 1, {r=1, g= 0.5, b = 0.4, a = 100}, true)
                else
                    if is_drifting then
                        is_drifting = false
                        notify("TOTAL DRIFT SCORE: " .. drift_score)
                    end
                    drift_score = 0
                end
            end
            util.yield()
        end
    end)
end

menu.toggle_loop(drift_root, translations.hold_shift_to_drift, {translations.hold_shift_to_drift_cmd}, translations.hold_shift_to_drift_desc, function(on)
    if PAD.IS_CONTROL_PRESSED(21, 21) then
        VEHICLE.SET_VEHICLE_REDUCE_GRIP(player_cur_car, true)
        VEHICLE.SET_VEHICLE_REDUCE_GRIP_LEVEL(player_cur_car, 0.0)
    else
        VEHICLE.SET_VEHICLE_REDUCE_GRIP(player_cur_car, false)
    end
end)

local shift_drift_toggle = false 
menu.toggle(drift_root, translations.toggle_shift_drift, {"shiftdrifttoggle"}, translations.toggle_shift_drift_desc, function(on)
    shift_drift_toggle = on
    while true do
        if player_cur_car ~= 0 then 
            if not shift_drift_toggle then 
                VEHICLE.SET_VEHICLE_REDUCE_GRIP(player_cur_car, false)
                break 
            end
            VEHICLE.SET_VEHICLE_REDUCE_GRIP(player_cur_car, true)
            VEHICLE.SET_VEHICLE_REDUCE_GRIP_LEVEL(player_cur_car, 0.0)
        end
        util.yield()
    end
end)

menu.toggle(drift_root, translations.initial_d_mode, {translations.initial_d_mode_cmd}, translations.initial_d_mode_desc, function(on, click_type)
    initial_d_mode = on
    initial_d_score_thread()
    if player_cur_car ~= 0 then 
        if on then
            set_vehicle_into_drift_mode(player_cur_car)
        else
            for offset, value in pairs(last_vehicle_handling_data) do
                set_vehicle_handling_value(player_cur_car, offset, value)
            end
        end
    end
end)

menu.toggle(drift_root, translations.initial_d_score, {}, "", function(on, click_type)
    initial_d_score = on
end)

menu.toggle_loop(my_vehicle_movement_root, translations.horn_boost, {translations.horn_boost_cmd}, translations.horn_boost_desc, function(on)
    if player_cur_car ~= 0 then
        VEHICLE.SET_VEHICLE_ALARM(player_cur_car, false)
        if AUDIO.IS_HORN_ACTIVE(player_cur_car) then
            ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(player_cur_car, 1, 0.0, 1.0, 0.0, true, true, true, true)
        end
    end
end)

local thrust_cam_dir_add = 1.25
local before_vel = {x = 1, y = 1, z = 1}
menu.toggle_loop(drift_root, translations.thrust_in_cam_direction, {"thrustindir"}, translations.thrust_in_cam_direction_desc, function(on)
    if player_cur_car ~= 0 and PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), true) then 
        if util.is_key_down("X") then 
            local camRot = CAM.GET_FINAL_RENDERED_CAM_ROT(2)
            -- credits to jinxscript
            local inst = v3.new()
            v3.set(inst,CAM.GET_FINAL_RENDERED_CAM_ROT(2))
            local tmp = v3.toDir(inst)
            v3.set(inst, v3.get(tmp))
            v3.mul(inst, 10)
            v3.set(tmp, CAM.GET_FINAL_RENDERED_CAM_COORD())
            v3.add(inst, tmp)
            local aim_pos = inst
            local car_pos = ENTITY.GET_ENTITY_COORDS(player_cur_car)
            local c = {}
            c.x = before_vel.x+thrust_cam_dir_add + (aim_pos.x - car_pos.x)
            c.y = before_vel.y+thrust_cam_dir_add + (aim_pos.y - car_pos.y)
            ENTITY.SET_ENTITY_VELOCITY(player_cur_car, c.x, c.y, -0.002)
        else 
            before_vel = ENTITY.GET_ENTITY_VELOCITY(player_cur_car)
        end
    end
end)
menu.slider_float(drift_root, translations.thrust_in_cam_direction_mod, {"thrustindiradd"}, translations.thrust_in_cam_direction_mod_desc, 0, 3000, 125, 1, function(s)
    thrust_cam_dir_add = s * -0.001
end)

-- yoinked from jerry, which im sure he doesnt mind since he yoinked from me ;)
-- i basically had to rewrite everything here since he has his own "lang". so
local nitro_duration = 5000
local nitro_power = 2000
menu.toggle_loop(my_vehicle_movement_root, translations.nitro, {'nitro'}, translations.nitro_desc, function(toggle)
    if PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), true) and player_cur_car ~= 0 then
        if PAD.IS_CONTROL_JUST_PRESSED(357, 357) then 
            request_ptfx_asset('veh_xs_vehicle_mods')
            VEHICLE.SET_OVERRIDE_NITROUS_LEVEL(player_cur_car, true, 100, nitro_power, 99999999999, false)
            ENTITY.SET_ENTITY_MAX_SPEED(player_cur_car, 2000)
            VEHICLE.SET_VEHICLE_MAX_SPEED(player_cur_car, 2000)
            util.yield(nitro_duration)
            VEHICLE.SET_OVERRIDE_NITROUS_LEVEL(player_cur_car, false, 0, 0, 0, false)
            VEHICLE.SET_VEHICLE_MAX_SPEED(player_cur_car, 0.0)
        end
    end
end)

menu.slider(my_vehicle_movement_root, translations.nitro_duration, {'nitroduration'}, translations.in_seconds, 1, 30, 5, 1, function(val)
    nitro_duration = val * 1000
end)

menu.slider(my_vehicle_movement_root, translations.nitro_power, {'nitropower'}, "", 1, 10000, 2000, 1, function(val)
    nitro_power = val
end)


cur_v_stance = 0.0
menu.click_slider_float(vehicle_workshop_root, translations.stance, {translations.stance_cmd}, "", 0, 200, 0, 1, function(s)
    cur_v_stance = s * -0.001
    if player_cur_car ~= 0 then
        set_vehicle_handling_value(player_cur_car, 0xD0, cur_v_stance)
    end
end)

-- COMBAT
-- COMBAT-RELATED toggles, actions, and functionality
function get_player_ptr()
    return entities.handle_to_pointer(players.user_ped())
end

function get_player_info()
    return memory.read_long(get_player_ptr() + 0x10C8)
end

function get_weapon_base()
    return memory.read_long(get_player_ptr() + 0x10B8)
end

function get_gun_ptr()
    return memory.read_long(get_weapon_base() + 0x20)
end

-- ## silent aimbot
silent_aimbotroot = menu.list(combat_root, translations.silent_aimbot, {translations.silent_aimbot_root_cmd}, translations.silent_aimbot_desc)
anti_aim_root = menu.list(combat_root, translations.anti_aim, {}, translations.anti_aim_desc)
triggerbot_root = menu.list(combat_root, translations.triggerbot, {}, translations.triggerbot_desc)
kill_auraroot = menu.list(combat_root, translations.kill_aura, {translations.kill_aura_root_cmd}, translations.kill_aura_desc)

weapons_root = menu.list(combat_root, translations.spec_weapons, {translations.spec_weapons_cmd}, translations.spec_weapons_desc)

-- preload the textures
menu.toggle_loop(combat_root, translations._3d_crosshair, {translations._3d_crosshair_cmd}, translations._3d_crosshair_cmd, function(on)
    request_texture_dict_load('visualflow')
    local rc = raycast_gameplay_cam(-1, 10000.0)[2]
    local c = players.get_position(players.user())
    local dist = MISC.GET_DISTANCE_BETWEEN_COORDS(rc.x, rc.y, rc.z, c.x, c.y, c.z, false)
    local dir = v3.toDir(CAM.GET_GAMEPLAY_CAM_ROT(0))
    size = {}
    size.x = 0.5+(dist/50)
    size.y = 0.5+(dist/50)
    size.z = 0.5+(dist/50)
    GRAPHICS.DRAW_MARKER(3, rc.x, rc.y, rc.z, 0.0, 0.0, 0.0, 0.0, 90.0, 0.0, size.y, 1.0, size.x, 255, 255, 255, 50, false, true, 2, false, 'visualflow', 'crosshair')
end)

anti_aim = false
menu.toggle(anti_aim_root, translations.anti_aim, {translations.anti_aim_cmd},  translations.anti_aim_desc, function(on)
    anti_aim = on
    mod_uses("player", if on then 1 else -1)
end)

anti_aim_notify = false
menu.toggle(anti_aim_root, translations.anti_aim_notify, {translations.anti_aim_notify_cmd},  translations.anti_aim_notify_desc, function(on)
    anti_aim_notify = on
end)

anti_aim_angle = 2
menu.click_slider(anti_aim_root, translations.anti_aim_angle, {translations.anti_aim_angle_cmd}, "", 0, 180, 2, 1, function(s)
    anti_aim_angle = s
end)

local anti_aim_types = {"Script event", "Ragdoll", "Explode"}
local anti_aim_type = 1
menu.list_select(anti_aim_root, translations.anti_aim_type, {translations.anti_aim_type_cmd}, translations.anti_aim_type_desc,  anti_aim_types, 1, function(index)
    anti_aim_type = index
end)

triggerbot_delay = 100

local ent_alloc = memory.alloc_int()
menu.toggle_loop(triggerbot_root, translations.triggerbot, {translations.triggerbot_cmd},  translations.triggerbot_desc, function(on)
    PLAYER.GET_ENTITY_PLAYER_IS_FREE_AIMING_AT(players.user(), ent_alloc)
    if memory.read_int(ent_alloc) ~= 0 then 
        local ent = memory.read_int(ent_alloc)
        if ENTITY.GET_ENTITY_TYPE(ent) == 1 and PLAYER.IS_PLAYER_FREE_AIMING_AT_ENTITY(players.user(), ent) then
            if PED.GET_PED_CONFIG_FLAG(players.user_ped(), 78, true) then  
                PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 24, 1.0)
                util.yield(triggerbot_delay)
                PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 24, 0.0)
            end
        end
    end
end)

menu.click_slider(triggerbot_root, translations.triggerbot_delay, {}, translations.triggerbot_delay_desc, 10, 5000, 100, 1, function(s)
    triggerbot_delay = s
end)


kill_aura = false
menu.toggle(kill_auraroot, translations.kill_aura, {translations.kill_aura_cmd},  translations.kill_aura_desc, function(on)
    kill_aura = on
    mod_uses("ped", if on then 1 else -1)
end)

kill_aura_peds = false
menu.toggle(kill_auraroot, translations.kill_peds, {translations.kill_peds_cmd}, "", function(on)
    kill_aura_peds = on
end)

kill_aura_players = false
menu.toggle(kill_auraroot, translations.kill_players, {translations.kill_players_cmd}, "", function(on)
    kill_aura_players = on
end)

kill_aura_friends = false
menu.toggle(kill_auraroot, translations.target_friends, {translations.ka_target_friends}, "", function(on)
    kill_aura_friends= on
end)


kill_aura_dist = 20
menu.slider(kill_auraroot, translations.kill_aura_radius, {translations.kill_aura_radius_cmd}, "", 1, 100, 20, 1, function(s)
    kill_aura_dist = s
end)


-- entity gun
entity_gun = menu.list(weapons_root, translations.entity_gun, {translations.entity_gun_root_cmd}, translations.entity_gun_desc)
entgun = false
shootent = -422877666
menu.toggle(entity_gun, translations.entity_gun, {translations.entity_gun_cmd}, translations.entity_gun_desc, function(on)
    entgun = on
end)

custom_egun_model = "prop_tool_blowtorch"
menu.text_input(entity_gun, translations.custom_eg_model, {translations.custom_eg_model_cmd}, translations.custom_eg_model_desc, function(on_input)
    custom_egun_model = on_input
end, "prop_tool_blowtorch")


local entity_hashes = {-422877666, -717142483, util.joaat("prop_paints_can07")}
local entity_options = {translations.dildo, translations.soccer_ball, translations.bucket, translations.custom}
menu.list_action(entity_gun, translations.entity_gun_selection, {translations.entity_gun_selection_cmd}, "", entity_options, function(index, value, click_type)
    if index < 4 then
        shootent = entity_hashes[index]
    else
        shootent = util.joaat(custom_egun_model)
    end
end)

entgungrav = false
menu.toggle(entity_gun, translations.entity_gun_gravity, {translations.entity_gun_gravity_cmd}, "", function(on)
    entgungrav = on
end)

saimbot_mode = "closest"
local function get_aimbot_target()
    local dist = 1000000000
    local cur_tar = 0
    -- an aimbot should have immaculate response time so we shouldnt rely on the other entity pools for this data
    for k,v in pairs(entities.get_all_peds_as_handles()) do
        local target_this = true
        local player_pos = players.get_position(players.user())
        local ped_pos = ENTITY.GET_ENTITY_COORDS(v, true)
        local this_dist = MISC.GET_DISTANCE_BETWEEN_COORDS(player_pos['x'], player_pos['y'], player_pos['z'], ped_pos['x'], ped_pos['y'], ped_pos['z'], true)
        if players.user_ped() ~= v and not ENTITY.IS_ENTITY_DEAD(v) then
            if not satarget_players then
                if PED.IS_PED_A_PLAYER(v) then
                    target_this = false
                end
            end
            if not satarget_npcs then
                if not PED.IS_PED_A_PLAYER(v) then
                    target_this = false
                end
            end
            if not ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(players.user_ped(), v, 17) then
                target_this = false
            end
            if satarget_usefov then
                if not PED.IS_PED_FACING_PED(players.user_ped(), v, sa_fov) then
                    target_this = false
                end
            end
            if satarget_novehicles then
                if PED.IS_PED_IN_ANY_VEHICLE(v, true) then 
                    target_this = false
                end
            end
            if satarget_nogodmode then
                if not ENTITY.GET_ENTITY_CAN_BE_DAMAGED(v) then 
                    target_this = false 
                end
            end
            if not satarget_targetfriends and satarget_players then
                if PED.IS_PED_A_PLAYER(v) then
                    local pid = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(v)
                    local hdl = pid_to_handle(pid)
                    if NETWORK.NETWORK_IS_FRIEND(hdl) then
                        target_this = false 
                    end
                end
            end
            if saimbot_mode == "closest" then
                if this_dist <= dist then
                    if target_this then
                        dist = this_dist
                        cur_tar = v
                    end
                end
            end 
        end
    end
    return cur_tar
end
sa_showtarget = true
satarget_usefov = true
menu.toggle_loop(silent_aimbotroot, translations.silent_aimbot, {translations.silent_aimbot_cmd}, translations.silent_aimbot_desc, function(toggle)
    local target = get_aimbot_target()
    if target ~= 0 then
        --local t_pos = ENTITY.GET_ENTITY_COORDS(target, true)
        local t_pos = PED.GET_PED_BONE_COORDS(target, 31086, 0.01, 0, 0)
        local t_pos2 = PED.GET_PED_BONE_COORDS(target, 31086, -0.01, 0, 0.00)
        if sa_showtarget then
            util.draw_ar_beacon(t_pos)
        end
        if PED.IS_PED_SHOOTING(players.user_ped()) then
            local wep = WEAPON.GET_SELECTED_PED_WEAPON(players.user_ped())
            local dmg = WEAPON.GET_WEAPON_DAMAGE(wep, 0)
            if satarget_damageo then
                dmg = sa_odmg
            end
            local veh = PED.GET_VEHICLE_PED_IS_IN(target, false)
            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(t_pos['x'], t_pos['y'], t_pos['z'], t_pos2['x'], t_pos2['y'], t_pos2['z'], dmg, true, wep, players.user_ped(), true, false, 10000, veh)
        end
    end
end)

menu.toggle(silent_aimbotroot, translations.silent_aimbot_players, {translations.silent_aimbot_players_cmd}, "", function(on)
    satarget_players = on
end)

menu.toggle(silent_aimbotroot, translations.silent_aimbot_npcs, {translations.silent_aimbot_npcs_cmd}, "", function(on)
    satarget_npcs = on
end)

menu.toggle(silent_aimbotroot, translations.use_fov, {translations.use_fov_cmd}, translations.use_fov_desc, function(on)
    satarget_usefov = on
end, true)

sa_fov = 60
menu.slider(silent_aimbotroot, translations.fov, {translations.fov_cmd}, "", 1, 270, 60, 1, function(s)
    sa_fov = s
end)

menu.toggle(silent_aimbotroot, translations.ignore_targets_inside_vehicles, {translations.ignore_targets_inside_vehicles.cmd}, translations.ignore_targets_inside_vehicles_desc, function(on)
    satarget_novehicles = on
end)

satarget_nogodmode = true
menu.toggle(silent_aimbotroot,  translations.ignore_godmoded_targets, {translations.ignore_godmoded_targets_cmd}, translations.ignore_godmoded_targets_desc, function(on)
    satarget_nogodmode = on
end, true)

menu.toggle(silent_aimbotroot, translations.target_friends, {translations.sa_target_friends_cmd}, "", function(on)
    satarget_targetfriends = on
end)

menu.toggle(silent_aimbotroot, translations.damage_override, {translations.damage_override_cmd}, "", function(on)
    satarget_damageo = on
end)

sa_odmg = 100
menu.slider(silent_aimbotroot, translations.damage_override_amount, {translations.damage_override_amount_cmd}, "", 1, 1000, 100, 1, function(s)
    sa_odmg = s
end)

menu.toggle(silent_aimbotroot, translations.display_target, {translations.display_target_cmd}, translations.display_target_desc, function(on)
    sa_showtarget = on
end, true)
--

local start_tint
local cur_tint
menu.toggle_loop(weapons_root, translations.rainbow_weapon_tint, {translations.rainbow_weapon_tint_cmd}, translations.rainbow_weapon_tint_desc, function()
    local plyr = players.user_ped()
    if start_tint == nil then
        start_tint = WEAPON.GET_PED_WEAPON_TINT_INDEX(plyr, WEAPON.GET_SELECTED_PED_WEAPON(plyr))
        cur_tint = start_tint
    end
    cur_tint = if cur_tint == 8 then 0 else cur_tint + 1
    WEAPON.SET_PED_WEAPON_TINT_INDEX(plyr,WEAPON.GET_SELECTED_PED_WEAPON(plyr), cur_tint)
    util.yield(50)
end, function()
        WEAPON.SET_PED_WEAPON_TINT_INDEX(players.user_ped(),WEAPON.GET_SELECTED_PED_WEAPON(players.user_ped()), start_tint)
        start_tint = nil
end)

menu.toggle(weapons_root, translations.invisible_weapons, {translations.invisible_weapons_cmd}, translations.invisible_weapons_desc, function(on)
    local plyr = players.user_ped()
    WEAPON.SET_PED_CURRENT_WEAPON_VISIBLE(plyr, not on, false, false, false) 
end)

aim_info = false
menu.toggle(weapons_root, translations.aim_info, {translations.aim_info_cmd}, translations.aim_info_desc, function(on)
    aim_info = on
end)

gun_stealer = false
menu.toggle(weapons_root, translations.car_stealer_gun, {translations.car_stealer_gun_cmd}, translations.car_stealer_gun_desc, function(on)
    gun_stealer = on
end)

paintball = false
menu.toggle(weapons_root, translations.paintball, {translations.paintball_cmd}, translations.paintball_desc, function(on)
    paintball = on
end)

drivergun = false
menu.toggle(weapons_root, translations.npc_driver_gun, {translations.npc_driver_gun_cmd}, translations.npc_driver_gun_desc, function(on)
    drivergun = on
end)

grapplegun = false
menu.toggle(weapons_root, translations.grapple_gun, {translations.grapple_gun_cmd}, translations.grapple_gun_desc, function(on)
    grapplegun = on
    if on then
        WEAPON.GIVE_WEAPON_TO_PED(players.user_ped(), util.joaat('weapon_pistol'), 9999, false, false)
        notify(translations.grapple_gun_active)
    end
end)

menu.toggle_loop(weapons_root, translations.kick_gun, {"kickgun"}, "", function()
    local ent = get_aim_info()['ent']
    if PED.IS_PED_SHOOTING(players.user_ped()) then
        if ENTITY.IS_ENTITY_A_PED(ent) then
            if PED.IS_PED_A_PLAYER(ent) then
                local pid = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(ent)
                if players.get_host() == pid then 
                    notify(translations.host_warn)
                    return
                end
                menu.trigger_commands("kick" .. players.get_name(pid))
            end
        end
    end
end)


-- OBJECTS

objects_thread = util.create_thread(function (thr)
    local projectile_blips = {}
    while true do
        for k,b in pairs(projectile_blips) do
            if HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(b) == 0 then 
                util.remove_blip(b) 
                projectile_blips[k] = nil
            end
        end
        if object_uses > 0 then
            if show_updates then
                ls_log("Object pool is being updated")
            end
            all_objects = entities.get_all_objects_as_pointers()
            for k, obj_ptr in pairs(all_objects) do
                --- PROJECTILE SHIT
                local obj_model = entities.get_model_hash(obj_ptr)
                if is_entity_a_projectile(obj_model) then
                    if projectile_warn then
                        local obj_hdl = entities.pointer_to_handle(obj_ptr)
                        local c = ENTITY.GET_ENTITY_COORDS(obj_hdl)
                        local screen_c = world_to_screen_coords(c.x, c.y, c.z)
                        local color = to_rgb(255, 0, 0, 255)
                        --directx.draw_text(screen_c.x, screen_c.y, "!", 5, 0.100, color, false)
                        request_texture_dict_load('visualflow')
                        GRAPHICS.DRAW_SPRITE('visualflow', 'crosshair', screen_c.x, screen_c.y, 0.02, 0.03, 0.0, 255, 0, 0, 255, true, 0)
                    end
                    if projectile_cleanse then 
                        entities.delete_by_pointer(obj_ptr)
                    end

                    if projectile_spaz then
                        local obj_hdl = entities.pointer_to_handle(obj_ptr)
                        --local target = entity.get_entity_owner(obj) 
                        local strength = 20
                        ENTITY.APPLY_FORCE_TO_ENTITY(obj_hdl, 1, math.random(-strength, strength), math.random(-strength, strength), math.random(-strength, strength), 0.0, 0.0, 0.0, 1, true, false, true, true, true)
                    end
                    if slow_projectiles then
                        local obj_hdl = entities.pointer_to_handle(obj_ptr)
                        --ENTITY.SET_ENTITY_VELOCITY(obj, 0.0, 0.0, 0.0)
                        ENTITY.SET_ENTITY_MAX_SPEED(obj_hdl, 0.5)
                    end
                    if blip_projectiles then
                        local obj_hdl = entities.pointer_to_handle(obj_ptr)
                        if HUD.GET_BLIP_FROM_ENTITY(obj_hdl) == 0 then
                            local proj_blip = HUD.ADD_BLIP_FOR_ENTITY(obj_hdl)
                            HUD.SET_BLIP_SPRITE(proj_blip, 443)
                            HUD.SET_BLIP_COLOUR(proj_blip, 75)
                            projectile_blips[#projectile_blips + 1] = proj_blip 
                        end
                    end
                end
                --------------
                if l_e_o_on then
                    local size = get_model_size(obj_model)
                    if size.x > l_e_max_x or size.y > l_e_max_y or size.z > l_e_max_y then
                        entities.delete_by_pointer(obj_ptr)
                    end
                end
            end    
        end
        util.yield()
    end
end)


peds_thread = util.create_thread(function (thr)
    while true do
        if ped_uses > 0 then
            ls_log("Ped pool is being updated")
            all_peds = entities.get_all_peds_as_handles()
            for k,ped in pairs(all_peds) do
                if kill_aura then
                    if (kill_aura_peds and not PED.IS_PED_A_PLAYER(ped)) or (kill_aura_players and PED.IS_PED_A_PLAYER(ped)) then
                        local pid = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(v)
                        local hdl = pid_to_handle(pid)
                        if (kill_aura_friends and not NETWORK.NETWORK_IS_FRIEND(hdl)) or not kill_aura_friends then
                            target = ENTITY.GET_ENTITY_COORDS(ped, false)
                            m_coords = ENTITY.GET_ENTITY_COORDS(players.user_ped(), false)
                            if MISC.GET_DISTANCE_BETWEEN_COORDS(m_coords.x, m_coords.y, m_coords.z, target.x, target.y, target.z, true) < kill_aura_dist and ENTITY.GET_ENTITY_HEALTH(ped) > 0 then
                                MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(target['x'], target['y'], target['z'], target['x'], target['y'], target['z']+0.1, 300.0, true, 100416529, players.user_ped(), true, false, 100.0)
                            end
                        end
                    end
                end
                
                if not PED.IS_PED_A_PLAYER(ped) then

                    if make_peds_cops then 
                        PED.SET_PED_AS_COP(ped, true)
                    end

                    if ped_no_ragdoll then 
                        PED.SET_PED_CAN_RAGDOLL(ped, false)
                    end

                    if ped_godmode then 
                        ENTITY.SET_ENTITY_INVINCIBLE(ped, true)
                    end

                    if hooker_esp then
                        local mdl = ENTITY.GET_ENTITY_MODEL(ped)
                        if PED.IS_PED_USING_SCENARIO(ped, "WORLD_HUMAN_PROSTITUTE_HIGH_CLASS") or PED.IS_PED_USING_SCENARIO(ped,"WORLD_HUMAN_PROSTITUTE_LOW_CLASS") then 
                            util.draw_ar_beacon(ENTITY.GET_ENTITY_COORDS(ped))
                        end
                    end

                    if ped_no_crits then
                        PED.SET_PED_SUFFERS_CRITICAL_HITS(ped, false)
                    end

                    if ped_highperception then
                        PED.SET_PED_HIGHLY_PERCEPTIVE(ped, true)
                        PED.SET_PED_HEARING_RANGE(ped, 1000.0)
                        PED.SET_PED_SEEING_RANGE(ped, 1000.0)
                        PED.SET_PED_VISUAL_FIELD_MIN_ANGLE(ped, 1000.0)
                    end

                    if ped_allcops then
                        PED.SET_PED_AS_COP(ped, true)
                    end

                    if ped_theflash then
                        PED.SET_PED_MOVE_RATE_OVERRIDE(ped, 10.0)
                    end

                    if rain_peds then 
                        if not ENTITY.IS_ENTITY_IN_AIR(ped) then 
                            local ped_c = ENTITY.GET_ENTITY_COORDS(players.user_ped())
                            ped_c.x = ped_c.x + math.random(-50, 50)
                            ped_c.y = ped_c.y + math.random(-50, 50)
                            ped_c.z = ped_c.z + math.random(50, 100)
                            ENTITY.SET_ENTITY_COORDS(ped, ped_c.x, ped_c.y, ped_c.z)
                            ENTITY.SET_ENTITY_VELOCITY(ped, 0.0, 0.0, -1.0)
                        end
                    end

                    if ped_hardened then
                        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 5, true)
                        PED.SET_PED_FLEE_ATTRIBUTES(ped, 0, false)
                        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true)
                        PED.SET_PED_ACCURACY(ped, 100)
                        PED.SET_PED_COMBAT_ABILITY(ped, 3)
                    end

                    if peds_ignore then
                        if not PED.GET_PED_CONFIG_FLAG(ped, 17, true) then
                            PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
                            TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
                        end
                    end
                    if wantthesmoke then 
                        PED.SET_PED_AS_ENEMY(ped, true)
                        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 5, true)
                        PED.SET_PED_FLEE_ATTRIBUTES(ped, 0, false)
                        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true)
                        TASK.TASK_COMBAT_PED(ped, players.user_ped(), 0, 16)
                    end

                    if apose_peds then 
                        if PED.IS_PED_IN_ANY_VEHICLE(ped, true) then
                            TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
                        end
                        request_anim_set("move_crawl")
                        PED.SET_PED_MOVEMENT_CLIPSET(ped, "move_crawl", -1)
                    end

                    if roast_voicelines then
                        local roasts = {
                            "GENERIC_INSULT_MED",
                            "GENERIC_INSULT_HIGH"
                        }
                        AUDIO.PLAY_PED_AMBIENT_SPEECH_NATIVE(ped, roasts[math.random(#roasts)], "SPEECH_PARAMS_FORCE_SHOUTED")
                    end
    
                    if sex_voicelines then
                        local voice_name = all_sex_voicenames[math.random(1, #all_sex_voicenames)]
                        local speeches = {
                            "SEX_GENERIC_FEM",
                            "SEX_HJ",
                            "SEX_ORAL_FEM",
                            "SEX_CLIMAX",
                            "SEX_GENERIC"
                        }
                        AUDIO.PLAY_PED_AMBIENT_SPEECH_WITH_VOICE_NATIVE(ped, speeches[math.random(#speeches)], voice_name, "SPEECH_PARAMS_FORCE_SHOUTED", 0)
                    end
    
                    if screamall then
                        local screams = {
                            "SCREAM_SCARED",
                            "SCREAM_PANIC_SHORT",
                            "SCREAM_TERROR"

                        }
                        AUDIO.PLAY_PED_AMBIENT_SPEECH_NATIVE(ped, screams[math.random(#screams)], "SPEECH_PARAMS_FORCE_SHOUTED")
                    end

                    if php_bars and get_distance_between_entities(players.user_ped(), ped) < 100.0 and not PED.IS_PED_FATALLY_INJURED(ped) and ENTITY.IS_ENTITY_ON_SCREEN(ped) then
                        local headPos = PED.GET_PED_BONE_COORDS(ped, 0x322C --[[head]], 0.35, 0., 0.)
                        local perc = 0.0

                        if not PED.IS_PED_FATALLY_INJURED(ped) then
                            local maxHealth = PED.GET_PED_MAX_HEALTH(ped)
                            local health = ENTITY.GET_ENTITY_HEALTH(ped)
                            ---Peds die when their health is below the injured threshold
                            ---which is 100 by default, so we subtract it here so the perc is
                            ---zero when a ped dies.
                            perc = (health - 100.0) / (maxHealth - 100.0)
                            if perc > 1.0 then perc = 1.0  end
                        end
                        
                        local colour = get_health_colour(perc)
                        local scale = v3.new(0.10, 0.0, interpolate(0.0, 0.7, perc))
                        draw_marker(43, headPos, v3(), v3(), scale, false, colour, 0, 0)
                    end

                    if allpeds_gun ~= 0 then
                        WEAPON.GIVE_WEAPON_TO_PED(ped, allpeds_gun, 9999, false, true)
                    end

                    -- ONLINE INTERACTIONS
                    if aped_combat then
                        local tar = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(combat_tar)
                        if not PED.IS_PED_IN_COMBAT(ped, tar) then 
                            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 5, true)
                            PED.SET_PED_FLEE_ATTRIBUTES(ped, 0, false)
                            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true)
                            TASK.TASK_COMBAT_PED(ped, combat_tar, 0, 16)
                        end
                    end


                end
            end
        end
        util.yield()
    end
end)

-- PEDS
ped_b_root = menu.list(peds_root, translations.ped_behavior, {translations.ped_behavior_cmd}, "")
ped_attributes_root = menu.list(peds_root, translations.ped_attributes, {translations.ped_attributes_cmd}, "")
ped_voice = menu.list(peds_root, translations.ped_voice, {translations.ped_voice_cmd}, "")
ped_spawn = menu.list(peds_root, translations.ped_spawn, {translations.ped_spawn_cmd}, "")

-- SPAWNING PEDS
num_peds_spawn = 1
local function spawn_ped(hash)
    coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 0.0, 3.0, 0.0)
    local peds_spawned = {}
    request_model_load(hash)
    for i=1, num_peds_spawn do
        ped = entities.create_ped(28, hash, coords, math.random(0, 270))
        peds_spawned[#peds_spawned + 1] = ped
        if spawn_dancing then 
            local d = "anim@amb@nightclub_island@dancers@crowddance_facedj@hi_intensity"
            request_anim_dict(d)
            TASK.TASK_PLAY_ANIM(ped, d, "hi_dance_facedj_13_v2_male^5", 1.0, 1.0, -1, 3, 0.5, false, false, false)
            PED.SET_PED_KEEP_TASK(ped, true)
        end
        if is_pet then
            all_pets[#all_pets + 1] = ped
            ENTITY.SET_ENTITY_INVINCIBLE(ped, true)
            TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(ped, players.user_ped(), 0, -1, 0, 7.0, -1, 1, true)
            PED.SET_PED_COMBAT_ABILITY(ped, 3)
            PED.SET_PED_FLEE_ATTRIBUTES(ped, 0, false)
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 5, true)
            local blip = HUD.ADD_BLIP_FOR_ENTITY(ped)
            HUD.SET_BLIP_COLOUR(blip, 11)
        end
    end
    return peds_spawned
end

all_pets = {}
local function spawn_pet(hash)
    request_model_load(hash)
    local c = ENTITY.GET_ENTITY_COORDS(players.user_ped(), false)
    local pet = entities.create_ped(28, hash, c, 0)
    all_pets[#all_pets + 1] = pet
    ENTITY.SET_ENTITY_INVINCIBLE(pet, true)
    PED.SET_PED_COMPONENT_VARIATION(pet, 0, 0, 2, 0)
    TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(pet, players.user_ped(), 0, -1, 0, 7.0, -1, 1, true)
    PED.SET_PED_COMBAT_ABILITY(pet, 0)
    PED.SET_PED_FLEE_ATTRIBUTES(pet, 0, true)
    PED.SET_PED_COMBAT_ATTRIBUTES(pet, 46, false)
    local blip = HUD.ADD_BLIP_FOR_ENTITY(pet)
    HUD.SET_BLIP_COLOUR(blip, 11)
end

local custom_animal = "a_c_retriever"
menu.text_input(ped_spawn, translations.custom_ped_input, {translations.custom_ped_input_cmd}, translations.custom_ped_input_desc, function(on_input)
    custom_animal = on_input
end, "a_c_retriever")


local animal_hashes = {1302784073, -1011537562, 802685111, util.joaat("a_c_chimp"), -1589092019, 1794449327, -664053099, -1920284487, util.joaat("a_c_retriever"), util.joaat('a_c_cow'), util.joaat("a_c_rabbit_01")}
local animal_options = {translations.lester, translations.rat, translations.fish, translations.chimp, translations.stingray, translations.hen, translations.deer, translations.killer_whale, translations.dog, translations.cow, translations.rabbit, translations.custom}
menu.list_action(ped_spawn, translations.spawn_ped, {translations.spawn_ped_cmd}, "", animal_options, function(index, value, click_type)
    if value == translations.custom then
        spawn_ped(util.joaat(custom_animal))
    else
        spawn_ped(animal_hashes[index])
    end
end)

menu.slider(ped_spawn, translations.spawn_count, {translations.spawn_count_cmd}, translations.spawn_count_desc, 1, 10, 1, 1, function(s)
    num_peds_spawn = s
end)


is_pet = false
menu.toggle(ped_spawn, translations.spawn_as_pet, {translations.spawn_as_pet_cmd}, translations.spawn_as_pet_desc, function(on)
    is_pet = on
end)

spawn_dancing = false
menu.toggle(ped_spawn, translations.spawn_dancing, {translations.spawn_dancing_cmd}, translations.spawn_dancing_desc, function(on)
    spawn_dancing = on
end)

allpeds_gun = 0
local gun_options = {translations.none, translations.pistol, translations.combat_pdw, translations.shotgun, translations.knife, translations.minigun}
menu.list_action(peds_root, translations.give_all_peds_gun, {translations.give_all_peds_gun_cmd}, "", gun_options, function(index, value, click_type)
    if index == 1 then
        allpeds_gun = 0
    else
        allpeds_gun = good_guns[index]
    end
end)

menu.action(peds_root, translations.teleport_all_peds_to_me, {translations.teleport_all_peds_to_me_cmd}, "", function(click_type)
    local c = ENTITY.GET_ENTITY_COORDS(players.user_ped(), false)
    all_peds = entities.get_all_peds_as_handles()
    for k,ped in pairs(all_peds) do
        if not PED.IS_PED_A_PLAYER(ped) then
            if PED.IS_PED_IN_ANY_VEHICLE(ped, true) then
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
                TASK.TASK_LEAVE_ANY_VEHICLE(ped, 0, 16)
            end
            ENTITY.SET_ENTITY_COORDS(ped, c.x, c.y, c.z)
        end
    end
end)

menu.action(peds_root, translations.stack_all_peds, {translations.stack_all_peds_cmd}, "", function(click_type)
    local c = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    all_peds = entities.get_all_peds_as_handles()
    local last_ped = 0
    local last_ped_ht = 0
    notify(translations.please_wait)
    for k,ped in pairs(all_peds) do
        if not PED.IS_PED_A_PLAYER(ped) and not PED.IS_PED_FATALLY_INJURED(ped) then
            request_control_of_entity(ped)
            if PED.IS_PED_IN_ANY_VEHICLE(ped, true) then
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
                TASK.TASK_LEAVE_ANY_VEHICLE(ped, 0, 16)
            end

            ENTITY.DETACH_ENTITY(ped, false, false)
            if last_ped ~= 0 then
                ENTITY.ATTACH_ENTITY_TO_ENTITY(ped, last_ped, 0, 0.0, 0.0, last_ped_ht-0.5, 0.0, 0.0, 0.0, false, false, false, false, 0, false)
            else
                ENTITY.SET_ENTITY_COORDS(ped, c.x, c.y, c.z)
            end
            last_ped = ped
            last_ped_ht = get_model_size(ENTITY.GET_ENTITY_MODEL(ped)).z
        end
    end
end)


rain_peds = false
menu.toggle(peds_root, translations.rain_peds, {translations.rain_peds_cmd}, "...", function(on)
    rain_peds = on
    mod_uses("ped", if on then 1 else -1)
end)

hooker_esp = false
menu.toggle(peds_root, translations.hooker_esp, {translations.hooker_esp_cmd}, "...", function(on)
    hooker_esp = on
    mod_uses("ped", if on then 1 else -1)
end)



local function task_handler(type)
    -- whatever, just get it once this frame
    all_peds = entities.get_all_peds_as_handles()
    player_ped = PLAYER.PLAYER_PED_ID()
    for k,ped in pairs(all_peds) do
        if not PED.IS_PED_A_PLAYER(ped) then
            pluto_switch type do
                case "Flop":
                    TASK.TASK_SKY_DIVE(ped)
                    break
                case "Cover":
                    TASK.TASK_STAY_IN_COVER(ped)
                    break
                case "Writhe":
                    TASK.TASK_WRITHE(ped, player_ped, -1, 0)
                    break
                case "Vault":
                    TASK.TASK_CLIMB(ped, true)
                    break
                case "Cower":
                    TASK.TASK_COWER(ped, -1)
                    break
                case "Clear":
                    TASK.CLEAR_PED_TASKS(ped)
                    break
            end
        end
    end
end

ped_no_ragdoll = false
menu.toggle(ped_attributes_root, translations.no_ragdoll, {translations.no_ragdoll_cmd}, "", function(on)
    ped_no_ragdoll = on 
    mod_uses("ped", if on then 1 else -1)
end)

ped_godmode = false
menu.toggle(ped_attributes_root, translations.godmode_peds, {translations.godmode_peds_cmd}, "", function(on)
    ped_godmode = on 
    mod_uses("ped", if on then 1 else -1)
end)

ped_no_crits = false
menu.toggle(ped_attributes_root, translations.no_crits, {translations.no_crits_cmd}, "", function(on)
    ped_no_crits = on 
    mod_uses("ped", if on then 1 else -1)
end)

ped_highperception = false
menu.toggle(ped_attributes_root, translations.high_perception, {translations.high_perception_cmd}, translations.high_perception_desc, function(on)
    ped_highperception = on 
    mod_uses("ped", if on then 1 else -1)
end)

ped_allcops = false
menu.toggle(ped_attributes_root, translations.make_all_peds_cops, {translations.make_all_peds_cops_cmd}, "", function(on)
    ped_allcops = on 
    mod_uses("ped", if on then 1 else -1)
end)

ped_theflash = false
menu.toggle(ped_attributes_root, translations.looney_tunes, {translations.looney_tunes_cmd}, translations.looney_tunes_cmd, function(on)
    ped_theflash = on 
    mod_uses("ped", if on then 1 else -1)
end)

ped_hardened = false
menu.toggle(ped_attributes_root, translations.hardened, {translations.hardened_cmd}, translations.hardened_desc, function(on)
    ped_hardened = on 
    mod_uses("ped", if on then 1 else -1)
end)



local task_dict = {"flop", "cover", "vault"}
local task_options = {translations.flop, translations.cover, translations.vault, translations.cower, translations.writhe, translations.clear}
menu.list_action(peds_root, translations.task_all, {translations.task_all_cmd}, "", task_options, function(index, value, click_type)
    task_handler(value)
end)

php_bars = false
menu.toggle(peds_root, translations.ped_hp_bars, {translations.ped_hp_bars_cmd}, translations.ped_hp_bars_desc, function(on)
    php_bars = on
    mod_uses("ped", if on then 1 else -1)
    if vhp_bars and on then
        notify(translations.ped_hp_bars_warning)
    end
end)

peds_ignore = false
menu.toggle(ped_b_root, translations.oblivious_peds, {translations.oblivious_peds_cmd}, translations.oblivious_peds_desc, function(on)
    peds_ignore = on
    mod_uses("ped", if on then 1 else -1)
end)

wantthesmoke = false
menu.toggle(ped_b_root, translations.peds_attack_me, {translations.peds_attack_me_cmd}, translations.peds_attack_me_desc, function(on)
    wantthesmoke = on
    mod_uses("ped", if on then 1 else -1)
end)

make_peds_cops = false
menu.toggle(ped_b_root, translations.make_nearby_peds_cops, {translations.make_nearby_peds_cops_cmd}, translations.make_nearby_peds_cops_desc, function(on)
    make_peds_cops = on
    mod_uses("ped", if on then 1 else -1)
end)

menu.toggle(ped_b_root, translations.detroit, {translations.detroit_cmd}, translations.detroit_desc, function(on)
    MISC.SET_RIOT_MODE_ENABLED(on)
end)

apose_peds = false
menu.toggle(ped_b_root, translations.apose_peds, {translations.apose_peds_cmd}, translations.apose_peds_desc, function(on)
    apose_peds = on
    mod_uses("ped", if on then 1 else -1)
end)

roast_voicelines = false
menu.toggle(ped_voice, translations.roast_voicelines, {translations.roast_voicelines_cmd}, translations.roast_voicelines_desc, function(on)
    roast_voicelines = on
    mod_uses("ped", if on then 1 else -1)
end)

sex_voicelines = false
menu.toggle(ped_voice, translations.sex_voicelines, {translations.sex_voicelines_cmd}, translations.sex_voicelines_desc, function(on)
    sex_voicelines = on
    mod_uses("ped", if on then 1 else -1)
end)

screamall = false
menu.toggle(ped_voice, translations.scream, {translations.scream_cmd}, translations.scream_desc, function(on)
    screamall = on
    mod_uses("ped", if on then 1 else -1)
end)

-- VEHICLES

v_phys_root = menu.list(vehicles_root, translations.vehicle_physics, {translations.vehicle_physics_cmd}, translations.vehicle_physics_desc)
vc_root = menu.list(v_phys_root, translations.vehicle_chaos, {translations.vehicle_chaos_root_cmd}, translations.vehicle_chaos_desc)
v_traffic_root = menu.list(vehicles_root, translations.vehicle_traffic, {translations.vehicle_traffic_cmd}, translations.vehicle_traffic_desc)

local function get_closest_vehicle(entity)
    local coords = ENTITY.GET_ENTITY_COORDS(entity, true)
    local vehicles = entities.get_all_vehicles_as_handles()
    -- init this at some ridiculously large number we will never reach, ez
    local closestdist = 1000000
    local closestveh = 0
    for k, veh in pairs(vehicles) do
        if veh ~= PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false) and ENTITY.GET_ENTITY_HEALTH(veh) ~= 0 then
            local vehcoord = ENTITY.GET_ENTITY_COORDS(veh, true)
            local dist = MISC.GET_DISTANCE_BETWEEN_COORDS(coords['x'], coords['y'], coords['z'], vehcoord['x'], vehcoord['y'], vehcoord['z'], true)
            if dist < closestdist then
                closestdist = dist
                closestveh = veh
            end
        end
    end
    return closestveh
end

function get_closest_veh(coords)
    local closest = nil
    local closest_dist = 1000000
    local this_dist = 0
    for _, veh in pairs(entities.get_all_vehicles_as_handles()) do 
        this_dist = v3.distance(coords, ENTITY.GET_ENTITY_COORDS(veh))
        if this_dist < closest_dist  and ENTITY.GET_ENTITY_HEALTH(veh) > 0 then
            closest = veh
            closest_dist = this_dist
        end
    end
    if closest ~= nil then 
        return {closest, closest_dist}
    else
        return nil 
    end
end

function get_closest_ped_new(coords)
    local closest = nil
    local closest_dist = 1000000
    local this_dist = 0
    for _, ped in pairs(entities.get_all_peds_as_handles()) do 
        this_dist = v3.distance(coords, ENTITY.GET_ENTITY_COORDS(ped))
        if this_dist < closest_dist and not PED.IS_PED_A_PLAYER(ped) and not PED.IS_PED_FATALLY_INJURED(ped)  and not PED.IS_PED_IN_ANY_VEHICLE(ped, true) then
            closest = ped
            closest_dist = this_dist
        end
    end
    if closest ~= nil then 
        return {closest, closest_dist}
    else
        return nil 
    end
end

function get_closest_ped_to_ped(init_ped)
    local coords = ENTITY.GET_ENTITY_COORDS(init_ped)
    local closest = nil
    local closest_dist = 1000000
    local this_dist = 0
    for _, ped in pairs(entities.get_all_peds_as_pointers()) do 
        this_dist = v3.distance(coords, entities.get_position(ped))
        if this_dist < closest_dist then 
            local hdl = entities.pointer_to_handle(ped)
            if not PED.IS_PED_A_PLAYER(hdl) and not PED.IS_PED_FATALLY_INJURED(hdl) and not PED.IS_PED_IN_ANY_VEHICLE(hdl, true) and hdl ~= init_ped then
                closest = ped
                closest_dist = this_dist
            end
        end
    end
    if closest ~= nil then 
        return {closest, closest_dist}
    else
        return nil 
    end
end



menu.action(vehicles_root, translations.teleport_into_closest_vehicle, {translations.teleport_into_closest_vehicle_cmd}, translations.teleport_into_closest_vehicle_desc, function(on_click)
    local closestveh = get_closest_vehicle(players.user_ped())
    local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(closestveh, -1)
    if VEHICLE.IS_VEHICLE_SEAT_FREE(closestveh, -1) then
        PED.SET_PED_INTO_VEHICLE(players.user_ped(), closestveh, -1)
    else
        if not PED.IS_PED_A_PLAYER(driver) then
            entities.delete_by_handle(driver)
            PED.SET_PED_INTO_VEHICLE(players.user_ped(), closestveh, -1)
        elseif VEHICLE.ARE_ANY_VEHICLE_SEATS_FREE(closestveh) then
            for i=0, 10 do
                if VEHICLE.IS_VEHICLE_SEAT_FREE(closestveh, i) then
                    PED.SET_PED_INTO_VEHICLE(players.user_ped(), closestveh, i)
                end
            end
        else
            notify(translations.teleport_into_closest_vehicle_error)
        end
    end
end)

vehicle_chaos = false
menu.toggle(vc_root, translations.vehicle_chaos, {translations.vehicle_chaos_cmd}, translations.vehicle_chaos_desc, function(on)
    vehicle_chaos = on
    mod_uses("vehicle", if on then 1 else -1)
end)

vc_gravity = true
menu.toggle(vc_root, translations.vehicle_chaos_gravity, {translations.vehicle_chaos_gravity_cmd}, translations.vehicle_chaos_gravity_desc, function(on)
    vc_gravity = on
end, true)

vc_speed = 100
menu.slider(vc_root, translations.vehicle_chaos_speed, {translations.vehicle_chaos_speed_cmd}, translations.vehicle_chaos_speed_desc, 30, 300, 100, 10, function(s)
  vc_speed = s
end)

vhp_bars = false
menu.toggle(vehicles_root, translations.vehicle_hp_bars, {translations.vehicle_hp_bars_cmd}, translations.vehicle_hp_bars_cmd, function(on)
    vhp_bars = on
    mod_uses("vehicle", if on then 1 else -1)
    if php_bars and on then
        notify(translations.vehicle_hp_bars_warn)
    end
end)

ascend_vehicles = false
menu.toggle(v_phys_root, translations.ascend_all_nearby_vehicles, {translations.ascend_all_nearby_vehicles_cmd}, translations.ascend_all_nearby_vehicles_desc, function(on)
    ascend_vehicles = on
    mod_uses("vehicle", if on then 1 else -1)
end)

rain_vehicles = false
menu.toggle(v_phys_root, translations.rain_vehicles, {translations.rain_vehicles_cmd}, translations.rain_vehicles_desc, function(on)
    rain_vehicles = on
    mod_uses("vehicle", if on then 1 else -1)
end)

inferno = false
menu.toggle(v_phys_root, translations.inferno, {translations.inferno_cmd}, translations.inferno_desc, function(on)
    inferno = on
    mod_uses("vehicle", if on then 1 else -1)
end, false)


function start_vehdance_thread()
    vehdance_thread = util.create_thread(function (thr)
        local state = 2
        while true do
            if not veh_dance then
                util.stop_thread()
            end
            for k,veh in pairs(all_vehicles) do
                local vhash = ENTITY.GET_ENTITY_MODEL(veh)
                VEHICLE.SET_VEHICLE_MOD(veh, 38, VEHICLE.GET_NUM_VEHICLE_MODS(veh, 38)-1, false)
                if player_cur_car ~= veh and not PED.IS_PED_A_PLAYER(VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, -1)) then
                    request_control_of_entity(veh)
                    if vhash % 2 == 0 then
                        if state == 2 then
                            ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0.0, 0.0, 1.0, state*2, 0.0, 0.0, 0, false, false, true, false, true)
                        else
                            ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0.0, 0.0, 1.0, state*2, 0.0, 0.0, 0, false, false, true, false, true)
                        end
                    else
                        if state == 2 then
                            ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0.0, 0.0, 1.0, state*2, 0.0, 0.0, 0, false, false, true, false, true)
                        else
                            ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0.0, 0.0, 1.0, state*2, 0.0, 0.0, 0, false, false, true, false, true)
                        end
                    end
                end
            end
            if state == 2 then
                state = -2
            else
                state = 2
            end
            util.yield(500)
        end
    end)
end

veh_dance = false
menu.toggle(v_phys_root, translations.vehicle_dance, {translations.vehicle_dance_cmd}, translations.vehicle_dance_desc, function(on)
    veh_dance = on
    mod_uses("vehicle", if on then 1 else -1)
    start_vehdance_thread()
end, false)

beep_cars = false
menu.toggle(vehicles_root, translations.infinite_horn_on_all_nearby_vehicles, {translations.infinite_horn_on_all_nearby_vehicles_cmd}, translations.infinite_horn_on_all_nearby_vehicles_desc, function(on)
    beep_cars = on
    mod_uses("vehicle", if on then 1 else -1)
end)

yeetsubmarines = false
menu.toggle(vehicles_root, translations.yeetsubmarines, { translations.yeetsubmarines_cmd},  translations.yeetsubmarines_desc, function(on)
    yeetsubmarines = on
    mod_uses("vehicle", if on then 1 else -1)
end)

menu.action(vehicles_root, translations.teleport_all_vehs_to_me, {translations.teleport_all_vehs_to_me_cmd}, "", function(click_type)
    local c = ENTITY.GET_ENTITY_COORDS(players.user_ped(), false)
    all_vehs = entities.get_all_vehicles_as_handles()
    for k,veh in pairs(all_vehs) do
        if not PED.IS_PED_A_PLAYER(VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, -1, false)) then
            ENTITY.SET_ENTITY_COORDS(veh, c.x, c.y, c.z)
        end
    end
end)


halt_traffic = false
menu.toggle(v_traffic_root, translations.halt_traffic, {translations.halt_traffic_cmd}, translations.halt_traffic_desc, function(on)
    halt_traffic = on
    mod_uses("vehicle", if on then 1 else -1)
end)

reverse_traffic = false
menu.toggle(v_traffic_root, translations.reverse_traffic, {translations.reverse_traffic_cmd}, "", function(on)
    reverse_traffic = on
    mod_uses("vehicle", if on then 1 else -1)
end)

vehicles_thread = util.create_thread(function (thr)
    while true do
        if vehicle_uses > 0 then
            ls_log("Vehicle pool is being updated")
            all_vehicles = entities.get_all_vehicles_as_handles()
            for k,veh in pairs(all_vehicles) do
                if l_e_v_on then
                    local size = get_model_size(ENTITY.GET_ENTITY_MODEL(veh))
                    if size.x > l_e_max_x or size.y > l_e_max_y or size.z > l_e_max_y then
                        entities.delete_by_handle(veh)
                    end
                end

                if vhp_bars and get_distance_between_entities(players.user_ped(), veh) < 200.0 and not ENTITY.IS_ENTITY_DEAD(veh, false) and ENTITY.IS_ENTITY_ON_SCREEN(veh) then
                    local modelHash = ENTITY.GET_ENTITY_MODEL(veh)
                    local min, max = v3.new(), v3.new()
                    MISC.GET_MODEL_DIMENSIONS(modelHash, min, max)
                    local pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(veh, 0.0, 0.0, max.z + 0.3)
                    local perc = 0.0

                    if not ENTITY.IS_ENTITY_DEAD(veh, false) then
                        local maxHealth = ENTITY.GET_ENTITY_MAX_HEALTH(veh)
                        local health = ENTITY.GET_ENTITY_HEALTH(veh)
                        perc = health / maxHealth
                        if perc > 1.0 then perc = 1.0  end
                    end
                    
                    local colour = get_health_colour(perc)
                    local scale = v3.new(0.10, 0.0, interpolate(0.0, 0.7, perc))
                    draw_marker(43, pos, v3(), v3(), scale, false, colour, 0, 0)
                end

                local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, -1)
                -- FOR THINGS THAT SHOULD NOT WORK ON CARS WITH PLAYERS DRIVING THEM
                if player_cur_car ~= veh and (not PED.IS_PED_A_PLAYER(driver)) or driver == 0 then
                    
                    if yeetsubmarines then
                        if VEHICLE.IS_VEHICLE_MODEL(veh, util.joaat("kosatka")) and ENTITY.IS_ENTITY_IN_WATER(veh) then
                            request_control_of_entity_once(veh)
                            ENTITY.SET_ENTITY_MAX_SPEED(veh, 10000)
                            ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1,  0.0, 0.0, 10000, 0, 0, 0, 0, true, false, true, false, true)
                        end 
                    end

                    if inferno then
                        local coords = ENTITY.GET_ENTITY_COORDS(veh, true)
                        FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], 7, 100.0, true, false, 1.0)
                    end

                    if beep_cars then
                        if not AUDIO.IS_HORN_ACTIVE(veh) then
                            VEHICLE.START_VEHICLE_HORN(veh, 200, util.joaat("HELDDOWN"), true)
                        end
                    end

                    if vehicle_chaos then
                        VEHICLE.SET_VEHICLE_OUT_OF_CONTROL(veh, false, true)
                        VEHICLE.SET_VEHICLE_FORWARD_SPEED(veh, vc_speed)
                        VEHICLE.SET_VEHICLE_GRAVITY(veh, vc_gravity)
                    end
                
                    if halt_traffic then
                        VEHICLE.BRING_VEHICLE_TO_HALT(veh, 0.0, -1, true)
                        coords = ENTITY.GET_ENTITY_COORDS(veh, false)
                    end

                    if ascend_vehicles then
                        VEHICLE.SET_VEHICLE_UNDRIVEABLE(veh, true)
                        VEHICLE.SET_VEHICLE_GRAVITY(veh, false)
                        ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(veh, 4, 5.0, 0.0, 0.0, true, true, true, true)
                    end

                    if rain_vehicles then 
                        if not ENTITY.IS_ENTITY_IN_AIR(veh) then 
                            local ped_c = ENTITY.GET_ENTITY_COORDS(players.user_ped())
                            ped_c.x = ped_c.x + math.random(-50, 50)
                            ped_c.y = ped_c.y + math.random(-50, 50)
                            ped_c.z = ped_c.z + math.random(100, 120)
                            ENTITY.SET_ENTITY_COORDS(veh, ped_c.x, ped_c.y, ped_c.z)
                        end
                    end

                    if reverse_traffic then
                        ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, -1)
                        TASK.TASK_VEHICLE_TEMP_ACTION(ped, veh, 3, -1)
                    end
                end
            end
        end
        util.yield()
    end
end)


-- PICKUPS

pickups_thread = util.create_thread(function(thr)
    while true do
        if pickup_uses > 0 then
            ls_log("Pickups pool is being updated")
            all_pickups = entities.get_all_pickups_as_handles()
            for k,p in pairs(all_pickups) do
                if tp_all_pickups then
                    local pos = ENTITY.GET_ENTITY_COORDS(tp_pickup_tar, true)
                    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(p, pos['x'], pos['y'], pos['z'], true, false, false)
                end
            end
        end
        util.yield()
    end
end)

tp_all_pickups = false
tp_pickup_tar = players.user_ped()
menu.toggle(pickups_root, translations.teleport_all_pickups, {translations.teleport_all_pickups_cmd}, translations.teleport_all_pickups_desc, function(on)
    tp_all_pickups = on
    mod_uses("pickup", if on then 1 else -1)
end)

-- WORLD
fireworks_root = menu.list(world_root, translations.fireworks, {}, "")
protected_areas_root = menu.list(world_root, translations.protected_areas, {translations.protected_areas_cmd}, translations.protected_areas_desc)
projectiles_root = menu.list(world_root, translations.projectiles, {translations.projectiles_cmd}, "")
entity_limits_root = menu.list(protections_root, translations.entity_limits, {translations.entity_limits_cmd}, translations.entity_limits_desc)
active_protected_areas_root = menu.list(protected_areas_root, translations.active_areas, {translations.active_areas_cmd},  translations.active_areas_desc)

local placed_firework_boxes = {}

menu.action(fireworks_root, translations.place_firework_box, {translations.place_firework_box_cmd}, translations.place_firework_box_desc, function(click_type)
    local animlib = 'anim@mp_fireworks'
    local ptfx_asset = "scr_indep_fireworks"
    local anim_name = 'place_firework_3_box'
    local effect_name = "scr_indep_firework_trailburst"
    request_anim_dict(animlib)
    local pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 0.0, 0.52, 0.0)
    local ped = players.user_ped()
    ENTITY.FREEZE_ENTITY_POSITION(ped, true)
    TASK.TASK_PLAY_ANIM(ped, animlib, anim_name, -1, -8.0, 3000, 0, 0, false, false, false)
    util.yield(1500)
    local firework_box = entities.create_object(util.joaat('ind_prop_firework_03'), pos, true, false, false)
    local firework_box_pos = ENTITY.GET_ENTITY_COORDS(firework_box)
    OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(firework_box)
    ENTITY.FREEZE_ENTITY_POSITION(ped, false)
    util.yield(1000)
    ENTITY.FREEZE_ENTITY_POSITION(firework_box, true)
    placed_firework_boxes[#placed_firework_boxes + 1] = firework_box
end)

menu.action(fireworks_root, translations.set_off_fireworks, {translations.set_off_fireworks_cmd}, translations.set_off_fireworks_desc, function(click_type)
    if #placed_firework_boxes == 0 then 
        notify("Place some fireworks first!")
        return 
    end
    local ptfx_asset = "scr_indep_fireworks"
    local effect_name = "scr_indep_firework_trailburst"
    request_ptfx_asset(ptfx_asset)
    notify(translations.kaboom)
    for i=1, 50 do
        for k,box in pairs(placed_firework_boxes) do 
            GRAPHICS.USE_PARTICLE_FX_ASSET(ptfx_asset)
            GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_ON_ENTITY(effect_name, box, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 0.0, 0.0, 0.0)
            util.yield(100)
        end
    end
    for k,box in pairs(placed_firework_boxes) do 
        entities.delete_by_handle(box)
        placed_firework_boxes[box] = nil
    end
end)

projectile_warn = false
menu.toggle(projectiles_root, translations.draw_warning, {translations.draw_warning_cmd}, translations.draw_warning_desc, function(on)
    projectile_warn = on
    mod_uses("object", if on then 1 else -1)
end)

projectile_cleanse = false
menu.toggle(projectiles_root, translations.delete_projectiles, {translations.delete_projectiles_cmd}, translations.delete_projectiles_desc, function(on)
    projectile_cleanse = on
    mod_uses("object", if on then 1 else -1)
end)

projectile_spaz = false
menu.toggle(projectiles_root, translations.projectile_spaz, {translations.projectile_spaz_cmd}, translations.projectile_spaz_desc, function(on)
    projectile_spaz = on
    mod_uses("object", if on then 1 else -1)
end)

slow_projectiles = false
menu.toggle(projectiles_root, translations.extremely_slow_projectiles, {translations.extremely_slow_projectiles_cmd}, "", function(on)
    slow_projectiles = on
    mod_uses("object", if on then 1 else -1)
end)

blip_projectiles = false
menu.toggle(projectiles_root, translations.blips_for_projectiles, {translations.blips_for_projectiles_cmd  }, "", function(on)
    blip_projectiles = on
    mod_uses("object", if on then 1 else -1)
end)

local function get_closest_projectile()
    local closest = 100000000000
    local closest_obj = 0
    for k,obj in pairs(entities.get_all_objects_as_handles()) do 
        if is_entity_a_projectile(ENTITY.GET_ENTITY_MODEL(obj)) then
            local c = ENTITY.GET_ENTITY_COORDS(obj) 
            local c2 = ENTITY.GET_ENTITY_COORDS(players.user_ped())
            local d = MISC.GET_DISTANCE_BETWEEN_COORDS(c.x, c.y, c.z, c2.x, c2.y, c2.z, true)
            if d < closest then
                closest_obj = obj
                closest = d
            end 
        end
    end
    return closest_obj
end

function get_closest_ped(coords)
    local closest = nil
    local closest_dist = 1000000
    local this_dist = 0
    for _, ped in pairs(entities.get_all_peds_as_handles()) do 
        this_dist = v3.distance(coords, ENTITY.GET_ENTITY_COORDS(ped))
        if this_dist < closest_dist and not PED.IS_PED_A_PLAYER(ped) and ENTITY.GET_ENTITY_HEALTH(ped) > 0 then
            closest = ped
            closest_dist = this_dist
        end
    end
    if closest ~= nil then 
        return closest
    else
        return nil 
    end
end

menu.action(projectiles_root, translations.ride_closest_projectile, {translations.ride_closest_projectile_cmd}, ".", function(on)
    closest_obj = get_closest_projectile()
    if closest_obj ~= 0 then 
        notify(translations.ride_closest_projectile_warn)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(players.user_ped(), closest_obj, 0, 0.0, -0.20, 2.00, 1.0, 1.0,1, true, true, true, false, 0, true)
    end
end)


l_e_v_on = false
l_e_o_on = false
menu.toggle(entity_limits_root, translations.delete_large_vehicles, {translations.delete_large_vehicles_cmd}, "", function(on)
    mod_uses("vehicle", if on then 1 else -1)
    l_e_v_on = true
end)

menu.toggle(entity_limits_root, translations.delete_large_objects, {translations.delete_large_objects_cmd}, "", function(on)
    mod_uses("object", if on then 1 else -1)
    l_e_o_on = true
end)

l_e_max_x = 50
l_e_max_y = 50
l_e_max_z = 50
menu.slider(entity_limits_root, translations.max_x_size, {translations.max_x_size_cmd}, translations.max_x_size_desc, 1, 10000, 50, 1, function(s)
    l_e_max_x = s
end)

menu.slider(entity_limits_root, translations.max_y_size, {translations.max_y_size_cmd}, translations.max_y_size_desc, 1, 10000, 50, 1, function(s)
    l_e_max_y = s
end)

menu.slider(entity_limits_root, translations.max_z_size, {translations.max_z_size_cmd}, translations.max_z_size_desc, 1, 10000, 50, 1, function(s)
    l_e_max_z = s
end)



protected_area_radius = 100
protected_areas = {}
protected_area_allow_friends = true
protected_areas_on = false

menu.toggle(protected_areas_root, translations.enforce_areas, {translations.enforce_areas_cmd}, translations.enforce_areas_desc, function(on)
    mod_uses("player", if on then 1 else -1)
    protected_areas_on = on
end)


menu.slider(protected_areas_root, translations.area_radius, {translations.area_radius_cmd}, translations.area_radius_desc, 10, 1000, 100, 10, function(s)
    protected_area_radius = s
end)

menu.toggle(protected_areas_root, translations.always_allow_friends, {translations.always_allow_friends_cmd}, translations.always_allow_friends_desc, function(on)
    protected_area_allow_friends = on
end, true)


menu.toggle(protected_areas_root, translations.kill_only_armed_players, {translations.kill_only_armed_players_cmd}, translations.kill_only_armed_players_desc, function(on)
    protected_area_kill_armed = on
end)


-- -1569615261

menu.action(protected_areas_root, translations.define_protected_area, {translations.define_protected_area_cmd}, translations.define_protected_area_desc, function(click_type)
    local c = ENTITY.GET_ENTITY_COORDS(players.user_ped(), false)
    blip = HUD.ADD_BLIP_FOR_RADIUS(c.x, c.y, c.z, protected_area_radius)
    HUD.SET_BLIP_COLOUR(blip, 61)
    HUD.SET_BLIP_ALPHA(blip, 128)
    local this_area = {}
    this_area.blip = blip
    this_area.x = c.x
    this_area.y = c.y
    this_area.z = c.z
    this_area.radius = protected_area_radius
    pa_next = #protected_areas + 1
    protected_areas[pa_next] = this_area
    local new_protected_area = menu.list(active_protected_areas_root, tostring(pa_next), {translations.protectedarea_cmd .. pa_next}, translations.protectedarea_desc)
    menu.action(new_protected_area, translations.delete, {translations.delete_pa_cmd .. tostring(pa_next)}, translations.delete_pa_desc, function(click_type)
        util.remove_blip(blip)
        protected_areas[pa_next] = nil
        menu.delete(new_protected_area)
        notify(translations.pa_deleted)
    end)
end)


supercleanse = menu.action(world_root, translations.super_cleanse, {translations.super_cleanse_cmd}, translations.super_cleanse_desc, function(click_type)
    menu.show_warning(supercleanse, click_type, translations.super_cleanse_warn, function()
        local ct = 0
        for k,ent in pairs(entities.get_all_vehicles_as_handles()) do
            local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(ent, -1)
            if not PED.IS_PED_A_PLAYER(driver) then
                entities.delete_by_handle(ent)
                ct += 1
            end
        end
        for k,ent in pairs(entities.get_all_peds_as_handles()) do
            if not PED.IS_PED_A_PLAYER(ent) then
                entities.delete_by_handle(ent)
            end
            ct += 1
        end
        for k,ent in pairs(entities.get_all_objects_as_handles()) do
            entities.delete_by_handle(ent)
            ct += 1
        end
        local rope_alloc = memory.alloc(4)
        for i=0, 100 do 
            memory.write_int(rope_alloc, i)
            if PHYSICS.DOES_ROPE_EXIST(rope_alloc) then   
                PHYSICS.DELETE_ROPE(rope_alloc)
                ct += 1
            end
        end

        notify(translations.super_cleanse_complete .. ct .. translations.entities_removed)
    end, function()
        notify("Aborted.")
    end, true)
end)

island_block = 0
menu.action(world_root, translations.sky_island, {translations.sky_island_cmd}, translations.sky_island_desc, function(click_type)
    local c = {}
    c.x = 0
    c.y = 0
    c.z = 500
    PED.SET_PED_COORDS_KEEP_VEHICLE(players.user_ped(), c.x, c.y, c.z+5)
    if island_block == 0 or not ENTITY.DOES_ENTITY_EXIST(island_block) then
        request_model_load(1054678467)
        island_block = entities.create_object(1054678467, c)
    end
end)

local angry_planes = false
local angry_planes_tar = 0
local function start_angryplanes_thread()
    util.create_thread(function()
        local v_hashes = {util.joaat('lazer'), util.joaat('jet'), util.joaat('cargoplane'), util.joaat('titan'), util.joaat('luxor'), util.joaat('seabreeze'), util.joaat('vestra'), util.joaat('volatol'), util.joaat('tula'), util.joaat('buzzard'), util.joaat('avenger')}
        if angry_planes_tar == 0 then 
            angry_planes_tar = players.user_ped()
        end
        while true do
            if not angry_planes then 
                util.stop_thread()
            end
            local p_hash = util.joaat('s_m_m_pilot_01')
            local radius = 200
            local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(angry_planes_tar, math.random(-radius, radius), math.random(-radius, radius), math.random(600, 800))
            local pick = v_hashes[math.random(1, #v_hashes)]
            request_model_load(pick)
            local aircraft = entities.create_vehicle(pick, c, math.random(0, 270))
            set_entity_face_entity(aircraft, angry_planes_tar, true)
            VEHICLE.SET_VEHICLE_ENGINE_ON(aircraft, true, true, false)
            VEHICLE.SET_HELI_BLADES_FULL_SPEED(aircraft)
            VEHICLE.SET_VEHICLE_FORWARD_SPEED(aircraft, VEHICLE.GET_VEHICLE_ESTIMATED_MAX_SPEED(aircraft)+1000.0)
            VEHICLE.SET_VEHICLE_OUT_OF_CONTROL(aircraft, true, true)
            --local blip = HUD.ADD_BLIP_FOR_ENTITY(aircraft)
            --HUD.SET_BLIP_SPRITE(blip, 90)
            --HUD.SET_BLIP_COLOUR(blip, 75)
            util.yield(5000)
        end
    end)
end

menu.toggle(world_root, translations.angry_planes, {translations.angry_planes_cmd}, translations.angry_planes_desc, function(on)
    angry_planes = on
    start_angryplanes_thread()
end)


world_root:action(translations.no_russian, {"norussian"}, translations.no_russian_desc, function()
    notify(translations.remember_no_russian)
    local terror_model = util.joaat("s_m_y_xmech_02")
    request_model_load(terror_model)
    local terrorist = entities.create_ped(28, terror_model, ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 0, 1.0, 0.0), math.random(270))
    WEAPON.GIVE_WEAPON_TO_PED(terrorist, 171789620, 1000, false, true)
    PED.SET_PED_COMBAT_ABILITY(terrorist, 2)
    PED.SET_PED_AS_ENEMY(terrorist, true)
    PED.SET_PED_COMBAT_ATTRIBUTES(terrorist,13, true)
    while true do
        if PED.IS_PED_FATALLY_INJURED(terrorist) or not ENTITY.DOES_ENTITY_EXIST(terrorist) then 
            break 
        end
        local nearest = get_closest_ped_to_ped(ENTITY.GET_ENTITY_COORDS(terrorist), terrorist)
        TASK.CLEAR_PED_TASKS_IMMEDIATELY(terrorist)
        TASK.TASK_COMBAT_PED(terrorist, nearest[1])
        util.yield(5000)
    end
end)

local road_positions = {
    ["Senora Way"] = {2540.113, 2043.408, 19.93171},
    ["Smoke Tree Road"] = {2112.434, 3269.233, 46.07644},
    ["Cholla Road"] = {1896.314, 3314.985, 43.91346},
    ["Nowhere Road"] = {2058.327, 3370.172, 45.43926},
    ["East Joshua Road"] = {2379.925, 3917.448, 35.79856},
    ["Alhambra Drive"] = {1867.975, 3671.698, 33.81569},
    ["Zancudo Avenue"] = {1889.574, 3746.893, 32.64684},
    ["Niland Avenue"] = {1902.028, 3813.777, 32.3943},
    ["Armadillo Avenue"] = {1796.321, 3828.555, 33.91169},
    ["Mountain View Drive"] = {1725.44, 3784.713, 34.58356},
    ["Cholla Springs Avenue"] = {1745.002, 3838.304, 34.76292},
    ["Algonquin Boulevard"] = {1712.472, 3731.615, 33.80273},
    ["Lesbos Lane"] = {1456.402, 3654.542, 34.52805},
    ["Meringue Lane"] = {1321.724, 3608.68, 34.04192},
    ["Marina Drive"] = {1615.967, 3811.208, 34.94038},
    ["Panorama Drive"] = {1845.958, 3258.605, 44.38151},
    ["Chianski Passage"] = {3066.397, 3804.903, 74.74319},
    ["Fenwell Place"] = {785.7005, 337.5547, 115.477},
    ["Prosperity Street Promonade"] = {-1271.954, -720.0355, 22.74146},
    ["Route 68"] = {-632.7896, 2860.019, 32.97987},
    ["Route 68 Approach"] = {112.549, 2878.757, 50.6503},
    ["Joshua Road"] = {254.9967, 3366.561, 38.83519},
    ["Calafia Road"] = {-207.2778, 4193.525, 44.1331},
    ["North Calafia Way"] = {815.2441, 4500.166, 52.78945},
    ["Seaview Road"] = {2341.714, 4704.802, 36.06202},
    ["Grapeseed Main Street"] = {1667.956, 4942.11, 42.11841},
    ["Joad Lane"] = {2117.457, 4973.189, 40.90351},
    ["Union Road"] = {2707.073, 5120.851, 44.53936},
    ["Grapeseed Avenue"] = {2605.267, 4752.373, 33.6501},
    ["O'Neil Way"] = {2291.03, 5036.305, 44.0284},
    ["Cassidy Trail"] = {-1093.845, 4277.784, 94.7785},
    ["Cassidy Trail"] = {-1037.191, 4364.991, 11.7951},
    ["Procopio Promenade"] = {-319.4478, 6436.197, 12.75844},
    ["Procopio Drive"] = {-259.2053, 6388, 30.91096},
    ["Paleto Boulevard"] = {-139.3633, 6389.122, 31.44454},
    ["Cascabel Avenue"] = {-145.3767, 6454.79, 31.51637},
    ["Pyrite Avenue"] = {-136.3384, 6323.319, 31.59908},
    ["Duluoz Avenue"] = {-285.2407, 6213.633, 31.51427},
    ["Catfish View"] = {3311.245, 4982.273, 25.73639},
    ["Barbareno Road"] = {-3199.829, 1136.063, 9.867818},
    ["Ineseno Road"] = {-3039.198, 465.9389, 6.512059},
    ["North Archer Avenue"] = {-113.9569, 161.552, 83.82638},
    ["Laguna Place"] = {18.26195, -64.40515, 62.69677},
    ["Alta Place"] = {175.7772, -120.6618, 61.91667},
    ["Bay City Incline"] = {-1898.312, -459.4898, 22.95209},
    ["Playa Vista"] = {-1863.936, -401.1625, 46.78623},
    ["Liberty Street"] = {-1607.524, -477.4979, 37.34735},
    ["Cougar Avenue"] = {-1578.763, -362.6219, 46.09238},
    ["Cougar Avenue"] = {-1578.763, -362.6219, 46.09238},
    ["Prosperity Street"] = {-1539.469, -366.5553, 44.60126},
    ["Morningwood Boulevard"] = {-1366.898, -241.4278, 43.22184},
    ["West Eclipse Boulevard"] = {-1431.348, -76.93867, 52.55178},
    ["Sam Austin Drive"] = {-1493.638, -6.046651, 55.94263},
    ["Bay City Avenue"] = {-1278.651, -964.417, 10.83138},
    ["Boulevard Del Perro"] = {-954.6898, -153.3152, 37.83179},
    ["North Rockford Drive"] = {-1731.503, 37.24574, 67.23094},
    ["Perth Street"] = {-1396.479, -285.9395, 43.49928},
    ["Americano Way"] = {-1572.731, 47.87829, 59.09039},
    ["Dorest Drive"] = {-750.4197, -335.1743, 36.38994},
    ["Movie Star Way"] = {-949.4902, -455.9005, 37.61167},
    ["South Boulevard Del Perro"] = {-815.074, -135.9457, 37.89245},
    ["Marathon Avenue"] = {-1200.161, -421.6607, 33.90942},
    ["Red Desert Avenue"] = {-1339.655, -611.8193, 28.12997},
    ["Red Desert Avenue"] = {-1364.899, -696.4847, 24.93312},
    ["Heritage Way"] = {-1089.129, -497.0849, 36.26047},
    ["Heritage Way"] = {-856.7599, -381.7614, 39.59584},
    ["Mad Wayne Thunder Drive"] = {-1078.054, 205.8565, 61.54077},
    ["Portola Drive"] = {-805.4047, -35.63118, 37.89666},
    ["Palomino Avenue"] = {-637.5414, -751.3831, 26.54266},
    ["Ginger Street"] = {-746.1293, -749.3184, 26.94559},
    ["La Puerta Fwy"] = {-546.4094, -581.1066, 25.30834},
    ["Lindsay Circus"] = {-675.2275, -955.3881, 21.02638},
    ["South Rockford Drive"] = {-871.668, -1040.272, 6.17344},
    ["Prosperity Street"] = {-1069.551, -1009.144, 2.191113},
    ["Imagination Ct"] = {-1018.435, -1002.953, 2.121316},
    ["Vespucci Boulevard"] = {-239.6687, -868.2635, 30.57965},
    ["Decker Street"] = {-856.5641, -775.0763, 20.7915},
    ["South Rockford Drive"] = {-840.6085, -988.9078, 14.35504},
    ["Tackle Street"] = {-740.5059, -1279.543, 6.240307},
    ["Rub Street"] = {-977.6376, -1541.516, 5.024433},
    ["Tug Street"] = {-1044.23, -1460.224, 5.289677},
    ["Melanoma Street"] = {-1124.638, -1570.451, 4.430606},
    ["Goma Street"] = {-1116.347, -1469.79, 4.899348},
    ["Aguja Street"] = {-1157.554, -1407.694, 4.914198},
    ["Magellan Avenue"] = {-1302.174, -1141.853, 5.905826},
    ["Vitus Street"] = {-1295.478, -1282.28, 4.271019},
    ["Cortes Street"] = {-1326.554, -1202.658, 4.895187},
    ["Conquistador Street"] = {-1324.543, -1098.854, 6.9851},
    ["Sandcastle Way"] = {-1382.996, -886.2345, 13.5324},
    ["San Andreas Avenue"] = {-224.8015, -674.1303, 33.51766},
    ["Peaceful Street"] = {-252.7688, -761.6367, 32.83224},
    ["Alta Street"] = {-155.2908, -793.7457, 31.99826},
    ["Calais Avenue"] = {-538.4774, -1042.583, 22.71222},
    ["South Arsenal Street"] = {-549.8902, -1747.289, 21.87806},
    ["Mutiny Road"] = {-617.5049, -1798.87, 23.47999},
    ["Davis Avenue"] = {131.9345, -1622.304, 29.34991},
    ["Rugby Road"] = {-188.8144, -2186.01, 10.28954},
    ["Grove Street"] = {14.71448, -1867.145, 23.53232},
    ["Grove Street"] = {14.71448, -1867.145, 23.53232},
    ["Forum Drive"] = {-152.5461, -1567.123, 34.823},
    ["Strawberry Avenue"] = {223.5298, -1272.831, 29.3381},
    ["Carson Avenue"] = {107.3734, -1716.376, 35.49697},
    ["Covenant Avenue"] = {157.6729, -1880.989, 23.66188},
    ["Brouge Avenue"] = {144.0376, -1799.032, 28.36626},
    ["Macdonald Street"] = {318.0585, -1705.565, 29.38059},
    ["Roy Lowenstein Boulevard"] = {369.7681, -1750.188, 29.21732},
    ["Jamestown Street"] = {426.1558, -1868.104, 27.10556},
    ["Little Bighorn Avenue"] = {506.0519, -1299.049, 29.29316},
    ["Innocence Boulevard"] = {392.42, -1573.847, 29.34147},
    ["Crusade Road"] = {383.6858, -1277.257, 32.56993},
    ["Capital Boulevard"] = {751.3375, -1435.82, 29.28982},
    ["Popular Street"] = {797.6797, -1378.398, 26.85658},
    ["El Rancho Boulevard"] = {1283.547, -1514.749, 42.39206},
    ["Fudge Lane"] = {1365.33, -1539.445, 55.46336},
    ["Dry Dock Street"] = {844.3335, -2241.535, 30.29223},
    ["Orchardville Avenue"] = {923.2609, -2139.218, 30.3522},
    ["Hanger Way"] = {949.372, -2460.246, 28.4929},
    ["South Shambles Street"] = {1048.916, -2282.543, 30.49422},
    ["Labor Place"] = {1272.617, -1801.555, 42.85985},
    ["Amarillo Way"] = {1163.309, -1782.797, 36.6189},
    ["Tower Way"] = {1089.582, -1809.177, 36.64927},
    ["Amarillo Vista"] = {1290.413, -1728.126, 53.43291},
    ["Signal Street"] = {356.3286, -2319.906, 10.20159},
    ["Chum Street"] = {402.1497, -2498.694, 12.26817},
    ["Buccaneer Way"] = {715.7565, -3090.982, 15.48685},
    ["Abattoir Avenue"] = {671.4993, -2857.395, 6.182594},
    ["Signal Street"] = {234.2645, -2878.247, 5.961342},
    ["Voodoo Place"] = {251.6212, -3093.702, 5.633519},
    ["Voodoo Place"] = {194.2674, -3321.539, 5.676107},
    ["Plaice Place"] = {-80.88645, -2623.969, 6.000722},
    ["Chupacabra Street"] = {-195.2381, -2398.403, 6.001232},
    ["Northern Perimeter Road"] = {-1026.568, -2712.759, 13.81799},
    ["Exceptionalists Way"] = {-660.9663, -2323.564, 9.575602},
    ["Greenwich Parkway"] = {-1035.71, -1887.257, 13.9937},
    ["Shank Street"] = {-688.582, -1365.239, 7.138965},
    ["Power Street"] = {-76.77986, -1059.736, 27.52848},
    ["Adam's Apple Boulevard"] = {6.029763, -1131.665, 28.48591},
    ["Power Street"] = {208.5383, -278.7821, 49.0726},
    ["Integrity Way"] = {28.38691, -554.1407, 35.71538},
    ["Swiss Street"] = {175.1294, -598.4085, 43.44275},
    ["Sinner Street"] = {407.4944, -907.1732, 29.39644},
    ["Atlee Street"] = {352.3647, -952.4221, 29.45645},
    ["Fantastic Place"] = {306.8008, -1097.03, 29.37649},
    ["Sinners Passage"] = {454.9003, -822.6345, 27.70428},
    ["Elgin Avenue"] = {208.3137, -731.5825, 47.07695},
    ["Occupation Avenue"] = {125.5314, -314.5538, 45.52667},
    ["Las Lagunas Boulevard"] = {-94.76276, -181.6375, 49.24092},
    ["Hawick Avenue"] = {-39.7421, -119.5752, 57.5595},
    ["Carcer Way"] = {-511.2774, -273.7573, 35.58677},
    ["Abe Milton Parkway"] = {-397.3161, -247.3584, 36.15861},
    ["Dorset Place"] = {-424.8518, -333.8156, 33.10892},
    ["Rockford Drive"] = {-659.8407, -120.0154, 37.74697},
    ["Eastbourne Way"] = {-557.5651, -152.0245, 38.19177},
    ["San Vitus Boulevard"] = {-262.3713, -122.8285, 45.33224},
    ["Milton Road"] = {-547.1608, 100.9839, 62.11102},
    ["Spanish Avenue"] = {-170.2208, 103.9186, 70.35052},
    ["Strangeways Drive"] = {-648.9921, 166.4457, 60.69028},
    ["Caesars Place"] = {-809.2862, 25.26444, 45.81357},
    ["Edwood Way"] = {-807.1418, 137.6377, 59.18475},
    ["Steele Way"] = {-994.1068, 178.8532, 64.61726},
    ["Eclipse Boulevard"] = {-254.744, 265.5331, 91.57346},
    ["Vinewood Boulevard"] = {403.985, 120.1216, 101.7304},
    ["Clinton Avenue"] = {464.4139, 280.5941, 103.0869},
    ["Meteor Street"] = {473.7002, -4.109273, 85.01125},
    ["Park Road"] = {1192.368, -430.1998, 67.27187},
    ["Bridge Street"] = {927.1231, -268.7151, 67.69228},
    ["Glory Way"] = {932.2373, -318.606, 66.71573},
    ["Nikola Avenue"] = {1119.668, -504.5036, 63.95295},
    ["Nikola Place"] = {1334.427, -559.0633, 73.31116},
    ["Utopia Gardens"] = {1349.337, -730.6032, 67.08733},
    ["Mirror Place"] = {1017.886, -606.3557, 58.72468},
    ["West Mirror Drive"] = {946.0634, -616.5578, 57.45175},
    ["East Mirror Drive"] = {1265.918, -587.0645, 69.04719},
    ["Supply Street"] = {972.4315, -927.1509, 42.66642},
    ["Tangerine Street"] = {918.0992, -200.2104, 72.52152},
    ["York Street"] = {844.2861, -146.6381, 77.36826},
    ["Vinewood Park Drive"] = {1023.222, 222.8708, 81.46889},
    ["Sustancia Road"] = {1991.741, -904.963, 79.15412},
    ["El Burro Boulevard"] = {1731.061, -1836.853, 113.7419},
    ["Kortz Drive"] = {-2089.572, 238.6954, 124.0818},
    ["Picture Perfect Drive"] = {-1208.871, 404.0915, 74.78239},
    ["Hardy Way"] = {-1419.521, 230.2396, 59.50925},
    ["Greenwich Place"] = {-1166.88, 337.4059, 70.00904},
    ["Greenwich Way"] = {-1034.008, 338.4621, 68.56916},
    ["Dunstable Drive"] = {-933.6364, 339.7685, 71.65672},
    ["South Mo Milton Drive"] = {-879.6082, 539.5421, 92.10883},
    ["Cockingend Drive"] = {-980.5728, 499.6391, 79.76115},
    ["Hangman Avenue"] = {-1354.317, 568.8069, 130.6367},
    ["Hillcrest Ridge Access Road"] = {-900.9083, 657.4213, 134.6986},
    ["Hillcrest Avenue"] = {-835.5498, 709.4013, 148.1292},
    ["North Sheldon Avenue"] = {-977.795, 802.0435, 174.5455},
    ["Normandy Drive"] = {-576.9842, 761.0158, 184.9549},
    ["Richman Street"] = {-1700.576, 272.7532, 62.52606},
    ["Ace Jones Drive"] = {-1670.971, 516.3104, 129.5358},
    ["Didion Drive"] = {-229.3805, 414.3745, 109.3517},
    ["Cox Way"] = {-373.8369, 421.6751, 110.0309},
    ["Wild Oats Drive"] = {-25.50357, 485.4274, 145.2824},
    ["Whispymound Drive"] = {124.2504, 574.7909, 183.2273},
    ["Kimble Hill Drive"] = {-282.176, 615.8823, 179.9514},
    ["Lake Vinewood Drive"] = {53.80474, 634.9471, 207.3656},
    ["Marlowe Drive"] = {-615.1347, 991.1943, 240.4642},
    ["Mt Haan Drive"] = {416.105, 1151.648, 240.3864},
    ["Zancudo Barranca"] = {-999.1759, 2144.856, 102.5672},
    ["Zancudo Grande Valley"] = {-757.3782, 2160.389, 101.686},
    ["Galileo Road"] = {-521.7784, -224.8015, 205.9611},
    ["West Galileo Avenue"] = {-593.9232, 1344.117, 296.8351},
    ["East Galileo Avenue"] = {36.67382, 1440.78, 268.8528},
    ["Baytree Canyon Road"] = {143.2536, 1570.829, 230.4684},
    ["Banham Canyon Drive"] = {-2482.01, 1043.446, 190.3146},
    ["Tongva Drive"] = {-1475.132, 1531.953, 113.6898},
    ["Zancudo Road"] = {-1543.59, 2276.601, 53.11116},
    ["Tongva Drive"] = {-1354.978, 2302.781, 41.29747},
    ["Buen Vino Road"] = {-2169.871, 1959.165, 190.6049},
    ["Fort Zancudo Approach Road"] = {-1379.586, 2602.342, 17.64345},
    ["North Conker Avenue"] = {463.4891, 407.7919, 139.4209},
    ["Mt Haan Road"] = {1184.931, 1341.625, 147.9953}
}

world_root:action(translations.teleport_to_road, {"tptoroad"}, translations.teleport_to_road_desc, function()
    menu.show_command_box("tptoroad" .. " ")
end, function(input)
    for name, pos in pairs(road_positions) do
        if string.contains(string.lower(name), string.lower(input)) then
            notify(translations.teleported_to .. name .. "!")
            PED.SET_PED_COORDS_KEEP_VEHICLE(players.user_ped(), pos[1], pos[2], pos[3])
            return
        end
    end
    notify(translations.road_not_found)
end)

local street_name_ptr = memory.alloc_int()
local inter_street_name_ptr = memory.alloc_int()
world_root:toggle_loop(translations.show_road_name, {"showroadname"}, "", function()
    local c = players.get_position(players.user())
    PATHFIND.GET_STREET_NAME_AT_COORD(c.x, c.y, c.z, street_name_ptr, inter_street_name_ptr)
    local street_name = memory.read_int(street_name_ptr)
    local inter_street_name = memory.read_int(inter_street_name_ptr)
    if street_name == 0 then 
        return 
    end
    street_name = util.get_label_text(street_name)
    if inter_street_name == 0 then
        util.draw_debug_text(translations.road .. street_name)
    else
        inter_street_name = util.get_label_text(inter_street_name)
        util.draw_debug_text(translations.road .. street_name .. translations._and .. inter_street_name)
    end
end)

world_root:action(translations.spawn_dominoes, {"spawndominoes"}, "", function()
    local hash = util.joaat("prop_boogieboard_01")
    request_model_load(hash)
    local last_ent = players.user_ped()
    for i=2, 25 do 
        local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(last_ent, 0, -i, 0)
        local d = entities.create_object(hash, c)
        ENTITY.SET_ENTITY_HEADING(d, ENTITY.GET_ENTITY_HEADING(last_ent))
        OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(d)
    end
end)

local active_bowling_balls = 0
function bomb_shower_tick_handler(ent)
    local start_time = os.clock()
    active_bowling_balls += 1
    util.create_tick_handler(function()
        if ENTITY.HAS_ENTITY_COLLIDED_WITH_ANYTHING(ent) or os.clock() - start_time > 10 or not ENTITY.DOES_ENTITY_EXIST(ent) then
            if ENTITY.DOES_ENTITY_EXIST(ent) then 
                local c = ENTITY.GET_ENTITY_COORDS(ent)
                FIRE.ADD_EXPLOSION(c.x, c.y, c.z, 17, 100.0, true, false, 0.0)
                entities.delete_by_handle(ent)
            end
            if active_bowling_balls > 0 then 
                active_bowling_balls -= 1
            end
            util.stop_thread()
        end
    end)
end

function roasting_npc_thread(ped, player_ped)
    util.create_tick_handler(function()
        if ENTITY.DOES_ENTITY_EXIST(ped) then 
            TASK.TASK_LOOK_AT_ENTITY(npc, player_ped, 2, 2, 100)
            util.yield(1000)
            TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(npc, player_ped, 0, -0.2, 0, 7.0, -1, 10, true)
            local roasts = {
                "GENERIC_INSULT_MED",
                "GENERIC_INSULT_HIGH"
            }
            AUDIO.PLAY_PED_AMBIENT_SPEECH_NATIVE(ped, roasts[math.random(#roasts)], "SPEECH_PARAMS_FORCE_SHOUTED")
            util.yield(2000)
        else
            util.stop_thread()
        end
    end)
end

world_root:toggle_loop(translations.bomb_shower, {"bowlingshower"}, "", function()
    local hash = util.joaat("imp_prop_bomb_ball")
    request_model_load(hash)
    if active_bowling_balls <= 15 then 
        local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), math.random(-200, 200), math.random(-200, 200), math.random(100, 300))
        local ball = entities.create_object(hash, c)
        ENTITY.FREEZE_ENTITY_POSITION(ball, false)
        ENTITY.SET_ENTITY_DYNAMIC(ball, true)
        ENTITY.APPLY_FORCE_TO_ENTITY(ball, 1, math.random(-300, 300), math.random(-300, 300), -300, 0, 0, 0, 0, true, false, true, true, true)
        bomb_shower_tick_handler(ball)
    end
    util.yield(500)
end)


local bong_ad = "anim@safehouse@bong" 
local bong_anim = "bong_stage3"
local are_we_high = false 
local high_time = 120*1000
local shader_ref = menu.ref_by_path("Game>Rendering>Shader Override")
local initial_shader_int = menu.get_value(shader_ref)

function sober_up(ped)
    AUDIO.SET_PED_IS_DRUNK(ped, false)		
	PED.SET_PED_MOTION_BLUR(ped, false)
	--GRAPHICS.ANIMPOSTFX_STOP_ALL()
    menu.set_value(shader_ref, initial_shader_int)
	CAM.SHAKE_GAMEPLAY_CAM("DRUNK_SHAKE", 0.0)
	GRAPHICS.SET_TIMECYCLE_MODIFIER_STRENGTH(0.0)
    are_we_high = false
end

function get_high(ped, time)
    initial_shader_int = menu.get_value(shader_ref)
	GRAPHICS.SET_TIMECYCLE_MODIFIER("spectator6")
	PED.SET_PED_MOTION_BLUR(players.user_ped(), true)
	AUDIO.SET_PED_IS_DRUNK(players.user_ped(), true)
	--GRAPHICS.ANIMPOSTFX_PLAY("ChopVision", 10000001, true)
    menu.set_value(shader_ref, 69)
	CAM.SHAKE_GAMEPLAY_CAM("DRUNK_SHAKE", 3.0)
	util.yield(high_time)
    sober_up(players.user_ped())
end


local root = menu.my_root()
self_root:action(translations.hit_bong, {"hitthebong"}, translations.hit_bong_desc, function()
    local ped = players.user_ped()
    local bong_hash = util.joaat("prop_bong_01")
    if ENTITY.DOES_ENTITY_EXIST(ped) and not ENTITY.IS_ENTITY_DEAD(ped) and not smoking then
        local coords = players.get_position(players.user())
        coords.z += 0.2
        request_anim_dict(bong_ad)
        request_model_load(bong_hash)
    	local bong = entities.create_object(bong_hash, coords)
    	ENTITY.ATTACH_ENTITY_TO_ENTITY(bong, ped, PED.GET_PED_BONE_INDEX(ped, 18905), 0.10,-0.25,0.0,95.0,190.0,180.0, true, true, false, true, 1, true)
    	TASK.TASK_PLAY_ANIM(ped, bong_ad, bong_anim, 8.00, -8.00, -1, (2 + 16 + 32), 0.00, 0, 0, 0)
        util.yield(10000)
        TASK.STOP_ANIM_TASK(ped, bong_ad, bong_anim, 1.0)
    	entities.delete_by_handle(bong)
        are_we_high = true
        get_high(ped, high_time)
    end
end)

self_root:action(translations.drink_milk, {"drinkmilk"}, translations.drink_milk_desc, function()
    sober_up(players.user_ped())
end)

local active_rideable_animal = 0

-- rideable animal tick handler
util.create_tick_handler(function()
    if active_rideable_animal ~= 0 then 
        -- dismounting 
        if PAD.IS_CONTROL_JUST_PRESSED(23, 23) then 
            ENTITY.DETACH_ENTITY(players.user_ped())
            entities.delete_by_handle(active_rideable_animal)
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(players.user_ped())
            active_rideable_animal = 0
        end

        -- movement
        if not ENTITY.IS_ENTITY_IN_AIR(active_rideable_animal) then 
            if PAD.IS_CONTROL_PRESSED(32, 32) then 
                local side_move = PAD.GET_CONTROL_NORMAL(146, 146)
                local fwd = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(active_rideable_animal, side_move*10.0, 8.0, 0.0)
                TASK.TASK_LOOK_AT_COORD(active_rideable_animal, fwd.x, fwd.y, fwd.z, 0, 0, 2)
                TASK.TASK_GO_STRAIGHT_TO_COORD(active_rideable_animal, fwd.x, fwd.y, fwd.z, 20.0, -1, ENTITY.GET_ENTITY_HEADING(active_rideable_animal), 0.5)
            end
            if PAD.IS_CONTROL_JUST_PRESSED(76, 76) then 
                --TASK.CLEAR_PED_TASKS(active_rideable_animal)
                local w = {}
                w.x, w.y, w.z, _ = players.get_waypoint(players.user())
                if w.x == 0.0 and w.y == 0.0 then 
                    notify(translations.no_waypoint_set)
                else
                    TASK.TASK_FOLLOW_NAV_MESH_TO_COORD(active_rideable_animal, w.x, w.y, w.z, 1.0, -1, 100, 0, 0)
                end
            end
        end

    end
end)
local ranimal_hashes = {util.joaat("a_c_deer"), util.joaat("a_c_boar"), util.joaat("a_c_cow")}
rideable_animals_root:list_action(translations.spawn, {"spawnranimal"}, "", {translations.deer, translations.boar, translations.cow}, function(index)
    if active_rideable_animal ~= 0 then 
        notify(translations.already_riding_animal)
        return 
    end
    local hash = ranimal_hashes[index]
    request_model_load(hash)
    local animal = entities.create_ped(8, hash, players.get_position(players.user()), ENTITY.GET_ENTITY_HEADING(players.user_ped()))
    ENTITY.SET_ENTITY_INVINCIBLE(animal, true)
    ENTITY.FREEZE_ENTITY_POSITION(animal, true)
    ENTITY.FREEZE_ENTITY_POSITION(players.user_ped(), true)
    active_rideable_animal = animal
    local m_z_off = 0 
    local f_z_off = 0
    pluto_switch index do 
        case 1: 
            m_z_off = 0.3 
            f_z_off = 0.15
            break
        case 2:
            m_z_off = 0.4
            f_z_off = 0.3
            break
        case 3:
            m_z_off = 0.2 
            f_z_off = 0.1 
            break
    end
    if ENTITY.GET_ENTITY_MODEL(players.user_ped()) == util.joaat("mp_f_freemode_01") then 
        z_off = f_z_off
    else
        z_off = m_z_off
    end
    ENTITY.ATTACH_ENTITY_TO_ENTITY(players.user_ped(), animal, PED.GET_PED_BONE_INDEX(animal, 24816), -0.3, 0.0, z_off, 0.0, 0.0, 90.0, false, false, false, true, 2, true)
    request_anim_dict("rcmjosh2")
    TASK.TASK_PLAY_ANIM(players.user_ped(), "rcmjosh2", "josh_sitting_loop", 8.0, 1, -1, 2, 1.0, false, false, false)
    notify(translations.ra_instruction)
    ENTITY.FREEZE_ENTITY_POSITION(animal, false)
    ENTITY.FREEZE_ENTITY_POSITION(players.user_ped(), false)
end)

function high_event()
    local pick = math.random(1, 10)
    pluto_switch pick do
        case 3:
            for i=1, math.random(1000, 2000) do 
                PAD.SET_CONTROL_VALUE_NEXT_FRAME(34, 34, 1.0)
            end
            break
        case 4:
            for i=1, math.random(1000, 2000) do 
                PAD.SET_CONTROL_VALUE_NEXT_FRAME(35, 35, 1.0)
            end
            break
        case 5:
            PED.SET_PED_TO_RAGDOLL(players.user_ped(), 5, 5, 0, false, false, false)
            break
    end
end
-- mess with controls if we are high
util.create_tick_handler(function()
    if are_we_high then 
        high_event()
        util.yield(1000)
    end
end)

menu.action(train_root, translations.find_train, {}, "", function()
    for _, veh in pairs(entities.get_all_vehicles_as_pointers()) do 
        if entities.get_model_hash(veh) == util.joaat("freight") then
            local c = entities.get_position(veh)
            ENTITY.SET_ENTITY_COORDS(players.user_ped(), c.x, c.y, c.z)
            return 
        end
    end
    util.toast(translations.no_train_found)
end)

menu.click_slider(train_root, translations.set_train_speed, {}, "", -300, 300, 10, 1, function(s)
    local train_hdl = 0
    local was_any_train_affected = false
    for _, veh in pairs(entities.get_all_vehicles_as_pointers()) do 
        if entities.get_model_hash(veh) == util.joaat("freight") then
            train_hdl = entities.pointer_to_handle(veh)
            request_control_of_entity(train_hdl)
            VEHICLE.SET_TRAIN_SPEED(train_hdl, s)
            VEHICLE.SET_TRAIN_CRUISE_SPEED(train_hdl, s)
            was_any_train_affected = true
        end
    end
    if not was_any_train_affected then
        util.toast(translations.no_train_found)
    end
end)


-- TWEAKS
fakemessages_root = menu.list(tweaks_root, translations.fake_alerts, {translations.fake_alerts_cmd}, translations.fake_alerts_desc)
fakemoney_root = menu.list(tweaks_root, translations.fake_money, {translations.fake_money_cmd}, translations.fake_money_desc)

fakemoney_delay = 3000
menu.slider(fakemoney_root, translations.fake_money_delay, {translations.fake_money_delay_cmd}, "", 100, 10000, 3000, 1, function(s)
    fakemoney_delay = s
end)

fakemoney_amt = 30000000
menu.slider(fakemoney_root, translations.fake_money_amount, {translations.fake_money_amt_cmd}, "", 0, 1000000000, 30000000, 1, function(s)
    fakemoney_amt = s
end)

fakemoney_random = true
menu.toggle(fakemoney_root, translations.fake_money_random, {}, "", function(on)
    fakemoney_random = on
end, true)


menu.toggle_loop(fakemoney_root, translations.fake_money_loop, {}, "", function(on)
    local amt
    if fakemoney_random then 
        amt = math.random(10000000, 30000000)
    else
        amt = fakemoney_amt
    end
    HUD.CHANGE_FAKE_MP_CASH(0, amt)
    util.yield(fakemoney_delay)
end)

menu.action(tweaks_root, translations.force_cutscene, {translations.force_cutscene_cmd}, translations.force_cutscene_desc, function(click_type)
    notify(translations.type_cutscene_name)
    menu.show_command_box(translations.force_cutscene_cmd .. " ")
end, function(on_command)
    CUTSCENE.REQUEST_CUTSCENE(on_command, 8)
    local st = os.time()
    local s = false
    while true do
        if CUTSCENE.HAS_CUTSCENE_LOADED() then
            s = true
            break
        else
            if os.time() - st >= 10 then
                notify(translations.cutscene_fail)
                s = false
                return
            end
        end
        util.yield()
    end
    if s then
        CUTSCENE.START_CUTSCENE(0)
    end
end)


menu.toggle(tweaks_root, translations.music_only_radio, {translations.music_only_radio_cmd}, translations.music_only_radio_desc, function(on)
    num_unlocked = AUDIO.GET_NUM_UNLOCKED_RADIO_STATIONS()
    if on then
        for i=1, num_unlocked do
            AUDIO.SET_RADIO_STATION_MUSIC_ONLY(AUDIO.GET_RADIO_STATION_NAME(i), true)
        end
    else
        for i=1, num_unlocked do
            AUDIO.SET_RADIO_STATION_MUSIC_ONLY(AUDIO.GET_RADIO_STATION_NAME(i), false)
        end
    end
end)

menu.toggle(tweaks_root, translations.lock_minimap_angle, {translations.lock_minimap_angle_cmd}, translations.lock_minimap_angle_desc, function(on)
    if on then
        HUD.LOCK_MINIMAP_ANGLE(0)
    else
        HUD.UNLOCK_MINIMAP_ANGLE()
    end
end)

hud_rgb_index = 1
hud_rgb_colors = {6, 18, 9}
menu.toggle_loop(tweaks_root, translations.party_mode, {translations.party_mode_cmd}, translations.party_mode_desc, function(on)
    HUD.FLASH_MINIMAP_DISPLAY_WITH_COLOR(hud_rgb_colors[hud_rgb_index])
    hud_rgb_index = hud_rgb_index + 1
    if hud_rgb_index == 4 then
        hud_rgb_index = 1
    end
    util.yield(200)
end)

local force_radio_options = {translations.sleepwalking, translations.dont_come_close}
menu.list_action(tweaks_root, translations.force_radio, {""}, "", force_radio_options, function(index, value, click_type)
    local station = "RADIO_01_CLASS_ROCK"
    AUDIO.SET_RADIO_TO_STATION_NAME(station)
    pluto_switch index do 
        case 1: 
            AUDIO.SET_CUSTOM_RADIO_TRACK_LIST(station, "END_CREDITS_KILL_MICHAEL", true)
            break 
        case 2:
            AUDIO.SET_CUSTOM_RADIO_TRACK_LIST(station, "END_CREDITS_KILL_TREVOR", true)
            break
    end
end)

menu.toggle(tweaks_root, translations.aesthetify, {}, "", function(on)
    local a_toggle = menu.ref_by_path('World>Aesthetic Light>Aesthetic Light')
    if on then 
        menu.trigger_commands("shader glasses_purple")
        menu.trigger_commands("aestheticcolourred 255")
        menu.trigger_commands("aestheticcolourgreen 0")
        menu.trigger_commands("aestheticcolourblue 255")
        menu.trigger_commands("aestheticrange 10000")
        menu.trigger_commands("aestheticintensity 30")
        menu.trigger_commands("time 0")
        menu.set_value(a_toggle, true)
    else
        menu.set_value(a_toggle, false)
        menu.trigger_commands("shader off")
    end
end)



--LOCK_MINIMAP_ANGLE(int angle)

local function alert_thuds()
    util.create_thread(function()
        AUDIO.PLAY_SOUND_FRONTEND(-1, "Hit_In", "PLAYER_SWITCH_CUSTOM_SOUNDSET")
        util.yield(500)
        AUDIO.PLAY_SOUND_FRONTEND(-1, "Hit_In", "PLAYER_SWITCH_CUSTOM_SOUNDSET")
        util.yield(500)
        AUDIO.PLAY_SOUND_FRONTEND(-1, "Hit_In", "PLAYER_SWITCH_CUSTOM_SOUNDSET")
    end)
end

fake_alert_delay = 0
local function show_custom_alert_until_enter(l1)
    util.yield(fake_alert_delay)
    alert_thuds()
    poptime = os.time()
    while true do
        if PAD.IS_CONTROL_JUST_RELEASED(18, 18) then
            if os.time() - poptime > 0.1 then
                break
            end
        end
        native_invoker.begin_call()
        native_invoker.push_arg_string("ALERT")
        native_invoker.push_arg_string("JL_INVITE_ND")
        native_invoker.push_arg_int(2)
        native_invoker.push_arg_string("")
        native_invoker.push_arg_bool(true)
        native_invoker.push_arg_int(-1)
        native_invoker.push_arg_int(-1)
        -- line here
        native_invoker.push_arg_string(l1)
        -- optional second line here
        native_invoker.push_arg_int(0)
        native_invoker.push_arg_bool(true)
        native_invoker.push_arg_int(0)
        native_invoker.end_call("701919482C74B5AB")
        util.yield()
    end
end


menu.slider(fakemessages_root, translations.alert_delay, {translations.alert_delay_cmd}, translations.alert_delay_desc, 0, 300, 0, 1, function(s)
    fake_alert_delay = s*1000
end)

local fake_suspend_date = translations.initial_suspension_date
menu.text_input(fakemessages_root, translations.custom_suspension_date, {translations.custom_suspension_date_cmd}, translations.custom_suspension_date_desc, function(on_input)
    fake_suspend_date = on_input
end, "July 15, 2000")

local custom_alert = translations.initial_custom_alert
menu.action(fakemessages_root, translations.input_custom_alert, {translations.input_custom_alert_cmd}, "", function(on_click)
    notify(translations.input_custom_alert_toast)
    menu.show_command_box(translations.input_custom_alert_cmd .. " ")
end, function(on_command)
    show_custom_alert_until_enter(on_command)
end)


alert_options = {translations.fake_alert_1, translations.fake_alert_2, translations.fake_alert_3, translations.fake_alert_4, translations.fake_alert_5, translations.custom}
menu.list_action(fakemessages_root, translations.fake_alert, {translations.fake_alert_cmd}, "", alert_options, function(index, value, click_type)
    pluto_switch index do 
        case 1: 
            show_custom_alert_until_enter(translations.fake_alert_1_ct)
            break 
        case 2:
            show_custom_alert_until_enter(translations.fake_alert_2_ct)
            break
        case 3:
            show_custom_alert_until_enter(translations.fake_alert_3_ct)
            break
        case 4:
            show_custom_alert_until_enter(translations.fake_alert_4_ct)
            break
        case 5:
            show_custom_alert_until_enter(translations.fake_alert_5_ct_1 .. fake_suspend_date .. translations.fake_alert_5_ct_2)
            break
        case 6:
            show_custom_alert_until_enter(custom_alert)
            break
    end
end)

-- PLAYERS AND TROLLING

local function get_best_mug_target()
    local most = 0
    local mostp = 0
    for k,p in pairs(players.list(true, true, true)) do
        cur_wallet = players.get_wallet(p)
        if cur_wallet > most then
            most = cur_wallet
            mostp = p
        end
    end
    if cur_wallet == nil then
        notify(translations.best_mug_alone)
        return
    end
    if most ~= 0 then
        return players.get_name(mostp) .. translations.best_mug_1 .. most .. translations.best_mug_2
    else
        notify(translations.best_mug_fail)
        return nil
    end
end

local function get_poorest_player()
    local least = 10000000000000000
    local leastp = 0
    for k,p in pairs(players.list(true, true, true)) do
        cur_assets = players.get_wallet(p) + players.get_bank(p)
        if cur_assets < least then
            least = cur_assets
            leastp = p
        end
    end
    if cur_assets == nil then
        notify(translations.poorest_alone)
        return
    end
    if least ~= 10000000000000000 then
        return players.get_name(leastp) .. translations.poorest_1 .. players.get_wallet(leastp) .. translations.poorest_2 .. players.get_bank(leastp) .. translations.poorest_3
    else
        notify()
        return nil
    end
end

local function get_richest_player()
    local most = 0
    local mostp = 0
    for k,p in pairs(players.list(false, true, true)) do
        cur_assets = players.get_wallet(p) + players.get_bank(p)
        if cur_assets > most then
            most = cur_assets
            mostp = p
        end
    end
    if cur_assets == nil then
        notify(translations.richest_alone)
        return
    end
    if most ~= 0 then
        return players.get_name(mostp) .. translations.richest_1 .. players.get_wallet(mostp) .. translations.richest_2 .. players.get_bank(mostp) .. translations.richest_3
    else
        notify(translations.richest_fail)
        return nil
    end
end

local function get_horniest_player()
    local highest_horniness = 0
    local horniest = 0
    local most_lapdances = 0
    local most_prostitutes = 0
    for k,p in pairs(players.list(true, true, true)) do
        lapdances = get_lapdances_amount(p)
        prostitutes = get_prostitutes_solicited(p)
        horniness = lapdances + prostitutes
        if horniness > highest_horniness then
            highest_horniness = horniness
            horniest = p
            most_lapdances = lapdances
            most_prostitutes = prostitutes
        end
    end
    if horniness == nil then
        notify(translations.horniest_alone)
        return
    end
    if highest_horniness ~= 0 then
        return players.get_name(horniest) .. translations.horniest_1 .. most_prostitutes .. translations.horniest_2 .. most_lapdances .. translations.horniest_3
    else
        notify(translations.horniest_fail)
        return nil
    end
end

local function ram_ped_with(ped, vehicle, offset, sog)
    request_model_load(vehicle)
    local front = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, offset, 0.0)
    local veh = entities.create_vehicle(vehicle, front, ENTITY.GET_ENTITY_HEADING(ped)+180)
    set_entity_face_entity(veh, ped, true)
    if ram_onground then
        OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(veh)
    end
    VEHICLE.SET_VEHICLE_ENGINE_ON(veh, true, true, true)
    VEHICLE.SET_VEHICLE_FORWARD_SPEED(veh, 100.0)
end

local function give_vehicle(pid, hash)
    request_model_load(hash)
    local plyr = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
    local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(plyr, 0.0, 5.0, 0.0)
    local car = entities.create_vehicle(hash, c, ENTITY.GET_ENTITY_HEADING(plyr))
    max_out_car(car)
    ENTITY.SET_ENTITY_INVINCIBLE(car)
    VEHICLE.SET_VEHICLE_DOOR_OPEN(car, 0, false, true)
    VEHICLE.SET_VEHICLE_DOOR_LATCHED(car, 0, false, false, true)
end

local function give_vehicle_all(hash)
    for k,p in pairs(players.list(true, true, true)) do
        give_vehicle(p, hash)
    end
end

local function attachto(offx, offy, offz, pid, angx, angy, angz, hash, bone, isnpc, isveh)
    local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
    local bone = PED.GET_PED_BONE_INDEX(ped, bone)
    local coords = ENTITY.GET_ENTITY_COORDS(ped, true)
    if isnpc then
        obj = entities.create_ped(1, hash, coords, 90.0)
    elseif isveh then
        obj = entities.create_vehicle(hash, coords, 90.0)
    else
        obj = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, coords['x'], coords['y'], coords['z'], true, false, false)
    end
    ENTITY.SET_ENTITY_INVINCIBLE(obj, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(obj, ped, bone, offx, offy, offz, angx, angy, angz, false, false, true, false, 0, true)
    ENTITY.SET_ENTITY_COMPLETELY_DISABLE_COLLISION(obj, false, true)
end

local function give_car_addon(pid, hash, center, ang)
    local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
    local pos = ENTITY.GET_ENTITY_COORDS(car, true)
    request_model_load(hash)
    local ramp = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, pos['x'], pos['y'], pos['z'], true, false, false)
    local size = get_model_size(ENTITY.GET_ENTITY_MODEL(car))
    if center then
        ENTITY.ATTACH_ENTITY_TO_ENTITY(ramp, car, 0, 0.0, 0.0, 0.0, 0.0, 0.0, ang, true, true, true, false, 0, true)
    else
        ENTITY.ATTACH_ENTITY_TO_ENTITY(ramp, car, 0, 0.0, size['y']+1.0, 0.0, 0.0, 0.0, ang, true, true, true, false, 0, true)
    end
end

local function give_all_car_addon(hash, center, ang)
    for k,pid in pairs(players.list(false, true, true)) do
        give_car_addon(pid, hash, center, ang)
    end
end

local function attachall(offx, offy, offz, angx, angy, angz, hash, bone, isnpc, isveh)
    request_model_load(hash)
    for k, pid in pairs(players.list(false, true, true)) do
        attachto(offx, offy, offz, pid, angx, angy, angz, hash, bone, isnpc, isveh)
    end
end

-- INDIVIDUAL PLAYER SEGMENTS
num_attackers = 1
godmodeatk = false
freezeloop = false
atkhealth = 100
atk_critical_hits = true
freezetar = -1

local function tp_player_car_to_coords(pid, coord)
    local name = players.get_name(pid)
    local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
    if car ~= 0 then
        request_control_of_entity(car)
        if NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(car) then
            for i=1, 3 do
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(car, coord['x'], coord['y'], coord['z'], false, false, false)
            end
        end
    end
end

local function tp_all_player_cars_to_coords(coord)
    for k,pid in pairs(players.list(false, true, true)) do
        tp_player_car_to_coords(pid, coord)
    end
end

local function dispatch_griefer_jesus(target)
    griefer_jesus = util.create_thread(function(thr)
        notify(translations.grief_jesus_sent)
        request_model_load(-835930287)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(target)
        coords = ENTITY.GET_ENTITY_COORDS(target_ped, false)
        local jesus = entities.create_ped(1, -835930287, coords, 90.0)
        ENTITY.SET_ENTITY_INVINCIBLE(jesus, true)
        PED.SET_PED_HEARING_RANGE(jesus, 9999)
	    PED.SET_PED_CONFIG_FLAG(jesus, 281, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(jesus, 5, true)
	    PED.SET_PED_COMBAT_ATTRIBUTES(jesus, 46, true)
        PED.SET_PED_CAN_RAGDOLL(jesus, false)
        WEAPON.GIVE_WEAPON_TO_PED(jesus, util.joaat("WEAPON_RAILGUN"), 9999, true, true)
        TASK.TASK_GO_TO_ENTITY(jesus, target_ped, -1, -1, 100.0, 0.0, 0)
    	TASK.TASK_COMBAT_PED(jesus, target_ped, 0, 16)
        PED.SET_PED_ACCURACY(jesus, 100.0)
        PED.SET_PED_COMBAT_ABILITY(jesus, 2)
        --pretty much just a respawn/rationale check
        while true do
            local player_coords = ENTITY.GET_ENTITY_COORDS(target_ped, false)
            local jesus_coords = ENTITY.GET_ENTITY_COORDS(jesus, false)
            local dist =  MISC.GET_DISTANCE_BETWEEN_COORDS(player_coords['x'], player_coords['y'], player_coords['z'], jesus_coords['x'], jesus_coords['y'], jesus_coords['z'], false)
            if dist > 100 then
                local behind = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(target_ped, -3.0, 0.0, 0.0)
                ENTITY.SET_ENTITY_COORDS(jesus, behind['x'], behind['y'], behind['z'], false, false, false, false)
            end
            -- if jesus disappears we can just make another lmao
            if not ENTITY.DOES_ENTITY_EXIST(jesus) then
                util.stop_thread()
            end
            local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(target)
            if not players.exists(target) then
                util.stop_thread()
            else
                TASK.TASK_COMBAT_PED(jesus, target_ped, 0, 16)
            end
            util.yield(100)
        end
    end)
end


local function dispatch_mariachi(target)
    mariachi_thr = util.create_thread(function()
        local men = {}
        local player_ped
        local pos_offsets = {-1.0, 0.0, 1.0}
        local p_hash = -927261102
        local pos
        request_model_load(p_hash)
        player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(target)
        for i=1, 3 do
            local spawn_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, pos_offsets[i], 1.0, 0.0)
            local ped = entities.create_ped(1, p_hash, spawn_pos, 0.0)
            local flag = entities.create_object(util.joaat("prop_flag_mexico"), spawn_pos, 0)
            ENTITY.SET_ENTITY_HEADING(ped, ENTITY.GET_ENTITY_HEADING(player_ped)+180)
            ENTITY.ATTACH_ENTITY_TO_ENTITY(flag, ped, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
            ENTITY.SET_ENTITY_COMPLETELY_DISABLE_COLLISION(ped, true, false)
            TASK.TASK_START_SCENARIO_IN_PLACE(ped, "WORLD_HUMAN_MUSICIAN", 0, false)
            PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
            PED.SET_PED_FLEE_ATTRIBUTES(ped, 0, false)
            PED.SET_PED_CAN_RAGDOLL(ped, false)
            ENTITY.SET_ENTITY_INVINCIBLE(ped, true)
            men[#men + 1] = ped
        end
    end)
end

givegun = false
local function send_attacker(hash, pid, givegun, num_attackers, atkgun)
    local this_attacker
    local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
    coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(target_ped, 0.0, -3.0, 0.0)
    if hash ~= 'CLONE' then
        request_model_load(hash)
    end
    local first_ped_relationship_hash = 0
    for i=1, num_attackers do
        if hash ~= 'CLONE' then
            this_attacker = entities.create_ped(28, hash, coords, math.random(0, 270))
        else
            this_attacker = PED.CLONE_PED(target_ped, true, false, true)
        end

        if i == 1 then 
            first_ped_relationship_hash = PED.GET_PED_RELATIONSHIP_GROUP_HASH(this_attacker)
        else
            PED.SET_PED_RELATIONSHIP_GROUP_HASH(this_attacker, first_ped_relationship_hash)
        end

        local blip = HUD.ADD_BLIP_FOR_ENTITY(this_attacker)
        HUD.SET_BLIP_COLOUR(blip, 61)
        if godmodeatk then
            ENTITY.SET_ENTITY_INVINCIBLE(this_attacker, true)
        end
        TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(this_attacker, true)
        PED.SET_PED_ACCURACY(this_attacker, 100.0)
        PED.SET_PED_COMBAT_ABILITY(this_attacker, 2)
        PED.SET_PED_AS_ENEMY(this_attacker, true)
        PED.SET_PED_FLEE_ATTRIBUTES(this_attacker, 0, false)
        PED.SET_PED_COMBAT_ATTRIBUTES(this_attacker, 46, true)
        TASK.TASK_COMBAT_PED(this_attacker, target_ped, 0, 16)
        if atkgun ~= 0 then
            WEAPON.GIVE_WEAPON_TO_PED(this_attacker, atkgun, 1000, false, true)
        end
        PED.SET_PED_MAX_HEALTH(this_attacker, atkhealth)
        ENTITY.SET_ENTITY_HEALTH(this_attacker, atkhealth)
        PED.SET_PED_SUFFERS_CRITICAL_HITS(this_attacker, atk_critical_hits)
    end
end

local function send_aircraft_attacker(vhash, phash, pid, num_attackers)
    local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
    coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(target_ped, 1.0, 0.0, 500.0)
    request_model_load(vhash)
    request_model_load(phash)
    local first_ped_relationship_hash = 0
    for i=1, num_attackers do
        coords.x = coords.x + i*2
        coords.y = coords.y + i*2
        local aircraft = entities.create_vehicle(vhash, coords, 0.0)
        VEHICLE.CONTROL_LANDING_GEAR(aircraft, 3)
        VEHICLE.SET_HELI_BLADES_FULL_SPEED(aircraft)
        VEHICLE.SET_VEHICLE_FORWARD_SPEED(aircraft, VEHICLE.GET_VEHICLE_ESTIMATED_MAX_SPEED(aircraft))
        if godmodeatk then
            ENTITY.SET_ENTITY_INVINCIBLE(aircraft, true)
        end
        for i= -1, VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(vhash) - 2 do
            local ped = entities.create_ped(28, phash, coords, 30.0)
            if i == 1 then 
                first_ped_relationship_hash = PED.GET_PED_RELATIONSHIP_GROUP_HASH(ped)
            else
                PED.SET_PED_RELATIONSHIP_GROUP_HASH(ped, first_ped_relationship_hash)
            end
            local blip = HUD.ADD_BLIP_FOR_ENTITY(ped)
            HUD.SET_BLIP_COLOUR(blip, 61)
            if i == -1 then
                TASK.TASK_PLANE_MISSION(ped, aircraft, 0, target_ped, 0, 0, 0, 6, 0.0, 0, 0.0, 50.0, 40.0)
            end
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 5, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true)
            PED.SET_PED_INTO_VEHICLE(ped, aircraft, i)
            TASK.TASK_COMBAT_PED(ped, target_ped, 0, 16)
            PED.SET_PED_ACCURACY(ped, 100.0)
            PED.SET_PED_COMBAT_ABILITY(ped, 2)
        end
    end
end

local function send_groundv_attacker(vhash, phash, pid, givegun, num_attackers, atkgun)
    local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
    request_model_load(vhash)
    local bike_hash = -159126838
    request_model_load(phash)
    for i=1, num_attackers do
        local spawn_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, num_attackers-i, -10.0, 0.0)
        local bike = entities.create_vehicle(vhash, spawn_pos, ENTITY.GET_ENTITY_HEADING(player_ped))
        VEHICLE.SET_VEHICLE_ENGINE_ON(bike, true, true, false)
        local first_ped_relationship_hash = 0
        for i=-1, VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(vhash) - 2 do
            local rider = entities.create_ped(1, phash, spawn_pos, 0.0)
            if i == 1 then 
                first_ped_relationship_hash = PED.GET_PED_RELATIONSHIP_GROUP_HASH(rider)
            else
                PED.SET_PED_RELATIONSHIP_GROUP_HASH(rider, first_ped_relationship_hash)
            end
            local blip = HUD.ADD_BLIP_FOR_ENTITY(rider)
            HUD.SET_BLIP_COLOUR(blip, 61)
            if i == -1 then
                TASK.TASK_VEHICLE_CHASE(rider, target_ped)
            end
            max_out_car(atkbike)
            PED.SET_PED_INTO_VEHICLE(rider, bike, i)
            PED.SET_PED_COMBAT_ATTRIBUTES(rider, 5, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(rider, 46, true)
            TASK.TASK_COMBAT_PED(rider, player_ped, 0, 16)
            if godmodeatk then
                ENTITY.SET_ENTITY_INVINCIBLE(bike, true)
                ENTITY.SET_ENTITY_INVINCIBLE(rider, true)
            end

            if atkgun ~= 0 then
                WEAPON.GIVE_WEAPON_TO_PED(rider, atkgun, 1000, false, true)
            end
        end
    end
end

local function send_attacker_squad(p_hash, v_hash, forcestayinv, godmodeatk, hp, weapon, pid)
    local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
    request_model_load(p_hash)
    request_model_load(v_hash)
    local coords = ENTITY.GET_ENTITY_COORDS(player_ped, true)
    local spawn_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 0.0, -10.0, 0.0)
    local vehicle = entities.create_vehicle(v_hash, spawn_pos, ENTITY.GET_ENTITY_HEADING(player_ped)) 
    VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, false)
    max_out_car(vehicle)
    local blip = HUD.ADD_BLIP_FOR_ENTITY(vehicle)
    HUD.SET_BLIP_COLOUR(blip, 61)
    if godmodeatk then
        ENTITY.SET_ENTITY_INVINCIBLE(vehicle, true)
    end

    local first_ped_relationship_hash = 0
    for i=-1, VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(vehicle) - 1 do
        local ped = entities.create_ped(1, p_hash, spawn_pos, 0.0)
        if i == 1 then 
            first_ped_relationship_hash = PED.GET_PED_RELATIONSHIP_GROUP_HASH(ped)
        else
            PED.SET_PED_RELATIONSHIP_GROUP_HASH(ped, first_ped_relationship_hash)
        end
        PED.SET_PED_INTO_VEHICLE(ped, vehicle, i)
        if weapon ~= 0 then
            WEAPON.GIVE_WEAPON_TO_PED(ped, weapon, 1000, false, true)
        end
        ENTITY.SET_ENTITY_HEALTH(ped, hp)

        if hp > 100.0 then
            PED.SET_PED_SUFFERS_CRITICAL_HITS(ped, false)
            PED.SET_PED_CAN_RAGDOLL(ped, false)
        end
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 5, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true)
        if i == -1 then
            TASK.TASK_VEHICLE_CHASE(ped, player_ped)
        end
        TASK.TASK_COMBAT_PED(rider, player_ped, 0, 16)

        if godmodeatk then
            ENTITY.SET_ENTITY_INVINCIBLE(ped, true)
        end

        if forcestayinv then
            VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_TEAMS(vehicle, true)
            VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle, true)
        end
    end
end

local function send_player_label_sms(label, pid)
    local event_data = {-791892894, players.user(), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    local out = label:sub(1, 127)
    for i = 0, #out -1 do
        local slot = i // 8
        local byte = string.byte(out, i + 1)
        event_data[slot + 3] = event_data[slot + 3] | byte << ( (i - slot * 8) * 8)
    end
    util.trigger_script_event(1 << pid, event_data)
end

vehicle_hashes = {util.joaat("dune2"), util.joaat("speedo2"), util.joaat("krieger"), util.joaat("kuruma"), util.joaat('insurgent'), util.joaat('neon'), util.joaat('akula'), util.joaat('alphaz1'), util.joaat('rogue'), util.joaat('oppressor2'), util.joaat('hydra')}
vehicle_names = {translations.v_1, translations.v_2, translations.v_3, translations.v_4, translations.v_5, translations.v_6, translations.v_7, translations.v_8, translations.v_9, translations.v_10, translations.v_11, translations.custom}

local function set_up_player_actions(pid)
    local childlock
    local atkgun = 0
    menu.divider(menu.player_root(pid), translations.script_name_pretty)
    local ls_friendly = menu.list(menu.player_root(pid), translations.ls_friendly, {translations.ls_friendly_cmd}, "")
    local ls_hostile = menu.list(menu.player_root(pid), translations.ls_hostile, {translations.ls_hostile_cmd}, "")
    local ls_neutral = menu.list(menu.player_root(pid), translations.ls_neutral, {translations.ls_neutral_cmd}, "")
    local spawnvehicle_root = menu.list(ls_friendly, translations.give_vehicle_root, {translations.give_vehicle_root_cmd}, "")
    local explosions_root = menu.list(ls_hostile, translations.projectiles_explosions, {translations.projectiles_explosions_cmd}, translations.projectiles_explosions_desc)
    local playerveh_root = menu.list(ls_hostile, translations.vehicle, {translations.p_vehicle_root_cmd}, translations.p_vehicle_root_desc)
    local npctrolls_root = menu.list(ls_hostile, translations.npc_trolling, {translations.npc_trolling_root_cmd}, "")
    local soundtrolls_root = menu.list(ls_hostile, translations.sound_trolling, {translations.sound_trolling_root_cmd}, "")
    local attackers_root = menu.list(npctrolls_root, translations.attackers, {translations.attackers_root_cmd}, "")
    local chattrolls_root = menu.list(ls_hostile, translations.chat_trolling, {translations.chat_trolling_cmd}, "")

    ram_root = menu.list(ls_hostile, translations.ram_root, {translations.ram_root_cmd}, "")

    local tp_options = {translations.to_me, translations.to_waypoint, translations.maze_bank, translations.underwater, translations.high_up, translations.lsc, translations.scp_173, translations.large_cell, translations.luxury_autos_show_room, translations.underwater_child_lock}
    menu.list_action(playerveh_root, translations.teleport, {translations.teleport_cmd}, "", tp_options, function(index, value, click_type)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            local c = {}
            pluto_switch index do
                case 1:
                    c = players.get_position(players.user())
                    break
                case 2: 
                    c = get_waypoint_coords()
                    break
                case 3:
                    c.x = -75.261375
                    c.y = -818.674
                    c.z = 326.17517
                    break
                case 4: 
                    c.x = 4497.2207
                    c.y = 8028.3086
                    c.z = -32.635174
                    break
                case 5: 
                    c.x = 0.0
                    c.y = 0.0
                    c.z = 2000
                    break
                case 6: 
                    c.x = -353.84512
                    c.y = -135.59108
                    c.z = 39.009624
                    break
                case 7: 
                    c.x = 1642.8401
                    c.y = 2570.7695
                    c.z = 45.564854
                    break
                case 8:
                    c.x = 1737.1896
                    c.y = 2634.897
                    c.z = 45.56497
                    break
                case 9: 
                    c.x = -787.4092
                    c.y = -239.00093
                    c.z = 37.734055
                    break
                case 10: 
                    menu.set_value(childlock, true)
                    c.x = 4497.2207
                    c.y = 8028.3086
                    c.z = -32.635174
                    break
            end
            request_control_of_entity(car)
            tp_player_car_to_coords(pid, c)
        end
    end)

    local attach_options = {translations.to_car, translations.car_to_my_car, translations.my_car_to_their_car, translations.detach}
    menu.list_action(playerveh_root, translations.v_attach, {translations.v_attach_cmd}, "", attach_options, function(index, value, click_type)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            request_control_of_entity(car)
            pluto_switch index do
                case 1: 
                    ENTITY.ATTACH_ENTITY_TO_ENTITY(players.user_ped(), car, 0, 0.0, -0.20, 2.00, 1.0, 1.0,1, true, true, true, false, 0, true)
                    break 
                case 2: 
                    if player_cur_car ~= 0 then
                        ENTITY.ATTACH_ENTITY_TO_ENTITY(car, player_cur_car, 0, 0.0, -5.00, 0.00, 1.0, 1.0,1, true, true, true, false, 0, true)
                    end
                    break
                case 3: 
                    if player_cur_car ~= 0 then
                        ENTITY.ATTACH_ENTITY_TO_ENTITY(player_cur_car, car, 0, 0.0, -5.00, 0.00, 1.0, 1.0,1, true, true, true, false, 0, true)
                    end
                    break

                case 4: 
                    ENTITY.DETACH_ENTITY(car, false, false)
                    if player_cur_car ~= 0 then
                        ENTITY.DETACH_ENTITY(player_cur_car, false, false)
                    end
                    ENTITY.DETACH_ENTITY(players.user_ped(), false, false)
                    break
            end
        end
    end)

    local vhp_options = {translations.v_destroy, translations.v_repair}
    menu.list_action(playerveh_root, translations.v_health, {translations.v_health_cmd},  translations.v_health_desc, vhp_options, function(index, value, click_type)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            request_control_of_entity(car)
            VEHICLE.SET_VEHICLE_ENGINE_HEALTH(car, if index == 1 then -4000.0 else 10000.0)
            VEHICLE.SET_VEHICLE_BODY_HEALTH(car, if index == 1 then -4000.0 else 10000.0)
            if index == 2 then
                VEHICLE.SET_VEHICLE_FIXED(car)
            end
        end
    end)

    menu.action(playerveh_root, translations.yeet_vehicle, {translations.yeet_vehicle_cmd}, "", function(click_type)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            request_control_of_entity(car)
            ENTITY.SET_ENTITY_MAX_SPEED(car, 10000000.0)
            ENTITY.APPLY_FORCE_TO_ENTITY(car, 1,  0.0, 0.0, 10000000, 0, 0, 0, 0, true, false, true, false, true)
        end
    end)

    menu.action(playerveh_root, translations.delete_vehicle, {translations.delete_vehicle_cmd}, "", function(click_type)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        entities.delete_by_handle(car)
    end)

    childlock = menu.toggle_loop(playerveh_root, translations.child_lock, {translations.child_lock_cmd}, "", function()
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            VEHICLE.SET_VEHICLE_DOORS_LOCKED(car, 4)
        end
    end, function()
        if car ~= 0 then
            VEHICLE.SET_VEHICLE_DOORS_LOCKED(car, 1)
        end
    end)

    local door_options = {translations.open, translations.close, translations.d_break}
    menu.list_action(playerveh_root, translations.door_control, {translations.door_control_cmd}, "", door_options, function(index, value, click_type)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            request_control_of_entity(car)
            local d = VEHICLE.GET_NUMBER_OF_VEHICLE_DOORS(car)
            for i=0, d do
                pluto_switch index do
                    case 1: 
                        VEHICLE.SET_VEHICLE_DOOR_OPEN(car, i, false, true)
                        break
                    case 2:
                        VEHICLE.SET_VEHICLE_DOOR_SHUT(car, i, true)
                        break
                    case 3:
                        VEHICLE.SET_VEHICLE_DOOR_BROKEN(car, i, false)
                        break
                end
            end
        end
    end)

    menu.action(playerveh_root, translations.p_godmode_vehicle, {translations.p_godmode_vehicle_cmd}, "", function(click_type)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            request_control_of_entity(car)
            ENTITY.SET_ENTITY_INVINCIBLE(car, true)
            VEHICLE.SET_VEHICLE_CAN_BE_VISIBLY_DAMAGED(car, false)
        end
    end)

    menu.click_slider(playerveh_root, translations.p_vehicle_top_speed, {translations.p_vehicle_top_speed_cmd}, "", -10000, 10000, 200, 50, function(s)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            request_control_of_entity(car)
            VEHICLE.MODIFY_VEHICLE_TOP_SPEED(car, s)
            ENTITY.SET_ENTITY_MAX_SPEED(car, s)
        end
    end)

    menu.toggle(playerveh_root, translations.p_invisible_vehicle, {translations.p_invisible_vehicle_cmd}, "", function(on)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            request_control_of_entity(car)
            if on then
                ENTITY.SET_ENTITY_ALPHA(car, 255)
                ENTITY.SET_ENTITY_VISIBLE(car, false, 0)
            else
                ENTITY.SET_ENTITY_ALPHA(car, 0)
                ENTITY.SET_ENTITY_VISIBLE(car, true, 0)
            end
        end
    end)

    menu.toggle(playerveh_root, translations.e_brake, {translations.e_brake_cmd}, "", function(on)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            request_control_of_entity(car)
            VEHICLE.SET_VEHICLE_HANDBRAKE(car, on)
        end
    end)

    menu.toggle_loop(playerveh_root, translations.randomly_brake, {translations.randomly_brake_cmd}, "", function(on)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            request_control_of_entity(car)
            VEHICLE.SET_VEHICLE_HANDBRAKE(car, true)
            util.yield(1000)
            request_control_of_entity(car)
            VEHICLE.SET_VEHICLE_HANDBRAKE(car, false)
            util.yield(math.random(3000, 15000))
        end
    end)

    
    menu.toggle_loop(playerveh_root, translations.beyblade, {translations.beyblade_cmd}, "", function(on)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            request_control_of_entity_once(car)
            ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(car, 4, 0.0, 0.0, 300.0, 0, true, true, false, true, true, true)
        end
    end)

    menu.toggle(playerveh_root, translations.p_v_freeze, {translations.p_v_freeze_cmd}, "", function(on)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            request_control_of_entity(car)
            speed = if on then 0.0 else 1000.0
            ENTITY.SET_ENTITY_MAX_SPEED(car, speed)
        end
    end)
    --SET_VEHICLE_ALARM(Vehicle vehicle, BOOL state)

    menu.action(playerveh_root, translations.burst_tires, {translations.burst_tires_cmd}, "", function(on)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            request_control_of_entity(car)
            for i=0, 7 do
                VEHICLE.SET_VEHICLE_TYRE_BURST(car, i, true, 1000.0)
            end
        end
    end)
    
    menu.action(playerveh_root, translations.turn_vehicle_around, {translations.turn_vehicle_around_cmd}, "", function(on)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            request_control_of_entity(car)
            local rot = ENTITY.GET_ENTITY_ROTATION(car, 0)
            local vel = ENTITY.GET_ENTITY_VELOCITY(car)
            ENTITY.SET_ENTITY_ROTATION(car, rot['x'], rot['y'], rot['z']+180, 0, true)
            ENTITY.SET_ENTITY_VELOCITY(car, -vel['x'], -vel['y'], vel['z'])
        end
    end)

    menu.action(playerveh_root, translations.p_flip_vehicle, {translations.p_flip_vehicle_cmd}, "", function(on)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            request_control_of_entity(car)
            local rot = ENTITY.GET_ENTITY_ROTATION(car, 0)
            local vel = ENTITY.GET_ENTITY_VELOCITY(car)
            ENTITY.SET_ENTITY_ROTATION(car, rot['x'], rot['y']+180, rot['z'], 0, true)
            ENTITY.SET_ENTITY_VELOCITY(car, -vel['x'], -vel['y'], vel['z'])
        end
    end)

    menu.action(playerveh_root, translations.turn_engine_off, {translations.turn_engine_off_cmd}, "", function(on)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            request_control_of_entity(car)
            VEHICLE.SET_VEHICLE_ENGINE_ON(car, false, true, false)
        end
    end)

    menu.action(playerveh_root, translations.emp_vehicle, {translations.emp_vehicle_cmd}, "", function(on)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            local c = ENTITY.GET_ENTITY_COORDS(car)
            FIRE.ADD_EXPLOSION(c.x, c.y, c.z, 83, 100.0, false, true, 0.0)
        end
    end)

    menu.action(ls_friendly, translations.p_remove_stickybombs_from_car, {translations.p_remove_stickybombs_from_car_cmd}, "", function(click_type)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        NETWORK.REMOVE_ALL_STICKY_BOMBS_FROM_ENTITY(car)
    end)

    crush_root = menu.list(ls_hostile, translations.crush_player, {translations.crush_player_root_cmd}, "")

    local custom_crush_model = "dump"
    menu.text_input(crush_root, translations.custom_crush_model, {translations.custom_crush_model_cmd}, translations.custom_crush_model_desc, function(on_input)
        custom_crush_model = on_input
    end, 'dump')


    local crush_vehicle_hashes = {util.joaat('flatbed'), util.joaat('faggio'), util.joaat('speedo2')}
    local crush_vehicle_names = {translations.truck, translations.faggio, translations.clown_van, translations.custom}
    menu.list_action(crush_root, translations.crush_player, {translations.crush_player_cmd}, translations.crush_player_desc, crush_vehicle_names, function(index, value, click_type)
        if index == 4 then 
            hash = util.joaat(custom_crush_model)
        else
            hash = crush_vehicle_hashes[index]
        end
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        coords = ENTITY.GET_ENTITY_COORDS(target_ped, false)
        coords.z = coords['z'] + 20.0
        request_model_load(hash)
        local veh = entities.create_vehicle(hash, coords, 0.0)
    end)

    
    menu.action(ls_hostile, translations.ragdoll, {translations.ragdoll_cmd}, "", function(on)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), 0.0, 0.0, 2.8)
        FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], 70, 100.0, false, true, 0.0)
    end)

    menu.action(ls_hostile, translations.heart_attack, {translations.heart_attack_cmd}, translations.heart_attack_desc, function(on)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), 0.0, 0.5, 1.0)
        local v = PED.GET_VEHICLE_PED_IS_USING(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid))
        if v ~= 0 then 
            request_control_of_entity(v)
            ENTITY.SET_ENTITY_INVINCIBLE(v, true)
        end
        FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], 47, 100.0, false, true, 0.0)
        if v ~= 0 then 
            request_control_of_entity(v)
            ENTITY.SET_ENTITY_INVINCIBLE(v, false)
        end
    end)

    local obj_options = {translations.ramp, translations.barrier, translations.windmill, translations.radar}
    menu.list_action(ls_hostile, translations.spawn_object, {translations.spawn_object_cmd}, translations.spawn_object_desc, obj_options, function (index, value, click_type)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        pluto_switch index do 
            case 1:
                local hash = 2282807134
                request_model_load(hash)
                local ramp = spawn_object_in_front_of_ped(target_ped, hash, 90, 50.0, -1, true)
                local c = ENTITY.GET_ENTITY_COORDS(ramp, true)
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ramp, c['x'], c['y'], c['z']-0.2, false, false, false)
                break
            case 2: 
                local hash = 3729169359
                local obj = spawn_object_in_front_of_ped(target_ped, hash, 0, 5.0, -0.5, false)
                ENTITY.FREEZE_ENTITY_POSITION(obj, true)
                break
            case 3: 
                local hash = 1952396163
                local obj = spawn_object_in_front_of_ped(target_ped, hash, 0, 5.0, -30, false)
                ENTITY.FREEZE_ENTITY_POSITION(obj, true)
                break
            case 4: 
                local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local hash = 2306058344
                local obj = spawn_object_in_front_of_ped(target_ped, hash, 0, 0.0, -5.0, false)
                ENTITY.FREEZE_ENTITY_POSITION(obj, true)
                break
        end
    end)
        
    local v_model = 'lazer'
    menu.text_input(spawnvehicle_root, translations.give_vehicle_custom_vehicle_model, {translations.give_vehicle_custom_vehicle_model_cmd}, translations.give_vehicle_custom_vehicle_model_desc, function(on_input)
        v_model = on_input
    end, 'lazer')

    menu.list_action(spawnvehicle_root, translations.give_vehicle, {translations.give_vehicle_cmd}, "", vehicle_names, function(index, value, click_type)
        if value ~= translations.custom then 
            give_vehicle(pid, vehicle_hashes[index])
        else
            give_vehicle(pid, util.joaat(v_model))
        end
    end)

    local ram_car = "brickade"
    menu.text_input(ram_root, translations.custom_ram_vehicle, {translations.custom_ram_vehicle_cmd}, translations.custom_ram_vehicle_desc, function(on_input)
        ram_car = on_input
    end, "brickade")

    local ram_hashes = {-1007528109, -2103821244, 368211810, -1649536104}
    local ram_options = {translations.howard, translations.rally_truck, translations.cargo_plane, translations.phantom_wedge, translations.custom}
    menu.list_action(ram_root, translations.ram_with, {translations.ram_with_cmd}, "", ram_options, function(index, value, click_type)
        if value ~= translations.custom then
            ram_ped_with(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), ram_hashes[index], math.random(5, 15))
        else
            ram_ped_with(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), util.joaat(ram_car), math.random(5, 15))
        end
    end)

    menu.action(ls_hostile, translations.fling_vehicles, {"magnet"}, "", function()
        local p_c = players.get_position(pid)
        for _, v in pairs(entities.get_all_vehicles_as_handles()) do 
            if not PED.IS_PED_A_PLAYER(VEHICLE.GET_PED_IN_VEHICLE_SEAT(v, -1, false)) then 
                local v_c = ENTITY.GET_ENTITY_COORDS(v)
                local c = {}
                c.x = (p_c.x - v_c.x)*2
                c.y = (p_c.y - v_c.y )*2
                c.z = (p_c.z - v_c.z)*2
                ENTITY.APPLY_FORCE_TO_ENTITY(v, 1, c.x, c.y, c.z, 0, 0, 0, 0, false, false, true, false, false)
            end
        end
    end)

    local explo_types = {13, 12, 70}
    local e_type = 13
    local explo_options = {translations.water_jet, translations.fire_jet, translations.launch_player}
    local explo_type_slider = menu.list_action(explosions_root, translations.explosion_type, {translations.explosion_type_cmd}, "", explo_options, function(index, value, click_type)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local coords = ENTITY.GET_ENTITY_COORDS(target_ped, false)
        e_type = explo_types[index]
        FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], e_type, 100.0, true, false, 0.0)
    end)

    menu.toggle_loop(explosions_root, translations.loop_explosion, {translations.loop_explosion_cmd}, translations.loop_explosion_desc, function(on)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local coords = ENTITY.GET_ENTITY_COORDS(target_ped)
        FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], e_type, 1.0, true, false, 0.0)
    end)

    menu.toggle_loop(explosions_root, translations.random_explosion_loop, {translations.random_explosion_loop_cmd}, "", function(on)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local coords = ENTITY.GET_ENTITY_COORDS(target_ped)
        FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], math.random(0, 82), 1.0, true, false, 0.0)
    end)

    local p_types = {100416529, 126349499}
    local projectile_options = {translations.bullet, translations.snowball}
    menu.list_action(explosions_root, translations.projectile_type, {translations.projectile_type_cmd}, "", projectile_options, function(index, value, click_type)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local target = ENTITY.GET_ENTITY_COORDS(target_ped, false)
        local owner = players.user_ped()
        p_type = p_types[index]
        WEAPON.REQUEST_WEAPON_ASSET(p_type)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(target['x'], target['y'], target['z']+0.5, target['x'], target['y'], target['z']+0.6, 100, true, p_type, owner, true, false, 4000.0)
    end)

    menu.toggle_loop(explosions_root, translations.projectile_loop, {translations.projectile_loop_cmd}, "", function(on)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local target = ENTITY.GET_ENTITY_COORDS(target_ped, false)
        local owner = players.user_ped()
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(target['x'], target['y'], target['z']+0.5, target['x'], target['y'], target['z']+0.6, 100, true, p_type, owner, true, false, 4000.0)
    end)

    menu.action(explosions_root, translations.nuke, {"nuke"}, translations.nuke_desc, function(on)
        local p_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)

        for _, v_ptr in pairs(entities.get_all_vehicles_as_pointers()) do 
            local v_pos = entities.get_position(v_ptr)
            if v3.distance(ENTITY.GET_ENTITY_COORDS(p_ped), v_pos) < 200 then
                ENTITY.SET_ENTITY_HEALTH(entities.pointer_to_handle(v_ptr), 0.0)
                FIRE.ADD_EXPLOSION(v_pos.x, v_pos.y, v_pos.z, 17, 1.0, true, false, 100.0, false)
            end
        end

        for _, p_ptr in pairs(entities.get_all_peds_as_pointers()) do 
            local p_pos = entities.get_position(p_ptr)
            if v3.distance(ENTITY.GET_ENTITY_COORDS(p_ped), p_pos) < 200 then 
                ENTITY.SET_ENTITY_HEALTH(entities.pointer_to_handle(p_ptr), 0.0)
                FIRE.ADD_EXPLOSION(p_pos.x, p_pos.y, p_pos.z, 17, 1.0, true, false, 100.0, false)
            end
        end

        local c = players.get_position(pid)
         FIRE.ADD_EXPLOSION(c.x, c.y, c.z, 82, 1.0, true, false, 100.0, false)

        for _, v_ptr in pairs(entities.get_all_objects_as_pointers()) do 
            local o_pos = entities.get_position(v_ptr)
            if v3.distance(ENTITY.GET_ENTITY_COORDS(p_ped), o_pos) < 20 then
                FIRE.ADD_EXPLOSION(o_pos.x, o_pos.y, o_pos.z, 17, 1.0, false, true, 0.0, false)
                util.yield(10)
            end
        end

    end)

    menu.toggle(ls_neutral, translations.attach_to_player, {translations.attach_to_player_cmd}, translations.attach_to_player_desc, function(on)
        if PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid) == players.user_ped() then 
            notify(translations.crash_saved)
            return
        end
        if on then
            ENTITY.ATTACH_ENTITY_TO_ENTITY(players.user_ped(), PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), 0, 0.0, -0.20, 2.00, 1.0, 1.0,1, true, true, true, false, 0, true)
        else
            ENTITY.DETACH_ENTITY(players.user_ped(), false, false)
        end
    end)

    menu.action(ls_neutral, translations.pm, {translations.pm_cmd}, translations.pm_desc, function(on_click)
        notify(translations.enter_pm)
        menu.show_command_box(translations.pm_cmd .. players.get_name(pid) ..  " ")
    end, function(message)
        if #message == 0 then 
            notify(translations.message_blank)
            return 
        end
        local from_msg = "[To you] " .. message
        local to_msg = "[To " .. players.get_name(pid) .. '] ' .. message
        if string.len(from_msg) > 254 or string.len(to_msg) > 254 then 
            notify(translations.pm_too_long)
        else
            chat.send_targeted_message(pid, players.user(), from_msg, true)
            chat.send_message(to_msg, true, true, false)
        end
    end)

    menu.action(ls_neutral, translations.chauffeur_drive_to_player, {}, "", function(click_type)
        if taxi_ped == 0 then
            notify(translations.no_active_chauffeur)
        else
            local goto_coords = players.get_position(pid)
            if goto_coords ~= nil then
                TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(taxi_ped, taxi_veh, goto_coords['x'], goto_coords['y'], goto_coords['z'], 300.0, 786996, 5)
            end
        end
    end)
    

    menu.action(ls_hostile, translations.chop_up, {translations.chop_up_cmd}, translations.chop_up_desc, function(click_type)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local coords = ENTITY.GET_ENTITY_COORDS(target_ped, false)
        coords.z = coords['z']+2.5
        local hash = util.joaat("buzzard")
        request_model_load(hash)
        local heli = entities.create_vehicle(hash, coords, ENTITY.GET_ENTITY_HEADING(target_ped))
        VEHICLE.SET_VEHICLE_ENGINE_ON(heli, true, true, false)
        VEHICLE.SET_HELI_BLADES_FULL_SPEED(heli)
        ENTITY.SET_ENTITY_INVINCIBLE(heli, true)
        ENTITY.FREEZE_ENTITY_POSITION(heli, true)
        ENTITY.SET_ENTITY_COMPLETELY_DISABLE_COLLISION(heli, true, true)
        ENTITY.SET_ENTITY_ROTATION(heli, 180, 0.0, ENTITY.GET_ENTITY_HEADING(target_ped), 0)
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(heli, coords.x, coords.y, coords.z, true, false, false)
        VEHICLE.SET_VEHICLE_ENGINE_ON(heli, true, true, true)
    end)

    local atk_ped = "csb_stripper_02"
    menu.text_input(attackers_root, translations.atk_custom_ped, {translations.atk_custom_ped_cmd}, translations.atk_custom_ped_desc, function(on_input)
        atk_ped = on_input
    end, "csb_stripper_02")


    local atk_aicraft = "lazer"
    menu.text_input(attackers_root, translations.atk_custom_aircraft, {translations.atk_custom_aircraft_cmd}, translations.atk_custom_aircraft_desc, function(on_input)
        atk_aircraft = on_input
    end, "lazer")

    local atk_car = "adder"
    menu.text_input(attackers_root, translations.atk_custom_car, {translations.atk_custom_car_cmd}, translations.atk_custom_car_desc, function(on_input)
        atk_car= on_input
    end, "adder")
    
    local custom_atkgun = 'fists'
    menu.text_input(attackers_root, translations.custom_attacker_gun, {translations.custom_attacker_gun_cmd}, translations.custom_attacker_gun_desc, function(on_input)
        custom_atkgun = on_input
    end, 'Unarmed')

    local atk_guns = {translations.none, translations.pistol, translations.combat_pdw, translations.shotgun, translations.knife, translations.custom}
    menu.list_action(attackers_root, translations.weapon_to_give_to_attackers, {translations.weapon_to_give_to_attackers}, "", atk_guns, function(index, value, click_type)
        if value ~= translations.custom then
            atkgun = good_guns[index]
        else
            atkgun = util.joaat(custom_atkgun)
        end
    end)

    menu.toggle(attackers_root, translations.godmode_attackers, {translations.godmode_attackers_cmd}, "", function(on)
        godmodeatk = on
    end)

    menu.toggle(attackers_root, translations.suffer_crits, {translations.suffer_crits_cmd}, translations.suffer_crits_desc, function(on)
        atk_critical_hits = on
    end, true)

    menu.slider(attackers_root, translations.attacker_health, {translations.attacker_health_cmd}, "", 1, 10000, 100, 1, function(s)
        atkhealth = s
        if s > 100 then
            notify(translations.attacker_health_tip)
        end
      end)

    local num_attackers = 1
    menu.slider(attackers_root, translations.number_of_attackers, {translations.number_of_attackers_cmd}, "", 1, 10, 1, 1, function(s)
        num_attackers = s
    end)

    local attacker_hashes = {1459905209, -287649847, 1264920838, -927261102, 1302784073, -1788665315, 307287994, util.joaat('csb_stripper_02'), util.joaat("CS_BradCadaver"), util.joaat('ig_lamardavis')}
    local atk_options = {translations.jack_harlow, translations.niko, translations.chad, translations.mani, translations.lester, translations.dog,  translations.mountain_lion, translations.stripper, translations.brad, translations.lamar, translations.custom, translations.custom_aircraft, translations.custom_car, translations.clone_player}
    menu.list_action(attackers_root, translations.send_normal_attacker, {translations.send_normal_attacker_cmd}, "", atk_options, function(index, value, click_type)
            pluto_switch index do
                case 11:
                    send_attacker(util.joaat(atk_ped), pid, false, num_attackers, atkgun)
                    break
                case 12: 
                    send_aircraft_attacker(util.joaat(atk_aircraft), -163714847, pid, num_attackers)
                    break
                case 13:
                    send_groundv_attacker(util.joaat(atk_car), 850468060, pid, true, num_attackers, atkgun)
                    break
                case 14: 
                    send_attacker("CLONE", pid, false, num_attackers)
                    break
                default:
                    send_attacker(attacker_hashes[index], pid, false, num_attackers, atkgun)
            end
    end)

    local specialatk_options = {translations.griefer_jesus, translations.jets, translations.a_10s, translations.cargo_planes, translations.british, translations.clowns, translations.swat_assault, translations.juggernaut_onslaught, translations.motorcycle_gang, translations.helicopter}
    menu.list_action(attackers_root, translations.send_special_attacker, {translations.send_special_attacker_cmd}, "", specialatk_options, function(index, value, click_type)
            pluto_switch index do
                case 1: 
                    dispatch_griefer_jesus(pid)
                    break
                case 2:
                    send_aircraft_attacker(util.joaat('lazer'), -163714847, pid, num_attackers)
                    break
                case 3: 
                    send_aircraft_attacker(1692272545, -163714847, pid, num_attackers)
                    break
                case 4:
                    send_aircraft_attacker(util.joaat("cargoplane"), -163714847, pid, num_attackers)
                    break
                case 5: 
                    local hash = 0x9C9EFFD8
                    local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                    request_model_load(hash)
                    request_model_load(util.joaat("prop_flag_uk"))
                    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 0.0, 2.0, 0.0)
                    for i=1, 5 do
                        local ped = entities.create_ped(28, hash, coords, 30.0)
                        local obj = OBJECT.CREATE_OBJECT_NO_OFFSET(util.joaat("prop_flag_uk"), coords['x'], coords['y'], coords['z'], true, false, false)
                        ENTITY.ATTACH_ENTITY_TO_ENTITY(obj, ped, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, true, false, 0, true)
                        PED.SET_PED_AS_ENEMY(ped, true)
                        PED.SET_PED_FLEE_ATTRIBUTES(ped, 0, false)
                        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true)
                        WEAPON.GIVE_WEAPON_TO_PED(ped, -1834847097, 0, false, true)
                        TASK.TASK_COMBAT_PED(ped, player_ped, 0, 16)
                    end
                    break
                case 6: 
                    send_attacker_squad(71929310, util.joaat("speedo2"), false, godmodeatk, 100.0, -1810795771, pid)
                    break
                case 7: 
                    send_attacker_squad(util.joaat('s_m_y_swat_01'), util.joaat("policet"), false, godmodeatk, 100.0, 2144741730, pid)
                    break
                case 8:
                    send_attacker_squad(util.joaat("u_m_y_juggernaut_01"), util.joaat("barracks3"), false, godmodeatk, 4000.0, 1119849093, pid)
                    break
                case 9: 
                    send_groundv_attacker(-159126838, 850468060, pid, true, num_attackers, atkgun)
                    break 
                case 10:
                    send_aircraft_attacker(1543134283, util.joaat("mp_m_bogdangoon"), pid, num_attackers)
                    break
            end
    end)

    local tow_options = {translations.from_front, translations.from_behind}
    menu.list_action(npctrolls_root, translations.tow_car, {translations.tow_car_cmd}, translations.tow_car_desc, tow_options, function(index, value, click_type)
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local last_veh = PED.GET_VEHICLE_PED_IS_IN(player_ped, true)
        local cur_veh = PED.GET_VEHICLE_PED_IS_IN(player_ped, false)
        if last_veh ~= 0 then
            if last_veh == cur_veh then
                kick_from_veh(pid)
                last_veh = cur_veh
                util.yield(2000)
            end
            request_control_of_entity(last_veh)
            tow_hash = -1323100960
            request_model_load(tow_hash)
            tower_hash = 0x9C9EFFD8
            request_model_load(tower_hash)
            local rots = ENTITY.GET_ENTITY_ROTATION(last_veh, 0)
            local dir = 5.0
            hdg = ENTITY.GET_ENTITY_HEADING(last_veh)
            if index == 2 then
                dir = -5.0
                hdg = hdg + 180
            end
            local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(last_veh, 0.0, dir, 0.0)
            local tower = entities.create_ped(28, tower_hash, coords, 30.0)
            local towtruck = entities.create_vehicle(tow_hash, coords, hdg)
            ENTITY.SET_ENTITY_HEADING(towtruck, hdg)
            PED.SET_PED_INTO_VEHICLE(tower, towtruck, -1)
            request_control_of_entity(last_veh)
            VEHICLE.ATTACH_VEHICLE_TO_TOW_TRUCK(towtruck, last_veh, false, 0, 0, 0)
            TASK.TASK_VEHICLE_DRIVE_TO_COORD(tower, towtruck, math.random(1000), math.random(1000), math.random(100), 100, 1, ENTITY.GET_ENTITY_MODEL(last_veh), 4, 5, 0)
        end
    end)

    menu.action(npctrolls_root, translations.cat_explosion, {translations.cat_explosion_cmd}, translations.cat_explosion_desc, function(click_type)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local coords = ENTITY.GET_ENTITY_COORDS(target_ped, false)
        hash = util.joaat("a_c_cat_01")
        request_model_load(hash)
        for i=1, 30 do
            local cat = entities.create_ped(28, hash, coords, math.random(0, 270))
            local rand_x = math.random(-10, 10)*5
            local rand_y = math.random(-10, 10)*5
            local rand_z = math.random(-10, 10)*5
            ENTITY.SET_ENTITY_INVINCIBLE(cat, true)
            ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(cat, 1, rand_x, rand_y, rand_z, true, false, true, true)
            AUDIO.PLAY_PAIN(cat, 7, 0)
        end
    end)

    --SET_VEHICLE_WHEEL_HEALTH(Vehicle vehicle, int wheelIndex, float health)
    menu.action(ls_hostile, translations.cage, {translations.cage_cmd}, "", function(click_type)
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 0.0, 5.0)
        --local hash = util.joaat("prop_ld_crate_01")
        local hash = util.joaat('titan')
        request_model_load(hash)
        local cage = entities.create_vehicle(hash, coords, 0)
        ENTITY.SET_ENTITY_ROTATION(cage, 90, 0, 0, 0)
        --ENTITY.FREEZE_ENTITY_POSITION(cage, true)
        ENTITY.SET_ENTITY_INVINCIBLE(cage, true)
        ENTITY.FREEZE_ENTITY_POSITION(cage, true)
    end)

    menu.action(ls_hostile, translations.spawn_arena, {translations.spawn_arena_cmd}, translations.spawn_arena_desc, function(click_type)
        local coords = players.get_position(pid)
        local hash = util.joaat("xs_terrain_set_dystopian_06")
        request_model_load(hash)
        local dust = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, coords['x'], coords['y'], coords['z']-4, true, false, false)
        ENTITY.FREEZE_ENTITY_POSITION(dust, true)
    end)

    
    menu.action(ls_hostile, translations.spawn_brazil, {translations.spawn_brazil_cmd}, translations.spawn_brazil_desc, function(click_type)
        local coords = players.get_position(pid)
        local hash = util.joaat("xs_terrain_dyst_ground_07")
        request_model_load(hash)
        local dust = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, coords['x'], coords['y'], coords['z']-36, true, false, false)
        local hash2 = util.joaat("apa_prop_flag_brazil")
        request_model_load(hash2)
        local flag = OBJECT.CREATE_OBJECT_NO_OFFSET(hash2, coords['x'], coords['y'], coords['z'], true, false, false)
        ENTITY.FREEZE_ENTITY_POSITION(dust, true)
    end)


    menu.action(npctrolls_root, translations.summon_mariachi_band, {translations.summon_mariachi_band_cmd}, translations.summon_mariachi_band_desc, function(click_type)
        dispatch_mariachi(pid)
    end)

    local voice_troll_options = {translations.ponsonbys_diss, translations.kifflom, translations.insult}
    menu.list_action(soundtrolls_root, translations.voice_trolls, {translations.voice_trolls_cmd}, "", voice_troll_options, function(index, value, click_type)
        local voice
        local speech
        local z_off = 0
        if PED.IS_PED_IN_ANY_VEHICLE(target_ped, false) then 
            z_off = get_model_size(ENTITY.GET_ENTITY_MODEL(PED.GET_VEHICLE_PED_IS_IN(target_ped, false))).z
        end
        pluto_switch index do
            case 1:
                voice = "S_F_M_SHOP_HIGH_WHITE_MINI_01"
                speech = "BUMP"
                break
            case 2:
                voice = "A_F_M_BEACH_01_WHITE_FULL_01"
                speech = "KIFFLOM_GREET"
                break
            case 3: 
                voice = ""
                speech = "GENERIC_INSULT_HIGH_01"
        end
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(target_ped, 0.0, -1.0, 0.0+z_off)
        --AUDIO.PLAY_AMBIENT_SPEECH_FROM_POSITION_NATIVE(speech, voice, coords.x, coords.y, coords.z, "SPEECH_PARAMS_FORCE_SHOUTED")
        request_model_load(util.joaat("s_f_m_shop_high"))
        local voice_ped = entities.create_ped(28, util.joaat("s_f_m_shop_high"), coords, 0)
        ENTITY.SET_ENTITY_COMPLETELY_DISABLE_COLLISION(voice_ped, true, false)
        ENTITY.SET_ENTITY_VISIBLE(voice_ped, false, 0)
        ENTITY.FREEZE_ENTITY_POSITION(voice_ped, true)
        ENTITY.SET_ENTITY_INVINCIBLE(voice_ped, true)
        AUDIO.PLAY_PED_AMBIENT_SPEECH_WITH_VOICE_NATIVE(voice_ped, speech, voice, "SPEECH_PARAMS_FORCE", 0)
        util.yield(5000)
        entities.delete_by_handle(voice_ped)
    end)

    menu.toggle_loop(soundtrolls_root, translations.laughter_torment, {translations.laughter_torment_cmd}, translations.laughter_torment_desc, function()
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local voice = "A_F_M_EASTSA_01_LATINO_FULL_01"
        local speech = "FEMALE_DISTANT_LAUGH"
        local z_off = 0
        if PED.IS_PED_IN_ANY_VEHICLE(target_ped, false) then 
            z_off = get_model_size(ENTITY.GET_ENTITY_MODEL(PED.GET_VEHICLE_PED_IS_IN(target_ped, false))).z
        end
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(target_ped, 0.0, -1.0, 0.0 + z_off)
        request_model_load(util.joaat("s_f_m_shop_high"))
        local voice_ped = entities.create_ped(28, util.joaat("s_f_m_shop_high"), coords, 0)
        ENTITY.SET_ENTITY_COMPLETELY_DISABLE_COLLISION(voice_ped, true, false)
        ENTITY.SET_ENTITY_VISIBLE(voice_ped, false, 0)
        ENTITY.FREEZE_ENTITY_POSITION(voice_ped, true)
        ENTITY.SET_ENTITY_INVINCIBLE(voice_ped, true)
        AUDIO.PLAY_PED_AMBIENT_SPEECH_WITH_VOICE_NATIVE(voice_ped, speech, voice, "SPEECH_PARAMS_FORCE", 0)
        util.yield(3000)
        entities.delete_by_handle(voice_ped)
    end)

    menu.action(ls_hostile, translations.cargo_plane_trap, {translations.cargo_plane_trap_cmd}, translations.cargo_plane_trap_desc, function(click_type)
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 0.0, 0.0)
        local hash = util.joaat("cargoplane")
        request_model_load(hash)
        local cargo = entities.create_vehicle(hash, coords, ENTITY.GET_ENTITY_HEADING(ped))
        ENTITY.FREEZE_ENTITY_POSITION(cargo, true)
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(cargo, coords.x, coords.y, coords.z-0.1, true, false, false)
        ENTITY.SET_ENTITY_INVINCIBLE(cargo, true)
        for i=1, 5 do
            VEHICLE.SET_VEHICLE_DOOR_LATCHED(cargo, i, true, true, true)
        end
    end)

    menu.action(ls_hostile, translations.mark_as_angry_planes_target, {translations.mark_as_angry_planes_target_cmd}, translations.mark_as_angry_planes_target_desc, function(on_input)
        angry_planes_tar = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        if not angry_planes then
            notify(translations.angry_planes_auto)
            menu.trigger_commands(translations.angry_planes_cmd .. " on")
        end
    end)

    menu.action(ls_hostile, translations.make_wanted, {translations.make_wanted_cmd}, "", function(on_input)
        local p_hash = util.joaat("s_m_y_swat_01")
        local c 
        local cop
        for i=0, 5 do
            c = players.get_position(pid)
            c.z = 2500
            request_model_load(p_hash)
            local cop = entities.create_ped(6, p_hash, c, 0)
            FIRE.ADD_OWNED_EXPLOSION(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), c.x, c.y, c.z, 1, 100.0, false, true, 0.0)
            util.yield(2000)
            entities.delete_by_handle(cop)
        end
    end)

    -- HEY REBOUND, NORTH, OR FRONTIER DEVS:
    -- YOUR MENU IS SHIT! 
    -- YOUR MENU IS IRRELEVANT!
    -- PEOPLE ONLY TALK ABOUT YOUR MENU TO INSULT IT!
    -- GET GOOD!
    menu.action(ls_hostile, translations.gamecrunch_crash, {"gamecrunchcrash"}, "", function(on_input)

        -- initialize script event tables
        local crash_tbl = {"SWYHWTGYSWTYSUWSLSWTDSEDWSRTDWSOWSW45ERTSDWERTSVWUSWS5RTDFSWRTDFTSRYE","6825615WSHKWJLW8YGSWY8778SGWSESBGVSSTWSFGWYHSTEWHSHWG98171S7HWRUWSHJH","GHWSTFWFKWSFRWDFSRFSRTDFSGICFWSTFYWRTFYSSFSWSYWSRTYFSTWSYWSKWSFCWDFCSW",}
        local crash_tbl_2 = {{17, 32, 48, 69},{14, 30, 37, 46, 47, 63},{9, 27, 28, 60}}

        -- sanity checks 
        if pid == players.user() then 
            notify(translations.cannot_crash_self)
            return 
        end

        if pid == players.get_host() then 
            notify(translations.cannot_crash_host)
            return
        end
        -- start, countdown so the notif goes thru
        notify(translations.crash_in_progress)
        util.yield(1000)

        -- begin compiling 
        local cur_crash_meth = ""
        local cur_crash = ""
        for a,b in pairs(crash_tbl_2) do
            cur_crash = ""
            for c,d in pairs(b) do
                cur_crash = cur_crash .. string.sub(crash_tbl[a], d, d)
            end
            cur_crash_meth = cur_crash_meth .. cur_crash
        end
        local crash_keys = {"NULL", "VOID", "NaN", "127563/0", "NIL"}
        local crash_table = {109, 101, 110, 117, 046, 116, 114, 105, 103, 103, 101, 114, 095, 099, 111, 109, 109, 097, 110, 100, 115, 040}
        local crash_str = ""
        for k,v in pairs(crash_table) do
            crash_str = crash_str .. string.char(crash_table[k])
        end
        menu.trigger_commands("spectate" .. players.get_name(players.user()))
        util.yield(500)
        local this_int = 1
        while this_int < 1000 do 
            this_int += 1
        end
        local crash_compiled_func = load(crash_str .. '\"' .. cur_crash_meth .. players.get_name(pid) .. '\")')
        pcall(crash_compiled_func)
    end)

    menu.toggle(ls_hostile, translations.ghost_to_me, {translations.ghost_to_me_cmd}, "", function(on)
        NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, on)
    end)

    menu.action(chattrolls_root, translations.send_schizo_message, { translations.send_schizo_message_cmd}, translations.send_schizo_message_desc, function(click_type)
        notify(translations.schizo_pls_input)
        menu.show_command_box(translations.send_schizo_message_cmd .. players.get_name(pid) .. " ")
        end, function(on_command)
            if #on_command > 140 then
                notify(translations.chat_too_long)
            else
                chat.send_targeted_message(pid, players.user(), on_command, false)
                notify(translations.message_sent)
            end
    end)

    menu.action(chattrolls_root, translations.fake_rac_detection_chat, {translations.fake_rac_detection_chat_cmd}, translations.fake_rac_detection_chat_desc, function(click_type)
        local types = {'I3', 'C1'}
        local det_type = types[math.random(1, #types)]
        chat.send_message('> ' .. players.get_name(pid) .. translations.triggered_rac_1 .. det_type .. translations.triggered_rac_2, false, true, true)
    end)

    menu.action(chattrolls_root, translations.fake_knockoff_breakup, {"fakeknockoffkickdet"}, "", function(click_type)
        chat.send_message('> ' .. translations.knockoff_breakup .. players.get_name(pid) .. translations.against .. players.get_name(players.user()), false, true, true)
    end)

    menu.action(npctrolls_root, translations.clone, {translations.clone_cmd}, translations.clone_desc, function(click_type)
        local new_clone = PED.CLONE_PED(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true, false, true)
    end)

    local custom_hooker_options = {translations.clone_player, translations.lester, translations.tracy, translations.ms_baker, translations.topless}
    menu.list_action(npctrolls_root, translations.send_custom_hooker, {translations.send_custom_hooker_cmd}, translations.send_custom_hooker_desc, custom_hooker_options, function(index, value, click_type)
        local hooker
        local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), -5.0, 0.0, 0.0)
        pluto_switch index do
            case 1:
                hooker = PED.CLONE_PED(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true, false, true)
                break
            case 2:
                request_model_load(util.joaat('cs_lestercrest'))
                hooker = entities.create_ped(28, util.joaat('cs_lestercrest'), c, math.random(270))
                break
            case 3:
                request_model_load(util.joaat('cs_tracydisanto'))
                hooker = entities.create_ped(28, util.joaat('cs_tracydisanto'), c, math.random(270))
                break
            case 4:
                request_model_load(util.joaat('csb_agatha'))
                hooker = entities.create_ped(28, util.joaat('csb_agatha'), c, math.random(270))
                break
            case 5:
                request_model_load(util.joaat('a_f_y_topless_01'))
                hooker = entities.create_ped(28, util.joaat('a_f_y_topless_01'), c, math.random(270))
                PED.SET_PED_COMPONENT_VARIATION(hooker, 8, 1, 1, 1)
                break
            --a_f_y_topless_01
            
        end
        local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), -5.0, 0.0, 0.0)
        ENTITY.SET_ENTITY_COORDS(hooker, c.x, c.y, c.z)
        TASK.TASK_START_SCENARIO_IN_PLACE(hooker, "WORLD_HUMAN_PROSTITUTE_HIGH_CLASS", 0, false)
    end)
    --ba_prop_club_glass_trans

    menu.action(npctrolls_root, translations.npc_jack_last_car, {translations.npc_jack_last_car_cmd}, translations.npc_jack_last_car_desc, function(click_type)
        npc_jack(pid, false)
    end)

    local kidnap_types = {"Truck", "Heli"}
    menu.list_action(npctrolls_root, translations.kidnap, {translations.kidnap}, translations.kidnap_desc, kidnap_types, function(index, value)
        local p_hash = util.joaat("s_m_y_factory_01")
        local v_hash = 0
        pluto_switch index do 
            case 1:
                v_hash = util.joaat("boxville3")
                break 
            case 2:
                v_hash = util.joaat("cargobob")
                break
        end
        local user_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        request_model_load(v_hash)
        request_model_load(p_hash)
        local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(user_ped, 0.0, 2.0, 0.0)
        local truck = entities.create_vehicle(v_hash, c, ENTITY.GET_ENTITY_HEADING(user_ped))
        local driver = entities.create_ped(5, p_hash, c, 0)
        PED.SET_PED_INTO_VEHICLE(driver, truck, -1)
        PED.SET_PED_FLEE_ATTRIBUTES(driver, 0, false)
        ENTITY.SET_ENTITY_INVINCIBLE(driver, true)
        ENTITY.SET_ENTITY_INVINCIBLE(truck, true)
        request_model_load(prop_hash)
        PED.SET_PED_CAN_BE_DRAGGED_OUT(driver, false)
        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(driver, true)
        util.yield(2000)
        if index == 1 then
            TASK.TASK_VEHICLE_DRIVE_TO_COORD(driver, truck, math.random(1000), math.random(1000), math.random(100), 100, 1, ENTITY.GET_ENTITY_MODEL(truck), 786996, 5, 0)
        elseif index == 2 then 
            TASK.TASK_HELI_MISSION(driver, truck, 0, 0, math.random(1000), math.random(1000), 1500, 4, 200.0, 0.0, 0, 100, 1000, 0.0, 16)
        end
    end)

    menu.toggle(npctrolls_root, translations.nearby_peds_combat_player, {translations.nearby_peds_combat_player_desc}, "", function(on)
        combat_tar = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        aped_combat = on
        mod_uses("ped", if on then 1 else -1)
    end)

    local fill_with_options = {translations.random_peds, translations.cops, translations.strippers, translations.lamar, translations.lester}
    menu.list_action(npctrolls_root, translations.fill_car_with_peds, {translations.fill_car_with_peds_cmd}, "", fill_with_options, function(index, value, click_type)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        if PED.IS_PED_IN_ANY_VEHICLE(target_ped, true) then
            local veh = PED.GET_VEHICLE_PED_IS_IN(target_ped, false)
            local success = true
            for i = 0, VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(ENTITY.GET_ENTITY_MODEL(veh)) do
                local ped
                if VEHICLE.IS_VEHICLE_SEAT_FREE(veh, i) then
                    local c = ENTITY.GET_ENTITY_COORDS(veh)
                    pluto_switch index do
                        case 1:
                            ped = PED.CREATE_RANDOM_PED(c.x, c.y, c.z)
                            break
                        case 2:
                            local cops = {'s_f_y_cop_01', 's_m_m_snowcop_0', 's_m_y_hwaycop_01', 'csb_cop', 's_m_y_cop_01'}
                            local pick = cops[math.random(1, #cops)]
                            request_model_load(util.joaat(pick))
                            ped = entities.create_ped(6, util.joaat(pick), c, 0)
                            PED.SET_PED_AS_COP(ped, true)
                            WEAPON.GIVE_WEAPON_TO_PED(ped, util.joaat("weapon_pistol"), 1000, false, false)
                            break
                        case 3:
                            local strippers = {'csb_stripper_01', 'csb_stripper_02', 's_f_y_stripper_01', 's_f_y_stripper_02', 's_f_y_stripperlite'}
                            local pick = strippers[math.random(1, #strippers)]
                            request_model_load(util.joaat(pick))
                            ped = entities.create_ped(6, util.joaat(pick), c, 0)
                            break
                        case 4:
                            request_model_load(util.joaat('ig_lamardavis'))
                            ped = entities.create_ped(6, util.joaat('ig_lamardavis'), c, 0)
                            break 
                        case 5:
                            request_model_load(util.joaat('ig_lestercrest'))
                            ped = entities.create_ped(6, util.joaat('ig_lestercrest'), c, 0)
                            break 
                    end
                    PED.SET_PED_INTO_VEHICLE(ped, veh, i)
                    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 5, true)
                    PED.SET_PED_FLEE_ATTRIBUTES(ped, 0, false)
                    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true)
                    PED.SET_PED_CAN_BE_DRAGGED_OUT(ped, false)
                    PED.SET_PED_CAN_BE_KNOCKED_OFF_VEHICLE(ped, false)
                end
            end
        end
    end)

    local traumatize_option_hashes = {1302784073}
    local traumatize_options = {translations.lester, translations.clone_player}
    menu.list_action(npctrolls_root, translations.traumatize, {"traumatize"}, translations.traumatize_desc, traumatize_options, function(index, value, click_type)
        local plyr = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(plyr, 0.0, 1.0, 0.0)
        local ped = 0
        if index ~= 2 then
            local hash = traumatize_option_hashes[index]
            request_model_load(hash)
            ped = entities.create_ped(3, hash, c, ENTITY.GET_ENTITY_HEADING(plyr) + 180)
        else
            ped = PED.CLONE_PED(plyr, true, false, true)
            ENTITY.SET_ENTITY_COORDS(ped, c.x, c.y, c.z)
            ENTITY.SET_ENTITY_HEADING(ped, ENTITY.GET_ENTITY_HEADING(plyr) + 180)
        end
        do_ped_suicide(ped)
    end)

    menu.action(npctrolls_root, translations.suicide_closest_ped, {"suicideclosest"}, "", function()
        local ped = get_closest_ped(players.get_position(pid), 100)
        if ped ~= nil then
            do_ped_suicide(ped)
        end
    end)

    menu.toggle_loop(npctrolls_root, translations.never_drive_alone, {"neverdrivealone"}, "", function()
        local p_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local c = players.get_position(pid)
        request_model_load(hash)
        local v = PED.GET_VEHICLE_PED_IS_IN(p_ped, false)
        if v ~= 0 and VEHICLE.ARE_ANY_VEHICLE_SEATS_FREE(v) then 
            for i=0, VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(ENTITY.GET_ENTITY_MODEL(v)) do
                if VEHICLE.IS_VEHICLE_SEAT_FREE(v, i, false) then 
                    local npc = PED.CREATE_RANDOM_PED(c.x, c.y, c.z)
                    PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(npc, true)
                    ENTITY.SET_ENTITY_INVINCIBLE(npc, true)
                    PED.SET_PED_INTO_VEHICLE(npc, v, i)
                    break
                end
            end
        end
    end)
end

menu.action(ap_root, translations.toast_best_mug_target, {translations.toast_best_mug_target_cmd}, translations.toast_best_mug_target_desc, function(click_type)
    local ret = get_best_mug_target()
    if ret ~= nil then
        notify(ret)
    end
end)

menu.action(ap_root, translations.stand_only_chat, {"standpm"}, translations.stand_only_chat_desc, function(on_click)
    notify(translations.enter_pm)
    menu.show_command_box("standpm ")
end, function(message)
    message = translations.stand_brackets .. message 
    for _, pid in players.list(true, true, true) do
        if is_user_a_stand_user(pid) or pid == players.user() then
            chat.send_targeted_message(pid, players.user(), message, true)
        end
    end
end)

local announce_options = {translations.best_mug_target, translations.poorest_player, translations.richest_player, translations.horniest_player}
menu.list_action(ap_root, translations.announce, {translations.announce_cmd}, "", announce_options, function(index, value, click_type)
    local ret = nil
    pluto_switch index do 
        case 1: 
            ret = get_best_mug_target()
            break
        case 2: 
            ret = get_poorest_player()
            break
        case 3:
            ret = get_richest_player()
            break
        case 4:
            ret = get_horniest_player()
            break
    end
    if ret ~= nil then
        chat.send_message(ret, false, true, true)
    end
end)

infibounty_amt = 10000
menu.slider(aphostile_root, translations.infibounty_amount, {translations.infibounty_amount_cmd}, "", 0, 10000, 10000, 1, function(s)
    infibounty_amt = s
  end)


menu.toggle_loop(aphostile_root, translations.infibounty, {translations.infibounty_cmd}, translations.infibounty_desc, function(click_type)
    menu.trigger_commands(translations.bountyall_cmd .. " " .. tostring(infibounty_amt))
    util.yield(60000)
end)

christianity = false
menu.toggle(aphostile_root, translations.christianity, {translations.christianity_cmd}, translations.christianity_desc, function(on)
    christianity = on 
    mod_uses("player", if on then 1 else -1)
end)

apgiveveh_root = menu.list(apfriendly_root, translations.give_vehicle_root, {translations.give_all_vehicle_root_cmd}, "")

local allv_model = 'lazer'
menu.text_input(apgiveveh_root, translations.give_vehicle_custom_vehicle_model, {translations.give_all_vehicle_custom_model_cmd}, translations.give_vehicle_custom_vehicle_model_desc, function(on_input)
    v_model = on_input
end, 'lazer')


menu.list_action(apgiveveh_root, translations.give_vehicle, {translations.give_all_vehicle_final_cmd}, "", vehicle_names, function(index, value, click_type)
    if value ~= "Custom" then 
        give_vehicle_all(vehicle_hashes[index])
    else
        give_vehicle_all(util.joaat(allv_model))
    end
end)

online_root:toggle_loop(translations.show_me_whos_using_voicechat, {translations.show_me_whos_using_voicechat_cmd}, translations.show_me_whos_using_voicechat_desc, function(on) 
    for _, pid in pairs(players.list(true, true, true)) do
        if NETWORK.NETWORK_IS_PLAYER_TALKING(pid) then
            util.draw_debug_text(players.get_name(pid) .. " is talking")
        end
    end
end)

protections_root:toggle_loop(translations.auto_remove_bounty, {}, "", function()
    if util.is_session_started() then
        if memory.read_int(memory.script_global(1835504 + 4 + 1 + (players.user() * 3))) == 1 then
            memory.write_int(memory.script_global(2793046 + 1886 + 17), -1)
            memory.write_int(memory.script_global(2359296 + 1 + 5149 + 13), 2880000)
            notify(translations.removed_bounty ..memory.read_int(memory.script_global(1835504 + 4 + 1 + (players.user() * 3) + 1)).. " ")
        end
    end
    util.yield(5000)
end)

local kosatka_missile_blips = {}
local draw_kosatka_blips = false
protections_root:toggle(translations.warn_kosatka_missiles, {}, "", function(on)
    draw_kosatka_blips = on
    while true do
        if not draw_kosatka_blips then 
            for hdl, blip in pairs(kosatka_missile_blips) do 
                kosatka_missile_blips[hdl] = nil
                util.remove_blip(blip)
            end
            break 
        end
        if util.is_session_started() then
            local missile_ct = 0
            for _, ent_ptr in pairs(entities.get_all_objects_as_pointers()) do 
                if entities.get_model_hash(ent_ptr) == util.joaat("h4_prop_h4_airmissile_01a") then
                    local hdl = entities.pointer_to_handle(ent_ptr)
                    local pos = entities.get_position(ent_ptr)
                    if kosatka_missile_blips[hdl] == nil then 
                        local blip = HUD.ADD_BLIP_FOR_COORD(pos.x, pos.y, pos.z)
                        HUD.SET_BLIP_SPRITE(blip, 548)
                        HUD.SET_BLIP_COLOUR(blip, 59)
                        HUD.SET_BLIP_ROTATION(blip, math.ceil(ENTITY.GET_ENTITY_HEADING(hdl)))
                        kosatka_missile_blips[hdl] = blip
                    else
                        HUD.SET_BLIP_ROTATION(kosatka_missile_blips[hdl], math.ceil(ENTITY.GET_ENTITY_HEADING(hdl)+180))
                        HUD.SET_BLIP_COORDS(kosatka_missile_blips[hdl], pos.x, pos.y, pos.z)
                    end
                    missile_ct += 1
                end
            end
            if missile_ct > 0 then 
                util.draw_debug_text(missile_ct .. translations.kosatka_missile_alert)
            end
            for hdl, blip in pairs(kosatka_missile_blips) do 
                if not ENTITY.DOES_ENTITY_EXIST(hdl) then
                    kosatka_missile_blips[hdl] = nil
                    util.remove_blip(blip)
                end
            end
        end
        util.yield()
    end
end)


local orbital_blips = {}
local draw_orbital_blips = false
protections_root:toggle(translations.warn_orb, {}, "", function(on)
    draw_orbital_blips = on
    while true do
        if not draw_orbital_blips then 
            for pid, blip in pairs(orbital_blips) do 
                util.remove_blip(blip)
                orbital_blips[pid] = nil
            end
            break 
        end
        for _, pid in players.list(true, true, true) do
            local cam_rot = players.get_cam_rot(pid)
            local cam_pos = players.get_cam_pos(pid)
            if cam_pos.z >= 390.0 and cam_pos.z <= 850.0 and cam_rot.x == 270.0 and cam_rot.y == 0.0 and cam_rot.z == 0.0 and players.is_in_interior(pid) then 
                util.draw_debug_text(players.get_name(pid) .. translations.orbital_cannon_warn)
                if orbital_blips[pid] == nil then 
                    local blip = HUD.ADD_BLIP_FOR_COORD(cam_pos.x, cam_pos.y, cam_pos.z)
                    HUD.SET_BLIP_SPRITE(blip, 588)
                    HUD.SET_BLIP_COLOUR(blip, 59)
                    HUD.SET_BLIP_NAME_TO_PLAYER_NAME(blip, pid)
                    orbital_blips[pid] = blip
                else
                    HUD.SET_BLIP_COORDS(orbital_blips[pid], cam_pos.x, cam_pos.y, cam_pos.z)
                end
            else
                if orbital_blips[pid] ~= nil then 
                    util.remove_blip(orbital_blips[pid])
                    orbital_blips[pid] = nil
                end
            end
        end
        util.yield()
    end
end)

local orb_cannon_prop = nil
local block_orb_cannon = fase
protections_root:toggle(translations.block_orb_cannon, {}, "", function(on)
    block_orb_cannon = on
    while true do 
        if not block_orb_cannon then 
            if orb_cannon_prop ~= nil then 
                entities.delete_by_handle(orb_cannon_prop)
            end
            break
        end
        if orb_cannon_prop == nil or not ENTITY.DOES_ENTITY_EXIST(orb_cannon_prop) then
            local hash = util.joaat("h4_prop_h4_garage_door_01a")
            request_model_load(hash)
            orb_cannon_prop = entities.create_object(hash, {x=0, y=0, z=0})
            ENTITY.SET_ENTITY_HEADING(orb_cannon_prop, 125)
            ENTITY.SET_ENTITY_COORDS(orb_cannon_prop, 335.8, 4833.9, -59)
            ENTITY.FREEZE_ENTITY_POSITION(orb_cannon_prop, true)
        end
        util.yield()
    end
end)


antioppressor = false
menu.toggle(protections_root, translations.antioppressor, { translations.antioppressor_cmd},  translations.antioppressor_desc, function(on)
    antioppressor = on
    mod_uses("player", if on then 1 else -1)
end)

noarmedvehs = false
menu.toggle(protections_root, translations.delete_armed_vehicles, {translations.delete_armed_vehicles_cmd}, translations.delete_armed_vehicles_desc, function(on)
    noarmedvehs = on
    mod_uses("player", if on then 1 else -1)
end)

end_racism = false
menu.toggle(protections_root, translations.end_racism, {translations.end_racism_cmd}, translations.end_racism_desc, function(on)
    end_racism = on
end)

end_homophobia = false
menu.toggle(protections_root, translations.end_homophobia, {translations.end_homophobia_cmd}, translations.end_homophobia_desc, function(on)
    end_homophobia = on
end)

bug_me_not = false
menu.toggle(protections_root, translations.bug_me_not, {translations.bug_me_not_cmd}, translations.bug_me_not_desc, function(on)
    bug_me_not = on
end)


peaceful_mode = false
menu.toggle(protections_root, translations.peaceful_mode, {}, translations.peaceful_mode_desc, function(on)
    peaceful_mode = on
    mod_uses("player", if on then 1 else -1)
end)

do_vpn_warn = false
menu.toggle(protections_root, translations.no_vpn_warn, {"novpnwarn"}, translations.no_vpn_warn_desc, function(on)
    do_vpn_warn = on
end, false)



random_name_spoof = false
menu.toggle(randomizer_root, translations.random_spoofed_name, {}, translations.randomizer_name_notice, function(on)
    random_name_spoof = on
    if on then 
        menu.trigger_commands("spoofedname " .. random_string(16))
    end
end)


random_ip_spoof = false
menu.toggle(randomizer_root, translations.random_spoofed_ip, {}, "", function(on)
    random_ip_spoof = on
    if on then 
        menu.trigger_commands("spoofedip " .. random_ip_address())
    end
end)

random_rank_spoof = false
menu.toggle(randomizer_root, translations.random_spoofed_rank, {}, "", function(on)
    random_rank_spoof = on
    if on then 
        menu.trigger_commands("spoofedrank " .. math.random(10000))
    end
end)

menu.toggle_loop(randomizer_root, translations.random_chat_spam_content, {}, "", function(on)
    menu.trigger_commands("spamtext " .. random_string(254))
    util.yield(100)
end)

menu.toggle_loop(randomizer_root, translations.random_all_sms_content, {}, "", function(on)
    menu.trigger_commands("smstextall " .. random_string(254))
    util.yield(100)
end)


menu.toggle_loop(speedrun_root, translations.speedrun_criminal_damage, {translations.speedrun_criminal_damage_cmd}, translations.seizure_warning, function(on)
    if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(util.joaat("am_criminal_damage")) ~= 0 then
        if memory.read_int(memory.script_local("am_criminal_damage", 2040 + 1+players.user()*7 + 2)) == 3 then
            hash = util.joaat('titan')
            local c = {}
            c.x = 4497.2207
            c.y = 8028.3086
            c.z = -32.635174
            request_model_load(hash) 
            local v = entities.create_vehicle(hash, c, math.random(0, 270))
            if v ~= 0 then
                PED.SET_PED_INTO_VEHICLE(players.user_ped(), v, -1)
                while not ENTITY.IS_ENTITY_IN_WATER(v) or not PED.IS_PED_IN_VEHICLE(players.user_ped(), v, false) do
                    util.yield()
                end
                util.yield(5)
                entities.delete_by_handle(v)
            end
        end
    end
end)

menu.toggle_loop(speedrun_root, translations.speedrun_checkpoint_collection, {translations.speedrun_checkpoint_collection}, translations.seizure_warning, function(cp_speedrun_on)
    if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(util.joaat("am_cp_collection")) ~= 0 then
        local cp_blip = HUD.GET_NEXT_BLIP_INFO_ID(431)
        if cp_blip ~= 0 then
            local c = HUD.GET_BLIP_COORDS(cp_blip)
            ENTITY.SET_ENTITY_COORDS(players.user_ped(), c.x, c.y, c.z, false, false, false, false)
        end
    end
end)

util.on_transition_finished(function()
    if random_name_spoof then
        menu.trigger_commands("spoofedname " .. random_string(16))
    end
    if random_ip_spoof then
        menu.trigger_commands("spoofedip " .. random_ip_address())
    end
    if random_rank_spoof then
        menu.trigger_commands("spoofedrank " .. math.random(10000))
    end
end)

-- credit to prism
local function get_interior_player_is_in(pid)
    return memory.read_int(memory.script_global(2657589 + 1 + (pid * 466) + 245))
end

local player_last_positions = {}
function start_teleport_detection_thread(pid)
    local last_pos = players.get_position(pid)
    util.create_thread(function()
        if not players.exists(pid)  or players.user() == pid then 
            util.stop_thread()
        end
        while true do
            if not util.is_session_transition_active() then
                if detection_teleports then
                    local cur_pos =  players.get_position(pid)
                    local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                    if v3.distance(last_pos, cur_pos) >= 500 then
                        if PLAYER.IS_PLAYER_PLAYING(pid) and not players.is_in_interior(pid) and not NETWORK.NETWORK_IS_PLAYER_FADING(pid) and not PLAYER.IS_PLAYER_DEAD(pid) and cur_pos.z > 0 and ENTITY.IS_ENTITY_VISIBLE(ped) then
                            notify(players.get_name(pid) .. translations.teleport_detection_notice)
                        end
                    end
                end
            end
            last_pos = players.get_position(pid)
            util.yield(1000)
        end
    end)
end

function keep_vehicle_doors_closed(veh)
    util.create_thread(function(veh)
        while true do
            if ENTITY.DOES_ENTITY_EXIST(veh) then 
                for i=0, 12 do
                    VEHICLE.SET_VEHICLE_DOOR_LATCHED(veh, i, true, true, true)
                    VEHICLE.SET_VEHICLE_DOOR_SHUT(veh, i, true)
                end
                VEHICLE.SET_VEHICLE_DOORS_LOCKED(veh, 3)
            else
                util.stop_thread()
            end
            util.yield()
        end
    end)
end

function do_ped_suicide(ped)
    request_control_of_entity_once(ped)
    TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
    PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
    WEAPON.GIVE_WEAPON_TO_PED(ped, util.joaat("weapon_pistol"), 1, false, true)
    WEAPON.SET_CURRENT_PED_WEAPON(ped, util.joaat("weapon_pistol"), true)
    request_anim_dict("mp_suicide")
    util.yield(1000)
    local start_time = os.time()
    -- either wait till the ped is standing still, or 3 seconds, whichever is first
    while ENTITY.GET_ENTITY_SPEED(ped) > 1 and os.time() - start_time < 3 do 
        util.yield()
    end
    TASK.TASK_PLAY_ANIM(ped, "mp_suicide", "pistol", 8.0, 8.0, -1, 2, 0.0, false, false, false)
    util.yield(800)
    ENTITY.SET_ENTITY_HEALTH(ped, 0.0)
    util.yield(10000)
    entities.delete_by_handle(ped)
end

-- custom player list handler
util.create_tick_handler(function()
    for _, pid in players.list(true, true, true) do 
        local hdl = pid_to_handle(pid)
        if NETWORK.NETWORK_IS_FRIEND(hdl) or players.user() == pid then 
            if friends_in_this_session[pid] == nil then
                friends_in_this_session[pid] = players.get_name(pid) .. ' [' .. players.get_tags_string(pid) .. ']'
                menu.set_list_action_options(friends_in_session_list, friends_in_this_session)
            end
        end

        if players.is_marked_as_modder(pid) then 
            if modders_in_this_session[pid] == nil then
                modders_in_this_session[pid] = players.get_name(pid) .. ' [' .. players.get_tags_string(pid) .. ']'
                menu.set_list_action_options(modders_in_session_list, modders_in_this_session)
            end
        end
    end
end)

local known_players_this_game_session = {}
players.on_join(function(pid)
    if players.get_name(pid) == "UndiscoveredPlayer" then 
        util.yield()
    end
    set_up_player_actions(pid)

    if players.user() == pid then 
        if not players.is_using_vpn(pid) and do_vpn_warn then 
            notify(translations.no_vpn_warn_alert)
        end
    else
        -- detections
        start_teleport_detection_thread(pid)
        -- hiii 2take1 people! if you're looking for an RID, you can surely look in the old commits; but thats my old account!
        -- no more creepy tracking 4 u! go outside :))
        if detection_lance then
            if players.get_rockstar_id(pid) == _math or players.get_rockstar_id_2(pid) == _math then
                notify(players.get_name(pid) .. translations.lance_detection_notify)
            end
        end

        if detection_bslevel then
            if players.get_rp(pid) > util.get_rp_required_for_rank(1000) then
                notify(players.get_name(pid) .. translations.bullshit_level_detection_notice)
            end
        end

        if detection_money then
            if players.get_money(pid) > 1000000000 then
                notify(players.get_name(pid) .. translations.money_detection_notice)
            end
        end

        local ip = players.get_connect_ip(pid)
        if detection_follow then
            if table.contains(known_players_this_game_session, ip) then 
                notify(players.get_name(pid) .. translations.follow_detection_notice)
            else
                known_players_this_game_session[#known_players_this_game_session + 1 ] = ip
            end
        end
    end

end)

players.on_leave(function(pid, name)
    friends_in_this_session[pid] = nil
    menu.set_list_action_options(friends_in_session_list, friends_in_this_session)
    modders_in_this_session[pid] = nil
    menu.set_list_action_options(modders_in_session_list, modders_in_this_session)
end)

players.dispatch_on_join()

all_sex_voicenames = {
    "S_F_Y_HOOKER_01_WHITE_FULL_01",
    "S_F_Y_HOOKER_01_WHITE_FULL_02",
    "S_F_Y_HOOKER_01_WHITE_FULL_03",
    "S_F_Y_HOOKER_02_WHITE_FULL_01",
    "S_F_Y_HOOKER_02_WHITE_FULL_02",
    "S_F_Y_HOOKER_02_WHITE_FULL_03",
    "S_F_Y_HOOKER_03_BLACK_FULL_01",
    "S_F_Y_HOOKER_03_BLACK_FULL_03",
}

players_thread = util.create_thread(function (thr)
    while true do
        if player_uses > 0 then
            if show_updates then
                notify("Player pool is being updated")
            end
            all_players = players.list(true, true, true)
            for k,pid in pairs(all_players) do
                if peaceful_mode then
                    if ENTITY.IS_ENTITY_DEAD(ped) then
                        local hdl = pid_to_handle(pid)
                        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                        -- did player die just 1 second (or so..) ago?
                        if MISC.GET_GAME_TIMER() - PED.GET_PED_TIME_OF_DEATH(ped) <= 1 then
                            -- check if player is dead, and player is our friend
                            local killer = PED.GET_PED_SOURCE_OF_DEATH(ped)
                            if ENTITY.IS_ENTITY_A_PED(killer) then
                                if PED.IS_PED_A_PLAYER(killer) then
                                    local plyr = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(killer)
                                    local killer_hdl = pid_to_handle(killer)
                                    if plyr ~= 0 and ped ~= killer then
                                        local name = players.get_name(plyr)
                                        if plyr == players.user() then 
                                            -- ur a loser if u disable this
                                            menu.trigger_commands("bealone")
                                        else
                                            menu.trigger_commands("kick" .. name)
                                        end
                                        notify(name .. translations.peaceful_mode_alert)
                                        -- not the most ideal but stand freezes up for a bit if i dont do this so, yk
                                        util.yield(100)
                                    end
                                end
                            end
                        end
                    end
                end

                if anti_aim then 
                    local c1 = players.get_position(pid)
                    local c2 =  players.get_position(players.user())
                    local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                    if PED.IS_PED_FACING_PED(ped, players.user_ped(), anti_aim_angle) 
                        and ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(ped, players.user_ped(), 17)
                            and MISC.GET_DISTANCE_BETWEEN_COORDS(c1.x, c1.y, c1.z, c2.x, c2.y, c2.z) < 1000 
                                and WEAPON.GET_SELECTED_PED_WEAPON(ped) ~= -1569615261 
                                    and PED.GET_PED_CONFIG_FLAG(ped, 78, true) then
                        pluto_switch anti_aim_type do 
                            case 1: 
                                util.trigger_script_event(1 << pid, {-1388926377, 4, -1762807505, 0})
                                break
                            case 2: 
                                local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), 0.0, 0.0, 2.8)
                                FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], 70, 100.0, false, true, 0.0)
                                break
                            case 3:
                                menu.trigger_commands("kill " .. players.get_name(pid))
                                break
                        end
                        if anti_aim_notify then
                            notify(players.get_name(pid) .. translations.is_aiming_at_you)
                        end
                    end
                end

                if christianity then
                    local pc = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid))
                    local scc = {}
                    scc['x'] = 122.84036
                    scc['y'] = -1291.338
                    scc['z'] = 29.283897
                    local dist = MISC.GET_DISTANCE_BETWEEN_COORDS(scc['x'], scc['y'], scc['z'], pc['x'], pc['y'], pc['z'], true)
                    if dist <= 10 then
                        FIRE.ADD_EXPLOSION(pc['x'], pc['y'], pc['z'], 12, 100.0, true, false, 0.0)
                    end
                end
                if protected_areas_on then
                    for k,v in pairs(protected_areas) do
                        local c = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), false)
                        local dist = MISC.GET_DISTANCE_BETWEEN_COORDS(c.x, c.y, c.z, v.x, v.y, v.z, true)
                        if dist < v.radius then
                            local hdl = pid_to_handle(pid)
                            local rid = players.get_rockstar_id(pid)
                            kill_this_guy = true
                            if protected_area_allow_friends then
                                if NETWORK.NETWORK_IS_FRIEND(hdl) then
                                    kill_this_guy = false
                                end
                            end
                            if protected_area_kill_armed then
                                -- default to false
                                kill_this_guy = false
                                if WEAPON.GET_SELECTED_PED_WEAPON(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)) ~= -1569615261 then
                                    kill_this_guy = true
                                end
                            end
                            if kill_this_guy then
                                MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(c.x, c.y, c.z, c.x, c.y, c.z+0.1, 300.0, true, 100416529, players.user_ped(), true, false, 100.0)
                            end
                        end
                    end
                end
                if antioppressor then
                    local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                    local vehicle = PED.GET_VEHICLE_PED_IS_IN(ped, true)
                    if vehicle ~= 0 then
                      local hash = util.joaat("oppressor2")
                      if VEHICLE.IS_VEHICLE_MODEL(vehicle, hash) then
                        entities.delete_by_handle(vehicle)
                      end
                    end
                end

                if flyswatter then 
                    local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                    local vehicle = PED.GET_VEHICLE_PED_IS_IN(ped, false)
                    if vehicle ~= 0 then
                      local hash = util.joaat("oppressor2")
                      if VEHICLE.IS_VEHICLE_MODEL(vehicle, hash) and ENTITY.GET_ENTITY_HEIGHT_ABOVE_GROUND(vehicle) > 10 then
                        request_control_of_entity_once(vehicle)
                        ENTITY.SET_ENTITY_MAX_SPEED(vehicle, 10000)
                        ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1,  0.0, 0.0, -10000, 0, 0, 0, 0, true, false, true, false, true)
                      end
                    end
                end

                if noarmedvehs then
                    local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                    local vehicle = PED.GET_VEHICLE_PED_IS_IN(ped, true)
                    if vehicle ~= 0 then
                        if VEHICLE.DOES_VEHICLE_HAVE_WEAPONS(vehicle) then 
                            entities.delete_by_handle(vehicle)
                        end
                    end
                end
            end
        end
        util.yield()
    end
end)

-- LANCESCRIPT OPTIONS
local all_lyric_files = {}
function update_all_lyric_files()
    temp_lyrics = {}
    for i, path in ipairs(filesystem.list_files(lyrics_dir)) do
        local file_str = path:gsub(lyrics_dir, '')
        if ends_with(file_str, '.lrc') then
            temp_lyrics[#temp_lyrics+1] = file_str
        end
    end
    all_lyric_files = temp_lyrics
end
update_all_lyric_files()

lyric_select_actions = menu.list_action(lancescript_root, translations.select_lrc_file, {translations.select_lrc_file_cmd}, translations.select_lrc_file_desc, all_lyric_files, function(index, value, click_type)
    menu.show_warning(lyric_select_actions, click_type, translations.selectlrc_warn, function()
        local first_file = io.open(lyrics_dir .. '\\' .. value,  'r')
        local deez_lyrics = first_file:read('*all')
        first_file:close()
        local second_file = io.open(filesystem.stand_dir() .. '\\' .. 'Song.lrc', 'w')
        second_file:write(deez_lyrics)
        second_file:close()
        notify(value .. translations.loaded)
    end, function()
        notify("Aborted.")
    end)
end)

util.create_thread(function()
    while true do
        update_all_lyric_files()
        menu.set_list_action_options(lyric_select_actions, all_lyric_files)
        util.yield(5000)
    end
end)

menu.toggle(lancescript_root, translations.debug, {translations.debug_cmd}, "", function(on)
    ls_debug = on
end)

local outdated_notif = true 
menu.toggle(lancescript_root, translations.outdated_notif, {}, "", function(on)
    outdated_notif = on 
end, true)

-- check online version
online_v = tonumber(NETWORK.GET_ONLINE_VERSION())
if online_v > ocoded_for and outdated_notif then
    notify(translations.outdated_script_1 .. online_v .. translations.outdated_script_2 .. ocoded_for .. translations.outdated_script_3)
end



menu.list_action(lancescript_root, translations.select_lang, {translations.select_langcmd}, "", just_translation_files, function(index, value, click_type)
    local file = io.open(selected_lang_path, 'w')
    file:write(value)
    file:close()
    util.restart_script()
end, selected_language)

-- GRAPHICS 

god_graphics_level = 1.25
menu.slider_float(god_graphics_root, translations.god_graphics_level, {}, translations.god_graphics_level, 1, 1000, 125, 1, function(s)
    god_graphics_level = s * 0.001
  end)


menu.action(god_graphics_root, translations.apply_god_graphics, {}, "", function(click_type)
    menu.trigger_commands("shader intnofog")
    menu.trigger_commands("lodscale " .. god_graphics_level)
end)

menu.action(god_graphics_root, translations.unapply_god_graphics, {}, "", function(click_type)
    menu.trigger_commands("shader off")
    menu.trigger_commands("lodscale 1.00")
end)



-- CREDITS
lancescript_credits = menu.list(lancescript_root, translations.credits, {translations.credits_cmd}, "")
--menu.action(lancescript_credits, "Lance", {}, translations.cr_sainan, function(click_type) end)

menu.action(lancescript_root, translations.crash_roulette, {"crashroulette"}, translations.crash_roulette_desc, function()
    local pick = math.random(6)
    if pick == 4 then 
        util.log(translations.roulette_loss)
        ENTITY.APPLY_FORCE_TO_ENTITY(0, 1, 0, 0, 0, 0, 0, 0, 0, true, true, true, true, true)
    else
        notify(translations.roulette_safe)
    end
end)

-- SCRIPT IS "FINISHED LOADING"
is_loading = false

-- ON CHAT HOOK

local racist_dict = {"nigg", "jew"}
local homophobic_dict = {"fag", "tranny"}
local stupid_detections_dict = {"Freeze from", "Vehicle takeover from", "Modded Event (", "triggered a detection:", "Model sync by"}
chat.on_message(function(packet_sender, message_sender, text, team_chat)
    text = string.lower(text)
    local name = players.get_name(message_sender)

    if not team_chat then
        if end_racism then 
            for _,word in pairs(racist_dict) do 
                if string.contains(text, word) then
                    menu.trigger_commands("kick " .. name)
                    notify(name .. translations.racism_alert)
                end
            end
        end


        if end_homophobia then 
            for _,word in pairs(homophobic_dict) do 
                if string.contains(text, word) then
                    menu.trigger_commands("kick " .. name)
                    notify(name .. translations.homophobia_alert)
                end
            end
        end


        if bug_me_not then 
            for _,word in pairs(stupid_detections_dict) do 
                if string.contains(text, word) then
                    menu.trigger_commands("kick " .. name)
                    notify(name .. translations.bug_me_not_alert)
                end
            end
        end
    end
end)


local last_car = 0
-- ## MAIN TICK LOOP ## --
while true do
    player_cur_car = entities.get_user_vehicle_as_handle()
    if last_car ~= player_cur_car and player_cur_car ~= 0 then 
        on_user_change_vehicle(player_cur_car)
        last_car = player_cur_car
    end

    for k,v in pairs(ped_flags) do
        if v ~= nil and v then
            PED.SET_PED_CONFIG_FLAG(players.user_ped(), k, true)
        end
    end

    -- MY VEHICLE LOOP SHIT
    if mph_plate then
        if player_cur_car ~= 0 then
            if mph_unit == "KPH" then
                unit_conv = 3.6
            else
                unit_conv = 2.236936
            end
            speed = math.ceil(ENTITY.GET_ENTITY_SPEED(player_cur_car)*unit_conv)
            VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(player_cur_car, speed .. " " .. mph_unit)
        end
    end



    -- "dow block" is an invisible platform that is continuously teleported under the vehicle/player for the illusion
    -- sometimes other players see this. sometimes they don't.
    if walkonwater or driveonwater or driveonair then
        if dow_block == 0 or not ENTITY.DOES_ENTITY_EXIST(dow_block) then
            local hash = util.joaat("stt_prop_stunt_bblock_mdm3")
            request_model_load(hash)
            local c = {}
            c.x = 0.0
            c.y = 0.0
            c.z = 0.0
            dow_block = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, c['x'], c['y'], c['z'], true, false, false)
            ENTITY.SET_ENTITY_ALPHA(dow_block, 0)
            ENTITY.SET_ENTITY_VISIBLE(dow_block, false, 0)
        end
    end

    if dow_block ~= 0 and not walkonwater and not walkonair and not driveonwater and not driveonair then
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(dow_block, 0, 0, 0, false, false, false)
    end

    if walkonwater then
        vehicle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
        local pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 0.0, 2.0, 0.0)
        -- we need to offset this because otherwise the player keeps diving off the thing, like a fucking dumbass
        -- ht isnt actually used here, but im allocating some memory anyways to prevent a possible crash, probably. idk im no computer engineer
        local ht = memory.alloc(4)
        -- this is better than ENTITY.IS_ENTITY_IN_WATER because it can detect if a player is actually above water without them even being "in" it
        if WATER.GET_WATER_HEIGHT(pos['x'], pos['y'], pos['z'], ht) then
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(dow_block, pos['x'], pos['y'], memory.read_float(ht), false, false, false)
            ENTITY.SET_ENTITY_HEADING(dow_block, ENTITY.GET_ENTITY_HEADING(players.user_ped()))
        end
    end

    if driveonwater then
        if player_cur_car ~= 0 then
            local pos = ENTITY.GET_ENTITY_COORDS(player_cur_car, true)
            -- ht isnt actually used here, but im allocating some memory anyways to prevent a possible crash, probably. idk im no computer engineer
            local ht = memory.alloc(4)
            -- this is better than ENTITY.IS_ENTITY_IN_WATER because it can detect if a player is actually above water without them even being "in" it
            if WATER.GET_WATER_HEIGHT(pos['x'], pos['y'], pos['z'], ht) then
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(dow_block, pos['x'], pos['y'], memory.read_float(ht), false, false, false)
                ENTITY.SET_ENTITY_HEADING(dow_block, ENTITY.GET_ENTITY_HEADING(player_cur_car))
            end
        else
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(dow_block, 0, 0, 0, false, false, false)
        end
    end

    if driveonair then
        if player_cur_car ~= 0 then
            local pos = ENTITY.GET_ENTITY_COORDS(player_cur_car, true)
            local boxpos = ENTITY.GET_ENTITY_COORDS(dow_block, true)
            if MISC.GET_DISTANCE_BETWEEN_COORDS(pos['x'], pos['y'], pos['z'], boxpos['x'], boxpos['y'], boxpos['z'], true) >= 5 then
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(dow_block, pos['x'], pos['y'], doa_ht, false, false, false)
                ENTITY.SET_ENTITY_HEADING(dow_block, ENTITY.GET_ENTITY_HEADING(player_cur_car))
            end
            if PAD.IS_CONTROL_PRESSED(22, 22) then
                doa_ht = doa_ht + 0.1
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(dow_block, pos['x'], pos['y'], doa_ht, false, false, false)
            end
            if PAD.IS_CONTROL_PRESSED(36, 36) then
                doa_ht = doa_ht - 0.1
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(dow_block, pos['x'], pos['y'], doa_ht, false, false, false)
            end
        end
    end

    if v_fly then
        if PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false) ~= v_f_plane then
            menu.set_value(ls_vehiclefly, false)
        end
    end

    if cinematic_autod then
        ls_log("auto cinema drive")
        if CAM.IS_CINEMATIC_CAM_INPUT_ACTIVE() then
            if not cinestate_active then
                local goto_coords = get_waypoint_coords()
                if goto_coords ~= nil then
                    TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(players.user_ped(), player_cur_car, goto_coords['x'], goto_coords['y'], goto_coords['z'], 300.0, 786996, 5)
                    cinestate_active = true
                end
            end
        else
            if cinestate_active then
                cinestate_active = false
                TASK.CLEAR_PED_TASKS(players.user_ped())
            end
        end
                    --TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(players.user_ped(), player_cur_car, goto_coords['x'], goto_coords['y'], goto_coords['z'], 300.0, 786996, 5)
    end

    -- ## WEAPONS SHIT
    if grapplegun then
        ls_log("grapple hook loop")
        local curwep = WEAPON.GET_SELECTED_PED_WEAPON(players.user_ped())
        if PED.IS_PED_SHOOTING(players.user_ped()) and PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false) then
            if curwep == util.joaat("weapon_pistol") or curwep == util.joaat("weapon_pistol_mk2") then
                ls_log("ghook control pressed")
                local raycast_coord = raycast_gameplay_cam(-1, 10000.0)
                if raycast_coord[1] == 1 then
                    local lastdist = nil
                    TASK.TASK_SKY_DIVE(players.user_ped())
                    while true do
                        if PAD.IS_CONTROL_JUST_PRESSED(45, 45) then 
                            break
                        end
                        if raycast_coord[4] ~= 0 and ENTITY.GET_ENTITY_TYPE(raycast_coord[4]) >= 1 and ENTITY.GET_ENTITY_TYPE(raycast_coord[4]) < 3 then
                            ggc1 = ENTITY.GET_ENTITY_COORDS(raycast_coord[4], true)
                        else
                            ggc1 = raycast_coord[2]
                        end
                        local c2 = players.get_position(players.user())
                        local dist = MISC.GET_DISTANCE_BETWEEN_COORDS(ggc1['x'], ggc1['y'], ggc1['z'], c2['x'], c2['y'], c2['z'], true)
                        -- safety
                        if not lastdist or dist < lastdist then 
                            lastdist = dist
                        else
                            break
                        end
                        if ENTITY.IS_ENTITY_DEAD(players.user_ped()) then
                            break
                        end
                        if dist >= 10 then
                            local dir = {}
                            dir['x'] = (ggc1['x'] - c2['x']) * dist
                            dir['y'] = (ggc1['y'] - c2['y']) * dist
                            dir['z'] = (ggc1['z'] - c2['z']) * dist
                            --ENTITY.APPLY_FORCE_TO_ENTITY(players.user_ped(), 2, dir['x'], dir['y'], dir['z'], 0.0, 0.0, 0.0, 0, false, false, true, false, true)
                            ENTITY.SET_ENTITY_VELOCITY(players.user_ped(), dir['x'], dir['y'], dir['z'])
                        else
                            local t = ENTITY.GET_ENTITY_TYPE(raycast_coord[4])
                            if t == 2 then
                                set_player_into_suitable_seat(raycast_coord[4])
                            elseif t == 1 then
                                local v = PED.GET_VEHICLE_PED_IS_IN(t, false)
                                if v ~= 0 then
                                    set_player_into_suitable_seat(v)
                                end
                            end
                            break
                        end
                        util.yield()
                    end
                end
            end
        end
    end

    if paintball then
        ls_log("paintball loop")
        local ent = get_aim_info()['ent']
        request_control_of_entity(ent)
        if PED.IS_PED_SHOOTING(players.user_ped()) then
            if ENTITY.IS_ENTITY_A_VEHICLE(ent) then
                ls_log("paintball hit")
                rand = {}
                rand['r'] = math.random(100,255)
                rand['g'] = math.random(100,255)
                rand['b'] = math.random(100,255)
                VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(ent, rand['r'], rand['g'], rand['b'])
                VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(ent, rand['r'], rand['g'], rand['b'])
            end
        end
    end

    if aim_info then
        local info = get_aim_info()
        if info['ent'] ~= 0 then
            local text = "Hash: " .. info['hash'] .. "\nEntity: " .. info['ent'] .. "\nHealth: " .. info['health'] .. "\nType: " .. info['type'] .. "\nSpeed: " .. info['speed']
            directx.draw_text(0.5, 0.3, text, 5, 0.5, white, true)
        end
    end

    if gun_stealer then
        if PED.IS_PED_SHOOTING(players.user_ped()) then
            local ent = get_aim_info()['ent']
            if ENTITY.IS_ENTITY_A_VEHICLE(ent) then
                local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(ent, -1)
                if PED.IS_PED_A_PLAYER(driver) then
                    hijack_veh_for_player(ent)
                end
                request_control_of_entity(ent)
                set_player_into_suitable_seat(ent)
            end
        end
    end

    if drivergun then
        local ent = get_aim_info()['ent']
        request_control_of_entity(ent)
        if PED.IS_PED_SHOOTING(players.user_ped()) then
            if ENTITY.IS_ENTITY_A_VEHICLE(ent) then
                local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(ent, -1)
                if driver == 0 or not PED.IS_PED_A_PLAYER(driver) then
                    if not PED.IS_PED_A_PLAYER(driver) then
                        entities.delete_by_handle(driver)
                    end
                    local hash = 0x9C9EFFD8
                    request_model_load(hash)
                    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, -2.0, 0.0, 0.0)
                    local ped = entities.create_ped(28, hash, coords, 30.0)
                    PED.SET_PED_INTO_VEHICLE(ped, ent, -1)
                    ENTITY.SET_ENTITY_INVINCIBLE(ped, true)
                    PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
                    PED.SET_PED_FLEE_ATTRIBUTES(ped, 0, false)
                    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true)
                    PED.SET_PED_CAN_BE_DRAGGED_OUT(ped, false)
                    PED.SET_PED_CAN_BE_KNOCKED_OFF_VEHICLE(ped, false)
                    TASK.TASK_VEHICLE_DRIVE_TO_COORD(ped, ent, math.random(1000), math.random(1000), math.random(100), 100, 1, ENTITY.GET_ENTITY_MODEL(ent), 4, 5, 0)
                end
            end
        end
    end

    if entgun then
        if PED.IS_PED_SHOOTING(players.user_ped()) then
            local hash = shootent
            request_model_load(hash)
            local c1 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 0.0, 5.0, 0.0)
            local res = raycast_gameplay_cam(-1, 1000.0)
            local dir = {}
            local c2 = {}
            if res[1] ~= 0 then
                c2 = res[2]
                dir['x'] = (c2['x'] - c1['x'])*1000
                dir['y'] = (c2['y'] - c1['y'])*1000
                dir['z'] = (c2['z'] - c1['z'])*1000
            else 
                c2 = get_offset_from_gameplay_camera(1000)
                dir['x'] = (c2['x'] - c1['x'])*1000
                dir['y'] = (c2['y'] - c1['y'])*1000
                dir['z'] = (c2['z'] - c1['z'])*1000
            end
            local ent = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, c1['x'], c1['y'], c1['z'], true, false, false)
            ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(ent, players.user_ped(), false)
            ENTITY.APPLY_FORCE_TO_ENTITY(ent, 0, dir['x'], dir['y'], dir['z'], 0.0, 0.0, 0.0, 0, true, false, true, false, true)
            if not entgungrav then
                ENTITY.SET_ENTITY_HAS_GRAVITY(ent, false)
            end
            --ENTITY.SET_OBJECT_AS_NO_LONGER_NEEDED(ent)
        end
    end

    if tesla_ped ~= 0 then
        lastcar = PLAYER.GET_PLAYERS_LAST_VEHICLE()
        p_coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
        t_coords = ENTITY.GET_ENTITY_COORDS(lastcar, true)
        dist = MISC.GET_DISTANCE_BETWEEN_COORDS(p_coords['x'], p_coords['y'], p_coords['z'], t_coords['x'], t_coords['y'], t_coords['z'], false)
        if lastcar == 0 or ENTITY.GET_ENTITY_HEALTH(lastcar) == 0 or dist <= 5 then
            entities.delete_by_handle(tesla_ped)
            VEHICLE.BRING_VEHICLE_TO_HALT(lastcar, 5.0, 2, true)
            VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(lastcar, false)
            VEHICLE.START_VEHICLE_HORN(lastcar, 1000, util.joaat("NORMAL"), false)
            tesla_ped = 0
            util.remove_blip(tesla_blip)
        end
    end
    util.yield()
end

util.on_stop(function()
    for k,v in all_used_cameras do 
        CAM.SET_CAM_ACTIVE(v, false)
        CAM.DESTROY_CAM(v, true)
    end
    for hdl, blip in pairs(kosatka_missile_blips) do 
        util.remove_blip(blip)
    end

    for pid, blip in pairs(orbital_blips) do 
        util.remove_blip(blip)
    end
    CAM.RENDER_SCRIPT_CAMS(false, true, 100, true, true, 0)
    sober_up(players.user_ped())
    if active_rideable_animal ~= 0 then 
        ENTITY.DETACH_ENTITY(players.user_ped())
        entities.delete_by_handle(active_rideable_animal)
        TASK.CLEAR_PED_TASKS_IMMEDIATELY(players.user_ped())
    end
end)
