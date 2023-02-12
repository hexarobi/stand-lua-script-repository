util.require_natives(1651208000)

--[[

█─▄▄▄─█─▄▄─█▄─▄▄▀█▄─▄▄─█─▄▄▄▄█─▄▄▄─█▄─▄▄▀█▄─▄█▄─▄▄─█─▄─▄─█
█─███▀█─██─██─██─██─▄█▀█▄▄▄▄─█─███▀██─▄─▄██─███─▄▄▄███─███
▀▄▄▄▄▄▀▄▄▄▄▀▄▄▄▄▀▀▄▄▄▄▄▀▄▄▄▄▄▀▄▄▄▄▄▀▄▄▀▄▄▀▄▄▄▀▄▄▄▀▀▀▀▄▄▄▀▀

Developed by Code#1337

I don't mind you using bits of code from CodeScript as long as its not the ENTIRE script :)

]]--

all_players_root = menu.list(menu.my_root(), "All players", {"allplayers"}, "Commands to use on everybody")
menu.divider(all_players_root, 'Applies to everybody')

toxic_root = menu.list(all_players_root, "Toxic", {"toxic"}, "Toxic options")

fun_root = menu.list(all_players_root, "Fun", {"fun"}, "Fun options")

friendly_root = menu.list(all_players_root, "Friendly", {"friendly"}, "Friendly options")

me_root = menu.list(menu.my_root(), "Self", {"selfoptions"}, "Your options")

render_root = menu.list(menu.my_root(), "Render", {"renderoptions"}, "Graphics stuff")

local function request_control_of_entity(ent, time)
    if ent and ent ~= 0 then
        local end_time = os.clock() + (time or 3)
        while not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(ent) and os.clock() < end_time do
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(ent)
            util.yield()
        end
        return NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(ent)
    end
    return false
end

local function shake_player(pid, power)
    local entity = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
    local coords = ENTITY.GET_ENTITY_COORDS(entity, true)
    FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], 7, 0, false, true, power)
end

local function send_player_vehicle_flying(pid)
    local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(ped, false)

    if vehicle == 0 then
        return
    end

    request_control_of_entity(vehicle)

    if NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(vehicle) then
        ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(vehicle, 1, 0, 100, 40, true, true, true, true)
        util.toast(players.get_name(pid) .. " is now flying ;)")
    else
        util.toast("could not request control of " .. players.get_name(pid) .. "'s vehicle")
    end
end

local function boost_vehicle(vehicle, speed)
    request_control_of_entity(vehicle)

    if NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(vehicle) then
        ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(vehicle, 1, 0, speed, 0, true, true, true, true)
        util.toast("done :D")
    else
        util.toast("failed to request control of vehicle :(")
    end
end

local function kill_player(pid)
    local entity = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
    local coords = ENTITY.GET_ENTITY_COORDS(entity, true)
    FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'] + 2, 7, 1000, false, true, 0)
end

local function vehicle_emp(pid)
    local entity = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
    local coords = ENTITY.GET_ENTITY_COORDS(entity, true)
    FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], 65, 999, false, true, 0)
end

local function fake_explosion(pid)
    local entity = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
    local coords = ENTITY.GET_ENTITY_COORDS(entity, true)
    FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], 7, 0, true, true, 0)
end

local function load_model(hash) -- lancescript
    local request_time = os.time()
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

local function upgrade_vehicle(vehicle) -- lancescript
    for i = 0, 49 do
        local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
        VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
    end
end

local function give_oppressor(pid)
    local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
    local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 5.0, 0.0)

    local hash = util.joaat("oppressor2")

    if not STREAMING.HAS_MODEL_LOADED(hash) then
        load_model(hash)
    end

    local oppressor = entities.create_vehicle(hash, c, ENTITY.GET_ENTITY_HEADING(ped))
    ENTITY.SET_ENTITY_INVINCIBLE(oppressor)

    upgrade_vehicle(oppressor)
end

local function get_player_count()
    return #players.list(true, true, true)
end

local function update_player_count()
    menu.set_menu_name(player_count, get_player_count() .. " player(s)")
