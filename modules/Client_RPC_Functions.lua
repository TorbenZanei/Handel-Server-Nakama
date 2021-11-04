local nk = require("nakama")
local core = require("Core_Function")
local gf = require("Game_Functions")

local room_funiture_table = {{0,1},{2},{3},{4}}



-- Spielstandveränderung speichern
local function save_update(_context, save_state)
	local update = nk.json_encode(save_state)
	local new_save_state = {{collection = "player_data", key = "save_state", user_id = _context.user_id, value = {["SaveState"] = update}}}
	nk.storage_write(new_save_state)
end


local function get_world_id(_context, _payload)
	local matches = nk.match_list()
	local current_match = matches[1]
	
	if current_match == nil then
		return nk.match_create("World_Control", {})
	else
		return current_match.match_id
	end
end

local function get_world_data(_context, _payload)
	
	local object_ids = {{collection = "Welt_1", key = "Ware_Data"}}
	local object = nk.storage_read(object_ids)
	
	return object[1].value["Ware_Data"]
end

local function get_save_state(_context, _payload)
	
	local save_state = {{collection = "player_data", key = "save_state", user_id = _context.user_id}}
	local object = nk.storage_read(save_state)
	
--	nk.logger_info(object[1].value["SaveState"])
	
	return object[1].value["SaveState"]
end



-- Funktion um die Bauflächenerweiterung zu prüfen
local function extend_shop(_context, _payload)
	local object = nk.storage_read({{collection = "player_data", key = "save_state", user_id = _context.user_id}})
	local save_state = nk.json_decode(object[1].value["SaveState"])
	local data = nk.json_decode(_payload)
	local id_data = {}
	id_data[1] = data[1] + 1
	id_data[2] = data[2] + 1
	if save_state[1] >= 2500 and save_state[3][id_data[2]][id_data[1]] == 1 then
		save_state[1] = save_state[1] - 2500
		save_state[3][id_data[2]][id_data[1]] = 2
		if data[2] > 0 and save_state[3][id_data[2] - 1][id_data[1]] == 0 then
			save_state[3][id_data[2] - 1][id_data[1]] = 1
		end
		if data[2] < 3 and save_state[3][id_data[2] + 1][id_data[1]] == 0 then
			save_state[3][id_data[2] + 1][id_data[1]] = 1
		end
		if data[1] > 0 and save_state[3][id_data[2]][id_data[1] - 1] == 0 then
			save_state[3][id_data[2]][id_data[1] - 1] = 1
		end
		if data[1] < 3 and save_state[3][id_data[2]][id_data[1] + 1] == 0 then
			save_state[3][id_data[2]][id_data[1] + 1] = 1
	 	end
		for i = 1, 7 do
			for l = 1, 7 do
				if save_state[5][i + 5 * data[2]][l + 5 * data[1]][1] == 0 then				--Wenn unbabaut
					if (i == 1 and data[2] == 0) or (l == 1 and data[1] == 0) or (i == 7 and data[2] == 3) or (l == 7 and data[1] == 3) then
						save_state[5][i + 5 * data[2]][l + 5 * data[1]] = {2, 0, 1, 0, 0, 0, 3, 0}
					elseif i == 1 or l == 1 or i == 7 or l == 7 then
						save_state[5][i + 5 * data[2]][l + 5 * data[1]] = {2, 0, 1, 0, 0, 0, 2, 0}
					else
						save_state[5][i + 5 * data[2]][l + 5 * data[1]] = {1, 0, 0, 0, 0, 0, 0, 0}
					end
				elseif save_state[5][i + 5 * data[2]][l + 5 * data[1]][1] == 2 then			--Wenn Wand bereits vorhanden
					if save_state[5][i + 5 * data[2]][l + 5 * data[1]][7] == 2 and not(i == 1 or i == 7 or l == 1 or l == 7) then
						save_state[5][i + 5 * data[2]][l + 5 * data[1]][7] = 1
					end
				end
			end
		end
		
		save_update(_context, save_state)
		
		return "1"
	else
		return "0"
	end
end

