local nk = require("nakama")
local core = require("Core_Function")

local GF = {}

-- Raumbau hilfsfunktionen
function GF.check_surrounding(tile, room, tile_data, room_id)
	local allowed = true
	
	if tile_data[tile[2] - 1][tile[1] - 1][1] ~= 2 and tile_data[tile[2] - 1][tile[1] - 1][2] ~= room_id then allowed = false end
	if tile_data[tile[2]][tile[1] - 1][1] ~= 2 and tile_data[tile[2]][tile[1] - 1][2] ~= room_id then allowed = false end
	if tile_data[tile[2] + 1][tile[1] - 1][1] ~= 2 and tile_data[tile[2] + 1][tile[1] - 1][2] ~= room_id then allowed = false end
	if tile_data[tile[2] - 1][tile[1]][1] ~= 2 and tile_data[tile[2] - 1][tile[1]][2] ~= room_id then allowed = false end
	if tile_data[tile[2] + 1][tile[1]][1] ~= 2 and tile_data[tile[2] + 1][tile[1]][2] ~= room_id then allowed = false end
	if tile_data[tile[2] - 1][tile[1] + 1][1] ~= 2 and tile_data[tile[2] - 1][tile[1] + 1][2] ~= room_id then allowed = false end
	if tile_data[tile[2]][tile[1] + 1][1] ~= 2 and tile_data[tile[2]][tile[1] + 1][2] ~= room_id then allowed = false end
	if tile_data[tile[2] + 1][tile[1] + 1][1] ~= 2 and tile_data[tile[2] + 1][tile[1] + 1][2] ~= room_id then allowed = false end
	
	return allowed
end

function GF.add_to_path(tile, room_array, path_array)
	local is_member = core.table_contains(path_array, tile)
	local room_has =  core.table_contains(room_array[1], tile)
	if not is_member and not room_has then
		table.insert(path_array, tile)
		return true
	else
		return false
	end	
end

function GF.check_room_wall(tile_data, room_array)
	local tiles = room_array[1]
	local wall_compleat = true
	for i, tile in ipairs(tiles) do
		if wall_compleat then
			wall_compleat = GF.check_surrounding(tile, tiles, tile_data, room_array[4])
		end
	end
	if not wall_compleat then
		room_array[2] = false
		room_array[3] = false
	end
	return room_array
end

function GF.check_possible_room(tile_data, actual_tile, room_array, path_array, path)
	
	if tile_data[actual_tile[2]][actual_tile[1]][1] == 1 then
		if not path and tile_data[actual_tile[2]][actual_tile[1]][2] == 0 then
			tile_data[actual_tile[2]][actual_tile[1]][2] = room_array[4]
			table.insert(room_array[1], actual_tile)
			GF.check_possible_room(tile_data, {actual_tile[1], actual_tile[2] - 1}, room_array, path_array, path)
			GF.check_possible_room(tile_data, {actual_tile[1], actual_tile[2] + 1}, room_array, path_array, path)
			GF.check_possible_room(tile_data, {actual_tile[1] - 1, actual_tile[2]}, room_array, path_array, path)
			GF.check_possible_room(tile_data, {actual_tile[1] + 1, actual_tile[2]}, room_array, path_array, path)
		end
		if path and GF.add_to_path(actual_tile, room_array, path_array) then
			GF.check_possible_room(tile_data, {actual_tile[1], actual_tile[2] - 1}, room_array, path_array, path)
			GF.check_possible_room(tile_data, {actual_tile[1], actual_tile[2] + 1}, room_array, path_array, path)
			GF.check_possible_room(tile_data, {actual_tile[1] - 1, actual_tile[2]}, room_array, path_array, path)
			GF.check_possible_room(tile_data, {actual_tile[1] + 1, actual_tile[2]}, room_array, path_array, path)
		end
	elseif tile_data[actual_tile[2]][actual_tile[1]][1] == 2 and tile_data[actual_tile[2]][actual_tile[1]][3] == 2 and GF.add_to_path(actual_tile, room_array, path_array) then
		local exit = false
		if actual_tile[2] > 1 then
			GF.check_possible_room(tile_data, {actual_tile[1], actual_tile[2] - 1}, room_array, path_array, true)
		else
			exit = true
		end
		if actual_tile[2] < 22 then
			GF.check_possible_room(tile_data, {actual_tile[1], actual_tile[2] + 1}, room_array, path_array, true)
		else
			exit = true
		end
		if actual_tile[1] > 1 then
			GF.check_possible_room(tile_data, {actual_tile[1] - 1, actual_tile[2]}, room_array, path_array, true)
		else
			exit = true
		end
		if actual_tile[1] < 22 then
			GF.check_possible_room(tile_data, {actual_tile[1] + 1, actual_tile[2]}, room_array, path_array, true)
		else
			exit = true
		end
		if exit and not path then
			room_array[2] = true
			room_array[3] = true
		elseif exit and path then
			room_array[2] = true
		end
		
	elseif tile_data[actual_tile[2]][actual_tile[1]][1] == 3 and GF.add_to_path(actual_tile, room_array, path_array) then
		GF.check_possible_room(tile_data, {actual_tile[1], actual_tile[2] - 1}, room_array, path_array, path)
		GF.check_possible_room(tile_data, {actual_tile[1], actual_tile[2] + 1}, room_array, path_array, path)
		GF.check_possible_room(tile_data, {actual_tile[1] - 1, actual_tile[2]}, room_array, path_array, path)
		GF.check_possible_room(tile_data, {actual_tile[1] + 1, actual_tile[2]}, room_array, path_array, path)
	end
	return room_array
