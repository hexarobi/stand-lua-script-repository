-- kepler, written by bitwise#5568
local kepler_edition = 1.00
local gtao_edition = 1.66
local updated = false
local dev_mode = false
local handle_ptr = memory.alloc(13*8)
local internet_enabled = not menu.get_value(menu.ref_by_path('Stand>Lua Scripts>Settings>Disable Internet Access'))
natives_version = "1681379138.g"
util.require_natives(natives_version)

store_dir = filesystem.store_dir() .. '\\kepler\\'
translations_dir = store_dir .. '\\translations\\'
resources_dir = filesystem.resources_dir() .. '\\kepler\\'
relative_translations_dir = "./store/kepler/translations/"

local startup_sound = resources_dir .. '\\startup.wav'
local notification_sound = resources_dir .. '\\notification.wav'

local function play_wav(wav)
    util.create_thread(function()
        local fr = soup.FileReader(wav)
        local wav = soup.audWav(fr)
        local dev = soup.audDevice.getDefault()
        local pb = dev:open(wav.channels)
        local mix = soup.audMixer()
        mix.stop_playback_when_done = true
        mix:setOutput(pb)
        mix:playSound(wav)
        while pb:isPlaying() do util.yield() end
    end)
end

local play_notification_sounds = true
function say(text)
    if play_notification_sounds then 
        play_wav(notification_sound)
    end
    util.toast('[Kepler] ' .. text)
end

if not filesystem.is_dir(store_dir) then
    filesystem.mkdirs(store_dir)
end

if not filesystem.is_dir(translations_dir) then 
    filesystem.mkdirs(translations_dir)
end