-- Funktion um den Mauer/Türbau zu prüfen
local function construct_wall(_context, _payload)
	local object = nk.storage_read({{collection = "player_data", key = "save_state", user_id = _context.user_id}})
	local save_state = nk.json_decode(object[1].value["SaveState"])
	
	local data = nk.json_decode(_payload)
	local id_data = {}
	id_data[1] = data[1] + 1
	id_data[2] = data[2] + 1
	
	if save_state[1] >= 100 and save_state[5][id_data[2]][id_data[1]][1] == 1 and not(save_state[5][id_data[2]][id_data[1]][2] ~= 0 or 
	(save_state[5][id_data[2] - 1][id_data[1]][1] == 2 and save_state[5][id_data[2] - 1][id_data[1]][3] == 2) or 
	(save_state[5][id_data[2] + 1][id_data[1]][1] == 2 and save_state[5][id_data[2] + 1][id_data[1]][3] == 2) or 
	(save_state[5][id_data[2]][id_data[1] - 1][1] == 2 and save_state[5][id_data[2]][id_data[1] - 1][3] == 2) or 
	(save_state[5][id_data[2]][id_data[1] + 1][1] == 2 and save_state[5][id_data[2]][id_data[1] + 1][3] == 2)) then
		
		save_state[1] = save_state[1] - 100
		save_state[5][id_data[2]][id_data[1]] = {2, 0, 1, 0, 0, 0, 1, 0}
		
		save_update(_context, save_state)
		
		return "1"
	elseif save_state[1] >= 100 and save_state[5][id_data[2]][id_data[1]][1] == 2 and save_state[5][id_data[2]][id_data[1]][3] == 1 and save_state[5][id_data[2]][id_data[1]][7] ~= 2 then
	
		if ((id_data[2] == 1 or save_state[5][id_data[2] - 1][id_data[1]][1] == 2 and save_state[5][id_data[2] - 1][id_data[1]][3] == 1) and 
		    (id_data[2] == 22 or save_state[5][id_data[2] + 1][id_data[1]][1] == 2 and save_state[5][id_data[2] + 1][id_data[1]][3] == 1) and 
		    (id_data[1] == 1 or save_state[5][id_data[2]][id_data[1] - 1][1] ~= 2) and 
		    (id_data[1] == 22 or save_state[5][id_data[2]][id_data[1] + 1][1] ~= 2)) or 
		   ((id_data[1] == 1 or save_state[5][id_data[2]][id_data[1] - 1][1] == 2 and save_state[5][id_data[2]][id_data[1] - 1][3] == 1) and 
	     	(id_data[1] == 22 or save_state[5][id_data[2]][id_data[1] + 1][1] == 2 and save_state[5][id_data[2]][id_data[1] + 1][3] == 1) and 
		    (id_data[2] == 1 or save_state[5][id_data[2] - 1][id_data[1]][1] ~= 2) and 
		    (id_data[2] == 22 or save_state[5][id_data[2] + 1][id_data[1]][1] ~= 2)) then
			
			save_state[1] = save_state[1] - 100
			save_state[5][id_data[2]][id_data[1]] = {2, 0, 2, 0, 0, 0, save_state[5][id_data[2]][id_data[1]][7], 0}
			
			save_update(_context,save_state)
			
			return("1")
		else
			return("0")
		end
	elseif save_state[1] >= 100 and save_state[5][id_data[2]][id_data[1]][1] == 2 and save_state[5][id_data[2]][id_data[1]][3] == 2 and save_state[5][id_data[2]][id_data[1]][7] ~= 2 then
		local tile_data = save_state[5]
		local tile_coordinates = {id_data[1] ,id_data[2]}
		if gf.check_door_needet(save_state, tile_coordinates) then
			save_state[1] = save_state[1] - 100
			save_state[5][id_data[2]][id_data[1]] = {2, 0, 1, 0, 0, 0, save_state[5][id_data[2]][id_data[1]][7], 0}
			save_update(_context,save_state)
			return "1"
		else
			return "0"
		end	
		
	else
		return "0"
	end
end