end



local function make_car_jump(vehicle, jump)
    if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(vehicle) then
        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(vehicle)
    end

    ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(vehicle, 1, 0, 0, jump, true, false, true, true)
end

local function ped_explosion(pid, model_name, amount)
    local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
    local coords = ENTITY.GET_ENTITY_COORDS(ped, false)

    for i = 1, (amount or 5) do
        local hash = util.joaat(model_name or "a_c_shepherd")
        load_model(hash)

        local dog = entities.create_ped(28, hash, coords, math.random(0, 270))

        local size = 20
        local x = math.random(-size, size)
        local y = math.random(-size, size)
        local z = 5

        ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(dog, 1, x, y, z, true, false, true, true)
        AUDIO.PLAY_PAIN(dog, 7, 0)
    end
end

local function player_vehicle_options(pid, menu_list)
    menu.divider(menu_list, "Vehicle")

    menu.action(
        menu_list,
        "Spawn vehicle",
        {"spawnfor"},
        "Spawn a vehicle for " .. players.get_name(pid),

        function (click_type)
            menu.show_command_box_click_based(click_type, "spawnfor" .. players.get_name(pid) .. " ")
        end,

        function(txt)
            local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 5.0, 0.0)

            local hash = util.joaat(txt)

            if not STREAMING.HAS_MODEL_LOADED(hash) then
                load_model(hash)
            end

            local vehicle = entities.create_vehicle(hash, c, 0)

            request_control_of_entity(vehicle)
            
            AUDIO._SOUND_VEHICLE_HORN_THIS_FRAME(vehicle)

            --AUDIO.SET_HORN_PERMANENTLY_ON_TIME(vehicle, 3 * 1000)
        end
    )

    menu.action(
        menu_list,
        "Repair vehicle",
        {},
        "Repair " .. players.get_name(pid) .. "'s vehicle",

        function ()
            local ped = PLAYER.GET_PLAYER_PED(pid)
            local vehicle = PED.GET_VEHICLE_PED_IS_IN(ped, true)

            if vehicle ~= 0 then
                request_control_of_entity(vehicle)

                if NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(vehicle) then
                    VEHICLE.SET_VEHICLE_FIXED(vehicle)
                end
            end
        end
    )

    menu.action(
        menu_list,
        "Fully upgrade vehicle",
        {},
        "Upgrade the players car",

        function()
            local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)

            local vehicle = PED.GET_VEHICLE_PED_IS_USING(player_ped)
            request_control_of_entity(vehicle)
            upgrade_vehicle(vehicle)
        end
    )
end

local function load_weapon_asset(hash)
    while not WEAPON.HAS_WEAPON_ASSET_LOADED(hash) do
        WEAPON.REQUEST_WEAPON_ASSET(hash)
        util.yield(50)
    end
end

local function passive_mode_kill(pid)
    local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
    local hash = 0x787F0BB

    local audible = true
    local visible = true

    load_weapon_asset(hash)
    
    for i = 0, 50 do
        if PLAYER.IS_PLAYER_DEAD(pid) then
            util.toast("Successfully killed " .. players.get_name(pid))
            return
        end

        local coords = ENTITY.GET_ENTITY_COORDS(ped)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(coords.x, coords.y, coords.z, coords.x, coords.y, coords.z - 2, 100, 0, hash, 0, audible, not visible, 2500)
        
        util.yield(10)
    end

    util.toast("Could not kill " .. players.get_name(pid) .. ". Are they in god mode or no ragdoll?")
end

local function shoot_ped(ped, hash, damage, ownerPed)
    local audible = true
    local visible = true
    local speed = 1

    load_weapon_asset(hash)

    local ik_head = 0x322c
    local to = PED.GET_PED_BONE_COORDS(ped, ik_head, 0, 0, 0)

    local from = {}
    from.x = to.x - 0.2
    from.y = to.y
    from.z = to.z

    GRAPHICS.DRAW_LINE(from.x, from.y, from.z, to.x, to.y, to.z, 255, 100, 255, 255)
    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(from.x, from.y, from.z, to.x, to.y, to.z, damage, false, hash, ownerPed, audible, not visible, speed)