end

function GF.check_possible_shop(tile_data, actual_tile, room_array, path_array, path)
	if tile_data[actual_tile[2]][actual_tile[1]][1] == 1 then
		if not path and tile_data[actual_tile[2]][actual_tile[1]][2] == 0 then
			tile_data[actual_tile[2]][actual_tile[1]][2] = room_array[4]
			table.insert(room_array[1], actual_tile)
			GF.check_possible_room(tile_data, {actual_tile[1], actual_tile[2] - 1}, room_array, path_array, path)
			GF.check_possible_room(tile_data, {actual_tile[1], actual_tile[2] + 1}, room_array, path_array, path)
			GF.check_possible_room(tile_data, {actual_tile[1] - 1, actual_tile[2]}, room_array, path_array, path)
			GF.check_possible_room(tile_data, {actual_tile[1] + 1, actual_tile[2]}, room_array, path_array, path)
		end
	elseif tile_data[actual_tile[2]][actual_tile[1]][1] == 2 and tile_data[actual_tile[2]][actual_tile[1]][3] == 2 and GF.add_to_path(actual_tile, room_array, path_array) then
		local exit = false
		if actual_tile[2] > 1 then
			exit = true
		end
		if actual_tile[2] < 22 then
			exit = true
		end
		if actual_tile[1] > 1 then
			exit = true
		end
		if actual_tile[1] < 22 then
			exit = true
		end
	
		if exit and not path then
			room_array[3] = true
		end
	end
	return room_array
end

-- Mauer/Türbau hilfsfunktionen

function GF.get_start_coordinates(room, tile_data)
	local start_coordinates
	for i = 1, 22 do
		for l = 1, 22 do
			if tile_data[i][l][1] ~= 0 and tile_data[i][l][2] == room[1] then
				start_coordinates = {l, i}
				return start_coordinates
			end
		end
	end
end