-- Funktion um den Raumbau zu prüfen
local function construct_room(_context, _payload)
	
	local object = nk.storage_read({{collection = "player_data", key = "save_state", user_id = _context.user_id}})
	local save_state = nk.json_decode(object[1].value["SaveState"])
	
	local data = nk.json_decode(_payload)
	local id_data = {}
	id_data[1] = data[2][1] + 1
	id_data[2] = data[2][2] + 1
	
	local tile_data = save_state[5]
	local room_id = data[1]
	local tile_coordinates = id_data
	
	local result
	
	nk.logger_info(nk.json_encode(data))
	
	if room_id == 3 then
		result = gf.check_possible_shop(tile_data, tile_coordinates, {{}, false, false, save_state[4][1]}, {}, false)
	else
		result = gf.check_possible_room(tile_data, tile_coordinates, {{}, false, false, save_state[4][1]}, {}, false)
	end
	
	result = gf.check_room_wall(tile_data, result)
	
	if (result[2] and room_id < 3) or (result[3] and room_id == 3)then
		table.insert(save_state[4], {save_state[4][1], room_id})
		save_state[4][1] = save_state[4][1] + 1
		save_update(_context, save_state)
		return "1"
	else
		return "0"
	end
end

-- Funktion um den Einrichtungsbau zu prüfen
local function construct_funiture(_context, _payload)
	local object = nk.storage_read({{collection = "player_data", key = "save_state", user_id = _context.user_id}})
	local save_state = nk.json_decode(object[1].value["SaveState"])
	
	local data = nk.json_decode(_payload)
	local id_data = {}
	id_data[1] = data[2][1] + 1
	id_data[2] = data[2][2] + 1
	
	local room_for_id
	for i, room in ipairs(save_state[4]) do
		
		if type(room) == "table" and room[1] == save_state[5][id_data[2]][id_data[1]][2] then
			room_for_id = room
		end
	end
	
	local room_id = room_for_id[2] + 1	
	if save_state[1] >= 100 and save_state[5][id_data[2]][id_data[1]][1] == 1 and save_state[5][id_data[2]][id_data[1]][3] == 0 and core.table_contains(room_funiture_table[room_id], data[1]) then
		save_state[1] = save_state[1] - 100
		save_state[5][id_data[2]][id_data[1]][1] = 3
		save_state[5][id_data[2]][id_data[1]][4] = 1
		save_state[5][id_data[2]][id_data[1]][5] = 10
		save_state[5][id_data[2]][id_data[1]][6] = data[1]
		save_update(_context, save_state)
		return "1"
	else
		return "0"
	end
end

local function upgrade_funiture(_context, _payload)
	return nil
end