end

local function remove_vehicle_god(vehicle)
    request_control_of_entity(vehicle)

    if NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(vehicle) then
        ENTITY.SET_ENTITY_INVINCIBLE(vehicle, false)
    else
        util.toast("Was not able to gain control over a vehicle")
    end
end

local function explosion_circle(ped, angle, radius)
    local ped_coords = ENTITY.GET_ENTITY_COORDS(ped)

    local offset_x = ped_coords.x
    local offset_y = ped_coords.y

    local x = offset_x + radius * math.cos(angle)
    local y = offset_y + radius * math.sin(angle)

    FIRE.ADD_EXPLOSION(x, y, ped_coords.z, 4, 1, true, false, 0)
end

local function player_general_toxic_options(pid, menu_list)
    menu.divider(menu_list, "General")

    menu.toggle_loop(menu_list, "Extreme camera shake", {}, "Shake the players screen", function()
        shake_player(pid, 5000)
        util.yield(200)
    end)

    menu.action(menu_list, "Kill silently", {}, "Kill the player without loud explosions", function()
        kill_player(pid)
    end)

    menu.action(menu_list, "Passive mode kill", {}, "(DOESN'T WORK ON NO RAGDOLL PLAYERS) Kill player in passive mode", function ()
        passive_mode_kill(pid)
    end)

    menu.toggle_loop(menu_list, "Bullet spam", {}, "Spams bullets...", function ()
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        
        if not PED.IS_PED_DEAD_OR_DYING(ped) then
            local WEAPON_MG = 0x9D07F764
            shoot_ped(ped, WEAPON_MG, 100, 0)
        end

        util.yield(5)
    end)

    local explosion_circle_angle = 0
    menu.toggle_loop(menu_list, "Explosion circle", {}, "", function ()
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        explosion_circle(ped, explosion_circle_angle, 25)
        explosion_circle_angle += 0.15

        util.yield(50)
    end)
end


local function player_vehicle_toxic_options(pid, menu_list)
    menu.divider(menu_list, "Vehicle")

    menu.action(menu_list, "Invisible vehicle EMP", {"vehicleemp"}, "Vehicle EMP", function()
        vehicle_emp(pid)
    end)

    menu.action(menu_list, "Launch vehicle in the air", {"vehiclefly"}, "Sends players vehicle flying", function()
        send_player_vehicle_flying(pid)
    end)

    menu.action(menu_list, "Boost vehicle", {}, "Makes the car move forward faster :)", function ()
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local vehicle = PED.GET_VEHICLE_PED_IS_USING(ped)

        if vehicle == 0 then
            util.toast("that player is not driving a vehicle")
            return
        end

        boost_vehicle(vehicle, 50)
    end)

    menu.action(menu_list, "Remove vehicle god mode", {}, "Removes the players god mode (won't work if the player has protections)", function ()
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local vehicle = PED.GET_VEHICLE_PED_IS_USING(ped)

        if vehicle ~= 0 then
            remove_vehicle_god(vehicle)
        end
    end)

    
end

local function player_chat_options(pid, menu_list)
    menu.divider(menu_list, "Chat")

    menu.action(menu_list, "Send private chat message", {"chatto"}, "Sends message to this player only",
        function (click_type)
            menu.show_command_box_click_based(click_type, "chatto" .. players.get_name(pid) .. " ")
        end,
        function (txt)
            local from = players.user()
            local me = players.user()
            local to = pid
            local message = txt

            chat.send_targeted_message(to, from, message, false)
            chat.send_targeted_message(me, from, '(shows for you and ' .. players.get_name(to) .. ') ' .. message, false)
        end
    )

    menu.action(menu_list, "Send message to everyone except this player", {"chatexcept"}, "Sends message to this player only",
        function (click_type)
            menu.show_command_box_click_based(click_type, "chatexcept" .. players.get_name(pid) .. " ")
        end,
        function (txt)
            for k,v in pairs(players.list(true, true, true)) do
                if v ~= pid then
                    chat.send_targeted_message(v, players.user(), txt, false)
                end
            end
        end
    )