local translation_files = {}
for i, path in ipairs(filesystem.list_files(translations_dir)) do
    local file_str = path:gsub(translations_dir, '')
    if string.endswith(file_str, '.lua') then
        translation_files[#translation_files + 1] = file_str
    end
end

function fetch_default_translations()
    local done = false
    async_http.init('gist.githubusercontent.com', '/stakonum/7b5ba8abcb5c6c5a3182968c3e9362b0/raw/?cachebust=----', function(data)
        local file = io.open(translations_dir .. "/english.lua",'w')
        file:write(data)
        file:close()
        done = true 
    end, function()
        util.toast('!!! Failed to retrieve default translation table. All options that would be translated will look weird. Please check your connection to GitHub.')
    end)
    async_http.dispatch()
    while not done do 
        util.yield()
    end
    return translation_data
end

-- translation system initializing
if not table.contains(translation_files, 'english.lua') then 
    fetch_default_translations()
end

-- begin autoupdater
if not internet_enabled then 
    if SCRIPT_MANUAL_START then 
        say("Lua script internet access is disabled. The autoupdater will not run and some things may not work. Please enable internet access for the best experience.")
    end
else
    async_http.init('gist.githubusercontent.com', '/stakonum/c207cda8ae4c7c4f7abc79113f41222c/raw/?cachebust=----', function(data)
        local _, latest_version = string.partition(data, 'local kepler_edition = ')
        local latest_version, _ = string.partition(latest_version, '\n')
        latest_version = tonumber(latest_version)
        if latest_version > kepler_edition then 
            local f = io.open(filesystem.scripts_dir() .. SCRIPT_REL_PATH, 'wb')
            f:write(a)
            f:close()
            fetch_default_translations()
            if SCRIPT_MANUAL_START then 
                say("Updated! Now restarting.")
                say(translations.changelog .. get_changelog())
            end
            util.restart_script()
        elseif kepler_edition > latest_version then 
            dev_mode = true
            if SCRIPT_MANUAL_START then 
                say("Your edition of Kepler is higher than the repository's edition! Happy developing! " .. latest_version)
            end
        end
    end, function()
        util.toast('!!! Failed to retrieve from Gist.')
    end)
    async_http.dispatch()
end
-- end autoupdater

-- translations support
local selected_lang_path = translations_dir .. 'selected_language.txt'
if not table.contains(translation_files, 'selected_language.txt') then
    local file = io.open(selected_lang_path, 'w')
    file:write('english.lua')
    file:close()
end

local translations = {}
setmetatable(translations, {
    __index = function (self, key)
        return key
    end
})

local selected_lang_file = io.open(selected_lang_path, 'r')
local selected_language = selected_lang_file:read()
if not table.contains(translation_files, selected_language) then
    util.toast(selected_language .. ' was not found. Defaulting to English.')
    translations = require(relative_translations_dir .. "english")
else
    translations = require(relative_translations_dir .. '\\' .. selected_language:gsub('.lua', ''))
end

-- end translations support

local online_v = tonumber(GET_ONLINE_VERSION())
if online_v > gtao_edition then
    say(translations.gtao_newer)
end


-- filesystem handling and logo 
if not filesystem.is_dir(resources_dir) then
    say(translations.resource_dir_missing)
end

-- logo display and sound
if SCRIPT_MANUAL_START then
    local logo = directx.create_texture(resources_dir .. 'logo.png')
    play_wav(startup_sound)
    logo_thread = util.create_thread(function (thr)
        starttime = os.clock()
        local alpha = 0
        local scale = 0.0
        local alpha = 1
        while true do
            directx.draw_texture(logo, scale, scale, 0.5, 0.5, 0.5, 0.5, 0, 1, 1, 1, alpha)
            if os.clock() - starttime > 3 then 
                alpha -= 0.02
                if alpha <= 0 then 
                    util.stop_thread()
                end
            else
                if scale < 0.09 then 
                    scale += 0.001
                end
            end
            util.yield()
        end
    end)
end

local main_root = menu.my_root()

main_root:divider(translations.me)
local self_root = main_root:list(translations.self, {'keplerself'}, '')
local combat_root = main_root:list(translations.combat, {}, '')
local vehicle_root = main_root:list(translations.vehicle, {'keplercar'}, '')
local online_root = main_root:list(translations.online, {}, "")

main_root:divider(translations.entities)

local peds_root = main_root:list(translations.peds, {"keplerpeds"}, '')
local spawn_peds_root = peds_root:list(translations.spawn, {"keplerspawnped"}, "")
local vehicles_root = main_root:list(translations.vehicles, {"keplervehicles"}, '')
local objects_root = main_root:list(translations.objects, {"keplerobjects"}, '')
local pickups_root = main_root:list(translations.pickups, {"keplerpickups"}, '')

function request_model_load(hash)
    util.request_model(hash, 2000)
end

function request_anim_dict(dict)
    request_time = os.time()
    if not DOES_ANIM_DICT_EXIST(dict) then
        return
    end
    REQUEST_ANIM_DICT(dict)
    while not HAS_ANIM_DICT_LOADED(dict) do
        if os.time() - request_time >= 10 then
            break
        end
        util.yield()
    end
end

local gun_names = {translations.none, translations.pistol, translations.minigun, translations.rpg}
local gun_hashes = {0, 453432689, 1119849093, -1312131151}

-- SECTION: SELF
-- entity ownership forcing
local function request_control_of_entity(ent)
    if not NETWORK_HAS_CONTROL_OF_ENTITY(ent) and util.is_session_started() then
        local netid = NETWORK_GET_NETWORK_ID_FROM_ENTITY(ent)
        SET_NETWORK_ID_CAN_MIGRATE(netid, true)
        local st_time = os.time()
        while not NETWORK_HAS_CONTROL_OF_ENTITY(ent) do
            -- intentionally silently fail, otherwise we are gonna spam the everloving shit out of the user
            if os.time() - st_time >= 5 then
                util.log("Failed to request entity control in 5 seconds (entity " .. ent .. ")")
                break
            end
            NETWORK_REQUEST_CONTROL_OF_ENTITY(ent)
            util.yield()
        end
    end
end

local function request_anim_dict(dict)
    while not HAS_ANIM_DICT_LOADED(dict) do
        REQUEST_ANIM_DICT(dict)
        util.yield()
    end
end

local function request_anim_set(set)
    while not HAS_ANIM_SET_LOADED(set) do
        REQUEST_ANIM_SET(set)
        util.yield()
    end
end

local function request_control_of_entity_once(ent)
    if not NETWORK_HAS_CONTROL_OF_ENTITY(ent) and util.is_session_started() then
        local netid = NETWORK_GET_NETWORK_ID_FROM_ENTITY(ent)
        SET_NETWORK_ID_CAN_MIGRATE(netid, true)
        NETWORK_REQUEST_CONTROL_OF_ENTITY(ent)
    end
end

-- gets coords of waypoint
local function get_waypoint_coords()
    local coords = GET_BLIP_COORDS(GET_FIRST_BLIP_INFO_ID(8))
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

local active_rideable_animal = 0
-- rideable animal tick handler
util.create_tick_handler(function()
    if active_rideable_animal ~= 0 then 
        -- dismounting 
        if IS_CONTROL_JUST_PRESSED(23, 23) then 
            DETACH_ENTITY(players.user_ped())
            entities.delete_by_handle(active_rideable_animal)
            CLEAR_PED_TASKS_IMMEDIATELY(players.user_ped())
            active_rideable_animal = 0
        end

        -- movement
        if not IS_ENTITY_IN_AIR(active_rideable_animal) then 
            if IS_CONTROL_PRESSED(32, 32) then 
                local side_move = GET_CONTROL_NORMAL(146, 146)
                local fwd = GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(active_rideable_animal, side_move*10.0, 8.0, 0.0)
                TASK_LOOK_AT_COORD(active_rideable_animal, fwd.x, fwd.y, fwd.z, 0, 0, 2)
                TASK_GO_STRAIGHT_TO_COORD(active_rideable_animal, fwd.x, fwd.y, fwd.z, 20.0, -1, GET_ENTITY_HEADING(active_rideable_animal), 0.5)
            end

            if IS_CONTROL_JUST_PRESSED(76, 76) then 
                --CLEAR_PED_TASKS(active_rideable_animal)
                local w = {}
                w.x, w.y, w.z, _ = players.get_waypoint(players.user())
                if w.x == 0.0 and w.y == 0.0 then 
                    say(translations.no_waypoint_set)
                else
                    TASK_FOLLOW_NAV_MESH_TO_COORD(active_rideable_animal, w.x, w.y, w.z, 1.0, -1, 100, 0, 0)
                end
            end
        end

    end
end)

local ranimal_hashes = {util.joaat("a_c_deer"), util.joaat("a_c_boar"), util.joaat("a_c_cow")}
self_root:list_action(translations.spawn_rideable_animal, {"keplerra"}, "", {translations.deer, translations.boar, translations.cow}, function(index)
    if active_rideable_animal ~= 0 then 
        say(translations.already_riding_animal)
        return 
    end
    local hash = ranimal_hashes[index]
    request_model_load(hash)
    local animal = entities.create_ped(8, hash, players.get_position(players.user()), GET_ENTITY_HEADING(players.user_ped()))
    SET_ENTITY_INVINCIBLE(animal, true)
    FREEZE_ENTITY_POSITION(animal, true)
    FREEZE_ENTITY_POSITION(players.user_ped(), true)
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
    if GET_ENTITY_MODEL(players.user_ped()) == util.joaat("mp_f_freemode_01") then 
        z_off = f_z_off
    else
        z_off = m_z_off
    end
    ATTACH_ENTITY_TO_ENTITY(players.user_ped(), animal, GET_PED_BONE_INDEX(animal, 24816), -0.3, 0.0, z_off, 0.0, 0.0, 90.0, false, false, false, true, 2, true)
    request_anim_dict("rcmjosh2")
    TASK_PLAY_ANIM(players.user_ped(), "rcmjosh2", "josh_sitting_loop", 8.0, 1, -1, 2, 1.0, false, false, false)
    say(translations.ra_instruction)
    FREEZE_ENTITY_POSITION(animal, false)
    FREEZE_ENTITY_POSITION(players.user_ped(), false)
end)

self_root:action(translations.front_flip, {"frontflip"}, "", function()
    local hash = util.joaat("prop_ecola_can")
    request_model_load(hash)
    local prop = entities.create_object(hash, players.get_position(players.user()))
    FREEZE_ENTITY_POSITION(prop)
    ATTACH_ENTITY_TO_ENTITY(players.user_ped(), prop, 0, 0, 0, 0, 0, 0, 0, true, false, false, false, 0, true)
    local hdg = GET_GAMEPLAY_CAM_ROT(0).z
    SET_ENTITY_ROTATION(prop, 0, 0, hdg, 1)
    for i=1, -360, -8 do
        SET_ENTITY_ROTATION(prop, i, 0, hdg, 1)
        util.yield()
    end
    DETACH_ENTITY(players.user_ped())
    entities.delete_by_handle(prop)
end)

local walk_on_water = false
menu.toggle(self_root, translations.walk_on_water, {"keplerjesus"}, "", function(on)
    walk_on_water = on
end)


self_root:toggle_loop(translations.keep_clean, {"keepmeclean"}, "", function()
    CLEAR_PED_BLOOD_DAMAGE(players.user_ped())
    CLEAR_PED_WETNESS(players.user_ped())
    CLEAR_PED_ENV_DIRT(players.user_ped())
end)

function request_ptfx_asset(asset)
    local request_time = os.time()
    REQUEST_NAMED_PTFX_ASSET(asset)
    while not HAS_NAMED_PTFX_ASSET_LOADED(asset) do
        if os.time() - request_time >= 10 then
            break
        end
        util.yield()
    end
end

local burning_man_ptfx_asset = "core"
local burning_man_ptfx_effect = "fire_wrecked_plane_cockpit"
request_ptfx_asset(burning_man_ptfx_asset)

local trail_bones = {0xffa, 0xfa11, 0x83c, 0x512d, 0x796e, 0xb3fe, 0x3fcf, 0x58b7, 0xbb0}
local looped_ptfxs = {}
local was_burning_man_on = false
self_root:toggle(translations.burning_man, {"burningman"}, "", function(on)
    if not on then 
        for _, p in pairs(looped_ptfxs) do
            REMOVE_PARTICLE_FX(p, false)
            STOP_PARTICLE_FX_LOOPED(p, false)
        end
    else
        request_ptfx_asset(burning_man_ptfx_asset)
        for _, bone in pairs(trail_bones) do
            USE_PARTICLE_FX_ASSET(burning_man_ptfx_asset)
            local bone_id = GET_PED_BONE_INDEX(players.user_ped(), bone)
            fx = START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE(burning_man_ptfx_effect, players.user_ped(), 0.0, 0.0, 0.0, 0.0, 0.0, 90.0, bone_id, 0.5, false, false, false, 0, 0, 0, 0)
            looped_ptfxs[#looped_ptfxs+1] = fx
            SET_PARTICLE_FX_LOOPED_COLOUR(fx, 100, 100, 100, false)
        end
    end
end)


self_root:toggle_loop(translations.laser_eyes, {"lasereyes"}, translations.hold_horn_to_use, function(on)
    local weaponHash = util.joaat("weapon_heavysniper_mk2")
    local dictionary = "weap_xs_weapons"
    local ptfx_name = "bullet_tracer_xs_sr"
    local camRot = GET_FINAL_RENDERED_CAM_ROT(2)
    if IS_CONTROL_PRESSED(51, 51) then
        -- credits to jinxscript
        local inst = v3.new()
        v3.set(inst,GET_FINAL_RENDERED_CAM_ROT(2))
        local tmp = v3.toDir(inst)
        v3.set(inst, v3.get(tmp))
        v3.mul(inst, 1000)
        v3.set(tmp, GET_FINAL_RENDERED_CAM_COORD())
        v3.add(inst, tmp)
        camAim_x, camAim_y, camAim_z = v3.get(inst)
        local ped_model = GET_ENTITY_MODEL(players.user_ped())
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
        local boneCoord_L = GET_WORLD_POSITION_OF_ENTITY_BONE(players.user_ped(), GET_PED_BONE_INDEX(players.user_ped(), left_eye_id))
        local boneCoord_R = GET_WORLD_POSITION_OF_ENTITY_BONE(players.user_ped(), GET_PED_BONE_INDEX(players.user_ped(), right_eye_id))
        camRot.x += 90
        request_ptfx_asset(dictionary)
        USE_PARTICLE_FX_ASSET(dictionary)
        START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(ptfx_name, boneCoord_L.x, boneCoord_L.y, boneCoord_L.z, camRot.x, camRot.y, camRot.z, 2, 0, 0, 0, false)
        USE_PARTICLE_FX_ASSET(dictionary)
        START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(ptfx_name, boneCoord_R.x, boneCoord_R.y, boneCoord_R.z, camRot.x, camRot.y, camRot.z, 2, 0, 0, 0, false)
        SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(boneCoord_L.x, boneCoord_L.y, boneCoord_L.z, camAim_x, camAim_y, camAim_z, 100, true, weaponHash, players.user_ped(), false, true, 100, players.user_ped(), 0)
        SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(boneCoord_R.x, boneCoord_R.y, boneCoord_R.z, camAim_x, camAim_y, camAim_z, 100, true, weaponHash, players.user_ped(), false, true, 100, players.user_ped(), 0)
    end
end)


self_root:click_slider(translations.tp_forward, {"keplertpf"}, "", 1, 100, 1, 1, function(s)
    local pos = GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 0, s, 0)
    SET_ENTITY_COORDS_NO_OFFSET(PLAYER_PED_ID(), pos['x'], pos['y'], pos['z'], true, false, false)
end)

local drive_on_air_toggle
walkonwater = false
self_root:toggle(translations.walk_on_water, {translations.walk_on_water_cmd}, "", function(on)
    walkonwater = on
    if on then
        menu.set_value(drive_on_air_toggle, false)
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
self_root:text_input(translations.teleport_to_road, {"keplertptoroad"}, "", function(input)
    if input == "" then 
        return 
    end
    for name, pos in pairs(road_positions) do
        if string.contains(string.lower(name), string.lower(input)) then
            say(translations.teleported_to .. name .. "!")
            SET_PED_COORDS_KEEP_VEHICLE(players.user_ped(), pos[1], pos[2], pos[3])
            menu.trigger_commands("keplertptoroad")
            return
        end
    end
    say(translations.road_not_found)
end)


self_root:divider(translations.settings)
local self_section_settings_root = self_root:list(translations.settings, {'keplerselfsetting'}, "")

-- SECTION: COMBAT


-- aim info
local ent_types = {translations.none, translations.ped, translations.vehicle, translations.object}
local function get_aim_info()
    local outptr = memory.alloc(4)
    local success = GET_ENTITY_PLAYER_IS_FREE_AIMING_AT(players.user(), outptr)
    local info = {}
    if success then
        local ent = memory.read_int(outptr)
        if not DOES_ENTITY_EXIST(ent) then
            info["ent"] = 0
        else
            info["ent"] = ent
        end
        if GET_ENTITY_TYPE(ent) == 1 then
            local veh = GET_VEHICLE_PED_IS_IN(ent, false)
            if veh ~= 0 then
                if GET_PED_IN_VEHICLE_SEAT(veh, -1) then
                    ent = veh
                    info['ent'] = ent
                end
            end
        end
        info["hash"] = GET_ENTITY_MODEL(ent)
        info["health"] = GET_ENTITY_HEALTH(ent)
        info["type"] = ent_types[GET_ENTITY_TYPE(ent)+1]
        info["speed"] = math.floor(GET_ENTITY_SPEED(ent))
    else
        info['ent'] = 0
    end
    return info
end

local function pid_to_handle(pid)
    NETWORK_HANDLE_FROM_PLAYER(pid, handle_ptr, 13)
    return handle_ptr
end

local vehicle_uses = 0
local pickup_uses = 0
local ped_uses = 0 
local player_uses = 0

local function mod_uses(type, incr)
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

local kill_aura = false
local kill_aura_peds = false
local kill_aura_players = false
local kill_aura_friends = false
local kill_aura_dist = 20

local silent_aimbot_root = combat_root:list(translations.silent_aimbot, {}, "")
local anti_aim_root = combat_root:list(translations.anti_aim, {}, "")
local kill_aura_root = combat_root:list(translations.kill_aura, {}, "")
local special_weapons_root = combat_root:list(translations.modded_weapons, {"keplermoddedwep"}, "")

-- SUBSECTION: ANTI-AIM
local anti_aim = false
anti_aim_root:toggle_loop(translations.anti_aim, {"kepleraa"}, "", function(on)
    anti_aim = on
    mod_uses("player", if on then 1 else -1)
end)

anti_aim_root:divider(translations.settings)
local aa_section_settings_root = anti_aim_root:list(translations.settings, {'kepleraasetting'}, "")

local anti_aim_say = false
aa_section_settings_root:toggle(translations.anti_aim_say, {"kepleraasay"},  translations.anti_aim_say_desc, function(on)
    anti_aim_say = on
end)

local anti_aim_angle = 2
aa_section_settings_root:click_slider(translations.anti_aim_angle, {"kepleraaangle"}, "", 0, 180, 2, 1, function(s)
    anti_aim_angle = s
end)

local anti_aim_types = {translations.script_event, translations.ragdoll, translations.explode}
local anti_aim_type = 1
aa_section_settings_root:list_select(translations.anti_aim_type, {"kepleraatype"}, "", anti_aim_types, 1, function(index)
    anti_aim_type = index
end)

-- SUBSECTION: KILL AURA

kill_aura_root:toggle(translations.kill_aura, {translations.kill_aura_cmd}, "", function(on)
    kill_aura = on
    mod_uses("ped", if on then 1 else -1)
end)

kill_aura_root:divider(translations.settings)
local kill_aura_section_settings_root = kill_aura_root:list(translations.settings, {'keplerkasetting'}, "")

kill_aura_section_settings_root:toggle(translations.target_peds, {"keplerkapeds"}, "", function(on)
    kill_aura_peds = on
end)

kill_aura_section_settings_root:toggle(translations.target_players, {"keplerkaplayers"}, "", function(on)
    kill_aura_players = on
end)


kill_aura_section_settings_root:toggle(translations.target_friends, {"keplerkafriends"}, "", function(on)
    kill_aura_friends = on
end)

kill_aura_section_settings_root:slider(translations.radius, {"keplerkadist"}, "", 1, 100, 20, 1, function(s)
    kill_aura_dist = s
end)

-- SUBSECTION: SILENT AIMBOT
local sa_showtarget = true
local sa_target_usefov = true
local sa_fov = 5
local sa_target_nogodmode = true
local sa_target_players = true
local sa_target_peds = false 
local sa_target_friends = false 
local sa_target_damageo = false 
local sa_target_novehicles = false 
local sa_odmg = 100
local sa_showtarget = true 

local silent_aimbot_mode = "closest"
local function get_aimbot_target()
    local dist = 1000000000
    local cur_tar = 0
    -- an aimbot should have immaculate response time so we shouldnt rely on the other entity pools for this data
    for k,v in pairs(entities.get_all_peds_as_handles()) do
        local target_this = true
        local player_pos = players.get_position(players.user())
        local ped_pos = GET_ENTITY_COORDS(v, true)
        local this_dist = GET_DISTANCE_BETWEEN_COORDS(player_pos['x'], player_pos['y'], player_pos['z'], ped_pos['x'], ped_pos['y'], ped_pos['z'], true)
        if players.user_ped() ~= v and not IS_ENTITY_DEAD(v) then
            if not sa_target_players then
                if IS_PED_A_PLAYER(v) then
                    target_this = false
                end
            end
            if not sa_target_peds then
                if not IS_PED_A_PLAYER(v) then
                    target_this = false
                end
            end
            if not HAS_ENTITY_CLEAR_LOS_TO_ENTITY(players.user_ped(), v, 17) then
                target_this = false
            end
            if sa_target_usefov then
                if not IS_PED_FACING_PED(players.user_ped(), v, sa_fov) then
                    target_this = false
                end
            end
            if sa_target_novehicles then
                if IS_PED_IN_ANY_VEHICLE(v, true) then 
                    target_this = false
                end
            end
            if sa_target_nogodmode then
                if not GET_ENTITY_CAN_BE_DAMAGED(v) then 
                    target_this = false 
                end
            end
            if not sa_target_friends and sa_target_players then
                if IS_PED_A_PLAYER(v) then
                    local pid = NETWORK_GET_PLAYER_INDEX_FROM_PED(v)
                    local hdl = pid_to_handle(pid)
                    if NETWORK_IS_FRIEND(hdl) then
                        target_this = false 
                    end
                end
            end
            if silent_aimbot_mode == "closest" then
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

silent_aimbot_root:toggle_loop(translations.silent_aimbot, {"keplersa"}, "", function(toggle)
    local target = get_aimbot_target()
    if target ~= 0 then
        local t_pos = GET_PED_BONE_COORDS(target, 31086, 0.01, 0, 0)
        local t_pos2 = GET_PED_BONE_COORDS(target, 31086, -0.01, 0, 0.00)
        if sa_showtarget then
            util.draw_ar_beacon(t_pos)
        end
        if IS_PED_SHOOTING(players.user_ped()) then
            local wep = GET_SELECTED_PED_WEAPON(players.user_ped())
            local dmg = GET_WEAPON_DAMAGE(wep, 0)
            if sa_target_damageo then
                dmg = sa_odmg
            end
            local veh = GET_VEHICLE_PED_IS_IN(target, false)
            SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(t_pos['x'], t_pos['y'], t_pos['z'], t_pos2['x'], t_pos2['y'], t_pos2['z'], dmg, true, wep, players.user_ped(), true, false, 10000, veh)
        end
    end
end)

silent_aimbot_root:divider(translations.settings)
local silent_aimbot_section_settings_root = silent_aimbot_root:list(translations.settings, {'keplersasetting'}, "")

silent_aimbot_section_settings_root:toggle(translations.target_players, {"keplersa_targetplayers"}, "", function(on)
    sa_target_players = on
end, true)

silent_aimbot_section_settings_root:toggle(translations.target_peds, {"keplersa_targetpeds"}, "", function(on)
    sa_target_peds = on
end)

silent_aimbot_section_settings_root:toggle(translations.use_fov, {"keplersausefov"}, "", function(on)
    sa_target_usefov = on
end, true)

silent_aimbot_section_settings_root:slider(translations.fov, {"keplersafov"}, "", 1, 270, 1, 1, function(s)
    sa_fov = s
end)

silent_aimbot_section_settings_root:toggle(translations.ignore_targets_inside_vehicles, {"keplersanoveh"}, "", function(on)
    sa_target_novehicles = on
end)

silent_aimbot_section_settings_root:toggle(translations.ignore_godmoded_targets, {"keplersanogodmode"}, "", function(on)
    sa_target_nogodmode = on
end, true)

silent_aimbot_section_settings_root:toggle(translations.target_friends, {"keplersafriends"}, "", function(on)
    sa_target_friends = on
end)

silent_aimbot_section_settings_root:toggle(translations.damage_override, {"keplersadmg"}, "", function(on)
    sa_target_damageo = on
end)

local sa_odmg = 100
silent_aimbot_section_settings_root:slider(translations.damage_override_amount, {"keplersadmgamt"}, "", 1, 1000, 100, 1, function(s)
    sa_odmg = s
end)

silent_aimbot_section_settings_root:toggle(translations.display_target, {"keplersadrawtar"}, "", function(on)
    sa_showtarget = on
end, true)

-- SUBSECTION: SPECIAL WEAPONS
local aim_info = false
special_weapons_root:toggle(translations.aim_info, {translations.aim_info_cmd}, translations.aim_info_desc, function(on)
    aim_info = on
end)

local gun_stealer = false
special_weapons_root:toggle(translations.car_stealer_gun, {translations.car_stealer_gun_cmd}, translations.car_stealer_gun_desc, function(on)
    gun_stealer = on
end)

local paintball = false
special_weapons_root:toggle(translations.paintball, {translations.paintball_cmd}, translations.paintball_desc, function(on)
    paintball = on
end)

special_weapons_root:toggle_loop(translations.kick_gun, {"keplerkickgun"}, "", function()
    local ent = get_aim_info()['ent']
    if IS_PED_SHOOTING(players.user_ped()) then
        if IS_ENTITY_A_PED(ent) then
            if IS_PED_A_PLAYER(ent) then
                local pid = NETWORK_GET_PLAYER_INDEX_FROM_PED(ent)
                if players.get_host() == pid then 
                    say(translations.host_warn)
                    return
                end
                menu.trigger_commands("kick" .. players.get_name(pid))
            end
        end
    end
end)

local drivergun = false
special_weapons_root:toggle(translations.npc_driver_gun, {translations.npc_driver_gun_cmd}, translations.npc_driver_gun_desc, function(on)
    drivergun = on
end)

local grapplegun = false
special_weapons_root:toggle(translations.grapple_gun, {translations.grapple_gun_cmd}, "", function(on)
    grapplegun = on
    if on then
        GIVE_WEAPON_TO_PED(players.user_ped(), util.joaat('weapon_pistol'), 9999, false, false)
        say(translations.grapple_gun_active)
    end
end)

-- SPAWNING PEDS
local all_pets = {}
local spawn_ped_as_pet = true
local num_peds_to_spawn = 1
local function spawn_ped(hash)
    coords = GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 0.0, 3.0, 0.0)
    local peds_spawned = {}
    request_model_load(hash)
    for i=1, num_peds_to_spawn do
        ped = entities.create_ped(28, hash, coords, math.random(0, 270))
        peds_spawned[#peds_spawned + 1] = ped
        if spawn_ped_as_pet then
            all_pets[#all_pets + 1] = ped
            SET_ENTITY_INVINCIBLE(ped, true)
            TASK_FOLLOW_TO_OFFSET_OF_ENTITY(ped, players.user_ped(), 0, -1, 0, 7.0, -1, 1, true)
            SET_PED_COMBAT_ABILITY(ped, 3)
            SET_PED_FLEE_ATTRIBUTES(ped, 0, false)
            SET_PED_COMBAT_ATTRIBUTES(ped, 5, true)
            local blip = ADD_BLIP_FOR_ENTITY(ped)
            SET_BLIP_COLOUR(blip, 11)
        end
    end
    local spawn_ct = #peds_spawned
    if spawn_ct > 1 then 
        say(spawn_ct .. translations.peds_created)
    else
        say(spawn_ct .. translations.ped_created)
    end
    return peds_spawned
end

-- SECTION: PEDS
local gun_to_give_peds = 1
peds_root:list_select(translations.give_gun, {"keplergivepedgun"}, "", gun_names, 1, function(index)
    gun_to_give_peds = index
    mod_uses("ped", if index == 0 then -1 else 1)
end)

peds_root:toggle(translations.godmode, {"keplerpedgodmode"}, "", function(on)
    ped_godmode = on 
    mod_uses("ped", if on then 1 else -1)
end)

peds_root:toggle(translations.oblivious, {"keplerobliviouspeds"}, "", function(on)
    peds_ignore = on 
    mod_uses("ped", if on then 1 else -1)
end)

peds_root:toggle(translations.a_pose, {"keplerapose"}, "", function(on)
    apose_peds = on 
    mod_uses("ped", if on then 1 else -1)
end)

peds_root:toggle(translations.battle_royale, {"keplerbattleroyale"}, "", function(on)
    SET_RIOT_MODE_ENABLED(on)
end)

peds_root:action(translations.teleport_all_to_me, {"keplerfetchallpeds"}, "", function(click_type)
    local c = GET_ENTITY_COORDS(players.user_ped(), false)
    local all_peds = entities.get_all_peds_as_handles()
    for k,ped in pairs(all_peds) do
        if not IS_PED_A_PLAYER(ped) then
            if IS_PED_IN_ANY_VEHICLE(ped, true) then
                CLEAR_PED_TASKS_IMMEDIATELY(ped)
                TASK_LEAVE_ANY_VEHICLE(ped, 0, 16)
            end
            SET_ENTITY_COORDS(ped, c.x, c.y, c.z)
        end
    end
end)

peds_root:action(translations.clear_all, {"keplerclearpeds"}, translations.break_missions_warn, function()
    local ct = 0
    for k,ent in pairs(entities.get_all_peds_as_handles()) do
        if not IS_PED_A_PLAYER(ent) then
            entities.delete_by_handle(ent)
        end
        ct += 1
    end
    say(ct .. translations.entities_removed)
end)

peds_root:divider(translations.settings)
local peds_settings_subsection = peds_root:list(translations.settings, {}, "")

local custom_ped_string = "a_c_retriever"
spawn_peds_root:text_input(translations.spawn_custom_ped, {"keplerspawnpedmdl"}, "", function(input)
    spawn_ped(util.joaat(input))
end, custom_ped_string)


local animal_hashes = {1302784073, -1011537562, 802685111, util.joaat("a_c_chimp"), -1589092019, 1794449327, -664053099, -1920284487, util.joaat("a_c_retriever"), util.joaat('a_c_cow'), util.joaat("a_c_rabbit_01")}
local animal_options = {translations.lester, translations.rat, translations.fish, translations.chimp, translations.stingray, translations.hen, translations.deer, translations.killer_whale, translations.dog, translations.cow, translations.rabbit}
spawn_peds_root:list_action(translations.presets, {"keplerspawnped"}, "", animal_options, function(index, value, click_type)
    spawn_ped(animal_hashes[index])
end)

spawn_peds_root:divider(translations.settings)
local spawn_peds_section_settings = spawn_peds_root:list(translations.settings, {}, "")
spawn_peds_section_settings:slider(translations.spawn_count, {"keplerpedspawnct"}, "", 1, 10, 1, 1, function(s)
    num_peds_to_spawn = s
end)

spawn_peds_section_settings:toggle(translations.spawn_as_pet, {"keplerspawnaspet"}, "", function(on)
    spawn_ped_as_pet = on
end, true)

-- SECTION: VEHICLES

vehicle_chaos = false
vehicles_root:toggle(translations.vehicle_chaos, {translations.vehicle_chaos_cmd}, "", function(on)
    vehicle_chaos = on
    mod_uses("vehicle", if on then 1 else -1)
end)

vehicles_root:action(translations.teleport_all_to_me, {"keplertpallvehs"}, "", function(click_type)
    local c = GET_ENTITY_COORDS(players.user_ped(), false)
    all_vehs = entities.get_all_vehicles_as_handles()
    for k,veh in pairs(all_vehs) do
        if not IS_PED_A_PLAYER(GET_PED_IN_VEHICLE_SEAT(veh, -1, false)) then
            SET_ENTITY_COORDS(veh, c.x, c.y, c.z)
        end
    end
end)

local traffic_options = {translations.normal, translations.halt, translations.reverse}
local traffic_mode = 1
local last_traffic_mode = 1
vehicles_root:textslider(translations.traffic, {"keplertraffic"}, "", traffic_options, function(index)
    traffic_mode = index 
    if last_traffic_mode == 1 and index ~= 1 then 
        mod_uses("vehicle", 1)
    else 
        mod_uses("vehicle", -1)
    end
end)

vehicles_root:action(translations.clear_all, {"keplerclearvehicles"}, translations.break_missions_warn, function()
    local ct = 0
    for k,ent in pairs(entities.get_all_vehicles_as_handles()) do
        entities.delete_by_handle(ent)
        ct += 1
    end
    say(ct .. translations.entities_removed)
end)

local function get_closest_vehicle(entity)
    local coords = GET_ENTITY_COORDS(entity, true)
    local vehicles = entities.get_all_vehicles_as_handles()
    -- init this at some ridiculously large number we will never reach, ez
    local closestdist = 1000000
    local closestveh = 0
    for k, veh in pairs(vehicles) do
        if veh ~= GET_VEHICLE_PED_IS_IN(PLAYER_PED_ID(), false) and GET_ENTITY_HEALTH(veh) ~= 0 then
            local vehcoord = GET_ENTITY_COORDS(veh, true)
            local dist = GET_DISTANCE_BETWEEN_COORDS(coords['x'], coords['y'], coords['z'], vehcoord['x'], vehcoord['y'], vehcoord['z'], true)
            if dist < closestdist then
                closestdist = dist
                closestveh = veh
            end
        end
    end
    return closestveh
end

vehicle_root:action(translations.find_closest_vehicle, {"keplerclosestv"}, "", function(on_click)
    local closestveh = get_closest_vehicle(players.user_ped())
    local driver = GET_PED_IN_VEHICLE_SEAT(closestveh, -1)
    if IS_VEHICLE_SEAT_FREE(closestveh, -1) then
        SET_PED_INTO_VEHICLE(players.user_ped(), closestveh, -1)
    else
        if not IS_PED_A_PLAYER(driver) then
            entities.delete_by_handle(driver)
            SET_PED_INTO_VEHICLE(players.user_ped(), closestveh, -1)
        elseif ARE_ANY_VEHICLE_SEATS_FREE(closestveh) then
            for i=0, 10 do
                if IS_VEHICLE_SEAT_FREE(closestveh, i) then
                    SET_PED_INTO_VEHICLE(players.user_ped(), closestveh, i)
                end
            end
        else
            notify(translations.teleport_into_closest_vehicle_error)
        end
    end
end)

local beep_cars = false
vehicles_root:toggle(translations.honk, {}, "", function(on)
    beep_cars = on
    mod_uses("vehicle", if on then 1 else -1)
end)



vehicles_root:divider(translations.settings)
local vehicles_settings_subsection = vehicles_root:list(translations.settings, {}, "")
local vc_gravity = true
vehicles_settings_subsection:toggle(translations.vehicle_chaos_gravity, {"keplervcgravity"}, "", function(on)
    vc_gravity = on
end, true)

local vc_speed = 100
vehicles_settings_subsection:slider(translations.vehicle_chaos_speed, {"keplervcspeed"}, "", 30, 300, 100, 10, function(s)
  vc_speed = s
end)

vehicles_thread = util.create_tick_handler(function (thr)
    if vehicle_uses > 0 then
        all_vehicles = entities.get_all_vehicles_as_handles()
        for k,veh in pairs(all_vehicles) do
            local driver = GET_PED_IN_VEHICLE_SEAT(veh, -1)
            -- FOR THINGS THAT SHOULD NOT WORK ON CARS WITH PLAYERS DRIVING THEM
            if player_car_hdl ~= veh and (not IS_PED_A_PLAYER(driver)) or driver == 0 then

                if yeetsubmarines then
                    if IS_VEHICLE_MODEL(veh, util.joaat("kosatka")) and IS_ENTITY_IN_WATER(veh) then
                        request_control_of_entity_once(veh)
                        SET_ENTITY_MAX_SPEED(veh, 10000)
                        APPLY_FORCE_TO_ENTITY(veh, 1,  0.0, 0.0, 10000, 0, 0, 0, 0, true, false, true, false, true)
                    end 
                end

                if inferno then
                    local coords = GET_ENTITY_COORDS(veh, true)
                    ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], 7, 100.0, true, false, 1.0)
                end

                if beep_cars then
                    if not IS_HORN_ACTIVE(veh) then
                        START_VEHICLE_HORN(veh, 200, util.joaat("HELDDOWN"), true)
                    end
                end

                if vehicle_chaos then
                    SET_VEHICLE_OUT_OF_CONTROL(veh, false, true)
                    SET_VEHICLE_FORWARD_SPEED(veh, vc_speed)
                    SET_VEHICLE_GRAVITY(veh, vc_gravity)
                end
                
                pluto_switch traffic_mode do 
                    case 1:
                        break
                    case 2:
                        BRING_VEHICLE_TO_HALT(veh, 0.0, -1, true)
                        break 
                    case 3:
                        local ped = GET_PED_IN_VEHICLE_SEAT(veh, -1)
                        TASK_VEHICLE_TEMP_ACTION(ped, veh, 3, -1)
                        break 
                end
                if ascend_vehicles then
                    SET_VEHICLE_UNDRIVEABLE(veh, true)
                    SET_VEHICLE_GRAVITY(veh, false)
                    APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(veh, 4, 5.0, 0.0, 0.0, true, true, true, true)
                end

            end
        end
    end
end)

-- SECTION: OBJECTS

objects_root:action(translations.clear_all, {"keplerclearobjects"}, translations.break_missions_warn, function()
    local ct = 0
    for k,ent in pairs(entities.get_all_objects_as_handles()) do
        entities.delete_by_handle(ent)
        ct += 1
    end
    say(ct .. translations.entities_removed)
end)

objects_root:divider(translations.settings)
local objects_settings_subsection = objects_root:list(translations.settings, {}, "")

-- SECTION: PICKUPS

pickups_root:action(translations.teleport_all_to_me, {"keplergetpickups"}, "", function()
    for k,p in pairs(entities.get_all_pickups_as_handles()) do
        if tp_all_pickups then
            local pos = GET_ENTITY_COORDS(tp_pickup_tar, true)
            SET_ENTITY_COORDS_NO_OFFSET(p, pos['x'], pos['y'], pos['z'], true, false, false)
        end
    end
end)

pickups_root:action(translations.clear_all, {"keplerclearpickups"}, translations.break_missions_warn, function()
    local ct = 0
    for k,ent in pairs(entities.get_all_pickups_as_handles()) do
        entities.delete_by_handle(ent)
        ct += 1
    end
    say(ct .. translations.entities_removed)
end)



pickups_root:divider(translations.settings)
local pickups_settings_subsection = pickups_root:list(translations.settings, {}, "")


-- SECTION: VEHICLE
local veh_fly_previous_car = 0
local veh_fly_speed = 100
local veh_fly = false
local veh_fly_plane = 0

local player_car_hdl = 0
util.create_tick_handler(function()
    player_car_hdl = entities.get_user_vehicle_as_handle()
end)

vehicle_root:toggle_loop(translations.hold_shift_to_drift, {"keplerdrift"}, "", function(on)
    if IS_CONTROL_PRESSED(21, 21) then
        SET_VEHICLE_REDUCE_GRIP(player_car_hdl, true)
        SET_VEHICLE_REDUCE_GRIP_LEVEL(player_car_hdl, 0.0)
    else
        SET_VEHICLE_REDUCE_GRIP(player_car_hdl, false)
    end
end)

vehicle_root:toggle_loop(translations.draw_car_angle, {"keplercarangle"}, "", function()
    if player_car_hdl ~= 0 and IS_PED_IN_ANY_VEHICLE(players.user_ped(), true) then
        local ang = math.abs(math.ceil(math.abs(GET_ENTITY_ROTATION(player_cur_car, 0).z) - math.abs(GET_GAMEPLAY_CAM_ROT(0).z)))
        directx.draw_text(0.5, 1.0, tostring(ang) .. '°', 5, 1.4, {r=1, g=1, b=1, a=1}, true)
    end
end)

local dow_block = 0
local driveonwater = false
local doa_ht = 0
local drive_on_air = false
local driveonwater_toggle

drive_on_air_toggle = vehicle_root:toggle(translations.drive_on_air, {"keplerairdrive"}, "", function(on)
    drive_on_air = on
    if on then
        local pos = players.get_position(players.user())
        doa_ht = pos['z']
        say(translations.drive_on_air_instructions)
        if driveonwater then
            menu.set_value(driveonwater_toggle, false)
        end
    end
end)

driveonwater_toggle = vehicle_root:toggle(translations.drive_on_water, {"keplerwaterdrive"}, "", function(on)
    driveonwater = on
    if on then
        if drive_on_air then
            menu.set_value(drive_on_air_toggle, false)
        end
    else
        if not drive_on_air and not walkonwater then
            SET_ENTITY_COORDS_NO_OFFSET(dow_block, 0, 0, 0, false, false, false)
        end
    end
end)


local vehiclefly = menu.toggle_loop(vehicle_root, translations.vehicle_fly, {"keplerfly"}, "", function(on)
    if player_car_hdl ~= 0 and IS_PED_IN_ANY_VEHICLE(players.user_ped(), true) then
        SET_ENTITY_MAX_SPEED(player_car_hdl, veh_fly_speed)
        local c = GET_GAMEPLAY_CAM_ROT(0)
        DISABLE_CINEMATIC_BONNET_CAMERA_THIS_UPDATE()
        SET_ENTITY_ROTATION(player_car_hdl, c.x, 0, c.z, 0, true)
        any_c_pressed = false
        --W
        local x_vel = 0.0
        local y_vel = 0.0
        local z_vel = 0.0
        if IS_CONTROL_PRESSED(32, 32) then
            x_vel = veh_fly_speed
        end 
        --A
        if IS_CONTROL_PRESSED(63, 63) then
            y_vel = -veh_fly_speed
        end
        --S
        if IS_CONTROL_PRESSED(33, 33) then
            x_vel = -veh_fly_speed
        end
        --D
        if IS_CONTROL_PRESSED(64, 64) then
            y_vel = veh_fly_speed
        end
        if x_vel == 0.0 and y_vel == 0.0 and z_vel == 0.0 then
            SET_ENTITY_VELOCITY(player_car_hdl, 0.0, 0.0, 0.0)
        else
            local angs = GET_ENTITY_ROTATION(player_car_hdl, 0)
            local spd = GET_ENTITY_VELOCITY(player_car_hdl)
            if angs.x > 1.0 and spd.z < 0 then
                z_vel = -spd.z 
            else
                z_vel = 0.0
            end
            APPLY_FORCE_TO_ENTITY(player_car_hdl, 3, y_vel, x_vel, z_vel, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
        end
    end
end, function()
    if player_car_hdl ~= 0 then
        SET_ENTITY_HAS_GRAVITY(player_car_hdl, true)
    end
end)

vehicle_root:action(translations.force_eject, {"eject"}, "", function(click_type)
    CLEAR_PED_TASKS_IMMEDIATELY(players.user_ped())
    TASK_LEAVE_ANY_VEHICLE(players.user_ped(), 0, 16)
end)

local ped = 0
vehicle_root:action(translations.drive_to_me, {"drivetome"}, "", function(click_type)
    local lastcar = GET_PLAYERS_LAST_VEHICLE()
    if lastcar ~= 0 then
        local owner_ped = players.user_ped()
        local lastcar = GET_PLAYERS_LAST_VEHICLE()
        local coords = GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(owner_ped, 0.0, 5.0, 0.0)
        local ped_hash = -67533719
        request_model_load(ped_hash)
        local ped = entities.create_ped(32, ped_hash, coords, GET_ENTITY_HEADING(owner_ped))
        local blip = ADD_BLIP_FOR_ENTITY(ped)
        SET_BLIP_COLOUR(blip, 7)
        SET_ENTITY_VISIBLE(ped, false, 0)
        SET_ENTITY_INVINCIBLE(ped, true)
        SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
        SET_PED_FLEE_ATTRIBUTES(ped, 0, false)
        SET_PED_INTO_VEHICLE(ped, lastcar, -1)
        TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(ped, lastcar, coords['x'], coords['y'], coords['z'], 300.0, 786996, 5)
        util.create_thread(function()
            while true do 
                if not ped then return end
                local p_coords = GET_ENTITY_COORDS(players.user_ped(), true)
                local t_coords = GET_ENTITY_COORDS(lastcar, true)
                local dist = GET_DISTANCE_BETWEEN_COORDS(p_coords['x'], p_coords['y'], p_coords['z'], t_coords['x'], t_coords['y'], t_coords['z'], false)
                if lastcar == 0 or GET_ENTITY_HEALTH(lastcar) == 0 or dist <= 5 then
                    BRING_VEHICLE_TO_HALT(lastcar, 5.0, 2, true)
                    SET_VEHICLE_DOOR_OPEN(lastcar, 0, false, true)
                    entities.delete_by_handle(ped)
                    ped = 0
                    util.remove_blip(blip)
                    util.stop_thread()
                end
                util.yield()
            end
        end)
    end
end)

vehicle_root:click_slider(translations.dirt, {"vdirt"}, "", 0, 15, 0, 1, function(s)
    if player_car_hdl ~= 0 then
        SET_VEHICLE_DIRT_LEVEL(player_car_hdl, s)
    end
end)

local v_remove_options = {translations.wheels, translations.windows}
vehicle_root:textslider(translations.remove, {"keplervremove"}, "", v_remove_options, function(index)
    if player_car_hdl ~= 0 then 
        if index == 1 then 
            for i=0,47 do
                entities.detach_wheel(entities.get_user_vehicle_as_pointer(false), i)
            end
        else
            for i=0,7 do
                SMASH_VEHICLE_WINDOW(player_car_hdl, i)
            end
        end
    end
end)

vehicle_root:toggle_loop(translations.rainbow_headlights, {"keplerrgbhd"}, "", function(on)
    if player_car_hdl ~= 0 then 
        TOGGLE_VEHICLE_MOD(player_car_hdl, 22, true)
        for i=1, 12 do
            SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(player_car_hdl, i)  
            util.yield(500)
        end
    end
end)

vehicle_root:divider(translations.settings)
local vehicle_section_settings_root = vehicle_root:list(translations.settings, {'keplervehsetting'}, "")

vehicle_section_settings_root:slider(translations.vehicle_fly_speed, {"keplerveh_fly_speed"}, "", 1, 3000, 100, 1, function(s)
    veh_fly_speed = s
end)


-- SECTION: ONLINE
local detection_follow = false 
local known_players_this_game_session = {}
local do_vpn_warn = false 
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
                    local ped = GET_PLAYER_PED_SCRIPT_INDEX(pid)
                    if v3.distance(last_pos, cur_pos) >= 500 then
                        if IS_PLAYER_PLAYING(pid) and not players.is_in_interior(pid) and not NETWORK_IS_PLAYER_FADING(pid) and not IS_PLAYER_DEAD(pid) and cur_pos.z > 0 and IS_ENTITY_VISIBLE(ped) then
                            say(players.get_name(pid) .. translations.teleport_detection_notice)
                        end
                    end
                end
            end
            last_pos = players.get_position(pid)
            util.yield(1000)
        end
    end)
end

function nuke_player(pid)
    local p_ped = GET_PLAYER_PED_SCRIPT_INDEX(pid)

    for _, v_ptr in pairs(entities.get_all_vehicles_as_pointers()) do 
        local v_pos = entities.get_position(v_ptr)
        if v3.distance(GET_ENTITY_COORDS(p_ped), v_pos) < 200 then
            SET_ENTITY_HEALTH(entities.pointer_to_handle(v_ptr), 0.0)
            ADD_EXPLOSION(v_pos.x, v_pos.y, v_pos.z, 17, 1.0, true, false, 100.0, false)
        end
    end

    for _, p_ptr in pairs(entities.get_all_peds_as_pointers()) do 
        local p_pos = entities.get_position(p_ptr)
        if v3.distance(GET_ENTITY_COORDS(p_ped), p_pos) < 200 then 
            SET_ENTITY_HEALTH(entities.pointer_to_handle(p_ptr), 0.0)
            ADD_EXPLOSION(p_pos.x, p_pos.y, p_pos.z, 17, 1.0, true, false, 100.0, false)
        end
    end

    local c = players.get_position(pid)
     ADD_EXPLOSION(c.x, c.y, c.z, 82, 1.0, true, false, 100.0, false)

    for _, v_ptr in pairs(entities.get_all_objects_as_pointers()) do 
        local o_pos = entities.get_position(v_ptr)
        if v3.distance(GET_ENTITY_COORDS(p_ped), o_pos) < 20 then
            ADD_EXPLOSION(o_pos.x, o_pos.y, o_pos.z, 17, 1.0, false, true, 0.0, false)
            util.yield(10)
        end
    end
end

-- credit to nowiry
local function set_entity_face_entity(entity, target, usePitch)
    local pos1 = GET_ENTITY_COORDS(entity, false)
    local pos2 = GET_ENTITY_COORDS(target, false)
    local rel = v3.new(pos2)
    rel:sub(pos1)
    local rot = rel:toRot()
    if not usePitch then
        SET_ENTITY_HEADING(entity, rot.z)
    else
        SET_ENTITY_ROTATION(entity, rot.x, rot.y, rot.z, 2, 0)
    end
end

local function ram_ped_with(ped, vehicle, offset, sog)
    request_model_load(vehicle)
    local front = GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, offset, 0.0)
    local veh = entities.create_vehicle(vehicle, front, GET_ENTITY_HEADING(ped)+180)
    set_entity_face_entity(veh, ped, true)
    if ram_onground then
        PLACE_OBJECT_ON_GROUND_PROPERLY(veh)
    end
    SET_VEHICLE_ENGINE_ON(veh, true, true, true)
    SET_VEHICLE_FORWARD_SPEED(veh, 100.0)
