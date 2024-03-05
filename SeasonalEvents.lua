--[[
#
#   This script was heavily inspired by ShinyWasabi's event script for YimMenu.
#   I (LordByron_) ported everything over to Stand and added some stuff.
#
--]]
util.keep_running()
util.require_natives("natives-3095a")

function MP(stat)
    return "MP" .. util.get_char_slot() .. "_"
end

function GET_INT_GLOBAL(global)
    return memory.read_int(memory.script_global(global))
end
function SET_INT_GLOBAL(global, value)
    memory.write_int(memory.script_global(global), value)
end

function GET_FLOAT_GLOBAL(global)
    return memory.read_float(memory.script_global(global))
end
function SET_FLOAT_GLOBAL(global, value)
    memory.write_float(memory.script_global(global), value)
end

function GET_VEC3_GLOBAL(global)
    return memory.read_vector3(memory.script_global(global))
end
function SET_VEC3_GLOBAL(global, value)
    memory.write_vector3(memory.script_global(global), value)
end

function SET_TUNABLE(tunable, value)
    memory.write_int(memory.tunable(tunable), value)
end

function SET_PACKED_STAT_BOOL(stat, value)
    STATS.SET_PACKED_STAT_BOOL_CODE(stat, value, util.get_char_slot())
end

random_events = {
    DRUG_VEHICLE = 0,
    MOVIE_PROPS = 1,
    GOLDEN_GUN = 2,
    VEHICLE_LIST = 3,
    SLASHERS = 4,
    PHANTOM_CAR = 5,
    SIGHTSEEING = 6,
    SMUGGLER_TRAIL = 7,
    CERBERUS = 8,
    SMUGGLER_PLANE = 9,
    CRIME_SCENE = 10,
    METAL_DETECTOR = 11,
    GANG_CONVOY = 12,
    STORE_ROBBERY = 13,
    XMAS_MUGGER = 14,
    BANK_SHOOTOUT = 15,
    ARMORED_TRUCK = 16,
    POSSESSED_ANIMALS = 17,
    GHOSTHUNT = 18,
    XMAS_TRUCK = 19,
}

local selected_event = 0
local event_state
local event_loc
local event_coords
local trigger_range
local fmmc_types = { 24, 26, 259, 273, 270, 269, 275, 286, 287, 266, 147, 268, 288, 290, 310, 311, 312, 320, 313, 323 }
local event_hash = -126218586
local gsbd_randomevents = 1882037

util.create_tick_handler(function (script)
	event_state = GET_INT_GLOBAL(gsbd_randomevents + 1 + (1 + (selected_event * 15)))
	event_loc = GET_INT_GLOBAL(gsbd_randomevents + 1 + (1 + (selected_event * 15)) + 6)
	event_coords = GET_VEC3_GLOBAL(gsbd_randomevents + 1 + (1 + (selected_event * 15)) + 10) -- It gets updated every 5 seconds
	trigger_range = GET_FLOAT_GLOBAL(gsbd_randomevents + 1 + (1 + (selected_event * 15)) + 13)
	SET_TUNABLE(util.joaat("StandardControllerVolume"), 1) -- Slashers
	SET_TUNABLE(util.joaat("StandardTargettingTime"), 1) -- Phantom Car
	SET_TUNABLE(util.joaat("SSP2POSIX"), 1697101200)
	SET_TUNABLE(util.joaat("ENABLE_SU22_SMUGGLER_TRAIL"), 1) -- R* has disabled it in 1.68 for some reason
	SET_TUNABLE(util.joaat("NC_SOURCE_TRUCK_HEAD_COUNT"), 3) -- Cerberus
	SET_TUNABLE(util.joaat("STANDARD_KEYBIND_SELECTION"), 1) -- Gooch
	SET_TUNABLE(util.joaat("ENABLE_MAZEBANKSHOOTOUT_DLC22022"), 1)
	SET_TUNABLE(util.joaat("ENABLE_HALLOWEEN_GHOSTHUNT"), 1)
	SET_TUNABLE(util.joaat("ENABLE_HALLOWEEN_POSSESSED_ANIMAL"), 1)
	SET_TUNABLE(2093114948, 1) -- Happy Holidays Hauler
end)

function start_event(event_id, event_location)
    local args = {event_hash, 0, event_id, 0, event_location, 0}
    util.trigger_script_event(util.get_session_players_bitflag(), args)