end

local function player_chat_spam(pid, menu_list)
    menu.divider(menu_list, "Chat Spammer (" .. players.get_name(pid) .. ")")

    local message = "Subscribe to Code Disease on YouTube thanks"
    local delay = 80
    local max = 100

    menu.toggle_loop(menu_list, "Enable spammer", {}, "", function()
        -- chat.send_message has some sort of rate limit for some reason
        chat.send_targeted_message(pid, players.user(), message, false)

        if pid ~= players.user() then
            chat.send_targeted_message(players.user(), players.user(), message, false)
        end

        local delay = (max - delay) * 10
        
        util.yield(delay)
    end)

    menu.text_input(menu_list, "Message", {"spammessage"}, "the text to be spammed", function(txt)
        message = txt
    end, message)

    menu.divider(menu_list, "Advanced")

    menu.slider(menu_list, "Spam speed", {},  "spam delay", 0, max, delay, 2, function (v)
        delay = v
    end)
end

local function player_toxic_chat_options(pid, menu_list)
    menu.divider(menu_list, "Chat")

    menu.action(menu_list, "Chat as " .. players.get_name(pid), {"chatasplayer"}, "Spoofs your chat username name",
        function (click_type)
            
            menu.show_command_box_click_based(click_type, "chatasplayer" .. players.get_name(pid) .. " ")
        end,
        function (txt)
            local from = pid
            local message = txt

            for k,v in pairs(players.list(true, true, true)) do
                chat.send_targeted_message(v, from, message, false)
            end
        end
    )

    player_chat_spammer = menu.list(menu_list, "Spam " .. players.get_name(pid), {"chatspam"}, "spam this user")

    player_chat_spam(pid, player_chat_spammer)

    -- menu.toggle_loop(menu_list, "Spam " .. players.get_name(pid), {}, )
end

local function player_trolling_options(pid, menu_list)
    menu.divider(menu_list, "Trolling")

    menu.action(menu_list, "Dog explosion", {}, "Woof", function ()
        ped_explosion(pid, "a_c_retriever")
    end)

    menu.action(menu_list, "Cat explosion", {}, "Meow", function ()
        ped_explosion(pid, "a_c_cat_01")
    end)

    menu.action(menu_list, "Fake explosion", {}, "Boom", function ()
        fake_explosion(pid)
    end)

    
end

players.on_join(
    function(pid)
        update_player_count()

        menu.divider(menu.player_root(pid), "CodeScript (" .. players.get_name(pid) .. ")")
        player_toxic_root = menu.list(menu.player_root(pid), "Toxic", {}, "Toxic options for " .. players.get_name(pid))
        player_friendly_root = menu.list(menu.player_root(pid), "Friendly", {}, "Friendly options for " .. players.get_name(pid))
        player_neutral_root = menu.list(menu.player_root(pid), "Neutral", {}, "Neutral options for " .. players.get_name(pid))

        
        -- toxic
        player_toxic_chat_options(pid, player_toxic_root)
        player_general_toxic_options(pid, player_toxic_root)
        player_vehicle_toxic_options(pid, player_toxic_root)

        -- friendly
        player_vehicle_options(pid, player_friendly_root)

        -- neutral
        player_chat_options(pid, player_neutral_root)
        player_trolling_options(pid, player_neutral_root)

    end
)

players.on_leave(function ()
    update_player_count()
end)

