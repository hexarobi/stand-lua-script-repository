--Scrip has been created by Parci

local json = require("json")
local function memScan(name, pattern, callback)
    local addr = memory.scan(pattern)
    if addr == 0 then
        util.log("Failed to find " .. name .. " pattern")
        found_all = false
        return
    end
    callback(addr)
    util.log("Found " .. name)
end

local SCIPtr
memScan("SCI", "48 8B D3 48 8D 4C 24 ? 48 69 D2", function (ptr)
	SCIPtr = memory.rip(ptr - 0x4)
end)


local function getSCAuthToken()
	return memory.read_string(SCIPtr)
end
local function findSCPlayers(name, offset)
	local resp = {}
	local response = false
	local ot = ""
	async_http.init("scui.rockstargames.com", "/api/friend/accountsearch", function(output)
		resp = json.decode(output)
		ot = output
		response = true
	end, function() response = false end)
	async_http.add_header("Authorization", 'SCAUTH val="' .. getSCAuthToken() .. '"')
	async_http.add_header("X-Requested-With", "XMLHttpRequest")
	async_http.set_post("application/json", '{"searchNickname":"' .. name .. '", "pageIndex":' .. offset .. '}')
	async_http.dispatch()
	repeat 
	    util.yield()
	until response
	return resp
end

local searchSCPlayerMenu = menu.list(menu.my_root(), "Search social club player", {}, "")

local scPlayers = {}
local searchSCPlayer = ""
local totalSearchedPlayers = -1
local currentSearchedPlayersLoad = 0
local onSearch = false
local ondel = false
local onFocusHandlers = {}
menu.text_input(searchSCPlayerMenu, "Name", {"searchscplayer"}, "", function (text)
	for _, value in ipairs(scPlayers) do
		if value ~= nil then value:delete() end

	end 
	scPlayers = {}
	onFocusHandlers = {}
	onFocusHandlers[0] = nil
	scPlayers[0] = nil
	totalSearchedPlayers = -1
	currentSearchedPlayersLoad = 0
	searchSCPlayer = text

	onSearch = false
	
	if #text < 3 then return end

	onSearch = true
	local data = findSCPlayers(searchSCPlayer, 0)
	totalSearchedPlayers = tonumber(data["Total"])
	local function loadMorePlayersOnFocus()
		onSearch = true
		if ondel then
			return
		end
		ondel = true
		menu.remove_handler(scPlayers[#scPlayers-5], onFocusHandlers[1])
		menu.remove_handler(scPlayers[#scPlayers], onFocusHandlers[2])
		onFocusHandlers = {}
		onFocusHandlers[0] = nil

		data = findSCPlayers(searchSCPlayer, currentSearchedPlayersLoad)
		local players = data["Accounts"] 
		currentSearchedPlayersLoad = data["NextOffset"]
		for i, player in ipairs(players) do
		
			local playerAddMenu = menu.action(menu.shadow_root(), player["Nickname"], {}, 'Add to history and open', function ()
				local pName = player["Nickname"]
				menu.trigger_commands("historyadd " .. pName)
				util.yield(100)
				menu.trigger_commands("historyadd " .. pName)
			end)
			local ch = searchSCPlayerMenu:getChildren()
			scPlayers[#scPlayers+1] = menu.attach_after(ch[#ch], playerAddMenu)
			util.yield()
			if (i == 10 or i == 5) and not (currentSearchedPlayersLoad > totalSearchedPlayers) then
				onFocusHandlers[#onFocusHandlers+1] = menu.on_focus(scPlayers[#scPlayers], function ()
					loadMorePlayersOnFocus()
				end)
			end
		end
		
		if currentSearchedPlayersLoad > totalSearchedPlayers then
			currentSearchedPlayersLoad = totalSearchedPlayers
		end
		util.yield(100)
		ondel = false
		onSearch = false
	end
	local players = data["Accounts"] 
    currentSearchedPlayersLoad = data["NextOffset"]
	onFocusHandlers[0] = nil
	for i, player in ipairs(players) do
		
		local playerAddMenu = menu.action(menu.shadow_root(), player["Nickname"], {}, 'Add to history and open', function ()
			local pName = player["Nickname"]
			menu.trigger_commands("historyadd " .. pName)
			util.yield(100)
			menu.trigger_commands("historyadd " .. pName)
		end)
		local ch = searchSCPlayerMenu:getChildren()
		scPlayers[#scPlayers+1] = menu.attach_after(ch[#ch], playerAddMenu)
		util.yield()
		if (i == 10 or i == 5) and not (currentSearchedPlayersLoad > totalSearchedPlayers) then
			onFocusHandlers[#onFocusHandlers+1] = menu.on_focus(scPlayers[#scPlayers], function ()
				loadMorePlayersOnFocus()
			end)
		end
	end
	
	currentSearchedPlayersLoad = data["NextOffset"]
	if currentSearchedPlayersLoad > totalSearchedPlayers then
		currentSearchedPlayersLoad = totalSearchedPlayers
	end
	onSearch = false
end)
local searchLine = menu.divider(searchSCPlayerMenu, "...")
local tagt = 0
util.create_tick_handler(function()
	if (not onSearch or #searchSCPlayer < 3) and totalSearchedPlayers == -1 then
		searchLine.menu_name = "^Enter player name^"
		tagt = 0
	elseif onSearch then
		local lab = ""
		for i = 0, tagt do	
			lab = lab .. "."
		end
		searchLine.menu_name = lab
		tagt = tagt+1
		if tagt > 50 then
			tagt = 0
		end
		util.yield(100)
	elseif totalSearchedPlayers == 0 then
		searchLine.menu_name = "No players found"
		tagt = 0
	elseif currentSearchedPlayersLoad < totalSearchedPlayers then
		searchLine.menu_name = currentSearchedPlayersLoad .. " of " .. totalSearchedPlayers .. " loaded"
		tagt = 0
	elseif currentSearchedPlayersLoad == totalSearchedPlayers then
		searchLine.menu_name = totalSearchedPlayers .. " found"
		tagt = 0
	else
		searchLine.menu_name = "Some error"
		tagt = 0

	end
	
end)