end

menu.list_select(menu.my_root(), "Event", {}, "", {
    {random_events.DRUG_VEHICLE, "Drug Vehicle"},
    {random_events.MOVIE_PROPS, "Movie Props"},
    {random_events.GOLDEN_GUN, "Sleeping Guard"},
    {random_events.VEHICLE_LIST, "Exotic Exports"},
    {random_events.SLASHERS, "Slashers"},
    {random_events.PHANTOM_CAR, "Phantom Car"},
    {random_events.SIGHTSEEING, "Sightseeing"},
    {random_events.SMUGGLER_TRAIL, "Smuggler Trail"},
    {random_events.CERBERUS, "Cerberus"},
    {random_events.SMUGGLER_PLANE, "Smuggler Plane"},
    {random_events.CRIME_SCENE, "Crime Scene"},
    {random_events.METAL_DETECTOR, "Metal Detector"},
    {random_events.GANG_CONVOY, "Gang Convoy"},
    {random_events.STORE_ROBBERY, "Store Robbery"},
    {random_events.XMAS_MUGGER, "Gooch"},
    {random_events.BANK_SHOOTOUT, "Weazel Bank Shootout"},
    {random_events.ARMORED_TRUCK, "Armoured Truck"},
    {random_events.POSSESSED_ANIMALS, "Possessed Animals"},
    {random_events.GHOSTHUNT, "Ghosts Exposed"},
    {random_events.XMAS_TRUCK, "Happy Holidays Hauler"},
}, 0, function(value, menu_name, prev_value, click_type)
    selected_event = value
    eventrange.value = (GET_FLOAT_GLOBAL(gsbd_randomevents + 1 + (1 + (selected_event * 15)) + 13) * 100)
end)

selected_loc = menu.slider(menu.my_root(), "Event Location", {"eventloc"}, "", 0, 2147483647, 0, 1, function(value) end)

eventrange = menu.slider_float(menu.my_root(), "Trigger Range", {"eventrange"}, "", 0, 100000000, trigger_range * 100, 50, function(value)
    SET_FLOAT_GLOBAL(gsbd_randomevents + 1 + (1 + (selected_event * 15)) + 13, value / 100)
end)

menu.action(menu.my_root(), "Launch Event", {}, "", function()
    while players.get_script_host() ~= players.user() do
        util.toast("You are not the script host. Please wait...")
        menu.trigger_commands("scripthost")
        util.yield(1000)
    end
    start_event(fmmc_types[selected_event + 1], selected_loc.value)
    util.yield(1000)
    if event_state >= 1 then
        util.toast("The event has been started successfully.")
    else
        util.toast("There has been an error while starting the event.")
    end
end)

menu.action(menu.my_root(), "Teleport", {}, "", function()
    if random_events.PHANTOM_CAR ~= selected_event and random_events.SIGHTSEEING ~= selected_event and random_events.XMAS_MUGGER ~= selected_event and random_events.GHOSTHUNT ~= selected_event then
        if event_state >= 1 then
            if event_coords.x ~= 0.0 and event_coords.y ~= 0.0 and event_coords.z ~= 0.0 then
                players.teleport_3d(players.user(), event_coords.x, event_coords.y, event_coords.z)
            else
                util.toast("Wait for coordinates to be updated.")
            end
        else
            util.toast("The event is not active.")
        end
    else
        util.toast("This event doesn't support teleporting.")
    end
end)


menu.divider(menu.my_root(), "Other Events")

local yeti = menu.list(menu.my_root(), "Yeti Event", {""}, "")
menu.toggle_loop(yeti, "Enable", {}, "", function()
    SET_INT_GLOBAL(262145 + 36054, 1)
end)
menu.action(yeti, "Position 1", {}, "", function()
    players.teleport_3d(players.user(), -1562.69, 4699.04, 50.426)
end)
menu.action(yeti, "Position 2", {}, "", function()
    players.teleport_3d(players.user(), -1359.869, 4733.429, 46.919)
end)
menu.action(yeti, "Position 3", {}, "", function()
    players.teleport_3d(players.user(), -1715.398, 4501.203, 0.096)
end)
menu.action(yeti, "Position 4", {}, "", function()
    players.teleport_3d(players.user(), -1282.18, 4487.826, 12.643)
end)
menu.action(yeti, "Position 5", {}, "", function()
    players.teleport_3d(players.user(), -1569.665, 4478.485, 20.215)
end)