local function everyone_toxic_options(menu_list)

    menu.divider(menu_list, "Toxic / Troll")

    menu.toggle_loop(menu_list, "Screen shaker", {"shakeeveryone"}, "Shakes everyones screen", function()
        for k,v in pairs(players.list(true, true, true)) do
            shake_player(v, 5000)
            util.yield()
        end
        util.yield(1000)
    end)

    menu.action(menu_list, "Kill without explosion", {"killeveryone"}, "Silently kill everyone", function()
        for k,v in pairs(players.list(false, true, true)) do
            kill_player(v)
            util.yield()
        end
    end)

    menu.action(menu_list, "Passive mode kill", {"passivekilleveryone"}, "Passive mode kill everyone", function()
        for k,v in pairs(players.list(false, true, true)) do
            passive_mode_kill(v)
        end
    end)

    menu.divider(menu_list, "")
    menu.divider(menu_list, "Vehicle Trolls")

    menu.toggle_loop(menu_list, "Jumpy car", {"jumpycareveryone"}, "Makes everyone's car jump", function()
        for k,v in pairs(players.list(true, true, true)) do
            local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(v)
    
            if PED.IS_PED_IN_ANY_VEHICLE(ped) then
                local vehicle = PED.GET_VEHICLE_PED_IS_USING(ped)

                request_control_of_entity(vehicle)
    
                if NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(vehicle) then
                    make_car_jump(vehicle, 5)
                end
    
                util.yield(300)
            end
        end
    end)

    menu.toggle_loop(menu_list, "Ultra jumpy car", {"jumpycareveryone"}, "Makes everyone's car jump", function()
        for k,v in pairs(players.list(true, true, true)) do
            local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(v)
    
            if PED.IS_PED_IN_ANY_VEHICLE(ped) then
                local vehicle = PED.GET_VEHICLE_PED_IS_USING(ped)

                request_control_of_entity(vehicle)
    
                if NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(vehicle) then
                    make_car_jump(vehicle, 25)
                end
            end
        end
    
        util.yield(1000)
    end)

    menu.action(menu_list, "Launch vehicle in the air", {}, "Send everyones car flying", function ()
        for k,v in pairs(players.list(true, true, true)) do
            send_player_vehicle_flying(v)
            
        end
    end)

    local explosion_circle_angle = 0
    menu.toggle_loop(menu_list, "Explosion circle", {}, "", function ()
        for k,v in pairs(players.list(true, true, true)) do
            local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(v)
            explosion_circle(ped, explosion_circle_angle, 25)
        end

        explosion_circle_angle += 0.15
        util.yield(50)
    end)

    menu.action(menu_list, "Invisible vehicle EMP", {}, "Makes everyone's car stall", function ()
        for k,v in pairs(players.list(true, true, true)) do
            vehicle_emp(v)
            
        end
    end)

    menu.action(menu_list, "Remove vehicle god mode", {}, "", function ()
        for k,v in pairs(players.list(false, true, true)) do
            local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(v)
            local vehicle = PED.GET_VEHICLE_PED_IS_IN(ped)
    
            if vehicle ~= 0 then
                remove_vehicle_god(vehicle)
                
            end
        end
    end)
end

local function everyone_fun_options(menu_list)
    menu.divider(menu_list, "Fun (Everybody)")

    menu.action(menu_list, "Oppressor party", {"oppressorparty"}, "Spawn everyone an oppressor", function ()
        chat.send_message("OPPRESSOR PARTY!! SPAWNING AN OPPRESSOR FOR EVERYBODY!!! :D", false, true, true)
        for k,v in pairs(players.list(true, true, true)) do
            give_oppressor(v)
            util.yield()
        end
    end)
    
end

local function everyone_friendly_options(menu_list)
    menu.divider(menu_list, "Friendly (Everybody)")

    menu.action(menu_list, "Spawn vehicle", {"spawnvehicleeveryone"}, "Spawn everyone a vehicle",
    function (click_type)
        menu.show_command_box_click_based(click_type, "spawnvehicleeveryone ")
    end,
    function (txt)
        local hash = util.joaat(txt)

        if not STREAMING.HAS_MODEL_LOADED(hash) then
            load_model(hash)
        end

        for k,v in pairs(players.list(true, true, true)) do
            local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(v)
            local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 5.0, 0.0)

            local vehicle = entities.create_vehicle(hash, c, 0)

            request_control_of_entity(vehicle)

            util.yield()
        end
    end)
end

