util.require_natives("1663599433")

-- Source code by: Prisuhm#5253 on Discord. 

function bitTest(addr, offset)
    return (memory.read_int(addr) & (1 << offset)) ~= 0
end

function reclaimAll() 
	local count = memory.read_int(memory.script_global(1586468))
    for i = 0, count do
        local canFix = (bitTest(memory.script_global(1586468 + 1 + (i * 142) + 103), 1) and bitTest(memory.script_global(1586468 + 1 + (i * 142) + 103), 2))
        if canFix then
            MISC.CLEAR_BIT(memory.script_global(1586468 + 1 + (i * 142) + 103), 1)
            MISC.CLEAR_BIT(memory.script_global(1586468 + 1 + (i * 142) + 103), 3)
            MISC.CLEAR_BIT(memory.script_global(1586468 + 1 + (i * 142) + 103), 16)
            util.toast("Your personal vehicle was destroyed. It has been automatically claimed.")
        end
    end
end

-- menu nodes
menu.toggle_loop(menu.my_root(), "Auto Claim Destroyed Vehicles", {}, "Automatically claims destroyed vehicles so you won't have to.\nLess efficient performance-wise.", function()
    reclaimAll()
    util.yield(100)
end)

menu.action(menu.my_root(), "Claim Destroyed Vehicles", {}, "Claims destroyed vehicles so you won't have to.", function()
	reclaimAll()
end)

util.keep_running()