end

function get_closest_ped(coords)
    local closest = nil
    local closest_dist = 1000000
    local this_dist = 0
    for _, ped in pairs(entities.get_all_peds_as_handles()) do 
        this_dist = v3.distance(coords, GET_ENTITY_COORDS(ped))
        if this_dist < closest_dist and not IS_PED_A_PLAYER(ped) and GET_ENTITY_HEALTH(ped) > 0 then
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

function do_ped_suicide(ped)
    request_control_of_entity_once(ped)
    CLEAR_PED_TASKS_IMMEDIATELY(ped)
    SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
    GIVE_WEAPON_TO_PED(ped, util.joaat("weapon_pistol"), 1, false, true)
    SET_CURRENT_PED_WEAPON(ped, util.joaat("weapon_pistol"), true)
    request_anim_dict("mp_suicide")
    util.yield(1000)
    local start_time = os.time()
    -- either wait till the ped is standing still, or 3 seconds, whichever is first
    while GET_ENTITY_SPEED(ped) > 1 and os.time() - start_time < 3 do 
        util.yield()
    end
    TASK_PLAY_ANIM(ped, "mp_suicide", "pistol", 8.0, 8.0, -1, 2, 0.0, false, false, false)
    util.yield(800)
    SET_ENTITY_HEALTH(ped, 0.0)
    util.yield(10000)
    entities.delete_by_handle(ped)