local function chat_spammer_options(menu_list)
    menu.divider(menu_list, "Chat spammer")

    local mode = 1

    local message = "pog"
    local delay = 80
    local max = 100

    menu.toggle_loop(menu_list, "Enable spammer", {}, "", function()
        local delay = (max - delay) * 10

        if mode == 1 then
            -- chat.send_message has some sort of rate limit for some reason
            for k,v in pairs(players.list(true, true, true)) do
                chat.send_targeted_message(v, players.user(), message, false)
            end
            util.yield(delay)
        elseif mode == 2 then
            for k1,v1 in pairs(players.list(true, true, true)) do
                for k2,v2 in pairs(players.list(true, true, true)) do
                    chat.send_targeted_message(v2, v1, message, false)
                end
                
                util.yield(delay)
            end
        end
    end)

    local options = {
		"Normal spam",
		"Everyone spamming"
	}

    menu.slider_text(menu_list, "Mode", {}, "", options, function(op)
        mode = op
        util.toast(op)
    end)

    menu.text_input(menu_list, "Message", {"spammessage"}, "the text to be spammed", function(txt)
        message = txt
    end, message)

    menu.divider(menu_list, "Advanced")

    menu.slider(menu_list, "Spam speed", {},  "spam delay", 0, max, delay, 2, function (v)
        delay = v
    end)
end

local function self_chat_options(menu_list)
    chat_spammer_options(menu_list)
end

local function self_experimental_features(menu_list)
    menu.divider(menu_list, "Experimental features SHH")

    menu.action(menu_list, "spinny car", {}, "", function()
        local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 0.0, 5.0, 0.0)

        local hash = util.joaat("jester3")

        if not STREAMING.HAS_MODEL_LOADED(hash) then
            load_model(hash)
        end

        local vehicle = entities.create_vehicle(hash, c, 0)

        request_control_of_entity(vehicle)

        if NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(vehicle) then
            util.toast("has control")
        end

        util.create_tick_handler(function ()
            local heading = ENTITY.GET_ENTITY_HEADING(vehicle)
            heading = heading + 2.5
            ENTITY.SET_ENTITY_HEADING(vehicle, heading)
            util.yield_once()
        end)
    end)
end

local function self_options(menu_list)
    menu.divider(menu_list, "Self")
    local chat_spammer = menu.list(menu_list, "Chat spammer", {"spammer"}, "chat spammer")
    local experimental_features = menu.list(menu_list, "Experimental features", {}, "")

    self_experimental_features(experimental_features)

    self_chat_options(chat_spammer)
end

local function render_waypoint_at(loc)
    -- GRAPHICS._DRAW_SPHERE(loc.x, loc.y, loc.z, 0.4, 255, 100, 255, 100)
    GRAPHICS.DRAW_LINE(loc.x, loc.y, loc.z, loc.x, loc.y, loc.z + 100, 255, 100, 255, 100)
end



local function render_options(menu_list)
    menu.divider(menu_list, "Render / Graphics")

    menu.toggle_loop(menu_list, "Render waypoint", {}, "", function ()
        if HUD.IS_WAYPOINT_ACTIVE() then
            local blip = HUD.GET_FIRST_BLIP_INFO_ID(8)
            local loc = HUD.GET_BLIP_COORDS(blip)

            render_waypoint_at(loc)
        end
    end)

    menu.toggle_loop(menu_list, "Render my location", {}, "", function ()
        local my_ped = players.user_ped()
        local loc = ENTITY.GET_ENTITY_COORDS(my_ped)

        render_waypoint_at(loc)
    end)

    menu.divider(menu_list, "Advanced")

    menu.action(menu_list, "Add white blip at my location", {}, "test", function (toggle)
        local me_ped = players.user_ped()
        local pos = ENTITY.GET_ENTITY_COORDS(me_ped, false)
        HUD.ADD_BLIP_FOR_RADIUS(pos.x, pos.y, pos.z, 5)
    end)
end

everyone_toxic_options(toxic_root)
everyone_fun_options(fun_root)
everyone_friendly_options(friendly_root)

self_options(me_root)

render_options(render_root)

player_count = menu.action(all_players_root, get_player_count() .. " player(s)", {}, "", function()
    util.toast("There are " .. get_player_count() .. " player(s) in your lobby :)")
end)

