-- Funktion um einen Abriss zu prüfen
local function destory_object(_context, _payload)
	local object = nk.storage_read({{collection = "player_data", key = "save_state", user_id = _context.user_id}})
	local save_state = nk.json_decode(object[1].value["SaveState"])
	
	local data = nk.json_decode(_payload)
	local id_data = {}
	id_data[1] = data[2][1] + 1
	id_data[2] = data[2][2] + 1
	
	if data[1] == 3 then
		local tile = save_state[5][id_data[2]][id_data[1]]
		if (tile[3] <= 1 and gf.check_if_storage_removable({id_data[1], id_data[2]}, save_state) and tile[4] <= 1) or (tile[3] > 1 and tile[4] <= 1) then
			save_state[5][id_data[2]][id_data[1]][1] = 1
			save_state[5][id_data[2]][id_data[1]][3] = 0
			save_update(_context, save_state)
			return "1"
		else
			return "0"
		end
	elseif data[1] == 2 then
		if gf.check_if_room_deletable(save_state, save_state[5][id_data[2]][id_data[1]][2]) then
			gf.delete_room(save_state, save_state[5][id_data[2]][id_data[1]][2])
			save_update(_context, save_state)
			return "1"
		else
			return "0"
		end
	elseif data[1] == 1 then
		
		local action_allowed = true 
		
		local tile = save_state[5][id_data[2]][id_data[1]]
		local top_tile = save_state[5][id_data[2] - 1][id_data[1]]
		local bot_tile = save_state[5][id_data[2] + 1][id_data[1]]
		local left_tile = save_state[5][id_data[2]][id_data[1] - 1]
		local right_tile = save_state[5][id_data[2]][id_data[1] + 1]
		
		if tile[1] == 2 and tile[7] == 1 then	-- Wand ist eine Innenwand
			
			local sw = {} --status der umliegenden wände
			table.insert(sw, gf.get_tile_state(save_state[5][id_data[2] - 1][id_data[1] - 1]))
			table.insert(sw, gf.get_tile_state(save_state[5][id_data[2] - 1][id_data[1]]))
			table.insert(sw, gf.get_tile_state(save_state[5][id_data[2] - 1][id_data[1] + 1]))
			table.insert(sw, gf.get_tile_state(save_state[5][id_data[2]][id_data[1] - 1]))
			table.insert(sw, gf.get_tile_state(save_state[5][id_data[2]][id_data[1] + 1]))
			table.insert(sw, gf.get_tile_state(save_state[5][id_data[2] + 1][id_data[1] - 1]))
			table.insert(sw, gf.get_tile_state(save_state[5][id_data[2] + 1][id_data[1]]))
			table.insert(sw, gf.get_tile_state(save_state[5][id_data[2] + 1][id_data[1] + 1]))
			
			--Wand ist keine benötigte Ecke
			if sw[2] == 1 and sw[5] == 1 and (sw[3] == 2 or (sw[1] == 2 and sw[4] == 2 and sw[6] == 2 and sw[7] == 2 and sw[8] == 2)) then action_allowed = false end
			if sw[5] == 1 and sw[7] == 1 and (sw[8] == 2 or (sw[1] == 2 and sw[2] == 2 and sw[3] == 2 and sw[4] == 2 and sw[6] == 2)) then action_allowed = false end
			if sw[7] == 1 and sw[4] == 1 and (sw[6] == 2 or (sw[1] == 2 and sw[2] == 2 and sw[3] == 2 and sw[5] == 2 and sw[8] == 2)) then action_allowed = false end
			if sw[4] == 1 and sw[2] == 1 and (sw[1] == 2 or (sw[3] == 2 and sw[5] == 2 and sw[6] == 2 and sw[7] == 2 and sw[8] == 2)) then action_allowed = false end
			
			if sw[1] == 1 and sw[2] == 1 and sw[4] == 1 then action_allowed = true end
			if sw[2] == 1 and sw[3] == 1 and sw[5] == 1 then action_allowed = true end
			if sw[5] == 1 and sw[7] == 1 and sw[8] == 1 then action_allowed = true end
			if sw[4] == 1 and sw[6] == 1 and sw[7] == 1 then action_allowed = true end
			
			--Wand ist keine benötigtes T-Stück
			if sw[2] == 1 and sw[5] == 1 and sw[4] == 1 and (sw[1] == 2 or sw[3] == 2 or (sw[6] == 2 or sw[7] == 2 or sw[8] == 2)) then action_allowed = false end
			if sw[5] == 1 and sw[7] == 1 and sw[2] == 1 and (sw[3] == 2 or sw[8] == 2 or (sw[1] == 2 or sw[4] == 2 or sw[6] == 2)) then action_allowed = false end
			if sw[7] == 1 and sw[4] == 1 and sw[5] == 1 and (sw[6] == 2 or sw[8] == 2 or (sw[1] == 2 or sw[2] == 2 or sw[3] == 2)) then action_allowed = false end
			if sw[4] == 1 and sw[2] == 1 and sw[7] == 1 and (sw[1] == 2 or sw[6] == 2 or (sw[3] == 2 or sw[5] == 2 or sw[8] == 2)) then action_allowed = false end
			 
			if sw[1] == 1 and sw[2] == 1 and sw[4] == 1 and sw[6] == 1 and sw[7] == 1 then action_allowed = true end
			if sw[1] == 1 and sw[2] == 1 and sw[3] == 1 and sw[4] == 1 and sw[5] == 1 then action_allowed = true end
			if sw[2] == 1 and sw[3] == 1 and sw[5] == 1 and sw[7] == 1 and sw[8] == 1 then action_allowed = true end
			if sw[4] == 1 and sw[5] == 1 and sw[6] == 1 and sw[7] == 1 and sw[8] == 1 then action_allowed = true end
			
			--Wand ist kein benötigtes Kreuz
			if sw[2] == 1 and sw[4] == 1 and sw[5] == 1 and sw[6] == 1 and (sw[1] == 2 or sw[3] == 2 or sw[6] == 2 or sw[8] == 2) then action_allowed = false end
			
			--Wand ist nicht der Rahmen einer Tür
			if (top_tile[1] == 2 and top_tile[3] == 2) or (bot_tile[1] == 2 and bot_tile[3] == 2) or (left_tile[1] == 2 and left_tile[3] == 2) or (right_tile[1] == 2 and right_tile[3] == 2) then
				action_allowed = false 
			end
			
			if action_allowed then	--Ergebnis ob Wand benötigt wird oder nicht
				if top_tile[1] == 2 and bot_tile[1] == 2 and left_tile[1] ~= 2 and right_tile[1] ~= 2 then	-- Wand ist Vertikal
					if left_tile[2] == 0 and right_tile[2] == 0 then			--Auf beiden seiten der wand kein Raum
						save_state[5][id_data[2]][id_data[1]] = {1, 0, 0, 0, 0, 0, 0, 0}
					elseif left_tile[2] ~= 0 and right_tile[2] ~= 0 then		--Auf beiden seiten der wand Räume
						local room_1
						local room_2
						for i, room in ipairs(save_state[4]) do
							if type(room) == "table" then
								if room[1] == left_tile[2] then
									room_1 = room
								end
								if room[1] == right_tile[2] then
									room_2 = room
								end
							end
						end
						if room_1[1] == room_2[1] then							-- auf beiden seiten der gleiche Raum
							save_state[5][id_data[2]][id_data[1]] = {1, room_1[1], 0, 0, 0, 0, 0, 0}
						elseif room_1[2] == room_2[2] then						-- auf beiden seiten verschiedene Räume der gleichen art
							save_state[5][id_data[2]][id_data[1]] = {1, 0, 0, 0, 0, 0, 0, 0}
							gf.delete_room(save_state, left_tile[2])
							gf.fuse_rooms(save_state[5], {id_data[1], id_data[2]}, right_tile[2])
						else
							return "0"
						end
					elseif left_tile[2] == 0 and right_tile[2] ~= 0 then		--Links frei, Rechts ein Raum
						save_state[5][id_data[2]][id_data[1]] = {1, 0, 0, 0, 0, 0, 0, 0}
						gf.fuse_rooms(save_state[5], {id_data[1], id_data[2]}, right_tile[2])
					elseif left_tile[2] ~= 0 and right_tile[2] == 0 then		--Links ein Raum, Rechts frei
						save_state[5][id_data[2]][id_data[1]] = {1, 0, 0, 0, 0, 0, 0, 0}
						gf.fuse_rooms(save_state[5], {id_data[1], id_data[2]}, left_tile[2])
					else
						return "0"
					end
				
				elseif top_tile[1] ~= 2 and bot_tile[1] ~= 2 and left_tile[1] == 2 and right_tile[1] == 2 then -- Wand ist Horizontal
					if top_tile[2] == 0 and bot_tile[2] == 0 then				--Auf beiden seiten der wand kein Raum
						save_state[5][id_data[2]][id_data[1]] = {1, 0, 0, 0, 0, 0, 0, 0}
					elseif top_tile[2] ~= 0 and bot_tile[2] ~= 0 then			--Auf beiden seiten der wand Räume
						local room_1
						local room_2
						for i, room in ipairs(save_state[4]) do
							if type(room) == "table" then
								if room[1] == top_tile[2] then
									room_1 = room
								end
								if room[1] == bot_tile[2] then
									room_2 = room
								end
							end
						end
						if room_1[1] == room_2[1] then							-- auf beiden seiten der gleiche Raum
							save_state[5][id_data[2]][id_data[1]] = {1, room_1[1], 0, 0, 0, 0, 0, 0}
						elseif room_1[2] == room_2[2] then						-- auf beiden seiten verschiedene Räume der gleichen art
							save_state[5][id_data[2]][id_data[1]] = {1, 0, 0, 0, 0, 0, 0, 0}
							gf.delete_room(save_state, top_tile[2])
							gf.fuse_rooms(save_state[5], {id_data[1], id_data[2]}, bot_tile[2])
						else
							return "0"
						end
					elseif top_tile[2] == 0 and bot_tile[2] ~= 0 then			--Oben frei, Unten ein Raum
						save_state[5][id_data[2]][id_data[1]] = {1, 0, 0, 0, 0, 0, 0, 0}
						gf.fuse_rooms(save_state[5], {id_data[1], id_data[2]}, bot_tile[2])
					elseif top_tile[2] ~= 0 and bot_tile[2] == 0 then			--Oben ein Raum, Unten frei
						save_state[5][id_data[2]][id_data[1]] = {1, 0, 0, 0, 0, 0, 0, 0}
						gf.fuse_rooms(save_state[5], {id_data[1], id_data[2]}, top_tile[2])
					else
						return "0"
					end
				else	-- Wand trennt keine Räume
					if top_tile[0] ~= 2 and top_tile[1] ~= 0 then
						save_state[5][id_data[2]][id_data[1]] = {1, top_tile[1], 0, 0, 0, 0, 0, 0}
					elseif bot_tile[0] ~= 2 and bot_tile[1] ~= 0 then
						save_state[5][id_data[2]][id_data[1]] = {1, bot_tile[1], 0, 0, 0, 0, 0, 0}
					elseif left_tile[0] ~= 2 and left_tile[1] ~= 0 then
						save_state[5][id_data[2]][id_data[1]] = {1, left_tile[1], 0, 0, 0, 0, 0, 0}
					elseif right_tile[0] ~= 2 and right_tile[1] ~= 0 then
						save_state[5][id_data[2]][id_data[1]] = {1, right_tile[1], 0, 0, 0, 0, 0, 0}
					else
						save_state[5][id_data[2]][id_data[1]] = {1, 0, 0, 0, 0, 0, 0, 0}
					end
				end
				save_update(_context, save_state)
				return "1"
			else
				return "0"
			end
		else
			return "0"
		end
	end