end

local vehicle_hashes = {util.joaat("dune2"), util.joaat("speedo2"), util.joaat("krieger"), util.joaat("kuruma"), util.joaat('insurgent'), util.joaat('neon'), util.joaat('akula'), util.joaat('alphaz1'), util.joaat('rogue'), util.joaat('oppressor2'), util.joaat('hydra')}
local vehicle_names = {translations.space_docker, translations.clown_van, translations.krieger, translations.kuruma, translations.insurgent, translations.neon, translations.akula, translations.alphaz1, translations.rogue, translations.oppressor2, translations.hydra}

local function max_out_car(veh)
    for i=0, 47 do
        num = GET_NUM_VEHICLE_MODS(veh, i)
        SET_VEHICLE_MOD(veh, i, num -1, true)
    end
end

local function give_vehicle(pid, hash)
    request_model_load(hash)
    local plyr = GET_PLAYER_PED_SCRIPT_INDEX(pid)
    local c = GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(plyr, 0.0, 5.0, 0.0)
    local car = entities.create_vehicle(hash, c, GET_ENTITY_HEADING(plyr))
    max_out_car(car)
    SET_ENTITY_INVINCIBLE(car)
    SET_VEHICLE_DOOR_OPEN(car, 0, false, true)
    SET_VEHICLE_DOOR_LATCHED(car, 0, false, false, true)
end

local function tp_player_car_to_coords(pid, coord)
    local name = players.get_name(pid)
    local car = GET_VEHICLE_PED_IS_IN(GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
    if car ~= 0 then
        request_control_of_entity(car)
        if NETWORK_HAS_CONTROL_OF_ENTITY(car) then
            for i=1, 3 do
                SET_ENTITY_COORDS_NO_OFFSET(car, coord['x'], coord['y'], coord['z'], false, false, false)
            end
        end
    end
end

local function kick_from_veh(pid)
    menu.trigger_commands("vehkick" .. players.get_name(pid))
end

local function npc_jack(target, nearest)
    npc_jackthr = util.create_thread(function(thr)
        local player_ped = GET_PLAYER_PED_SCRIPT_INDEX(target)
        local last_veh = GET_VEHICLE_PED_IS_IN(player_ped, true)
        kick_from_veh(target)
        local st = os.time()
        while not IS_VEHICLE_SEAT_FREE(last_veh, -1) do 
            if os.time() - st >= 10 then
                notify(translations.failed_to_free_seat)
                util.stop_thread()
            end
            util.yield()
        end
        local hash = 0x9C9EFFD8
        request_model_load(hash)
        local coords = GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, -2.0, 0.0, 0.0)
        local ped = entities.create_ped(28, hash, coords, 30.0)
        SET_ENTITY_INVINCIBLE(ped, true)
        SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
        SET_PED_FLEE_ATTRIBUTES(ped, 0, false)
        SET_PED_COMBAT_ATTRIBUTES(ped, 46, true)
        SET_PED_INTO_VEHICLE(ped, last_veh, -1)
        SET_VEHICLE_ENGINE_ON(last_veh, true, true, false)
        TASK_VEHICLE_DRIVE_TO_COORD(ped, last_veh, math.random(1000), math.random(1000), math.random(100), 100, 1, GET_ENTITY_MODEL(last_veh), 786996, 5, 0)
        util.stop_thread()
    end)
end

local attacker_gun = util.joaat('weapon_pistol')
local number_of_attackers = 1
local attacker_godmode = false
local attacker_takes_critical_hits = true 
local attacker_health = 100