menu.divider(menu.my_root(), "Rockstar Gifts")

local wait_msg = "This can take up to 30 seconds."

-- 2014
menu.action(menu.my_root(), "2014 Holiday Gift", {}, wait_msg .. "\nStocking Mask", function()
    SET_PACKED_STAT_BOOL(3741, false)
    SET_TUNABLE(util.joaat("TOGGLE_GIFT_TO_PLAYER_WHEN_LOGGING_ON"), 1)
end)

-- 2015
menu.action(menu.my_root(), "2015 XMAS Day Gift", {}, wait_msg .. "\nAbominable Snowman Mask", function()
    SET_PACKED_STAT_BOOL(4332, false)
    SET_TUNABLE(util.joaat("TOGGLE_2015_CHRISTMAS_DAY_GIFT"), 1)
end)

-- 2016
menu.action(menu.my_root(), "2016 Gift 1", {}, wait_msg .. "\nOdious Krampus Mask", function()
    SET_PACKED_STAT_BOOL(18130, false)
    SET_TUNABLE(-101086705, 1) -- Odious Krampus
end)
menu.action(menu.my_root(), "2016 Gift 2", {}, wait_msg .. "\nHideous Krampus Mask", function()
    SET_PACKED_STAT_BOOL(18131, false)
    SET_TUNABLE(-551933479, 1) -- Hideous Krampus
end)
menu.action(menu.my_root(), "2016 Gift 3", {}, wait_msg .. "\nFearsome Krampus Mask", function()
    SET_PACKED_STAT_BOOL(18132, false)
    SET_TUNABLE(-2080228265, 1) -- Fearsome Krampus
end)

-- 2017
menu.action(menu.my_root(), "2017 XMAS Day Gift", {}, wait_msg .. "\nHeinous Krampus Mask", function()
    SET_PACKED_STAT_BOOL(18133, false)
    SET_TUNABLE(util.joaat("TOGGLE_2017_CHRISTMAS_DAY_GIFT"), 1)
end)

-- 2018
menu.action(menu.my_root(), "2018 XMAS Eve Gift", {}, wait_msg .. "\nBlack & White Bones Festive Sweater", function()
    SET_PACKED_STAT_BOOL(25018, false)
    SET_TUNABLE(util.joaat("TOGGLE_2018_CHRISTMAS_EVE_GIFT"), 1)
end)
menu.action(menu.my_root(), "2018 XMAS Day Gift", {}, wait_msg .. "\nSlasher Festive Sweater, Up-n-Atomizer", function()
    SET_PACKED_STAT_BOOL(25019, false)
    SET_TUNABLE(util.joaat("TOGGLE_2018_CHRISTMAS_DAY_GIFT"), 1)
end)
menu.action(menu.my_root(), "2018 NY Eve Gift", {}, wait_msg .. "\nBlack & Red Bones Festive Sweater", function()
    SET_PACKED_STAT_BOOL(25020, false)
    SET_TUNABLE(util.joaat("TOGGLE_2018_NEW_YEARS_EVE_GIFT"), 1)
end)
menu.action(menu.my_root(), "2018 NY Day Gift", {}, wait_msg .. "\nRed Bones Festive Sweater", function()
    SET_PACKED_STAT_BOOL(25021, false)
    SET_TUNABLE(util.joaat("TOGGLE_2018_NEW_YEARS_DAY_GIFT"), 1)
end)

-- 2019
menu.action(menu.my_root(), "2019 XMAS Eve Gift", {}, wait_msg .. "\nGreen Reindeer Lights Bodysuit", function()
    SET_PACKED_STAT_BOOL(28167, false)
    SET_TUNABLE(util.joaat("TOGGLE_2019_CHRISTMAS_EVE_GIFT"), 1)
end)
menu.action(menu.my_root(), "2019 XMAS Day Gift", {}, wait_msg .. "\nMinigun Sweater, Festive Lights Bodysuit", function()
    SET_PACKED_STAT_BOOL(28168, false)
    SET_TUNABLE(util.joaat("TOGGLE_2019_CHRISTMAS_DAY_GIFT"), 1)
end)
menu.action(menu.my_root(), "2019 NY Eve Gift", {}, wait_msg .. "\nYellow Reindeer Lights Bodysuit", function()
    SET_PACKED_STAT_BOOL(28169, false)
    SET_TUNABLE(util.joaat("TOGGLE_2019_NEW_YEARS_EVE_GIFT"), 1)
end)
menu.action(menu.my_root(), "2019 NY Day Gift", {}, wait_msg .. "\nNeon Festive Lights Bodysuit", function()
    SET_PACKED_STAT_BOOL(28170, false)
    SET_TUNABLE(util.joaat("TOGGLE_2019_NEW_YEARS_DAY_GIFT"), 1)
end)