end

local function hire_worker(_context, _payload)
	local object = nk.storage_read({{collection = "player_data", key = "save_state", user_id = _context.user_id}})
	local save_state = nk.json_decode(object[1].value["SaveState"])
	
	if save_state[1] >= 500 then
		save_state[1] = save_state[1] - 500
		save_state[2] = save_state[2] + 1
		save_update(_context, save_state)
		return "1"
	else
		return "0"
	end
end

local function fire_worker(_context, _payload)
	local object = nk.storage_read({{collection = "player_data", key = "save_state", user_id = _context.user_id}})
	local save_state = nk.json_decode(object[1].value["SaveState"])
	
	if save_state[2] > save_state[7] and save_state[2] > 0  then
		save_state[2] = save_state[2] - 1
		save_update(_context, save_state)
		return "1"
	else
		return "0"
	end
end

local function start_production(_context, _payload)
	local object = nk.storage_read({{collection = "player_data", key = "save_state", user_id = _context.user_id}})
	local save_state = nk.json_decode(object[1].value["SaveState"])
	
	object = nk.storage_read({{collection = "Welt_1", key = "Ware_Data"}})
	local ware_data = nk.json_decode(object[1].value["Ware_Data"])
	
	local data = nk.json_decode(_payload)
	local id_data = {}
	id_data[1] = data[3][1] + 1
	id_data[2] = data[3][2] + 1
	
	local tile = save_state[5][id_data[2]][id_data[1]]
	if tile[4] == 0 and save_state[7] < save_state[2] then
		if gf.check_if_on_stock(save_state, ware_data[data[1] + 1][5]) then
			gf.remove_from_storage(save_state, ware_data[data[1] + 1][5])
			save_state[7] = save_state[7] + 1
			tile[4] = 3
			tile[5] = ware_data[data[1]][6]
			tile[6] = data[1]
			tile[7] = data[2]
		
			save_update(_context, save_state)
			return "1"
		else
			save_state[7] = save_state[7] + 1
			tile[4] = 3
			tile[5] = 0
			tile[6] = data[1]
			tile[7] = data[2]
			tile[8] = 2
		
			save_update(_context, save_state)
			return "1"
		end
	else
		return "0"
	end