local function send_aircraft_attacker(vhash, phash, pid, num_attackers)
    local target_ped = GET_PLAYER_PED_SCRIPT_INDEX(pid)
    local coords = GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(target_ped, 1.0, 0.0, 500.0)
    request_model_load(vhash)
    request_model_load(phash)
    local first_ped_relationship_hash = 0
    for i=1, number_of_attackers do
        coords.x = coords.x + i*2
        coords.y = coords.y + i*2
        local aircraft = entities.create_vehicle(vhash, coords, 0.0)
        CONTROL_LANDING_GEAR(aircraft, 3)
        SET_HELI_BLADES_FULL_SPEED(aircraft)
        SET_VEHICLE_FORWARD_SPEED(aircraft, GET_VEHICLE_ESTIMATED_MAX_SPEED(aircraft))
        if godmode_attacker then
            SET_ENTITY_INVINCIBLE(aircraft, true)
        end
        for i= -1, GET_VEHICLE_MODEL_NUMBER_OF_SEATS(vhash) - 2 do
            local ped = entities.create_ped(28, phash, coords, 30.0)
            if i == 1 then 
                first_ped_relationship_hash = GET_PED_RELATIONSHIP_GROUP_HASH(ped)
            else
                SET_PED_RELATIONSHIP_GROUP_HASH(ped, first_ped_relationship_hash)
            end
            local blip = ADD_BLIP_FOR_ENTITY(ped)
            SET_BLIP_COLOUR(blip, 61)
            if i == -1 then
                TASK_PLANE_MISSION(ped, aircraft, 0, target_ped, 0, 0, 0, 6, 0.0, 0, 0.0, 50.0, 40.0)
            end
            SET_PED_COMBAT_ATTRIBUTES(ped, 5, true)
            SET_PED_COMBAT_ATTRIBUTES(ped, 46, true)
            SET_PED_INTO_VEHICLE(ped, aircraft, i)
            TASK_COMBAT_PED(ped, target_ped, 0, 16)
            SET_PED_ACCURACY(ped, 100.0)
            SET_PED_COMBAT_ABILITY(ped, 2)
        end
    end
end


local function send_attacker(hash, pid, givegun, num_attackers, atkgun)
    local this_attacker
    local target_ped = GET_PLAYER_PED_SCRIPT_INDEX(pid)
    coords = GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(target_ped, 0.0, -3.0, 0.0)
    if hash ~= 'CLONE' then
        request_model_load(hash)
    end
    local first_ped_relationship_hash = 0
    for i=1, number_of_attackers do
        if hash ~= 'CLONE' then
            this_attacker = entities.create_ped(28, hash, coords, math.random(0, 270))
        else
            this_attacker = CLONE_PED(target_ped, true, false, true)
        end

        if i == 1 then 
            first_ped_relationship_hash = GET_PED_RELATIONSHIP_GROUP_HASH(this_attacker)
        else
            SET_PED_RELATIONSHIP_GROUP_HASH(this_attacker, first_ped_relationship_hash)
        end

        local blip = ADD_BLIP_FOR_ENTITY(this_attacker)
        SET_BLIP_COLOUR(blip, 61)
        if attacker_godmode then
            SET_ENTITY_INVINCIBLE(this_attacker, true)
        end
        TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(this_attacker, true)
        SET_PED_ACCURACY(this_attacker, 100.0)
        SET_PED_COMBAT_ABILITY(this_attacker, 2)
        SET_PED_AS_ENEMY(this_attacker, true)
        SET_PED_FLEE_ATTRIBUTES(this_attacker, 0, false)
        SET_PED_COMBAT_ATTRIBUTES(this_attacker, 46, true)
        TASK_COMBAT_PED(this_attacker, target_ped, 0, 16)
        if attacker_gun ~= 0 then
            GIVE_WEAPON_TO_PED(this_attacker, attacker_gun, 1000, false, true)
        end
        SET_PED_MAX_HEALTH(this_attacker, attacker_health)
        SET_ENTITY_HEALTH(this_attacker, attacker_health)
        SET_PED_SUFFERS_CRITICAL_HITS(this_attacker, attacker_takes_critical_hits)
    end
end

local attacker_hashes = {1302784073, 0xFBF98469, 0x9D0087A8, 0x61D201B3, 0x38430167, 0x1250D7BA}
local attacker_options = {translations.lester, translations.agent14, translations.gangster, translations.american, translations.marston, translations.mountain_lion}