-- GUI CODE

local window_x = 0.01
local window_y = 0.03
local text_margin = 0.003
local text_height = 0.018 -- (not accurate lol)
local window_width = 0.12
local window_height = 0.2
local menu_items = {
    "menu option 1",
    "menu option 2",
    "menu option 3",
    "menu option 4",
    "menu option 5"
}
local selected_index = 0

local blur_rect_instance

local function colour(r, g, b, a)
    return { -- colour values go between 0 and 1
        r = r / 255,
        g = g / 255,
        b = b / 255,
        a = a / 255
    }
end

local function gui_background(x, y, width, height, blur_radius)
    local background = colour(10, 0, 10, 100)

    local border_color_left = colour(255, 0, 255, 255)
    local border_color_right = colour(0, 0, 0, 255)

    directx.blurrect_draw(
        blur_rect_instance, 
        x, y, width, height,
        blur_radius or 5
    )

    directx.draw_rect(
        x, y,
        width, height,
        background
    )

    -- left border line
    directx.draw_line(
        x, y,
        x, y + height,
        border_color_left
    )

    -- top border line
    directx.draw_line(
        x, y,
        x + width, y,
        border_color_left, border_color_right
    )

    directx.draw_line(
        x + width, y,
        x + width, y + height,
        border_color_right
    )

    -- bottom border line
    directx.draw_line(
        x, y + height,
        x + width, y + height,
        border_color_left, border_color_right
    )
end



local function text(text, x, y, text_scale, highlighted)
    if highlighted then
        directx.draw_rect(
            x, y,
            window_width - (text_margin * 2), text_height,
            colour(15, 15, 15, 0)
        )
    end

    directx.draw_text(
        x, y, text, ALIGN_TOP_LEFT, text_scale,
        colour(255, 255, 255, 255)
    )
end

local function render_list(x, y, list, selected_index)
    local ty = 0
    local text_scale = 0.5 -- dont change :)

    for i,v in pairs(list) do
        local highlighed = i == selected_index - 1

        text(v, x, y + ty, text_scale, highlighed)
        ty = ty + text_height
    end
end

local function edition_string()
    local edition = menu.get_edition()

    if edition == 0 then
        return "free"
    elseif edition == 1 then
        return "basic"
    elseif edition == 2 then
        return "regular"
    elseif edition == 3 then
        return "ultimate"
    end
end

local function render_menu()
    local width = window_width
    local height = window_height

    gui_background(window_x, window_y,
        width, height)

    text("Stand " .. edition_string(),
        window_x + text_margin,
        window_y + text_margin,
        0.6, false)
    
    local top_margin = 0.025
    
    render_list(
        window_x + text_margin,
        window_y + text_margin + top_margin,
        menu_items, selected_index
    )
end

local function set_menu_open(toggle) end -- this needs to be defined before input_handler but after tick_handler

local menu_is_open = false

local function input_handler()
    if menu.is_open() then return end

    local VK_NUMPAD8 = 0x68
    local VK_NUMPAD2 = 0x62

    if util.is_key_down(VK_NUMPAD2) then
        selected_index = selected_index + 1

    elseif util.is_key_down(VK_NUMPAD8) then
        selected_index = selected_index - 1

    end
end

local function tick_handler()
    if menu_is_open then
        render_menu()
    end

    input_handler()
    return true
end

blur_rect_instance = directx.blurrect_new()
util.create_tick_handler(tick_handler) -- start the loop (it stops when menu_is_open is false)

function set_menu_open(toggle)
    if toggle and not menu_is_open then
        menu_is_open = true
        
    elseif not toggle and menu_is_open then
        menu_is_open = false

    end
end

menu.toggle(menu.my_root(), "show experimental gui", {}, "", function(toggle)
    set_menu_open(toggle)
end)

-- END OF GUI CODE








players.dispatch_on_join()


util.on_stop(function ()
    directx.blurrect_free(blur_rect_instance)
    util.toast("CodeScript disappears")
end)