end

local function offer_for_sale(_context, _payload)
	local object = nk.storage_read({{collection = "player_data", key = "save_state", user_id = _context.user_id}})
	local save_state = nk.json_decode(object[1].value["SaveState"])
	
	object = nk.storage_read({{collection = "Welt_1", key = "Ware_Data"}})
	local ware_data = nk.json_decode(object[1].value["Ware_Data"])
	
	local data = nk.json_decode(_payload)
	local id_data = {}
	id_data[1] = data[3][1] + 1
	id_data[2] = data[3][2] + 1
	
	local tile = save_state[5][id_data[2]][id_data[1]]
	if tile[4] == 0 then
		tile[4] = 4
		tile[5] = 5
		tile[6] = data[1]
		tile[7] = data[2]
		
		save_update(_context, save_state)
		return "1"
	else
		return "0"
	end
end

local function update_action(_context, _payload)
	local object = nk.storage_read({{collection = "player_data", key = "save_state", user_id = _context.user_id}})
	local save_state = nk.json_decode(object[1].value["SaveState"])
	
	local data = nk.json_decode(_payload)
	local id_data = {}
	id_data[1] = data[2][1] + 1
	id_data[2] = data[2][2] + 1
	
	local tile = save_state[5][id_data[2]][id_data[1]]
	
	if tile[4] == 1 then
		tile[1] = 1
		tile[3] = 0
		tile[4] = 0
		tile[5] = 0
		tile[6] = 0
		
		save_update(_context, save_state)
		return "1"
	elseif tile[4] == 3 then
		if data[1] == 0 then
			save_state[7] = save_state[7] - 1
			tile[4] = 0
			tile[5] = 0
			tile[6] = 0
			tile[7] = 0
		else
			tile[7] = data[1]
		end
		
		save_update(_context, save_state)
		return "1"
	elseif tile[4] == 4 then
		nk.logger_info("test")
		if data[1] == 0 then
			tile[4] = 0
			tile[5] = 0
			tile[6] = 0
			tile[7] = 0
		else
			tile[7] = data[1]
		end
				
		save_update(_context, save_state)
		return "1"
	end
	return "0"
