util.keep_running()
util.require_natives(1672190175)

local root = menu.my_root()

root:action("Claim All Personal Vehicles", {}, "Claims all destroyed/impounded personal vehicles", function()
    for slot = 0, 415 do
        local veh = memory.script_global(1586468 + 1 + (slot * 142) + 103)
        local bitfield = memory.read_int(veh)

        memory.write_int(veh, bitfield & ((bitfield & (1 << 1)) ~= 0 and ~0x26 or ~0x40))
    end
end)

root:action("Claim Personal Vehicle", {}, "Claims the current active personal vehicle", function()
    local pv_slot = memory.script_global(2359296 + 1 + (0 * 5568) + 681 + 2)
    local veh = memory.script_global(1586468 + 1 + (memory.read_int(pv_slot) * 142) + 103)
    local bitfield = memory.read_int(veh)

    memory.write_int(veh, bitfield & ((bitfield & (1 << 1)) ~= 0 and ~0x26 or ~0x40))
end)

root:toggle_loop("Auto Claim All Personal Vehicles", {}, "Automatically claims all destroyed/impounded personal vehicles", function()
    menu.ref_by_rel_path(root, "Claim All Personal Vehicles"):trigger()
    util.yield_once()
end)

root:toggle_loop("Auto Claim Personal Vehicle", {}, "Automatically claims the current active personal vehicle", function()
    menu.ref_by_rel_path(root, "Claim Personal Vehicle"):trigger()
    util.yield_once()
end)