function GF.check_room_path(tile_data, actual_tile, room_array, path_array, path)
	if tile_data[actual_tile[2]][actual_tile[1]][1] == 1 then
		if not path and GF.add_to_path(actual_tile, room_array, path_array) then
			GF.check_room_path(tile_data, {actual_tile[1], actual_tile[2] - 1}, room_array, path_array, path)
			GF.check_room_path(tile_data, {actual_tile[1], actual_tile[2] + 1}, room_array, path_array, path)
			GF.check_room_path(tile_data, {actual_tile[1] - 1, actual_tile[2]}, room_array, path_array, path)
			GF.check_room_path(tile_data, {actual_tile[1] + 1, actual_tile[2]}, room_array, path_array, path)
		end	
		if path and GF.add_to_path(actual_tile, room_array, path_array) then
			GF.check_room_path(tile_data, {actual_tile[1], actual_tile[2] - 1}, room_array, path_array, path)
			GF.check_room_path(tile_data, {actual_tile[1], actual_tile[2] + 1}, room_array, path_array, path)
			GF.check_room_path(tile_data, {actual_tile[1] - 1, actual_tile[2]}, room_array, path_array, path)
			GF.check_room_path(tile_data, {actual_tile[1] + 1, actual_tile[2]}, room_array, path_array, path)
		end
	elseif tile_data[actual_tile[2]][actual_tile[1]][1] == 2 and actual_tile ~= room_array[3] and tile_data[actual_tile[2]][actual_tile[1]][3] == 2 and GF.add_to_path(actual_tile, room_array, path_array) then
		local exit = false
		if actual_tile[2] > 1 then
			GF.check_room_path(tile_data, {actual_tile[1], actual_tile[2] - 1}, room_array, path_array, true)
		else
			exit = true
		end
		if actual_tile[2] < 22 then
			GF.check_room_path(tile_data, {actual_tile[1], actual_tile[2] + 1}, room_array, path_array, true)
		else
			exit = true
		end
		if actual_tile[1] > 1 then
			GF.check_room_path(tile_data, {actual_tile[1] - 1, actual_tile[2]}, room_array, path_array, true)
		else
			exit = true
		end
		if actual_tile[1] < 22 then
			GF.check_room_path(tile_data, {actual_tile[1] + 1, actual_tile[2]}, room_array, path_array, true)
		else
			exit = true
		end
		
		if exit and not path then
			room_array[1] = true
			room_array[2] = true
		elseif exit and path then
			room_array[1] = true
		end
		
	elseif tile_data[actual_tile[2]][actual_tile[1]][1] == 3 and GF.add_to_path(actual_tile, room_array, path_array) then
		GF.check_room_path(tile_data, {actual_tile[1], actual_tile[2] - 1}, room_array, path_array, path)
		GF.check_room_path(tile_data, {actual_tile[1], actual_tile[2] + 1}, room_array, path_array, path)
		GF.check_room_path(tile_data, {actual_tile[1] - 1, actual_tile[2]}, room_array, path_array, path)
		GF.check_room_path(tile_data, {actual_tile[1] + 1, actual_tile[2]}, room_array, path_array, path)
	end
	
	return room_array
end

function GF.check_shop_path(tile_data, actual_tile, room_array, path_array, path)
	if tile_data[actual_tile[2]][actual_tile[1]][1] == 1 then
		if not path and GF.add_to_path(actual_tile, room_array, path_array) then
			GF.check_shop_path(tile_data, {actual_tile[1], actual_tile[2] - 1}, room_array, path_array, path)
			GF.check_shop_path(tile_data, {actual_tile[1], actual_tile[2] + 1}, room_array, path_array, path)
			GF.check_shop_path(tile_data, {actual_tile[1] - 1, actual_tile[2]}, room_array, path_array, path)
			GF.check_shop_path(tile_data, {actual_tile[1] + 1, actual_tile[2]}, room_array, path_array, path)
		end	
	elseif tile_data[actual_tile[2]][actual_tile[1]][1] == 2 and actual_tile ~= room_array[3] and tile_data[actual_tile[1]][actual_tile[1]][3] == 2 and GF.add_to_path(actual_tile, room_array, path_array) then
		local exit = false
		if actual_tile[2] > 1 then
			exit = true
		end
		if actual_tile[2] < 22 then
			exit = true
		end
		if actual_tile[1] > 1 then
			exit = true
		end
		if actual_tile[1] < 22 then
			exit = true
		end		
		if exit and not path then
			room_array[2] = true
		end	
	end
	return room_array
end

function GF.check_door_needet(save_data, data)
	local tile_data = save_data[5]
	local tile_coordinates = {data[1],data[2]}
	local start_coordinates
	local still_has_path = true
	for i, room in ipairs(save_data[4]) do
		if type(room) == "table" then
			start_coordinates = GF.get_start_coordinates(room, save_data[5])
			local result 
			if room[1] == 3 then
				result = GF.check_shop_path(tile_data, start_coordinates, {false, false, tile_coordinates}, {}, false)
			else
				result = GF.check_room_path(tile_data, start_coordinates, {false, false, tile_coordinates}, {}, false)
			end
			if still_has_path then
				still_has_path = (result[1] and room[2] < 3) or (result[2] and room[2] == 3)
			end
		end
	end
	return still_has_path
end

-- Kauf/Verkauf Hilfsfunktionen
function GF.check_if_fit(save_state, ware_data, data)
	local ware_category = ware_data[data[1] + 1][2]
	local space = {0,0,0,0,0,0,0}
	local space_occupied = {0,0,0,0,0,0}
	
	for i, row in ipairs(save_state[5]) do
		for l, tile in ipairs(row) do
			if tile[1] == 3 then
				if tile[3] == 0 then
					space[1] = space[1] + 10
				elseif tile[3] == 1 then
					space[2] = space[2] + 20
				end
			end
		end
	end
	
	for i, ware in ipairs(save_state[6]) do
		space_occupied[ware_data[ware[1] + 1][2] + 1] = space_occupied[ware_data[ware[1] + 1][2] + 1] + ware[2]
	end

	for i = 1, table.getn(space_occupied) do
		if space[i + 1] < space_occupied[i] then
			space_occupied[i] = space_occupied[i] - space[i + 1]
			space[i + 1] = 0
		else
			space[i + 1] = space[i + 1] - space_occupied[i]
			space_occupied[i] = 0
		end
	end
	for i, spot in ipairs(space_occupied) do
		space[1] = space[1] - spot
	end
	local space_left = space[1] + space[ware_category + 2] 
	return space_left >= data[2]