-- CODE: PLAYER ACTION HANDLING
local function set_up_player_actions(pid)
    local player_root = menu.player_root(pid)
    local ragdoll_options = {translations.non_fatal, translations.fatal}
    player_root:divider("Kepler")
    local player_vehicle_root = player_root:list(translations.vehicle, {"keplerpv"}, "")

    local tp_options = {translations.to_me, translations.to_waypoint, translations.maze_bank, translations.underwater, translations.high_up, translations.lsc, translations.scary_cell, translations.large_cell, translations.luxury_autos, translations.underwater_and_lock_doors}
    player_vehicle_root:list_action(translations.teleport, {"keplertpv"}, "", tp_options, function(index, value, click_type)
        local car = GET_VEHICLE_PED_IS_IN(GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
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

    player_vehicle_root:action(translations.remove_stickybombs, {"keplernosticky"}, "", function(click_type)
        local car = GET_VEHICLE_PED_IS_IN(GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        REMOVE_ALL_STICKY_BOMBS_FROM_ENTITY(car)
    end)

    local explosion_types = {40, 13, 12, 70}
    local explosion_type = 13
    local explosion_options = {translations.regular, translations.water_jet, translations.fire_jet, translations.atomizer}
    local player_explosions_root = player_root:list(translations.explosions, {}, '')
    local player_friendly_root = player_root:list(translations.friendly, {'keplerbefriend'}, '')
    local player_trolling_root = player_root:list(translations.trolling, {'keplertroll'}, '')
    player_explosions_root:list_select(translations.type, {'keplerexploptype'}, "", explosion_options, 1, function(index)
        explosion_type = explosion_types[index]
    end)

    player_explosions_root:action(translations.explode_once, {'keplerexplop'}, '', function()
        local target_ped = GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local coords = GET_ENTITY_COORDS(target_ped, false)
        ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], explosion_type, 100.0, true, false, 0.0)
    end)

    player_explosions_root:toggle_loop(translations.loop, {'keplerloopexplop'}, '', function(on)
        local target_ped = GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local coords = GET_ENTITY_COORDS(target_ped, false)
        ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], explosion_type, 100.0, true, false, 0.0)
    end)

    local flip_options = {translations.horizontally, translations.vertically}
    player_vehicle_root:textslider(translations.flip_vehicle, {}, "", flip_options, function(index)
        local car = GET_VEHICLE_PED_IS_IN(GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            request_control_of_entity(car)
            local rot = GET_ENTITY_ROTATION(car, 0)
            local vel = GET_ENTITY_VELOCITY(car)
            if index == 1 then 
                SET_ENTITY_ROTATION(car, rot['x'], rot['y'], rot['z']+180, 0, true)
            else
                SET_ENTITY_ROTATION(car, rot['x'], rot['y']+180, rot['z'], 0, true)
            end
            SET_ENTITY_VELOCITY(car, -vel['x'], -vel['y'], vel['z'])
        end
    end)

    player_vehicle_root:action(translations.yeet, {"kepleryeet"}, "", function(click_type)
        local car = GET_VEHICLE_PED_IS_IN(GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            request_control_of_entity(car)
            SET_ENTITY_MAX_SPEED(car, 10000000.0)
            APPLY_FORCE_TO_ENTITY(car, 1,  0.0, 0.0, 10000000, 0, 0, 0, 0, true, false, true, false, true)
        end
    end)

    player_vehicle_root:toggle_loop(translations.child_lock, {"keplerclock"}, "", function()
        local car = GET_VEHICLE_PED_IS_IN(GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            SET_VEHICLE_DOORS_LOCKED(car, 4)
        end
    end, function()
        if car ~= 0 then
            SET_VEHICLE_DOORS_LOCKED(car, 1)
        end
    end)

    local door_options = {translations.open, translations.close, translations._break}
    player_vehicle_root:textslider(translations.door_control, {"keplerdoorctrl"}, "", door_options, function(index, value, click_type)
        local car = GET_VEHICLE_PED_IS_IN(GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            request_control_of_entity(car)
            local d = GET_NUMBER_OF_VEHICLE_DOORS(car)
            for i=0, d do
                pluto_switch index do
                    case 1: 
                        SET_VEHICLE_DOOR_OPEN(car, i, false, true)
                        break
                    case 2:
                        SET_VEHICLE_DOOR_SHUT(car, i, true)
                        break
                    case 3:
                        SET_VEHICLE_DOOR_BROKEN(car, i, false)
                        break
                end
            end
        end
    end)

    local godmode_options = {translations.give, translations.remove}
    player_vehicle_root:textslider(translations.godmode, {"keplergodmodev"}, "", godmode_options, function(index)
        local car = GET_VEHICLE_PED_IS_IN(GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            request_control_of_entity(car)
            SET_ENTITY_INVINCIBLE(car, if index == 1 then true else false)
            SET_VEHICLE_CAN_BE_VISIBLY_DAMAGED(car, if index == 1 then false else true)
        end
    end)

    local engine_off_options = {translations.regular, translations.emp}
    player_vehicle_root:textslider(translations.turn_engine_off, {}, "", engine_off_options, function(index)
        local car = GET_VEHICLE_PED_IS_IN(GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            local c = GET_ENTITY_COORDS(car)
            if index == 1 then 
                request_control_of_entity(car)
                SET_VEHICLE_ENGINE_ON(car, false, true, false)
            else
                ADD_EXPLOSION(c.x, c.y, c.z, 83, 100.0, false, true, 0.0)
            end
        end
    end)

    player_vehicle_root:click_slider(translations.top_speed, {"keplervtopspeed"}, "", -10000, 10000, 200, 50, function(s)
        local car = GET_VEHICLE_PED_IS_IN(GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            request_control_of_entity(car)
            MODIFY_VEHICLE_TOP_SPEED(car, s)
            SET_ENTITY_MAX_SPEED(car, s)
        end
    end)

    player_vehicle_root:toggle(translations.invisible_vehicle, {"keplerinvisv"}, "", function(on)
        local car = GET_VEHICLE_PED_IS_IN(GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            request_control_of_entity(car)
            if on then
                SET_ENTITY_ALPHA(car, 255)
                SET_ENTITY_VISIBLE(car, false, 0)
            else
                SET_ENTITY_ALPHA(car, 0)
                SET_ENTITY_VISIBLE(car, true, 0)
            end
        end
    end)

    player_vehicle_root:toggle_loop(translations.brake, {"keplerebrake"}, "", function(on)
        local car = GET_VEHICLE_PED_IS_IN(GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            request_control_of_entity(car)
            SET_VEHICLE_HANDBRAKE(car, on)
        end
    end)


    player_root:toggle(translations.ghost_to_me, {"keplerghost"}, "", function(on)
        SET_REMOTE_PLAYER_AS_GHOST(pid, on)
    end)

    player_root:text_input(translations.send_pm, {"keplerpm"}, "", function(message)
        if #message == 0 then 
            return 
        end
        local from_msg = "[To you] " .. message
        local to_msg = "[To " .. players.get_name(pid) .. '] ' .. message
        if string.len(from_msg) > 254 or string.len(to_msg) > 254 then 
            notify(translations.pm_too_long)
        else
            chat.send_targeted_message(pid, players.user(), from_msg, true)
            chat.send_message(to_msg, true, true, false)
            menu.trigger_commands("keplerpm".. players.get_name(pid) .. " ")
        end
    end)

    local player_attacker_root = player_trolling_root:list(translations.attackers, {}, '')

    player_attacker_root:list_action(translations.normal_presets, {}, "", attacker_options, function(index, value, click_type)
        send_attacker(attacker_hashes[index], pid, true, num_attackers, attacker_gun)
    end)

    local specialatk_options = {translations.fighter_jets}
    player_attacker_root:list_action(translations.special_presets, {}, "", specialatk_options, function(index, value, click_type)
            pluto_switch index do
                case 1:
                    send_aircraft_attacker(util.joaat('lazer'), -163714847, pid, num_attackers)
                    break
            end
    end)

    player_attacker_root:action(translations.spawn_clone_as_attacker, {}, '', function()
        send_attacker("CLONE", pid, true, num_attackers, attacker_gun)
    end)

    player_attacker_root:divider(translations.design)

    player_attacker_root:text_input(translations.custom_model, {"keplerattackercustom"}, '', function(mdl)
        send_attacker(util.joaat(mdl), pid, true, num_attackers, attacker_gun)
    end, "a_c_retriever")

    player_attacker_root:slider(translations.number_of_attackers, {"keplernattackers"}, "", 1, 10, 1, 1, function(s)
        number_of_attackers = s
    end)

    player_attacker_root:list_select(translations.weapon_to_give_to_attackers, {translations.weapon_to_give_to_attackers}, "", gun_names, 1, function(index, value, click_type)
        attacker_gun = gun_hashes[index]
    end)

    player_attacker_root:toggle(translations.godmode, {}, "", function(on)
        godmode_attacker = on
    end)

    player_attacker_root:toggle(translations.suffer_crits, {}, '', function(on)
        attacker_takes_critical_hits = on
    end, true)

    player_attacker_root:slider(translations.health, {}, "", 1, 10000, 100, 1, function(s)
        attacker_health = s
      end)


    player_trolling_root:textslider(translations.ragdoll, {"keplerragdoll"}, "", ragdoll_options, function(index)
        local coords = GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(GET_PLAYER_PED_SCRIPT_INDEX(pid), 0.0, 0.0, 2.8)
        if index == 1 then 
            ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], 70, 100.0, false, true, 0.0)
        else
            ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], 47, 100.0, false, true, 0.0)
        end
    end)

    local crush_vehicle_hashes = {util.joaat('flatbed'), util.joaat('faggio'), util.joaat('speedo2'), util.joaat('brickade')}
    local crush_vehicle_names = {translations.truck, translations.faggio, translations.clown_van, translations.brickade}
    player_trolling_root:textslider(translations.crush, {"keplercrush"}, "", crush_vehicle_names, function(index, value, click_type)
        local hash = crush_vehicle_hashes[index]
        local target_ped = GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local coords = GET_ENTITY_COORDS(target_ped, false)
        coords.z = coords['z'] + 20.0
        request_model_load(hash)
        local veh = entities.create_vehicle(hash, coords, 0.0)
    end)

    local ram_vehicle_hashes = {util.joaat('brickade'), util.joaat("flatbed"), util.joaat("bus")}
    local ram_vehicle_names = {translations.brickade, translations.flatbed, translations.bus}
    player_trolling_root:textslider(translations.ram, {"keplerram"}, "", ram_vehicle_names, function(index, value, click_type)
        ram_ped_with(GET_PLAYER_PED_SCRIPT_INDEX(pid), ram_vehicle_hashes[index], math.random(5, 15))
    end)

    local kidnap_options = {translations.van, translations.cargobob}
    player_trolling_root:textslider(translations.kidnap, {"keplerkidnap"}, "", kidnap_options, function(index, value, click_type)
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
        local user_ped = GET_PLAYER_PED_SCRIPT_INDEX(pid)
        request_model_load(v_hash)
        request_model_load(p_hash)
        local c = GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(user_ped, 0.0, 2.0, 0.0)
        local truck = entities.create_vehicle(v_hash, c, GET_ENTITY_HEADING(user_ped))
        local driver = entities.create_ped(5, p_hash, c, 0)
        SET_PED_INTO_VEHICLE(driver, truck, -1)
        SET_PED_FLEE_ATTRIBUTES(driver, 0, false)
        SET_ENTITY_INVINCIBLE(driver, true)
        SET_ENTITY_INVINCIBLE(truck, true)
        SET_PED_CAN_BE_DRAGGED_OUT(driver, false)
        SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(driver, true)
        util.yield(2000)
        if index == 1 then
            TASK_VEHICLE_DRIVE_TO_COORD(driver, truck, math.random(1000), math.random(1000), math.random(100), 100, 1, GET_ENTITY_MODEL(truck), 786996, 5, 0)
        elseif index == 2 then 
            TASK_HELI_MISSION(driver, truck, 0, 0, math.random(1000), math.random(1000), 1500, 4, 200.0, 0.0, 0, 100, 1000, 0.0, 16)
        end
    end)


    
    local spawn_on_player_options = {translations.arena, translations.desert}
    player_trolling_root:textslider(translations.spawn, {"keplerkidnap"}, "", spawn_on_player_options, function(index, value, click_type)
        local coords = players.get_position(pid)
        local hash
        if index == 1 then 
            hash = util.joaat("xs_terrain_set_dystopian_06")
            local dust = CREATE_OBJECT_NO_OFFSET(hash, coords['x'], coords['y'], coords['z']-4, true, false, false)
            FREEZE_ENTITY_POSITION(dust, true)
        else
            hash = util.joaat("xs_terrain_dyst_ground_07")
            request_model_load(hash)
            local dust = CREATE_OBJECT_NO_OFFSET(hash, coords['x'], coords['y'], coords['z']-36, true, false, false)
            FREEZE_ENTITY_POSITION(dust, true)
        end
    end)

    player_trolling_root:action(translations.nuke, {"keplernuke"}, "", function(on)
        nuke_player(pid)
    end)

    player_trolling_root:action(translations.spawn_hooker_clone, {"keplerhookerclone"}, "", function()
        local c = GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(GET_PLAYER_PED_SCRIPT_INDEX(pid), -5.0, 3.0, 0.0)
        local hooker = CLONE_PED(GET_PLAYER_PED_SCRIPT_INDEX(pid), true, false, true)
        SET_ENTITY_COORDS(hooker, c.x, c.y, c.z)
        TASK_START_SCENARIO_IN_PLACE(hooker, "WORLD_HUMAN_PROSTITUTE_HIGH_CLASS", 0, false)
    end)

    player_trolling_root:action(translations.suicide_closest_ped, {"keplersuicideclosest"}, "", function()
        local ped = get_closest_ped(players.get_position(pid), 100)
        if ped ~= nil then
            do_ped_suicide(ped)
        end
    end)

    player_trolling_root:action(translations.npc_jack_vehicle, {"keplercarjack"}, "", function(click_type)
        npc_jack(pid, false)
    end)


    player_trolling_root:toggle_loop(translations.never_drive_alone, {"keplerneverdrivealone"}, "", function()
        local p_ped = GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local c = players.get_position(pid)
        local v = GET_VEHICLE_PED_IS_IN(p_ped, false)
        if v ~= 0 and ARE_ANY_VEHICLE_SEATS_FREE(v) then 
            for i=0, GET_VEHICLE_MODEL_NUMBER_OF_SEATS(GET_ENTITY_MODEL(v)) do
                if IS_VEHICLE_SEAT_FREE(v, i, false) then 
                    local npc = CREATE_RANDOM_PED(c.x, c.y, c.z)
                    SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(npc, true)
                    SET_ENTITY_INVINCIBLE(npc, true)
                    SET_PED_INTO_VEHICLE(npc, v, i)
                    break
                end
            end
        end
    end)

    local player_spawn_vehicle_root = player_friendly_root:list(translations.give_vehicle, {}, '')
    local v_model = 'lazer'
    player_spawn_vehicle_root:text_input(translations.enter_model, {"keplergivevmodel"}, "", function(model)
        give_vehicle(pid, util.joaat(model))
    end, 'lazer')


    player_spawn_vehicle_root:list_action(translations.presets, {"keplergivev"}, "", vehicle_names, function(index, value, click_type)
        give_vehicle(pid, vehicle_hashes[index])
    end)
end

for _, pid in players.list(true, true, true) do 
    set_up_player_actions(pid)
end

players.on_join(function(pid)
    if players.get_name(pid) == "UndiscoveredPlayer" then 
        util.yield()
    end

    set_up_player_actions(pid)

    if players.user() == pid then 
        if not players.is_using_vpn(pid) and do_vpn_warn then 
            say(translations.no_vpn_warn_alert)
        end
    else
        -- detections
        start_teleport_detection_thread(pid)

        local ip = players.get_connect_ip(pid)
        if detection_follow then
            if table.contains(known_players_this_game_session, ip) then 
                say(players.get_name(pid) .. translations.follow_detection_notice)
            else
                known_players_this_game_session[#known_players_this_game_session + 1 ] = ip
            end
        end
    end
end)

main_root:divider(translations.misc)
local protections_root = online_root:list(translations.protections, {}, "")
local trolling_root = online_root:list(translations.trolling, {}, "")
local friendly_root = online_root:list(translations.friendly, {}, "")

-- SUBSECTION: PROTECTIONS
menu.toggle(protections_root, translations.no_vpn_warn, {"novpnwarn"}, "", function(on)
    do_vpn_warn = on
end, false)


local admin_bail = true
menu.toggle(protections_root, translations.bail_on_admin_join, {}, "", function(on)
    admin_bail = on
    while admin_bail do
        if util.is_session_started() then
            for _, pid in players.list(false, true, true) do 
                if players.is_marked_as_admin(pid) then 
                    say(translations.admin_detected)
                    menu.trigger_commands("quickbail")
                end    
            end
        end
        util.yield()
    end
end, true)

protections_root:toggle_loop(translations.auto_remove_bounty, {}, "", function()
    if util.is_session_started() then
        if memory.read_int(memory.script_global(1835502 + 4 + 1 + (players.user() * 3))) == 1 then
            memory.write_int(memory.script_global(2815059 + 1856 + 17), -1)
            memory.write_int(memory.script_global(2359296 + 1 + 5149 + 13), 2880000)
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
                        local blip = ADD_BLIP_FOR_COORD(pos.x, pos.y, pos.z)
                        SET_BLIP_SPRITE(blip, 548)
                        SET_BLIP_COLOUR(blip, 59)
                        SET_BLIP_ROTATION(blip, math.ceil(GET_ENTITY_HEADING(hdl)))
                        kosatka_missile_blips[hdl] = blip
                    else
                        SET_BLIP_ROTATION(kosatka_missile_blips[hdl], math.ceil(GET_ENTITY_HEADING(hdl)+180))
                        SET_BLIP_COORDS(kosatka_missile_blips[hdl], pos.x, pos.y, pos.z)
                    end
                    missile_ct += 1
                end
            end
            if missile_ct > 0 then 
                util.draw_debug_text(missile_ct .. translations.kosatka_missile_alert)
            end
            for hdl, blip in pairs(kosatka_missile_blips) do 
                if not DOES_ENTITY_EXIST(hdl) then
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
                    local blip = ADD_BLIP_FOR_COORD(cam_pos.x, cam_pos.y, cam_pos.z)
                    SET_BLIP_SPRITE(blip, 588)
                    SET_BLIP_COLOUR(blip, 59)
                    SET_BLIP_NAME_TO_PLAYER_NAME(blip, pid)
                    orbital_blips[pid] = blip
                else
                    SET_BLIP_COORDS(orbital_blips[pid], cam_pos.x, cam_pos.y, cam_pos.z)
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
        if orb_cannon_prop == nil or not DOES_ENTITY_EXIST(orb_cannon_prop) then
            local hash = util.joaat("h4_prop_h4_garage_door_01a")
            request_model_load(hash)
            orb_cannon_prop = entities.create_object(hash, {x=0, y=0, z=0})
            SET_ENTITY_HEADING(orb_cannon_prop, 125)
            SET_ENTITY_COORDS(orb_cannon_prop, 335.8, 4833.9, -59)
            FREEZE_ENTITY_POSITION(orb_cannon_prop, true)
        end
        util.yield()
    end
end)


antioppressor = false
menu.toggle(protections_root, translations.antioppressor, { translations.antioppressor_cmd}, "", function(on)
    antioppressor = on
    mod_uses("player", if on then 1 else -1)
end)
 
online_root:divider(translations.settings)
local online_section_settings = online_root:list(translations.settings, {}, "")

-- SUBSECTION: TROLLING
local bounty_loop_amt = 10000
trolling_root:toggle_loop(translations.bounty_loop, {"keplerbountyloop"}, "", function(click_type)
    menu.trigger_commands("bountyall " .. tostring(bounty_loop_amt))
    util.yield(60000)
end)

local strip_club_visitors = {}
local christianity = false
trolling_root:toggle(translations.christianity, {"keplerchristian"}, translations.christianity_desc, function(on)
    christianity = on 
    if not on then 
        strip_club_visitors = {}
    end
    mod_uses("player", if on then 1 else -1)
end)

trolling_root:action(translations.nuke, {"keplernukeall"}, '', function()
    for _, pid in players.list(true, true, true) do
        nuke_player(pid)
    end
end)

trolling_root:divider(translations.settings)

local trolling_section_settings = trolling_root:list(translations.settings, {}, "")
trolling_section_settings:slider(translations.bounty_loop_amt, {"keplerblamt"}, "", 0, 10000, 10000, 1, function(s)
    bounty_loop_amt = s
end)



-- SUBSECTION: AP FRIENDLY
local function give_vehicle_all(hash)
    for k,p in pairs(players.list(true, true, true)) do
        give_vehicle(p, hash)
    end
end

local ap_spawn_vehicle_root = friendly_root:list(translations.spawn_vehicle, {}, "")

local allv_model = 'lazer'
ap_spawn_vehicle_root:text_input(translations.enter_model, {"keplergiveallvmodel"}, "", function(model)
    give_vehicle_all(util.joaat(model))
end, 'lazer')


ap_spawn_vehicle_root:list_action(translations.presets, {"keplergiveallv"}, "", vehicle_names, function(index, value, click_type)
    give_vehicle_all(vehicle_hashes[index])
end)

-- SECTION: TOYBOX
local train_speed = 0
util.create_tick_handler(function()
    if train_speed ~= 0 then 
        local train_hdl = 0
        for _, veh in pairs(entities.get_all_vehicles_as_pointers()) do 
            if entities.get_model_hash(veh) == util.joaat("freight") then
                train_hdl = entities.pointer_to_handle(veh)
                request_control_of_entity(train_hdl)
                SET_TRAIN_SPEED(train_hdl, s)
                SET_TRAIN_CRUISE_SPEED(train_hdl, s)
            end
        end
    end
end)

local toybox_root = main_root:list(translations.toybox, {'keplertoybox'}, '')
toybox_root:click_slider(translations.train_speed, {}, translations.train_speed_mod_desc, -300, 300, 0, 1, function(s)
end)

local bong_ad = "anim@safehouse@bong" 
local bong_anim = "bong_stage3"
local are_we_high = false 
local high_time = 120*1000
local shader_ref = menu.ref_by_path("Game>Rendering>Shader Override")
local initial_shader_int = menu.get_value(shader_ref)

function sober_up()
    local ped = players.user_ped()
    SET_PED_IS_DRUNK(ped, false)		
	SET_PED_MOTION_BLUR(ped, false)
	--ANIMPOSTFX_STOP_ALL()
    menu.set_value(shader_ref, initial_shader_int)
	SHAKE_GAMEPLAY_CAM("DRUNK_SHAKE", 0.0)
	SET_TIMECYCLE_MODIFIER_STRENGTH(0.0)
    are_we_high = false
end

function get_high(time)
    initial_shader_int = menu.get_value(shader_ref)
	SET_TIMECYCLE_MODIFIER("spectator6")
	SET_PED_MOTION_BLUR(players.user_ped(), true)
	SET_PED_IS_DRUNK(players.user_ped(), true)
	--ANIMPOSTFX_PLAY("ChopVision", 10000001, true)
    menu.set_value(shader_ref, 69)
	SHAKE_GAMEPLAY_CAM("DRUNK_SHAKE", 3.0)
	util.yield(high_time)
    sober_up()
end


local root = menu.my_root()
toybox_root:textslider(translations.hit_bong, {"hitthebong"}, "", {translations.hit, translations.sober_up}, function(index)
    local ped = players.user_ped()
    local bong_hash = util.joaat("prop_bong_01")
    if index == 2 then sober_up(players.user_ped()) return end
    if DOES_ENTITY_EXIST(ped) and not IS_ENTITY_DEAD(ped) and not smoking then
        local coords = players.get_position(players.user())
        coords.z += 0.2
        request_anim_dict(bong_ad)
        request_model_load(bong_hash)
    	local bong = entities.create_object(bong_hash, coords)
    	ATTACH_ENTITY_TO_ENTITY(bong, ped, GET_PED_BONE_INDEX(ped, 18905), 0.10,-0.25,0.0,95.0,190.0,180.0, true, true, false, true, 1, true)
    	TASK_PLAY_ANIM(ped, bong_ad, bong_anim, 8.00, -8.00, -1, (2 + 16 + 32), 0.00, 0, 0, 0)
        util.yield(10000)
        STOP_ANIM_TASK(ped, bong_ad, bong_anim, 1.0)
    	entities.delete_by_handle(bong)
        are_we_high = true
        get_high(high_time)
    end
end)


local placed_firework_boxes = {}
local firework_options = {translations.place, translations.set_off}
toybox_root:textslider(translations.place_firework_box, {translations.place_firework_box_cmd}, translations.place_firework_box_desc, firework_options, function(index)
    if index == 1 then 
        local animlib = 'anim@mp_fireworks'
        local ptfx_asset = "scr_indep_fireworks"
        local anim_name = 'place_firework_3_box'
        local effect_name = "scr_indep_firework_trailburst"
        request_anim_dict(animlib)
        local pos = GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 0.0, 0.52, 0.0)
        local ped = players.user_ped()
        FREEZE_ENTITY_POSITION(ped, true)
        TASK_PLAY_ANIM(ped, animlib, anim_name, -1, -8.0, 3000, 0, 0, false, false, false)
        util.yield(1500)
        local firework_box = entities.create_object(util.joaat('ind_prop_firework_03'), pos, true, false, false)
        local firework_box_pos = GET_ENTITY_COORDS(firework_box)
        PLACE_OBJECT_ON_GROUND_PROPERLY(firework_box)
        FREEZE_ENTITY_POSITION(ped, false)
        util.yield(1000)
        FREEZE_ENTITY_POSITION(firework_box, true)
        placed_firework_boxes[#placed_firework_boxes + 1] = firework_box
    else 
        if #placed_firework_boxes == 0 then 
            say(translations.no_fireworks)
            return 
        end
        local ptfx_asset = "scr_indep_fireworks"
        local effect_name = "scr_indep_firework_trailburst"
        request_ptfx_asset(ptfx_asset)
        for i=1, 50 do
            for k,box in pairs(placed_firework_boxes) do 
                USE_PARTICLE_FX_ASSET(ptfx_asset)
                START_NETWORKED_PARTICLE_FX_NON_LOOPED_ON_ENTITY(effect_name, box, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 0.0, 0.0, 0.0)
                util.yield(100)
            end
        end
        for k,box in pairs(placed_firework_boxes) do 
            entities.delete_by_handle(box)
            placed_firework_boxes[box] = nil
        end
    end
end)

local active_bowling_balls = 0
function bomb_shower_tick_handler(ent)
    local start_time = os.clock()
    active_bowling_balls += 1
    util.create_tick_handler(function()
        if HAS_ENTITY_COLLIDED_WITH_ANYTHING(ent) or os.clock() - start_time > 10 or not DOES_ENTITY_EXIST(ent) then
            if DOES_ENTITY_EXIST(ent) then 
                local c = GET_ENTITY_COORDS(ent)
                ADD_EXPLOSION(c.x, c.y, c.z, 17, 100.0, true, false, 0.0)
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
        if DOES_ENTITY_EXIST(ped) then 
            TASK_LOOK_AT_ENTITY(npc, player_ped, 2, 2, 100)
            util.yield(1000)
            TASK_FOLLOW_TO_OFFSET_OF_ENTITY(npc, player_ped, 0, -0.2, 0, 7.0, -1, 10, true)
            local roasts = {
                "GENERIC_INSULT_MED",
                "GENERIC_INSULT_HIGH"
            }
            PLAY_PED_AMBIENT_SPEECH_NATIVE(ped, roasts[math.random(#roasts)], "SPEECH_PARAMS_FORCE_SHOUTED")
            util.yield(2000)
        else
            util.stop_thread()
        end
    end)
end

toybox_root:toggle_loop(translations.bomb_shower, {"keplerbombshower"}, "", function()
    local hash = util.joaat("imp_prop_bomb_ball")
    request_model_load(hash)
    if active_bowling_balls <= 15 then 
        local c = GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), math.random(-200, 200), math.random(-200, 200), math.random(100, 300))
        local ball = entities.create_object(hash, c)
        FREEZE_ENTITY_POSITION(ball, false)
        SET_ENTITY_DYNAMIC(ball, true)
        APPLY_FORCE_TO_ENTITY(ball, 1, math.random(-300, 300), math.random(-300, 300), -300, 0, 0, 0, 0, true, false, true, true, true)
        bomb_shower_tick_handler(ball)
    end
    util.yield(500)
end)


local hooker_finder = false
toybox_root:toggle(translations.hooker_finder, {"keplerhookerfinder"}, "", function(on)
    hooker_finder = on
    mod_uses("ped", if on then 1 else -1)
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
            local c = GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(angry_planes_tar, math.random(-radius, radius), math.random(-radius, radius), math.random(600, 800))
            local pick = v_hashes[math.random(1, #v_hashes)]
            request_model_load(pick)
            local aircraft = entities.create_vehicle(pick, c, math.random(0, 270))
            set_entity_face_entity(aircraft, angry_planes_tar, true)
            SET_VEHICLE_ENGINE_ON(aircraft, true, true, false)
            SET_HELI_BLADES_FULL_SPEED(aircraft)
            SET_VEHICLE_FORWARD_SPEED(aircraft, GET_VEHICLE_ESTIMATED_MAX_SPEED(aircraft)+1000.0)
            SET_VEHICLE_OUT_OF_CONTROL(aircraft, true, true)
            --local blip = ADD_BLIP_FOR_ENTITY(aircraft)
            --SET_BLIP_SPRITE(blip, 90)
            --SET_BLIP_COLOUR(blip, 75)
            util.yield(5000)
        end
    end)
end

toybox_root:toggle(translations.angry_planes, {"keplerangryplanes"}, "", function(on)
    angry_planes = on
    start_angryplanes_thread()
end)

toybox_root:divider(translations.settings)
local toybox_section_settings_root = toybox_root:list(translations.settings, {}, "")

-- SECTION: TWEAKS
local tweaks_root = main_root:list(translations.tweaks, {}, '')

local fake_alerts_root = tweaks_root:list(translations.fake_alerts, {}, '')
local fake_alert_text = "Kepler"

local function show_custom_alert_until_enter(l1)
    local poptime = os.time()
    while true do
        if IS_CONTROL_JUST_RELEASED(18, 18) then
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

fake_alerts_root:text_input(translations.text, {"fakealerttext"}, "", function(text)
    fake_alert_text = text
end, 'Kepler')

fake_alerts_root:action(translations.show_fake_alert, {}, "", function()
    show_custom_alert_until_enter(fake_alert_text)
end)

local fake_alert_presets = {translations.fake_alert_1, translations.fake_alert_2, translations.fake_alert_3, translations.fake_alert_4}
fake_alerts_root:list_action(translations.presets, {}, "", fake_alert_presets, function(index, value, click_type)
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
            local t = os.time()+30*24*60*60
            show_custom_alert_until_enter(translations.fake_alert_4_ct_1 .. os.date('%B %d %Y', t) .. translations.fake_alert_4_ct_2)
            break
    end
end)

tweaks_root:text_input(translations.play_cutscene, {'keplercutscene'}, '', function(entry)
    CUTSCENE.REQUEST_CUTSCENE(entry, 8)
    local st = os.time()
    local s = false
    while true do
        if CUTSCENE.HAS_CUTSCENE_LOADED() then
            s = true
            break
        else
            if os.time() - st >= 10 then
                say(translations.cutscene_load_fail)
                s = false
                return
            end
        end
        util.yield()
    end
    if s then
        CUTSCENE.START_CUTSCENE(0)
    end
end, 'abigail_mcs_2')

local god_graphics_level = 1.25


local god_graphics_toggle = tweaks_root:toggle(translations.god_graphics, {}, "", function(on)
    if on then 
        menu.trigger_commands("shader intnofog")
        menu.trigger_commands("lodscale " .. god_graphics_level)
    else
        menu.trigger_commands("shader off")
        menu.trigger_commands("lodscale 1.00")
    end
end)

tweaks_root:toggle(translations.aesthetify, {}, "", function(on)
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


tweaks_root:toggle(translations.music_only_radio, {}, "", function(on)
    local num_unlocked = GET_NUM_UNLOCKED_RADIO_STATIONS()
    if on then
        for i=1, num_unlocked do
            SET_RADIO_STATION_MUSIC_ONLY(GET_RADIO_STATION_NAME(i), true)
        end
    else
        for i=1, num_unlocked do
            SET_RADIO_STATION_MUSIC_ONLY(GET_RADIO_STATION_NAME(i), false)
        end
    end
end)

tweaks_root:toggle(translations.lock_minimap_angle, {}, "", function(on)
    if on then
        LOCK_MINIMAP_ANGLE(0)
    else
        UNLOCK_MINIMAP_ANGLE()
    end
end)

tweaks_root:toggle_loop(translations.draw_controller_pressures, {"keplerctrlpressure"}, "", function()
    local center_x = 0.8
    local center_y = 0.8
    -- main underlay
    directx.draw_rect(center_x - 0.062, center_y - 0.125, 0.12, 0.13, {r = 0, g = 0, b = 0, a = 0.2})
    -- throttle
    directx.draw_rect(center_x, center_y, 0.005, -GET_CONTROL_NORMAL(87, 87)/10, {r = 0, g = 1, b = 0, a =1 })
    -- brake 
    directx.draw_rect(center_x - 0.01, center_y, 0.005, -GET_CONTROL_NORMAL(72, 72)/10, {r = 1, g = 0, b = 0, a =1 })
    -- steering
    directx.draw_rect(center_x - 0.0025, center_y - 0.115, math.max(GET_CONTROL_NORMAL(146, 146)/20), 0.01, {r = 0, g = 0.5, b = 1, a =1 })
end)

tweaks_root:divider(translations.settings)
local tweaks_section_settings = tweaks_root:list(translations.settings, {}, '')

tweaks_section_settings:slider_float(translations.god_graphics_level, {}, translations.god_graphics_level, 1, 1000, 125, 1, function(s)
    god_graphics_level = s * 0.001
    if menu.get_value(god_graphics_toggle) then 
        menu.trigger_commands("lodscale " .. god_graphics_level)
    end
end)

-- SECTION: SETTINGS
main_root:divider(translations.settings)
local settings_root = main_root:list(translations.settings, {'keplersettings'}, '')

settings_root:list_action(translations.select_language, {"keplersetlang"}, "", translation_files, function(index, value, click_type)
    local file = io.open(selected_lang_path, 'w')
    file:write(value)
    file:close()
    util.restart_script()
end, selected_language)

local downloadable_lang_links = {'https://example.com'}
local downloadable_lang_names = {translations.work_in_progress}
settings_root:list_action(translations.install_language, {"keplerinstalllang"}, "", downloadable_lang_names, function(index, value, click_type)
end)

local clock_setting = 1
util.create_tick_handler(function()
    pluto_switch clock_setting do
        case 1:
            return 
            break
        case 2:
            util.draw_debug_text(os.date('%I:%M %p'))
            break
        case 3:
            util.draw_debug_text(os.date('%H:%M %p'))
            break
    end
end)
local clock_settings = {translations.off, translations.twelve_hour, translations.twenty_four_hour}
settings_root:textslider(translations.clock, {"keplerclock"}, "", clock_settings, function(index)
    clock_setting = index 
end)

settings_root:toggle(translations.notification_sounds, {"keplernotifsound"}, '', function(on)
    play_notification_sounds = on
end, true)

main_root:divider(translations.community)
main_root:hyperlink(translations.join_discord, "https://discord.gg/eUzmsSTnsd", "")
-- ENTITY POOL THREADS/TICK HANDLERS
local peds_thread = util.create_tick_handler(function (thr)
    if ped_uses > 0 then
        local all_peds = entities.get_all_peds_as_handles()
        for k, ped in pairs(all_peds) do
            if kill_aura then
                if (kill_aura_peds and not IS_PED_A_PLAYER(ped)) or (kill_aura_players and IS_PED_A_PLAYER(ped)) then
                    local pid = NETWORK_GET_PLAYER_INDEX_FROM_PED(v)
                    local hdl = pid_to_handle(pid)
                    if (kill_aura_friends and not NETWORK_IS_FRIEND(hdl)) or not kill_aura_friends then
                        target = GET_ENTITY_COORDS(ped, false)
                        m_coords = GET_ENTITY_COORDS(players.user_ped(), false)
                        if GET_DISTANCE_BETWEEN_COORDS(m_coords.x, m_coords.y, m_coords.z, target.x, target.y, target.z, true) < kill_aura_dist and GET_ENTITY_HEALTH(ped) > 0 then
                            SHOOT_SINGLE_BULLET_BETWEEN_COORDS(target['x'], target['y'], target['z'], target['x'], target['y'], target['z']+0.1, 300.0, true, 100416529, players.user_ped(), true, false, 100.0)
                        end
                    end
                end
            end
            
            if not IS_PED_A_PLAYER(ped) then
            
                if gun_to_give_peds ~= 1 then
                    GIVE_WEAPON_TO_PED(ped, gun_hashes[gun_to_give_peds], 9999, false, true)
                end

                if ped_godmode then 
                    SET_ENTITY_INVINCIBLE(ped, true)
                end

                if hooker_finder then
                    local mdl = GET_ENTITY_MODEL(ped)
                    if IS_PED_USING_SCENARIO(ped, "WORLD_HUMAN_PROSTITUTE_HIGH_CLASS") or IS_PED_USING_SCENARIO(ped,"WORLD_HUMAN_PROSTITUTE_LOW_CLASS") then 
                        util.draw_ar_beacon(GET_ENTITY_COORDS(ped))
                    end
                end

                if peds_ignore then
                    if not GET_PED_CONFIG_FLAG(ped, 17, true) then
                        SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
                        TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
                    end
                end

                if apose_peds then 
                    if IS_PED_IN_ANY_VEHICLE(ped, true) then
                        CLEAR_PED_TASKS_IMMEDIATELY(ped)
                    end
                    request_anim_set("move_crawl")
                    SET_PED_MOVEMENT_CLIPSET(ped, "move_crawl", -1)
                end

                if allpeds_gun ~= 0 then
                    GIVE_WEAPON_TO_PED(ped, allpeds_gun, 9999, false, true)
                end

            end
        end
    end
    util.yield()
end)

local players_thread = util.create_tick_handler(function (thr)
    if player_uses > 0 then
        local all_players = players.list(true, true, true)
        for k,pid in pairs(all_players) do
            if anti_aim then 
                local c1 = players.get_position(pid)
                local c2 =  players.get_position(players.user())
                local ped = GET_PLAYER_PED_SCRIPT_INDEX(pid)
                if IS_PED_FACING_PED(ped, players.user_ped(), anti_aim_angle) 
                    and HAS_ENTITY_CLEAR_LOS_TO_ENTITY(ped, players.user_ped(), 17)
                        and GET_DISTANCE_BETWEEN_COORDS(c1.x, c1.y, c1.z, c2.x, c2.y, c2.z) < 1000 
                            and GET_SELECTED_PED_WEAPON(ped) ~= -1569615261 
                                and GET_PED_CONFIG_FLAG(ped, 78, true) then
                    pluto_switch anti_aim_type do 
                        case 1: 
                            util.trigger_script_event(1 << pid, {-1388926377, 4, -1762807505, 0})
                            break
                        case 2: 
                            local coords = GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(GET_PLAYER_PED_SCRIPT_INDEX(pid), 0.0, 0.0, 2.8)
                            ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], 70, 100.0, false, true, 0.0)
                            break
                        case 3:
                            menu.trigger_commands("kill " .. players.get_name(pid))
                            break
                    end

                    if anti_aim_say then
                        say(players.get_name(pid) .. translations.anti_aim_say_alert)
                    end
                    end
                end
                
            if christianity then 
                local pc = GET_ENTITY_COORDS(GET_PLAYER_PED_SCRIPT_INDEX(pid))
                local scc = {}
                scc['x'] = 122.84036
                scc['y'] = -1291.338
                scc['z'] = 29.283897
                local dist = GET_DISTANCE_BETWEEN_COORDS(scc['x'], scc['y'], scc['z'], pc['x'], pc['y'], pc['z'], true)
                if dist <= 10 then
                    local name = GET_PLAYER_NAME(pid)
                    if not table.contains(strip_club_visitors, name) then 
                        strip_club_visitors[#strip_club_visitors + 1] = name 
                        chat.send_message(name .. translations.visiting_strip_club, false, true, true)
                    end
                end
            end

            if antioppressor then
                local ped = GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local vehicle = GET_VEHICLE_PED_IS_IN(ped, true)
                if vehicle ~= 0 then
                  local hash = util.joaat("oppressor2")
                  if IS_VEHICLE_MODEL(vehicle, hash) then
                    entities.delete_by_handle(vehicle)
                  end
                end
            end
            if flyswatter then 
                local ped = GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local vehicle = GET_VEHICLE_PED_IS_IN(ped, false)
                if vehicle ~= 0 then
                  local hash = util.joaat("oppressor2")
                  if IS_VEHICLE_MODEL(vehicle, hash) and GET_ENTITY_HEIGHT_ABOVE_GROUND(vehicle) > 10 then
                    request_control_of_entity_once(vehicle)
                    SET_ENTITY_MAX_SPEED(vehicle, 10000)
                    APPLY_FORCE_TO_ENTITY(vehicle, 1,  0.0, 0.0, -10000, 0, 0, 0, 0, true, false, true, false, true)
                  end
                end
            end
            if noarmedvehs then
                local ped = GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local vehicle = GET_VEHICLE_PED_IS_IN(ped, true)
                if vehicle ~= 0 then
                    if DOES_VEHICLE_HAVE_WEAPONS(vehicle) then 
                        entities.delete_by_handle(vehicle)
                    end
                end
            end
        end
    end
    util.yield()
end)

-- UTILITIES

-- also credit to nowiry i believe
local function raycast_gameplay_cam(flag, distance)
    local ptr1, ptr2, ptr3, ptr4 = memory.alloc(), memory.alloc(), memory.alloc(), memory.alloc()
    local cam_rot = GET_GAMEPLAY_CAM_ROT(0)
    local cam_pos = GET_GAMEPLAY_CAM_COORD()
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
    local p2 = v3.new(ptr2)
    local p3 = v3.new(ptr3)
    local p4 = memory.read_int(ptr4)
    return {p1, p2, p3, p4}
end

-- i think nowiry gets credit here
local function raycast_cam(flag, distance, cam)
    local ptr1, ptr2, ptr3, ptr4 = memory.alloc(), memory.alloc(), memory.alloc(), memory.alloc()
    local cam_rot = GET_CAM_ROT(cam, 0)
    local cam_pos = GET_CAM_COORD(cam)
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
    local p2 = v3.new(ptr2)
    local p3 = v3.new(ptr3)
    local p4 = memory.read_int(ptr4)
    return {p1, p2, p3, p4}
end

-- set a player into a free seat in a vehicle, if any exist
local function set_player_into_suitable_seat(ent)
    local driver = GET_PED_IN_VEHICLE_SEAT(ent, -1)
    if not IS_PED_A_PLAYER(driver) or driver == 0 then
        if driver ~= 0 then
            entities.delete_by_handle(driver)
        end
        SET_PED_INTO_VEHICLE(players.user_ped(), ent, -1)
    else
        for i=0, GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(ent) do
            if IS_VEHICLE_SEAT_FREE(ent, i) then
                SET_PED_INTO_VEHICLE(players.user_ped(), ent, -1)
            end
        end
    end
end

-- GENERAL TICK
util.create_tick_handler(function()
    if grapplegun then
        local curwep = GET_SELECTED_PED_WEAPON(players.user_ped())
        if IS_PED_SHOOTING(players.user_ped()) and GET_VEHICLE_PED_IS_IN(players.user_ped(), false) then
            if curwep == util.joaat("weapon_pistol") or curwep == util.joaat("weapon_pistol_mk2") then
                local raycast_coord = raycast_gameplay_cam(-1, 10000.0)
                if raycast_coord[1] == 1 then
                    local lastdist = nil
                    TASK_SKY_DIVE(players.user_ped())
                    while true do
                        if IS_CONTROL_JUST_PRESSED(45, 45) then 
                            break
                        end
                        if raycast_coord[4] ~= 0 and GET_ENTITY_TYPE(raycast_coord[4]) >= 1 and GET_ENTITY_TYPE(raycast_coord[4]) < 3 then
                            ggc1 = GET_ENTITY_COORDS(raycast_coord[4], true)
                        else
                            ggc1 = raycast_coord[2]
                        end
                        local c2 = players.get_position(players.user())
                        local dist = GET_DISTANCE_BETWEEN_COORDS(ggc1['x'], ggc1['y'], ggc1['z'], c2['x'], c2['y'], c2['z'], true)
                        -- safety
                        if not lastdist or dist < lastdist then 
                            lastdist = dist
                        else
                            break
                        end
                        if IS_ENTITY_DEAD(players.user_ped()) then
                            break
                        end
                        if dist >= 10 then
                            local dir = {}
                            dir['x'] = (ggc1['x'] - c2['x']) * dist
                            dir['y'] = (ggc1['y'] - c2['y']) * dist
                            dir['z'] = (ggc1['z'] - c2['z']) * dist
                            --APPLY_FORCE_TO_ENTITY(players.user_ped(), 2, dir['x'], dir['y'], dir['z'], 0.0, 0.0, 0.0, 0, false, false, true, false, true)
                            SET_ENTITY_VELOCITY(players.user_ped(), dir['x'], dir['y'], dir['z'])
                        else
                            local t = GET_ENTITY_TYPE(raycast_coord[4])
                            if t == 2 then
                                set_player_into_suitable_seat(raycast_coord[4])
                            elseif t == 1 then
                                local v = GET_VEHICLE_PED_IS_IN(t, false)
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
        local ent = get_aim_info()['ent']
        request_control_of_entity(ent)
        if IS_PED_SHOOTING(players.user_ped()) then
            if IS_ENTITY_A_VEHICLE(ent) then
                rand = {}
                rand['r'] = math.random(100,255)
                rand['g'] = math.random(100,255)
                rand['b'] = math.random(100,255)
                SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(ent, rand['r'], rand['g'], rand['b'])
                SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(ent, rand['r'], rand['g'], rand['b'])
            end
        end
    end

    if aim_info then
        local info = get_aim_info()
        if info['ent'] ~= 0 then
            local text = "Hash: " .. info['hash'] .. "\nEntity: " .. info['ent'] .. "\nHealth: " .. info['health'] .. "\nType: " .. info['type'] .. "\nSpeed: " .. info['speed']
            directx.draw_text(0.5, 0.3, text, 5, 0.5, {r = 1, g = 1, b = 1, a = 1}, true)
        end
    end

    if gun_stealer then
        if IS_PED_SHOOTING(players.user_ped()) then
            local ent = get_aim_info()['ent']
            if IS_ENTITY_A_VEHICLE(ent) then
                local driver = GET_PED_IN_VEHICLE_SEAT(ent, -1)
                if IS_PED_A_PLAYER(driver) then
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
        if IS_PED_SHOOTING(players.user_ped()) then
            if IS_ENTITY_A_VEHICLE(ent) then
                local driver = GET_PED_IN_VEHICLE_SEAT(ent, -1)
                if driver == 0 or not IS_PED_A_PLAYER(driver) then
                    if not IS_PED_A_PLAYER(driver) then
                        entities.delete_by_handle(driver)
                    end
                    local hash = 0x9C9EFFD8
                    request_model_load(hash)
                    local coords = GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, -2.0, 0.0, 0.0)
                    local ped = entities.create_ped(28, hash, coords, 30.0)
                    SET_PED_INTO_VEHICLE(ped, ent, -1)
                    SET_ENTITY_INVINCIBLE(ped, true)
                    SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
                    SET_PED_FLEE_ATTRIBUTES(ped, 0, false)
                    SET_PED_COMBAT_ATTRIBUTES(ped, 46, true)
                    SET_PED_CAN_BE_DRAGGED_OUT(ped, false)
                    SET_PED_CAN_BE_KNOCKED_OFF_VEHICLE(ped, false)
                    TASK_VEHICLE_DRIVE_TO_COORD(ped, ent, math.random(1000), math.random(1000), math.random(100), 100, 1, GET_ENTITY_MODEL(ent), 4, 5, 0)
                end
            end
        end
    end

    if vehicle_fly then
        if GET_VEHICLE_PED_IS_IN(players.user_ped(), false) ~= veh_fly_plane then
            menu.set_value(vehiclefly, false)
        end
    end

    if ped ~= 0 then
        local lastcar = GET_PLAYERS_LAST_VEHICLE()
        local p_coords = GET_ENTITY_COORDS(players.user_ped(), true)
        local t_coords = GET_ENTITY_COORDS(lastcar, true)
        local dist = GET_DISTANCE_BETWEEN_COORDS(p_coords['x'], p_coords['y'], p_coords['z'], t_coords['x'], t_coords['y'], t_coords['z'], false)
        if lastcar == 0 or GET_ENTITY_HEALTH(lastcar) == 0 or dist <= 5 then
            entities.delete_by_handle(ped)
            BRING_VEHICLE_TO_HALT(lastcar, 5.0, 2, true)
            SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(lastcar, false)
            START_VEHICLE_HORN(lastcar, 1000, util.joaat("NORMAL"), false)
            ped = 0
            util.remove_blip(blip)
        end
    end

    -- drive/walk on water
    -- "dow block" is an invisible platform that is continuously teleported under the vehicle/player for the illusion
    -- sometimes other players see this. sometimes they don't.
    if walkonwater or driveonwater or drive_on_air then
        if dow_block == 0 or not DOES_ENTITY_EXIST(dow_block) then
            local hash = util.joaat("stt_prop_stunt_bblock_mdm3")
            request_model_load(hash)
            local c = {}
            c.x = 0.0
            c.y = 0.0
            c.z = 0.0
            dow_block = CREATE_OBJECT_NO_OFFSET(hash, c['x'], c['y'], c['z'], true, false, false)
            SET_ENTITY_ALPHA(dow_block, 0)
            SET_ENTITY_VISIBLE(dow_block, false, 0)
        end
    end

    if dow_block ~= 0 and not walkonwater and not walkonair and not driveonwater and not drive_on_air then
        SET_ENTITY_COORDS_NO_OFFSET(dow_block, 0, 0, 0, false, false, false)
    end

    if walkonwater then
        vehicle = GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
        local pos = GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 0.0, 2.0, 0.0)
        -- we need to offset this because otherwise the player keeps diving off the thing, like a fucking dumbass
        -- ht isnt actually used here, but im allocating some memory anyways to prevent a possible crash, probably. idk im no computer engineer
        local ht = memory.alloc(4)
        -- this is better than IS_ENTITY_IN_WATER because it can detect if a player is actually above water without them even being "in" it
        if WATER.GET_WATER_HEIGHT(pos['x'], pos['y'], pos['z'], ht) then
            SET_ENTITY_COORDS_NO_OFFSET(dow_block, pos['x'], pos['y'], memory.read_float(ht), false, false, false)
            SET_ENTITY_HEADING(dow_block, GET_ENTITY_HEADING(players.user_ped()))
        end
    end

    if driveonwater then
        if player_car_hdl ~= 0 then
            local pos = GET_ENTITY_COORDS(player_car_hdl, true)
            -- ht isnt actually used here, but im allocating some memory anyways to prevent a possible crash, probably. idk im no computer engineer
            local ht = memory.alloc(4)
            -- this is better than IS_ENTITY_IN_WATER because it can detect if a player is actually above water without them even being "in" it
            if WATER.GET_WATER_HEIGHT(pos['x'], pos['y'], pos['z'], ht) then
                SET_ENTITY_COORDS_NO_OFFSET(dow_block, pos['x'], pos['y'], memory.read_float(ht), false, false, false)
                SET_ENTITY_HEADING(dow_block, GET_ENTITY_HEADING(player_car_hdl))
            end
        else
            SET_ENTITY_COORDS_NO_OFFSET(dow_block, 0, 0, 0, false, false, false)
        end
    end

    if drive_on_air then
        if player_car_hdl ~= 0 then
            local pos = GET_ENTITY_COORDS(player_car_hdl, true)
            local boxpos = GET_ENTITY_COORDS(dow_block, true)
            if GET_DISTANCE_BETWEEN_COORDS(pos['x'], pos['y'], pos['z'], boxpos['x'], boxpos['y'], boxpos['z'], true) >= 5 then
                SET_ENTITY_COORDS_NO_OFFSET(dow_block, pos['x'], pos['y'], doa_ht, false, false, false)
                SET_ENTITY_HEADING(dow_block, GET_ENTITY_HEADING(player_car_hdl))
            end
            if IS_CONTROL_PRESSED(22, 22) then
                doa_ht = doa_ht + 0.1
                SET_ENTITY_COORDS_NO_OFFSET(dow_block, pos['x'], pos['y'], doa_ht, false, false, false)
            end
            if IS_CONTROL_PRESSED(36, 36) then
                doa_ht = doa_ht - 0.1
                SET_ENTITY_COORDS_NO_OFFSET(dow_block, pos['x'], pos['y'], doa_ht, false, false, false)
            end
        end
    end

end)

util.on_stop(function()
    if active_rideable_animal ~= 0 then 
        DETACH_ENTITY(players.user_ped())
        entities.delete_by_handle(active_rideable_animal)
        CLEAR_PED_TASKS_IMMEDIATELY(players.user_ped())
    end
end)