-- 2020
menu.action(menu.my_root(), "2020 XMAS Day Gift", {}, wait_msg .. "\nVibrant Stitch Emissive Mask", function()
    SET_PACKED_STAT_BOOL(30695, false)
    SET_TUNABLE(util.joaat("TOGGLE_2020_CHRISTMAS_DAY_GIFT"), 1)
end)

-- 2021
menu.action(menu.my_root(), "2021 XMAS Gift", {}, wait_msg .. "\nClownfish Mask, Red Festive Tee", function()
    SET_PACKED_STAT_BOOL(32292, false)
    SET_TUNABLE(util.joaat("TOGGLE_2021_CHRISTMAS_GIFT"), 1)
end)
menu.action(menu.my_root(), "2021 NY Gift", {}, wait_msg .. "\nBrown Sea Lion Mask, Green Festive Tee", function()
    SET_PACKED_STAT_BOOL(32293, false)
    SET_TUNABLE(util.joaat("TOGGLE_2021_NEW_YEARS_GIFT"), 1)
end)

-- 2022
menu.action(menu.my_root(), "2022 XMAS Gift", {}, wait_msg .. "\nGreen Reindeer Beer Hat", function()
    SET_PACKED_STAT_BOOL(36821, false)
    SET_TUNABLE(util.joaat("XMASGIFTS2022"), 1)
end)
menu.action(menu.my_root(), "2022 NY Gift", {}, wait_msg .. "\nYellow Holly Beer Hat, New Years Glasses", function()
    SET_PACKED_STAT_BOOL(36822, false)
    SET_TUNABLE(util.joaat("NEWYEARSGIFTS2022"), 1)
end)

-- 2023
menu.action(menu.my_root(), "2023 XMAS Gift", {}, wait_msg .. "\nCandy Cane, Snowball Launcher, Green Reindeer Beer Hat, White Festive Reindeer Hat, Green Festive Tree Hat", function()
    SET_PACKED_STAT_BOOL(42218, false)
    SET_TUNABLE(util.joaat("XMASGIFTS2023"), 1)
end)
menu.action(menu.my_root(), "2023 NY Gift", {}, wait_msg .. "\nNew Year's Hats, New Year's Glasses", function()
    SET_PACKED_STAT_BOOL(42219, false)
    SET_TUNABLE(util.joaat("NEWYEARSGIFTS2023"), 1)
end)

-- Other Gifts
othergifts = menu.action(menu.my_root(), "Other Gifts", {}, "Sprunk x eCola, R* Anniversary, etc.", function()
    menu.show_warning(othergifts, CLICK_COMMAND, "This will put you in a new session! If you try to unlock the other gifts as well, wait for them to unlock before proceeding.", function()
        menu.trigger_commands("go solopublic")
        while (GET_INT_GLOBAL(1575008) ~= 25) do -- Wait for TRANSITION_STATE_FM_TRANSITION_CREATE_PLAYER
            util.yield()
        end

        SET_PACKED_STAT_BOOL(32280, false)
        SET_TUNABLE(-224236432, 1) -- Sprunk x eCola Challenge
        SET_TUNABLE(util.joaat("XMAS23_SPRUNK_PLATE"), 1)
        SET_TUNABLE(util.joaat("XMAS23_ECOLA_PLATE"), 1)

        SET_PACKED_STAT_BOOL(32281, false)
        SET_TUNABLE(-1334486436, 1) -- Doomsday Heist Challenge

        SET_PACKED_STAT_BOOL(32282, false)
        SET_TUNABLE(1537236554, 1) -- Simeon's Export Request Challenge

        SET_PACKED_STAT_BOOL(42220, false)
        SET_TUNABLE(635655339, 1) -- Rockstar Anniversary
    end)
end)