end

local function buy_ware(_context, _payload)
	local object = nk.storage_read({{collection = "player_data", key = "save_state", user_id = _context.user_id}})
	local save_state = nk.json_decode(object[1].value["SaveState"])
	
	object = nk.storage_read({{collection = "Welt_1", key = "Ware_Data"}})
	local ware_data = nk.json_decode(object[1].value["Ware_Data"])
	
	local data = nk.json_decode(_payload)
	local ware_id = data[1]
	local amount = data[2]
	
	if save_state[1] >= (ware_data[ware_id + 1][6] * amount) and gf.check_if_fit(save_state, ware_data, data) then
		gf.add_to_storage(save_state, data)
		save_state[1] = save_state[1] - (ware_data[ware_id + 1][7] * amount)
		save_update(_context, save_state)
		return "1"
	else
		return "0"
	end
end

local function sell_ware(_context, _payload)
	local object = nk.storage_read({{collection = "player_data", key = "save_state", user_id = _context.user_id}})
	local save_state = nk.json_decode(object[1].value["SaveState"])
	
	object = nk.storage_read({{collection = "Welt_1", key = "Ware_Data"}})
	local ware_data = nk.json_decode(object[1].value["Ware_Data"])
	
	local data = nk.json_decode(_payload)
	
	if gf.check_if_on_stock(save_state, {data}) then
		gf.remove_from_storage(save_state, {data})
		save_state[1] = save_state[1] + (ware_data[data[1] + 1][7] * data[2] * 0.7)
		
		save_update(_context, save_state)
		return "1"
	else
		return "0"
	end
end

nk.register_rpc(get_world_id, "get_world_id")
nk.register_rpc(get_world_data, "get_world_data")
nk.register_rpc(get_save_state, "get_save_state")

nk.register_rpc(extend_shop, "extend_shop")
nk.register_rpc(construct_wall, "construct_wall")
nk.register_rpc(construct_room, "construct_room")
nk.register_rpc(construct_funiture, "construct_funiture")
nk.register_rpc(destory_object, "destory_object")
nk.register_rpc(hire_worker, "hire_worker")
nk.register_rpc(fire_worker, "fire_worker")
nk.register_rpc(start_production, "start_production")
nk.register_rpc(offer_for_sale, "offer_for_sale")
nk.register_rpc(update_action, "update_action")
nk.register_rpc(buy_ware, "buy_ware")
nk.register_rpc(sell_ware, "sell_ware")