end

function GF.add_to_storage(save_state, data)
	local new_ware = true
	for i, ware in ipairs(save_state[6]) do
		if ware[1] == data[1] then
			ware[2] = ware[2] + data[2]
			new_ware = false
		end
	end
	if new_ware then
		table.insert(save_state[6], data)
	end
end

function GF.check_if_on_stock(save_state, data)
	local ware_on_stock = false
	for i, ware in ipairs(data) do
		ware_on_stock = false
		for l, stock_ware in ipairs(save_state[6]) do
			if (stock_ware[1] == ware[1]) then
				if stock_ware[2] >= ware[2] then
					ware_on_stock = true
				end
			end
		end
		if not ware_on_stock then
			return false
		end
	end
	return true
end

function GF.remove_from_storage(save_state, data)
	for i, ware in ipairs(data) do
		for l, stock_ware in ipairs(save_state[6]) do
			if (stock_ware[1] == ware[1]) then
				stock_ware[2] = stock_ware[2] - ware[2]
				if stock_ware[2] == 0 then
					table.remove(save_state[6], l)
				end
			end
		end
	end
end

-- Abriss Hilfsfunktionen
function GF.get_tile_state(tile)
	--0 frei 1 mauer 2 raum 
	local state 
	if tile[1] == 1 and tile[2] == 0 then
		state = 0
	elseif tile[1] == 2 then
		state = 1
	elseif tile[1] == 1 and tile[2] ~= 0 then
		state = 2
	end
	return state
end

function GF.fuse_rooms(tile_state, actual_tile, room)
	if tile_state[actual_tile[2]][actual_tile[1]][1] == 1 then
		if tile_state[actual_tile[2]][actual_tile[1]][2] ~= room then
			tile_state[actual_tile[2]][actual_tile[1]][2] = room
			GF.fuse_rooms(tile_state, {actual_tile[1], actual_tile[2] - 1}, room)
			GF.fuse_rooms(tile_state, {actual_tile[1], actual_tile[2] + 1}, room)
			GF.fuse_rooms(tile_state, {actual_tile[1] - 1, actual_tile[2]}, room)
			GF.fuse_rooms(tile_state, {actual_tile[1] + 1, actual_tile[2]}, room)
		end
	end
end

function GF.check_if_storage_removable(data, save_state)
	local object = nk.storage_read({{collection = "Welt_1", key = "Ware_Data"}})
	local ware_data = nk.json_decode(object[1].value["Ware_Data"])
	
	local array_copy = core.copy_table(save_state)

	array_copy[5][data[2]][data[1]][1] = 1
	array_copy[5][data[2]][data[1]][3] = 0
	
	return GF.check_if_fit(array_copy, ware_data, {0,0})
end

function GF.check_if_room_deletable(save_state, room_id)
	local room_for_removal
	local room_deletable = true 
	
	for i, room in ipairs(save_state[4]) do
		if type(room) == "table" and room[1] == room_id then
			room_for_removal = room
		end
	end
	
	if room_for_removal ~= null then
		for i = 1, 22 do
			for l = 1, 22 do
				if save_state[5][i][l][1] == 1 and save_state[5][i][l][2] == room_for_removal[1] and save_state[5][i][l][3] ~= 0 then
					room_deletable = false
				end
			end
		end
	end
	return room_deletable
end

function GF.delete_room(save_state, room_id)
	local room_for_removal
	local room_position
	for i, room in ipairs(save_state[4]) do
		if type(room) == "table" and room[1] == room_id then
			room_for_removal = room
			room_position = i
		end
	end
	for i = 1, 22 do
		for l = 1, 22 do
			if save_state[5][i][l][1] == 1 and save_state[5][i][l][2] == room_for_removal[1] then
				save_state[5][i][l][2] = 0
			end
		end
	end
	table.remove(save_state[4], room_position)
end

return GF