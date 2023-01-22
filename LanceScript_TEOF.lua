-- coded by lance#8213, from scratch
-- if you are stealing my code to use it in another menu actually kys
-- extra options and fixes by Axhov#0001, not from scratch lol. Lots of stuff taken from wiriscript.

slaxdom = require("lib/slaxdom")
slaxml = require("lib/slaxml")
util.require_no_lag("natives-1627063482")
handle_ptr = memory.alloc(13*8)

util.toast("TEOF edits by Axhov#0001, LanceScript By Lance")
vehicles_dir = filesystem.scripts_dir() .. '\\menyoo vehicles\\'
if not filesystem.is_dir(vehicles_dir) then
    filesystem.mkdir(vehicles_dir)
end

maps_dir = filesystem.scripts_dir() .. '\\menyoo maps\\'
if not filesystem.is_dir(maps_dir) then
    filesystem.mkdir(maps_dir)
end

store_dir = filesystem.store_dir() .. '/lancescript/'
resources_dir = filesystem.resources_dir() .. '/lancescript/'
if not filesystem.is_dir(resources_dir) then
    util.toast("ALERT: resources dir is missing! Please make sure you installed Lancescript properly.")
end

if not filesystem.is_dir(store_dir) then
    filesystem.mkdirs(store_dir)
end

lancescript_logo = directx.create_texture(resources_dir .. 'lancescript_logo.png')

function log(content)
    if verbose then
        util.log("[LANCESCRIPT] " .. content)
    end
end

ocoded_for = 1.60
is_loading = true
-- enable to generate helpful logs for lance!
verbose = false
online_v = tonumber(NETWORK._GET_ONLINE_VERSION())
if online_v > ocoded_for then
    util.toast("This script is outdated for the current GTA:O version (" .. online_v .. ", coded for " .. ocoded_for .. "). Some options may not work, but most should.")
end

log("Setting up lists")
self_root = menu.list(menu.my_root(), "Self", {"lancescriptself"}, "Lets you do things to yourself/your ped")
vehicle_root = menu.list(menu.my_root(), "Vehicle", {"lanceobjecttroll"}, "")
online_root = menu.list(menu.my_root(), "Online", {"lancescriptonline"}, "")
world_root = menu.list(menu.my_root(), "World", {"lancescriptworld"}, "Rule the world")
nearbyentity_root = menu.list(menu.my_root(), "Nearby entities", {"lancescriptentity"}, "Vehicle chaos, ascend vehicles, beep all vehicles, etc.")
gametweaks_root = menu.list(menu.my_root(), "Game tweaks", {"lancescriptgametweaks"}, "")
lancescript_root = menu.list(menu.my_root(), "LanceScript", {"lancescriptutil"}, "")
credits_root = menu.list(menu.my_root(), "Credits", {"lancescriptcredits"}, "")
--------
protections_root = menu.list(online_root, "Protections", {"lancescriptprotections"}, "Protect yourself before you wreck yourself.")
recoveries_root = menu.list(online_root, "Recoveries", {"lancescriptrecoveries"}, "TESTED FOR A LONG TIME FOR SAFETY, BUT STILL USE AT YOUR OWN RISK!")
transport_root = menu.list(self_root, "Transportation", {"lancescripttransport"}, "")
chauffeur_root = menu.list(transport_root, "Chauffeur", {"lancescriptchauffeur"}, "")
weapons_root = menu.list(self_root, "Weapons", {"lancescriptweapons"}, "Weapon adjustments and tweaks")
silent_aimbotroot = menu.list(weapons_root, "Silent aimbot", {"lancescriptsilentaimbot"}, "Precisely shoot peds and players even if your shots miss, lol")
entity_gun = menu.list(weapons_root, "Entity gun", {"lancescriptentgun"}, "Shoot entities.")
cross = menu.list(weapons_root, "Crosshair disabling types", {"crosshairs"}, "Different ways to disable your crosshair for different scenarios")
pedmoney_root = menu.list(recoveries_root, "Ped money", {"lancescriptrecoveries"}, "TESTED FOR A LONG TIME FOR SAFETY, BUT STILL USE AT YOUR OWN RISK!")
spooner_root = menu.list(world_root, "Lance spooner", {"lancescriptspooner"}, "Spawn, move, and modify objects!")
--
menyoo_root = menu.list(spooner_root, "Menyoo XML\'s", {"lancescriptmenyoo"}, "Menyoo support!")
menyoovmain_root = menu.list(menyoo_root, "Vehicles", {"lancescriptmenyoovehicles"}, "Menyoo vehicle support!")
menyoom1_root = menu.list(menyoo_root, "Maps [BETA]", {"lancescriptmenyoomapsroot"}, "Menyoo maps support!")
menyoom_root = menu.list(menyoom1_root, "Maps", {"lancescriptmenyooallmaps"}, "All maps in your directory")
menyoomloaded_root = menu.list(menyoom1_root, "Currently loaded maps", {"lancescriptmenyooloadedmaps"}, "Maps you have loaded")
menyoov_root = menu.list(menyoovmain_root, "All vehicles", {"lancescriptmenyooloadedmaps"}, "Vehicles you have spawned")
menyoovloaded_root = menu.list(menyoovmain_root, "Currently loaded vehicles", {"lancescriptmenyooloadedmaps"}, "Vehicles you have spawned")
--
density_root = menu.list(world_root, "Population densities", {"lancescriptdensities"}, "Modify density multipliers")
budget_root = menu.list(world_root, "Budget", {"lancescriptbudget"}, "Modify entity budgets")
train_root = menu.list(world_root, "Train", {"lancescripttrain"}, "Control trains to your liking")
vehicles_root = menu.list(nearbyentity_root, "Vehicles and objects", {"lancescriptentity"}, "Vehicle chaos, ascend vehicles, beep all vehicles, etc.")
colorizev_root = menu.list(vehicles_root, "Color vehicles", {"lancescriptcolorize"}, "Paint all nearby vehicles colors!")
npc_root = menu.list(nearbyentity_root, "NPC\'s", {"lancescriptnpcs"}, "NPC tasks and more")
tasks_root = menu.list(npc_root, "Tasks", {"lancescripttasks"}, "")
unlocks_root = menu.list(recoveries_root, "Unlocks", {"lancescriptunlocks"}, "")
clothingunlock_root = menu.list(unlocks_root, "Clothing", {"lancescriptclothingunlocks"}, "")
allplayers_root = menu.list(online_root, "All players", {"lancescriptallplayers"}, "")
apnice_root = menu.list(allplayers_root, "Nice", {"apnice"}, "")
ap_vaddons = menu.list(apnice_root, "Vehicle addons", {"lsvaddons"}, "")
apnaughty_root = menu.list(allplayers_root, "Naughty", {"apnaughty"}, "")
apneutral_root = menu.list(allplayers_root, "Neutral", {"apneutral"}, "")
apforcedacts_root = menu.list(apneutral_root, "Forced vehicle actions", {"apforcedacts"}, "")
apgivecar_root = menu.list(apnice_root, "Give vehicle", {"apgivecar"}, "")
apgivemenyoocar_root = menu.list(apgivecar_root, "Give menyoo vehicle", {"apgivecar"}, "BE CAREFUL- SPAWNING TOO MANY ENTITIES WILL CRASH YOUR GAME! DO NOT USE THIS ON ENTITY-HEAVY XML\'S.")
business_root = menu.list(online_root, "Business monitor", {"lancescriptbusiness"}, "Business monitor allows you to monitor your businesses. It does NOT automatically sell or resupply, so there is no risk of being banned."..
"\nAll values in business monitor are reported by the game itself through stats. Lancescript does not miraculously come up with info. If there is an issue, it is an issue with how the game is reporting it, not Lancescript.")
ehud_root = menu.list(gametweaks_root, "HUD extras", {"lancescripthudextras"}, "Additional things to add to your hud")
fakemessages_root = menu.list(gametweaks_root, "Fake messages", {"lancescriptfakemessages"}, "")
labelpresets_root = menu.list(gametweaks_root, "Label presets", {"lancescriptlabelpresets"}, "Lets you HUD elements in the game say different things.")

menu.action(gametweaks_root, "Restart GTA V", {"restartgta"}, "Restarts your game in singleplayer, closes it in Online. You will need to reinject (duh).", function(on_click)
    MISC._RESTART_GAME()
end)
radio_root = menu.list(gametweaks_root, "Radio", {"lancescriptradio"}, "")
menu.divider(lancescript_root, "v11.0.3")
menu.toggle(lancescript_root, "Verbose mode", {"lsverbose"}, "Spams your console with valuable info.", function(on)
    verbose = on
end)
sounds_root = menu.list(lancescript_root, "Sounds", {"lancescriptsounds"}, "")

meme_root = menu.list(lancescript_root, "Memes", {"teofmemes"}, "timeless (maybe) classics. Come here for a laugh or dont I don't care but don't dm me telling me these are shit")

menu.hyperlink(meme_root, "Aughhhhh", "https://www.youtube.com/shorts/wIIRyyIc7Nw", "")
menu.hyperlink(meme_root, "Grandpa Found the Car Keys", "https://www.youtube.com/watch?v=PGJKeESLBpQ", "")
menu.hyperlink(meme_root, "The Hungry, Hungry Baby", "https://www.youtube.com/watch?v=X0pEBE_eYdU", "")
menu.hyperlink(meme_root, "Cheese", "https://www.youtube.com/watch?v=SyimUCBIo6c", "")
menu.hyperlink(meme_root, "Snap Back To Reality", "https://www.youtube.com/watch?v=fV3nflAQ99w", "")
menu.hyperlink(meme_root, "how is prangent formed", "https://www.youtube.com/watch?v=EShUeudtaFg", "")
menu.hyperlink(meme_root, "john madden", "https://www.youtube.com/watch?v=Hv6RbEOlqRo", "")
menu.hyperlink(meme_root, "Scott Bradford", "https://www.youtube.com/watch?v=Pbkn21NNduc", "")
menu.hyperlink(meme_root, "Big Bill Hell's", "https://www.youtube.com/watch?v=4sZuN0xXWLc", "")
menu.hyperlink(meme_root, "fart withh extra reverb", "https://www.youtube.com/watch?v=hr7GyFM7pX4", "")
menu.hyperlink(meme_root, "Deleted Wikipedia articles submitted by insane people", "https://www.youtube.com/watch?v=29vjQwnt-Fw", "")
menu.hyperlink(meme_root, "I put crack in their hotdogs", "https://www.youtube.com/shorts/gMZTAvBYPxs", "watch all the way through")
menu.hyperlink(meme_root, "OBJECTS THAT I HAVE SHOVED UP MY ARSE", "https://www.youtube.com/watch?v=6LvlG2dTQKg", "")
menu.hyperlink(meme_root, "are you guys going trick or treating", "https://www.youtube.com/watch?v=asgtIKR3CeA", "")
menu.hyperlink(meme_root, "THAT SHIT IS FUCKING TRASH", "https://www.youtube.com/watch?v=lA9QwsgOvpU", "")
menu.hyperlink(meme_root, "Samir you're breaking the car", "https://www.youtube.com/watch?v=D9-voINFkCg", "")
menu.hyperlink(meme_root, "", "", "")
menu.hyperlink(meme_root, "", "", "")

menu.action(menu.my_root(), "Players shortcut", {}, "Quickly opens session players list, for convenience", function(on_click)
    menu.trigger_commands("playerlist")
end)
log("Done setting up lists.")

good_guns = {584646201, 4208062921, 487013001, -1716189206, 1119849093}

-- this is taken from lua docs at http://lua-users.org/wiki/FileInputOutput
-- check if the file exists so if it doesnt we dont encounter errors
function file_exists(path)
    local file = io.open(path, "rb")
    if file then file:close() end
    return file ~= nil
end

function hasValue( tbl, str )
    local f = false
    for i = 1, #tbl do
        if type( tbl[i] ) == "table" then
            f = hasValue( tbl[i], str )  --  return value from recursion
            if f then break end  --  if it returned true, break out of loop
        elseif tbl[i] == str then
            return true
        end
    end
    return f
end

broken_root = menu.list(gametweaks_root, "Broken Options", {"brop"}, "BROKEN OPTIONS THAT I MAY OR MAY NOT ADD. IF SOMETHING IS HERE THAT MEANS IT DOES NOT WORK. IT MAY DO NOTHING, OR IT MAY CRASH YOUR GAME.")

-- credit to https://stackoverflow.com/questions/1426954/split-string-in-lua
function split_str(inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

function to_boolean(text)
    if text == 'true' or text == "1" then
        return true
    end
    return false
end

function get_element_text(el)
    local pieces = {}
    for _,n in ipairs(el.kids) do
      if n.type=='element' then pieces[#pieces+1] = get_element_text(n)
      elseif n.type=='text' then pieces[#pieces+1] = n.value
      end
    end
    return table.concat(pieces)
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

function parse_xml(path)
    -- does this path even exist?
    if not file_exists(path) then
        util.toast("yeah mate that file doesn\'t exist, pretty cringe")
        return
    end
    -- break file into string
    local xml = io.open(path):read('*all')
    -- dom that shit ;)
    local dom = slaxdom:dom(xml, {stripWhitespace=true})
    -- return our dominant superior ;)
    return dom
end

function pid_to_handle(pid)
    NETWORK.NETWORK_HANDLE_FROM_PLAYER(pid, handle_ptr, 13)
    return handle_ptr
end

function setup_menyoo_vehicles_list(mainroot, player, allplayers, dotp)
    for i, path in ipairs(filesystem.list_files(vehicles_dir)) do
        root = mainroot
        local ours = false
        if player == players.user() then
            ours = true 
        end
        if filesystem.is_dir(path) then
            root = menu.list(root, path:gsub(vehicles_dir, ''), {}, "")
            for i,path in ipairs(filesystem.list_files(path)) do
                if not allplayers then
                    menu.action(root, path:gsub(vehicles_dir, ''), {}, "Spawn this menyoo vehicle", function(on_click)
                        log("Click type was " .. on_click)
                        menyoo_load_vehicle(path, player, dotp, ours)
                    end)
                else
                    menu.action(root, path:gsub(vehicles_dir, ''), {}, "Spawn this menyoo vehicle for all players", function(on_click)
                        for k,v in pairs(players.list(true, true, true)) do
                            log("Click type was " .. on_click)
                            menyoo_load_vehicle(path, v, dotp, false)
                        end
                    end)
                end
            end
        else
            if string.match(path:gsub(vehicles_dir, ''), '.xml') then
                if not allplayers then
                    menu.action(root, path:gsub(vehicles_dir, ''), {}, "Spawn this menyoo vehicle", function(on_click)
                        log("Click type was " .. on_click)
                        menyoo_load_vehicle(path, player, dotp, ours)
                    end)
                else
                    menu.action(root, path:gsub(vehicles_dir, ''), {}, "Spawn this menyoo vehicle for all players", function(on_click)
                        for k,v in pairs(players.list(true, true, true)) do
                            log("Click type was " .. on_click)
                            menyoo_load_vehicle(path, v, dotp, false)
                        end
                    end)
                end
            end
        end
    end
end

function setup_menyoo_maps_list()
    for i, path in ipairs(filesystem.list_files(maps_dir)) do
        if filesystem.is_dir(path) then
            root = menu.list(menyoom_root, path:gsub(maps_dir, ''), {}, "")
            for i,path in ipairs(filesystem.list_files(path)) do
                menu.action(root, path:gsub(maps_dir, ''), {}, "Spawn this menyoo map", function(on_click)
                    menyoo_load_map(path)
                end)
            end
        else
            if string.match(path:gsub(maps_dir, ''), '.xml') then
                menu.action(menyoom_root, path:gsub(maps_dir, ''), {}, "Spawn this menyoo map", function(on_click)
                    menyoo_load_map(path)
                end)
            end
        end
    end
end

setup_menyoo_vehicles_list(menyoov_root, players.user(), false, true)
setup_menyoo_vehicles_list(apgivemenyoocar_root, pid, true, false)
setup_menyoo_maps_list()

function menyoo_preprocess_ped(ped, att_data, entity_initial_handles)
    local ped_data = {}
    isped = true
    entity = ped
    menyoo_preprocess_entity(ped, att_data)
    if #entity_initial_handles > 0 then
        entity_initial_handles[att_data['InitialHandle']] = ped
    end
    for a,b in pairs(att_data['PedProperties'].kids) do
        local name = b.name
        local val = get_element_text(b)
        if name == 'PedProps' or name == 'PedComps' or name == 'TaskSequence' then
            ped_data[name] = b 
        else
            ped_data[name] = val
        end
    end
    local task_data = {}
    if att_data['TaskSequence'] ~= nil then
        for a,b in pairs(att_data['TaskSequence'].kids) do
            for c,d in pairs(b.kids) do
                task_data[d.name] = get_element_text(d)
            end
        end
    end
    local props = menyoo_build_properties_table(ped_data['PedProps'].kids)
    for k,v in pairs(props) do
        k = k:gsub('_', '')
        v = split_str(v, ',')
        PED.SET_PED_PROP_INDEX(ped, k, tonumber(v[1]), tonumber(v[2]), true)
    end
    local comps = menyoo_build_properties_table(ped_data['PedComps'].kids)
    for k,v in pairs(comps) do
        k = k:gsub('_', '')
        v = split_str(v, ',')
        PED.SET_PED_COMPONENT_VARIATION(ped, k, tonumber(v[1]), tonumber(v[2]), tonumber(v[2]))
    end
    PED.SET_PED_CAN_RAGDOLL(ped, to_boolean(ped_data['CanRagdoll']))
    PED.SET_PED_ARMOUR(ped, ped_data['Armour'])
    WEAPON.GIVE_WEAPON_TO_PED(ped, ped_data['CurrentWeapon'], 999, false, true)
    -- skipping over relationship groups, fuck that shit, seriously
    -- anim shit
    if task_data['AnimDict'] ~= nil then
        request_anim_dict(task_data['AnimDict'])
        local duration = tonumber(task_data['Duration'])
        local flag = tonumber(task_data['Flag'])
        local speed = tonumber(task_data['Speed'])
        TASK.TASK_PLAY_ANIM(ped, task_data['AnimDict'], task_data['AnimName'], 8.0, 8.0, duration, flag, speed, false, false, false)
    elseif ped_data['AnimDict'] ~= nil then
        request_anim_dict(ped_data['AnimDict'])
        TASK.TASK_PLAY_ANIM(ped, ped_data['AnimDict'], ped_data['AnimName'], 8.0, 8.0, -1, 1, 1.0, false, false, false)
    end
end

function nil_handler(val, default)
    if val == nil then
        val = default
    end
    return val
end

function menyoo_preprocess_entity(entity, data)
    data['Dynamic'] = nil_handler(data['Dynamic'], true)
    data['FrozenPos'] = nil_handler(data['FrozenPos'], true)
    data['OpacityLevel'] = nil_handler(data['OpacityLevel'], 255)
    data['IsInvincible'] = nil_handler(data['IsInvincible'], false)
    data['IsVisible'] = nil_handler(data['IsVisible'], true)
    data['HasGravity'] = nil_handler(data['HasGravity'], false)
    data['IsBulletProof'] = nil_handler(data['IsBulletProof'], false)
    data['IsFireProof'] = nil_handler(data['IsFireProof'], false)
    data['IsExplosionProof'] = nil_handler(data['IsExplosionProof'], false)
    data['IsMeleeProof'] = nil_handler(data['IsMeleeProof'], false)
    ENTITY.FREEZE_ENTITY_POSITION(entity, to_boolean(data['FrozenPos']))
    ENTITY.SET_ENTITY_ALPHA(entity, tonumber(data['OpacityLevel']), false)
    ENTITY.SET_ENTITY_INVINCIBLE(entity, to_boolean(data['IsInvincible']))
    ENTITY.SET_ENTITY_VISIBLE(entity, to_boolean(data['IsVisible']), 0)
    ENTITY.SET_ENTITY_HAS_GRAVITY(entity, to_boolean(data['HasGravity']))
    ENTITY.SET_ENTITY_PROOFS(entity, to_boolean(data['IsBulletProof']), to_boolean(data['IsFireProof']), to_boolean(data['IsExplosionProof']), false, to_boolean(data['IsMeleeProof']), false, true, false)
end

function menyoo_preprocess_car(vehicle, data)
    log("Preprocessing vehicle " .. vehicle)
    local colors = menyoo_build_properties_table(data['Colours'].kids)
    local neons = menyoo_build_properties_table(data['Neons'].kids)
    local doorsopen = menyoo_build_properties_table(data['DoorsOpen'].kids)
    local doorsbroken = menyoo_build_properties_table(data['DoorsBroken'].kids)
    if data['TyresBursted'] ~= nil then
        local tyresbursted = menyoo_build_properties_table(data['TyresBursted'].kids)
        for k,v in pairs(tyresbursted) do
            -- fucking menyoo.. here they go mixing up wheel indexes with strings
            k = k:gsub('_', '')
            local cure_menyoo_aids = {['FrontLeft'] = 0, ['FrontRight'] = 1, [2] = 2, [3] = 3, ['BackLeft'] = 4, ['BackRight'] = 5, [6]=6, [7]=7, [8]=8}
            VEHICLE.SET_VEHICLE_TYRE_BURST(vehicle, cure_menyoo_aids[k], false, 0.0)
        end
    end
    local mods = menyoo_build_properties_table(data['Mods'].kids)
    
    for k,v in pairs(neons) do
        local comp = {['Left']=0, ['Right']=1, ['Front']=2, ['Back']=3}
        VEHICLE._SET_VEHICLE_NEON_LIGHT_ENABLED(vehicle, comp[k], to_boolean(v))
    end

    VEHICLE.SET_VEHICLE_WHEEL_TYPE(vehicle, tonumber(data['WheelType']))
    for k,v in pairs(mods) do
        k = k:gsub('_', '')
        v = split_str(v, ',')
        VEHICLE.SET_VEHICLE_MOD(vehicle, tonumber(k), tonumber(v[1]), to_boolean(v[2]))
    end

    for k,v in pairs(colors) do
        colors[k] = tonumber(v)
    end

    VEHICLE.SET_VEHICLE_COLOURS(vehicle, colors['Primary'], colors['Secondary'])
    VEHICLE.SET_VEHICLE_EXTRA_COLOURS(vehicle, colors['Pearl'], colors['Rim'])
    VEHICLE.SET_VEHICLE_TYRE_SMOKE_COLOR(vehicle, colors['tyreSmoke_R'], colors['tyreSmoke_G'], colors['tyreSmoke_B'])
    VEHICLE._SET_VEHICLE_INTERIOR_COLOR(vehicle, colors['LrInterior'])
    VEHICLE._SET_VEHICLE_DASHBOARD_COLOR(vehicle, colors['LrDashboard'])
    local livery = tonumber(data['Livery'])
    if livery == -1 then
        livery = 0
    end
    VEHICLE.SET_VEHICLE_LIVERY(vehicle, livery)
    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, data['NumberPlateText'])
    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(vehicle, tonumber(data['NumberPlateTextIndex']))
    -- wheel invis here
    -- engine sound name here
    VEHICLE.SET_VEHICLE_WINDOW_TINT(vehicle, tonumber(data['WindowTint']))
    VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(vehicle, to_boolean(data['BulletProofTyres']))
    VEHICLE. SET_VEHICLE_DIRT_LEVEL(vehicle, tonumber(data['DirtLevel']))
    VEHICLE.SET_VEHICLE_ENVEFF_SCALE(vehicle, tonumber(data['PaintFade']))
    VEHICLE.SET_CONVERTIBLE_ROOF_LATCH_STATE(vehicle, tonumber(data['RoofState']))
    VEHICLE.SET_VEHICLE_SIREN(vehicle, to_boolean(data['SirenActive']))
    VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, to_boolean(data['EngineOn']), true, false)
    -- not sure how to set lights on
    AUDIO.SET_VEHICLE_RADIO_LOUD(vehicle, to_boolean(data['IsRadioLoud']))
    VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle, tonumber(data['LockStatus']))
    if data['EngineHealth'] ~= nil then
        VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, tonumber(data['EngineHealth']))
    end
    log("Preprocessing complete for vehicle " .. vehicle)
end

function menyoo_build_properties_table(kids)
    log("Building a menyoo properties table...")
    if kids ~= nil then
        local table = {}
        for k,v in pairs(kids) do
            local name = v.name
            local val = get_element_text(v)
            table[name] = val
        end
        return table
    end
    return nil
end

function menyoo_load_map(path)
    local all_entities = {}
    util.toast("Your map is loading. This can take some time.")
    log("Loading a map from " .. path)
    local entity_initial_handles = {}
    local xml_tbl = parse_xml(path).root
    -- n appears to be the enum of the kid, k is the actual kid table
    local data = {}
    for a,b in pairs(xml_tbl.kids) do
        local vproperties = {}
        local pproperties = {}
        local name = b.name
        local isvehicle = false
        local isped = false
        if name == 'ReferenceCoords' then
            for k,v in pairs(b.kids) do
                if v.name == 'X' then
                    mmblip_x = tonumber(get_element_text(v))
                elseif v.name == 'Y' then
                    mmblip_y = tonumber(get_element_text(v))
                elseif v.name == 'Z' then
                    mmblip_z = tonumber(get_element_text(v))
                end
            end
            mmblip = HUD.ADD_BLIP_FOR_COORD(mmblip_x, mmblip_y, mmblip_z)
            HUD.SET_BLIP_SPRITE(mmblip, 77)
            HUD.SET_BLIP_COLOUR(mmblip, 48)
        end
        if name == 'Placement' then
            for c,d in pairs(b.kids) do
                log(d.name)
                if d.name == 'PositionRotation' then
                    for e, f in pairs(d.kids) do
                        data[f.name] = get_element_text(f)
                    end
                elseif d.name == 'VehicleProperties' then
                    log("vprope")
                    isvehicle = true
                    for n, p in pairs(d.kids) do
                        local prop_name = p.name
                        if prop_name == 'Colours' or prop_name == 'Neons' or prop_name == 'Mods' or prop_name == 'DoorsOpen' or prop_name == 'DoorsBroken' or prop_name == 'TyresBursted' then
                            vproperties[prop_name] = p
                        else
                            vproperties[prop_name]  = get_element_text(p)
                        end
                    end
                elseif d.name == 'PedProperties' then
                    isped = true
                    pproperties[d.name] = d
                else
                    data[d.name] = get_element_text(d)
                end
                log("done")
            end
            mmpos = {}
            mmpos.x = tonumber(data['X'])
            mmpos.y = tonumber(data['Y'])
            mmpos.z = tonumber(data['Z'])
            mmrot = {}
            mmrot.pi = tonumber(data['Pitch'])
            mmrot.ro = tonumber(data['Roll'])
            mmrot.ya = tonumber(data['Yaw'])
            if STREAMING.IS_MODEL_VALID(data['ModelHash']) then
                local mment = 0
                if isvehicle then
                    request_model_load(data['ModelHash'])
                    mment = entities.create_vehicle(data['ModelHash'], mmpos, mmrot.ya)
                    menyoo_preprocess_entity(mment, data)
                    menyoo_preprocess_car(mment, vproperties)
                elseif isped then
                    request_model_load(data['ModelHash'])
                    mment = entities.create_ped(0, data['ModelHash'], mmpos, mmrot.ya)
                    menyoo_preprocess_ped(mment, pproperties, {})
                    menyoo_preprocess_entity(mment, data)
                else
                    request_model_load(data['ModelHash'])
                    mment = entities.create_object(data['ModelHash'], mmpos)
                    menyoo_preprocess_entity(mment, data)
                end
                table.insert(all_entities, mment)
                ENTITY.SET_ENTITY_ROTATION(mment, mmrot.pi, mmrot.ro, mmrot.ya, 2, true)
            else
                util.toast("Some invalid models were found. Make sure you aren\'t using XML\'s that require mods.")
            end
        end
    end
    mm_maproot = menu.list(menyoomloaded_root, path:gsub(maps_dir, "") .. ' [' .. mmblip .. ']', {"lancescriptmenyooloadedmaps" .. mmblip}, "Maps you have loaded")
    menu.action(mm_maproot, "Teleport to map", {"menyoomteleportto" .. mmblip}, "Teleport to this map.", function(on_click)
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(PLAYER.PLAYER_PED_ID(), mmpos.x, mmpos.y, mmpos.z, false, false, false)
    end)

    menu.action(mm_maproot, "Delete map", {"menyoomdelete" .. mmblip}, "cease it to exist.", function(on_click)
        for k,v in pairs(all_entities) do
            entities.delete_by_handle(v)
        end
        menu.delete(mm_maproot)
        -- apparently remove blip is fucked, so we set sprite to invis as a failsafe
        HUD.SET_BLIP_ALPHA(mmblip, 0)
        HUD.REMOVE_BLIP(mmblip)
    end)
    util.toast("Map load complete. Look for a magenta-colored L on your map.")
end

function menyoo_load_vehicle(path, ped, doteleport, ours)
    log("Loading vehicle for ped " .. ped)
    local all_entities = {}
    if ours then
        log("This is ours")
        mvped = PLAYER.PLAYER_PED_ID()
    else
        log("This is theirs")
        mvped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(ped)
    end
    log("Loading a vehicle from " .. path)
    local entity_initial_handles = {}
    local data = {}
    local vproperties = {}
    local xml_tbl = parse_xml(path).root
    -- n appears to be the enum of the kid, k is the actual kid table
    for k,v in pairs(xml_tbl.kids) do
        local name = v.name
        if name == 'VehicleProperties' then
            for n, p in pairs(v.kids) do
                local prop_name = p.name
                if prop_name == 'Colours' or prop_name == 'Neons' or prop_name == 'Mods' or prop_name == 'DoorsOpen' or prop_name == 'DoorsBroken' or prop_name == 'TyresBursted' then
                    vproperties[prop_name] = p
                else
                    vproperties[prop_name]  = get_element_text(p)
                end
            end
        else
            if name == 'SpoonerAttachments' then
                data[name] = v
            else
                local el_text = get_element_text(v)
                data[name] = el_text
            end
        end
    end
    request_model_load(data['ModelHash'])
    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(mvped, 0.0, 5.0, 0.0)
    local vehicle = entities.create_vehicle(data['ModelHash'], coords, ENTITY.GET_ENTITY_HEADING(PLAYER.PLAYER_PED_ID()))
    table.insert(all_entities, vehicle)
    ENTITY.SET_ENTITY_INVINCIBLE(vehicle, true)
    if doteleport then
        PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), vehicle, -1)
    end
    if data['InitialHandle'] == nil then
        data['InitialHandle'] = math.random(10000, 30000)
    end
    entity_initial_handles[data['InitialHandle']] = vehicle
    -- apply natives that can apply to any entity
    menyoo_preprocess_entity(vehicle, data)
    menyoo_preprocess_car(vehicle, vproperties)
    -- vehicle-specific natives
    -- now for the attachments...
    local attachments = data['SpoonerAttachments']
    all_attachments = {}
    if attachments ~= nil then
        for a,b in pairs(attachments.kids) do
            local vproperties = {}
            -- each item here should be "attachment" element
            local att_data = {}
            for c,d in pairs(b.kids) do
                local name = d.name
                local val = get_element_text(d)
                if name == 'PedProperties' or name == 'Attachment' or name == 'TaskSequence' then
                    att_data[name] = d
                elseif name == 'VehicleProperties' then
                    for n, p in pairs(d.kids) do
                        local prop_name = p.name
                        if prop_name == 'Colours' or prop_name == 'Neons' or prop_name == 'Mods' or prop_name == 'DoorsOpen' or prop_name == 'DoorsBroken' or prop_name == 'TyresBursted' then
                            vproperties[prop_name] = p
                        else
                            vproperties[prop_name]  = get_element_text(p)
                        end
                    end
                else
                    att_data[name] = val
                end
            end
            request_model_load(att_data['ModelHash'])
            -- 1 = ped, 2 = vehicle, 3 = object
            local attachment_info = menyoo_build_properties_table(att_data['Attachment'].kids)
            local entity = nil
            local isped = false
            if att_data['Type'] == '1' then
                local ped = entities.create_ped(0, att_data['ModelHash'], coords, ENTITY.GET_ENTITY_HEADING(PLAYER.PLAYER_PED_ID()))
                menyoo_preprocess_ped(ped, att_data, entity_initial_handles)
                entity = ped
            elseif att_data['Type'] == '2' then
                local veh = entities.create_vehicle(att_data['ModelHash'], coords, ENTITY.GET_ENTITY_HEADING(PLAYER.PLAYER_PED_ID()))
                entity = veh
                menyoo_preprocess_entity(veh, att_data)
                menyoo_preprocess_car(veh, vproperties)
            elseif att_data['Type'] == '3' then
                local obj = entities.create_object(att_data['ModelHash'], coords)
                entity = obj
                menyoo_preprocess_entity(obj, att_data)
                -- obj code
            end
            table.insert(all_entities, entity)
            ENTITY.SET_ENTITY_INVINCIBLE(entity, true)
            local bone = tonumber(attachment_info['BoneIndex'])
            local x = tonumber(attachment_info['X'])
            local y = tonumber(attachment_info['Y'])
            local z = tonumber(attachment_info['Z'])
            local pitch = tonumber(attachment_info['Pitch'])
            local yaw = tonumber(attachment_info['Yaw'])
            local roll = tonumber(attachment_info['Roll'])
            all_attachments[entity] = {}
            all_attachments[entity]['attachedto'] = attachment_info['AttachedTo']
            all_attachments[entity]['bone'] = bone
            all_attachments[entity]['x'] = x
            all_attachments[entity]['y'] = y
            all_attachments[entity]['z'] = z
            all_attachments[entity]['pitch'] = pitch
            all_attachments[entity]['yaw'] = yaw
            all_attachments[entity]['roll'] = roll
            all_attachments[entity]['isped'] = isped
        end
        for k, v in pairs(all_attachments) do
            ENTITY.ATTACH_ENTITY_TO_ENTITY(k, entity_initial_handles[v['attachedto']], v['bone'], v['x'], v['y'], v['z'], v['pitch'], v['roll'], v['yaw'], true, false, true, v['isped'], 2, true)
        end
    end
    log("Vehicle has been loaded.")
    local this_blip = HUD.ADD_BLIP_FOR_ENTITY(vehicle)
    HUD.SET_BLIP_SPRITE(this_blip, 77)
    HUD.SET_BLIP_COLOUR(this_blip, 47)
    local this_veh_root = menu.list(menyoovloaded_root, vehicle .. " [" .. VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(ENTITY.GET_ENTITY_MODEL(vehicle)) .. "]", {"lancescriptmenyoov" .. vehicle}, "")
    menu.action(this_veh_root, "Delete", {"deletemenyoov" .. vehicle}, "Delete this vehicle. Make it cease to exist.", function(on_click)
        for k,v in pairs(all_entities) do
            entities.delete_by_handle(v)
        end
        menu.delete(this_veh_root)
        HUD.SET_BLIP_ALPHA(this_blip, 0)
        HUD.REMOVE_BLIP(this_blip)
    end)
    menu.action(this_veh_root, "Teleport inside", {"teleportemenyoov" .. vehicle}, "oh fuck yeah ride it", function(on_click)
        PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), vehicle, -1)
    end)
    return vehicle
end

vehicle_uses = 0
ped_uses = 0
pickup_uses = 0
player_uses = 0
object_uses = 0
robustmode = false
reap = false
function mod_uses(type, incr)
    -- this func is a patch. every time the script loads, all the toggles load and set their state. in some cases this makes the _uses optimization negative and breaks things. this prevents that.
    if incr < 0 and is_loading then
        -- ignore if script is still loading
        log("Not incrementing use var of type " .. type .. " by " .. incr .. "- script is loading")
        return
    end
    log("Incrementing use var of type " .. type .. " by " .. incr)
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

-- this function should not block script execution as it is always ran in either a thread or by an action (that should complete in less than 5 seconds, otherwise safety kicks in)
function request_control_of_entity(ent)
    if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(ent) and util.is_session_started() then
        log("Requesting entity control of " .. ent)
        local netid = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(ent)
        NETWORK.SET_NETWORK_ID_CAN_MIGRATE(netid, true)
        local st_time = os.time()
        while not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(ent) do
            -- intentionally silently fail, otherwise we are gonna spam the everloving shit out of the user
            if os.time() - st_time >= 5 then
                log("Failed to request entity control in 5 seconds (entity " .. ent .. ")")
                break
            end
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(ent)
            util.yield()
        end
    end
end

function get_model_size(hash)
    log("Getting model size of hash " .. hash)
    log("alloc 24 bytes, modelsize minptr")
    local minptr = memory.alloc(24)
    log("alloc 24 bytes, modelsize maxptr")
    local maxptr = memory.alloc(24)
    MISC.GET_MODEL_DIMENSIONS(hash, minptr, maxptr)
    min = memory.read_vector3(minptr)
    max = memory.read_vector3(maxptr)
    local size = {}
    size['x'] = max['x'] - min['x']
    size['y'] = max['y'] - min['y']
    size['z'] = max['z'] - min['z']
    size['max'] = math.max(size['x'], size['y'], size['z'])
    log("model size free mem")
    memory.free(minptr)
    memory.free(maxptr)
    log("Got model size of hash, it was " .. size['x'] .. " " .. size['y'] .. " " .. size['z'])
    return size
end

function do_label_preset(label, text)
    log("Setting up label present for label " .. label .. " with text " .. text)
    menu.trigger_commands("addlabel " .. label)
    local prep = "edit" .. string.gsub(label, "_", "") .. " " .. text
    menu.trigger_commands(prep)
    menu.trigger_commands("lancescriptlabelpresets")
    util.toast("Label set!")
end

function set_player_into_suitable_seat(ent)
    log("Setting player into suitable seat of entity " .. ent)
    local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(ent, -1)
    if not is_ped_player(driver) or driver == 0 then
        if driver ~= 0 then
            entities.delete_by_handle(driver)
        end
        PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), ent, -1)
    else
        for i=0, VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(ent) do
            if VEHICLE.IS_VEHICLE_SEAT_FREE(ent, i) then
                PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), ent, -1)
            end
        end
    end
end

function to_rgb(r, g, b, a)
    local color = {}
    color.r = r
    color.g = g
    color.b = b
    color.a = a
    return color
end
black = to_rgb(0.0,0.0,0.0,1.0)
white = to_rgb(1.0,1.0,1.0,1.0)
red = to_rgb(1,0,0,1)
green = to_rgb(0,1,0,1)
blue = to_rgb(0.0,0.0,1.0,1.0)

menu.action(credits_root, "Sainan", {}, "Donating $200 worth of crypto (top donor), helping with reverse engineering GTA V, developing Stand that makes Lancescript possible, and generally being a big help. Thanks for everything.", function(on_click)
end)
menu.action(credits_root, "61k", {}, "Donating $20 worth of Litecoin. Thank you for your support.", function(on_click)
end)
menu.action(credits_root, "QuickNET", {}, "Big help with reverse engineering, natives, memory stuff, etc. Thanks.", function(on_click)
end)
menu.action(credits_root, "YoYo", {}, "Donating to my PayPal. Thanks for your support! :)", function(on_click)
end)
menu.action(credits_root, "ICYPhoenix", {}, "Inspiring Lancescript, help with code/natives", function(on_click)
end)
menu.action(credits_root, "Hollywood Collins", {}, "For continued support of Lancescript. Thanks a ton for the marketing ;)", function(on_click)
end)
menu.action(credits_root, "aaronlink127", {}, "Code suggestions", function(on_click)
end)

menu.action(credits_root, "Axhov", {}, "Developer of TEOF", function(on_click)
end)

menu.action(credits_root, "Nowiry", {}, "Great developer, making some useful funcs that Lancescript uses, also helps in the continued development of TEOF", function(on_click)
end)
menu.action(credits_root, "Lancito01", {}, "Donating to me :)", function(on_click)
end)
menu.action(credits_root, "ZERO", {}, "Suggesting ped flags for burning man, and former swim in air", function(on_click)
end)
menu.action(credits_root, "Y1tzy", {}, "Donating to me :)", function(on_click)
end)
menu.action(credits_root, "Anyone who suggested things", {}, ":)", function(on_click)
end)
menu.action(credits_root, PLAYER.GET_PLAYER_NAME(players.user()), {}, "For using Lancescript!", function(on_click)
end)

function show_custom_alert_until_enter(l1)
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

custom_rgb = true
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

if SCRIPT_MANUAL_START then
    AUDIO.PLAY_SOUND(-1, "Virus_Eradicated", "LESTER1A_SOUNDS", 0, 0, 1)
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
            directx.draw_texture(lancescript_logo, 0.14, 0.14, 0.5, 0.5, 0.5, 0.5, 0, 1, 1, 1, logo_alpha)
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

function dispatch_griefer_jesus(target)
    log("Dispatched griefer jesus.")
    griefer_jesus = util.create_thread(function(thr)
        util.toast("Griefer jesus sent!")
        request_model_load(-835930287)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(target)
        coords = ENTITY.GET_ENTITY_COORDS(target_ped, false)
        coords.x = coords['x']
        coords.y = coords['y']
        coords.z = coords['z']
        local jesus = entities.create_ped(1, -835930287, coords, 90.0)
        ENTITY.SET_ENTITY_INVINCIBLE(jesus, true)
        PED.SET_PED_HEARING_RANGE(jesus, 9999)
	    PED.SET_PED_CONFIG_FLAG(jesus, 281, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(jesus, 5, true)
	    PED.SET_PED_COMBAT_ATTRIBUTES(jesus, 46, true)
        PED.SET_PED_CAN_RAGDOLL(jesus, false)
        WEAPON.GIVE_WEAPON_TO_PED(jesus, util.joaat("WEAPON_RAILGUN"), 9999, true, true)
		WEAPON.SET_PED_DROPS_WEAPONS_WHEN_DEAD(ped, false)
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
                local behind = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(target_ped, math.random(-10, 10),  math.random(-10, 10), 0.0)
                ENTITY.SET_ENTITY_COORDS(jesus, behind['x'], behind['y'], behind['z'], false, false, false, false)
            end
            -- if jesus disappears we can just make another lmao
            if not ENTITY.DOES_ENTITY_EXIST(jesus) then
                util.toast("Jesus apparently stopped existing. Stopping Jesus thread.")
                util.stop_thread()
            end
            local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(target)
            if not players.exists(target) then
                util.toast("The player target has been lost. The griefer Jesus thread is stopping.")
                util.stop_thread()
            else
                TASK.TASK_COMBAT_PED(jesus, target_ped, 0, 16)
            end
            util.yield()
        end
    end)
end

function dispatch_griefer_jesus2(target)
    log("Dispatched griefer jesus.")
    griefer_jesus = util.create_thread(function(thr)
        util.toast("Griefer jesus sent!")
        request_model_load(-835930287)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(target)
        coords = ENTITY.GET_ENTITY_COORDS(target_ped, false)
        coords.x = coords['x']
        coords.y = coords['y']
        coords.z = coords['z']
        local jesus = entities.create_ped(1, -835930287, coords, 90.0)
        ENTITY.SET_ENTITY_INVINCIBLE(jesus, false)
        PED.SET_PED_HEARING_RANGE(jesus, 9999)
	    PED.SET_PED_CONFIG_FLAG(jesus, 281, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(jesus, 5, true)
	    PED.SET_PED_COMBAT_ATTRIBUTES(jesus, 46, true)
        WEAPON.GIVE_WEAPON_TO_PED(jesus, util.joaat("WEAPON_RAILGUN"), 9999, true, true)
		WEAPON.SET_PED_DROPS_WEAPONS_WHEN_DEAD(ped, false)
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
                local behind = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, math.random(-10, 10),  math.random(-10, 10), 0.0)
                ENTITY.SET_ENTITY_COORDS(jesus, behind['x'], behind['y'], behind['z'], false, false, false, false)
            end
            -- if jesus disappears we can just make another lmao
            if ENTITY.IS_ENTITY_DEAD(jesus) then
				wait(3000)
					util.toast("Jesus Died. Stopping Jesus thread.")
					util.stop_thread()
            end
            local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(target)
            if not players.exists(target) then
                util.toast("The player target has been lost. The griefer Jesus thread is stopping.")
                util.stop_thread()
            else
                TASK.TASK_COMBAT_PED(jesus, target_ped, 0, 16)
            end
            util.yield()
        end
    end)
end

function kick_from_veh(pid)
    log("Kicking " .. pid .. " from vehicle.")
    menu.trigger_commands("vehkick" .. PLAYER.GET_PLAYER_NAME(pid))
end

function npc_jack(target, nearest)
    npc_jackthr = util.create_thread(function(thr)
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(target)
        local last_veh = PED.GET_VEHICLE_PED_IS_IN(player_ped, true)
        kick_from_veh(target)
        local st = os.time()
        while not VEHICLE.IS_VEHICLE_SEAT_FREE(last_veh, -1) do 
            if os.time() - st >= 10 then
                util.toast("Failed to free car seat in 10 seconds")
                util.stop_thread()
            end
            util.yield()
        end
        local hash = 0x9C9EFFD8
        request_model_load(hash)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, -2.0, 0.0, 0.0)
        coords.x = coords['x']
        coords.y = coords['y']
        coords.z = coords['z']
        local ped = entities.create_ped(28, hash, coords, 30.0)
        ENTITY.SET_ENTITY_INVINCIBLE(ped, true)
        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
        PED.SET_PED_FLEE_ATTRIBUTES(ped, 0, false)
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true)
        PED.SET_PED_INTO_VEHICLE(ped, last_veh, -1)
        VEHICLE.SET_VEHICLE_ENGINE_ON(last_veh, true, true, false)
        TASK.TASK_VEHICLE_DRIVE_TO_COORD(ped, last_veh, math.random(1000), math.random(1000), math.random(100), 100, 1, ENTITY.GET_ENTITY_MODEL(last_veh), 786996, 5, 0)
        util.toast("Vehicle jack complete!")
        util.stop_thread()
    end)
end

menu.hyperlink(lancescript_root, "LanceScript Archive", "https://archive.org/details/lancescript-incomplete-archive", "an archive of the lancescript versions I downloaded as they came out, dating to before the repository was a thing. NOT MEANT TO BE USED. THESE ARE OUTDATED.")

menu.toggle(lancescript_root, "Show active entity pools", {"entitypoolupdates"}, "Toasts what entity pools are being updated every tick. The more you see, the more performance loss; getting all entities is a heavy task.", function(on)
    show_updates = on
end)

menu.toggle(lancescript_root, "Robust mode", {"robustmode"}, "Robust mode automatically spectates a target player for some attack options and then yields for a bit to maximize the chance of it working. Consequentially, this makes the task take longer. This is especially helpful if a player is far away.", function(on)
    robustmode = on
end, false)

menu.toggle(lancescript_root, "Reap entities", {"reap"}, "Requests entity ownership for every entity in loops/pools. Should make things more reliable in most cases, but will also cause some more resource usage. Only use it if almost nothing is being affected.", function(on)
    reap = on
end, false)

menu.action(lancescript_root, "Toast stat", {"toaststat"}, "Input a stat to toast", function(on_click)
    util.toast("Please type the stat name")
    menu.show_command_box("toaststat ")
end, function(on_command)
    log("alloc 4 bytes, toaststat")
    local outptr = memory.alloc(4)
    STATS.STAT_GET_INT(MISC.GET_HASH_KEY(on_command), outptr, -1)
    util.toast("STAT returned " .. memory.read_int(outptr))
    log("toast stat free mem")
    memory.free(outptr)
end)

joinsound = false
menu.toggle(sounds_root, "Sound on player join", {"joinsound"}, "", function(on)
    joinsound = on
end)

leavesound = false
menu.toggle(sounds_root, "Sound on player leave", {"leavesound"}, "", function(on)
    leavesound = on
end)

all_vehicles = {}
all_objects = {}
all_players = {}
all_peds = {}
all_pickups = {}
player_cur_car = 0

infibounty = false
function start_infibounty_thread()
    infibounty_thread = util.create_thread(function (thr)
        while true do
            if not infibounty then
                util.stop_thread()
            else
                menu.trigger_commands("bountyall 10000")
            end
            util.yield(60000)
        end
    end)
end

--_SET_HYDRAULIC_WHEEL_VALUE(Vehicle vehicle, int wheelId, float value)
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
                if player_cur_car ~= veh and not is_ped_player(VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, -1)) then
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

tint_thread = util.create_thread(function (thr)
    cur_tint = 0
    while true do
        if cur_tint < 7 then
            cur_tint = cur_tint + 1
        else
            cur_tint = 0
        end
        util.yield(200)
    end
end)

function is_ped_player(ped)
    if PED.GET_PED_TYPE(ped) >= 4 then
        return false
    else
        return true
    end
end

function request_model_load(hash)
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

function request_ptfx_load(hash)
    request_time = os.time()
    STREAMING.REQUEST_NAMED_PTFX_ASSET(hash)
    while not STREAMING.HAS_PTFX_ASSET_LOADED(hash) do
        if os.time() - request_time >= 10 then
            break
        end
        util.yield()
    end
end

function get_random_ped()
    peds = entities.get_all_peds_as_handles()
    npcs = {}
    valid = 0
    for k,p in pairs(peds) do
        if p ~= nil and not is_ped_player(p) then
            table.insert(npcs, p)
            valid = valid + 1
        end
    end
    return npcs[math.random(valid)]
end


function spawn_object_in_front_of_ped(ped, hash, ang, room, zoff, setonground)
    coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, room, zoff)
    request_model_load(hash)
    hdng = ENTITY.GET_ENTITY_HEADING(ped)
    coords.x = coords['x']
    coords.y = coords['y']
    coords.z = coords['z']
    new = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, coords['x'], coords['y'], coords['z'], true, false, false)
    ENTITY.SET_ENTITY_HEADING(new, hdng+ang)
    if setonground then
        OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(new)
    end
    return new
end

entgun = false
shootent = -422877666
menu.toggle(entity_gun, "Entity gun", {"entgun"}, "Shoot them entities", function(on)
    entgun = on
end, false)

menu.action(entity_gun, "Dildo (default)", {"shootentdildo"}, "Click to choose this entity to fire", function(on_click)
    shootent = -422877666
    util.toast("You will now shoot this entity")
end)

menu.action(entity_gun, "Soccer ball", {"shootentsoccer"}, "Click to choose this entity to fire", function(on_click)
    shootent = -717142483
    util.toast("You will now shoot this entity")
end)

menu.action(entity_gun, "Bucket", {"shootentbucket"}, "Click to choose this entity to fire", function(on_click)
    shootent = util.joaat("prop_paints_can07")
    util.toast("You will now shoot this entity")
end)

entgungrav = false
menu.toggle(entity_gun, "Entity gun gravity", {"entgungravity"}, "", function(on)
    entgungrav = on
end, false)


menu.action(entity_gun, "Custom obj model", {"customentgunmodel"}, "Input a custom model to shoot. The model name, not the hash.", function(on_click)
    util.toast("Please input the model name")
    menu.show_command_box("customentgunmodel" .. " ")
end, function(on_command)
    local hash = util.joaat(on_command)
    if not STREAMING.IS_MODEL_VALID(hash) then
        util.toast("That was an invalid model.")
    else
        shootent = hash
        util.toast("Entity gun has been set to shoot " .. on_command)
    end
end)

rainbow_tint = false
menu.toggle(weapons_root, "Rainbow weapon tint", {"rainbowtint"}, "boogie", function(on)
    plyr = PLAYER.PLAYER_PED_ID()
    if on then
        local last_tint = WEAPON.GET_PED_WEAPON_TINT_INDEX(PLAYER.PLAYER_PED_ID(), WEAPON.GET_SELECTED_PED_WEAPON(PLAYER.PLAYER_PED_ID()))
        rainbow_tint = true
    else
        rainbow_tint = false
        WEAPON.SET_PED_WEAPON_TINT_INDEX(PLAYER.PLAYER_PED_ID(),WEAPON.GET_SELECTED_PED_WEAPON(PLAYER.PLAYER_PED_ID()), last_tint)
    end
end, false)

menu.toggle(weapons_root, "Invisible weapons", {"invisguns"}, "Makes your weapons invisible. Might be local only. You need to retoggle when switching weapons.", function(on)
    local plyr = PLAYER.PLAYER_PED_ID()
    WEAPON.SET_PED_CURRENT_WEAPON_VISIBLE(plyr, not on, false, false, false) 
end, false)

menu.toggle_loop(cross, "No Crosshairs (PVP/E)", {"invischpvp"}, "Makes your Crosshair invisible. Designed for PVP/E. Automatically disabled when holding snipers and when in vehicles with weapons. Use in conjuction with Crosshair lua by CocoW in the repository for functioning custom crosshairs :pog:", function()
    local currentWeapon = WEAPON.GET_SELECTED_PED_WEAPON(PLAYER.PLAYER_PED_ID())
	local plyr = PLAYER.PLAYER_PED_ID()
	local vehicle = PED.IS_PED_IN_ANY_VEHICLE(plyr, true) 
	cars = {}
	if vehicle == true then
		local cock = PED.GET_VEHICLE_PED_IS_IN(plyr, false)
        if not VEHICLE.DOES_VEHICLE_HAVE_WEAPONS(cock) then
			HUD.HIDE_HUD_COMPONENT_THIS_FRAME(14)
		end
	else
		if WEAPON.GET_WEAPONTYPE_GROUP(currentWeapon) ~= -1212426201 then
			HUD.HIDE_HUD_COMPONENT_THIS_FRAME(14)
		end
    end
end)

menu.toggle_loop(cross, "No Crosshairs", {"invisch"}, "Makes your Crosshair invisible. Does not disable itself unless you disable it. Use in conjuction with Crosshair lua by CocoW in the repository for functioning custom crosshairs :pog:", function()
    HUD.HIDE_HUD_COMPONENT_THIS_FRAME(14)
end)

menu.toggle_loop(cross, "No Crosshairs (PVP/E) (Snipers Included)", {"invischpvp2"}, "Makes your Crosshair invisible. Designed for PVP/E. Automatically disabled when in vehicles with weapons, but NOT when holding snipers. Use in conjuction with Crosshair lua by CocoW in the repository for functioning custom crosshairs :pog:", function()
    local currentWeapon = WEAPON.GET_SELECTED_PED_WEAPON(PLAYER.PLAYER_PED_ID())
	local plyr = PLAYER.PLAYER_PED_ID()
	local vehicle = PED.IS_PED_IN_ANY_VEHICLE(plyr, true) 
	if vehicle == true then
		local cock = PED.GET_VEHICLE_PED_IS_IN(plyr, false)
        if not VEHICLE.DOES_VEHICLE_HAVE_WEAPONS(cock) then
			HUD.HIDE_HUD_COMPONENT_THIS_FRAME(14)
		end
	else
		HUD.HIDE_HUD_COMPONENT_THIS_FRAME(14)
    end
end)

aim_info = false
menu.toggle(weapons_root, "Aim info", {"aiminfo"}, "Displays info of the entity you\'re aiming at", function(on)
    aim_info = on
end, false)

gun_stealer = false
menu.toggle(weapons_root, "Car stealer gun", {"gunstealer"}, "Shoot a vehicle to steal it. If it is a car with a player driver, it will teleport you into the next available seat.", function(on)
    gun_stealer = on
end, false)

paintball = false
menu.toggle(weapons_root, "Paintball", {"paintball"}, "Shoot a vehicle and it will turn into a random color! :)", function(on)
    paintball = on
end, false)

drivergun = false
menu.toggle(weapons_root, "NPC driver gun", {"drivergun"}, "Shoot a vehicle to insert an NPC driver that will drive the vehicle to a random area", function(on)
    drivergun = on
end, false)

grapplegun = false
menu.toggle(weapons_root, "Grapple gun", {"grapplegun"}, "fun stuff", function(on)
    if on then
        grapplegun = true
        util.toast("Grapple gun is now active! Shoot somewhere with a pistol. Press R while grappling to stop grappling.")
        menu.trigger_commands("getgunspistol")
    else
        grapplegun = false
    end
end, false)

-- silent aimbot code start

menu.toggle(silent_aimbotroot, "Silent aimbot", {"saimbottoggle"}, "", function(on)
    silent_aimbot = on
    start_silent_aimbot()
end)

menu.toggle(silent_aimbotroot, "Silent aimbot players", {"saimbotplayers"}, "", function(on)
    satarget_players = on
end)

menu.toggle(silent_aimbotroot, "Silent aimbot NPC\'s", {"saimbotpeds"}, "", function(on)
    satarget_npcs = on
end)

menu.toggle(silent_aimbotroot, "Use FOV", {"saimbotusefov"}, "You won\'t kill someone through your asshole.", function(on)
    satarget_usefov = on
end)

sa_fov = 180
menu.slider(silent_aimbotroot, "FOV", {"saimbotfov"}, "", 1, 270, 180, 1, function(s)
    sa_fov = s
end)

menu.toggle(silent_aimbotroot, "Ignore targets inside vehicles", {"saimbotnovehicles"}, "If you want to be more realistic, or are having issues hitting targets in vehicles", function(on)
    satarget_novehicles = on
end)

satarget_nogodmode = true
menu.toggle(silent_aimbotroot, "Ignore godmoded targets", {"saimbotnogodmodes"}, "Because what\'s the point?", function(on)
    satarget_nogodmode = on
end, true)

menu.toggle(silent_aimbotroot, "Target friends", {"saimbottargetfriends"}, "", function(on)
    satarget_targetfriends = on
end)

menu.toggle(silent_aimbotroot, "Damage override", {"saimbotdmgo"}, "", function(on)
    satarget_damageo = on
end)

sa_odmg = 100
menu.slider(silent_aimbotroot, "Damage override amount", {"saimbotdamageoverride"}, "", 1, 1000, 100, 1, function(s)
    sa_odmg = s
end)



saimbot_mode = "closest"
function get_aimbot_target()
    local dist = 1000000000
    local cur_tar = 0
    for k,v in pairs(entities.get_all_peds_as_handles()) do
        local target_this = true
        local player_pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
        local ped_pos = ENTITY.GET_ENTITY_COORDS(v, true)
        local this_dist = MISC.GET_DISTANCE_BETWEEN_COORDS(player_pos['x'], player_pos['y'], player_pos['z'], ped_pos['x'], ped_pos['y'], ped_pos['z'], true)
        if PLAYER.PLAYER_PED_ID() ~= v and not ENTITY.IS_ENTITY_DEAD(v) then
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
            if not ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(PLAYER.PLAYER_PED_ID(), v, 17) then
                target_this = false
            end
            if satarget_usefov then
                if not PED.IS_PED_FACING_PED(PLAYER.PLAYER_PED_ID(), v, sa_fov) then
                    target_this = false
                end
            end
            if satarget_novehicles then
                if PED.IS_PED_IN_ANY_VEHICLE(v, true) then 
                    target_this = false
                end
            end
            if satarget_nogodmode then
                if not ENTITY._GET_ENTITY_CAN_BE_DAMAGED(v) then 
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

-- silent aimbot code start
function start_silent_aimbot()
    saimbot_thread = util.create_thread(function (thr)
    while true do
        if not silent_aimbot then
            util.stop_thread()
        end
        local target = get_aimbot_target()
        if target ~= 0 then
            --local t_pos = ENTITY.GET_ENTITY_COORDS(target, true)
            local t_pos = PED.GET_PED_BONE_COORDS(target, 31086, 0.01, 0, 0)
            local t_pos2 = PED.GET_PED_BONE_COORDS(target, 31086, -0.01, 0, 0.00)
            -- debug shit, ignore
            if false then
                GRAPHICS.DRAW_MARKER(0, t_pos['x'], t_pos['y'], t_pos['z'], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.1, 0.1, 0.1, 255, 0, 255, 100, false, true, 2, false, 0, 0, false)
                GRAPHICS.DRAW_MARKER(0, t_pos2['x'], t_pos2['y'], t_pos2['z'], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.1, 0.1, 0.1, 255, 0, 255, 100, false, true, 2, false, 0, 0, false)
            end
            GRAPHICS.DRAW_MARKER(0, t_pos['x'], t_pos['y'], t_pos['z']+2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 1, 255, 0, 255, 100, false, true, 2, false, 0, 0, false)
            if PED.IS_PED_SHOOTING(PLAYER.PLAYER_PED_ID()) then
                local wep = WEAPON.GET_SELECTED_PED_WEAPON(PLAYER.PLAYER_PED_ID())
                local dmg = WEAPON.GET_WEAPON_DAMAGE(wep, 0)
                if satarget_damageo then
                    dmg = sa_odmg
                end
                local veh = PED.GET_VEHICLE_PED_IS_IN(target, false)
                MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(t_pos['x'], t_pos['y'], t_pos['z'], t_pos2['x'], t_pos2['y'], t_pos2['z'], dmg, true, wep, PLAYER.PLAYER_PED_ID(), true, false, 10000, veh)
            end
        end
        util.yield()
    end
end)
end

-- silent aimbot code end

noexplosives = false
menu.toggle(protections_root, "No explosives", {"noexplosives"}, "Automatically removes all explosive projectiles from the world when they spawn, even rockets. Not sure if this works nicely on other players. This is not an extensive list, and only includes some player weapons; vehicle weapons may be unaffected.", function(on)
    noexplosives = on
end, false)

menu.action(protections_root, "Detach everything from everyone", {"detachall"}, "Detaches every attached entity that is attached to a ped. Makes no distinction between player and NPC peds. Kind of funky on other players.", function(on_click)
    detach_all_entities()
end)

tp_all_pickups = false
tp_pickup_tar = PLAYER.PLAYER_PED_ID()
menu.toggle(recoveries_root, "Teleport all pickups", {"tppickups"}, "Teleports all pickups, right to you.", function(on)
    if on then
        tp_all_pickups = true
        mod_uses("pickup", 1)
    else
        tp_all_pickups = false
        mod_uses("pickup", -1)
    end
end, false)

menu.slider(pedmoney_root, "Delay (in ms)", {"pedmoneydelay"}, "Set a delay for ped money, in ms. Raise if getting transaction errors.", 1, 3000, 500, 100, function(s)
    pedmoney_delay = s
end)

ped_flags = {}

menu.action(self_root, "Set/unset custom ped flag", {"custompedflag"}, "Do not touch unless you know what you\'re doing.", function(on_click)
    util.toast("Please input the flag int to use")
    menu.show_command_box("custompedflag ")
end, function(on_command)
    local pflag = tonumber(on_command)
    if ped_flags[pflag] == true then
        ped_flags[pflag] = false
        util.toast("Flag set to false")
    else
        ped_flags[pflag] = true
        util.toast("Flag set to true")
    end
end)

menu.toggle(self_root, "Make me a cop", {"makemecop"}, "Sets your ped as a cop. To make you not a cop, it will suicide you. Will make you invisible to almost all cops, but you will report your own crimes, get a cop voice, have a vision cone, and will not be able to shoot at other cops. SWAT and army will still shoot you.", function(on)
    local ped = PLAYER.PLAYER_PED_ID()
    if on then
        PED.SET_PED_AS_COP(ped, true)
    else
        menu.trigger_commands("suicide")
    end
end)

menu.toggle(self_root, "Burning man", {"burningman"}, "Walk da fire (will turn auto-heal/demi godmode on lol)", function(on)
    ped_flags[430] = on
    if on then
        FIRE.START_ENTITY_FIRE(PLAYER.PLAYER_PED_ID())
        menu.trigger_commands("demigodmode on")
    else
        FIRE.STOP_ENTITY_FIRE(PLAYER.PLAYER_PED_ID())
    end
end)

cinematic_autod = false
menu.toggle(self_root, "Auto-drive to waypoint when in cinematic camera", {"cinematicautodrive"}, "red dead shit. this is made mainly for if you toggle cinematic camera and may break if you hold the cinematic camera key.", function(on)
    cinematic_autod = on
end)

function get_ground_z(coords)
    local start_time = os.time()
    while true do
        if os.time() - start_time >= 5 then
            log("Failed to get ground Z in 5 seconds.")
            return nil
        end
        local success, est = util.get_ground_z(coords['x'], coords['y'], coords['z']+2000)
        if success then
            log("Got ground Z successfully: " .. est)
            return est
        end
        util.yield()
    end
end

function get_waypoint_coords()
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

function max_out_car(veh)
    for i=0, 49 do
        num = VEHICLE.GET_NUM_VEHICLE_MODS(veh, i)
        VEHICLE.SET_VEHICLE_MOD(veh, i, num -1, true)
    end
end

taxi_ped = 0
taxi_veh = 0
taxi_blip = -1
function create_chauffeur(vhash, phash)
    if taxi_veh ~= 0 then
        taxi_veh = 0
        entities.delete_by_handle(taxi_veh)
    end
    if taxi_ped ~= 0 then
        taxi_ped = 0
        HUD.REMOVE_BLIP(taxi_blip)
        entities.delete_by_handle(taxi_ped)
    end
    local plyr = PLAYER.PLAYER_PED_ID()
    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(plyr, 0.0, 5.0, 0.0)
    coords.x = coords['x']
    coords.y = coords['y']
    coords.z = coords['z']
    request_model_load(vhash)
    request_model_load(phash)
    taxi_veh = entities.create_vehicle(vhash, coords, ENTITY.GET_ENTITY_HEADING(plyr))
    max_out_car(taxi_veh)
    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(taxi_veh, "LANCE")
    VEHICLE.SET_VEHICLE_COLOURS(taxi_veh, 145, 145)
    VEHICLE.SET_VEHICLE_INDIVIDUAL_DOORS_LOCKED(taxi_veh, 0, 2)
    ENTITY.SET_ENTITY_INVINCIBLE(taxi_veh, true)
    --VEHICLE.MODIFY_VEHICLE_TOP_SPEED(taxi_veh, 300.0)3
    taxi_ped = entities.create_ped(32, phash, coords, ENTITY.GET_ENTITY_HEADING(plyr))
    taxi_blip = HUD.ADD_BLIP_FOR_ENTITY(taxi_ped)
    HUD.SET_BLIP_COLOUR(taxi_blip, 7)
    ENTITY.SET_ENTITY_INVINCIBLE(taxi_ped, true)
    PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(taxi_ped, true)
    PED.SET_PED_FLEE_ATTRIBUTES(taxi_ped, 0, false)
    --PED.SET_PED_CAN_BE_DRAGGED_OUT(taxi_ped, false)
    VEHICLE.SET_VEHICLE_EXCLUSIVE_DRIVER(taxi_veh, taxi_ped, -1)
    PED.SET_PED_INTO_VEHICLE(taxi_ped, taxi_veh, -1)
    util.toast("Your chauffeur has been created! Enjoy!")
end

menu.action(chauffeur_root, "Chauffeur: Create in kuruma", {"chkuruma"}, "Spawns chauffeur in a kuruma", function(on_click)
    create_chauffeur(410882957, 988062523)
end)

menu.action(chauffeur_root, "Chauffeur: Create in T20", {"cht20"}, "Spawns chauffeur in a kuruma", function(on_click)
    create_chauffeur(1663218586, 988062523)
end)

menu.action(chauffeur_root, "Chauffeur: Create in Insurgent", {"chinsurgent"}, "Spawns chauffeur in a kuruma", function(on_click)
    create_chauffeur(-1860900134, 988062523)
end)

menu.action(chauffeur_root, "Chauffeur: Create in Hakuchou", {"chhakuchou"}, "Spawns chauffeur in hakuchou", function(on_click)
    create_chauffeur(1265391242, 988062523)
end)
--1265391242


menu.action(chauffeur_root, "Chauffeur: Drive to waypoint", {"chwaypoint"}, "Commands your chauffeur to go to the waypoint. HE WILL GET THERE, WHATEVER IT TAKES. This includes going the wrong way, hitting peds, etc.", function(on_click)
    if taxi_ped == 0 then
        util.toast("Create a chauffeur before doing this.")
        return
    end
    local goto_coords = get_waypoint_coords()
    if goto_coords ~= nil then
        TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(taxi_ped, taxi_veh, goto_coords['x'], goto_coords['y'], goto_coords['z'], 300.0, 786996, 5)
    end
end)

menu.action(chauffeur_root, "Chauffeur: Teleport into car", {"chtp2car"}, "Teleports you into the chauffeur\'s car", function(on_click)
    if taxi_ped == 0 then
        util.toast("Create a chauffeur before doing this.")
        return
    end
    local plyr = PLAYER.PLAYER_PED_ID()
    PED.SET_PED_INTO_VEHICLE(plyr, taxi_veh, 0)
end)

menu.action(chauffeur_root, "Chauffeur: Drive to me", {"chtp2me"}, "Drives the chauffeur\'s car to you", function(on_click)
    if taxi_veh == 0 then
        util.toast("Create a chauffeur before doing this.")
        return
    end
    local plyr = PLAYER.PLAYER_PED_ID()
    goto_coords = ENTITY.GET_ENTITY_COORDS(plyr, true)
    TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(taxi_ped, taxi_veh, goto_coords['x'], goto_coords['y'], goto_coords['z'], 300.0, 786996, 5)
    util.toast("They\'re on their way.")
end)

menu.action(chauffeur_root, "Chauffeur: Fix car", {"chfix"}, "Fixes/flips the car", function(on_click)
    if taxi_veh == 0 then
        util.toast("Create a chauffeur before doing this.")
        return
    end
    OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(taxi_veh)
end)

--PLACE_OBJECT_ON_GROUND_PROPERLY(Object object)

menu.toggle(chauffeur_root, "Chauffeur: Lock doors", {"chlock"}, "Locks the doors of chauffeur\'s car", function(on)
    if taxi_veh ~= 0 then
        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(taxi_veh, on)
    end
end)

menu.toggle(chauffeur_root, "Chauffeur: Open doors", {"chopen"}, "Opens/closes the doors of chauffeur\'s car", function(on)
    if taxi_veh ~= 0 then
        for i=0, 7 do
            if on then
                VEHICLE.SET_VEHICLE_DOOR_OPEN(taxi_veh, i, false, false)
            else
                VEHICLE.SET_VEHICLE_DOOR_SHUT(taxi_veh, i, false)
            end
        end
    end
end)

menu.action(chauffeur_root, "Chauffeur: Stop", {"chstop"}, "Tells the chauffeur to park the car and stop. You will need to tell them where to go again.", function(on_click)
    if taxi_veh ~= 0 then
        TASK.TASK_VEHICLE_TEMP_ACTION(taxi_ped, taxi_veh, 1, -1)
    end
end)

menu.action(chauffeur_root, "Chauffeur: Delete", {"chdelete"}, "Deletes the chauffeur and his car", function(on_click)
    if taxi_veh ~= 0 then
        entities.delete_by_handle(taxi_veh)
        taxi_veh = 0
    end
    if taxi_ped ~= 0 then
        entities.delete_by_handle(taxi_ped)
        taxi_ped = 0
    end
    HUD.REMOVE_BLIP(taxi_blip)
    taxi_blip = -1
end)

menu.action(chauffeur_root, "Chauffeur: Self destruct", {"chdestruct"}, "do i need to explain?", function(on_click)
    if taxi_veh ~= 0 then
        ENTITY.SET_ENTITY_INVINCIBLE(taxi_veh, false)
        ENTITY.SET_ENTITY_INVINCIBLE(taxi_ped, false)
        VEHICLE.EXPLODE_VEHICLE(taxi_veh, true, false)
        taxi_veh = 0
        taxi_ped = 0
        HUD.REMOVE_BLIP(taxi_blip)
        taxi_blip = -1
    end
end)


hud_rainbow = false
menu.toggle(gametweaks_root, "RGB hud", {"rgbhud"}, "RGB\'s your hud. This is AIDS, and requires a game restart to reset.", function(on)
    hud_rainbow = on
end)

ehud_hdg = false
menu.toggle(ehud_root, "Heading", {"ehudheading"}, "", function(on)
    ehud_hdg = on
end)


menu.action(gametweaks_root, "Force cutscene", {"forcecutscene"}, "Input a cutscene to force. Google \"GTA V cutscene names list\". Very fun shit.", function(on_click)
    util.toast("Please type the cutscene name")
    menu.show_command_box("forcecutscene ")
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
                util.toast("Cutscene failed to load in 10 seconds.")
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
--pro_mcs_1


lodscale = 1
menu.slider(gametweaks_root, "LOD Scale Override", {"lodscale"}, "Overrides extended distance scaling, lets you make distant objects \"look more HD\". This is an oversimplified explanation. May also make your game run like shit.", 1, 200, 1, 1, function(s)
    lodscale = s
  end)

menu.action(labelpresets_root, "Joining GTA Online with Lancescript", {}, "Usually says: \"Joining GTA online\"", function(on_click)
    do_label_preset("HUD_JOINING", "Joining GTA Online with Lancescript")
end)

menu.action(labelpresets_root, "Taking forever to load...", {}, "Usually says: \"Loading\"", function(on_click)
    do_label_preset("MP_SPINLOADING", "Taking forever to load...")
end)

menu.action(labelpresets_root, "AIDS online", {}, "Usually says: \"GTA online\"", function(on_click)
    do_label_preset("HUD_LBD_FMF", "AIDS Online (Invite, ~1~)")
    do_label_preset("HUD_LBD_FMP", "AIDS Online (Public, ~1~)")
    do_label_preset("HUD_LBD_FMS", "AIDS Online (Solo, ~1~)")
    do_label_preset("HUD_LBD_FMF", "AIDS Online (Friend, ~1~)")
    do_label_preset("PM_SCR_MIS", "AIDS Online")
    do_label_preset("PCARD_ONLINE_OTHER", "AIDS Online")
    do_label_preset("ONLINE_BUILD", "AIDS Online")
    do_label_preset("LOADING_MPLAYER", "AIDS Online")

end)

menu.action(labelpresets_root, "Player fucking died", {}, "Usually says: \"-playername- died.\"", function(on_click)
    do_label_preset("TICK_DIED", "~a~~HUD_COLOUR_WHITE~ fucking died.")
end)

menu.action(labelpresets_root, "Player dipped", {}, "Usually says: \"-playername- left.\"", function(on_click)
    do_label_preset("TICK_LEFT", "~a~~HUD_COLOUR_WHITE~ dipped.")
end)

menu.action(labelpresets_root, "you got caught kiddo", {}, "Usually says: \"You have been banned from Grand Theft Auto Online.\" Hopefully you never see this one.", function(on_click)
    do_label_preset("HUD_ROSBANNED", "you got caught kiddo")
    do_label_preset("HUD_ROSBANPERM", "you got caught kiddo")
end)

menu.toggle(radio_root, "Music-only radio", {"musiconly"}, "Forces radio stations to only play music. No bullshit.", function(on)
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

menu.action(radio_root, "Tracklist override - \"Sleepwalking\"", {"sleepwalking"}, "End music if you kill michael. Who the fuck would kill Michael?", function(on_click)
    local station = "RADIO_01_CLASS_ROCK"
    AUDIO.SET_RADIO_TO_STATION_NAME(station)
    AUDIO.SET_CUSTOM_RADIO_TRACK_LIST(station, "END_CREDITS_KILL_MICHAEL", true)
end)

menu.action(radio_root, "Tracklist override - \"Don\'t come close\"", {"dontcomeclose"}, "End music if you kill Trevor. Makes you feel like a piece of shit. I picked this option when I was young. I regret it.", function(on_click)
    local station = "RADIO_01_CLASS_ROCK"
    AUDIO.SET_RADIO_TO_STATION_NAME(station)
    AUDIO.SET_CUSTOM_RADIO_TRACK_LIST(station, "END_CREDITS_KILL_TREVOR", true)
end)

--SKIP_RADIO_FORWARD()

ban_msg = "HUD_ROSBANPERM"
--_SET_WARNING_MESSAGE_WITH_ALERT(char* labelTitle, char* labelMsg, int p2, int p3, char* labelMsg2, BOOL p5, int p6, int p7, char* p8, char* p9, BOOL background, int errorCode)

menu.action(fakemessages_root, "Fake ban message 1", {"fakeban"}, "Shows a completely fake ban message. Maybe use this to get free accounts from cheat devs or cause a scare on r/Gta5modding.", function(on_click)
    show_custom_alert_until_enter("You have been banned from Grand Theft Auto Online.~n~Return to Grand Theft Auto V.")
end)

menu.action(fakemessages_root, "Fake ban message 2", {"fakeban"}, "Shows a completely fake ban message. Maybe use this to get free accounts from cheat devs or cause a scare on r/Gta5modding.", function(on_click)
    show_custom_alert_until_enter("You have been banned from Grand Theft Auto Online permanently.~n~Return to Grand Theft Auto V.")
end)
--0x252F03F2

menu.action(fakemessages_root, "Services unavailable", {"fakeservicedown"}, "rOcKstaR GaMe ServICeS ArE UnAvAiLAbLe RiGht NoW", function(on_click)
    show_custom_alert_until_enter("The Rockstar game services are unavailable right now.~n~Please return to Grand Theft Auto V.")
end)

menu.action(fakemessages_root, "Suspended until xyz", {"suspendeduntil"}, "Suspended until xyz. It will ask you to input the date to show, don\'t worry.", function(on_click)
    util.toast("Input the date your \"suspension\" should end.")
    menu.show_command_box("suspendeduntil ")
end, function(on_command)
    -- fuck it lol
    show_custom_alert_until_enter("You have been suspended from Grand Theft Auto Online until " .. on_command .. ".~n~In addition, your Grand Theft Auto Online character(s) will be reset.~n~Return to Grand Theft Auto V.")
end)

menu.action(fakemessages_root, "Stand on TOP!", {"stand on top"}, "yep", function(on_click)
    show_custom_alert_until_enter("Stand on TOP!")
end)

menu.action(fakemessages_root, "Yeeyee ass haircut", {"yeeyee"}, "maybe", function(on_click)
    show_custom_alert_until_enter("Maybe if you got rid of that old ~r~yee yee ass haircut~w~ you'd get some bitches on your dick")
end)

menu.action(fakemessages_root, "Welcome to the Black Parade", {"blackparade"}, "", function(on_click)
    show_custom_alert_until_enter("When I was a young boy, my father~n~"..
    "Took me into the city to see a marching band~n~"..
    "He said, \"Son, when you grow up would you be~n~"..
    "The savior of the broken, the beaten and the damned?\"~n~"..
    "He said, \"Will you defeat them? Your demons~n~"..
    "And all the non-believers, the plans that they have made?~n~"..
    "Because one day, I\'ll leave you a phantom~n~"..
    "To lead you in the summer to join the black parade...\"~n~"..
    "~n~"..
    "When I was a young boy, my father~n~"..
    "Took me into the city to see a marching band~n~"..
    "He said, \"Son, when you grow up would you be~n~"..
    "The savior of the broken, the beaten and the damned?\"")
end)


menu.action(fakemessages_root, "Reddit", {"henlo"}, "they be like \"um ackshully u should buy 2take1\"", function(on_click)
    show_custom_alert_until_enter("Hello r/GTA5Modding!")
end)

menu.action(fakemessages_root, "Exit scam", {"exitscam"}, "you know the vibes", function(on_click)
    show_custom_alert_until_enter("Dear beloved Ozark Users, PLEASE READ THIS MESSAGE IN ITS ENTIRETY.~n~"..

    "It is with a heavy heart I have to write this message.~n~"..
    
    "I received correspondence today via a Law Firm in my local country from TakeTwo Interactive.~n~"..
    
    "Effective immediately, Ozark has shutdown and ceased all services."
)
end)

menu.action(fakemessages_root, "Custom alert", {"customalert"}, "Shows a custom alert of your liking. Credit to QuickNUT and Sainan for help with this.", function(on_click)
    util.toast("Please type what you want the alert to say. Type ~n~ for new line, ie foo~n~bar will show up as 2 lines.")
    menu.show_command_box("customalert ")
end, function(on_command)
    show_custom_alert_until_enter(on_command)
end)

make_peds_cops = false
menu.toggle(npc_root, "Make nearby peds cops", {"makecops"}, "They\'re not actually real cops, but kind of are. They seem to flee very easily, but will snitch on you. Sort of like mall cops.", function(on)
    if on then
        make_peds_cops = true
        mod_uses("ped", 1)
    else
        make_peds_cops = false
        mod_uses("ped", -1)
    end
end, false)

menu.toggle(npc_root, "Detroit", {"detroit"}, "All nearby NPC\'s duel it out and are given weapons. Surprisingly this is handled by the game itself.", function(on)
    MISC.SET_RIOT_MODE_ENABLED(on)
end, false)

menu.action(npc_root, "Make nearby peds musicians", {}, "now here\'s wonderwall", function(on_click)
    local peds = entities.get_all_peds_as_handles()
    for k,ped in pairs(peds) do
        if not is_ped_player(ped) then
            TASK.TASK_LEAVE_ANY_VEHICLE(ped, 0, 16)
            TASK.TASK_START_SCENARIO_IN_PLACE(ped, "WORLD_HUMAN_MUSICIAN", 0, true)
        end
    end
end)

roast_voicelines = false
menu.toggle(npc_root, "Roast voicelines", {"npcroasts"}, "Very unethical.", function(on)
    --make_all_peds_say("GENERIC_INSULT_MED", "SPEECH_PARAMS_FORCE_SHOUTED")
    if on then
        mod_uses("ped", 1)
        roast_voicelines = true
    else
        mod_uses("ped", -1)
        roast_voicelines = false
    end
end, false)

sex_voicelines = false
menu.toggle(npc_root, "Sex voicelines", {"sexlines"}, "oH FuCK YeAh", function(on)
    if on then
        mod_uses("ped", 1)
        sex_voicelines = true
    else
        mod_uses("ped", -1)
        sex_voicelines = false
    end
end, false)

gluck_voicelines = false
menu.toggle(npc_root, "Gluck gluck 9000 voicelines", {"gluckgluck9000"}, "I\'m begging you, touch some grass.", function(on)
    if on then
        mod_uses("ped", 1)
        gluck_voicelines = true
    else
        mod_uses("ped", -1)
        gluck_voicelines = false
    end
end, false)

screamall = false
menu.toggle(npc_root, "Scream", {"screamall"}, "Makes all nearby peds scream horrifically. Awesome.", function(on)
    if on then
        mod_uses("ped", 1)
        screamall = true
    else
        mod_uses("ped", -1)
        screamall = false
    end
end, false)

play_ped_ringtones = false
menu.toggle(npc_root, "Ring all peds phones", {"ringtones"}, "Turns all nearby ped ringtones on", function(on)
    if on then
        play_ped_ringtones = true
        mod_uses("ped", 1)
    else
        play_ped_ringtones = false
        mod_uses("ped", -1)
    end
end, false)

dumb_peds = false
menu.toggle(npc_root, "Make all peds dumb", {"dumbpeds"}, "Makes nearby peds dumb / marks them as \"not highly perceptive\" in the engine. Whatever that means tbh.", function(on)
    if on then
        dumb_peds = true
        mod_uses("ped", 1)
    else
        dumb_peds = false
        mod_uses("ped", -1)
    end
end, false)

safe_peds = false
menu.toggle(npc_root, "Give peds helmets", {"safepeds"}, "First-time drivers need safety.", function(on)
    if on then
        safe_peds = true
        mod_uses("ped", 1)
    else
        safe_peds = false
        mod_uses("ped", -1)
    end
end, false)

deaf_peds = false
menu.toggle(npc_root, "Make all peds deaf", {"deafpeds"}, "Makes nearby peds deaf. Probably only noticeable for stealth missions.", function(on)
    if on then
        deaf_peds = true
        mod_uses("ped", 1)
    else
        deaf_peds = false
        mod_uses("ped", -1)
    end
end, false)

kill_peds= false
menu.toggle(npc_root, "Kill peds", {"killpeds"}, "Stand already does this, but whatever. Ours is more dramatic I think.", function(on)
    if on then
        kill_peds = true
        mod_uses("ped", 1)
    else
        kill_peds = false
        mod_uses("ped", -1)
    end
end, false)

wantthesmoke = false
menu.toggle(npc_root, "I want the smoke", {"iwantthesmoke"}, "Tells all nearby peds you want the smoke. May break some things.", function(on)
    if on then
        wantthesmoke = true
        mod_uses("ped", 1)
    else
        wantthesmoke = false
        mod_uses("ped", -1)
    end
end, false)

karate = false
menu.toggle(npc_root, "Karate", {"karate"}, "Forces all peds to take several years of martial arts classes. They will kick your ass.", function(on)
    if on then
        karate = true
        mod_uses("ped", 1)
    else
        karate = false
        mod_uses("ped", -1)
    end
end, false)

php_bars = false
menu.toggle(npc_root, "HP bars", {"pedhpbars"}, "Draw health bars on NPC\'s.", function(on)
    if on then
        php_bars = true
        if vhp_bars then
            util.toast("WARNING: You have vehicle HP bars on at the same time as this! Some bars may not appear due to engine limits.")
        end
        mod_uses("ped", 1)
    else
        php_bars = false
        mod_uses("ped", -1)
    end
end, false)

pacifist = false
menu.toggle(npc_root, "Pacifist mode", {"pacifistmode"}, "Disables targetting of peds. Also makes them invincible. May break stuff.", function(on)
    if on then
        pacifist = true
        mod_uses("ped", 1)
    else
        pacifist = false
        mod_uses("ped", -1)
    end
end, false)


-- i think 25 is a fair value for default
ped_accuracy = 25
menu.slider(npc_root, "Ped weapon accuracy", {"pedaccuracy"}, "How good peds are at aiming. ", 0, 100, 50, 1, function(s)
    ped_accuracy = s
end)

ignore = false
menu.toggle(npc_root, "Oblivious peds", {"ignoreme"}, "Peds will not care about anything you do.", function(on)
    if on then
        ignore = true
        mod_uses("ped", 1)
    else
        ignore = false
        mod_uses("ped", -1)
    end
end, false)

rapture = false
menu.toggle(npc_root, "Rapture peds", {"rapturepeds"}, "Raptures the peds. Play \"Starlight\" by Jai Wolf while using for the best experience.", function(on)
    if on then
        rapture = true
        mod_uses("ped", 1)
    else
        rapture = false
        mod_uses("ped", -1)
    end
end, false)


allpeds_gun = 0
menu.click_slider(npc_root, "Gun to give to all peds", {"givepedswep"}, "0 = none\n1 = pistol\n2 = combat pdw\n3 = shotgun\n4 = Knife\n5 = minigun", 0, 5, 0, 1, function(s)
    if s == 0 then
        allpeds_gun = 0
    else
        allpeds_gun = good_guns[s]
    end
end)
menu.trigger_commands("givepedswep 0")

menu.action(npc_root, "Input weapon hash to give", {"apcustomwephash"}, "Input a custom weapon hash for peds to get. You must enter the hash for this one, not the string.", function(on_click)
    util.toast("Please input the weapon hash")
    menu.show_command_box("apcustomwephash ")
end, function(on_command)
    allpeds_gun = on_command
    util.toast("Weapon set to " .. on_command)
end)

function task_handler(type)
    -- whatever, just get it once this frame
    all_peds = entities.get_all_peds_as_handles()
    player_ped = PLAYER.PLAYER_PED_ID()
    for k,ped in pairs(all_peds) do
        if not is_ped_player(ped) then
            if type == "flop" then
                TASK.TASK_SKY_DIVE(ped)
            elseif type == "cover" then
                TASK.TASK_STAY_IN_COVER(ped)
            elseif type == "writheme" then
                TASK.TASK_WRITHE(ped, player_ped, -1, 0)
            elseif type == "vault" then
                TASK.TASK_CLIMB(ped, true)
            elseif type =="unused" then
                --
            elseif type == "cower" then
                TASK.TASK_COWER(ped, -1)
            end

        end
    end

end
menu.action(tasks_root, "Do the FLOP", {"flop"}, "All walking NPC\'s will do the flop. All driving NPC\'s will gently park their car, leave it, and do it then.", function(on_click)
    task_handler("flop")
end)

menu.action(tasks_root, "Move to cover", {"cover"}, "Pussy peds", function(on_click)
    task_handler("cover")
end)

menu.action(tasks_root, "Vault", {"vault"}, "They vault/skip over an invisible hurdle. Olympics. It also makes drivers vault out of their vehicle and fall through the world, because rockstar.", function(on_click)
    task_handler("vault")
end)

menu.action(tasks_root, "Cower", {"cower"}, "They cower for an eternity.", function(on_click)
    task_handler("cower")
end)


menu.action(tasks_root, "Writhe me", {"writheme"}, "Makes peds infinitely suffer on the ground. Finally a use for those dumbasses. The native makes drivers become invisible until they die for some reason.", function(on_click)
    task_handler("writheme")
end)

--start_healthbar_thread()

function get_closest_vehicle(entity)
    local coords = ENTITY.GET_ENTITY_COORDS(entity, true)
    local vehicles = entities.get_all_vehicles_as_handles()
    -- init this at some ridiculously large number we will never reach, ez
    local closestdist = 1000000
    local closestveh = 0
    for k, veh in pairs(vehicles) do
        if veh ~= PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false) then
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

-- BEGIN SPOONER CODE
spooner_mode = false
spooner_cam = 0
spoonspawn_offset = 1.0
spooner_objs = {}
spooner_vehicles = {}
spooner_peds = {}
highlight_ent = 0
ent_lists = {}
ent_types = {}
spooner_focused = false

-- credit to nowiry
function rotation_to_direction(rotation) 
    local adjusted_rotation = 
    { 
        x = (math.pi / 180) * rotation.x, 
        y = (math.pi / 180) * rotation.y, 
        z = (math.pi / 180) * rotation.z 
    }
    local direction = 
    {
        x = -math.sin(adjusted_rotation.z) * math.abs(math.cos(adjusted_rotation.x)), 
        y =  math.cos(adjusted_rotation.z) * math.abs(math.cos(adjusted_rotation.x)), 
        z =  math.sin(adjusted_rotation.x)
    }
    return direction
end

-- credits to nowiry
function get_offset_from_gameplay_camera(distance)
    local cam_rot = CAM.GET_GAMEPLAY_CAM_ROT(0)
    local cam_pos = CAM.GET_GAMEPLAY_CAM_COORD()
    local direction = rotation_to_direction(cam_rot)
    local destination = 
    { 
        x = cam_pos.x + direction.x * distance, 
        y = cam_pos.y + direction.y * distance, 
        z = cam_pos.z + direction.z * distance 
    }
    return destination
end

function get_offset_from_camera(distance, camera)
    local cam_rot = CAM.GET_CAM_ROT(camera, 0)
    local cam_pos = CAM.GET_CAM_COORD(camera)
    local direction = rotation_to_direction(cam_rot)
    local destination = 
    { 
        x = cam_pos.x + direction.x * distance, 
        y = cam_pos.y + direction.y * distance, 
        z = cam_pos.z + direction.z * distance 
    }
    return destination
end

function raycast_gameplay_cam(flag, distance)
    log("raycast gameplay cam, allocating")
    local ptr1, ptr2, ptr3, ptr4 = memory.alloc(), memory.alloc(), memory.alloc(), memory.alloc()
    local cam_rot = CAM.GET_GAMEPLAY_CAM_ROT(0)
    local cam_pos = CAM.GET_GAMEPLAY_CAM_COORD()
    local direction = rotation_to_direction(cam_rot)
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
    log("raycast_gameplay_cam free mem")
    memory.free(ptr1)
    memory.free(ptr2)
    memory.free(ptr3)
    memory.free(ptr4)
    return {p1, p2, p3, p4}
end


function raycast_cam(flag, distance, cam)
    log("raycast cam, allocating")
    local ptr1, ptr2, ptr3, ptr4 = memory.alloc(), memory.alloc(), memory.alloc(), memory.alloc()
    local cam_rot = CAM.GET_CAM_ROT(cam, 0)
    local cam_pos = CAM.GET_CAM_COORD(cam)
    local direction = rotation_to_direction(cam_rot)
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
    log("raycast_cam free mem")
    memory.free(ptr1)
    memory.free(ptr2)
    memory.free(ptr3)
    memory.free(ptr4)
    return {p1, p2, p3, p4}
end

function start_spooner_thread()
    spooner_thread = util.create_thread(function (thr)
        while true do
            if not spooner_mode then
                -- shit
            else
                -- make sure all ents in entity lists exist
                for e,l in pairs(ent_lists) do 
                    if not ENTITY.DOES_ENTITY_EXIST(e) then
                        delete_entity(e)
                    end
                end
                if PAD.IS_CONTROL_JUST_PRESSED(24, 24) then
                    local raycast_ent = raycast_cam(-1, 100.0, spooner_cam)[4]
                    local type = ENTITY.GET_ENTITY_TYPE(raycast_ent)
                    if raycast_ent ~= 0 then
                        if type >= 1 and type <= 3 then
                            util.toast("Entity selected!")
                        end
                        if type == 1 then
                            create_entity_listing(raycast_ent, "p")
                            menu.trigger_commands("lancescriptspooner" .. raycast_ent)
                        elseif type == 2 then
                            create_entity_listing(raycast_ent, "v")
                            menu.trigger_commands("lancescriptspooner" .. raycast_ent)
                        elseif type == 3 then
                            create_entity_listing(raycast_ent, "o")
                            menu.trigger_commands("lancescriptspooner" .. raycast_ent)
                        end
                    end
                end
                HUD.DISPLAY_SNIPER_SCOPE_THIS_FRAME()
                spooner_cam = CAM.GET_RENDERING_CAM()
            end
            if highlight_ent ~= 0 then
                local c = ENTITY.GET_ENTITY_COORDS(highlight_ent, true)
                c['z'] = c['z'] + get_model_size(ENTITY.GET_ENTITY_MODEL(highlight_ent))['z']
                GRAPHICS.DRAW_MARKER(0, c['x'], c['y'], c['z'], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 2.0, 255, 0, 255, 200, true, true, 0, true, 0, 0, false)
            end
            util.yield()
        end
    end)
end

start_spooner_thread()
function get_spoonercam_coords()
    if spooner_mode then
        return CAM.GET_CAM_COORD(spooner_cam)
    else
        return CAM.GET_GAMEPLAY_CAM_COORD()
    end
end

function delete_entity(ent)
    local type = ent_types[ent]
    if type == "o" then
        spooner_objs[ent] = nil
    elseif type == "v" then
        spooner_vehicles[ent] = nil
    elseif type == "p" then
        spooner_peds[ent] = nil
    end
    menu.delete(ent_lists[ent])
    ent_lists[ent] = nil
	entities.delete_by_handle(ent)
end

function create_entity_listing(ent, type)
    if not hasValue(spooner_vehicles, ent) and not hasValue(spooner_objs, ent) and not hasValue(spooner_peds, ent) then
        if type == "v" then
            table.insert(spooner_vehicles, ent)
            ent_types[ent] = "v"
            local name = string.lower(VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(ENTITY.GET_ENTITY_MODEL(ent))):gsub("^%l", string.upper) .. " (" .. ent .. ")"
            spoonlstng = menu.list(spawnedvehs_root, name, {"lancescriptspooner"..ent}, "")
        elseif type == "o" then
            table.insert(spooner_objs, ent)
            ent_types[ent] = "o"
            spoonlstng = menu.list(spawnedobjs_root, ent, {"lancescriptspooner"..ent}, "")
        elseif type == "p" then
            table.insert(spooner_peds, ent)
            ent_types[ent] = "p"
            spoonlstng = menu.list(spawnedpeds_root, ent, {"lancescriptspooner"..ent}, "")
        end
        ent_lists[ent] = spoonlstng
        menu.on_focus(spoonlstng, function()
            spooner_focused = true
            highlight_ent = ent
            --if not ENTITY.DOES_ENTITY_EXIST(ent) then
            --    util.toast("Entity no longer exists.")
            --    delete_entity(ent)
            --end
            local c = ENTITY.GET_ENTITY_COORDS(ent, true)
            local d = ENTITY.GET_ENTITY_ROTATION(ent, 3)
            c['x'] = math.floor(c['x'])
            c['y'] = math.floor(c['y'])
            c['z'] = math.floor(c['z'])
            d['x'] = math.floor(d['x'])
            d['y'] = math.floor(d['y'])
            d['z'] = math.floor(d['z'])
            menu.trigger_commands("spoonerposx" .. ent .. " " .. c['x'])
            menu.trigger_commands("spoonerposy" .. ent .. " " .. c['y'])
            menu.trigger_commands("spoonerposz" .. ent .. " " .. c['z'])
            menu.trigger_commands("spoonerpitch" .. ent .. " " .. d['x'])
            menu.trigger_commands("spooneryaw" .. ent .. " " .. d['y'])
            menu.trigger_commands("spoonerroll" .. ent .. " " .. d['z'])
        end)
        menu.on_blur(spoonlstng, function()
            if highlight_ent == ent then
                highlight_ent = 0
            end
            spooner_focused = false
        end)
        menu.action(spoonlstng, "Delete", {"delete" .. ent}, "Delete this entity", function(on_click)
            delete_entity(ent)
        end)
        menu.action(spoonlstng, "Kill", {"kill" .. ent}, "Sets the entity\'s health to 0", function(on_click)
            if type == "v" then
                VEHICLE.SET_VEHICLE_ENGINE_HEALTH(ent, 0.0)
            else
                ENTITY.SET_ENTITY_HEALTH(ent, 0.0)
            end
        end)
        menu.action(spoonlstng, "Heal", {"heal" .. ent}, "Sets the entity\'s health to max. Doesn\'t work on already-dead peds", function(on_click)
            if type == "v" then
                VEHICLE.SET_VEHICLE_ENGINE_HEALTH(ent, 1000.0)
            else
                ENTITY.SET_ENTITY_HEALTH(ent, ENTITY.GET_ENTITY_MAX_HEALTH(ent))
            end
        end)

        menu.action(spoonlstng, "Explode", {"explode" .. ent}, "Blows up the entity. Come on, didn\'t you guess?", function(on_click)
            local coords = ENTITY.GET_ENTITY_COORDS(ent, true)
            FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], 7, 100.0, true, false, 1.0)
        end)
        menu.action(spoonlstng, "Teleport to me", {"bringtocam" .. ent}, "Teleports the entity to you/your camera position", function(on_click)
            local c = get_spoonercam_coords()
            menu.trigger_commands("spoonerposx" .. ent .. " " .. c['x'])
            menu.trigger_commands("spoonerposy" .. ent .. " " .. c['y'])
            menu.trigger_commands("spoonerposz" .. ent .. " " .. c['z'])
            --ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ent, c['x'], c['y'], c['z'], false, false, false)
        end)

        menu.action(spoonlstng, "Teleport to", {"bringtocam" .. ent}, "Teleports you to the entity", function(on_click)
            local c = ENTITY.GET_ENTITY_COORDS(ent, true)
            if spooner_mode then
                menu.trigger_commands("freecam off")
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(PLAYER.PLAYER_PED_ID(), c['x'], c['y'], c['z'], false, false, false)
                util.yield(100)
                menu.trigger_commands("freecam on")
            else
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(PLAYER.PLAYER_PED_ID(), c['x'], c['y'], c['z'], false, false, false)
            end
        end)

        menu.toggle(spoonlstng, "Freeze entity", {"freeze"..ent}, "Freeze this entity", function(on)
            ENTITY.FREEZE_ENTITY_POSITION(ent, on)
        end)

        menu.toggle(spoonlstng, "Godmode entity", {"god"..ent}, "Godmode this entity", function(on)
            ENTITY.SET_ENTITY_INVINCIBLE(ent, on)
        end)

        local c = ENTITY.GET_ENTITY_COORDS(ent, true)
        local d = ENTITY.GET_ENTITY_ROTATION(ent, 3)
        c['x'] = math.floor(c['x'])
        c['y'] = math.floor(c['y'])
        c['z'] = math.floor(c['z'])
        d['x'] = math.floor(d['x'])
        d['y'] = math.floor(d['y'])
        d['z'] = math.floor(d['z'])

        menu.slider(spoonlstng, "Pos X", {"spoonerposx"..ent}, "", -10000, 10000, c['x'], 1, function(s)
            local c = ENTITY.GET_ENTITY_COORDS(ent, true)
            if not spooner_focused then
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ent, s, c['y'], c['z'], false, false, false)
            end
        end)

        menu.slider(spoonlstng, "Pos Y", {"spoonerposy"..ent}, "", -10000, 10000, c['y'], 1, function(s)
            local c = ENTITY.GET_ENTITY_COORDS(ent, true)
            if not spooner_focused then
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ent, c['x'], s, c['z'], false, false, false)
            end
        end)

        menu.slider(spoonlstng, "Pos Z", {"spoonerposz"..ent}, "", -10000, 10000, c['z'], 1, function(s)
            local c = ENTITY.GET_ENTITY_COORDS(ent, true)
            if not spooner_focused then
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ent, c['x'], c['y'], s, false, false, false)
            end
        end)

        menu.slider(spoonlstng, "Pitch", {"spoonerpitch"..ent}, "", 0, 359, d['x'], 1, function(s)
            local c = ENTITY.GET_ENTITY_ROTATION(ent, 3)
            if not spooner_focused then
                ENTITY.SET_ENTITY_ROTATION(ent, s, c['y'], c['z'], 3, true)
            end
        end)

        menu.slider(spoonlstng, "Yaw", {"spooneryaw"..ent}, "", 0, 359, d['y'], 1, function(s)
            local c = ENTITY.GET_ENTITY_ROTATION(ent, 3)
            if not spooner_focused then
                ENTITY.SET_ENTITY_ROTATION(ent, c['x'], c['y'], s, 3, true)  
            end
        end)

        menu.slider(spoonlstng, "Roll", {"spoonerroll"..ent}, "", 0, 359, d['z'], 1, function(s)
            local c = ENTITY.GET_ENTITY_ROTATION(ent, 3)
            if not spooner_focused then
                ENTITY.SET_ENTITY_ROTATION(ent, c['x'], s, c['y'], 3, true)
            end
        end)
    end
    
end

menu.toggle(spooner_root, "Spooner mode", {"spoonermode"}, "Enter a freecam that lets you select entities by clicking them and spawn entities anywhere", function(on)
    if on then
        util.toast("Welcome to spooner mode! Get close to an entity and click it to select it and add it to the database :)")
        menu.trigger_commands("freecam on")
        spooner_mode = true
    else
        spooner_mode = false
        menu.trigger_commands("freecam off")
    end
end)

menu.slider(spooner_root, "Spawn offset", {"spoonerspawnoffset"}, "How far away to spawn objects from you/spooner camera.", 0, 100, 1, 1, function(s)
    spoonspawn_offset = s
end)

menu.action(spooner_root, "Teleport my player to cam", {"tptospooner"}, "Teleports you to the camera", function(on_click)
    local c = get_spoonercam_coords()
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(PLAYER.PLAYER_PED_ID(), c['x'], c['y'], c['z'], false, false, false)
end)

function spooner_create_obj(hash)
    request_model_load(hash)
    if spooner_mode then
        scamcoord = get_offset_from_camera(spoonspawn_offset, spooner_cam)
    else
        scamcoord = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, spoonspawn_offset, 0.0)
    end
    local c = scamcoord
    c.x = c['x']
    c.y = c['y']
    c.z = c['z']
    local obj = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, c['x'], c['y'], c['z'], true, false, false)
    if obj ~= 0 then
        create_entity_listing(obj, "o")
    end
end

function spooner_create_vehicle(hash)
    request_model_load(hash)
    if spooner_mode then
        scamcoord = get_offset_from_camera(spoonspawn_offset, spooner_cam)
        scamhdg = CAM.GET_CAM_ROT(spooner_cam, 0)['y']
    else
        scamcoord = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, spoonspawn_offset, 0.0)
        scamhdg = CAM.GET_GAMEPLAY_CAM_ROT()['y']
    end
    local c = scamcoord
    c.x = c['x']
    c.y = c['y']
    c.z = c['z']
    local veh = entities.create_vehicle(hash, c, scamhdg)
    if obj ~= 0 then
        create_entity_listing(veh, "v")
    end
end

function spooner_create_ped(hash)
    request_model_load(hash)
    if spooner_mode then
        scamcoord = get_offset_from_camera(spoonspawn_offset, spooner_cam)
        scamhdg = CAM.GET_CAM_ROT(spooner_cam, 0)['y']
    else
        scamcoord = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, spoonspawn_offset, 0.0)
        scamhdg = CAM.GET_GAMEPLAY_CAM_ROT()['y']
    end
    local c = scamcoord
    c.x = c['x']
    c.y = c['y']
    c.z = c['z']
    local ped = entities.create_ped(1, hash, c, scamhdg)
    if obj ~= 0 then
        create_entity_listing(ped, "p")
    end
end

spoonerobj_root = menu.list(spooner_root, "Objects", {"lancescriptspoonerobjs"}, "Spawn, move, and modify entities!")
spawnedobjs_root = menu.list(spoonerobj_root, "Spawned objects", {"lancescriptspoonerspawnedobjs"}, "Spawn, move, and modify spawned objects!")
spoonerveh_root = menu.list(spooner_root, "Vehicles", {"lancescriptspoonerobjs"}, "Spawn, move, and modify vehicles!")
spawnedvehs_root = menu.list(spoonerveh_root, "Spawned vehicles", {"lancescriptspoonerspawnedvehs"}, "Spawn, move, and modify spawned vehicles!")
spoonerped_root = menu.list(spooner_root, "Ped", {"lancescriptspoonerobjs"}, "Spawn, move, and modify vehicles!")
spawnedpeds_root = menu.list(spoonerped_root, "Spawned peds", {"lancescriptspoonerspawnedvehs"}, "Spawn, move, and modify spawned peds!")

menu.action(spoonerobj_root, "Input object model name", {"customspoonerobj"}, "Input a custom model to spawn. The model string, NOT the hash.", function(on_click)
    util.toast("Please input the model string")
    menu.show_command_box("customspoonerobj ")
end, function(on_command)
    local hash = util.joaat(on_command)
    spooner_create_obj(hash)
end)

spoonerautoobjs = false
menu.toggle(spoonerobj_root, "Auto-add objects", {"spoonerautoobjs"}, "Automatically adds objects to the spooner list when they are discovered. VERYNOT recommended, VERY performance heavy.", function(on)
    if on then
        mod_uses("object", 1)
        spoonerautoobjs = true
    else
        mod_uses("object", -1)
        spoonerautoobjs = false
    end
end)


menu.action(spoonerveh_root, "Input vehicle model name", {"customspoonerveh"}, "Input a custom vehicle to spawn. The model string, NOT the hash.", function(on_click)
    util.toast("Please input the model string")
    menu.show_command_box("customspoonerveh ")
end, function(on_command)
    local hash = util.joaat(on_command)
    spooner_create_vehicle(hash)
end)

spoonerautovehs = false
menu.toggle(spoonerveh_root, "Auto-add vehicles", {"spoonerautovehs"}, "Automatically adds vehicles to the spooner list when they are discovered. NOT recommended, very performance heavy.", function(on)
    if on then
        mod_uses("vehicle", 1)
        spoonerautovehs = true
    else
        mod_uses("vehicle", -1)
        spoonerautovehs = false
    end
end)

menu.action(spoonerped_root, "Input ped model name", {"customspoonerped"}, "Input a custom ped to spawn. The model string, NOT the hash.", function(on_click)
    util.toast("Please input the model string")
    menu.show_command_box("customspoonerped ")
end, function(on_command)
    local hash = util.joaat(on_command)
    spooner_create_ped(hash)
end)

spoonerautopeds = false
menu.toggle(spoonerped_root, "Auto-add peds", {"spoonerautopeds"}, "Automatically adds peds to the spooner list when they are discovered. NOT recommended, VERY performance heavy and may freeze your game.", function(on)
    if on then
        mod_uses("ped", 1)
        spoonerautopeds = true
    else
        mod_uses("ped", -1)
        spoonerautopeds = false
    end
end)

-- END SPOONER CODE
menu.action(vehicles_root, "Teleport into closest vehicle", {"closestvehicle"}, "Teleports into closest vehicle (excludes any you might be in already). If the closest vehicle has a player driver, it will put you in the next available seat, if any. Keep in mind that nearby vehicles may not actually be \"real\" vehicles and may just be LOD\'s.", function(on_click)
    local closestveh = get_closest_vehicle(PLAYER.PLAYER_PED_ID())
    local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(closestveh, -1)
    if VEHICLE.IS_VEHICLE_SEAT_FREE(closestveh, -1) then
        PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), closestveh, -1)
    else
        if not is_ped_player(driver) then
            entities.delete_by_handle(driver)
            PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), closestveh, -1)
        elseif VEHICLE.ARE_ANY_VEHICLE_SEATS_FREE(closestveh) then
            for i=0, 10 do
                if VEHICLE.IS_VEHICLE_SEAT_FREE(closestveh, i) then
                    PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), closestveh, i)
                end
            end
        else
            util.toast("No nearby vehicles with available seats found :(")
        end
    end
end)

blackhole = false
menu.toggle(vehicles_root, "Vehicle blackhole", {"blackhole"}, "A SUPER laggy but fun blackhole. When you toggle it on, it will set the blackhole position above you. Retoggle it to change the position. Oh also, this is very resource taxing and may temporarily fuck up collisions.", function(on)
    if on then
        holecoords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
        util.toast("Blackhole position has been set 50 units above your position. Retoggle this on and off to change the position.")
        blackhole = true
        mod_uses("vehicle", 1)
    else
        blackhole = false
        mod_uses("vehicle", -1)
    end
end, false)

hole_zoff = 50
menu.slider(vehicles_root, "Blackhole Z-offset", {"blackholeoffset"}, "How far above you to place the blackhole. Recommended to keep this fairly high.", 0, 100, 50, 10, function(s)
    hole_zoff = s
  end)

vehicle_fuckup = false
menu.toggle(vehicles_root, "Fuck up all cars", {"fuckupcars"}, "Beats the SHIT out of all nearby cars. But this damage is only local.", function(on)
    if on then
        vehicle_fuckup = true
        mod_uses("vehicle", 1)
    else
        vehicle_fuckup = false
        mod_uses("vehicle", -1)
    end
end, false)

inferno = false
menu.toggle(vehicles_root, "Inferno", {"inferno"}, "An overdramatic \"blow up all cars\" option. Will continue to blow up all cars even when they\'re dead, just so you get that classic modder feel.", function(on)
    if on then
        inferno = true
        mod_uses("vehicle", 1)
    else
        inferno = false
        mod_uses("vehicle", -1)
    end
end, false)


godmode_vehicles = false
menu.toggle(vehicles_root, "Godmode all vehicles nearby", {"godmodecars"}, "Makes all cars nearby undamageable. Built for NPC cars, so don\'t whine when Mr. ||||||||||| sticky bombs your itali.", function(on)
    if on then
        godmode_vehicles = true
        mod_uses("vehicle", 1)
    else
        godmode_vehicles = false
        mod_uses("vehicle", -1)
    end
end)

disable_veh_colls = false
menu.toggle(vehicles_root, "Hole all nearby cars", {"nocolcars"}, "Makes all nearby cars fall through the world, or \"into a hole\".", function(on)
    if on then
        disable_veh_colls = true
        mod_uses("vehicle", 1)
    else
        disable_veh_colls = false
        mod_uses("vehicle", -1)
    end
end)

custom_r = 254
menu.slider(colorizev_root, "Custom R", {"colorizecustomr"}, "", 1, 255, 254, 1, function(s)
    custom_r = s
end)

custom_g = 2
menu.slider(colorizev_root, "Custom G", {"colorizecustomg"}, "", 1, 255, 2, 1, function(s)
    custom_g = s
end)

custom_b = 252
menu.slider(colorizev_root, "Custom B", {"colorizecustomb"}, "", 1, 255, 252, 1, function(s)
    custom_b = s
end)

menu.action(colorizev_root, "RGB preset: Stand magenta", {"rpstandmagenta"}, "g", function(on_click)
    menu.trigger_commands("colorizecustomr 254")
    menu.trigger_commands("colorizecustomg 2")
    menu.trigger_commands("colorizecustomb 252")
end)

--colorize_cars = false
--custom_rgb = false
--
menu.toggle(colorizev_root, "Colorize vehicles", {"colorizevehicles"}, "Colorizes all nearby vehicles with the valus you set! Turn on rainbow to RGB this ;", function(on)
    if on then
        colorize_cars = true
        custom_rgb = true
        mod_uses("vehicle", 1)
    else
        colorize_cars = false
        custom_rgb = false
        mod_uses("vehicle", -1)
    end
end, false)

menu.toggle(colorizev_root, "Rainbow", {"rainbowvehicles"}, "Requires colorize vehicles to be turned on.", function(on)
    if not colorize_cars then
        menu.trigger_commands("colorizevehicles on")
    end
    custom_rgb = not on
end, false)

beep_cars = false
menu.toggle(vehicles_root, "Infinite horn on all nearby vehicles", {"beepvehicles"}, "Makes all nearby vehicles beep infinitely. May not be networked.", function(on)
    if on then
        beep_cars = true
        mod_uses("vehicle", 1)
    else
        beep_cars = false
        mod_uses("vehicle", -1)
    end
end, false)

veh_dance = false
menu.toggle(vehicles_root, "Earthquake mode/vehicle dance", {"vehicledance"}, "Makes all vehicles dance. Or earthquake. Whichever it looks like to you. ChairX.", function(on)
    if on then
        veh_dance = true
        mod_uses("vehicle", 1)
        start_vehdance_thread()
    else
        veh_dance = false
        mod_uses("vehicle", -1)
    end
end, false)

vhp_bars = false
menu.toggle(vehicles_root, "Vehicle HP bars", {"vehhpbars"}, "Draw health bars on vehicles.", function(on)
    if on then
        vhp_bars = true
        if php_bars then
            util.toast("WARNING: You have NPC HP bars on at the same time as this! Some bars may not appear due to engine limits.")
        end
        mod_uses("vehicle", 1)
    else
        vhp_bars = false
        mod_uses("vehicle", -1)
    end
end, false)

clear_radius = 100
function clear_area(radius)
    target_pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
    MISC.CLEAR_AREA(target_pos['x'], target_pos['y'], target_pos['z'], radius, true, false, false, false)
end

function get_closest_train()
    local vehicles = entities.get_all_vehicles_as_handles()
    for k, veh in pairs(vehicles) do
        if ENTITY.GET_ENTITY_MODEL(veh) == 1030400667 then
            request_control_of_entity(veh)
            return veh
        end
    end
    util.toast("Could not find the closest train.")
    return 0
end

menu.action(train_root, "Hijack closest train", {"hijacktrain"}, "", function(on_click)
    train = get_closest_train()
    if train ~= 0 then
        entities.delete_by_handle(VEHICLE.GET_PED_IN_VEHICLE_SEAT(train, -1))
        PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), train, -1)
        AUDIO.SET_VEHICLE_RADIO_ENABLED(train, true)
        util.toast("Success! Leave the train by using vehicle > force leave vehicle.")
    end
end)

menu.slider(train_root, "Closest train speed", {"trainspeed"}, "Setting it too high may make your game nope out of here", -1000, 1000, 20, 1, function(s)
    train_speed = s
end)

local density_avrm = 0.1
local density_vparked = 0.1
local density_vrandom = 0.1
local density_vregular = 0.1
local density_ped = 0.1

menu.slider(density_root, "Ambient vehicle range multiplier (*0.1)", {"avrm"}, "", 0, 10, 1, 1, function(s)
    density_avrm = s*0.1
end)

menu.slider(density_root, "Parked vehicle density multiplier (*0.1)", {"vparked"}, "", 0, 10, 1, 1, function(s)
  density_vparked = s*0.1
end)

menu.slider(density_root, "Random vehicle density multiplier (*0.1)", {"vparked"}, "", 0, 10, 1, 1, function(s)
    density_vrandom = s*0.1
end)

menu.slider(density_root, "Vehicle density multiplier (*0.1)", {"vregular"}, "", 0, 10, 1, 1, function(s)
    density_vregular = s*0.1
end)

menu.slider(density_root, "Ped density multiplier (*0.1)", {"vregular"}, "", 0, 10, 1, 1, function(s)
    density_ped = s*0.1
end)

menu.slider(budget_root, "Vehicle population budget", {"vpopbdget"}, "", 0, 10, 1, 1, function(s)
    STREAMING.SET_VEHICLE_POPULATION_BUDGET(s)
end)

menu.slider(budget_root, "Ped population budget", {"vpopbdget"}, "", 0, 10, 1, 1, function(s)
    STREAMING.SET_PED_POPULATION_BUDGET(s)
end)

menu.toggle(budget_root, "Reduce vehicle model budget", {"vreducebudget"}, "", function(on)
    STREAMING.SET_REDUCE_VEHICLE_MODEL_BUDGET(on)
end, false)

menu.toggle(budget_root, "Reduce ped model budget", {"vreducebudget"}, "", function(on)
    STREAMING.SET_REDUCE_PED_MODEL_BUDGET(on)
end, false)


menu.action(world_root, "Clear area", {"cleararea"}, "Clears the nearby area of everything", function(on_click)
    clear_area(clear_radius)
    util.toast('Area cleared :)')
end)

-- SET_PED_SHOOTS_AT_COORD(Ped ped, float x, float y, float z, BOOL toggle)

menu.action(world_root, "Clear world", {"clearworld"}, "Clears literally everything that can be cleared within the world (well, everything that\'s rendered in). Don\'t tell them, but it\'s really just a huge number as radius.", function(on_click)
    clear_area(1000000)
    util.toast('World cleared :)')
end)

local cont_clear = false
menu.toggle(world_root, "Continuous area clear", {"contareaclear"}, "Area clear, but looped", function(on)
    cont_clear = on
end, false)

menu.action(world_root, "Super cleanse", {"supercleanse"}, "Uses stand API to delete EVERY entity it finds (including player vehicles!).", function(on_click)
    local ct = 0
    for k,ent in pairs(entities.get_all_vehicles_as_handles()) do
        entities.delete_by_handle(ent)
        ct = ct + 1
    end
    for k,ent in pairs(entities.get_all_peds_as_handles()) do
        if not is_ped_player(ent) then
            entities.delete_by_handle(ent)
        end
        ct = ct + 1
    end
    for k,ent in pairs(entities.get_all_objects_as_handles()) do
        entities.delete_by_handle(ent)
        ct = ct + 1
    end
    util.toast("Super cleanse is complete! " .. ct .. " entities removed.")
end)


rapidtraffic = false
menu.toggle(world_root, "Party traffic lights", {"beep boop"}, "ITS TIME TO PARTY!!!!!! probably local, also it doesnt affect traffic behavior", function(on)
    if on then
        rapidtraffic = true
        mod_uses("object", 1)
    else
        rapidtraffic = false
        mod_uses("object", -1)
    end
end, false)

object_rainbow = false
menu.toggle(world_root, "Rainbow world lights", {"rainbowlights"}, "Rainbows all embedded light sources. EXTREME FPS KILLER, so use wisely.", function(on)
    if on then
        object_rainbow = true
        mod_uses("object", 1)
    else
        object_rainbow = false
        mod_uses("object", -1)
    end
end)


menu.slider(world_root, "Clear radius", {"clearradius"}, "Radius to clear things within", 100, 10000, 100, 100, function(s)
    radius = s
  end)

menu.slider(world_root, "World gravity level", {"worldgravity"}, "World gravity level (0 is normal, higher number = less gravity)", 0, 3, 1, 1, function(s)
  MISC.SET_GRAVITY_LEVEL(s)
end)

firework_spam = false
menu.toggle(world_root, "Firework spam", {"fireworkspam"}, "airplanes in the night sky are like shooting stars", function(on)
    firework_spam = on
end, false)
--FORCE_LIGHTNING_FLASH()
lightning_spam = false
menu.toggle(world_root, "Lightning spam", {"lightningspam"}, "epileptic-hating zeus. not sure if its networked or not, probably not.", function(on)
    lightning_spam = on
end, false)

function getOffsetFromEntityGivenDistance(entity, distance)
	local pos = ENTITY.GET_ENTITY_COORDS(entity, 0)
	local theta = (math.random() + math.random(0, 1)) * math.pi --returns a random angle between 0 and 2pi (exclusive)
	local coords = vect.new(
		pos.x + distance * math.cos(theta),
		pos.y + distance * math.sin(theta),
		pos.z
	)
	return coords
end


function start_meteor_shower()
    meteor_thr = util.create_thread(function(thr)
        while true do
            if not meteors then
                util.stop_thread()
            end
            local rand_1 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), math.random(-500, 500), math.random(-500, 500), 300.0)
            local rand_2 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), math.random(-500, 500), math.random(-500, 500), 0.0)
            local diff = {}
            local speed = 200
            diff.x = (rand_2['x'] - rand_1['x'])*speed
            diff.y = (rand_2['y'] - rand_1['y'])*speed
            diff.z = (rand_2['z'] - rand_1['z'])*speed
            local h = 3751297495
            request_model_load(h)
            rand_1.x = rand_1['x']
            rand_1.y = rand_1['y']
            rand_1.z = rand_1['z']
            local meteor = OBJECT.CREATE_OBJECT_NO_OFFSET(h, rand_1['x'], rand_1['y'], rand_1['z'], true, false, false)
            ENTITY.SET_ENTITY_HAS_GRAVITY(meteor, true)
            --ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(meteor, 4, diff.x, diff.y, diff.z, true, false, true, true)
            ENTITY.APPLY_FORCE_TO_ENTITY(meteor, 2, diff.x, diff.y, diff.z, 0, 0, 0, 0, true, false, true, false, true)
            OBJECT.SET_OBJECT_PHYSICS_PARAMS(meteor, 100000, 5, 1, 0, 0, .5, 0, 0, 0, 0, 0)
            util.yield(10000)
        end
    end)
end

local angryplanes_tar = PLAYER.PLAYER_PED_ID()
function plane_vel_thread(ent, pilot, tar)
    plane_vel_thr = util.create_thread(function(thr)
        local start_time = os.time()
        while true do
            if os.time() - start_time >= 10 then
                entities.delete_by_handle(ent)
                util.stop_thread()
            end
            if not ent or ent == 0 or not ENTITY.DOES_ENTITY_EXIST(ent) or ENTITY.IS_ENTITY_DEAD(ent) then
                util.stop_thread()
            else
                local c = ENTITY.GET_ENTITY_COORDS(ent, true)
                --TASK.TASK_PLANE_LAND(pilot, ent, c['x'], c['y'], c['z'], c['x'], c['y'], c['z'])
            end
            util.yield()
        end
    end)
end

function pairsByKeys(t, f)
	local a = {}
	for n in pairs(t) do table.insert(a, n) end
	table.sort(a, f)
	local i = 0
	local iter = function()
		i = i + 1
		if a[i] == nil then return nil
		else return a[i], t[a[i]]
		end
	end
	return iter
end

function start_angryplanes()
    angryplanes_thr = util.create_thread(function(thr)
        while true do
            if not angryplanes then
                util.stop_thread()
            end
            local rand = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), math.random(-500, 500), math.random(-500, 500), 300.0)
            hashes = {util.joaat("jet"), util.joaat("velum"), util.joaat("titan"), util.joaat("cargoplane"), util.joaat("luxor")}
            hash = hashes[math.random(1, #hashes)]
            phash = util.joaat("s_m_m_pilot_01")
            request_model_load(hash)
            request_model_load(phash)
            local aircraft = entities.create_vehicle(hash, rand, math.random(0, 359))
            VEHICLE.SET_VEHICLE_FORWARD_SPEED(aircraft, VEHICLE.GET_VEHICLE_ESTIMATED_MAX_SPEED(aircraft))
            VEHICLE.CONTROL_LANDING_GEAR(aircraft, 3)
            VEHICLE.SET_VEHICLE_ENGINE_ON(aircraft, true, true, false)
            VEHICLE.SET_HELI_BLADES_FULL_SPEED(aircraft)
            local pilot = entities.create_ped(1, phash, rand, 0.0)
            PED.SET_PED_INTO_VEHICLE(pilot, aircraft, -1)
            PED.SET_PED_COMBAT_ATTRIBUTES(pilot, 5, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(pilot, 46, true)
            PED.SET_PED_AS_ENEMY(pilot, true)
            PED.SET_PED_FLEE_ATTRIBUTES(pilot, 0, false)
            local c = ENTITY.GET_ENTITY_COORDS(angryplanes_tar, true)
            TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(pilot, aircraft, c['x'], c['y'], c['z'], 100.0, 786996, 0.0)
            --TASK.TASK_PLANE_MISSION(pilot, aircraft, 0, angryplanes_tar, 0, 0, 0, 17, 0.0, 0, 0.0, 50.0, 0.0)
            plane_vel_thread(aircraft, pilot, angryplanes_tar)
            util.yield(10000)
        end
    end)
end


meteors = false
menu.toggle(world_root, "Asteroid shower", {"asteroids"}, "sends asteroids from space and smashes them into the ground near you. 1 new asteroid is spawned every 10s.", function(on)
    -- accidentally named this meteors internally, too lazy 2 fix. dont judge boy
    if on then
        meteors = true
        start_meteor_shower()
    else
        meteors = false
    end
end, false)


effects_root = menu.list(world_root, "Screen effects", {"lancescriptfx"}, "")

menu.toggle(effects_root, "DMT", {"dmt"}, "", function(on)
    if on then
        GRAPHICS.ANIMPOSTFX_PLAY("DMT_flight", 0, true)
    else
        GRAPHICS.ANIMPOSTFX_STOP("DMT_flight")
    end
end, false)

menu.toggle(effects_root, "Clowns", {"clowns"}, "", function(on)
    if on then
        GRAPHICS.ANIMPOSTFX_PLAY("DrugsTrevorClownsFight", 0, true)
    else
        GRAPHICS.ANIMPOSTFX_STOP("DrugsTrevorClownsFight")
    end
end, false)

menu.toggle(effects_root, "Dog vision", {"dogvision"}, "", function(on)
    if on then
        GRAPHICS.ANIMPOSTFX_PLAY("ChopVision", 0, true)
    else
        GRAPHICS.ANIMPOSTFX_STOP("ChopVision")
    end
end, false)

menu.toggle(effects_root, "Rampage", {"rampage"}, "", function(on)
    if on then
        GRAPHICS.ANIMPOSTFX_PLAY("Rampage", 0, true)
    else
        GRAPHICS.ANIMPOSTFX_STOP("Rampage")
    end
end, false)

menu.action(effects_root, "Input custom effect", {"effectinput"}, "Input a custom animpostFX to play. Google lists of these if you want to see them.", function(on_click)
    util.toast("Please type the effect name")
    menu.show_command_box("effectinput ")
end, function(on_command)
    GRAPHICS.ANIMPOSTFX_PLAY(on_command, 0, true)
end)

menu.action(effects_root, "Stop all effects", {"stopfx"}, "Use only as emergency, to stop custom inputted effects, or to stop regularly-triggered effects. If you can, try untoggling the effect first here.", function(on_click)
    GRAPHICS.ANIMPOSTFX_STOP_ALL()
end)

ascend_vehicles = false
menu.toggle(vehicles_root, "Ascend all nearby vehicles", {"ascendvehicles"}, "It\'s supposed to neatly make them levitate.. but it just spends them spinning in mid air. Which is fucking hilarious.", function(on)
    if on then
        ascend_vehicles = true
        mod_uses("vehicle", 1)
    else
        ascend_vehicles = false
        mod_uses("vehicle", -1)
    end
end)

no_radio = false
menu.toggle(vehicles_root, "Disable radio on all cars", {"noradio"}, "serenity.", function(on)
    if on then
        no_radio = true
        mod_uses("vehicle", 1)
    else
        no_radio = false
        mod_uses("vehicle", -1)
    end
end)

loud_radio = false
menu.toggle(vehicles_root, "Loud radio on all cars", {"loudradio"}, "I CAN\'T HEAR YOU OVER ALL THIS BULLSHIT", function(on)
    if on then
        loud_radio = true
        mod_uses("vehicle", 1)
    else
        loud_radio = false
        mod_uses("vehicle", -1)
    end
end)


halt_traffic = false
menu.toggle(vehicles_root, "Halt traffic", {"halttraffic"}, "Prevents all nearby vehicles from moving, at all. Not even an inch. Irreversible so be careful.", function(on)
    if on then
        halt_traffic = true
        mod_uses("vehicle", 1)
    else
        halt_traffic = false
        mod_uses("vehicle", -1)
    end
end)

menu.action(vehicles_root, "Replace all cars with tractors", {"tractors"}, "yeehaw. not a loop because theres a big resource toll.", function(on_click)
    request_model_load(-2076478498)
    for k,veh in pairs(entities.get_all_vehicles_as_handles()) do
        local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, -1)
        if veh ~= 0 and not is_ped_player(driver) then
            if ENTITY.GET_ENTITY_MODEL(veh) ~= -2076478498 then
                local hash = 0x9C9EFFD8
                request_model_load(hash)
                local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(veh, -2.0, 0.0, 0.0)
                coords.x = coords['x']
                coords.y = coords['y']
                coords.z = coords['z']
                local ped = entities.create_ped(28, hash, coords, 30.0)
                if cur_veh ~= last_veh then
                    PED.SET_PED_INTO_VEHICLE(ped, last_veh, -1)
                end
                ENTITY.SET_ENTITY_INVINCIBLE(ped, true)
                PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
                PED.SET_PED_FLEE_ATTRIBUTES(ped, 0, false)
                PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true)
                PED.SET_PED_CAN_BE_DRAGGED_OUT(ped, false)
                PED.SET_PED_CAN_BE_KNOCKED_OFF_VEHICLE(ped, false)
                --TASK.TASK_GO_TO_COORD_ANY_MEANS(ped, math.random(1000), math.random(1000), math.random(100), 80.0, 0, true, 262144, 1)
                TASK.TASK_COMBAT_PED(ped, playerped, 0, 16)
                local hdg = ENTITY.GET_ENTITY_HEADING(veh)
                local oldspeed = ENTITY.GET_ENTITY_SPEED(veh)
                entities.delete_by_handle(veh)
                local newveh = entities.create_vehicle(-2076478498, coords, hdg)
                PED.SET_PED_INTO_VEHICLE(ped, newveh, -1)
                VEHICLE.SET_VEHICLE_ENGINE_ON(newveh, true, true, false)
                VEHICLE.SET_VEHICLE_FORWARD_SPEED(newveh, oldspeed)
                TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(ped, newveh, math.random(0,1000), math.random(0,100), math.random(0, 1000), 300.0, 786996, 5)
            end
        end
    end
end)


reverse_traffic = false
menu.toggle(vehicles_root, "Reverse traffic", {"reversetraffic"}, "Traffic, but flip it", function(on)
    if on then
        reverse_traffic = true
        mod_uses("vehicle", 1)
    else
        reverse_traffic = false
        mod_uses("vehicle", -1)
    end
end)

vehicle_chaos = false
menu.toggle(vehicles_root, "Vehicle chaos", {"chaos"}, "Enables the chaos...", function(on)
    if on then
        vehicle_chaos = true
        mod_uses("vehicle", 1)
    else
        vehicle_chaos = false
        mod_uses("vehicle", -1)
    end
end, false)

vc_gravity = true
menu.toggle(vehicles_root, "Vehicle chaos gravity", {"chaosgravity"}, "Gravity on/off", function(on)
    vc_gravity = on
end, true)

vc_speed = 100
menu.slider(vehicles_root, "Vehicle chaos speed", {"chaosspeed"}, "The speed to force the vehicles to. Higher = more chaos.", 30, 300, 100, 10, function(s)
  vc_speed = s
end)

bullet_rain = false
bullet_rain_target = -1
num_of_spam = 30
entity_grav = true
function spam_entity_on_player(ped, hash)
    request_model_load(hash)
    for i=1, num_of_spam do
        rand_coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, math.random(-1,1), math.random(-1,1), math.random(-1,1))
        rand_coords.x = rand_coords['x']
        rand_coords.y = rand_coords['y']
        rand_coords.z = rand_coords['z']
        obj = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, rand_coords['x'], rand_coords['y'], rand_coords['z'], true, false, false)
        if entity_grav then
            grav_factor = 1.0
        else
            grav_factor = 0.0
        end
        ENTITY.SET_ENTITY_HAS_GRAVITY(obj, entity_grav)
        ENTITY.FREEZE_ENTITY_POSITION(obj)
    end
    util.toast('Done spamming entities.')
end

local aircraft_root = menu.list(vehicle_root, "Aircraft", {"lanceaircraft"}, "")

menu.action(vehicle_root, "Force leave vehicle", {"forceleave"}, "Force leave vehicle, in case of emergency or stuckedness", function(on_click)
    TASK.CLEAR_PED_TASKS_IMMEDIATELY(PLAYER.PLAYER_PED_ID())
    TASK.TASK_LEAVE_ANY_VEHICLE(PLAYER.PLAYER_PED_ID(), 0, 16)
end)

menu.action(aircraft_root, "Break rudder", {"breakrudder"}, "Breaks rudder. Good for stunts.", function(on_click)
    if player_cur_car ~= 0 then
        VEHICLE.SET_VEHICLE_RUDDER_BROKEN(player_cur_car, true)
    end
end)
--SET_PLANE_TURBULENCE_MULTIPLIER(Vehicle vehicle, float multiplier)

vehicle_strafe = false
menu.toggle(vehicle_root, "Vehicle strafe", {"vstrafe"}, "Use right and left arrow keys to make your vehicle strafe horizontally.", function(on)
    vehicle_strafe = on
end, false)

vehicle_jump = false
menu.toggle(vehicle_root, "Vehicle jump", {"vjump"}, "Lets you jump with any vehicle with horn", function(on)
    vehicle_jump =  on
end, false)

vjumpforce = 20
menu.slider(vehicle_root, "Vehicle jump force", {"vjumpforce"}, "", 1, 300, 20, 1, function(s)
    vjumpforce = s
  end)

instantspinup = false
menu.toggle(aircraft_root, "Instant propeller spinup", {"instantspinup"}, "Immediately spins up the blades, with no wait", function(on)
    instantspinup = on
end, false)

menu.slider(aircraft_root, "Turbulence", {"turbulence"}, "Sets turbulence. 0 = no turbulence, 1 = default turbulence, 2 = heavy turbulence", 0, 2, 1, 1, function(s)
    if not player_cur_car then
        return
    end
    if s == 0 then
        VEHICLE.SET_PLANE_TURBULENCE_MULTIPLIER(player_cur_car, 0.0)
        VEHICLE.SET_HELI_TURBULENCE_SCALAR(player_cur_car, 0.0)
    elseif s == 1 then
        VEHICLE.SET_PLANE_TURBULENCE_MULTIPLIER(player_cur_car, 0.5)
        VEHICLE.SET_HELI_TURBULENCE_SCALAR(player_cur_car, 0.5)
    elseif s == 2 then
        VEHICLE.SET_PLANE_TURBULENCE_MULTIPLIER(player_cur_car, 1.0)
        VEHICLE.SET_HELI_TURBULENCE_SCALAR(player_cur_car, 1.0)
    end
end)

tesla_ped = 0
menu.action(vehicle_root, "Tesla summon", {"teslasummon"}, "Have your car drive itself to you.", function(on_click)
    lastcar = PLAYER.GET_PLAYERS_LAST_VEHICLE()
    if lastcar ~= 0 then
        local plyr = PLAYER.PLAYER_PED_ID()
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(plyr, 0.0, 5.0, 0.0)
        coords.x = coords['x']
        coords.y = coords['y']
        coords.z = coords['z']
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

menu.toggle(vehicle_root, "Invisible boat-mobile", {"boatmobile"}, "brrrr", function(on)
    if not player_cur_car then
        return
    end
    if on then
        ENTITY.SET_ENTITY_ALPHA(player_cur_car, 0, true)
        ENTITY.SET_ENTITY_VISIBLE(player_cur_car, false, false)
    else
        ENTITY.SET_ENTITY_ALPHA(player_cur_car, 255, true)
        ENTITY.SET_ENTITY_VISIBLE(player_cur_car, true, false)
    end
end)

menu.action(vehicle_root, "Vehicle 180", {"vehicle180"}, "Turns your vehicle around with momentum preserved. Recommended to bind this.", function(on_click)
    if player_cur_car ~= 0 then
		
    end
end)

stickyground = false
menu.toggle(vehicle_root, "Stick to ground/walls", {"stick2ground"}, "Keeps your car on the ground (may sacrifice performance due to friction, duhh). If riding walls is what ye seek, this also does that.", function(on)
    stickyground = on
end)

mph_plate = false
menu.toggle(vehicle_root, "Speedometer plate", {"speedplate"}, "Unlike Ozark, which had this feature, I don\'t exit scam! Will reset your plate to what it was originally when you disable, also has KPH and MPH settings, so this is already better.", function(on)
    if on then
        if player_cur_car ~= 0 then
            original_plate = VEHICLE.GET_VEHICLE_NUMBER_PLATE_TEXT(player_cur_car)
        else
            util.toast("You were not in a vehicle when starting this. You won\'t be able to revert plate text.")
            original_plate = "LANCE"
        end
        mph_plate = true
    else
        if player_cur_car ~= 0 then
            if original_plate == nil then
                original_plate = "LANCE"
            end
            VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(player_cur_car, original_plate)
        end
        mph_plate = false
    end
end)

mph_unit = "kph"
menu.toggle(vehicle_root, "Use MPH for speedometer plate", {"usemph"}, "Toggle off if you aren\'t American.", function(on)
    if on then
        mph_unit = "mph"
    else
        mph_unit = "kph"
    end
end, false)

everythingproof = false
menu.toggle(vehicle_root, "Everything-proof", {"everythingproof"}, "Makes your vehicle everything-proof. But not invincible. Glass seems to be bulletproof though. Don\'t judge me, I didn\'t make this native.", function(on)
    everythingproof = on
end)

menu.click_slider(vehicle_root, "Vehicle top speed", {"topspeed"}, "Sets vehicle top speed (this is known as engine power multiplier elsewhere)", 1, 2000, 200, 50, function(s)
    VEHICLE.MODIFY_VEHICLE_TOP_SPEED(player_cur_car, s)
end)

shift_drift = false
menu.toggle(vehicle_root, "Hold shift to drift", {"shiftdrift"}, "You heard me.", function(on)
    shift_drift = on
end)

infcms = false
menu.toggle(vehicle_root, "Infinite countermeasures", {"infinitecms"}, "We also don\'t charge $140 for this feature. It\'s a single native call lmao", function(on)
    infcms = on
end)

menu.slider(vehicle_root, "Dirt level", {"dirtlevel"}, "Arctic Monkeys - Do I Wanna Know", 0, 15.0, 0, 1, function(s)
    if player_cur_car ~= 0 then
        VEHICLE.SET_VEHICLE_DIRT_LEVEL(player_cur_car, s)
    end
end)

menu.slider(vehicle_root, "Light multiplier", {"lightmultiplier"}, "Sets brightness of lights in the vehicle. Local only.", 0, 1000000, 1, 1, function(s)
    if player_cur_car ~= 0 then
        VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(player_cur_car, s)
    end
end)

horn_boost = false
menu.toggle(vehicle_root, "Horn boost", {"hornboost"}, "beeeeeeeeeeeeeeeeeeeeeeeeeep", function(on)
    horn_boost = on
end)

force_cm = false
menu.toggle(vehicle_root, "Force spawn countermeasures", {"forcecms"}, "Forces countermeasures out in any vehicle when you use the horn key", function(on)
    force_cm = on
    menu.trigger_commands("getgunsflaregun")
end)

dow_block = 0
driveonwater = false
menu.toggle(vehicle_root, "Drive on water", {"driveonwater"}, "why does everyone need this feature!!!!!!!!", function(on)
    if on then
        driveonwater = true
        if driveonair then
            menu.trigger_commands("driveonair off")
            util.toast("Drive on air has been turned OFF automatically to prevent issues.")
        end
    else
        driveonwater = false
        if not driveonair and not walkonwater then
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(dow_block, 0, 0, 0, false, false, false)
        end
    end
end)

doa_ht = 0
driveonair = false
menu.toggle(vehicle_root, "Drive on air", {"driveonair"}, "yes", function(on)
    if on then
        local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
        doa_ht = pos['z']
        driveonair = true
        util.toast("Use space and ctrl to fine-tune your driving height!")
        if driveonwater then
            menu.trigger_commands("driveonwater off")
            util.toast("Drive on water has been turned OFF automatically to prevent issues.")
        end
    else
        driveonair = false
    end
end)


walkonwater = false
menu.toggle(self_root, "Walk on water", {"walkonwater"}, "no blasphemy permitted! this will not function when you are inside a vehicle.", function(on)
    if on then
        walkonwater = true
        menu.trigger_commands("walkonair off")
        menu.trigger_commands("driveonair off")
    else
        walkonwater = false
    end
end)

woa_ht = 0
walkonair = false
menu.toggle(self_root, "Walk on air", {"walkonair"}, "the gods! this will not function when you are inside a vehicle.", function(on)
    if on then
        local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
        woa_ht = pos['z'] - 1.00
        walkonair = true
        util.toast("Use space and ctrl to fine-tune your walking height!")
        menu.trigger_commands("walkonwater off")
        menu.trigger_commands("driveonair off")
    else
        walkonair = false
    end
end)

rainbow_tint = false

moonwalk = false
menu.toggle(self_root, "Moonwalk", {"moonwalk"}, "she was more like a beauty queen", function(on)
    moonwalk = on
end)

tpf_units = 0.5
menu.action(self_root, "TP forward", {"tpforward"}, "Teleports you a little bit forward. Useful for \"phasing\" through stuff; bind a key to it! Use the slider to adjust how far.", function(on_click)
    local pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0, tpf_units, 0)
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(PLAYER.PLAYER_PED_ID(), pos['x'], pos['y'], pos['z'], true, false, false)
end)

menu.slider(self_root, "TP forward units", {"tpfunits"}, "Number of units to teleport forward * 0.1", 5, 100, 1, 1, function(s)
    tpf_units = s*0.1
end)



--menu.action(self_root, "test", {"devtest"}, "devtest.", function(on_click)
--    local c = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
--    NETWORK._NETWORK_RESPAWN_COORDS(players.user(), c['x'], c['y'], c['z'], false, false)
--end)

turnsignals = false
menu.toggle(vehicle_root, "Use turn signals", {"turnsignals"}, "You will use turn signals when turning.", function(on)
    turnsignals = on
end)

function aa_thread()
    aa_threadv = util.create_thread(function()
        while true do
            if not noaccident then
                util.stop_thread()
            end
            if player_cur_car ~= 0 then
                local c = ENTITY.GET_ENTITY_COORDS(player_cur_car, true)
                local size = get_model_size(ENTITY.GET_ENTITY_MODEL(player_cur_car))
                for i=1,3 do
                    if i == 1 then
                        aad = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_cur_car, -size['x'], size['y']+0.1, size['z']/2)
                    elseif i == 2 then
                        aad = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_cur_car, 0.0, size['y']+0.1, size['z']/2)
                    else
                        aad = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_cur_car, size['x'], size['y']+0.1, size['z']/2)
                    end
                    if ENTITY.GET_ENTITY_SPEED(player_cur_car) > 10 then
                        log("aa thread allocation")
                        local ptr1, ptr2, ptr3, ptr4 = memory.alloc(), memory.alloc(), memory.alloc(), memory.alloc()
                        SHAPETEST.GET_SHAPE_TEST_RESULT(
                            SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(
                                c.x, 
                                c.y, 
                                c.z, 
                                aad.x, 
                                aad.y, 
                                aad.z, 
                                -1,
                                player_cur_car, 
                                4
                            ), ptr1, ptr2, ptr3, ptr4)
                        local p1 = memory.read_int(ptr1)
                        local p2 = memory.read_vector3(ptr2)
                        local p3 = memory.read_vector3(ptr3)
                        local p4 = memory.read_int(ptr4)
                        log("aa thread free mem")
                        memory.free(ptr1)
                        memory.free(ptr2)
                        memory.free(ptr3)
                        memory.free(ptr4)
                        local results = {p1, p2, p3, p4}
                        if results[1] ~= 0 then
                            ENTITY.SET_ENTITY_VELOCITY(player_cur_car, 0.0, 0.0, 0.0)
                            util.toast("Accident avoidance tripped! Stopping vehicle.")
                        end
                    end
                end
            end
        util.yield()
        end
    end)
end

noaccident = false
menu.toggle(vehicle_root, "Accident avoidance", {"accidentavoidance"}, "Uses brand new technology to avoid car accidents. Tesla certified. Some driving competency is still required.", function(on)
    if on then
        noaccident = true
        aa_thread()
    else
        noaccident = false
    end
end)

renderscorched = false
menu.toggle(vehicle_root, "Render scorched", {"renderscorched"}, "Renders your car scorched.", function(on)
    if on then
        renderscorched = true
    else
        renderscorched = false
        if player_cur_car ~= 0 then
            ENTITY.SET_ENTITY_RENDER_SCORCHED(player_cur_car, false)
        end
    end
end, false)

-- 	1198879012

swiss_cheese_dmg = 0
launchloop = false
launchtar = 0
hit_times = 1
ped_chase = false
chase_target = -1
earrape = false
earrape_target = -1
towfrombehind = false
ram_onground = false
waterjetloop = false 
firejetloop = false 
firejettar = 0 
waterjettar = 0
aped_combat = false
combat_tar = 0

function ram_ped_with(ped, vehicle, offset, sog)
    request_model_load(vehicle)
    local front = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, offset, 0.0)
    front.x = front['x']
    front.y = front['y']
    front.z = front['z']
    local veh = entities.create_vehicle(vehicle, front, ENTITY.GET_ENTITY_HEADING(ped)+180)
    if ram_onground then
        OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(veh)
    end
    VEHICLE.SET_VEHICLE_ENGINE_ON(veh, true, true, true)
    VEHICLE.SET_VEHICLE_FORWARD_SPEED(veh, 100.0)
end

function give_vehicle(pid, hash)
    request_model_load(hash)
    local plyr = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
    local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(plyr, 0.0, 5.0, 0.0)
    local car = entities.create_vehicle(hash, c, ENTITY.GET_ENTITY_HEADING(plyr))
    max_out_car(car)
    ENTITY.SET_ENTITY_INVINCIBLE(car)
    VEHICLE.SET_VEHICLE_DOOR_OPEN(car, 0, false, true)
    VEHICLE.SET_VEHICLE_DOOR_LATCHED(car, 0, false, false, true)
end

function give_vehicle_all(hash)
    for k,p in pairs(players.list(true, true, true)) do
        give_vehicle(p, hash)
    end
end

function give_bodyguard(pid)
    local hash = 988062523
    request_model_load(hash)
    local plyr = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
    local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(plyr, 0.0, 5.0, 0.0)
    c.x = c['x']
    c.y = c['y']
    c.z = c['z']
    local bg = entities.create_ped(28, hash, c, ENTITY.GET_ENTITY_HEADING(plyr)+180)
    local group = PED.GET_PED_GROUP_INDEX(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid))
    PED.SET_PED_AS_GROUP_MEMBER(bg, group)
    ENTITY.SET_ENTITY_INVINCIBLE(bg, true)
    TASK.TASK_COMBAT_HATED_TARGETS_AROUND_PED(bg, 30.0, 0)
    PED.SET_PED_FLEE_ATTRIBUTES(bg, 0, false)
    PED.SET_PED_COMBAT_ATTRIBUTES(bg, 46, true)
    WEAPON.GIVE_WEAPON_TO_PED(bg, 2144741730, 0, false, false)
    WEAPON.GIVE_WEAPON_TO_PED(bg, 2017895192, 0, false, false)
    PED.SET_PED_ACCURACY(bg, 100.0)
    local veh = PED.GET_VEHICLE_PED_IS_IN(plyr, true)
    if veh ~= 0 then
        if VEHICLE.ARE_ANY_VEHICLE_SEATS_FREE(veh) then
            for i=0, VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(veh) do
                if VEHICLE.IS_VEHICLE_SEAT_FREE(veh, i) then
                    PED.SET_PED_INTO_VEHICLE(bg, veh, i)
                    break
                end
            end
        end
    end
end

function give_bodyguard_all()
    for k,p in pairs(players.list(false, true, true)) do
        give_bodyguard(p)
    end
end

function detach_all_entities()
    local vehs = entities.get_all_vehicles_as_handles()
    local objs = entities.get_all_objects_as_handles()
    local peds = entities.get_all_peds_as_handles()
    for k,v in pairs(vehs) do
        if ENTITY.IS_ENTITY_ATTACHED_TO_ANY_PED(v) then
            request_control_of_entity(v)
            ENTITY.DETACH_ENTITY(v, false, false)
        end
    end
    for k,v in pairs(objs) do
        if ENTITY.IS_ENTITY_ATTACHED_TO_ANY_PED(v) then
            request_control_of_entity(v)
            ENTITY.DETACH_ENTITY(v, false, false)
        end
    end
    for k,v in pairs(peds) do
        if ENTITY.IS_ENTITY_ATTACHED_TO_ANY_PED(v) then
            request_control_of_entity(v)
            ENTITY.DETACH_ENTITY(v, false, false)
        end
    end
end

function give_car_addon(pid, hash, center, ang)
    local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
    local pos = ENTITY.GET_ENTITY_COORDS(car, true)
    pos.x = pos['x']
    pos.y = pos['y']
    pos.z = pos['z']
    request_model_load(hash)
    local ramp = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, pos['x'], pos['y'], pos['z'], true, false, false)
    local size = get_model_size(ENTITY.GET_ENTITY_MODEL(car))
    if center then
        ENTITY.ATTACH_ENTITY_TO_ENTITY(ramp, car, 0, 0.0, 0.0, 0.0, 0.0, 0.0, ang, true, true, true, false, 0, true)
    else
        ENTITY.ATTACH_ENTITY_TO_ENTITY(ramp, car, 0, 0.0, size['y']+1.0, 0.0, 0.0, 0.0, ang, true, true, true, false, 0, true)
    end
end

function give_all_car_addon(hash, center, ang)
    for k,pid in pairs(players.list(false, true, true)) do
        give_car_addon(pid, hash, center, ang)
    end
end

function deg_to_rad(x)
    return x * (math.pi/180)
end
-- credit to murten
function rot_to_dir(deg_z, deg_x)
    local rad_z = deg_to_rad(deg_z);
    local rad_x = deg_to_rad(deg_x);
    local num = math.abs(math.cos(rad_x));
    local vector3 = {
        x = -math.sin(rad_z) * num,
        y = math.cos(rad_z) * num,
        z = math.sin(rad_x)
    }
    return vector3
end

num_attackers = 1
godmodeatk = false
freezeloop = false 
freezetar = -1
atkgun = 0

function tp_player_car_to_coords(pid, coord)
    local name = PLAYER.GET_PLAYER_NAME(pid)
    if robustmode then
        menu.trigger_commands("spectate" .. name .. " on")
        util.yield(1000)
    end
    local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
    if car ~= 0 then
        request_control_of_entity(car)
        if NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(car) then
            for i=1, 3 do
                util.toast("Success")
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(car, coord['x'], coord['y'], coord['z'], false, false, false)
            end
        end
    end
end

function tp_all_player_cars_to_coords(coord)
    for k,pid in pairs(players.list(false, true, true)) do
        tp_player_car_to_coords(pid, coord)
    end
end

givegun = false
num_attackers = 1
function send_attacker(hash, pid, givegun)
    local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
    coords = ENTITY.GET_ENTITY_COORDS(target_ped, false)
    coords.x = coords['x']
    coords.y = coords['y']
    coords.z = coords['z']
    request_model_load(hash)
    for i=1, num_attackers do
        local attacker = entities.create_ped(28, hash, coords, math.random(0, 270))
        if godmodeatk then
            ENTITY.SET_ENTITY_INVINCIBLE(attacker, true)
        end
        TASK.TASK_COMBAT_PED(attacker, target_ped, 0, 16)
        PED.SET_PED_ACCURACY(attacker, 100.0)
        PED.SET_PED_COMBAT_ABILITY(attacker, 2)
        PED.SET_PED_AS_ENEMY(attacker, true)
		PED.SET_PED_ARMOUR(attacker,-1,0,1,2, 200)
		PED.SET_PED_MAX_HEALTH(attacker,-1,0,1,2, 10000)
		ENTITY.SET_ENTITY_HEALTH(attacker, 10000)
        PED.SET_PED_FLEE_ATTRIBUTES(attacker, 0, false)
        PED.SET_PED_COMBAT_ATTRIBUTES(attacker, 46, true)
        if givegun then
            WEAPON.GIVE_WEAPON_TO_PED(attacker, atkgun, 0, false, true)
        end
    end
end

function send_aircraft_attacker(vhash, phash, pid)
    local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
    coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, math.random(-50, 50),  math.random(-50, 50), 500.0)
    coords.x = coords['x']
    coords.y = coords['y']
    coords.z = coords['z']
    request_model_load(vhash)
    request_model_load(phash)
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
            if i == -1 then
                TASK.TASK_PLANE_MISSION(ped, aircraft, 0, target_ped, 0, 0, 0, 6, 0.0, 0, 0.0, 50.0, 40.0)
            end
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 5, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true)
            PED.SET_PED_INTO_VEHICLE(ped, aircraft, i)
            TASK.TASK_COMBAT_PED(ped, target_ped, 0, 16)
            PED.SET_PED_COMBAT_ABILITY(ped, 2)
			PED.SET_PED_ACCURACY(clown, 100.0)
			PED.SET_PED_ARMOUR(clown,-1,0,1,2, 200)
			PED.SET_PED_MAX_HEALTH(clown,-1,0,1,2, 1000)
			ENTITY.SET_ENTITY_HEALTH(clown, 1000)
        end
    end
end

function send_groundv_attacker(vhash, phash, pid, givegun)
    local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
    request_model_load(vhash)
    local bike_hash = -159126838
    request_model_load(phash)
    for i=1, num_attackers do
        local spawn_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, num_attackers-i, -10.0, 0.0)
        spawn_pos.x = spawn_pos['x']
        spawn_pos.y = spawn_pos['y']
        spawn_pos.z = spawn_pos['z']
        local bike = entities.create_vehicle(vhash, spawn_pos, ENTITY.GET_ENTITY_HEADING(player_ped))
        for i=-1, VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(vhash) - 2 do
            local rider = entities.create_ped(1, phash, spawn_pos, 0.0)
            if i == -1 then
                TASK.TASK_VEHICLE_CHASE(rider, target_ped)
            end
            max_out_car(atkbike)
            PED.SET_PED_INTO_VEHICLE(rider, bike, i)
            WEAPON.GIVE_WEAPON_TO_PED(rider, atkgun, 1000, false, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(rider, 5, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(rider, 46, true)
            TASK.TASK_COMBAT_PED(rider, player_ped, 0, 16)
            if godmodeatk then
                ENTITY.SET_ENTITY_INVINCIBLE(bike, true)
                ENTITY.SET_ENTITY_INVINCIBLE(rider, true)
            end
            if givegun then
                WEAPON.GIVE_WEAPON_TO_PED(rider, atkgun, 0, false, true)
            end
        end
    end
end

function set_up_player_actions(pid)
    log("Setting up player actions for pid " .. pid)
    log("Set up divider for pid " .. pid)
    menu.divider(menu.player_root(pid), "LanceScript TEOF")
    log("Set up ls nice for pid " .. pid)
    local ls_nice = menu.list(menu.player_root(pid), "Lancescript: Nice", {"lsnice"}, "")
    log("Set up vaddons for pid " .. pid)
    local ls_vaddons = menu.list(ls_nice, "Vehicle addons", {"lsvaddons"}, "")
    log("Set up ls naughty for pid " .. pid)
    local ls_naughty = menu.list(menu.player_root(pid), "Lancescript: Naughty", {"lsnaughty"}, "")
    --local scriptevents = menu.list(ls_naughty, "Script events", {"lsse"}, "Send script events to the player to do various things")
    local ls_neutral = menu.list(menu.player_root(pid), "Lancescript: Neutral", {"lsneutral"}, "")
    --menu.divider(scriptevents, "Made for GTA " .. ocoded_for)
    spawnvehicle_root = menu.list(ls_nice, "Give vehicle", {"spawnveh"}, "")
    menyoospawnvehicle_root = menu.list(spawnvehicle_root, "Give menyoo vehicle", {"spawnveh"}, "")
    setup_menyoo_vehicles_list(menyoospawnvehicle_root, pid, false, false)
    explosions_root = menu.list(ls_naughty, "Projectiles/explosions", {"lancescriptexplosions"}, "Fire jet, water jet, launch player, etc.")
    entspam_root = menu.list(ls_naughty, "Entity spam", {"entityspam"}, "")
    forcedacts_root = menu.list(ls_neutral, "Forced actions", {"forcedacts"}, "")
    plrecoveries_root = menu.list(ls_nice, "Recoveries", {"plrecoveries"}, "")
    plpedmoney_root = menu.list(plrecoveries_root, "Ped money", {"plpedmoney"}, "")
    npctrolls_root = menu.list(ls_naughty, "NPC trolling", {"npctrolls"}, "")
    attackers_root = menu.list(npctrolls_root, "Attackers", {"lancescriptattackers"}, "Send attackers")
	vehatk_root = menu.list(npctrolls_root, "Hostile Traffic Options", {"axhovattackers"}, "Hostile Traffic options")
	cop_root = menu.list(attackers_root, "Cop Mods", {"cops"}, "Modifications to apply to police spawned by the game, as well as attackers you spawn, but more for police.")
	atkab_root = menu.list(attackers_root, "Attacker attributes", {"atkatb"}, "attacker attributes")
	army_root = menu.list(attackers_root, "Marine Variants", {"teofatkarmy"}, "we are the army. run run. we are the army. run run.")
    objecttrolls_root = menu.list(ls_naughty, "Object trolling", {"objecttrolls"}, "")
    ram_root = menu.list(ls_naughty, "Ram", {"ram"}, "")
    log("Set up roots for pid " .. pid)
    log("Adding menu actions and toggles for pid " .. pid)

    menu.action(forcedacts_root, "Teleport vehicle to me", {"tpvtome"}, "This MAY OR MAY NOT WORK. It is NOT a bug if this does not work.", function(on_click)
        tp_player_car_to_coords(pid, ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true))
    end)
    log("tpvtome added")

    menu.action(forcedacts_root, "Teleport vehicle to waypoint", {"tpvtoway"}, "This MAY OR MAY NOT WORK. It is NOT a bug if this does not work.", function(on_click)
        local c = get_waypoint_coords()
        if c ~= nil then
            tp_player_car_to_coords(pid, c)
        end
    end)
    log("tpvtoway added")

    menu.action(forcedacts_root, "Teleport vehicle to Maze Bank helipad", {"tpvtomaze"}, "This MAY OR MAY NOT WORK. It is NOT a bug if this does not work.", function(on_click)
        local c = {}
        c.x = -75.261375
        c.y = -818.674
        c.z = 326.17517
        tp_player_car_to_coords(pid, c)
    end)
    log("forcedact mazebank added")
	
	menu.action(forcedacts_root, "Teleport vehicle to Mt. Chiliad", {"tpvtomtch"}, "This MAY OR MAY NOT WORK. It is NOT a bug if this does not work.", function(on_click)
		local c = {}
		c.x = 492.30
		c.y = 5589.44
		c.z = 794.28
		tp_player_car_to_coords(pid, c)
	end)
	log("forcedact chiliad added")

    menu.action(forcedacts_root, "Teleport vehicle deep underwater", {"tpvunderwater"}, "This MAY OR MAY NOT WORK. It is NOT a bug if this does not work.", function(on_click)
        local c = {}
        c.x = 4497.2207
        c.y = 8028.3086
        c.z = -32.635174
        tp_player_car_to_coords(pid, c)
    end)
    log("forcedact underwater added")

    menu.action(forcedacts_root, "Teleport vehicle into LSC", {"tpvlsc"}, "This MAY OR MAY NOT WORK. It is NOT a bug if this does not work.", function(on_click)
        local c = {}
        c.x = -353.84512
        c.y = -135.59108
        c.z = 39.009624
        tp_player_car_to_coords(pid, c)
    end)

    menu.action(forcedacts_root, "Teleport vehicle into SCP-173 cell", {"tpvscp"}, "This MAY OR MAY NOT WORK. It is NOT a bug if this does not work.", function(on_click)
        local c = {}
        c.x = 1642.8401
        c.y = 2570.7695
        c.z = 45.564854
        tp_player_car_to_coords(pid, c)
    end)

    menu.action(forcedacts_root, "Teleport vehicle into large cell", {"tpvcell"}, "This MAY OR MAY NOT WORK. It is NOT a bug if this does not work.", function(on_click)
        local c = {}
        c.x = 1737.1896
        c.y = 2634.897
        c.z = 45.56497
        tp_player_car_to_coords(pid, c)
    end)

    menu.action(forcedacts_root, "Destroy vehicle engine", {"destroyvengine"}, "This MAY OR MAY NOT WORK. It is NOT a bug if this does not work.", function(on_click)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            request_control_of_entity(car)
            VEHICLE.SET_VEHICLE_ENGINE_HEALTH(car, -4000.0)
        end
    end)
    log("forcedact destroyeng added")

    menu.action(forcedacts_root, "set vehicle engine to almost broken", {"damagevengine"}, "This MAY OR MAY NOT WORK. It is NOT a bug if this does not work.", function(on_click)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            request_control_of_entity(car)
            VEHICLE.SET_VEHICLE_ENGINE_HEALTH(car, 1.0)
			VEHICLE.SET_VEHICLE_BODY_HEALTH(car, 1)
        end
    end)

    menu.action(forcedacts_root, "Repair vehicle :)", {"repairveh"}, "This MAY OR MAY NOT WORK. It is NOT a bug if this does not work.", function(on_click)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            request_control_of_entity(car)
            VEHICLE.SET_VEHICLE_ENGINE_HEALTH(car, 1000.0)
            VEHICLE.SET_VEHICLE_FIXED(car)
            VEHICLE.SET_VEHICLE_BODY_HEALTH(car, 10000.0)
        end
    end)
    log("forcedact repairv added")

    menu.action(forcedacts_root, "Yeet vehicle", {"yeetv"}, "This MAY OR MAY NOT WORK. It is NOT a bug if this does not work.", function(on_click)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            request_control_of_entity(car)
            ENTITY.APPLY_FORCE_TO_ENTITY(car, 2, 0, 0, 10000000, 0, 0, 0, 0, true, false, true, false, true)
        end
    end)
    log("forcedact yeet added")

    menu.action(forcedacts_root, "Detach from trailer", {"detachv"}, "This MAY OR MAY NOT WORK. It is NOT a bug if this does not work.", function(on_click)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            request_control_of_entity(car)
            VEHICLE.DETACH_VEHICLE_FROM_TRAILER(car)
        end
    end)
    log("forcedact detachv added")

    menu.action(forcedacts_root, "Set license plate to LANCE", {"lancelicense"}, "This MAY OR MAY NOT WORK. It is NOT a bug if this does not work.", function(on_click)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            request_control_of_entity(car)
            VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(car, "LANCE")
        end
    end)
    log("forcedact licenselance added")

    menu.action(forcedacts_root, "Set license plate to STAND", {"standlicense"}, "This MAY OR MAY NOT WORK. It is NOT a bug if this does not work.", function(on_click)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            request_control_of_entity(car)
            VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(car, "STAND")
        end
    end)
    log("forcedact stand added")

    menu.action(forcedacts_root, "Set license plate to COCK", {"cocklicense"}, "This MAY OR MAY NOT WORK. It is NOT a bug if this does not work.", function(on_click)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            request_control_of_entity(car)
            VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(car, "COCK")
        end
    end)

    menu.action(forcedacts_root, "Custom plate text", {"customplatetext"}, "", function(on_click)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            util.toast("Please input the plate text")
            menu.show_command_box("customplatetext" .. PLAYER.GET_PLAYER_NAME(pid) .. " ")
        end
    end, function(on_command)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if #on_command <= 8 then
            request_control_of_entity(car)
            VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(car, on_command)
        else
            util.toast("Too many characters. Please re-input plate text.")
            menu.show_command_box("customplatetext" .. PLAYER.GET_PLAYER_NAME(pid) .. " ")
        end
    end)
    log("forcedact customplate added")

    
    menu.action(forcedacts_root, "Open all car doors", {"opendoors"}, "This MAY OR MAY NOT WORK. It is NOT a bug if this does not work.", function(on_click)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            request_control_of_entity(car)
            local d = VEHICLE._GET_NUMBER_OF_VEHICLE_DOORS(car)
            for i=1, d do
                VEHICLE.SET_VEHICLE_DOOR_OPEN(car, i, false, true)
            end
        end
    end)
    log("forcedact opendoors added")
        
    menu.action(forcedacts_root, "Close all car doors", {"opendoors"}, "This MAY OR MAY NOT WORK. It is NOT a bug if this does not work.", function(on_click)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            request_control_of_entity(car)
            local d = VEHICLE._GET_NUMBER_OF_VEHICLE_DOORS(car)
            for i=1, d do
                VEHICLE.SET_VEHICLE_DOOR_SHUT(car, i, false)
            end
        end
    end)
    log("forcedact closedoors added")

    menu.action(broken_root, "Disable Missiles", {"removevehm"}, "This MAY OR MAY NOT WORK. It is NOT a bug if this does not work. **ONLY applies to vehicles that DO NOT have missiles by default, like the deluxo or oppressor mk1 and mk2.**.", function(on_click)
       local vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
	   local owner = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX()
        if vehicle ~= 0 then
            if VEHICLE.DOES_VEHICLE_HAVE_WEAPONS(vehicle) then 
				VEHICLE.SET_VEHICLE_MOD_KIT(vehicle, 0)
				VEHICLE.SET_VEHICLE_MOD(vehicle, 10, -1)
			else 
				util.toast("Player is either not in a vehicle, vehicle does not have weapons, or you are out of range.")
			end
		end
	end)
	
    menu.action(forcedacts_root, "Godmode vehicle", {"godmodev"}, "This MAY OR MAY NOT WORK. It is NOT a bug if this does not work.", function(on_click)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            request_control_of_entity(car)
            ENTITY.SET_ENTITY_INVINCIBLE(car, true)
            VEHICLE.SET_VEHICLE_CAN_BE_VISIBLY_DAMAGED(car, false)
        end
    end)

    menu.click_slider(forcedacts_root, "Vehicle top speed", {"vtopspeed"}, "This MAY OR MAY NOT WORK. It is NOT a bug if this does not work.", 0, 3000, 200, 100, function(s)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            request_control_of_entity(car)
            VEHICLE.MODIFY_VEHICLE_TOP_SPEED(car, s)
        end
    end)
    log("forcedact topspeed added")

    menu.toggle(forcedacts_root, "Invisible vehicle", {"invisv"}, "This MAY OR MAY NOT WORK. It is NOT a bug if this does not work.", function(on)
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
    end, false)
    log("forcedact invisv added")

    menu.toggle(forcedacts_root, "Attach vehicle to my vehicle", {"attachvtomyv"}, "This MAY OR MAY NOT WORK. It is NOT a bug if this does not work.", function(on)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        if car ~= 0 then
            request_control_of_entity(car)
            if on then
                ENTITY.ATTACH_ENTITY_TO_ENTITY(car, player_cur_car, 0, 0.0, -5.00, 0.00, 1.0, 1.0,1, true, true, true, false, 0, true)
            else
                ENTITY.DETACH_ENTITY(car, false, false)
            end
        end
    end, false)
    log("forcedact attachv added")

    menu.action(ls_nice, "Remove stickybombs from car", {"removebombs"}, "", function(on_click)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        NETWORK.REMOVE_ALL_STICKY_BOMBS_FROM_ENTITY(car)
    end)
    log("forcedact removesticky added")

    menu.toggle(ls_nice, "Set as pickup teleport target", {"tppickutar"}, "", function(on)
        if on then
            tp_pickup_tar = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            if not tp_all_pickups then
                menu.trigger_commands("tppickups")
            end
        else
            tp_pickup_tar = PLAYER.PLAYER_PED_ID()
        end
    end, false)

    menu.action(ls_vaddons, "Ramp", {"addramp"}, "", function(on_click)
        give_car_addon(pid, util.joaat("prop_mp_ramp_01"), false, 180.0)
    end)

    menu.action(ls_vaddons, "Tube", {"addtube"}, "", function(on_click)
        give_car_addon(pid, util.joaat("stt_prop_stunt_tube_speedb"), true, 90.0)
    end)

    menu.action(ls_vaddons, "Lochness monster", {"addloch"}, "", function(on_click)
        give_car_addon(pid, util.joaat("h4_prop_h4_loch_monster"), true, -90.0)
    end)

    menu.action(ls_vaddons, "Custom model", {"customplyrvadmdl"}, "Input a custom model to attach. The model string, NOT the hash.", function(on_click)
        util.toast("Please input the model hash")
        menu.show_command_box("customplyrvadmdl" .. PLAYER.GET_PLAYER_NAME(pid) .. " ")
    end, function(on_command)
        local hash = util.joaat(on_command)
        give_car_addon(pid, hash, true, 0.0)
    end)
	
		menu.toggle_loop(ls_naughty, "snowball loop", {balls}, "test option I coded that I don't feel like removing for the reason stated in the next sentence. You can kill people in apartment garages with this.", function()
		local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid))
		local hash = 126349499
		WEAPON.REQUEST_WEAPON_ASSET(hash)
		MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z, pos.x , pos.y, pos.z-2, 200, 0, hash, 0, true, false, 2500.0)
	end)

    menu.action(ls_naughty, "Crush player", {"crush"}, "Spawns a heavy truck several meters above them and forces its Z velocity to -100 to absolutely decimate them when it lands.", function(on_click)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        coords = ENTITY.GET_ENTITY_COORDS(target_ped, false)
        coords.x = coords['x']
        coords.y = coords['y']
        coords.z = coords['z'] + 20.0
        request_model_load(1917016601)
        local truck = entities.create_vehicle(1917016601, coords, 0.0)
        local vel = ENTITY.GET_ENTITY_VELOCITY(vel)
        ENTITY.SET_ENTITY_VELOCITY(truck, vel['x'], vel['y'], -100.0)
		VEHICLE.SET_VEHICLE_DOORS_LOCKED(truck, 3)
		VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_NON_SCRIPT_PLAYERS(truck, true)
		wait(2000)
		entities.delete_by_handle(truck)
    end)

	 menu.action(ls_naughty, "Crush player (Faggio)", {"crush2"}, "Spawns a Faggio to crush them in case your target is standing next to a light pole or other situations where the truck would miss.", function(on_click)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        coords = ENTITY.GET_ENTITY_COORDS(target_ped, false)
        coords.x = coords['x']
        coords.y = coords['y']
        coords.z = coords['z'] + 20.0
        request_model_load(util.joaat("faggio2"))
        local truck = entities.create_vehicle(util.joaat("faggio2"), coords, 0.0)
        local vel = ENTITY.GET_ENTITY_VELOCITY(vel)
        ENTITY.SET_ENTITY_VELOCITY(truck, vel['x'], vel['y'], -200.0)
		VEHICLE.SET_VEHICLE_DOORS_LOCKED(truck, 3)
		VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_NON_SCRIPT_PLAYERS(truck, true)
		wait(2000)
		entities.delete_by_handle(truck)
    end)
	
	 menu.action(ls_naughty, "Crush player (Clown)", {"crush3"}, "Show them they are a clown", function(on_click)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        coords = ENTITY.GET_ENTITY_COORDS(target_ped, false)
        coords.x = coords['x']
        coords.y = coords['y']
        coords.z = coords['z'] + 20.0
        request_model_load(util.joaat("speedo2"))
        local truck = entities.create_vehicle(util.joaat("speedo2"), coords, 0.0)
        local vel = ENTITY.GET_ENTITY_VELOCITY(vel)
        ENTITY.SET_ENTITY_VELOCITY(truck, vel['x'], vel['y'], -200.0)
		VEHICLE.SET_VEHICLE_DOORS_LOCKED(truck, 3)
		VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_NON_SCRIPT_PLAYERS(truck, true)
		wait(2000)
		entities.delete_by_handle(truck)
    end)

	 menu.action(ls_naughty, "Crush player (Invisible)", {"crush4"}, "crush but with clown van", function(on_click)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        coords = ENTITY.GET_ENTITY_COORDS(target_ped, false)
        coords.x = coords['x']
        coords.y = coords['y']
        coords.z = coords['z'] + 20.0
        request_model_load(1917016601)
        local truck = entities.create_vehicle(1917016601, coords, 0.0)
        local vel = ENTITY.GET_ENTITY_VELOCITY(vel)
        ENTITY.SET_ENTITY_VELOCITY(truck, vel['x'], vel['y'], -200.0)
		VEHICLE.SET_VEHICLE_DOORS_LOCKED(truck, 3)
		ENTITY.SET_ENTITY_VISIBLE(truck, false, 0)
		VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_NON_SCRIPT_PLAYERS(truck, true)
		wait(2000)
		entities.delete_by_handle(truck)
    end)

	 menu.action(ls_naughty, "Crush player (Invisible Faggio)", {"crush5"}, "Spawns a Faggio to crush them in case your target is standing next to a light pole or other situations where the truck would miss.", function(on_click)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        coords = ENTITY.GET_ENTITY_COORDS(target_ped, false)
        coords.x = coords['x']
        coords.y = coords['y']
        coords.z = coords['z'] + 20.0
        request_model_load(util.joaat("faggio2"))
        local truck = entities.create_vehicle(util.joaat("faggio2"), coords, 0.0)
        local vel = ENTITY.GET_ENTITY_VELOCITY(vel)
        ENTITY.SET_ENTITY_VELOCITY(truck, vel['x'], vel['y'], -200.0)
		VEHICLE.SET_VEHICLE_DOORS_LOCKED(truck, 3)
		ENTITY.SET_ENTITY_VISIBLE(truck, false, 0)
		VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_NON_SCRIPT_PLAYERS(truck, true)
		wait(2000)
		entities.delete_by_handle(truck)
    end)
	

    menu.action(spawnvehicle_root, "Space docker", {"givespacedocker"}, "beep boop", function(on_click)
        give_vehicle(pid, util.joaat("dune2"))
    end)

    menu.action(spawnvehicle_root, "Clown van", {"giveclownvan"}, "what you are", function(on_click)
        give_vehicle(pid, util.joaat("speedo2"))
    end)

    menu.action(spawnvehicle_root, "Krieger", {"apkrieger"}, "its fast lol", function(on_click)
        give_vehicle(pid, util.joaat("krieger"))
			if vehv == on then
				VEHICLE.MODIFY_VEHICLE_TOP_SPEED(pid, 200)
			end
    end)
    
    menu.action(spawnvehicle_root, "Kuruma", {"apkuruma"}, "the 12 year old\'s dream", function(on_click)
        give_vehicle(pid, util.joaat("kuruma"))
    end)
    
    menu.action(spawnvehicle_root, "Insurgent", {"apinsurgent"}, "the 10 year old\'s dream", function(on_click)
        give_vehicle(pid, util.joaat("insurgent"))
    end)
    
    menu.action(spawnvehicle_root, "Neon", {"apneon"}, "electric car underrated and go brrt", function(on_click)
        give_vehicle(pid, util.joaat("neon"))
    end)
    
    menu.action(spawnvehicle_root, "Akula", {"apakula"}, "a good heli", function(on_click)
        give_vehicle(pid, util.joaat("akula"))
    end)
    
    menu.action(spawnvehicle_root, "Alpha Z-1", {"apakula"}, "super fucking fast plane lol", function(on_click)
        give_vehicle(pid, util.joaat("alphaz1"))
    end)
    
    menu.action(spawnvehicle_root, "Rogue", {"aprogue"}, "good attak plane", function(on_click)
        give_vehicle(pid, util.joaat("rogue"))
    end)
	
    menu.action(spawnvehicle_root, "Oppressor MkII", {"oppressor2"}, "Aids Mobile", function(on_click)
        give_vehicle(pid, util.joaat("oppressor2"))
    end)
	
	menu.action(spawnvehicle_root, "Lazer", {"Lazer"}, "The PVPers Choice", function(on_click)
        give_vehicle(pid, util.joaat("lazer"))
    end)
	
	menu.action(spawnvehicle_root, "Hydra", {"Hydra"}, "The broke nigga choice", function(on_click)
        give_vehicle(pid, util.joaat("hydra"))
	end)
	
	menu.action(spawnvehicle_root, "Br8", {"openwheel1"}, "Fastest F1 car", function(on_click)
        give_vehicle(pid, util.joaat("openwheel1"))
	end)
	
	menu.action(spawnvehicle_root, "Veto Modern", {"veto2"}, "its just a go kart idfk", function(on_click)
        give_vehicle(pid, util.joaat("veto2"))
			if vehv == on then -- unused, wouldnt work if you tried to get it to work
				VEHICLE.MODIFY_VEHICLE_TOP_SPEED(util.joaat, 200)
			end
	end)
	
	menu.action(spawnvehicle_root, "Sparrow", {"seasparrow2"}, "Cayo Heli", function(on_click)
        give_vehicle(pid, util.joaat("seasparrow2"))
	end)
	
    menu.action(spawnvehicle_root, "Input custom vehicle name", {"givecarinput"}, "Input a custom vehicle name to spawn (the NAME, NOT HASH)", function(on_click)
        util.toast("Please type the vehicle name")
        menu.show_command_box("givecarinput" .. PLAYER.GET_PLAYER_NAME(pid) .. " ")
    end, function(on_command)
        give_vehicle(pid, util.joaat(on_command))
    end)

    --AUDIO.PLAY_PED_RINGTONE("Dial_and_Remote_Ring", ped, true)
    menu.action(ls_neutral, "Chauffeur: Drive to player", {"chtoplayer"}, "Commands your chauffeur to go to the player. HE WILL GET THERE, WHATEVER IT TAKES. This includes going the wrong way, hitting peds, etc.", function(on_click)
        if taxi_ped == 0 then
            util.toast("Create a chauffeur before doing this.")
            return
        end
        local target = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        --local goto_coords = ENTITY.GET_ENTITY_COORDS()
        TASK.TASK_VEHICLE_CHASE(taxi_ped, target)
        --TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(taxi_ped, taxi_veh, goto_coords['x'], goto_coords['y'], goto_coords['z'], 300.0, 786996, 5)
    end)
    
    menu.toggle(ram_root, "Set on ground", {"ramonground"}, "Leave off if the user is flying aircraft", function(on)
        ram_onground = on
    end, true)
	
	 menu.action(ram_root, "Howard", {"ramhoward"}, "brrt", function(on_click)
        ram_ped_with(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), -1007528109, 10.0, true)
    end)
	
    menu.action(ram_root, "Rally truck", {"ramtruck"}, "vroom", function(on_click)
        ram_ped_with(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), -2103821244, 10.0, false)
    end)

    menu.action(ram_root, "Cargo plane", {"ramcargo"}, "some menus might have this blocked lol", function(on_click)
        ram_ped_with(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), 368211810, 15.0, false)
    end)

    menu.action(ram_root, "Phantom wedge", {"ramwedge"}, "they fly", function(on_click)
        ram_ped_with(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), -1649536104, 15.0, false)
    end)
		

    menu.action(explosions_root, "Fire jet", {"firejet"}, "one of the classic trolls", function(on_click)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local coords = ENTITY.GET_ENTITY_COORDS(target_ped, false)
        FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], 12, 100.0, true, false, 0.0)
    end)

    menu.toggle(ls_naughty, "Vehicle limp", {"vehiclelimp"}, "Makes the player\'s vehicle \"limp\" by creating a fight for entity ownership of it between you and the player. May raise red flags on some menus.", function(on)
        if on then
            freezeloop = true
            freezetar = pid
        else
            freezeloop = false
        end
    end)

    menu.toggle(explosions_root, "Fire jet loop", {"firejetloop"}, "For if someone REALLY pisses you off, x2", function(on)
        if on then
            firejetloop = true
            firejettar = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        else
            firejetloop = false
        end
    end)


    menu.action(explosions_root, "Water jet", {"waterjet"}, "one of the classic trolls", function(on_click)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local coords = ENTITY.GET_ENTITY_COORDS(target_ped, false)
        FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], 13, 100.0, true, false, 0.0)
    end)

    menu.toggle(explosions_root, "Water jet loop", {"waterjetloop"}, "One of the classic trolls, x2", function(on)
        if on then
            waterjetloop = true
            waterjettar = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        else
            waterjetloop = false
        end
    end)

    menu.toggle(plpedmoney_root, "Set as ped money target", {"setpedmoneytar"}, "", function(off)
        if on then
            pedmoney_tar = pid
            menu.trigger_commands("pedmoney off")
        else
            pedmoney_tar = players.user()
        end
    end, false)

    menu.toggle(ls_naughty, "Earrape: Explosions", {"earrape"}, "Be evil.", function(on)
        if on then
            earrape = true
            earrape_target = pid
        else
            earrape = false
        end
    end, false)

    menu.action(ls_naughty, "Chop up", {"chopup"}, "Makes chop suey of the player with helicopter blades. Works best if your player is nearby.", function(on_click)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local coords = ENTITY.GET_ENTITY_COORDS(target_ped, false)
        coords.x = coords['x']
        coords.y = coords['y']
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

    menu.toggle(ls_naughty, "Blackhole target", {"bhtarget"}, "A really toxic thing to do but you should do it anyways because it\'s fun. Obviously requires blackhole to be on.", function(on)
        if on then
            if not blackhole then
                blackhole = true
                menu.trigger_commands("blackhole on")
            end
            bh_target = pid
        else
            bh_target = -1
            if blackhole then
                blackhole = false
                menu.trigger_commands("blackhole off")
            end
        end
    end, false)


-------------------------------------------------------------
--functions needed to make hostile traffic work (from wiriscript) (some stuff may be useless here)
-------------------------------------------------------------

function GET_NEARBY_ENTITIES(pid, radius) --returns nearby peds and vehicles given player Id
	local peds = GET_NEARBY_PEDS(pid, radius)
	local vehicles = GET_NEARBY_VEHICLES(pid, radius)
	local entities = peds
	for i = 1, #vehicles do table.insert(entities, vehicles[i]) end
	return entities
end

function GET_NEARBY_VEHICLES(pid, radius) --returns a list of nearby vehicles given player Id
	local vehicles = {}
	local p = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
	local pos = ENTITY.GET_ENTITY_COORDS(p)
	local v = PED.GET_VEHICLE_PED_IS_IN(p, false)
	for k, vehicle in pairs(entities.get_all_vehicles_as_handles()) do 
		local veh_pos = ENTITY.GET_ENTITY_COORDS(vehicle)
		if vehicle ~= v and vect.dist(pos, veh_pos) <= radius then table.insert(vehicles, vehicle) end
	end
	return vehicles
end

function GET_NEARBY_PEDS(pid, radius) --returns a list of nearby peds given player Id
	local peds = {}
	local p = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
	local pos = ENTITY.GET_ENTITY_COORDS(p)
	for k, ped in pairs(entities.get_all_peds_as_handles()) do
		if ped ~= p then
			local ped_pos = ENTITY.GET_ENTITY_COORDS(ped)
			if vect.dist(pos, ped_pos) <= radius then table.insert(peds, ped) end
		end
	end
	return peds
end

function random(t) --returns a random value from table
	local list = {}
	for k, value in pairs(t) do table.insert(list, value) end
	return list[math.random(1, #list)]
end

function table.find(t, value)
	for k, v in pairs(t) do
		if v == value then
			return true
		end
	end
	return false
end

if loaded_config then
	for s, table in pairs(loaded_config) do
		for k, v in pairs(table) do
			if config[s] and config[s][k] ~= nil then
				config[s][k] = v
			end
		end
	end
end


vect = {
	['new'] = function(x, y, z)
		return {['x'] = x, ['y'] = y, ['z'] = z}
	end,
	['subtract'] = function(a, b)
		return vect.new(a.x-b.x, a.y-b.y, a.z-b.z)
	end,
	['add'] = function(a, b)
		return vect.new(a.x+b.x, a.y+b.y, a.z+b.z)
	end,
	['mag'] = function(a)
		return math.sqrt(a.x^2 + a.y^2 + a.z^2)
	end,
	['norm'] = function(a)
		local mag = vect.mag(a)
		return vect.div(a, mag)
	end,
	['mult'] = function(a, b)
		return vect.new(a.x*b, a.y*b, a.z*b)
	end, 
	['div'] = function(a, b)
		return vect.new(a.x/b, a.y/b, a.z/b)
	end, 
	['dist'] = function(a, b) --returns the distance between two vectors
		return vect.mag(vect.subtract(a, b) )
	end
}

function REQUEST_CONTROL_LOOP(entity)
	local tick = 0
	while not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity) and tick < 25 do
		wait()
		NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
		tick = tick + 1
	end
	if NETWORK.NETWORK_IS_SESSION_STARTED() then
		local netId = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(entity)
		NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
		NETWORK.SET_NETWORK_ID_CAN_MIGRATE(netId, true)
	end
end

wait = util.yield

------------------------------------------------------------------------------------------------------------------------------------
-- END HOSTILE PEDS CODE
------------------------------------------------------------------------------------------------------------------------------------

    menu.action(attackers_root, "Dog attack", {"dogatk"}, "arf uwu", function(on_click)
        send_attacker(-1788665315, pid, false)
    end)

    menu.action(attackers_root, "Mountain lion attack", {"cougaratk"}, "there aren't cougars in missions, or my sex life :sadge:", function(on_click)
        send_attacker(307287994, pid, false)
    end)

    menu.action(attackers_root, "Brad attack", {"bradatk"}, "scary", function(on_click)
        send_attacker(util.joaat("CS_BradCadaver"), pid, false)
    end)
	

    --WEAPON.GIVE_WEAPON_TO_PED(ped, 453432689, 0, false, true)

    --ATTACH_VEHICLE_TO_TOW_TRUCK(Vehicle towTruck, Vehicle vehicle, BOOL rear, float hookOffsetX, float hookOffsetY, float hookOffsetZ)
    menu.action(npctrolls_root, "Tow last car", {"towtruck"}, "They didn\'t pay their lease.", function(on_click)
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
            if towfrombehind then
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

    
    menu.toggle(npctrolls_root, "Tow from behind", {"towbehind"}, "Toggle on if the front of the car is blocked", function(on)
        towfrombehind = on
    end)

    menu.action(npctrolls_root, "Cat explosion", {"meow"}, "UWU", function(on_click)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local coords = ENTITY.GET_ENTITY_COORDS(target_ped, false)
        coords.x = coords['x']
        coords.y = coords['y']
        coords.z = coords['z']
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

    menu.action(attackers_root, "Send griefer Jesus", {"sendgrieferjesus"}, "Spawns an invincible Jesus with a railgun that will constantly attack the player, even after they die, teleporting to them if they are too far away. This tends to be super glitchy sometimes, but it\'s usually due to networking.", function(on_click)
        dispatch_griefer_jesus(pid)
    end)
	
	 menu.action(attackers_root, "Send killable griefer Jesus", {"sendgrieferjesus2"}, "Same option as the one above except not god mode. Might kill itself on accident. Bit of a trash option but I found the other to be too toxic.", function(on_click)
        dispatch_griefer_jesus2(pid)
    end)

    menu.action(attackers_root, "Send jets", {"sendjets"}, "We don\'t charge $140 for this extremely basic feature. However the jets will only target the player until the player dies, otherwise we would need another thread, and I don\'t want to make one.", function(on_click)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(target_ped, 1.0, 0.0, 500.0)
        coords.x = coords['x']
        coords.y = coords['y']
        coords.z = coords['z']
        local hash = util.joaat("lazer")
        request_model_load(hash)
        request_model_load(-163714847)
        for i=1, num_attackers do
            coords.x = coords.x + i*2
            coords.y = coords.y + i*2
            local jet = entities.create_vehicle(hash, coords, 0.0)
            VEHICLE.CONTROL_LANDING_GEAR(jet, 3)
            VEHICLE.SET_HELI_BLADES_FULL_SPEED(jet)
            VEHICLE.SET_VEHICLE_FORWARD_SPEED(jet, VEHICLE.GET_VEHICLE_ESTIMATED_MAX_SPEED(jet))
            if godmodeatk then
                ENTITY.SET_ENTITY_INVINCIBLE(jet, true)
            end
            local pilot = entities.create_ped(28, -163714847, coords, 30.0)
            PED.SET_PED_COMBAT_ATTRIBUTES(pilot, 5, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(pilot, 46, true)
            PED.SET_PED_INTO_VEHICLE(pilot, jet, -1)
            TASK.TASK_PLANE_MISSION(pilot, jet, 0, target_ped, 0, 0, 0, 6, 0.0, 0, 0.0, 50.0, 40.0)
            TASK.TASK_COMBAT_PED(pilot, target_ped, 0, 16)
            PED.SET_PED_ACCURACY(pilot, 100.0)
            PED.SET_PED_COMBAT_ABILITY(pilot, 2)
        end
    end)
    
    menu.action(attackers_root, "Send A10s", {"senda10s"}, "literally just a model swap of the send jets why would u want this", function(on_click)
        send_aircraft_attacker(1692272545, -163714847, pid)
    end)

    menu.action(attackers_root, "Send cargo planes", {"sendcargoplanes"}, "it doesnt have guns but you know, whatever. also the back is forced open so u can land in it lol", function(on_click)
        send_aircraft_attacker(util.joaat("cargoplane"), -163714847, pid)
    end)


    menu.action(entspam_root, "Traffic cones", {"conespam"}, "Spams traffic cones", function(on_click)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        spam_entity_on_player(target_ped, 3760607069)
    end)

    menu.action(entspam_root, "Dildo", {"dildospam"}, ":flushed:", function(on_click)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        spam_entity_on_player(target_ped, 3872089630)
    end)

    menu.action(entspam_root, "Hot dog", {"hotdogspam"}, "a dog thats hot", function(on_click)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        spam_entity_on_player(target_ped, 2565741261)
    end)

    menu.action(entspam_root, "Hot dog STAND", {"hotdogstandspam"}, "You know why I capitalized what I did.", function(on_click)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        spam_entity_on_player(target_ped, 2713464726)
    end)

    menu.action(entspam_root, "Ferris wheel", {"ferriswheelspam"}, "BE CAREFUL", function(on_click)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        spam_entity_on_player(target_ped, 3291218330)
    end)

    menu.action(entspam_root, "Rollercoaster car", {"rollerspam"}, "fun times", function(on_click)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        spam_entity_on_player(target_ped, 3413442113)
    end)

    menu.action(entspam_root, "Air radar", {"radarspam"}, "they spin", function(on_click)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        spam_entity_on_player(target_ped, 2306058344)
    end)

    menu.action(entspam_root, "Custom entity", {"customentityspam"}, "Inputs a custom entity. Try not to input invalid hashes, but the requester function is smart and should be fine if you do.", function(on_click)
        util.toast("Please input the model hash")
        menu.show_command_box("customentityspam" .. PLAYER.GET_PLAYER_NAME(pid) .. " ")
    end, function(on_command)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        spam_entity_on_player(target_ped, util.joaat(on_command))
    end)

    menu.toggle(entspam_root, "Entities have gravity", {"entitygrav"}, "", function(on)
        entity_grav = on
    end, true)

    menu.slider(entspam_root, "Number of entities", {"entspamnum"}, "Number of ents to spam.", 1, 30, 30, 10, function(s)
        num_of_spam = s
    end)

    menu.action(objecttrolls_root, "Ramp in front of player", {"ramp"}, "Spawns a ramp right in front of the player. Most nicely used when they are in a car.", function(on_click)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local hash = 2282807134
        request_model_load(hash)
        local ramp = spawn_object_in_front_of_ped(target_ped, hash, 90, 50.0, -1, true)
        local c = ENTITY.GET_ENTITY_COORDS(ramp, true)
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ramp, c['x'], c['y'], c['z']-0.2, false, false, false)
    end)

    menu.action(objecttrolls_root, "Barrier in front of player", {"barrier"}, "Spawns a *frozen* barrier right in front of the player. Good for causing accidents.", function(on_click)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local hash = 3729169359
        local obj = spawn_object_in_front_of_ped(target_ped, hash, 0, 5.0, -0.5, false)
        ENTITY.FREEZE_ENTITY_POSITION(obj, true)
    end)

    menu.action(objecttrolls_root, "Windmill player", {"windmill"}, "gotem.", function(on_click)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local hash = 1952396163
        local obj = spawn_object_in_front_of_ped(target_ped, hash, 0, 5.0, -30, false)
        ENTITY.FREEZE_ENTITY_POSITION(obj, true)
    end)

    menu.action(objecttrolls_root, "Radar player", {"radar"}, "also gotem.", function(on_click)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local hash = 2306058344
        local obj = spawn_object_in_front_of_ped(target_ped, hash, 0, 0.0, -5.0, false)
        ENTITY.FREEZE_ENTITY_POSITION(obj, true)
    end)

    menu.action(ls_naughty, "Owned snipe", {"snipe"}, "Snipes the player with you as the attacker [Will not work if you do not have LOS with the target]", function(on_click)
        local owner = PLAYER.PLAYER_PED_ID()
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local target = ENTITY.GET_ENTITY_COORDS(target_ped)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(target['x'], target['y'], target['z'], target['x'], target['y'], target['z']+0.1, 300.0, true, 100416529, owner, true, false, 100.0)
    end)

    menu.action(ls_naughty, "Anon snipe", {"selfsnipe"}, "Snipes the player anonymously, as if a random ped did it [The randomly selected ped needs to have LOS, I think]", function(on_click)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local target = ENTITY.GET_ENTITY_COORDS(target_ped)
        local random_ped = get_random_ped()
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(target['x'], target['y'], target['z'], target['x'], target['y'], target['z']+0.1, 300.0, true, 100416529, random_ped, true, false, 100.0)
    end)

    menu.action(explosions_root, "Anon launch player", {"launchplayer"}, "launches them with the uhhh ray gun or whatever. also creates a VERY considerable amount of ear pain.", function(on_click)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local coords = ENTITY.GET_ENTITY_COORDS(target_ped)
        FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], 70, 1.0, true, false, 0.0)
    end)
    --741814745
    
    menu.toggle(explosions_root, "Anon launch player loop", {"launchplayerloop"}, "For if someone REALLY pisses you off", function(on)
        if on then
            launchloop = true
            launchtar = pid
        else
            launchloop = false
        end
    end)

    menu.toggle(explosions_root, "Low FPS", {"lowfps"}, "Gives the player shit FPS. The slower they are moving the better. Not very effective if the player dies and respawns, so best used on other modders with godmode.", function(on)
        if on then
            lowfps = true
            lowfpstar = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        else
            lowfps = false
        end
    end)

    menu.slider(explosions_root, "Custom explosion", {"customexploslider"}, "The custom explosion enum to use.", 0, 82, 0, 1, function(s)
        customexplosion = s
      end)

    menu.toggle(explosions_root, "Custom explosion loop", {"customexplosions"}, "", function(on)
        if on then
            customexplo = true
            customexplosiontar = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        else
            customexplo = false
        end
    end)

    menu.action(ls_naughty, "Drop anon stickybomb", {"anonsticky"}, "Stubborn, but works when it works.", function(on_click)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local target = ENTITY.GET_ENTITY_COORDS(target_ped)
        local random_ped = get_random_ped()
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(target['x'], target['y'], target['z'], target['x'], target['y'], target['z']-1.0, 300.0, true, 741814745, random_ped, true, false, 100.0)
    end)

    --SET_VEHICLE_WHEEL_HEALTH(Vehicle vehicle, int wheelIndex, float health)
    menu.action(ls_naughty, "Cage", {"lscage"}, "Basic cage option. Cause you cant handle yourself. We are a little more ethical here at Lance Studios though, so the cage has some wiggle room (our special cage model also means that like, no menu blocks the model).", function(on_click)
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local coords = ENTITY.GET_ENTITY_COORDS(ped, true)
        coords.x = coords['x']
        coords.y = coords['y']
        coords.z = coords['z']
        local hash = 779277682
        request_model_load(hash)
        local cage1 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, coords['x'], coords['y'], coords['z'], true, false, false)
        ENTITY.SET_ENTITY_ROTATION(cage1, 0.0, -90.0, 0.0, 1, true)
        local cage2 = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, coords['x'], coords['y'], coords['z'], true, false, false)
        ENTITY.SET_ENTITY_ROTATION(cage2, 0.0, 90.0, 0.0, 1, true)
    end)

    menu.action(ls_naughty, "Delete vehicle", {"deleteveh"}, "delete the vehicle they\'re in lol", function(on_click)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
        entities.delete_by_handle(car)
    end)

    menu.action(ls_naughty, "Cargo plane trap", {"cargoplanetrap"}, "Traps the player in a cargo plane.", function(on_click)
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        -- TODO: fine tune this
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 0.0, 0.0)
        coords.x = coords['x']
        coords.y = coords['y']
        coords.z = coords['z']
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
    
    menu.action(npctrolls_root, "NPC jack last car v3.0", {"npcjack"}, "Sends an NPC to steal their car.", function(on_click)
        npc_jack(pid, false)
    end)

function SET_ENT_FACE_ENT(ent1, ent2) 
	local a = ENTITY.GET_ENTITY_COORDS(ent1)
	local b = ENTITY.GET_ENTITY_COORDS(ent2)
	local dx = b.x - a.x
	local dy = b.y - a.y
	local heading = MISC.GET_HEADING_FROM_VECTOR_2D(dx, dy)
	return ENTITY.SET_ENTITY_HEADING(ent1, heading)
end

    menu.action(attackers_root, "Bri'ish mode", {"british"}, "God save the queen.", function(on_click)
        local hash = 0x9C9EFFD8
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        request_model_load(hash)
        request_model_load(util.joaat("prop_flag_uk"))
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 0.0, 0.0, 0.0)
        for i=1, 5 do
            coords.x = coords['x']
            coords.y = coords['y']
            coords.z = coords['z']
            local ped = entities.create_ped(28, hash, coords, 30.0)
            local obj = OBJECT.CREATE_OBJECT_NO_OFFSET(util.joaat("prop_flag_uk"), coords['x'], coords['y'], coords['z'], true, false, false)
            ENTITY.ATTACH_ENTITY_TO_ENTITY(obj, ped, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, true, false, 0, true)
            PED.SET_PED_AS_ENEMY(ped, true)
            PED.SET_PED_FLEE_ATTRIBUTES(ped, 0, false)
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true)
			PED.SET_PED_CAN_RAGDOLL(ped, false)
			PED.SET_PED_MAX_HEALTH(ped, 2000)
			PED.SET_PED_AS_COP(ped, true)
			PED.SET_PED_HEARING_RANGE(ped, 99999)
			ENTITY.SET_ENTITY_HEALTH(ped, 2000)
			ENTITY.SET_ENTITY_MAX_SPEED(ped, 1000)
            WEAPON.GIVE_WEAPON_TO_PED(ped, -1834847097, 0, false, true)
            TASK.TASK_COMBAT_PED(ped, player_ped, 0, 16)
			PED.SET_AI_MELEE_WEAPON_DAMAGE_MODIFIER(ped, 1)
			PED.SET_PED_SUFFERS_CRITICAL_HITS(ped, false)
        end
    end)


	    menu.action(attackers_root, "Dr. Dre Ambush", {"drebush"}, "get clapped by Dre", function(on_click)
        local hash = 0xCF0C7037
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
		request_model_load(hash)
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, math.random(-10, 10),  math.random(-10, 10), 0.0)
        coords.x = coords['x']
        coords.y = coords['y']
        coords.z = coords['z']
        for i=1, 5 do
            coords.x = coords['x']
            coords.y = coords['y']
            coords.z = coords['z']
            local ped = entities.create_ped(28, hash, coords, 30.0)
            PED.SET_PED_AS_ENEMY(ped, true)
            PED.SET_PED_FLEE_ATTRIBUTES(ped, 0, false)
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true)
			PED.SET_PED_CAN_RAGDOLL(ped, false)
            WEAPON.GIVE_WEAPON_TO_PED(ped, -1357824103, 0, false, true)
            TASK.TASK_COMBAT_PED(ped, player_ped, 0, 16)
			PED.SET_PED_ACCURACY(ped, 100.0)
			PED.SET_PED_AS_COP(ped, true)
			PED.SET_PED_HEARING_RANGE(ped, 99999)
			PED.SET_PED_MAX_HEALTH(ped, 250)
			ENTITY.SET_ENTITY_HEALTH(ped, 250)
			PED.SET_PED_SHOOT_RATE(ped, 5)
			PED.SET_PED_SUFFERS_CRITICAL_HITS(ped, false)
			ENTITY.SET_ENTITY_PROOFS(ped, false, true, false, false, true, false, false, false)
			PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(driver, true)
			if d then -- unused
				PED.SET_AI_WEAPON_DAMAGE_MODIFIER(ped, 30000)
			end
        end
    end)

    menu.action(npctrolls_root, "Tell nearby peds to arrest", {"arrest"}, "Tells nearby peds to arrest the player. Obviously there is no arrest mechanic in GTA:O. So they don\'t actually arrest. But they will try.", function(on_click)
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local all_peds = entities.get_all_peds_as_handles()
        for k, ped in pairs(all_peds) do
            if not is_ped_player(ped) then
                request_control_of_entity(ped)
                PED.SET_PED_AS_COP(ped, true)
				PED.SET_PED_CAN_RAGDOLL(ped, false)
                PED.SET_PED_FLEE_ATTRIBUTES(ped, 0, false)
                PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true)
                WEAPON.GIVE_WEAPON_TO_PED(ped, 453432689, 0, false, true)
                TASK.TASK_ARREST_PED(ped, player_ped)
            end
        end
    end)
	
	menu.toggle(npctrolls_root, "Nearby peds combat player", {"combat"}, "Tells nearby peds to combat the player.", function(on)
        combat_tar = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        if on then
            aped_combat = true
            mod_uses("ped", 1)
        else
            aped_combat = false
            mod_uses("ped", -1)
        end
    end)
	
		menu.toggle(npctrolls_root, "Kill order to all peds", {"combat2"}, "Arms nearby peds, improves their aim and tells them to kill the player.", function(on)
        combat_tar = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        if on then
            aped_combat2 = true
            mod_uses("ped", 1)
        else
            aped_combat2 = false
            mod_uses("ped", -1)
        end
    end)
	

		menu.toggle_loop(cop_root, "Cracked Cops", {"combat3"}, "Makes police spawned by the game super cracked, increasing their accuracy and combat ability, as well as making their vehicle faster. There is a 0.5 second delay added to this loop due to npcs straight up not shooting with slower/ no delays in the loop.", function(on)
		local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
		local pos = ENTITY.GET_ENTITY_COORDS(player_ped)
		for _, ped in ipairs(GET_NEARBY_PEDS(pid, 250)) do
		local pt = PED.GET_PED_TYPE(ped)
			if not PED.IS_PED_A_PLAYER(ped) and not PED.IS_PED_HURT(ped) then
				if pt == 6 or pt == 27 then -- 6 is police, 27 is swat
					REQUEST_CONTROL_LOOP(ped)
					PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true)
					PED.SET_PED_COMBAT_ATTRIBUTES(ped, 2, true)
					PED.SET_PED_FLEE_ATTRIBUTES(ped, 512, false)
					PED.SET_PED_CAN_RAGDOLL(ped, false)
					PED.SET_PED_SUFFERS_CRITICAL_HITS(ped, false)
					WEAPON.GIVE_WEAPON_TO_PED(ped, -2084633992 , 9999, false, true)
					WEAPON.SET_PED_DROPS_WEAPONS_WHEN_DEAD(ped, false)
					PED.SET_PED_KEEP_TASK(ped, true)
					PED.SET_PED_SHOOT_RATE(ped, 3)
					ENTITY.SET_ENTITY_PROOFS(ped, false, true, false, false, true, false, false, false)
					WEAPON.SET_PED_INFINITE_AMMO_CLIP(ped, true)
					ENTITY.SET_ENTITY_HEALTH(ped, 250)
					PED.SET_PED_MAX_HEALTH(ped, 250)
					if PED.IS_PED_IN_ANY_VEHICLE(target_ped, true) then
						local veh = PED.GET_VEHICLE_PED_IS_IN(target_ped, false)
						VEHICLE.MODIFY_VEHICLE_TOP_SPEED(veh, 80)
						TASK.TASK_VEHICLE_CHASE(ped, player_ped)
						WEAPON.GIVE_WEAPON_TO_PED(ped, 584646201 , 9999, false, true)
						if godmodeatk then
							ENTITY.SET_ENTITY_INVINCIBLE(veh, true)
						end
						if pcar then
							PED.SET_PED_COMBAT_ATTRIBUTES(ped, 3, false)
						end
					else
						WEAPON.GIVE_WEAPON_TO_PED(ped, -2084633992 , 9999, false, true)
						TASK.TASK_COMBAT_PED(ped, player_ped, 0, 16)
						end
					wait(500)
				end
			end
		end
	end)
	

		menu.toggle_loop(cop_root, "Insane Cops", {"combat4"}, "Makes police spawned by the game and npcs from the attackers tab extremely powerful and deadly without making them invulnerable. Makes their vehicle invulnerable. Basically just cracked cops copied but with a damage multiplier.", function(on)
		local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
		local pos = ENTITY.GET_ENTITY_COORDS(player_ped)
		for _, ped in ipairs(GET_NEARBY_PEDS(pid, 250)) do
		local pt = PED.GET_PED_TYPE(ped)
			if not PED.IS_PED_A_PLAYER(ped) and not PED.IS_PED_HURT(ped) then
				if pt == 6 or pt == 27 then -- 6 is police, 27 is swat
					REQUEST_CONTROL_LOOP(ped)
					PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true)
					PED.SET_PED_COMBAT_ATTRIBUTES(ped, 2, true)
					PED.SET_PED_FLEE_ATTRIBUTES(ped, 512, false)
					PED.SET_PED_CAN_RAGDOLL(ped, false)
					PED.SET_PED_SUFFERS_CRITICAL_HITS(ped, false)
					WEAPON.GIVE_WEAPON_TO_PED(ped, -2084633992 , 9999, false, true)
					WEAPON.SET_PED_DROPS_WEAPONS_WHEN_DEAD(ped, false)
					PED.SET_PED_KEEP_TASK(ped, true)
					PED.SET_PED_SHOOT_RATE(ped, 3)
					ENTITY.SET_ENTITY_PROOFS(ped, false, true, false, false, true, false, false, false)
					WEAPON.SET_PED_INFINITE_AMMO_CLIP(ped, true)
					PED.SET_AI_WEAPON_DAMAGE_MODIFIER(ped, 3000)
					ENTITY.SET_ENTITY_HEALTH(ped, 250)
					PED.SET_PED_MAX_HEALTH(ped, 250)
					ENTITY.SET_ENTITY_INVINCIBLE(veh, true)
					if PED.IS_PED_IN_ANY_VEHICLE(ped, true) then
						local veh = PED.GET_VEHICLE_PED_IS_IN(ped, false)
						VEHICLE.MODIFY_VEHICLE_TOP_SPEED(veh, 50)
						TASK.TASK_VEHICLE_CHASE(ped, player_ped)
						WEAPON.GIVE_WEAPON_TO_PED(ped, 584646201 , 9999, false, true)
						if pcar then
							PED.SET_PED_COMBAT_ATTRIBUTES(ped, 3, false)
						end
					else
						WEAPON.GIVE_WEAPON_TO_PED(ped, -2084633992 , 9999, false, true)
						TASK.TASK_COMBAT_PED(ped, player_ped, 0, 16)
					wait(500)
					end
				end
			end
		end
	end)

	
		menu.toggle_loop(cop_root, "Always Aggro Cops", {"copmagnet"}, "Player always aggros cops even after death. Works with attackers from the attackers tab as well. Might (probably doesn't) break other stuff. (probably) Must be spectating or near the player for this to work. (havent tested if this is true lol)", function(on)
		local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid) -- gets the player 
		local pos = ENTITY.GET_ENTITY_COORDS(player_ped) -- gets the players coords, defines it as "pos"
		for _, ped in ipairs(GET_NEARBY_PEDS(pid, 2500)) do -- executes everything under this line for all peds 900 units from the player
		local pt = PED.GET_PED_TYPE(ped) -- gets the types of peds in this area
			if not PED.IS_PED_A_PLAYER(ped) then  -- if the ped is not a player, execute everything under this line
				if pt == 6 or pt == 27 then -- if the ped type is 6 or 27, execute everything under this line. 6 is police, 27 is swat
					REQUEST_CONTROL_LOOP(ped) -- requests control
					TASK.TASK_COMBAT_PED(ped, player_ped, 0, 0) --makes them fight the target
				end
			end
		wait(30)
		end
	end)



	menu.action(cop_root, "3 Star Wanted Level", {"threestar"}, "not a loop because technical reasons. Might not work so try spamming it I guess. Ill fix this when I get a chance.", function()
		local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid))
		
		local p = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
		local pedHash = util.joaat("s_m_y_cop_01")
		local cop = entities.create_ped(6, pedHash, ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(p, 0, 0, -90), CAM.GET_GAMEPLAY_CAM_ROT(0).z)
		FIRE.ADD_OWNED_EXPLOSION(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), pos.x, pos.y, pos.z-90, 0, 10, false, false, 0)
		ENTITY.SET_ENTITY_VISIBLE(cop, false, 0)
		wait(500)
		entities.delete_by_handle(cop)
	end)
	

	menu.toggle_loop(broken_root, "High Grip Cops", {"stick"}, "", function(on)
		local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
		local pos = ENTITY.GET_ENTITY_COORDS(player_ped)
		for _, ped in ipairs(GET_NEARBY_PEDS(pid, 250)) do
		local pt = PED.GET_PED_TYPE(ped)
			if not PED.IS_PED_A_PLAYER(ped) then
				if pt == 6 or pt == 27 then -- 6 is police, 27 is swat
					local veh = PED.GET_VEHICLE_PED_IS_IN(ped, false)
					local vel = ENTITY.GET_ENTITY_VELOCITY(veh)
					vel['z'] = -vel['z'] --is this even needed?
					ENTITY.APPLY_FORCE_TO_ENTITY(veh, 2, 0, 0, -50 -vel['z'], 0, 0, 0, 0, true, false, true, false, true)
					--ENTITY.SET_ENTITY_VELOCITY(player_cur_car, vel['x'], vel['y'], -0.2)
				end
			end
		end
	end)



		menu.action(npctrolls_root, "Delete Attackers", {"atkyeet"}, "deletes attackers as well as any police or noose units near the player.", function(on_click)
		local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid) 
		local pos = ENTITY.GET_ENTITY_COORDS(player_ped)
		for _, ped in ipairs(GET_NEARBY_PEDS(pid, 2500)) do
		local pt = PED.GET_PED_TYPE(ped)
			if not PED.IS_PED_A_PLAYER(ped) then  
				if pt == 6 or pt == 27 then -- 
					entities.delete_by_handle(ped)
				end
			end
		end
	end)

		menu.action(npctrolls_root, "Delete Attackers (alt)", {"atkyeet2"}, "try this if the other one doesnt work", function(on_click)
		local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid) 
		local pos = ENTITY.GET_ENTITY_COORDS(player_ped)
		for _, ped in ipairs(GET_NEARBY_PEDS(pid, 2500)) do
		local pt = PED.GET_PED_TYPE(ped)
			if not PED.IS_PED_A_PLAYER(ped) then  
				if pt == 6 or pt == 27 or pt == 1 then -- 
					entities.delete_by_handle(ped)
				end
			end
		end
	end)

		menu.action(cop_root, "Delete Cops", {"atkyeet"}, "deletes any police or noose units near the player, as well as attackers spawned by you.", function(on_click)
		local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid) 
		local pos = ENTITY.GET_ENTITY_COORDS(player_ped)
		for _, ped in ipairs(GET_NEARBY_PEDS(pid, 2500)) do
		local pt = PED.GET_PED_TYPE(ped)
			if not PED.IS_PED_A_PLAYER(ped) then  
				if pt == 6 or pt == 27 then -- 
					entities.delete_by_handle(ped)
				end
			end
		end
	end)

	
		menu.toggle_loop(broken_root, "Police Asswhooping", {"polwh"}, "", function(on_click)
		local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid) 
		local pos = ENTITY.GET_ENTITY_COORDS(player_ped)
		for _, ped in ipairs(GET_NEARBY_PEDS(pid, 2500)) do
		local pt = PED.GET_PED_TYPE(ped)
			if not PED.IS_PED_A_PLAYER(ped) then  
				if pt == 6 or pt == 27 then -- 
					if ENTITY.IS_ENTITY_DEAD(ped) then
						local iteration = 0
						local sod = PED.GET_PED_SOURCE_OF_DEATH(ped)
						if sod == player_ped then
							local iteration = iteration + 1
							wait(100)
							entities.delete_by_handle(ped)
						end
						if iteration == 3 then
							util.toast("police spawns")
							iteration = 0
						else
						break
						end
					else
					return
					end
				end
			end
		end
	end)


			menu.toggle_loop(vehatk_root, ('Hostile traffic'), {'hostiletraffic'}, 'All peds in vehicles near the player will maliciously run over or hit the player like a dumb low level. Press again to revive any peds that are dead in their vehicles (vehicle must be intact)(copied from wiriscript, now with increased range)', function()
		local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
		for k, vehicle in pairs(GET_NEARBY_VEHICLES(pid, 2050)) do	
			if not VEHICLE.IS_VEHICLE_SEAT_FREE(vehicle, -1) then
				local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1)
				if not PED.IS_PED_A_PLAYER(driver) then
					REQUEST_CONTROL_LOOP(driver)
					PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(driver, true)
					PED.SET_PED_MAX_HEALTH(driver, 300)
					ENTITY.SET_ENTITY_HEALTH(driver, 300)
					VEHICLE.MODIFY_VEHICLE_TOP_SPEED(vehicle, 40)
					TASK.CLEAR_PED_TASKS_IMMEDIATELY(driver)
					VEHICLE.MODIFY_VEHICLE_TOP_SPEED(vehicle, 50)
					PED.SET_PED_INTO_VEHICLE(driver, vehicle, -1)
					PED.SET_PED_COMBAT_ATTRIBUTES(driver, 46, true)
					TASK.TASK_COMBAT_PED(driver, player_ped, 0, 0)
					TASK.TASK_VEHICLE_MISSION_PED_TARGET(driver, vehicle, player_ped, 6, 100, 0, 0, 0, true)
					wait(10)
				end
			end
		end
	end)

			menu.toggle_loop(vehatk_root, ('Toxic traffic'), {'toxictraffic'}, 'Hostile traffic, but it speeds up the car, locks the door, makes the vehicles in range invulnerable, and makes the occupant invulnerable.(copied from wiriscript, now with increased range)', function()
		local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
		for k, vehicle in pairs(GET_NEARBY_VEHICLES(pid, 2000)) do	
			if not VEHICLE.IS_VEHICLE_SEAT_FREE(vehicle, -1) then
				local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1)
				if not PED.IS_PED_A_PLAYER(driver) then 
					REQUEST_CONTROL_LOOP(driver)
					PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(driver, true)
					PED.SET_PED_MAX_HEALTH(driver, 300)
					ENTITY.SET_ENTITY_INVINCIBLE(driver, true)
					ENTITY.SET_ENTITY_INVINCIBLE(vehicle, true)
					VEHICLE.MODIFY_VEHICLE_TOP_SPEED(vehicle, 50)
					VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle,-1, 3)
					TASK.CLEAR_PED_TASKS_IMMEDIATELY(driver)
					PED.SET_PED_INTO_VEHICLE(driver, vehicle, -1)
					PED.SET_PED_COMBAT_ATTRIBUTES(driver, 46, true)
					TASK.TASK_COMBAT_PED(driver, player_ped, 0, 0)
					TASK.TASK_VEHICLE_MISSION_PED_TARGET(driver, vehicle, player_ped, 6, 100, 0, 0, 0, true)
					wait(10)
				end
			end
		end
	end)

	menu.action(vehatk_root, ('Calm Down Traffic'), {'tcalm'}, 'does what it says. meant for hostile traffic options. Wont work if theyre on.', function()
	local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
	for k, vehicle in pairs(GET_NEARBY_VEHICLES(pid, 2050)) do	
		if not VEHICLE.IS_VEHICLE_SEAT_FREE(vehicle, -1) then
			local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1)
			if not PED.IS_PED_A_PLAYER(driver) then
					REQUEST_CONTROL_LOOP(driver)
					PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(driver, false)
					TASK.CLEAR_PED_TASKS_IMMEDIATELY(driver)
					PED.SET_PED_COMBAT_ATTRIBUTES(driver, 46, false)
					PED.SET_PED_INTO_VEHICLE(driver, vehicle, -1)
				end
			end
		end
	end)
	


function requestModels(...)
	local arg = {...}
	for _, model in ipairs(arg) do
		if not STREAMING.IS_MODEL_VALID(model) then
			util.toast(model)
			error("tried to request an invalid model")
		end
		STREAMING.REQUEST_MODEL(model)
		while not STREAMING.HAS_MODEL_LOADED(model) do
			wait()
		end
	end
end

streetcars = {dilettante, issi, exemplar, f620, felon, jackal, oracle2, zion, dominator, gauntlet, ruiner, buccaneer, sandking, cavalcade, dubsta, fq2,
 gresley, habanero, huntley, landstalker, radi,  seminole, serrano, asea, emperor, fugitive, ingot, intruder, primo, shafter, stanier, surge, washington, buffalo,
 carbonizzare, fusilade, massacro, ninef, rapidgt, surano, banshee,
}

streetdrivers = {a_f_m_eastsa_01, a_f_m_downtown_01

}


		menu.action(vehatk_root, "Send Annoying Lester", {"sendcripple"}, "Sends lester to ram them or run them over. Spawns on roads.", function(on_click)
		local vehicleHash = util.joaat("asea")
		local pedHash = 1302784073
		requestModels(vehicleHash, pedHash)
		local targetPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
		local pos = ENTITY.GET_ENTITY_COORDS(targetPed)
		local vehicle = entities.create_vehicle(vehicleHash, pos, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
		if not ENTITY.DOES_ENTITY_EXIST(vehicle) then
			return
		end

		local offset = getOffsetFromEntityGivenDistance(vehicle, 50.0)
		local outCoords = v3.new()
		local outHeading = memory.alloc()

		if PATHFIND.GET_CLOSEST_VEHICLE_NODE_WITH_HEADING(offset.x, offset.y, offset.z, outCoords, outHeading, 1, 3.0, 0) then
			ENTITY.SET_ENTITY_COORDS(vehicle, v3.getX(outCoords), v3.getY(outCoords), v3.getZ(outCoords))
			ENTITY.SET_ENTITY_HEADING(vehicle, memory.read_float(outHeading))
			VEHICLE.SET_VEHICLE_SIREN(vehicle, true)
			VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, true)
			for seat = -1, -1 do
				local cop = entities.create_ped(5, pedHash, outCoords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
				PED.SET_PED_INTO_VEHICLE(cop, vehicle, seat)
				PED.SET_PED_NEVER_LEAVES_GROUP(cop, true)
				TASK.TASK_COMBAT_PED(cop, targetPed, 0, 16)
				PED.SET_PED_KEEP_TASK(cop, true)
				PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(cop, true)
				VEHICLE.SET_VEHICLE_COLOURS(vehicle, 64, 64)
				VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_NON_SCRIPT_PLAYERS(van, true)
				VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle,-1, 3)
				PED.SET_PED_COMBAT_ATTRIBUTES(cop, 3, true)
				VEHICLE.MODIFY_VEHICLE_TOP_SPEED(vehicle, 50)
				TASK.TASK_VEHICLE_MISSION_PED_TARGET(cop, vehicle, targetPed, 6, 100, 0, 0, 0, true)
			end
		end
		v3.free(outCoords)
		memory.free(outHeading)
		STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(pedHash)
		STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(vehicleHash)
	end)
	uj = util.joaat
		menu.action(vehatk_root, "Send Annoying npc", {"sendmocc"}, "Sends an npc to ram them or run them over. Spawns on roads.", function(on_click)
		local vehtable = {"fusilade", "radius", "fq2", "mule", "oracle"}
		local retard = util.joaat("a_f_m_bevhills_01")
		local car1 = 499169875
		local car2 = -1651067813
		local car3 = -1137532101
		local car4 = 904750859
		local car5 = 1348744438
		local veh = random{499169875,  904750859,  -1137532101, -1651067813, 499169875}
		requestModels(car1, car2, car3, car4, car5, retard)
		local targetPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
		local pos = ENTITY.GET_ENTITY_COORDS(targetPed)
		local vehicle = entities.create_vehicle(veh, pos, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
		if not ENTITY.DOES_ENTITY_EXIST(vehicle) then
			return
		end

		local offset = getOffsetFromEntityGivenDistance(vehicle, 50.0)
		local outCoords = v3.new()
		local outHeading = memory.alloc()

		if PATHFIND.GET_CLOSEST_VEHICLE_NODE_WITH_HEADING(offset.x, offset.y, offset.z, outCoords, outHeading, 1, 3.0, 0) then
			ENTITY.SET_ENTITY_COORDS(vehicle, v3.getX(outCoords), v3.getY(outCoords), v3.getZ(outCoords))
			ENTITY.SET_ENTITY_HEADING(vehicle, memory.read_float(outHeading))
			VEHICLE.SET_VEHICLE_SIREN(vehicle, true)
			VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, true)
			for seat = -1, -1 do
				local cop = entities.create_ped(5, retard, outCoords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
				PED.SET_PED_INTO_VEHICLE(cop, vehicle, seat)
				PED.SET_PED_RANDOM_COMPONENT_VARIATION(cop, 0)
				PED.SET_PED_NEVER_LEAVES_GROUP(cop, true)
				VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_NON_SCRIPT_PLAYERS(vehicle, true)
				VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle,-1, 3)
				TASK.TASK_COMBAT_PED(cop, targetPed, 0, 16)
				PED.SET_PED_KEEP_TASK(cop, true)
				PED.SET_PED_COMBAT_ATTRIBUTES(cop, 3, true)
				VEHICLE.MODIFY_VEHICLE_TOP_SPEED(vehicle, 50)
				TASK.TASK_VEHICLE_MISSION_PED_TARGET(cop, vehicle, targetPed, 6, 100, 0, 0, 0, true)
			end
		end
		v3.free(outCoords)
		memory.free(outHeading)
		STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(pedHash)
		STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(car1)
		STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(car2)
		STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(car3)
		STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(car4)
		STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(car5)
	end)
	
		menu.action(vehatk_root, "Send Angry Trevor", {"sendmaniac"}, "Sends Trevor to ram them or run them over. Spawns on roads. Use watchdogs world hacking to delete, too dumb to get a functional delte button for this.", function(on_click)
		local vehicleHash = util.joaat("bodhi2")
		local pedHash = -1686040670
		requestModels(vehicleHash, pedHash)
		local targetPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
		local pos = ENTITY.GET_ENTITY_COORDS(targetPed)
		local vehicle = entities.create_vehicle(vehicleHash, pos, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
		if not ENTITY.DOES_ENTITY_EXIST(vehicle) then
			return
		end

		local offset = getOffsetFromEntityGivenDistance(vehicle, 50.0)
		local outCoords = v3.new()
		local outHeading = memory.alloc()

		if PATHFIND.GET_CLOSEST_VEHICLE_NODE_WITH_HEADING(offset.x, offset.y, offset.z, outCoords, outHeading, 1, 3.0, 0) then
			ENTITY.SET_ENTITY_COORDS(vehicle, v3.getX(outCoords), v3.getY(outCoords), v3.getZ(outCoords))
			ENTITY.SET_ENTITY_HEADING(vehicle, memory.read_float(outHeading))
			VEHICLE.SET_VEHICLE_SIREN(vehicle, true)
			VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, true)
			for seat = -1, -1 do
				local cop = entities.create_ped(2, pedHash, outCoords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
				PED.SET_PED_INTO_VEHICLE(cop, vehicle, seat)
				TASK.TASK_COMBAT_PED(cop, targetPed, 0, 16)
				PED.SET_PED_KEEP_TASK(cop, true)
				VEHICLE.SET_VEHICLE_COLOURS(vehicle, 32, 32)
				VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_NON_SCRIPT_PLAYERS(vehicle, true)
				VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle,-1, 3)
				PED.SET_PED_COMBAT_ATTRIBUTES(cop, 46, true)
				PED.SET_PED_COMBAT_ATTRIBUTES(cop, 3, false)
				PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(cop, true)
				VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, "Betty 32")
				VEHICLE.MODIFY_VEHICLE_TOP_SPEED(vehicle, 50)
				ENTITY.SET_ENTITY_INVINCIBLE(cop, true)
				ENTITY.SET_ENTITY_INVINCIBLE(vehicle, true)
				VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(vehicle, 0)
				PED.SET_PED_NEVER_LEAVES_GROUP(cop, true)
				TASK.TASK_VEHICLE_MISSION_PED_TARGET(cop, vehicle, targetPed, 6, 100, 0, 0, 0, true)
			end
			for seat2 = 0, 0 do --2nd invisible trevor to insult the player due to gta being gta
				local trev = entities.create_ped(2, pedHash, outCoords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
				PED.SET_PED_INTO_VEHICLE(trev, vehicle, seat2)
				PED.SET_PED_COMBAT_ATTRIBUTES(trev, 3, false)
				PED.SET_PED_COMBAT_ATTRIBUTES(trev, 46, true)
				ENTITY.SET_ENTITY_VISIBLE(trev, false, 0)
				TASK.TASK_COMBAT_PED(trev, targetPed, 0, 16)
				ENTITY.SET_ENTITY_INVINCIBLE(trev, true)
				PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(trev, true)
			end
		end
		v3.free(outCoords)
		memory.free(outHeading)
		STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(pedHash)
		STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(vehicleHash)
	end)

		menu.action(vehatk_root, "Send Guadalupe", {"sendgua"}, "Ya se enfade de sus hijos y ya viene a atropellar un pendejo", function(on_click)
		local vehicleHash = util.joaat("seminole")
		local pedHash = 261428209
		requestModels(vehicleHash, pedHash)
		local targetPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
		local pos = ENTITY.GET_ENTITY_COORDS(targetPed)
		local vehicle = entities.create_vehicle(vehicleHash, pos, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
		if not ENTITY.DOES_ENTITY_EXIST(vehicle) then
			return
		end

		local offset = getOffsetFromEntityGivenDistance(vehicle, 50.0)
		local outCoords = v3.new()
		local outHeading = memory.alloc()

		if PATHFIND.GET_CLOSEST_VEHICLE_NODE_WITH_HEADING(offset.x, offset.y, offset.z, outCoords, outHeading, 1, 3.0, 0) then
			ENTITY.SET_ENTITY_COORDS(vehicle, v3.getX(outCoords), v3.getY(outCoords), v3.getZ(outCoords))
			ENTITY.SET_ENTITY_HEADING(vehicle, memory.read_float(outHeading))
			VEHICLE.SET_VEHICLE_SIREN(vehicle, true)
			VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, true)
			for seat = -1, -1 do
				local cop = entities.create_ped(2, pedHash, outCoords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
				PED.SET_PED_INTO_VEHICLE(cop, vehicle, seat)
				TASK.TASK_COMBAT_PED(cop, targetPed, 0, 16)
				PED.SET_PED_KEEP_TASK(cop, true)
				VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_NON_SCRIPT_PLAYERS(vehicle, true)
				VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle,-1, 3)
				PED.SET_PED_COMBAT_ATTRIBUTES(cop, 46, true)
				PED.SET_PED_COMBAT_ATTRIBUTES(cop, 3, false)
				PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(cop, true)
				VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, "GUADALUPE")
				VEHICLE.MODIFY_VEHICLE_TOP_SPEED(vehicle, 50)
				ENTITY.SET_ENTITY_INVINCIBLE(cop, true)
				ENTITY.SET_ENTITY_INVINCIBLE(vehicle, true)
				VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(vehicle, 0)
				PED.SET_PED_NEVER_LEAVES_GROUP(cop, true)
				TASK.TASK_VEHICLE_MISSION_PED_TARGET(cop, vehicle, targetPed, 6, 100, 0, 0, 0, true)
			end
		end
		v3.free(outCoords)
		memory.free(outHeading)
		STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(pedHash)
		STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(vehicleHash)
	end)
	

		menu.action(vehatk_root, "Send Guadalupe Non GM", {"sendgua2"}, "A nice exican grandmother who's had enough of your shit", function(on_click)
		local vehicleHash = util.joaat("seminole")
		local pedHash = 261428209
		requestModels(vehicleHash, pedHash)
		local targetPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
		local pos = ENTITY.GET_ENTITY_COORDS(targetPed)
		local vehicle = entities.create_vehicle(vehicleHash, pos, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
		if not ENTITY.DOES_ENTITY_EXIST(vehicle) then
			return
		end

		local offset = getOffsetFromEntityGivenDistance(vehicle, 50.0)
		local outCoords = v3.new()
		local outHeading = memory.alloc()

		if PATHFIND.GET_CLOSEST_VEHICLE_NODE_WITH_HEADING(offset.x, offset.y, offset.z, outCoords, outHeading, 1, 3.0, 0) then
			ENTITY.SET_ENTITY_COORDS(vehicle, v3.getX(outCoords), v3.getY(outCoords), v3.getZ(outCoords))
			ENTITY.SET_ENTITY_HEADING(vehicle, memory.read_float(outHeading))
			VEHICLE.SET_VEHICLE_SIREN(vehicle, true)
			VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, true)
			for seat = -1, -1 do
				local cop = entities.create_ped(2, pedHash, outCoords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
				PED.SET_PED_INTO_VEHICLE(cop, vehicle, seat)
				TASK.TASK_COMBAT_PED(cop, targetPed, 0, 16)
				PED.SET_PED_KEEP_TASK(cop, true)
				VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_NON_SCRIPT_PLAYERS(vehicle, true)
				VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle,-1, 3)
				PED.SET_PED_COMBAT_ATTRIBUTES(cop, 46, true)
				PED.SET_PED_COMBAT_ATTRIBUTES(cop, 3, false)
				PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(cop, true)
				VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, "GUADALUPE")
				VEHICLE.MODIFY_VEHICLE_TOP_SPEED(vehicle, 50)
				VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(vehicle, 0)
				PED.SET_PED_NEVER_LEAVES_GROUP(cop, true)
				TASK.TASK_VEHICLE_MISSION_PED_TARGET(cop, vehicle, targetPed, 6, 100, 0, 0, 0, true)
			end
		end
		v3.free(outCoords)
		memory.free(outHeading)
		STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(pedHash)
		STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(vehicleHash)
	end)

		menu.action(cop_root, "Send FIB APC", {"fibapc"}, "you heard me.", function(on_click)
		local vehicleHash = util.joaat("apc")
		local pedHash = 1558115333 
		requestModels(vehicleHash, pedHash)
		local targetPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
		local pos = ENTITY.GET_ENTITY_COORDS(targetPed)
		local vehicle = entities.create_vehicle(vehicleHash, pos, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
		if not ENTITY.DOES_ENTITY_EXIST(vehicle) then
			return
		end

		local offset = getOffsetFromEntityGivenDistance(vehicle, 50.0)
		local outCoords = v3.new()
		local outHeading = memory.alloc()

		if PATHFIND.GET_CLOSEST_VEHICLE_NODE_WITH_HEADING(offset.x, offset.y, offset.z, outCoords, outHeading, 1, 3.0, 0) then
			ENTITY.SET_ENTITY_COORDS(vehicle, v3.getX(outCoords), v3.getY(outCoords), v3.getZ(outCoords))
			ENTITY.SET_ENTITY_HEADING(vehicle, memory.read_float(outHeading))
			VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, true)
			for seat = -1, 2 do
				local cop = entities.create_ped(2, pedHash, outCoords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
				PED.SET_PED_INTO_VEHICLE(cop, vehicle, seat)
				TASK.TASK_COMBAT_PED(cop, targetPed, 0, 16)
				VEHICLE.SET_VEHICLE_COLOURS(vehicle, 0, 0)
				VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_NON_SCRIPT_PLAYERS(vehicle, true)
				VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle,-1, 3)
				PED.SET_PED_COMBAT_ATTRIBUTES(cop, 46, true)
				PED.SET_PED_COMBAT_ATTRIBUTES(cop, 5, true)
				PED.SET_PED_COMBAT_ATTRIBUTES(cop, 2, true)
				VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, "FIB")
				VEHICLE.MODIFY_VEHICLE_TOP_SPEED(vehicle, 50)
				PED.SET_PED_COMBAT_ATTRIBUTES(cop, 3, false)
				VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(vehicle, 3)
				PED.SET_PED_MAX_HEALTH(cop, 600)
				ENTITY.SET_ENTITY_PROOFS(ped, false, true, false, false, true, false, false, false)
				ENTITY.SET_ENTITY_HEALTH(cop, 600)
				PED.SET_PED_SHOOT_RATE(cop, 5)
				PED.SET_PED_SUFFERS_CRITICAL_HITS(cop, false)
				WEAPON.GIVE_WEAPON_TO_PED(cop, 584646201, 9999, false, true)
				PED.SET_PED_ACCURACY(cop, 100.0)
				PED.SET_PED_HEARING_RANGE(cop, 99999)
				PED.SET_PED_AS_COP(cop, true)
				PED.SET_PED_CAN_RAGDOLL(cop, false)
				VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(vehicle, 0, 0, 0) --black
				VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(vehicle, 0, 0, 0)
				VEHICLE.SET_VEHICLE_MOD_COLOR_1(vehicle, 3, 0, 0) --matte finish
				VEHICLE.SET_VEHICLE_MOD_COLOR_2(vehicle, 3, 0, 0)-- matte secondary
				VEHICLE.SET_VEHICLE_WHEEL_TYPE(vehicle, 11) --street wheel type
				PED.SET_PED_SUFFERS_CRITICAL_HITS(clown, false)
				VEHICLE.SET_VEHICLE_MOD(vehicle, 23, 0)--wheel type?
				VEHICLE.SET_VEHICLE_EXTRA_COLOURS(vehicle, 0, 0) --wheel color
				VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(vehicle, 4) --plate type, 4 is SA EXEMPT which law enforcement and government vehicles use
			end
		end
		v3.free(outCoords)
		memory.free(outHeading)
		STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(pedHash)
		STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(vehicleHash)
	end)

	
    menu.action(npctrolls_root, "Fill car with peds", {"fillcar"}, "Fills the player\'s car with nearby peds", function(on_click)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        if PED.IS_PED_IN_ANY_VEHICLE(target_ped, true) then
                local veh = PED.GET_VEHICLE_PED_IS_IN(target_ped, false)
                local success = true
                while VEHICLE.ARE_ANY_VEHICLE_SEATS_FREE(veh) do
                    util.yield()
                    --  sometimes peds fail to get seated, so we will have something to break after 10 attempts if things go south
                    local iteration = 0
                    if iteration >= 20 then
                        util.toast("Failed to fully fill vehicle after 20 attempts. Please try again.")
                        local success = false
                        iteration = 0
                        break
                    end
                    local iteration = iteration + 1
                    local nearby_peds = entities.get_all_peds_as_handles()
                    for k,ped in pairs(nearby_peds) do
                        if PED.GET_VEHICLE_PED_IS_IN(ped, false) ~= veh and ENTITY.GET_ENTITY_HEALTH(ped) > 0 and not PED.IS_PED_FLEEING(ped) then
                            --dont touch player peds
                            if(PED.GET_PED_TYPE(ped) > 4) then
                                local veh = PED.GET_VEHICLE_PED_IS_IN(target_ped, false)
                                local iteration = iteration + 1
                                    for index = 0, VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(ENTITY.GET_ENTITY_MODEL(veh)) do
                                        if VEHICLE.IS_VEHICLE_SEAT_FREE(veh, index) then
                                            -- i think requesting control and clearing task deglitches the peds
                                            -- this is specifically to counter weird A-posing
                                            -- EDIT: it doesnt. why the fuck do some peds a-pose??? maybe ill find out eventually. oh well.
                                            request_control_of_entity(ped)
                                            TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
                                            PED.SET_PED_INTO_VEHICLE(ped, veh, index)
                                            PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
                                            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 5, true)
                                            PED.SET_PED_FLEE_ATTRIBUTES(ped, 0, false)
                                            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true)
                                            PED.SET_PED_CAN_BE_DRAGGED_OUT(ped, false)
                                            PED.SET_PED_CAN_BE_KNOCKED_OFF_VEHICLE(ped, false)
                                        end
                                    end
                                break
                            end
                        end
                    end
                end
                if success then
                    util.toast("Every available seat should now be full of peds. If it isn\'t, try spamming this or try again in a bit.")
                end
        else
            util.toast("Player is not in a car :(")
        end
    end)
	
   menu.action(attackers_root, "Clown attack", {"clownattack"}, "Sends clowns to attack the player.", function(on_click)
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local clown_hash = 71929310
        request_model_load(clown_hash)
        local van_hash = util.joaat("speedo2")
        request_model_load(van_hash)
        local coords = ENTITY.GET_ENTITY_COORDS(player_ped, true)
        local spawn_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, math.random(-20, 20), -20, 0.0)
        spawn_pos.x = spawn_pos['x']
        spawn_pos.y = spawn_pos['y']
        spawn_pos.z = spawn_pos['z']
        local van = entities.create_vehicle(van_hash, spawn_pos, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
		SET_ENT_FACE_ENT(van, player_ped)
        if godmodeatk then
            ENTITY.SET_ENTITY_INVINCIBLE(van, true)
        end
        for i=-1, VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(van) - 1 do
            local clown = entities.create_ped(1, clown_hash, spawn_pos, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
            PED.SET_PED_INTO_VEHICLE(clown, van, i)
			VEHICLE.MODIFY_VEHICLE_TOP_SPEED(van, 50)
            if i % 2 == 0 then
                WEAPON.GIVE_WEAPON_TO_PED(clown, -1810795771, 9999, false, true)
            else
                WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201, 9999, false, true)
            end
			PED.SET_PED_AS_COP(clown, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(clown, 5, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(clown, 46, true)
			ENTITY.SET_ENTITY_PROOFS(ped, false, true, false, false, true, false, false, false)
			PED.SET_PED_ACCURACY(clown, 100.0)
			PED.SET_PED_HEARING_RANGE(clown, 99999)
			VEHICLE.SET_VEHICLE_DOORS_LOCKED(van, 3)
			PED.SET_PED_MAX_HEALTH(clown, 250)
			ENTITY.SET_ENTITY_HEALTH(clown, 250)
			PED.SET_PED_SHOOT_RATE(clown, 5)
			PED.SET_PED_SUFFERS_CRITICAL_HITS(clown, false)
            if i == -1 then
                TASK.TASK_VEHICLE_CHASE(clown, player_ped)
            else
                TASK.TASK_COMBAT_PED(clown, player_ped, 0, 16)
				PED.SET_PED_CAN_RAGDOLL(clown, false)
            end
			if pcar then 
				PED.SET_PED_COMBAT_ATTRIBUTES(clown, 3, false)
			end
			if godemodeatk then 
				PED.SET_PED_COMBAT_ATTRIBUTES(clown, 3, false)
			end
			if d then
				PED.SET_AI_WEAPON_DAMAGE_MODIFIER(clown, 3000000)
			end
        end
    end)

 local spawnedPeds = {} -- stores the spawned attackers
	

	
  menu.action(attackers_root, "Lester Gang attack", {"crippleatk"}, "lester the molester", function(on_click)
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local clown_hash = 1302784073
        request_model_load(clown_hash)
        local van_hash = util.joaat("jugular")
        request_model_load(van_hash)
        local coords = ENTITY.GET_ENTITY_COORDS(player_ped, true)
        local spawn_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, math.random(-20, 20), -20, 0.0)
        local van = entities.create_vehicle(van_hash, spawn_pos, ENTITY.GET_ENTITY_HEADING(player_ped))
        
        if godmodeatk then
            ENTITY.SET_ENTITY_INVINCIBLE(van, true)
        end
        
        for i= -1, VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(van) - 1 do
            local clown = entities.create_ped(1, clown_hash, spawn_pos, 0.0)

            PED.SET_PED_INTO_VEHICLE(clown, van, i)
            
            if i % 2 == 0 then
                WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201, 1000, false, true)
            else
                WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201, 1000, false, true)
            end
    		PED.SET_PED_AS_COP(clown, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(clown, 5, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(clown, 46, true)
			PED.SET_PED_ACCURACY(clown, 100.0)
			ENTITY.SET_ENTITY_PROOFS(ped, false, true, false, false, true, false, false, false)
			PED.SET_PED_HEARING_RANGE(clown, 99999)
			VEHICLE.MODIFY_VEHICLE_TOP_SPEED(van, 50)
			VEHICLE.SET_VEHICLE_DOORS_LOCKED(van, 3)
			PED.SET_PED_MAX_HEALTH(clown, 250)
			ENTITY.SET_ENTITY_HEALTH(clown, 250)
			PED.SET_PED_SHOOT_RATE(clown, 5)
			PED.SET_PED_SUFFERS_CRITICAL_HITS(clown, false)
			if godmodeatk then
				ENTITY.SET_ENTITY_INVINCIBLE(van, true)
			end
			if pcar then 
				PED.SET_PED_COMBAT_ATTRIBUTES(clown, 3, false)
			end
			if d then
				PED.SET_AI_WEAPON_DAMAGE_MODIFIER(clown, 3000000)
			end
            if i == -1 then
                TASK.TASK_VEHICLE_CHASE(clown, player_ped)
                WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201, 1000, false, true)
                PED.SET_PED_CAN_RAGDOLL(clown, false)
            else
                TASK.TASK_COMBAT_PED(clown, player_ped, 0, 16)
                WEAPON.GIVE_WEAPON_TO_PED(clown, -1357824103, 1000, false, true)
                PED.SET_PED_CAN_RAGDOLL(clown, false)
			end
        end
    end)


	
	menu.toggle(atkab_root, "God Mode Vehicle", {"vehgm"}, "does what it says on the tin, only applies to vehicle attackers.", function(on)
		godmodeatk = on
	end)
	
	menu.toggle(atkab_root, "Attacker does not exit vehicle", {"veh"}, "does what it says on the tin, only applies to vehicle attackers.", function(on)
		pcar = on
	end)
	

	
	menu.action(cop_root, "FIB Attack", {"fibatk"}, "can be hard to escape from no matter the car, as long as it cant fly", function(on_click)
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local clown_hash = 1558115333
        request_model_load(clown_hash)
        local van_hash = util.joaat("krieger")
        request_model_load(van_hash)
        local coords = ENTITY.GET_ENTITY_COORDS(player_ped, true)
        local spawn_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, math.random(-20, 20), -20, 0.0)
        local van = entities.create_vehicle(van_hash, spawn_pos, ENTITY.GET_ENTITY_HEADING(player_ped))
        for i=-1, VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(van) - 1 do
            local clown = entities.create_ped(1, clown_hash, spawn_pos, 0.0)
            PED.SET_PED_INTO_VEHICLE(clown, van, i)
            if i % 2 == 0 then
                WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201, 1000, false, true)
            else
                WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201, 1000, false, true)
            end
			PED.SET_PED_AS_COP(clown, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(clown, 5, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(clown, 46, true)
			PED.SET_PED_ACCURACY(clown, 100.0)
			PED.SET_PED_HEARING_RANGE(clown, 99999)
			PED.SET_PED_RANDOM_COMPONENT_VARIATION(clown, 0)
			VEHICLE.SET_VEHICLE_DOORS_LOCKED(van, 3)
			VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(van, "FIB")
			VEHICLE.SET_VEHICLE_EXPLODES_ON_HIGH_EXPLOSION_DAMAGE(van, false)
			VEHICLE.MODIFY_VEHICLE_TOP_SPEED(van, 50)
			PED.SET_PED_MAX_HEALTH(clown, 250)
			ENTITY.SET_ENTITY_PROOFS(ped, false, true, false, false, true, false, false, false)
			ENTITY.SET_ENTITY_HEALTH(clown, 250)
			PED.SET_PED_SHOOT_RATE(clown, 5)
			VEHICLE.SET_VEHICLE_MOD_KIT(van, 0)
			VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(van, 0, 0, 0) --black
			VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(van, 0, 0, 0)
			VEHICLE.SET_VEHICLE_MOD_COLOR_1(van, 3, 0, 0) --matte finish
			VEHICLE.SET_VEHICLE_MOD_COLOR_2(van, 3, 0, 0)-- matte secondary
			VEHICLE.SET_VEHICLE_WHEEL_TYPE(van, 11) --street wheel type
			PED.SET_PED_SUFFERS_CRITICAL_HITS(clown, false)
			VEHICLE.SET_VEHICLE_MOD(van, 0, 3) --spoiler
			VEHICLE.SET_VEHICLE_MOD(van, 23, 0)--wheel type?
			VEHICLE.SET_VEHICLE_EXTRA_COLOURS(van, 0, 0) --wheel color
			VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(van, 4) --plate type, 4 is SA EXEMPT which law enforcement and government vehicles use
			if godmodeatk then
				ENTITY.SET_ENTITY_INVINCIBLE(van, true)
			end
			if pcar then 
				PED.SET_PED_COMBAT_ATTRIBUTES(clown, 3, false)
			end
			if d then
				PED.SET_AI_WEAPON_DAMAGE_MODIFIER(clown, 3000000)
			end
            if i == -1 then
                TASK.TASK_VEHICLE_CHASE(clown, player_ped)
				WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201 , 1000, false, true)
				PED.SET_PED_CAN_RAGDOLL(clown, false)
            else
                TASK.TASK_COMBAT_PED(clown, player_ped, 0, 16)
				WEAPON.GIVE_WEAPON_TO_PED(clown, -1357824103, 1000, false, true)
				PED.SET_PED_CAN_RAGDOLL(clown, false)
            end
        end
    end)

	menu.action(broken_root, "GTA player attack", {"gtap"}, "", function(on_click)
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local clown_hash = 1885233650
        request_model_load(clown_hash)
        local van_hash = util.joaat("t20")
        request_model_load(van_hash)
        local coords = ENTITY.GET_ENTITY_COORDS(player_ped, true)
        local spawn_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, math.random(-20, 20), -20, 0.0)
        local van = entities.create_vehicle(van_hash, spawn_pos, ENTITY.GET_ENTITY_HEADING(player_ped))
        for i=-1, -1 do
            local clown = entities.create_ped(1, clown_hash, spawn_pos, 0.0)
            PED.SET_PED_INTO_VEHICLE(clown, van, i)
            if i % 2 == 0 then
                WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201, 1000, false, true)
            else
                WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201, 1000, false, true)
            end
			PED.SET_PED_AS_COP(clown, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(clown, 5, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(clown, 46, true)
			PED.SET_PED_ACCURACY(clown, 100.0)
			PED.SET_PED_HEARING_RANGE(clown, 99999)
			VEHICLE.SET_VEHICLE_DOORS_LOCKED(van, 3)
			VEHICLE.MODIFY_VEHICLE_TOP_SPEED(van, 50)
			PED.SET_PED_MAX_HEALTH(clown, 250)
			ENTITY.SET_ENTITY_PROOFS(ped, false, true, false, false, true, false, false, false)
			ENTITY.SET_ENTITY_HEALTH(clown, 250)
			PED.SET_PED_SHOOT_RATE(clown, 5)
			VEHICLE.SET_VEHICLE_MOD_KIT(van, 0)
			VEHICLE.SET_VEHICLE_COLOURS(van, 0, 0)
			VEHICLE.SET_VEHICLE_MOD_COLOR_1(van, 3, 0, 0)
			VEHICLE.SET_VEHICLE_MOD_COLOR_2(van, 3, 0, 0)
			PED.SET_PED_SUFFERS_CRITICAL_HITS(clown, false)
			if godmodeatk then
				ENTITY.SET_ENTITY_INVINCIBLE(van, true)
			end
			if pcar then 
				PED.SET_PED_COMBAT_ATTRIBUTES(clown, 3, false)
			end
			if d then
				PED.SET_AI_WEAPON_DAMAGE_MODIFIER(clown, 3000000)
			end
            if i == -1 then
                TASK.TASK_VEHICLE_CHASE(clown, player_ped)
				WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201 , 1000, false, true)
				PED.SET_PED_CAN_RAGDOLL(clown, false)
            else
                TASK.TASK_COMBAT_PED(clown, player_ped, 0, 16)
				WEAPON.GIVE_WEAPON_TO_PED(clown, -1357824103, 1000, false, true)
				PED.SET_PED_CAN_RAGDOLL(clown, false)
            end
        end
    end)
	
		menu.action(attackers_root, "Send TP Industries Tactical Team", {"senddrugaddicts"}, "is only affected by the cannot leave vehicle attribute", function(on_click)
		local vehicleHash = util.joaat("bodhi2")
		local pedHash = -1686040670 --trevor
		local ronhash = -1124046095
		local wadehash = -1835459726
		requestModels(vehicleHash, pedHash, ronhash, wadehash)
		local targetPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
		local pos = ENTITY.GET_ENTITY_COORDS(targetPed)
		local vehicle = entities.create_vehicle(vehicleHash, pos, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
		if not ENTITY.DOES_ENTITY_EXIST(vehicle) then
			return
		end

		local offset = getOffsetFromEntityGivenDistance(vehicle, 50.0)
		local outCoords = v3.new()
		local outHeading = memory.alloc()

		if PATHFIND.GET_CLOSEST_VEHICLE_NODE_WITH_HEADING(offset.x, offset.y, offset.z, outCoords, outHeading, 1, 3.0, 0) then
			ENTITY.SET_ENTITY_COORDS(vehicle, v3.getX(outCoords), v3.getY(outCoords), v3.getZ(outCoords))
			ENTITY.SET_ENTITY_HEADING(vehicle, memory.read_float(outHeading))
			VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, true)
			for seat = -1, -1 do
				local cop = entities.create_ped(2, pedHash, outCoords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
				PED.SET_PED_INTO_VEHICLE(cop, vehicle, seat)
				TASK.TASK_COMBAT_PED(cop, targetPed, 0, 16)
				VEHICLE.SET_VEHICLE_COLOURS(vehicle, 32, 32)
				VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_NON_SCRIPT_PLAYERS(vehicle, true)
				VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle,-1, 3)
				PED.SET_PED_COMBAT_ATTRIBUTES(cop, 46, true)
				VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, "Betty 32")
				VEHICLE.MODIFY_VEHICLE_TOP_SPEED(vehicle, 50)
				ENTITY.SET_ENTITY_INVINCIBLE(vehicle, true)
				VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(vehicle, 0)
				PED.SET_PED_MAX_HEALTH(cop, 600)
				ENTITY.SET_ENTITY_PROOFS(ped, false, true, false, false, true, false, false, false)
				ENTITY.SET_ENTITY_HEALTH(cop, 600)
				PED.SET_PED_SHOOT_RATE(cop, 5)
				PED.SET_PED_SUFFERS_CRITICAL_HITS(cop, false)
				WEAPON.GIVE_WEAPON_TO_PED(cop, 584646201, 9999, false, true)
				PED.SET_PED_ACCURACY(cop, 100.0)
				PED.SET_PED_HEARING_RANGE(cop, 99999)
				PED.SET_PED_AS_COP(cop, true)
				PED.SET_PED_CAN_RAGDOLL(cop, false)
			end
			for seat2 = 0, 0 do
				local ron = entities.create_ped(4, ronhash, outCoords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
				PED.SET_PED_INTO_VEHICLE(ron, vehicle, seat2)
				PED.SET_PED_COMBAT_ATTRIBUTES(ron, 46, true)
				TASK.TASK_COMBAT_PED(ron, targetPed, 0, 16)
				PED.SET_PED_MAX_HEALTH(ron, 300)
				ENTITY.SET_ENTITY_PROOFS(ron, false, true, false, false, true, false, false, false)
				ENTITY.SET_ENTITY_HEALTH(ron, 300)
				PED.SET_PED_SHOOT_RATE(ron, 5)
				PED.SET_PED_SUFFERS_CRITICAL_HITS(ron, false)
				PED.SET_PED_ACCURACY(ron, 100.0)
				PED.SET_PED_HEARING_RANGE(ron, 99999)
				PED.SET_PED_AS_COP(ron, true)
				WEAPON.GIVE_WEAPON_TO_PED(ron, 584646201 , 9999, false, true)
			end
				for seat3 = 1, 1 do
				local wade = entities.create_ped(4, wadehash, outCoords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
				PED.SET_PED_INTO_VEHICLE(wade, vehicle, seat3)
				PED.SET_PED_COMBAT_ATTRIBUTES(wade, 46, true)
				TASK.TASK_COMBAT_PED(wade, targetPed, 0, 16)
				PED.SET_PED_MAX_HEALTH(wade, 300)
				ENTITY.SET_ENTITY_PROOFS(wade, false, true, false, false, true, false, false, false)
				ENTITY.SET_ENTITY_HEALTH(wade, 300)
				PED.SET_PED_SHOOT_RATE(wade, 5)
				PED.SET_PED_SUFFERS_CRITICAL_HITS(wade, false)
				PED.SET_PED_ACCURACY(wade, 100.0)
				PED.SET_PED_HEARING_RANGE(wade, 99999)
				PED.SET_PED_AS_COP(wade, true)
				WEAPON.GIVE_WEAPON_TO_PED(wade, 584646201 , 9999, false, true)
				PED.SET_PED_CAN_BE_KNOCKED_OFF_VEHICLE(wade, 1)
			end
		end
		if pcar then 
			PED.SET_PED_COMBAT_ATTRIBUTES(ron, 3, false)
			PED.SET_PED_COMBAT_ATTRIBUTES(cop, 3, false)
			PED.SET_PED_COMBAT_ATTRIBUTES(wade, 3, false)
		end
		v3.free(outCoords)
		memory.free(outHeading)
		STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(pedHash)
		STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(vehicleHash)
	end)


 	menu.action(attackers_root, "Extreme Attack", {"mercs"}, "sends the most brutal attackers, specially created to be brutal and annoying. Toxic.", function(on_click)
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid) -- gets the player
        local clown_hash = 788443093 --the hash number of the attacker
        request_model_load(clown_hash) --loads it
        local van_hash = util.joaat("kuruma2") --defines a kuruma as van_hash
        request_model_load(van_hash) --loads it
        local coords = ENTITY.GET_ENTITY_COORDS(player_ped, true) --defines the victims current coords
        local spawn_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, math.random(-20, 20), -20, 0.0) --creates a 360 bubble where they have a chance to spawn
        local van = entities.create_vehicle(van_hash, spawn_pos, ENTITY.GET_ENTITY_HEADING(player_ped)) --creates the van, then defines that van as "van"
        for i=-1, VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(van) - 1 do --for every seat in the current vehicle, (in this case 4) do this
            local clown = entities.create_ped(1, clown_hash, spawn_pos, 0.0) --creates the attacking ped
            PED.SET_PED_INTO_VEHICLE(clown, van, i) -- puts the attacking ped into the vehicle, and one for each seat
            if i % 2 == 0 then -- dont know lol, all I know is this affects what weapon they have inside and outside a car
                WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201, 1000, false, true)-- gives them an AP pistol
            else
                WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201, 1000, false, true)
            end
			PED.SET_PED_AS_COP(clown, true) --does what it says
            PED.SET_PED_COMBAT_ATTRIBUTES(clown, 5, true) --5 means "fight when unarmed"
            PED.SET_PED_COMBAT_ATTRIBUTES(clown, 46, true) --46 means always fight
			PED.SET_PED_ACCURACY(clown, 100.0) --makes them stupid accurate
			PED.SET_PED_HEARING_RANGE(clown, 99999) -- will aggro on you if you shoot a gun from miles away
			PED.SET_PED_SUFFERS_CRITICAL_HITS(clown, false) -- makes headshots deal the same damage as body shots, and they cannot fall from being shot
			VEHICLE.SET_VEHICLE_DOORS_LOCKED(van, 3) -- does what it says, number defines what the vehicle is locked to, in this case other players
			VEHICLE.MODIFY_VEHICLE_TOP_SPEED(van, 50) -- does what it says
			VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_NON_SCRIPT_PLAYERS(van, true) --redundant locking
			ENTITY.SET_ENTITY_INVINCIBLE(van, true) -- does what it says, the true/false defines if the engine is on
			PED.SET_PED_MAX_HEALTH(clown, 250) --does what is says, is the peds max possible health
			ENTITY.SET_ENTITY_HEALTH(clown, 250) --does what it says, actually setting the peds health to this.
			PED.SET_PED_KEEP_TASK(clown, true) --does what it says, probably useless
			PED.SET_PED_ARMOUR(clown, 200) --does what it says
			ENTITY.SET_ENTITY_PROOFS(ped, false, true, false, false, true, false, false, false) --supposed to make them fire and melee proof, doesnt seem to actually fucking work
			PED.SET_PED_SHOOT_RATE(clown, 3) --makes them shoot more often and be deadlier
            if i == -1 then --if inside the aforementioned car, do this
                TASK.TASK_VEHICLE_CHASE(clown, player_ped) --ped is told to chase the victim
				WEAPON.GIVE_WEAPON_TO_PED(clown,584646201 , 1000, false, true) --gives them AP pistol
				PED.SET_PED_CAN_RAGDOLL(clown, false)
            else
                TASK.TASK_COMBAT_PED(clown, player_ped, 0, 16)
				WEAPON.GIVE_WEAPON_TO_PED(clown, -1357824103, 1000, false, true) --gives them an advanced rifle or carbine rifle, cant remember, the 1000 is how much ammo they are given.
				PED.SET_PED_CAN_RAGDOLL(clown, false) --does what is says
            end
			if pcar then --basically a little option that depends on whether or not another option is on or not, and allows you to control their behavior
				PED.SET_PED_COMBAT_ATTRIBUTES(clown, 3, false) --keeps them from exiting the car
			end
			if d then -- unused
				PED.SET_AI_WEAPON_DAMAGE_MODIFIER(clown, 3000000) --does what it says, this remains unused because OP
			end
        end
    end)
memory.read_vector3 = function(int) local x,y,z = v3.get(int) return {x=x,y=y,z=z} end
wait = util.yield
joaat = util.joaat
alloc = memory.alloc
cTime = util.current_time_millis
create_tick_handler = util.create_tick_handler

	local function polizei(pId, vehicleHash, pedHash)
		local vehicleHash = util.joaat("police3")
		local pedHash = util.joaat("s_m_y_cop_01")
		requestModels(vehicleHash, pedHash)
		
		local targetPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
		local pos = ENTITY.GET_ENTITY_COORDS(targetPed)
		local vehicle = entities.create_vehicle(vehicleHash, pos, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
		util.toast(pos.x, pos.y, pos.z)
		if not ENTITY.DOES_ENTITY_EXIST(vehicle) then
			return
		end

		local offset = getOffsetFromEntityGivenDistance(vehicle, 50.0)
		local outCoords = v3.new()
		local outHeading = memory.alloc()

		if PATHFIND.GET_CLOSEST_VEHICLE_NODE_WITH_HEADING(offset.x, offset.y, offset.z, outCoords, outHeading, 1, 3.0, 0) then
			ENTITY.SET_ENTITY_COORDS(vehicle, v3.getX(outCoords), v3.getY(outCoords), v3.getZ(outCoords))
			ENTITY.SET_ENTITY_HEADING(vehicle, memory.read_float(outHeading))
			VEHICLE.SET_VEHICLE_SIREN(vehicle, true)
			VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, true)
			for seat = -1, 0 do
				local cop = entities.create_ped(5, pedHash, outCoords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
				PED.SET_PED_INTO_VEHICLE(cop, vehicle, seat)
				PED.SET_PED_RANDOM_COMPONENT_VARIATION(cop, 0)
				local weapon = (seat == -1) and "weapon_pistol" or "weapon_pumpshotgun"
				WEAPON.GIVE_WEAPON_TO_PED(cop, util.joaat(weapon), -1, false, true)
				PED.SET_PED_NEVER_LEAVES_GROUP(cop, true)
				PED.SET_PED_COMBAT_ATTRIBUTES(cop, 1, true)
				PED.SET_PED_AS_COP(cop, true)
				TASK.TASK_COMBAT_PED(cop, targetPed, 0, 16)
				PED.SET_PED_KEEP_TASK(cop, true)
				util.create_tick_handler(function()
					if TASK.GET_SCRIPT_TASK_STATUS(cop, 0x2E85A751) == 7 then
						TASK.CLEAR_PED_TASKS(cop)
						TASK.TASK_SMART_FLEE_PED(cop, PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId), 1000.0, -1, false, false)
						PED.SET_PED_KEEP_TASK(cop, true)
						return false
					end
					return true
				end)
			end	
		end

		v3.free(outCoords)
		memory.free(outHeading)
		STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(pedHash)
		STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(vehicleHash)
	end

function addBlipForEntity(entity, blipSprite, colour)
	local blip = HUD.ADD_BLIP_FOR_ENTITY(entity)
	HUD.SET_BLIP_SPRITE(blip, blipSprite)
	HUD.SET_BLIP_COLOUR(blip, colour)
	HUD.SHOW_HEIGHT_ON_BLIP(blip, false)
	HUD.SET_BLIP_ROTATION(blip, SYSTEM.CEIL(ENTITY.GET_ENTITY_HEADING(entity)))
	NETWORK.SET_NETWORK_ID_CAN_MIGRATE(entity, false)
	util.create_thread(function()
		while not ENTITY.IS_ENTITY_DEAD(entity) do
			local heading = ENTITY.GET_ENTITY_HEADING(entity)
			HUD.SET_BLIP_ROTATION(blip, SYSTEM.CEIL(heading))
			wait()
		end
		util.remove_blip(blip)
	end)
	return blip
end

	menu.action(cop_root, "Send Police Car", {"sendpolice"}, "", function(on_click)
		local vehicleHash = util.joaat("police3")
		local pedHash = util.joaat("s_m_y_cop_01")
		requestModels(vehicleHash, pedHash)
		
		local targetPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId)
		local pos = ENTITY.GET_ENTITY_COORDS(targetPed)
		local vehicle = entities.create_vehicle(vehicleHash, pos, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
		if not ENTITY.DOES_ENTITY_EXIST(vehicle) then
			return
		end

		local offset = getOffsetFromEntityGivenDistance(vehicle, 50.0)
		local outCoords = v3.new()
		local outHeading = memory.alloc()

		if PATHFIND.GET_CLOSEST_VEHICLE_NODE_WITH_HEADING(offset.x, offset.y, offset.z, outCoords, outHeading, 1, 3.0, 0) then
			ENTITY.SET_ENTITY_COORDS(vehicle, v3.getX(outCoords), v3.getY(outCoords), v3.getZ(outCoords))
			ENTITY.SET_ENTITY_HEADING(vehicle, memory.read_float(outHeading))
			VEHICLE.SET_VEHICLE_SIREN(vehicle, true)
			VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, true)
			for seat = -1, 0 do
				local cop = entities.create_ped(5, pedHash, outCoords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
				PED.SET_PED_INTO_VEHICLE(cop, vehicle, seat)
				PED.SET_PED_RANDOM_COMPONENT_VARIATION(cop, 0)
				local weapon = (seat == -1) and "weapon_pistol" or "weapon_pumpshotgun"
				WEAPON.GIVE_WEAPON_TO_PED(cop, util.joaat(weapon), -1, false, true)
				PED.SET_PED_NEVER_LEAVES_GROUP(cop, true)
				PED.SET_PED_COMBAT_ATTRIBUTES(cop, 1, true)
				PED.SET_PED_AS_COP(cop, true)
				TASK.TASK_COMBAT_PED(cop, targetPed, 0, 16)
				PED.SET_PED_KEEP_TASK(cop, true)
				util.create_tick_handler(function()
					if TASK.GET_SCRIPT_TASK_STATUS(cop, 0x2E85A751) == 7 then
						TASK.CLEAR_PED_TASKS(cop)
						TASK.TASK_SMART_FLEE_PED(cop, PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pId), 1000.0, -1, false, false)
						PED.SET_PED_KEEP_TASK(cop, true)
						return false
					end
					return true
				end)
			end	
		end

		v3.free(outCoords)
		memory.free(outHeading)
		STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(pedHash)
		STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(vehicleHash)
	end)


		menu.action(cop_root, "Send Cracked Police", {"sendswat"}, "Cracked Police Car, now with a 50/50 chance for a cop to be a female. Does not spawn on traffic nodes.", function(on_click)
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local clown_hash = {"368603149", "1581098148"}
		local copf = 368603149
		local copm = 1581098148
        request_model_load(copf)
		request_model_load(copm)
        local van_hash = util.joaat("police3")
        request_model_load(van_hash)
        local coords = ENTITY.GET_ENTITY_COORDS(player_ped, true)
		local outCoords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, math.random(-5, 5), -20, 0.0)
        local van = entities.create_vehicle(van_hash, outCoords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
        for i=-1, VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(van) - 1 do
            local clown = entities.create_ped(1, random(clown_hash), outCoords, 0.0)
            PED.SET_PED_INTO_VEHICLE(clown, van, i)
            if i % 2 == 0 then
                WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201, 1000, false, true)
            else
                WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201, 1000, false, true)
            end
			PED.SET_PED_AS_COP(clown, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(clown, 5, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(clown, 46, true)
			PED.SET_PED_ACCURACY(clown, 100.0)
			PED.SET_PED_HEARING_RANGE(clown, 99999)
			VEHICLE.SET_VEHICLE_DOORS_LOCKED(van, 3)
			VEHICLE.MODIFY_VEHICLE_TOP_SPEED(van, 50)
			PED.SET_PED_RANDOM_COMPONENT_VARIATION(clown, 0)
			PED.SET_PED_MAX_HEALTH(clown, 250)
			ENTITY.SET_ENTITY_PROOFS(ped, false, true, false, false, true, false, false, false)
			ENTITY.SET_ENTITY_HEALTH(clown, 250)
			PED.SET_PED_SHOOT_RATE(clown, 5)
			PED.SET_PED_SUFFERS_CRITICAL_HITS(clown, false)
			if godmodeatk then
				ENTITY.SET_ENTITY_INVINCIBLE(van, true)
			end
			if pcar then 
				PED.SET_PED_COMBAT_ATTRIBUTES(clown, 3, false)
			end
			if d then
				PED.SET_AI_WEAPON_DAMAGE_MODIFIER(clown, 3000000)
			end
            if i == -1 then
                TASK.TASK_VEHICLE_CHASE(clown, player_ped)
				WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201 , 1000, false, true)
				PED.SET_PED_CAN_RAGDOLL(clown, false)
            else
                TASK.TASK_COMBAT_PED(clown, player_ped, 0, 16)
				WEAPON.GIVE_WEAPON_TO_PED(clown, -1357824103, 1000, false, true)
				PED.SET_PED_CAN_RAGDOLL(clown, false)
            end
        end
    end)
	
		menu.action(cop_root, "Send Cracked Noose", {"sendswat"}, "Cracked noose van. Does not spawn on traffic nodes.", function(on_click)
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local clown_hash = -1920001264
        request_model_load(clown_hash)
        local van_hash = util.joaat("fbi2")
        request_model_load(van_hash)
        local coords = ENTITY.GET_ENTITY_COORDS(player_ped, true)
        local spawn_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, math.random(-20, 20), -20, 0.0)
        spawn_pos.x = spawn_pos['x']
        spawn_pos.y = spawn_pos['y']
        spawn_pos.z = spawn_pos['z']
        local van = entities.create_vehicle(van_hash, spawn_pos, ENTITY.GET_ENTITY_HEADING(player_ped))
        for i=-1, VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(van) - 1 do
            local clown = entities.create_ped(1, clown_hash, spawn_pos, 0.0)
            PED.SET_PED_INTO_VEHICLE(clown, van, i)
            if i % 2 == 0 then
                WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201, 1000, false, true)
            else
                WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201, 1000, false, true)
            end
			PED.SET_PED_AS_COP(clown, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(clown, 5, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(clown, 46, true)
			PED.SET_PED_ACCURACY(clown, 100.0)
			PED.SET_PED_HEARING_RANGE(clown, 99999)
			VEHICLE.SET_VEHICLE_DOORS_LOCKED(van, 3)
			VEHICLE.MODIFY_VEHICLE_TOP_SPEED(van, 50)
			PED.SET_PED_RANDOM_COMPONENT_VARIATION(clown, 0)
			PED.SET_PED_MAX_HEALTH(clown, 250)
			ENTITY.SET_ENTITY_PROOFS(ped, false, true, false, false, true, false, false, false)
			ENTITY.SET_ENTITY_HEALTH(clown, 250)
			PED.SET_PED_SHOOT_RATE(clown, 5)
			ENTITY.SET_ENTITY_INVINCIBLE(van, true)
			PED.SET_PED_SUFFERS_CRITICAL_HITS(clown, false)
			if godmodeatk then
				ENTITY.SET_ENTITY_INVINCIBLE(van, true)
			end
			if pcar then 
				PED.SET_PED_COMBAT_ATTRIBUTES(clown, 3, false)
			end
			if d then
				PED.SET_AI_WEAPON_DAMAGE_MODIFIER(clown, 3000000)
			end
            if i == -1 then
                TASK.TASK_VEHICLE_CHASE(clown, player_ped)
				WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201 , 1000, false, true)
				PED.SET_PED_CAN_RAGDOLL(clown, false)
            else
                TASK.TASK_COMBAT_PED(clown, player_ped, 0, 16)
				WEAPON.GIVE_WEAPON_TO_PED(clown, -1357824103, 1000, false, true)
				PED.SET_PED_CAN_RAGDOLL(clown, false)
            end
        end
    end)
	
		menu.action(cop_root, "Send Police Helicopter", {"sendswat"}, "an enhanced police maverick. Nothing too special apart from extra fire rate, health, and accuracy. God mode attribute wont keep the back rotor from being shot out. They also have a tendency to crash.", function(on_click)
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local clown_hash = -1920001264
        request_model_load(clown_hash)
        local van_hash = util.joaat("polmav")
        request_model_load(van_hash)
        local coords = ENTITY.GET_ENTITY_COORDS(player_ped, true)
        local spawn_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, math.random(-30, 30),  math.random(-30, 30), 60)
        spawn_pos.x = spawn_pos['x']
        spawn_pos.y = spawn_pos['y']
        spawn_pos.z = spawn_pos['z']
        local van = entities.create_vehicle(van_hash, spawn_pos, ENTITY.GET_ENTITY_HEADING(player_ped))
        for i=-1, VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(van) - 1 do
            local clown = entities.create_ped(1, clown_hash, spawn_pos, 0.0)
            PED.SET_PED_INTO_VEHICLE(clown, van, i)
            if i % 2 == 0 then
                WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201, 1000, false, true)
            else
                WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201, 1000, false, true)
            end
			VEHICLE.SET_VEHICLE_MOD_KIT(van, 0)
			VEHICLE.SET_VEHICLE_LIVERY(van, 0)
			VEHICLE.SET_VEHICLE_MOD(van, 48, 0)
			PED.SET_PED_AS_COP(clown, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(clown, 5, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(clown, 46, true)
			PED.SET_PED_ACCURACY(clown, 100.0)
			VEHICLE.SET_HELI_BLADES_FULL_SPEED(van)
			PED.SET_PED_HEARING_RANGE(clown, 99999)
			VEHICLE.SET_VEHICLE_DOORS_LOCKED(van, 3)
			VEHICLE.MODIFY_VEHICLE_TOP_SPEED(van, 50)
			PED.SET_PED_RANDOM_COMPONENT_VARIATION(clown, 0)
			PED.SET_PED_MAX_HEALTH(clown, 250)
			ENTITY.SET_ENTITY_PROOFS(ped, false, true, false, false, true, false, false, false)
			ENTITY.SET_ENTITY_HEALTH(clown, 250)
			PED.SET_PED_SHOOT_RATE(clown, 5)
			PED.SET_PED_SUFFERS_CRITICAL_HITS(clown, false)
			if godmodeatk then
				ENTITY.SET_ENTITY_INVINCIBLE(van, true)
			end
			if pcar then 
				PED.SET_PED_COMBAT_ATTRIBUTES(clown, 3, false)
			end
			if d then
				PED.SET_AI_WEAPON_DAMAGE_MODIFIER(clown, 3000000)
			end
            if i == -1 then
                TASK.TASK_VEHICLE_CHASE(clown, player_ped)
				WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201 , 1000, false, true)
				PED.SET_PED_CAN_RAGDOLL(clown, false)
            else
                TASK.TASK_COMBAT_PED(clown, player_ped, 0, 16)
				WEAPON.GIVE_WEAPON_TO_PED(clown, -1357824103, 1000, false, true)
				PED.SET_PED_CAN_RAGDOLL(clown, false)
            end
        end
    end)
	
			menu.action(cop_root, "Send Police Dinghy", {"sendmari"}, "for idiots who thought they could escape by water/ watercraft.", function(on_click)
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
		local clown_hash = 1581098148
        request_model_load(clown_hash)
        local van_hash = util.joaat("predator")
        request_model_load(van_hash)
        local coords = ENTITY.GET_ENTITY_COORDS(player_ped, true)
        local spawn_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, math.random(-20, 20), -20, 0.0)
        spawn_pos.x = spawn_pos['x']
        spawn_pos.y = spawn_pos['y']
        spawn_pos.z = spawn_pos['z']
        local van = entities.create_vehicle(van_hash, spawn_pos, ENTITY.GET_ENTITY_HEADING(player_ped))
        for i=-1, VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(van) - 1 do
            local clown = entities.create_ped(1, clown_hash, spawn_pos, 0.0)
            PED.SET_PED_INTO_VEHICLE(clown, van, i)
            if i % 2 == 0 then
                WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201, 1000, false, true)
            else
                WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201, 1000, false, true)
            end
			VEHICLE.SET_VEHICLE_SIREN(van, true)
			PED.SET_PED_AS_COP(clown, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(clown, 5, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(clown, 46, true)
			PED.SET_PED_ACCURACY(clown, 100.0)
			PED.SET_PED_HEARING_RANGE(clown, 99999)
			VEHICLE.SET_VEHICLE_DOORS_LOCKED(van, 3)
			VEHICLE.MODIFY_VEHICLE_TOP_SPEED(van, 50)
			PED.SET_PED_RANDOM_COMPONENT_VARIATION(clown, 0)
			PED.SET_PED_MAX_HEALTH(clown, 250)
			ENTITY.SET_ENTITY_PROOFS(ped, false, true, true, false, true, false, false, false)
			ENTITY.SET_ENTITY_HEALTH(clown, 250)
			PED.SET_PED_SHOOT_RATE(clown, 5)
			ENTITY.SET_ENTITY_INVINCIBLE(van, true)
			PED.SET_PED_SUFFERS_CRITICAL_HITS(clown, false)
			if pcar then 
				PED.SET_PED_COMBAT_ATTRIBUTES(clown, 3, false)
			end
			if d then
				PED.SET_AI_WEAPON_DAMAGE_MODIFIER(clown, 3000000)
			end
            if i == -1 then
                TASK.TASK_VEHICLE_CHASE(clown, player_ped)
				WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201 , 1000, false, true)
				PED.SET_PED_CAN_RAGDOLL(clown, false)
            else
                TASK.TASK_COMBAT_PED(clown, player_ped, 0, 16)
				WEAPON.GIVE_WEAPON_TO_PED(clown, -1357824103, 1000, false, true)
				PED.SET_PED_CAN_RAGDOLL(clown, false)
            end
        end
    end)
	
			menu.action(army_root, "Send Marine Platoon", {"sendmarp"}, "literally a copy paste of every other vehicle attacker option but with a small marine platoon. Does not spawn on traffic nodes. Vehicle is invulnerable by default.", function(on_click)
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local clown_hash = {"1490458366", "1925237458"}
		local marine1 = 1925237458
		local marine2 = 1490458366
        request_model_load(marine1)
		request_model_load(marine2)
        local van_hash = util.joaat("barracks3")
        request_model_load(van_hash)
        local coords = ENTITY.GET_ENTITY_COORDS(player_ped, true)
        local spawn_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, math.random(-20, 20), -20, 0.0)
        spawn_pos.x = spawn_pos['x']
        spawn_pos.y = spawn_pos['y']
        spawn_pos.z = spawn_pos['z']
        local van = entities.create_vehicle(van_hash, spawn_pos, ENTITY.GET_ENTITY_HEADING(player_ped))
        for i=-1, VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(van) - 1 do
            local clown = entities.create_ped(1, random(clown_hash), spawn_pos, 0.0)
            PED.SET_PED_INTO_VEHICLE(clown, van, i)
            if i % 2 == 0 then
                WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201, 1000, false, true)
            else
                WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201, 1000, false, true)
            end
			PED.SET_PED_AS_COP(clown, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(clown, 5, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(clown, 46, true)
			PED.SET_PED_ACCURACY(clown, 100.0)
			PED.SET_PED_HEARING_RANGE(clown, 99999)
			VEHICLE.SET_VEHICLE_DOORS_LOCKED(van, 3)
			VEHICLE.MODIFY_VEHICLE_TOP_SPEED(van, 50)
			PED.SET_PED_RANDOM_COMPONENT_VARIATION(clown, 0)
			PED.SET_PED_MAX_HEALTH(clown, 250)
			ENTITY.SET_ENTITY_PROOFS(ped, false, true, true, false, true, false, false, false)
			ENTITY.SET_ENTITY_HEALTH(clown, 250)
			PED.SET_PED_SHOOT_RATE(clown, 5)
			ENTITY.SET_ENTITY_INVINCIBLE(van, true)
			PED.SET_PED_SUFFERS_CRITICAL_HITS(clown, false)
			if pcar then 
				PED.SET_PED_COMBAT_ATTRIBUTES(clown, 3, false)
			end
			if d then
				PED.SET_AI_WEAPON_DAMAGE_MODIFIER(clown, 3000000)
			end
            if i == -1 then
                TASK.TASK_VEHICLE_CHASE(clown, player_ped)
				WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201 , 1000, false, true)
				PED.SET_PED_CAN_RAGDOLL(clown, false)
            else
                TASK.TASK_COMBAT_PED(clown, player_ped, 0, 16)
				WEAPON.GIVE_WEAPON_TO_PED(clown, -1357824103, 1000, false, true)
				PED.SET_PED_CAN_RAGDOLL(clown, false)
            end
        end
    end)
	

		menu.action(army_root, "Send Marine Half Track", {"sendmarht"}, "literally a copy paste of every other vehicle attacker option but with aforementioned vehicle. Does not spawn on traffic nodes. Attackers do not leave the vehicle and the gun on the back IS used.", function(on_click)
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local clown_hash = {"1490458366", "1925237458"}
		local marine1 = 1925237458
		local marine2 = 1490458366
        request_model_load(marine1)
		request_model_load(marine2)
        local van_hash = util.joaat("halftrack")
        request_model_load(van_hash)
        local coords = ENTITY.GET_ENTITY_COORDS(player_ped, true)
        local spawn_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, math.random(-20, 20), -20, 0.0)
        spawn_pos.x = spawn_pos['x']
        spawn_pos.y = spawn_pos['y']
        spawn_pos.z = spawn_pos['z']
        local van = entities.create_vehicle(van_hash, spawn_pos, ENTITY.GET_ENTITY_HEADING(player_ped))
        for i=-1, VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(van) - 1 do
            local clown = entities.create_ped(1, random(clown_hash), spawn_pos, 0.0)
            PED.SET_PED_INTO_VEHICLE(clown, van, i)
            if i % 2 == 0 then
                WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201, 1000, false, true)
            else
                WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201, 1000, false, true)
            end
			PED.SET_PED_AS_COP(clown, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(clown, 5, true)
			PED.SET_PED_COMBAT_ATTRIBUTES(clown, 3, false)
            PED.SET_PED_COMBAT_ATTRIBUTES(clown, 46, true)
			PED.SET_PED_ACCURACY(clown, 100.0)
			PED.SET_PED_HEARING_RANGE(clown, 99999)
			VEHICLE.SET_VEHICLE_DOORS_LOCKED(van, 3)
			VEHICLE.MODIFY_VEHICLE_TOP_SPEED(van, 50)
			PED.SET_PED_RANDOM_COMPONENT_VARIATION(clown, 0)
			PED.SET_PED_MAX_HEALTH(clown, 250)
			ENTITY.SET_ENTITY_PROOFS(ped, false, true, true, false, true, false, false, false)
			ENTITY.SET_ENTITY_HEALTH(clown, 250)
			PED.SET_PED_SHOOT_RATE(clown, 5)
			PED.SET_PED_SUFFERS_CRITICAL_HITS(clown, false)
			if pcar then 
				PED.SET_PED_COMBAT_ATTRIBUTES(clown, 3, false)
			end
			if godmodeatk then
				ENTITY.SET_ENTITY_INVINCIBLE(van, true)
			end
			if d then
				PED.SET_AI_WEAPON_DAMAGE_MODIFIER(clown, 3000000)
			end
            if i == -1 then
                TASK.TASK_VEHICLE_CHASE(clown, player_ped)
				WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201 , 1000, false, true)
				PED.SET_PED_CAN_RAGDOLL(clown, false)
            else
                TASK.TASK_COMBAT_PED(clown, player_ped, 0, 16)
				WEAPON.GIVE_WEAPON_TO_PED(clown, -1357824103, 1000, false, true)
				PED.SET_PED_CAN_RAGDOLL(clown, false)
            end
        end
    end)
	
			menu.action(army_root, "Send Marine Crusader", {"sendmarht"}, "literally a copy paste of every other vehicle attacker option but with aforementioned vehicle. Does not spawn on traffic nodes.", function(on_click)
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local clown_hash = {"1490458366", "1925237458"}
		local marine1 = 1925237458
		local marine2 = 1490458366
        request_model_load(marine1)
		request_model_load(marine2)
        local van_hash = util.joaat("crusader")
        request_model_load(van_hash)
        local coords = ENTITY.GET_ENTITY_COORDS(player_ped, true)
        local spawn_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, math.random(-20, 20), -20, 0.0)
        spawn_pos.x = spawn_pos['x']
        spawn_pos.y = spawn_pos['y']
        spawn_pos.z = spawn_pos['z']
        local van = entities.create_vehicle(van_hash, spawn_pos, ENTITY.GET_ENTITY_HEADING(player_ped))
        for i=-1, VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(van) - 1 do
            local clown = entities.create_ped(1, random(clown_hash), spawn_pos, 0.0)
            PED.SET_PED_INTO_VEHICLE(clown, van, i)
            if i % 2 == 0 then
                WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201, 1000, false, true)
            else
                WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201, 1000, false, true)
            end
			PED.SET_PED_AS_COP(clown, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(clown, 5, true)
			PED.SET_PED_COMBAT_ATTRIBUTES(clown, 3, false)
            PED.SET_PED_COMBAT_ATTRIBUTES(clown, 46, true)
			PED.SET_PED_ACCURACY(clown, 100.0)
			PED.SET_PED_HEARING_RANGE(clown, 99999)
			VEHICLE.SET_VEHICLE_DOORS_LOCKED(van, 3)
			VEHICLE.MODIFY_VEHICLE_TOP_SPEED(van, 50)
			PED.SET_PED_RANDOM_COMPONENT_VARIATION(clown, 0)
			PED.SET_PED_MAX_HEALTH(clown, 250)
			ENTITY.SET_ENTITY_PROOFS(ped, false, true, true, false, true, false, false, false)
			ENTITY.SET_ENTITY_HEALTH(clown, 250)
			PED.SET_PED_SHOOT_RATE(clown, 5)
			PED.SET_PED_SUFFERS_CRITICAL_HITS(clown, false)
			if pcar then 
				PED.SET_PED_COMBAT_ATTRIBUTES(clown, 3, false)
			end
			if godmodeatk then
				ENTITY.SET_ENTITY_INVINCIBLE(van, true)
			end
			if d then
				PED.SET_AI_WEAPON_DAMAGE_MODIFIER(clown, 3000000)
			end
            if i == -1 then
                TASK.TASK_VEHICLE_CHASE(clown, player_ped)
				WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201 , 1000, false, true)
				PED.SET_PED_CAN_RAGDOLL(clown, false)
            else
                TASK.TASK_COMBAT_PED(clown, player_ped, 0, 16)
				WEAPON.GIVE_WEAPON_TO_PED(clown, -1357824103, 1000, false, true)
				PED.SET_PED_CAN_RAGDOLL(clown, false)
            end
        end
    end)
	
			menu.action(army_root, "Send Marine Zhaba", {"sendmarzh"}, "literally a copy paste of every other vehicle attacker option but with aforementioned vehicle. Does not spawn on traffic nodes.", function(on_click)
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local clown_hash = {"1490458366", "1925237458"}
		local marine1 = 1925237458
		local marine2 = 1490458366
        request_model_load(marine1)
		request_model_load(marine2)
        local van_hash = util.joaat("technical2")
        request_model_load(van_hash)
        local coords = ENTITY.GET_ENTITY_COORDS(player_ped, true)
        local spawn_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, math.random(-20, 20), -20, 0.0)
        spawn_pos.x = spawn_pos['x']
        spawn_pos.y = spawn_pos['y']
        spawn_pos.z = spawn_pos['z']
        local van = entities.create_vehicle(van_hash, spawn_pos, ENTITY.GET_ENTITY_HEADING(player_ped))
        for i=-1, VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(van) - 1 do
            local clown = entities.create_ped(1, random(clown_hash), spawn_pos, 0.0)
            PED.SET_PED_INTO_VEHICLE(clown, van, i)
            if i % 2 == 0 then
                WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201, 1000, false, true)
            else
                WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201, 1000, false, true)
            end
			PED.SET_PED_AS_COP(clown, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(clown, 5, true)
			PED.SET_PED_COMBAT_ATTRIBUTES(clown, 3, false)
            PED.SET_PED_COMBAT_ATTRIBUTES(clown, 46, true)
			PED.SET_PED_ACCURACY(clown, 100.0)
			TASK.SET_PED_PATH_PREFER_TO_AVOID_WATER(clown, false)
			PED.SET_PED_HEARING_RANGE(clown, 99999)
			VEHICLE.SET_VEHICLE_DOORS_LOCKED(van, 3)
			VEHICLE.MODIFY_VEHICLE_TOP_SPEED(van, 50)
			PED.SET_PED_RANDOM_COMPONENT_VARIATION(clown, 0)
			PED.SET_PED_MAX_HEALTH(clown, 250)
			ENTITY.SET_ENTITY_PROOFS(ped, false, true, true, false, true, false, false, false)
			ENTITY.SET_ENTITY_HEALTH(clown, 250)
			PED.SET_PED_SHOOT_RATE(clown, 5)
			PED.SET_PED_SUFFERS_CRITICAL_HITS(clown, false)
			if pcar then 
				PED.SET_PED_COMBAT_ATTRIBUTES(clown, 3, false)
			end
			if godmodeatk then
				ENTITY.SET_ENTITY_INVINCIBLE(van, true)
			end
			if d then
				PED.SET_AI_WEAPON_DAMAGE_MODIFIER(clown, 3000000)
			end
            if i == -1 then
                TASK.TASK_VEHICLE_CHASE(clown, player_ped)
				WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201 , 1000, false, true)
				PED.SET_PED_CAN_RAGDOLL(clown, false)
            else
                TASK.TASK_COMBAT_PED(clown, player_ped, 0, 16)
				WEAPON.GIVE_WEAPON_TO_PED(clown, -1357824103, 1000, false, true)
				PED.SET_PED_CAN_RAGDOLL(clown, false)
            end
        end
    end)
	
	
			menu.action(army_root, "Send Marine Insurgent", {"sendmari"}, "literally a copy paste of every other vehicle attacker option but with marines. Does not spawn on traffic nodes.", function(on_click)
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local clown_hash = {"1490458366", "1925237458"}
		local marine1 = 1925237458
		local marine2 = 1490458366
        request_model_load(marine1)
		request_model_load(marine2)
        local van_hash = util.joaat("insurgent")
        request_model_load(van_hash)
        local coords = ENTITY.GET_ENTITY_COORDS(player_ped, true)
        local spawn_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, math.random(-20, 20), -20, 0.0)
        spawn_pos.x = spawn_pos['x']
        spawn_pos.y = spawn_pos['y']
        spawn_pos.z = spawn_pos['z']
        local van = entities.create_vehicle(van_hash, spawn_pos, ENTITY.GET_ENTITY_HEADING(player_ped))
        for i=-1, VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(van) - 1 do
            local clown = entities.create_ped(1, random(clown_hash), spawn_pos, 0.0)
            PED.SET_PED_INTO_VEHICLE(clown, van, i)
            if i % 2 == 0 then
                WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201, 1000, false, true)
            else
                WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201, 1000, false, true)
            end
			PED.SET_PED_AS_COP(clown, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(clown, 5, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(clown, 46, true)
			PED.SET_PED_ACCURACY(clown, 100.0)
			PED.SET_PED_HEARING_RANGE(clown, 99999)
			VEHICLE.SET_VEHICLE_DOORS_LOCKED(van, 3)
			VEHICLE.MODIFY_VEHICLE_TOP_SPEED(van, 50)
			PED.SET_PED_RANDOM_COMPONENT_VARIATION(clown, 0)
			PED.SET_PED_MAX_HEALTH(clown, 250)
			ENTITY.SET_ENTITY_PROOFS(ped, false, true, true, false, true, false, false, false)
			ENTITY.SET_ENTITY_HEALTH(clown, 250)
			PED.SET_PED_SHOOT_RATE(clown, 5)
			PED.SET_PED_SUFFERS_CRITICAL_HITS(clown, false)
			if pcar then 
				PED.SET_PED_COMBAT_ATTRIBUTES(clown, 3, false)
			end
			if d then
				PED.SET_AI_WEAPON_DAMAGE_MODIFIER(clown, 3000000)
			end
			if godmodeatk then
				ENTITY.SET_ENTITY_INVINCIBLE(van, true)
			end
            if i == -1 then
                TASK.TASK_VEHICLE_CHASE(clown, player_ped)
				WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201 , 1000, false, true)
				PED.SET_PED_CAN_RAGDOLL(clown, false)
            else
                TASK.TASK_COMBAT_PED(clown, player_ped, 0, 16)
				WEAPON.GIVE_WEAPON_TO_PED(clown, -1357824103, 1000, false, true)
				PED.SET_PED_CAN_RAGDOLL(clown, false)
            end
        end
    end)

			menu.action(army_root, "Send Marine Insurgent (npc cant exit)", {"sendmari2"}, "same as above but they cant leave the vehicle. Does not spawn on traffic nodes.", function(on_click)
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local clown_hash = {"1490458366", "1925237458"}
		local marine1 = 1925237458
		local marine2 = 1490458366
        request_model_load(marine1)
		request_model_load(marine2)
        local van_hash = util.joaat("insurgent")
        request_model_load(van_hash)
        local coords = ENTITY.GET_ENTITY_COORDS(player_ped, true)
        local spawn_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, math.random(-20, 20), -20, 0.0)
        spawn_pos.x = spawn_pos['x']
        spawn_pos.y = spawn_pos['y']
        spawn_pos.z = spawn_pos['z']
        local van = entities.create_vehicle(van_hash, spawn_pos, ENTITY.GET_ENTITY_HEADING(player_ped))
        for i=-1, VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(van) - 1 do
            local clown = entities.create_ped(1, random(clown_hash), spawn_pos, 0.0)
            PED.SET_PED_INTO_VEHICLE(clown, van, i)
            if i % 2 == 0 then
                WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201, 1000, false, true)
            else
                WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201, 1000, false, true)
            end
			PED.SET_PED_AS_COP(clown, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(clown, 5, true)
			PED.SET_PED_COMBAT_ATTRIBUTES(clown, 3, false)
            PED.SET_PED_COMBAT_ATTRIBUTES(clown, 46, true)
			PED.SET_PED_ACCURACY(clown, 100.0)
			PED.SET_PED_HEARING_RANGE(clown, 99999)
			VEHICLE.SET_VEHICLE_DOORS_LOCKED(van, 3)
			VEHICLE.MODIFY_VEHICLE_TOP_SPEED(van, 50)
			PED.SET_PED_RANDOM_COMPONENT_VARIATION(clown, 0)
			PED.SET_PED_MAX_HEALTH(clown, 250)
			ENTITY.SET_ENTITY_PROOFS(ped, false, true, true, false, true, false, false, false)
			ENTITY.SET_ENTITY_HEALTH(clown, 250)
			PED.SET_PED_SHOOT_RATE(clown, 5)
			PED.SET_PED_SUFFERS_CRITICAL_HITS(clown, false)
			if d then
				PED.SET_AI_WEAPON_DAMAGE_MODIFIER(clown, 3000000)
			end
			if godmodeatk then
				ENTITY.SET_ENTITY_INVINCIBLE(van, true)
			end
            if i == -1 then
                TASK.TASK_VEHICLE_CHASE(clown, player_ped)
				WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201 , 1000, false, true)
				PED.SET_PED_CAN_RAGDOLL(clown, false)
            else
                TASK.TASK_COMBAT_PED(clown, player_ped, 0, 16)
				WEAPON.GIVE_WEAPON_TO_PED(clown, -1357824103, 1000, false, true)
				PED.SET_PED_CAN_RAGDOLL(clown, false)
            end
        end
    end)
	
			menu.action(army_root, "Send Marine Khanjali", {"sendmari"}, "literally a copy paste of every other vehicle attacker option but with marines. Does not spawn on traffic nodes. Attackers do not leave the vehicle by default.", function(on_click)
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local clown_hash = {"1490458366", "1925237458"}
		local marine1 = 1925237458
		local marine2 = 1490458366
        request_model_load(marine1)
		request_model_load(marine2)
        local van_hash = util.joaat("khanjali")
        request_model_load(van_hash)
        local coords = ENTITY.GET_ENTITY_COORDS(player_ped, true)
        local spawn_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, math.random(-20, 20), -20, 0.0)
        spawn_pos.x = spawn_pos['x']
        spawn_pos.y = spawn_pos['y']
        spawn_pos.z = spawn_pos['z']
        local van = entities.create_vehicle(van_hash, spawn_pos, ENTITY.GET_ENTITY_HEADING(player_ped))
        for i=-1, VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(van) - 1 do
            local clown = entities.create_ped(1, random(clown_hash), spawn_pos, 0.0)
            PED.SET_PED_INTO_VEHICLE(clown, van, i)
            if i % 2 == 0 then
                WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201, 1000, false, true)
            else
                WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201, 1000, false, true)
            end
			PED.SET_PED_AS_COP(clown, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(clown, 5, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(clown, 46, true)
			PED.SET_PED_COMBAT_ATTRIBUTES(clown, 3, false)
			PED.SET_PED_ACCURACY(clown, 100.0)
			PED.SET_PED_HEARING_RANGE(clown, 99999)
			VEHICLE.SET_VEHICLE_DOORS_LOCKED(van, 3)
			VEHICLE.MODIFY_VEHICLE_TOP_SPEED(van, 50)
			PED.SET_PED_RANDOM_COMPONENT_VARIATION(clown, 0)
			PED.SET_PED_MAX_HEALTH(clown, 250)
			ENTITY.SET_ENTITY_PROOFS(ped, false, true, true, false, true, false, false, false)
			ENTITY.SET_ENTITY_HEALTH(clown, 250)
			PED.SET_PED_SHOOT_RATE(clown, 5)
			PED.SET_PED_SUFFERS_CRITICAL_HITS(clown, false)
			if pcar then 
				PED.SET_PED_COMBAT_ATTRIBUTES(clown, 3, false)
			end
			if godmodeatk then
				ENTITY.SET_ENTITY_INVINCIBLE(van, true)
			end
			if d then
				PED.SET_AI_WEAPON_DAMAGE_MODIFIER(clown, 3000000)
			end
            if i == -1 then
                TASK.TASK_VEHICLE_CHASE(clown, player_ped)
				WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201 , 1000, false, true)
				PED.SET_PED_CAN_RAGDOLL(clown, false)
            else
                TASK.TASK_COMBAT_PED(clown, player_ped, 0, 16)
				WEAPON.GIVE_WEAPON_TO_PED(clown, -1357824103, 1000, false, true)
				PED.SET_PED_CAN_RAGDOLL(clown, false)
            end
        end
    end)
	

	
			menu.action(army_root, "Send Marine APC", {"sendmari"}, "literally a copy paste of every other vehicle attacker option but with an APC. Does not spawn on traffic nodes. Enemies CAN leave vehicle, but for some reason they don't. They can follow into water and thru water, but are pretty slow and might get stuck.", function(on_click)
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local clown_hash = {"1490458366", "1925237458"}
		local marine1 = 1925237458
		local marine2 = 1490458366
        request_model_load(marine1)
		request_model_load(marine2)
        local van_hash = util.joaat("apc")
        request_model_load(van_hash)
        local coords = ENTITY.GET_ENTITY_COORDS(player_ped, true)
        local spawn_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, math.random(-20, 20), -20, 0.0)
        spawn_pos.x = spawn_pos['x']
        spawn_pos.y = spawn_pos['y']
        spawn_pos.z = spawn_pos['z']
        local van = entities.create_vehicle(van_hash, spawn_pos, ENTITY.GET_ENTITY_HEADING(player_ped))
        for i=-1, VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(van) - 1 do
            local clown = entities.create_ped(1, random(clown_hash), spawn_pos, 0.0)
            PED.SET_PED_INTO_VEHICLE(clown, van, i)
            if i % 2 == 0 then
                WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201, 1000, false, true)
            else
                WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201, 1000, false, true)
            end
			PED.SET_PED_AS_COP(clown, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(clown, 5, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(clown, 46, true)
			PED.SET_PED_ACCURACY(clown, 100.0)
			TASK.SET_PED_PATH_PREFER_TO_AVOID_WATER(clown, false)
			PED.SET_PED_HEARING_RANGE(clown, 99999)
			VEHICLE.SET_VEHICLE_DOORS_LOCKED(van, 3)
			VEHICLE.MODIFY_VEHICLE_TOP_SPEED(van, 50)
			PED.SET_PED_RANDOM_COMPONENT_VARIATION(clown, 0)
			PED.SET_PED_MAX_HEALTH(clown, 250)
			ENTITY.SET_ENTITY_PROOFS(ped, false, true, true, false, true, false, false, false)
			ENTITY.SET_ENTITY_HEALTH(clown, 250)
			PED.SET_PED_SHOOT_RATE(clown, 5)
			PED.SET_PED_SUFFERS_CRITICAL_HITS(clown, false)
			if pcar then 
				PED.SET_PED_COMBAT_ATTRIBUTES(clown, 3, false)
			end
			if d then
				PED.SET_AI_WEAPON_DAMAGE_MODIFIER(clown, 3000000)
			end
			if godmodeatk then
				ENTITY.SET_ENTITY_INVINCIBLE(van, true)
			end
            if i == -1 then
                TASK.TASK_VEHICLE_CHASE(clown, player_ped)
				WEAPON.GIVE_WEAPON_TO_PED(clown, 584646201 , 1000, false, true)
				PED.SET_PED_CAN_RAGDOLL(clown, false)
            else
                TASK.TASK_COMBAT_PED(clown, player_ped, 0, 16)
				WEAPON.GIVE_WEAPON_TO_PED(clown, -1357824103, 1000, false, true)
				PED.SET_PED_CAN_RAGDOLL(clown, false)
            end
        end
    end)
	



    menu.action(attackers_root, "Helicopter attack", {"heliattack"}, "Send an attack chopper to attack the player. Seems to be broken at the moment and I cant seem to decipher why.", function(on_click)
        send_aircraft_attacker(1543134283, util.joaat("mp_m_bogdangoon"), pid)
    end)
	 
gWeapons = {												
	WT_PIST 		= "weapon_pistol",
	WT_STUN			= "weapon_stungun",
	WT_RAYPISTOL	= "weapon_raypistol",
	WT_RIFLE_SCBN 	= "weapon_specialcarbine",
	WT_SG_PMP		= "weapon_pumpshotgun",
	WT_MG			= "weapon_mg",
	WT_RIFLE_HVY 	= "weapon_heavysniper",
	WT_MINIGUN		= "weapon_minigun",
	WT_RPG			= "weapon_rpg",
	WT_RAILGUN 		= "weapon_railgun",
	WT_CMPGL 		= "weapon_compactlauncher",
	WT_EMPL 		= "weapon_emplauncher"
}


gMeleeWeapons = {
	WT_UNARMED 		= "weapon_unarmed",
	WT_KNIFE		= "weapon_knife",
	WT_MACHETE		= "weapon_machete",
	WT_BATTLEAXE	= "weapon_battleaxe",
	WT_WRENCH		= "weapon_wrench",
	WT_HAMMER		= "weapon_hammer",
	WT_BAT			= "weapon_bat"
}


-- here you can modify which peds are available to choose
-- ["name shown in Stand"] = "ped model ID"
gPedModels = {
	["Prisoner"] 				= "s_m_y_prismuscl_01",
	["Mime"] 					= "s_m_y_mime",
	["Astronaut"] 				= "s_m_m_movspace_01",
	["SWAT"] 					= "s_m_y_swat_01",
	["Ballas Ganster"] 			= "csb_ballasog",
	["Marine"] 					= "csb_ramp_marine",
	["Female Police Officer"] 	= "s_f_y_cop_01",
	["Male Police Officer"] 	= "s_m_y_cop_01",
	["Jesus"] 					= "u_m_m_jesus_01",
	["Zombie"] 					= "u_m_y_zombie_01",
	["Juggernaut"] 				= "u_m_y_juggernaut_01",
	["Clown"] 					= "s_m_y_clown_01",
	["Hooker"] 					= "s_f_y_hooker_01",
	["Altruist"] 				= "a_m_y_acult_01"
}


    menu.toggle(ls_naughty, "Swiss cheese", {"swisscheese"}, "Rains a shit ton of bullets on the player. Anonymously.", function(on)
        if on then
            bullet_rain = true
            bullet_rain_target = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            bullet_rain_scapegoat = get_random_ped()
        else
            bullet_rain = false
        end
    end)

    menu.slider(ls_naughty, "Swiss cheese damage", {"swisscheesedmg"}, "Sets what damage swiss cheese option should do", 0, 1000, 0, 100, function(s)
        swiss_cheese_dmg = s
      end)
    log("Finished adding actions for player " .. pid)
end

bm_meth = false
menu.toggle(business_root, "Meth", {"bm_meth"}, "", function(on)
    if on then
        bm_meth = true
        bus_ticks = bus_ticks + 1
    else
        bm_meth = false
        bus_ticks = bus_ticks - 1
    end
end, false)

bm_weed = false
menu.toggle(business_root, "Weed", {"bm_weed"}, "", function(on)
    if on then
        bm_weed = true
        bus_ticks = bus_ticks + 1
    else
        bm_weed = false
        bus_ticks = bus_ticks - 1
    end
end, false)

bm_documents = false
menu.toggle(business_root, "Forgery", {"bm_forgery"}, "", function(on)
    if on then
        bm_documents = true
        bus_ticks = bus_ticks + 1
    else
        bm_documents = false
        bus_ticks = bus_ticks - 1
    end
end, false)

bm_cocaine = false
menu.toggle(business_root, "Cocaine", {"bm_cocaine"}, "", function(on)
    if on then
        bm_cocaine = true
        bus_ticks = bus_ticks + 1
    else
        bm_cocaine = false
        bus_ticks = bus_ticks - 1
    end
end, false)

bm_cash = false
menu.toggle(business_root, "Cash", {"bm_cash"}, "", function(on)
    if on then
        bm_cash = true
        bus_ticks = bus_ticks + 1
    else
        bm_cash = false
        bus_ticks = bus_ticks - 1
    end
end, false)

bm_cocaine = false
menu.toggle(business_root, "Bunker", {"bm_bunker"}, "", function(on)
    if on then
        bm_bunker = true
        bus_ticks = bus_ticks + 1
    else
        bm_bunker = false
        bus_ticks = bus_ticks - 1
    end
end, false)

bm_hub = false
menu.toggle(business_root, "Hub product counts", {"bm_hub"}, "", function(on)
    if on then
        bm_hub = true
        bus_ticks = bus_ticks + 1
    else
        bm_hub = false
        bus_ticks = bus_ticks - 1
    end
end, false)


bm_nightclubsafe = false
menu.toggle(business_root, "Nightclub safe", {"bm_safe"}, "", function(on)
    if on then
        bm_nightclubsafe = true
        bus_ticks = bus_ticks + 1
    else
        bm_nightclubsafe = false
        bus_ticks = bus_ticks - 1
    end
end, false)

bus_comms = {"bmsafe", "bmhub", "bmbunker", "bmcash", "bmcocaine", "bmforgery", "bmweed", "bmmeth"}
menu.action(business_root, "Turn all ON", {"bm_allon"}, "Turns all the options here ON", function(on_click)
    for k,val in pairs(bus_comms) do
        menu.trigger_commands(val .. " on")
    end
end)

menu.action(business_root, "Turn all OFF", {"bm_alloff"}, "Turns all the options here OFF", function(on_click)
    for k,val in pairs(bus_comms) do
        menu.trigger_commands(val .. " off")
    end
end)


menu.toggle(business_root, "Underlay", {"bm_underlay"}, "Shows an underlay under the text. Might be positioned wrong if I fucked up my math lol", function(on)
    bm_underlay = on
end, false)

menu.slider(business_root, "Display X offset", {"bmxoffset"}, "Offset the BM display by x * 0.00x", -100, 100, 0, 1, function(s)
    bm_xoffset = s*0.001
end)

menu.slider(business_root, "Underlay X offset", {"bmuoffset"}, "Offset the underlay display by x * 0.0x", -100, 100, 0, 1, function(s)
    bm_uoffset = s*0.01
end)

menu.slider(business_root, "Underlay width", {"bmxoffset"}, "Underlay width * 0.01", 0, 100, 7, 1, function(s)
    bm_uwidth = s*0.01
end)

function attachto(offx, offy, offz, pid, angx, angy, angz, hash, bone, isnpc, isveh)
    local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
    local bone = PED.GET_PED_BONE_INDEX(ped, bone)
    local coords = ENTITY.GET_ENTITY_COORDS(ped, true)
    coords.x = coords['x']
    coords.y = coords['y']
    coords.z = coords['z']
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

menu.action(ap_vaddons, "Tube", {"apvaddontube"}, "", function(on_click)
    give_all_car_addon(util.joaat("stt_prop_stunt_tube_speedb"), true, 90.0)
end)

menu.action(ap_vaddons, "Lochness monster", {"apvaddonloch"}, "", function(on_click)
    give_all_car_addon(util.joaat("h4_prop_h4_loch_monster"), true, -90.0)
end)

menu.action(ap_vaddons, "Custom model", {"customvaddonmdl"}, "Input a custom model to attach. The model string, NOT the hash.", function(on_click)
    util.toast("Please input the model hash")
    menu.show_command_box("customvaddonmdl ")
end, function(on_command)
    local hash = util.joaat(on_command)
    give_all_car_addon(hash, true, 0.0)
end)

menu.action(apgivecar_root, "Space docker", {"apspacedocker"}, "beep boop", function(on_click)
    give_vehicle_all(util.joaat("dune2"))
end)

menu.action(apgivecar_root, "Clown van", {"apclownvan"}, "what u are", function(on_click)
    give_vehicle_all(util.joaat("speedo2"))
end)

menu.action(apgivecar_root, "Krieger", {"apkrieger"}, "its fast lol", function(on_click)
    give_vehicle_all(util.joaat("krieger"))
end)

menu.action(apgivecar_root, "Kuruma", {"apkuruma"}, "the 12 year old\'s dream", function(on_click)
    give_vehicle_all(util.joaat("kuruma"))
end)

menu.action(apgivecar_root, "Insurgent", {"apinsurgent"}, "the 10 year old\'s dream", function(on_click)
    give_vehicle_all(util.joaat("insurgent"))
end)

menu.action(apgivecar_root, "Neon", {"apneon"}, "electric car underrated and go brrt", function(on_click)
    give_vehicle_all(util.joaat("neon"))
end)

menu.action(apgivecar_root, "Akula", {"apakula"}, "a good heli", function(on_click)
    give_vehicle_all(util.joaat("akula"))
end)

menu.action(apgivecar_root, "Alpha Z-1", {"apakula"}, "super fucking fast plane lol", function(on_click)
    give_vehicle_all(util.joaat("alphaz1"))
end)

menu.action(apgivecar_root, "Rogue", {"aprogue"}, "good attak plane", function(on_click)
    give_vehicle_all(util.joaat("rogue"))
end)

menu.action(apgivecar_root, "Input custom vehicle name", {"apcarinput2"}, "Input a custom vehicle name to spawn (the NAME, NOT HASH)", function(on_click)
    util.toast("Please type the vehicle name")
    menu.show_command_box("apcarinput2 ")
end, function(on_command)
    give_vehicle_all(util.joaat(on_command))
end)

---menu.action(apnice_root, "Give bodyguard", {"apbodyguards"}, "they protec", function(on_click)
---    give_bodyguard_all()
---end)

menu.action(apnaughty_root, "Session-wide chat", {"sessionwidechat"}, "Makes everyone in the session except you say something.", function(on_click)
    util.toast("Please type what you want the entire session to say.")
    menu.show_command_box("sessionwidechat ")
end, function(on_command)
    if #on_command > 140 then
        util.toast("That message is too long to show fully! I just saved you from humiliation.")
        return
    end
    for k,p in pairs(players.list(false, true, true)) do
        local name = PLAYER.GET_PLAYER_NAME(p)
        menu.trigger_commands("chatas" .. name .. " on")
        chat.send_message(on_command, false, true, true)
        menu.trigger_commands("chatas" .. name .. " off")
    end
end)

function get_best_mug_target()
    local most = 0
    local mostp = 0
    for k,p in pairs(players.list(false, true, true)) do
        cur_wallet = players.get_wallet(p)
        if cur_wallet > most then
            most = cur_wallet
            mostp = p
        end
    end
    if cur_wallet == nil then
        util.toast("You are alone. Cannot find best mug target.")
        return
    end
    if most ~= 0 then
        return PLAYER.GET_PLAYER_NAME(mostp) .. " has the most money in their wallet ($" .. most .. "). Maybe go mug them."
    else
        util.toast("Could not find best mug target.")
        return nil
    end

end
menu.action(apnaughty_root, "Toast best mug target", {"best mug"}, "Toasts you the player with the most wallet money, so you can mug them nicely.", function(on_click)
    local ret = get_best_mug_target()
    if ret ~= nil then
        util.toast(ret)
    end
end)

menu.action(apnaughty_root, "Announce best mug target", {"best mug"}, "Announces the player with the most wallet money, so people can mug them nicely.", function(on_click)
    local ret = get_best_mug_target()
    if ret ~= nil then
        chat.send_message(ret, false, true, true)
    end
end)

show_voicechatters = false
menu.toggle(online_root, "Show me who\'s using voicechat", {"showvoicechat"}, "Shows who is actually using GTA:O voice chat, in 2021. Which is likely to be nobody. So this is a bitch to test. but.", function(on)
    ped = PLAYER.PLAYER_PED_ID()
    if on then
        show_voicechatters = true
        mod_uses("player", 1)
    else
        show_voicechatters = false
        mod_uses("player", -1)
    end
end, false)

antioppressor = false
menu.toggle(apnaughty_root, "Antioppressor", {"antioppressor"}, "Never see a fly again! Automatically deletes all active oppressor mkII\'s.", function(on)
    if on then
        antioppressor = true
        mod_uses("player", 1)
    else
        antioppressor = false
        mod_uses("player", -1)
    end
end, false)

menu.toggle(apnaughty_root, "Mean antioppressor", {"meanantioppressor"}, "Requires antioppressor to be on. Simply tells antioppressor to kick the player instead of messing with explosives.", function(on)
    meanantioppressor = on
end, false)

aptloop = false
menu.toggle(apnaughty_root, "Apartment tp loop", {"apartmenttploop"}, "Please advise, extremely toxic", function(on)
    aptloop = on
end, false)

noarmedvehs = false
menu.toggle(apnaughty_root, "Delete armed vehicles", {"noarmedvehs"}, "Deletes any vehicle with a weapon. IMPORTANT: the game reports some false positives, ie considers a camera on a heli a \"gun\"..", function(on)
    if on then
        noarmedvehs = true
        mod_uses("player", 1)
    else
        noarmedvehs = false
        mod_uses("player", -1)
    end
end, false)


function unlock_tunable(tunable)
    local tunable_offset_offset = 0
    local addr = memory.script_global(262145 + (tunable + tunable_offset_offset))
    memory.write_byte(addr, 1)
end

function unlock_tunable_range(tunable, count)
    for i=tunable, tunable+count do
        unlock_tunable(i)
    end
end

menu.action(clothingunlock_root, "Arena war", {"clothingarena"}, "For redundancy. Stand already has this.", function(on_click)
    menu.trigger_commands("unlockarenawarclothing")
    util.toast("Clothing unlocked! Give it some time to show up.")
end)

menu.action(clothingunlock_root, "Casino heist", {"clothingcasino"}, "For redundancy. Stand already has this.", function(on_click)
    menu.trigger_commands("unlockcasinoheistclothing")
    util.toast("Clothing unlocked! Give it some time to show up.")
end)


menu.action(clothingunlock_root, "Cayo Perico", {"clothingcayo"}, "Unlock this clothing set", function(on_click)
    unlock_tunable_range(29689, 19)
    unlock_tunable_range(26709, 3)
    unlock_tunable_range(29713, 4)
    unlock_tunable_range(29718, 11)
    unlock_tunable_range(29730, 11)
    unlock_tunable_range(29742, 15)
    unlock_tunable_range(29762, 19)
    unlock_tunable_range(30346, 35)
    unlock_tunable_range(30391, 5)
    util.toast("Clothing unlocked! Give it some time to show up.")
end)

kicktryhardnames = false
menu.toggle(online_root, "Auto-crash/kick tryhard names", {"kicktryhardnames"}, "Crashes, then kicks (for if the crash didn\'t succeed) those losers with only L\'s and I\'s in their name, in such a way that makes them hard to report. Fuck them.", function(on)
    kicktryhardnames = on
end, false)

function get_random_player()
    local list = players.list(false, false, true)
    return list[math.random(#list)]
end

peacefulsession = true
menu.toggle(online_root, "Peaceful session", {"peacefulsess"}, "Kicks people who PvP. Does NOT take self defense into account.", function(on)
    if on then
        peacefulsession = true
        peacefulsess_thread()
        local ran = PLAYER.GET_PLAYER_NAME(get_random_player())
        menu.trigger_commands("chatas" .. ran .. " on")
        chat.send_message("Peaceful session is now ON! Don\'t kill each other or you will be auto-kicked!", false, true, true)
        menu.trigger_commands("chatas" .. ran .. " off")
        mod_uses("player", 1)
    else
        peacefulsession = false
        mod_uses("player", -1)
    end
end, false)

kicktryhardkds = false
menu.toggle(online_root, "Auto-kick high-KD tryhards", {"kicktryhardkds"}, "Auto-kicks tryhards with an obsessively high KD. Might piss off a lot of modders, but so be it.", function(on)
    kicktryhardkds = on
end, false)

local kdthres = 6
menu.slider(online_root, "Auto-kick KD threshold", {"autokickkd"}, "Threshold players must pass in their KD to be autokicked, if enabled.", 1, 100, 6, 1, function(s)
    kdthres = 6
  end)

local infibounty = false
menu.toggle(apnaughty_root, "Infibounty", {"infibounty"}, "Applies $10k bounty to all players, every 60 seconds", function(on)
    if on then
        infibounty = true
        start_infibounty_thread()
    else
        infibounty = false
    end
end, false)

christianity = false
menu.toggle(apnaughty_root, "Christianity", {"christianity"}, "Punishes players who visit the strip club", function(on)
    if on then
        christianity = true
        mod_uses("player", 1)
    else
        christianity = false
        mod_uses("player", -1)
    end
end, false)

menu.action(apforcedacts_root, "Teleport vehicles to me", {"tpavtome"}, "This MAY OR MAY NOT WORK. It is NOT a bug if this does not work.", function(on_click)
    tp_all_player_cars_to_coords(ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true))
end)

menu.action(apforcedacts_root, "Teleport vehicles to waypoint", {"tpavtoway"}, "This MAY OR MAY NOT WORK. It is NOT a bug if this does not work.", function(on_click)
    local c = get_waypoint_coords()
    if c ~= nil then
        tp_all_player_cars_to_coords(c)
    end
end)

menu.action(apforcedacts_root, "Teleport vehicles to Maze Bank helipad", {"tpavtomaze"}, "This MAY OR MAY NOT WORK. It is NOT a bug if this does not work.", function(on_click)
    local c = {}
    c.x = -75.261375
    c.y = -818.674
    c.z = 326.17517
    tp_all_player_cars_to_coords(c)
end)

menu.action(apforcedacts_root, "Teleport vehicles to Mt. Chiliad", {"tpavtomtch"}, "This MAY OR MAY NOT WORK. It is NOT a bug if this does not work.", function(on_click)
    local c = {}
    c.x = 492.30
    c.y = 5589.44
    c.z = 794.28
    tp_all_player_cars_to_coords(c)
end)

menu.action(apforcedacts_root, "Teleport vehicles deep underwater", {"tpavunderwater"}, "This MAY OR MAY NOT WORK. It is NOT a bug if this does not work.", function(on_click)
    local c = {}
    c.x = 4497.2207
    c.y = 8028.3086
    c.z = -32.635174
    tp_all_player_cars_to_coords(c)
end)

menu.action(apforcedacts_root, "Teleport vehicles into LSC", {"tpavlsc"}, "This MAY OR MAY NOT WORK. It is NOT a bug if this does not work.", function(on_click)
    local c = {}
    c.x = -353.84512
    c.y = -135.59108
    c.z = 39.009624
    tp_all_player_cars_to_coords(c)
end)

menu.action(apforcedacts_root, "Teleport vehicles into SCP-173 cell", {"tpavscp"}, "This MAY OR MAY NOT WORK. It is NOT a bug if this does not work.", function(on_click)
    local c = {}
    c.x = 1642.8401
    c.y = 2570.7695
    c.z = 45.564854
    tp_all_player_cars_to_coords( c)
end)

menu.action(apforcedacts_root, "Teleport vehicles into large cell", {"tpavcell"}, "This MAY OR MAY NOT WORK. It is NOT a bug if this does not work.", function(on_click)
    local c = {}
    c.x = 1737.1896
    c.y = 2634.897
    c.z = 45.56497
    tp_all_player_cars_to_coords(c)
end)
--tp_player_car_to_coords(pid, vector3(75.261375, -818.674, 326.17517))


menu.action(apnaughty_root, "Crash all", {"crashall"}, "Crashes everyone using a basic yet working method I discovered. 2take1 punching the air rn. Please don\'t abuse it.", function(on_click)
    -- obfuscation to prevent patching
    local str = string.char(98) .. string.char(101) .. string.char(97) .. string.char(108) .. string.char(111) .. string.char(110) .. string.char(101)
    util.toast("Crashall initiated, please hold")
    menu.trigger_commands(str)
end)

local cur_names = {}
for k,p in pairs(players.list(true, true, true)) do
    local name = PLAYER.GET_PLAYER_NAME(p)
    log("adding pid " .. p .. " to cur_names with name " .. name)
    cur_names[p+1] = name
    set_up_player_actions(p)
end

players.on_join(function(pid)
    log("on_join func")
    log("Player joining with pid " .. pid)
    if pid ~= players.user() then
        local name = PLAYER.GET_PLAYER_NAME(pid)
        log("Adding pid " .. pid .. " to curnames with name " .. name)
        cur_names[pid+1] = name
        --log("Getting RID of pid " .. pid)
        --local rid = get_rid(pid)
        --log("Rid was " .. rid)
        --if adminprotect then
        --    if admin_rids ~= nil then
        --        if hasValue(admin_rids, rid) then
        --            util.toast(name .. " has an admin RID. Bailing to SP.")
        --            menu.trigger_commands("quittosp")
        --        end
        --    end
        --end
        if name == "lance" then
            util.toast("Someone named lance is in the session! Either someone is spoofing as me, or it\'s really me :)")
        end
        if joinsound then
            log("joinsound")
            AUDIO.PLAY_SOUND_FRONTEND(23, "LOSER", "HUD_AWARDS", true)
        end
        if kicktryhardnames then
            log("kick tryhards")
            local _, Lcount = string.gsub(name, "L", "")
            local _, Icount = string.gsub(name, "I", "")
            local total = Lcount + Icount
            if total == #name then
                util.toast("Removing tryhard from your session (" .. name .. ").")
                menu.trigger_commands("crash" .. name)
                menu.trigger_commands("kick" .. name)
            end
        end
        if kicktryhardkds then
            local kd = players.get_kd(pid)
            if kd > kdthres then
                util.toast("Kicking " .. name .. " for having a KD past the threshold (" .. kd .. ").")
                menu.trigger_commands("kick" .. name)
            end
        end
    end
    log("finished on_join func")
    log("Setting up player actions for pid " .. pid)
    set_up_player_actions(pid)
end)

players.on_leave(function(pid)
    log("Player leaving with pid " .. pid)
    if pid ~= players.user() then
        if leavesound then
            AUDIO.PLAY_SOUND_FRONTEND(28, "COLLECTED", "HUD_AWARDS", true)
        end
    end
end)

vehicles_thread = util.create_thread(function (thr)
    while true do
        if vehicle_uses > 0 then
            if show_updates then
                util.toast("Vehicle pool is being updated")
            end
            all_vehicles = entities.get_all_vehicles_as_handles()
        end
        for k,veh in pairs(all_vehicles) do
            if reap then
                request_control_of_entity(veh)
            end
            if spoonerautovehs then
                create_entity_listing(veh, "v")
            end
            if vhp_bars then
                local d_coord = ENTITY.GET_ENTITY_COORDS(veh, true)
                d_coord['z'] = d_coord['z'] + 1.0
                local hp = ENTITY.GET_ENTITY_HEALTH(veh)
                local perc = hp/ENTITY.GET_ENTITY_MAX_HEALTH(veh)*100
                if perc ~= 0 then
                    local r = 0
                    local g = 0
                    local b = 0
                    if perc == 100 then
                        r = 0
                        g = 255
                        b = 0
                    elseif perc < 100 and perc > 50 then
                        r = 255
                        g = 255
                        b = 0
                    else
                        r = 255
                        g = 0
                        b = 0
                    end
                    GRAPHICS.DRAW_MARKER(43, d_coord['x'], d_coord['y'], d_coord['z'], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.50, 0, perc/150, r, g, b, 100, false, true, 2, false, 0, 0, false)
                end
            end
            if player_cur_car ~= veh then
                local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, -1)
                if not is_ped_player(driver) or driver == 0 then
                    if reap then
                        request_control_of_entity(veh)
                    end
                    if noattachments then
                        if IS_ENTITY_ATTACHED_TO_ANY_PED(veh) then
                            ENTITY.DETACH_ENTITY(veh, false, false)
                        end
                    end
                    ap_target = PLAYER.PLAYER_PED_ID()
                    if beep_cars then
                        if not AUDIO.IS_HORN_ACTIVE(veh) then
                            VEHICLE.START_VEHICLE_HORN(veh, 200, util.joaat("HELDDOWN"), true)
                        end
                    end
                    if inferno then
                        local coords = ENTITY.GET_ENTITY_COORDS(veh, true)
                        FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], 7, 100.0, true, false, 1.0)
                    end
                    if blackhole then
                        if bh_target ~= -1 then
                            holecoords = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(bh_target), true)
                        end
                        vcoords = ENTITY.GET_ENTITY_COORDS(veh, true)
                        speed = 100
                        local x_vec = (holecoords['x']-vcoords['x'])*speed
                        local y_vec = (holecoords['y']-vcoords['y'])*speed
                        local z_vec = ((holecoords['z']+hole_zoff)-vcoords['z'])*speed
                        -- dumpster fire if this goes wrong lol
                        ENTITY.SET_ENTITY_INVINCIBLE(veh, true)
                        --losioVEHICLE.SET_VEHICLE_GRAVITY(veh, false)
                        ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(veh, 1, x_vec, y_vec, z_vec, true, false, true, true)
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
                
                    if vehicle_fuckup then
                        VEHICLE.SET_VEHICLE_DAMAGE(veh, math.random(-5.0, 5.0), math.random(-5.0, 5.0), math.random(-5.0,5.0), 200.0, 10000.0, true)
                    end
                
                    if godmode_vehicles then
                        ENTITY.SET_ENTITY_CAN_BE_DAMAGED(veh, false)
                    end
                
                    if disable_veh_colls then
                        VEHICLE._DISABLE_VEHICLE_WORLD_COLLISION(veh)
                    end
                
                    if colorize_cars then
                        VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(veh, rgb[1], rgb[2], rgb[3])
                        VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(veh, rgb[1], rgb[2], rgb[3])
                        for i=0, 3 do
                            VEHICLE._SET_VEHICLE_NEON_LIGHT_ENABLED(veh, i, true)
                        end
                        VEHICLE._SET_VEHICLE_NEON_LIGHTS_COLOUR(veh, rgb[1], rgb[2], rgb[3])
                        VEHICLE.SET_VEHICLE_LIGHTS(veh, 2)
                    end
                
                    if no_radio then
                        AUDIO.SET_VEHICLE_RADIO_ENABLED(veh, false)
                    end
                
                    if loud_radio then
                        AUDIO.SET_VEHICLE_RADIO_LOUD(veh, true)
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

pickups_thread = util.create_thread(function(thr)
    while true do
        if pickup_uses > 0 then
            if show_updates then
                util.toast("Pickups pool is being updated")
            end
            all_pickups = entities.get_all_pickups_as_handles()
        end
        for k,p in pairs(all_pickups) do
            if tp_all_pickups then
                local pos = ENTITY.GET_ENTITY_COORDS(tp_pickup_tar, true)
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(p, pos['x'], pos['y'], pos['z'], true, false, false)
            end
        end
        util.yield()
    end
end)

peds_thread = util.create_thread(function (thr)
    while true do
        if ped_uses > 0 then
            if show_updates then
                util.toast("Ped pool is being updated")
            end
            all_peds = entities.get_all_peds_as_handles()
        end
        for k,ped in pairs(all_peds) do
            if not is_ped_player(ped) then
                if allpeds_gun ~= 0 then
                    WEAPON.GIVE_WEAPON_TO_PED(ped, allpeds_gun, 9999, false, false)
                end
                if reap then
                    request_control_of_entity(ped)
                end
                if aped_combat then
                    local tar = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(combat_tar)
                    if not PED.IS_PED_IN_COMBAT(ped, tar) then 
                        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 5, true)
                        PED.SET_PED_FLEE_ATTRIBUTES(ped, 0, false)
                        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true)
                        TASK.TASK_COMBAT_PED(ped, combat_tar, 0, 16)
						PED.SET_PED_AS_COP(ped, true)
                    end
                end
				if aped_combat2 then
                    local tar = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(combat_tar)
                    if not PED.IS_PED_IN_COMBAT(ped, tar) then 
                        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 5, true)
                        PED.SET_PED_FLEE_ATTRIBUTES(ped, 0, false)
                        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true)
						PED.SET_PED_ACCURACY(ped, 100.0)
						PED.SET_PED_CAN_RAGDOLL(ped, false)
						WEAPON.GIVE_WEAPON_TO_PED(ped, util.joaat("WEAPON_COMBATMG"), 9999, true, true)
						WEAPON.SET_PED_DROPS_WEAPONS_WHEN_DEAD(ped, false)
                        TASK.TASK_COMBAT_PED(ped, combat_tar, 0, 16)
						PED.SET_PED_AS_COP(ped, true)
						if d then --unused
							PED.SET_AI_WEAPON_DAMAGE_MODIFIER(ped, 3000000)
						end
                    end
                end
                if ignore then
                    if not PED.GET_PED_CONFIG_FLAG(ped, 17, true) then
                        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
                        TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
                    end
                end
                if rapture then
                    TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
                    PED.SET_PED_TO_RAGDOLL(ped, 100, 100, 0, true, true, true)
                    ENTITY.SET_ENTITY_VELOCITY(ped, 0.0, 0.0, 0.5)
                end
                if spoonerautopeds then
                    create_entity_listing(ped, "p")
                end
                if php_bars then
                    local d_coord = ENTITY.GET_ENTITY_COORDS(ped, true)
                    d_coord['z'] = d_coord['z'] + 0.8
                    local hp = ENTITY.GET_ENTITY_HEALTH(ped)
                    local perc = hp/ENTITY.GET_ENTITY_MAX_HEALTH(ped)*100
                    if perc ~= 0 then
                        local r = 0
                        local g = 0
                        local b = 0
                        if perc == 100 then
                            r = 0
                            g = 255
                            b = 0
                        elseif perc < 100 and perc > 50 then
                            r = 255
                            g = 255
                            b = 0
                        else
                            r = 255
                            g = 0
                            b = 0
                        end
                        GRAPHICS.DRAW_MARKER(43, d_coord['x'], d_coord['y'], d_coord['z'], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.10, 0, perc/150, r, g, b, 100, false, true, 2, false, 0, 0, false)
                    end
                end
                if noattachments then
                    if IS_ENTITY_ATTACHED_TO_ANY_PED(ped) then
                        ENTITY.DETACH_ENTITY(ped, false, false)
                    end
                end
                -- voicelines
                if ped_accuracy ~= 25 then
                    PED.SET_PED_ACCURACY(ped, ped_accuracy)
                end
                if karate then
                    PED.SET_PED_COMBAT_ABILITY(ped, 2)
                end
                if pacifist then
                    PED.SET_PED_CAN_BE_TARGETTED(ped, false)
                    ENTITY.SET_ENTITY_INVINCIBLE(ped, true)
                end
                if wantthesmoke then 
                    PED.SET_PED_AS_ENEMY(ped, true)
                    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 5, true)
                    PED.SET_PED_FLEE_ATTRIBUTES(ped, 0, false)
                    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true)
                    TASK.TASK_COMBAT_PED(ped, PLAYER.PLAYER_PED_ID(), 0, 16)
                end
                if roast_voicelines then
                    AUDIO.PLAY_PED_AMBIENT_SPEECH_NATIVE(ped, "GENERIC_INSULT_MED", "SPEECH_PARAMS_FORCE_SHOUTED")
                end

                if sex_voicelines then
                    AUDIO.PLAY_PED_AMBIENT_SPEECH_WITH_VOICE_NATIVE(ped, "SEX_GENERIC_FEM", "S_F_Y_HOOKER_01_WHITE_FULL_01", "SPEECH_PARAMS_FORCE_SHOUTED", 0)
                end

                if gluck_voicelines then
                    AUDIO.PLAY_PED_AMBIENT_SPEECH_WITH_VOICE_NATIVE(ped, "SEX_ORAL_FEM", "S_F_Y_HOOKER_01_WHITE_FULL_01", "SPEECH_PARAMS_FORCE_SHOUTED", 0)
                end

                if screamall then
                    AUDIO.PLAY_PAIN(ped, 7, 0)
                end

                if play_ped_ringtones then
                    AUDIO.PLAY_PED_RINGTONE("Dial_and_Remote_Ring", ped, true)
                end
    
                if dumb_peds then
                    PED.SET_PED_HIGHLY_PERCEPTIVE(ped, false)
                    PED.SET_PED_ALERTNESS(ped, 0)
                    PED.SET_PED_FLEE_ATTRIBUTES(ped, 0, false)
                end
    
                if peds_arrest_player then
                    TASK.TASK_ARREST_PED(ped, arrest_target)
                end
    
                if deaf_peds then
                    PED.SET_PED_HEARING_RANGE(ped, 0.0)
                end
    
                if safe_peds then
                    PED.GIVE_PED_HELMET(ped, true, 4096, 0)
                end

                if kill_peds then
                    if ENTITY.GET_ENTITY_HEALTH(ped) > 0 then
                        PED.EXPLODE_PED_HEAD(ped, -771403250)
                    end
                end

                if ped_chase then
                    if PED.IS_PED_IN_ANY_VEHICLE(ped) then
                        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 5, true)
                        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true)
                        TASK.SET_TASK_VEHICLE_CHASE_IDEAL_PURSUIT_DISTANCE(ped, 0.0)
                        TASK.SET_TASK_VEHICLE_CHASE_BEHAVIOR_FLAG(ped, 1, true)
                        TASK.TASK_COMBAT_PED(ped, chase_target, 0, 16)
                        TASK.TASK_VEHICLE_CHASE(ped, PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(chase_target))
                    end
                end
            end
        end
        util.yield()
    end
end)

function peacefulsess_thread()
    peacefulthr = util.create_thread(function(thr)
        while true do
            if not peacefulsession then
                util.stop_thread()
            end
            for k,pid in pairs(players.list(true, true, true)) do
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                if ENTITY.IS_ENTITY_DEAD(ped) then
                    -- how in the unholy fuck did i figure this one out holy shit
                    if MISC.GET_GAME_TIMER() - PED.GET_PED_TIME_OF_DEATH(ped) <= 1 then
                        local killer = PED.GET_PED_SOURCE_OF_DEATH(ped)
                        if ENTITY.IS_ENTITY_A_PED(killer) then
                            if is_ped_player(killer) then
                                local plyr = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(killer)
                                if plyr ~= 0 and ped ~= killer then
                                    local name = PLAYER.GET_PLAYER_NAME(plyr)
                                    util.toast(name .. " was very naughty and PvP\'d. They are being kicked.")
                                    menu.trigger_commands("kick" .. name)
                                end
                            else
                                ENTITY.SET_ENTITY_HEALTH(killer, 0.0)
                            end
                        end
                    end
                end
            end
            util.yield()
        end
    end)
end

players_thread = util.create_thread(function (thr)
    while true do
        if player_uses > 0 then
            if show_updates then
                util.toast("Player pool is being updated")
            end
            all_players = players.list(true, true, true)
        end
        for k,pid in pairs(all_players) do
            log("pthread for pid " .. pid)
            if antioppressor then
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local vehicle = PED.GET_VEHICLE_PED_IS_IN(ped, true)
                if vehicle ~= 0 then
                  local hash = util.joaat("oppressor2")
                  if VEHICLE.IS_VEHICLE_MODEL(vehicle, hash) then
                    if meanantioppressor then
                        menu.trigger_commands("kick".. PLAYER.GET_PLAYER_NAME(pid))
                    else
                        entities.delete_by_handle(vehicle)
                    end
                  end
                end
            end
            if noarmedvehs then
                log("noarmedvehs")
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local vehicle = PED.GET_VEHICLE_PED_IS_IN(ped, true)
                if vehicle ~= 0 then
                    if VEHICLE.DOES_VEHICLE_HAVE_WEAPONS(vehicle) then 
                        entities.delete_by_handle(vehicle)
                    end
                end
            end
            if christianity then
                log("christianity")
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

            if show_voicechatters then
                log("show voicechatters")
                if NETWORK.NETWORK_IS_PLAYER_TALKING(pid) then
                    util.toast(PLAYER.GET_PLAYER_NAME(pid) .. " is talking")
                end
            end
        end    
        util.yield()
    end
end)

-- thread i use when i want stuff to occur on a loop, but have a delay
-- same premise of rgb thread
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

objects_thread = util.create_thread(function (thr)
    if object_uses > 0 then
        if show_updates then
            util.toast("Object pool is being updated")
        end
        all_objects = entities.get_all_objects_as_handles()
    end
    while true do
        for k,obj in pairs(all_objects) do
            if reap then
                request_control_of_entity(obj)
            end
            if spoonerautoobjs then
                create_entity_listing(obj, "o")
            end
            if noattachments then
                if IS_ENTITY_ATTACHED_TO_ANY_PED(obj) then
                    ENTITY.DETACH_ENTITY(obj, false, false)
                end
            end
            if object_rainbow then
                OBJECT._SET_OBJECT_LIGHT_COLOR(obj, 1, rgb[1], rgb[2], rgb[3])
            end

            if rapidtraffic then
                ENTITY.SET_ENTITY_TRAFFICLIGHT_OVERRIDE(obj, tlightstate)
            end
        end    
        util.yield()
    end
end)

function hijack_veh_for_player(car)
    hijack_thread = util.create_thread(function (thr)
        local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(car, -1)
        if PED.IS_PED_A_PLAYER(driver) then
            menu.trigger_commands("vehkick" .. PLAYER.GET_PLAYER_NAME(NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(driver)))
        end
        local start = os.time()
        while VEHICLE.GET_PED_IN_VEHICLE_SEAT(car, -1) ~= 0 do
            if os.time() - start >= 5 then
                break
            end
            util.yield()
        end
        request_control_of_entity(car)
        PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), car, -1)
        VEHICLE.SET_VEHICLE_OUT_OF_CONTROL(car, false, false)
    end)
end

function get_last_mp_char()
    log("alloc 4 bytes, get_last_mp_char")
    local outptr = memory.alloc(4)
    STATS.STAT_GET_INT(MISC.GET_HASH_KEY("MPPLY_LAST_MP_CHAR"), outptr, -1)
    local out = memory.read_int(outptr)
    log("get_last_mp_char free mem")
    memory.free(outptr)
    return out
end

function get_business_slot_supplies(slot)
    prefix = "MP" .. get_last_mp_char() .. "_"
    log("alloc 4 bytes, get_business_slot_supplies")
    local outptr = memory.alloc(4)
    STATS.STAT_GET_INT(MISC.GET_HASH_KEY(prefix .. "MATTOTALFORFACTORY" .. slot), outptr, -1)
    local out = memory.read_int(outptr)
    log("get_business_slot_supplies free mem")
    memory.free(outptr)
    return out
end

function get_hub_product_of_type(id)
    prefix = "MP" .. get_last_mp_char() .. "_"
    log("alloc 4 bytes, get_hub_product_of_type")
    local outptr = memory.alloc(4)
    STATS.STAT_GET_INT(MISC.GET_HASH_KEY(prefix .. "HUB_PROD_TOTAL_" .. id), outptr, -1)
    local out = memory.read_int(outptr)
    log("get_hub_product_of_type free mem")
    memory.free(outptr)
    return out
end

function get_business_slot_product(slot)
    log("alloc 4 bytes, get_business_slot_product")
    prefix = "MP" .. get_last_mp_char() .. "_"
    local outptr = memory.alloc(4)
    STATS.STAT_GET_INT(MISC.GET_HASH_KEY(prefix .. "PRODTOTALFORFACTORY" .. slot), outptr, -1)
    local out = memory.read_int(outptr)
    log("get_business_slot_product free mem")
    memory.free(outptr)
    return out
end

function get_resupply_timer(slot)
    prefix = "MP" .. get_last_mp_char() .. "_"
    log("alloc 4 bytes, get_resupply_timer")
    local outptr = memory.alloc(4)
    STATS.STAT_GET_INT(MISC.GET_HASH_KEY(prefix .. "PAYRESUPPLYTIMER" .. slot), outptr, -1)
    local out = memory.read_int(outptr)
    log("get_resupply_timer free mem")
    memory.free(outptr)
    return out
end

function get_bunker_research()
    prefix = "MP" .. get_last_mp_char() .. "_"
    log("alloc 4 bytes, get_bunker_research")
    local outptr = memory.alloc(4)
    STATS.STAT_GET_INT(MISC.GET_HASH_KEY(prefix .. "RESEARCHTOTALFORFACTORY5"), outptr, -1)
    local out = memory.read_int(outptr)
    log("get_bunker_research free mem")
    memory.free(outptr)
    return out
    --RESEARCHTOTALFORFACTORY5 
end

local ent_types = {"None", "Ped", "Vehicle", "Object"}
function get_aim_info()
    log("alloc 4 bytes, get_aim_info")
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
    log("get_aim_info free mem")
    memory.free(outptr)
    return info
end

-- this is a patch for if the default state makes the vehicle uses go negative

meth_col = to_rgb(0, 1, 1, 1)
weed_col = to_rgb(0, 0.4, 0, 1)
bunker_col = to_rgb(1, 1, 0, 1)
cash_col = to_rgb(0, 0.8, 0, 1)
cocaine_col = to_rgb(1, 1, 1, 1)
forgery_col = to_rgb(1, 0, 1, 1)
cargo_col = to_rgb(0.7, 0.5, 0, 1)
weapons_col = to_rgb(0.7, 0.7, 0.7, 1)
meth_info = {"???", "???"}
weed_info = {"???", "???"}
cash_info = {"???", "???"}
cocaine_info = {"???", "???", "???"}
doc_info = {"???", "???"}
bunker_info = {"???", "???", "???"}
nightclub_info = {"???"}
bm_xoffset = 0
bm_uoffset = 0
bm_uwidth = 0.7
bus_ticks = 0
hub_ticks = 0
hub_meth = 0
hub_weed = 0
hub_cocaine = 0
hub_forgery = 0
hub_counterfeit = 0
hub_cargo = 0
hub_weapons = 0
methbuses = {1, 6, 11, 16}
weedbuses = {2, 7, 12, 17}
cocbuses = {3, 8, 13, 18}
cashbuses = {4, 9, 14, 19}
docbuses = {5, 10, 15, 20}
bunkerbuses = {21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31}
nightclubs = {}
arcades = {}
cinestate_active = false


-- we are done loading!
is_loading = false

-- main tick loop
while true do
    for k,v in pairs(ped_flags) do
        if v ~= nil and v then
            PED.SET_PED_CONFIG_FLAG(PLAYER.PLAYER_PED_ID(), k, true)
        end
    end
    if train ~= nil and train ~= 0 then
        VEHICLE.SET_TRAIN_SPEED(train, train_speed)
        VEHICLE.SET_TRAIN_CRUISE_SPEED(train, train_speed)
    end
    if moonwalk then
        if PAD.IS_CONTROL_PRESSED(32, 32)  or PAD.IS_CONTROL_PRESSED(34, 34) or PAD.IS_CONTROL_PRESSED(35, 35) then
            local f = ENTITY.GET_ENTITY_FORWARD_VECTOR(PLAYER.PLAYER_PED_ID())
            f['x'] = -f['x']
            f['y'] = -f['y']
            f['z'] = -f['z']
            ENTITY.SET_ENTITY_VELOCITY(PLAYER.PLAYER_PED_ID(), f['x'], f['y']*3, 0.0)
        end
    end
    if renderscorched then
        if player_cur_car ~= 0 then
            ENTITY.SET_ENTITY_RENDER_SCORCHED(player_cur_car, true)
        end
    end
    if grapplegun then
        log("grapple hook loop")
        local curwep = WEAPON.GET_SELECTED_PED_WEAPON(PLAYER.PLAYER_PED_ID())
        if PED.IS_PED_SHOOTING(PLAYER.PLAYER_PED_ID()) and PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false) then
            if curwep == util.joaat("weapon_pistol") or curwep == util.joaat("weapon_pistol_mk2") then
                log("ghook control pressed")
                local raycast_coord = raycast_gameplay_cam(-1, 10000.0)
                if raycast_coord[1] == 1 then
                    local lastdist = nil
                    TASK.TASK_SKY_DIVE(PLAYER.PLAYER_PED_ID())
                    while true do
                        if PAD.IS_CONTROL_JUST_PRESSED(45, 45) then 
                            break
                        end
                        if raycast_coord[4] ~= 0 and ENTITY.GET_ENTITY_TYPE(raycast_coord[4]) >= 1 and ENTITY.GET_ENTITY_TYPE(raycast_coord[4]) < 3 then
                            ggc1 = ENTITY.GET_ENTITY_COORDS(raycast_coord[4], true)
                        else
                            ggc1 = raycast_coord[2]
                        end
                        local c2 = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
                        local dist = MISC.GET_DISTANCE_BETWEEN_COORDS(ggc1['x'], ggc1['y'], ggc1['z'], c2['x'], c2['y'], c2['z'], true)
                        -- safety
                        if not lastdist or dist < lastdist then 
                            lastdist = dist
                        else
                            break
                        end
                        if ENTITY.IS_ENTITY_DEAD(PLAYER.PLAYER_PED_ID()) then
                            break
                        end
                        if dist >= 10 then
                            local dir = {}
                            dir['x'] = (ggc1['x'] - c2['x']) * dist
                            dir['y'] = (ggc1['y'] - c2['y']) * dist
                            dir['z'] = (ggc1['z'] - c2['z']) * dist
                            --ENTITY.APPLY_FORCE_TO_ENTITY(PLAYER.PLAYER_PED_ID(), 2, dir['x'], dir['y'], dir['z'], 0.0, 0.0, 0.0, 0, false, false, true, false, true)
                            ENTITY.SET_ENTITY_VELOCITY(PLAYER.PLAYER_PED_ID(), dir['x'], dir['y'], dir['z'])
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
    if entgun then
        if PED.IS_PED_SHOOTING(PLAYER.PLAYER_PED_ID()) then
            local hash = shootent
            request_model_load(hash)
            local c1 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 5.0, 0.0)
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
            c1.x = c1['x']
            c1.y = c1['y']
            c1.z = c1['z']
            local ent = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, c1['x'], c1['y'], c1['z'], true, false, false)
            ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(ent, PLAYER.PLAYER_PED_ID(), false)
            ENTITY.APPLY_FORCE_TO_ENTITY(ent, 0, dir['x'], dir['y'], dir['z'], 0.0, 0.0, 0.0, 0, true, false, true, false, true)
            if not entgungrav then
                ENTITY.SET_ENTITY_HAS_GRAVITY(ent, false)
            end
            --ENTITY.SET_OBJECT_AS_NO_LONGER_NEEDED(ent)
        end
    end
    if turnsignals then
        log("turn signal")
        if player_cur_car ~= 0 then
            local left = PAD.IS_CONTROL_PRESSED(34, 34)
            local right = PAD.IS_CONTROL_PRESSED(35, 35)
            if left then
                VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(player_cur_car, 1, true)
            elseif right then
                VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(player_cur_car, 0, true)
            end
            if not left then
                VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(player_cur_car, 1, false)
            end
            if not right then
                VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(player_cur_car, 0, false)
            end
        end
    end
    if walkonwater or driveonwater or driveonair or walkonair then
        log("dowblock check")
        if dow_block == 0 or not ENTITY.DOES_ENTITY_EXIST(dow_block) then
            log("dowblock made")
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
        log("move dowblock to 0 0 0")
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(dow_block, 0, 0, 0, false, false, false)
    end

    if walkonwater then
        log("walkonwater loop")
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
        if car == 0 then
            local pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 2.0, 0.0)
            -- we need to offset this because otherwise the player keeps diving off the thing, like a fucking dumbass
            -- ht isnt actually used here, but im allocating some memory anyways to prevent a possible crash, probably. idk im no computer engineer
            log("alloc 4 bytes, walkonwater")
            local ht = memory.alloc(4)
            -- this is better than ENTITY.IS_ENTITY_IN_WATER because it can detect if a player is actually above water without them even being "in" it
            if WATER.GET_WATER_HEIGHT(pos['x'], pos['y'], pos['z'], ht) then
                local t, z = util.get_ground_z(pos['x'], pos['y'], pos['z'])
                if t then
                    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(dow_block, pos['x'], pos['y'], z, false, false, false)
                    ENTITY.SET_ENTITY_HEADING(dow_block, ENTITY.GET_ENTITY_HEADING(PLAYER.PLAYER_PED_ID()))
                end
            end
            log("walkonwater free mem")
            memory.free(ht)
        end
    end
    if driveonwater then
        log("driveonwater loop")
        if player_cur_car ~= 0 then
            local pos = ENTITY.GET_ENTITY_COORDS(player_cur_car, true)
            -- ht isnt actually used here, but im allocating some memory anyways to prevent a possible crash, probably. idk im no computer engineer
            log("alloc 4 bytes, driveonwater")
            local ht = memory.alloc(4)
            -- this is better than ENTITY.IS_ENTITY_IN_WATER because it can detect if a player is actually above water without them even being "in" it
            if WATER.GET_WATER_HEIGHT(pos['x'], pos['y'], pos['z'], ht) then
                local t, z = util.get_ground_z(pos['x'], pos['y'], pos['z'])
                if t then
                    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(dow_block, pos['x'], pos['y'], z, false, false, false)
                    ENTITY.SET_ENTITY_HEADING(dow_block, ENTITY.GET_ENTITY_HEADING(player_cur_car))
                end
            end
            log("driveonwater free mem")
            memory.free(ht)
        else
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(dow_block, 0, 0, 0, false, false, false)
        end
    end
    if driveonair then
        log("driveonair loop")
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
    if walkonair then
        log("walkonair loop")
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
        if car == 0 then
            local pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 2.0, 0.0)
            local boxpos = ENTITY.GET_ENTITY_COORDS(dow_block, true)
            if MISC.GET_DISTANCE_BETWEEN_COORDS(pos['x'], pos['y'], pos['z'], boxpos['x'], boxpos['y'], boxpos['z'], true) >= 5 then
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(dow_block, pos['x'], pos['y'], woa_ht, false, false, false)
                ENTITY.SET_ENTITY_HEADING(dow_block, ENTITY.GET_ENTITY_HEADING(PLAYER.PLAYER_PED_ID()))
            end
            if PAD.IS_CONTROL_PRESSED(22, 22) then
                woa_ht = woa_ht + 0.1
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(dow_block, pos['x'], pos['y'], woa_ht, false, false, false)
            end
            if PAD.IS_CONTROL_PRESSED(36, 36) then
                woa_ht = woa_ht - 0.1
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(dow_block, pos['x'], pos['y'], woa_ht, false, false, false)
            end
        end
    end
    local hud_extras = 0
    if ehud_hdg then
        log("heading hud")
        local hdg = math.floor(ENTITY.GET_ENTITY_HEADING(PLAYER.PLAYER_PED_ID()))
        directx.draw_text(0.5, 0.0, hdg, 5, 0.84, white, true)
        hud_extras = hud_extras + 1
    end

    if vehicle_strafe then
        log("vstrafe")
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
    end

    if vehicle_jump then
        log("vjump")
        if player_cur_car ~= 0 then
            if PAD.IS_CONTROL_JUST_PRESSED(86,86) then
                ENTITY.APPLY_FORCE_TO_ENTITY(player_cur_car, 1, 0.0, 0.0, vjumpforce, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
            end
        end
    end
    if density_avrm ~= 0.1 then
        VEHICLE.SET_AMBIENT_VEHICLE_RANGE_MULTIPLIER_THIS_FRAME(density_avrm)
    end
    if density_vparked ~= 0.1 then
        VEHICLE.SET_PARKED_VEHICLE_DENSITY_MULTIPLIER_THIS_FRAME(density_vparked)
    end
    if density_vrandom ~= 0.1 then
        VEHICLE.SET_RANDOM_VEHICLE_DENSITY_MULTIPLIER_THIS_FRAME(density_vrandom)
    end
    if density_vregular ~= 0.1 then
        VEHICLE.SET_VEHICLE_DENSITY_MULTIPLIER_THIS_FRAME(density_vregular)
    end
    if density_ped ~= 0.1 then
        PED.SET_PED_DENSITY_MULTIPLIER_THIS_FRAME(density_ped)
    end
    if cinematic_autod then
        log("auto cinema drive")
        if CAM._IS_CINEMATIC_CAM_ACTIVE() then
            if not cinestate_active then
                local goto_coords = get_waypoint_coords()
                if goto_coords ~= nil then
                    TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(PLAYER.PLAYER_PED_ID(), player_cur_car, goto_coords['x'], goto_coords['y'], goto_coords['z'], 300.0, 786996, 5)
                    cinestate_active = true
                end
            end
        else
            if cinestate_active then
                cinestate_active = false
                TASK.CLEAR_PED_TASKS(PLAYER.PLAYER_PED_ID())
            end
        end
                    --TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(PLAYER.PLAYER_PED_ID(), player_cur_car, goto_coords['x'], goto_coords['y'], goto_coords['z'], 300.0, 786996, 5)
    end
    if player_cur_car ~= 0 and horn_boost then
        log("horn boost")
        VEHICLE.SET_VEHICLE_ALARM(player_cur_car, false)
        if AUDIO.IS_HORN_ACTIVE(player_cur_car) then
            ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(player_cur_car, 1, 0.0, 1.0, 0.0, true, true, true, true)
        end
    end

    if player_cur_car ~= 0 and force_cm then
        log("force cm")
        if PAD.IS_CONTROL_PRESSED(46, 46) then
            local target = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), math.random(-5, 5), -30.0, math.random(-5, 5))
            --MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(target['x'], target['y'], target['z'], target['x'], target['y'], target['z'], 300.0, true, -1355376991, PLAYER.PLAYER_PED_ID(), true, false, 100.0)
            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(target['x'], target['y'], target['z'], target['x'], target['y'], target['z'], 100.0, true, 1198879012, PLAYER.PLAYER_PED_ID(), true, false, 100.0)
        end
    end

    if aim_info then
        log("aim info loop")
        local info = get_aim_info()
        if info['ent'] ~= 0 then
            local text = "Hash: " .. info['hash'] .. "\nEntity: " .. info['ent'] .. "\nHealth: " .. info['health'] .. "\nType: " .. info['type'] .. "\nSpeed: " .. info['speed']
            directx.draw_text(0.5, 0.3, text, 5, 0.5, white, true)
        end
    end
    if gun_stealer then
        log("stealer gun")
        if PED.IS_PED_SHOOTING(PLAYER.PLAYER_PED_ID()) then
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
        log("driver gun")
        local ent = get_aim_info()['ent']
        request_control_of_entity(ent)
        if PED.IS_PED_SHOOTING(PLAYER.PLAYER_PED_ID()) then
            if ENTITY.IS_ENTITY_A_VEHICLE(ent) then
                local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(ent, -1)
                if driver == 0 or not is_ped_player(driver) then
                    if not is_ped_player(driver) then
                        entities.delete_by_handle(driver)
                    end
                    local hash = 0x9C9EFFD8
                    request_model_load(hash)
                    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, -2.0, 0.0, 0.0)
                    coords.x = coords['x']
                    coords.y = coords['y']
                    coords.z = coords['z']
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

    if paintball then
        log("paintball loop")
        local ent = get_aim_info()['ent']
        request_control_of_entity(ent)
        if PED.IS_PED_SHOOTING(PLAYER.PLAYER_PED_ID()) then
            if ENTITY.IS_ENTITY_A_VEHICLE(ent) then
                log("paintball hit")
                rand = {}
                rand['r'] = math.random(100,255)
                rand['g'] = math.random(100,255)
                rand['b'] = math.random(100,255)
                VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(ent, rand['r'], rand['g'], rand['b'])
                VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(ent, rand['r'], rand['g'], rand['b'])
            end
        end
    end

    if tesla_ped ~= 0 then
        log("tesla ped loop")
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
            HUD.REMOVE_BLIP(tesla_blip)
        end
    end
    if aptloop then
        menu.trigger_commands("aptmeall")
    end
    if rainbow_tint then
        WEAPON.SET_PED_WEAPON_TINT_INDEX(PLAYER.PLAYER_PED_ID(),WEAPON.GET_SELECTED_PED_WEAPON(PLAYER.PLAYER_PED_ID()), cur_tint)
    end
    if noexplosives then
        WEAPON.REMOVE_ALL_PROJECTILES_OF_TYPE(741814745, false)
        WEAPON.REMOVE_ALL_PROJECTILES_OF_TYPE(-1312131151, false)
        WEAPON.REMOVE_ALL_PROJECTILES_OF_TYPE(-1568386805, false)
        WEAPON.REMOVE_ALL_PROJECTILES_OF_TYPE(2138347493, false)
        WEAPON.REMOVE_ALL_PROJECTILES_OF_TYPE(1672152130, false)
        WEAPON.REMOVE_ALL_PROJECTILES_OF_TYPE(125959754, false)
        WEAPON.REMOVE_ALL_PROJECTILES_OF_TYPE(-1813897027, false)
        WEAPON.REMOVE_ALL_PROJECTILES_OF_TYPE(615608432, false)
        WEAPON.REMOVE_ALL_PROJECTILES_OF_TYPE(1420407917, false)
        WEAPON.REMOVE_ALL_PROJECTILES_OF_TYPE(1169823560, false)
    end
    if stickyground then
        if player_cur_car ~= 0 then
            local vel = ENTITY.GET_ENTITY_VELOCITY(player_cur_car)
            vel['z'] = -vel['z']
            ENTITY.APPLY_FORCE_TO_ENTITY(player_cur_car, 2, 0, 0, -50 -vel['z'], 0, 0, 0, 0, true, false, true, false, true)
            --ENTITY.SET_ENTITY_VELOCITY(player_cur_car, vel['x'], vel['y'], -0.2)
        end
    end

    if bus_ticks > 0 then
        for i=0,5 do
            log("alloc 4 bytes, bus tick")
            local outptr = memory.alloc(4)
            STATS.STAT_GET_INT(MISC.GET_HASH_KEY("MP0_" .. "FACTORYSLOT" .. i), outptr, -1)
            local id = memory.read_int(outptr)
            if hasValue(methbuses, id) then
                meth_info = {get_business_slot_product(i), get_business_slot_supplies(i)}
            elseif hasValue(weedbuses, id) then
                weed_info = {get_business_slot_product(i), get_business_slot_supplies(i)}
            elseif hasValue(cocbuses, id) then
                cocaine_info = {get_business_slot_product(i), get_business_slot_supplies(i)}
            elseif hasValue(cashbuses, id) then
                cash_info = {get_business_slot_product(i), get_business_slot_supplies(i)}
            elseif hasValue(docbuses, id) then
                doc_info = {get_business_slot_product(i), get_business_slot_supplies(i)}
            elseif hasValue(bunkerbuses, id) then
                bunker_info = {get_business_slot_product(i), get_business_slot_supplies(i), get_bunker_research(i)}
            end
            log("bus ticks free mem")
            memory.free(outptr)
        end
        for i=0, 6 do
            local total = get_hub_product_of_type(i)
            if i == 0 then
                hub_cargo = total
            elseif i == 1 then
                hub_weapons = total
            elseif i == 2 then
                hub_cocaine = total
            elseif i == 3 then
                hub_meth = total
            elseif i == 4 then
                hub_weed = total
            elseif i == 5 then
                hub_forgery = total
            elseif i == 6 then
                hub_counterfeit = total
            end
        end
    end
    if util.is_session_started() then
        if bm_underlay then
            if bm_meth or bm_weed or bm_documents or bm_cocaine or bm_bunker or bm_cash or bm_nightclubsafe or bm_hub then
                local black = black
                black.a = 0.6
                directx.draw_rect(0.80 + bm_uoffset, 0.0, bm_uwidth, 0.3, black)
            end
        end
        local ct = 0
        if bm_meth then
            ct = ct + 0.02
            local line = "Meth | product: " .. meth_info[1] .. "/20, supplies: " .. meth_info[2] .. "%"
            directx.draw_text(1.0 + bm_xoffset, ct, line, 6, 0.5, meth_col, true)
        end

        if bm_weed then
            ct = ct + 0.02
            local line = "Weed | product: " .. weed_info[1] .. "/80, supplies: " .. weed_info[2] .. "%"
            directx.draw_text(1.0 + bm_xoffset, ct, line, 6, 0.5, weed_col, true)
        end

        if bm_documents then
            ct = ct + 0.02
            local line = "Forgery | product: " .. doc_info[1] .. "/60, supplies: " .. doc_info[2] .. "%"
            directx.draw_text(1.0 + bm_xoffset, ct, line, 6, 0.5, forgery_col, true)
        end

        if bm_cocaine then
            ct = ct + 0.02
            local line = "Cocaine | product: " .. cocaine_info[1] .. "/10, supplies: " .. cocaine_info[2] .. "%"
            directx.draw_text(1.0 + bm_xoffset, ct, line, 6, 0.5, cocaine_col, true)
        end

        if bm_bunker then
            ct = ct + 0.02
            local line = "Bunker | product: " .. bunker_info[1] .. "/100, supplies: " .. bunker_info[2] .. "%, research: " .. bunker_info[3] .. "%"
            directx.draw_text(1.0 + bm_xoffset, ct, line, 6, 0.5, bunker_col, true)
        end

        if bm_cash then
            ct = ct + 0.02
            local line = "Counterfeit | product: " .. cash_info[1] .. "/60, supplies: " .. cash_info[2] .. "%"
            directx.draw_text(1.0 + bm_xoffset, ct, line, 6, 0.5, cash_col, true)
        end

        if bm_nightclubsafe then
            prefix = "MP" .. get_last_mp_char() .. "_"
            log("alloc 4 bytes, nightclubsafe")
            local safevalptr = memory.alloc(4)
            STATS.STAT_GET_INT(MISC.GET_HASH_KEY(prefix .. "CLUB_SAFE_CASH_VALUE"), safevalptr, -1)
            safeval = memory.read_int(safevalptr)
            log("nightclubsafe free mem")
            memory.free(safevalptr)
            ct = ct + 0.02
            directx.draw_text(1.0 + bm_xoffset, ct, "Nightclub safe: $" .. safeval, 6, 0.5, cash_col, true)
        end

        if bm_hub then
            -- not gonna make a whole func just for this
            ct = ct + 0.02
            directx.draw_text(1.0 + bm_xoffset, ct, "Hub cargo: " .. hub_cargo .. "/50", 6, 0.5, cargo_col, true)
            ct = ct + 0.02
            directx.draw_text(1.0 + bm_xoffset, ct, "Hub documents: " .. hub_forgery .. "/60", 6, 0.5, forgery_col, true)
            ct = ct + 0.02
            directx.draw_text(1.0 + bm_xoffset, ct, "Hub weed: " .. hub_weed .. "/80", 6, 0.5, weed_col, true)
            ct = ct + 0.02
            directx.draw_text(1.0 + bm_xoffset, ct, "Hub cocaine: " .. hub_cocaine .. "/10", 6, 0.5, cocaine_col, true)
            ct = ct + 0.02
            directx.draw_text(1.0 + bm_xoffset, ct, "Hub counterfeit: " .. hub_counterfeit .. "/40", 6, 0.5, cash_col, true)
            ct = ct + 0.02
            directx.draw_text(1.0 + bm_xoffset, ct, "Hub meth: " .. hub_meth .. "/20", 6, 0.5, meth_col, true)
            ct = ct + 0.02
            directx.draw_text(1.0 + bm_xoffset, ct, "Hub weapons: " .. hub_weapons .. "/100", 6, 0.5, weapons_col, true)
        end
    end

    if earrape then
        coords = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(earrape_target), true)
        coords['x'] = coords['x'] + 15
        coords['y'] = coords['y'] + 15
        coords['z'] = coords['z'] + 15
        FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], 38, 0.0, true, true, 0.0)
    end

    if lightning_spam then
        MISC.FORCE_LIGHTNING_FLASH()
    end

    if firework_spam then
        coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
        coords['x'] = coords['x'] + math.random(-100, 100)
        coords['y'] = coords['y'] + math.random(-100, 100)
        coords['z'] = coords['z'] + math.random(30, 100)
        FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], 38, 100.0, true, false, 0.0)
    end

    if instantspinup then
        if player_cur_car ~= 0 then
            VEHICLE.SET_HELI_BLADES_FULL_SPEED(player_cur_car)
        end
    end

    if mph_plate then
        if player_cur_car ~= 0 then
            if mph_unit == "kph" then
                unit_conv = 3.6
            else
                unit_conv = 2.236936
            end
            speed = math.ceil(ENTITY.GET_ENTITY_SPEED(player_cur_car)*unit_conv)
            VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(player_cur_car, speed .. " " .. mph_unit)
        end
    end

    player_cur_car = entities.get_user_vehicle_as_handle()
    
    if hud_rainbow then
        for i=0,215 do
            HUD.REPLACE_HUD_COLOUR_WITH_RGBA(i, rgb[1], rgb[2], rgb[3], 255)
        end
    end

    if player_cur_car ~= 0 then
        if everythingproof then
            ENTITY.SET_ENTITY_PROOFS(player_cur_car, true, true, true, true, true, true, true, true)
        end
        if racemode then
            VEHICLE.SET_VEHICLE_IS_RACING(player_cur_car, true)
        end

        if infcms then
            if VEHICLE._GET_VEHICLE_COUNTERMEASURE_COUNT(player_cur_car) < 100 then
                VEHICLE._SET_VEHICLE_COUNTERMEASURE_COUNT(player_cur_car, 100)
            end
        end

        if shift_drift then
            if PAD.IS_CONTROL_PRESSED(21, 21) then
                VEHICLE.SET_VEHICLE_REDUCE_GRIP(player_cur_car, true)
                VEHICLE._SET_VEHICLE_REDUCE_TRACTION(player_cur_car, 0.0)
            else
                VEHICLE.SET_VEHICLE_REDUCE_GRIP(player_cur_car, false)
            end
        end
    end

    if cont_clear then
        clear_area(clear_radius)
    end

    if bullet_rain then
        target = ENTITY.GET_ENTITY_COORDS(bullet_rain_target)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(target['x'], target['y'], target['z'], target['x'], target['y'], target['z']+0.1, swiss_cheese_dmg, true, 100416529, bullet_rain_scapegoat, true, false, 100.0)
    end
    
    if launchloop then
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(launchtar)
        local coords = ENTITY.GET_ENTITY_COORDS(target_ped)
        FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], 70, 1.0, true, false, 0.0)
    end

    if waterjetloop then
        local coords = ENTITY.GET_ENTITY_COORDS(waterjettar)
        FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], 13, 100.0, true, false, 0.0)
    end

    if freezeloop then
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(freezetar)
        local car = PED.GET_VEHICLE_PED_IS_IN(ped)
        request_control_of_entity(car)
    end
    if firejetloop then
        local coords = ENTITY.GET_ENTITY_COORDS(firejettar)
        FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], 12, 100.0, true, false, 0.0)
    end

    if lowfps then
        -- patented code xxx
        local coords = ENTITY.GET_ENTITY_COORDS(lowfpstar)
        FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], 82, 100.0, true, false, 0.0)
    end

    if customexplo then
        local coords = ENTITY.GET_ENTITY_COORDS(customexplosiontar)
        FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], customexplosion, 100.0, true, false, 0.0)

    end


	util.yield()
end
