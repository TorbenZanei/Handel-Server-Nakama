local nk = require("nakama")
local core = require("Core_Function")
local gf = require("Game_Functions")

--[[
Speicherstand Legene:
Position 1 = Aktuelles Geld
Position 2 = Anzahl Arbeiter
Position 3 = Aktuelle bauchfläche ein Array ist eine Reihe, eine Positon ist ein block 5*5 Felder
		   0 = unbenutzbare Baufläche, 1 = Baufläche die freigeschalten werden kann, 2 = Baufläche die bereits freigeschalten ist
Position 4 = Array der Aktuellen Räume [Id des Raums, Id der Raumart]
Position 5 = Status der Spielfelder
		   Wenn Spielfeld nicht freigespielt = [0]
		   Wenn Spielfeld frei = [Status,Room ID,Funiture ID,action ID,time left,outcome id,extra data]
Position 6 Waren auf Lager
Position 7 Beschäftigte Arbeiter 
--]]

local NEW_SAVE_STATE = '[500000,0,[[2,1,0,0],[1,0,0,0],[0,0,0,0],[0,0,0,0]],[1],[' ..
						 '[[2,0,1,0,0,0,3,0],[2,0,1,0,0,0,3,0],[2,0,1,0,0,0,3,0],[2,0,1,0,0,0,3,0],[2,0,1,0,0,0,3,0],[2,0,1,0,0,0,3,0],[2,0,1,0,0,0,3,0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0]]' ..
						',[[2,0,1,0,0,0,3,0],[1,0,0,0,0,0,0,0],[1,0,0,0,0,0,0,0],[1,0,0,0,0,0,0,0],[1,0,0,0,0,0,0,0],[1,0,0,0,0,0,0,0],[2,0,1,0,0,0,2,0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0]]' ..
						',[[2,0,1,0,0,0,3,0],[1,0,0,0,0,0,0,0],[1,0,0,0,0,0,0,0],[1,0,0,0,0,0,0,0],[1,0,0,0,0,0,0,0],[1,0,0,0,0,0,0,0],[2,0,1,0,0,0,2,0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0]]' ..
						',[[2,0,1,0,0,0,3,0],[1,0,0,0,0,0,0,0],[1,0,0,0,0,0,0,0],[1,0,0,0,0,0,0,0],[1,0,0,0,0,0,0,0],[1,0,0,0,0,0,0,0],[2,0,1,0,0,0,2,0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0]]' ..
						',[[2,0,1,0,0,0,3,0],[1,0,0,0,0,0,0,0],[1,0,0,0,0,0,0,0],[1,0,0,0,0,0,0,0],[1,0,0,0,0,0,0,0],[1,0,0,0,0,0,0,0],[2,0,1,0,0,0,2,0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0]]' ..
						',[[2,0,1,0,0,0,3,0],[1,0,0,0,0,0,0,0],[1,0,0,0,0,0,0,0],[1,0,0,0,0,0,0,0],[1,0,0,0,0,0,0,0],[1,0,0,0,0,0,0,0],[2,0,1,0,0,0,2,0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0]]' ..
						',[[2,0,1,0,0,0,3,0],[2,0,1,0,0,0,2,0],[2,0,1,0,0,0,2,0],[2,0,1,0,0,0,2,0],[2,0,1,0,0,0,2,0],[2,0,1,0,0,0,2,0],[2,0,1,0,0,0,2,0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0]]' ..
						',[[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0]]' ..
						',[[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0]]' ..
						',[[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0]]' ..
						',[[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0]]' ..
						',[[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0]]' ..
						',[[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0]]' ..
						',[[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0]]' ..
						',[[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0]]' ..
						',[[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0]]' ..
						',[[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0]]' ..
						',[[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0]]' ..
						',[[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0]]' ..
						',[[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0]]' ..
						',[[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0]]' ..
						',[[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0]]' ..
						'],[],0]'

local OpCodes = {
	get_ware_data = 1,
	get_save_state = 2
}

local World_Control = {}

function World_Control.match_init(_context, _params)
	local state = {
	
		presences = {},
		member = {},
		member_count = 1,
		ware_data = {
			{0, 0, 'Kupfer','Ein Kupferbarren',{},0,20},
			{1, 0, 'Eisen','Ein Eisenbarren',{},0,30},
			{2, 1, 'Kettenglieder','Ringglieder für Kettenrüstungen',{{1,2}},5,70},
			{3, 2, 'Eisenhelm','Ein einfacher Eisenhelm',{{0,1},{1,3}},10,100},
			{4, 2, 'Kettenhemd','Ein Einfaches Kettenhemd',{{2,3}},15,150}
		}
	}
	
	nk.storage_write({{collection = "Welt_1", key = "Ware_Data", value = {["Ware_Data"] = nk.json_encode(state.ware_data)}, permission_read = 2, permission_write = 0}})
	
	local tick_rate = 1
	local label = "Welt_1"
	
	return state, tick_rate, label
end

function World_Control.match_join_attempt(context, dispatcher, tick, state, presence, metadata)
	if state.presences[presence.user_id] ~= nil then
		return state, false, "Bereits eingeloggt"
	end
	return state, true
end

function World_Control.match_join(context, dispatcher, tick, state, presence)
	for _, new_presence in ipairs(presence) do
		state.presences[new_presence.user_id] = new_presence
		if not core.table_contains(state.member, new_presence.user_id) then
			state.member[state.member_count] = new_presence.user_id
			state.member_count = state.member_count + 1
		end
		
		local save_state = {{collection = "player_data", key = "save_state", user_id = new_presence.user_id}}
		local object = nk.storage_read(save_state)
		
		if object[1] == nil then
			local new_save_state = {{collection = "player_data", key = "save_state", user_id = new_presence.user_id, value = {["SaveState"] = NEW_SAVE_STATE}}}
			nk.storage_write(new_save_state)
--		else 
--			local new_save_state = {{collection = "player_data", key = "save_state", user_id = new_presence.user_id, value = {["SaveState"] = NEW_SAVE_STATE}}}
--			nk.storage_write(new_save_state)
		end
	end
	return state
end

function World_Control.match_leave(context, dispatcher, tick, state, presences)
	for _, presence in ipairs(presences) do
		state.presences[presence.user_id] = nil
	end
	return state
end

function World_Control.match_terminate(context, dispatcher, tick, state, grace_seconds)
	
	return state
end

function World_Control.match_loop(context, dispatcher, tick, state, messages)
	
	for i, presence in ipairs(state.member) do
		local object = nk.storage_read({{collection = "player_data", key = "save_state", user_id = presence}})
		local save_state = nk.json_decode(object[1].value["SaveState"])
	
		for l, row in ipairs(save_state[5]) do
			for m, tile in ipairs(row) do
			--	nk.logger_info(nk.json_encode(tile))
				if tile[1] ~= 0 and tile[4] ~= 0 then	 
					if tile[5] <= 0 then
						nk.logger_info("aktion")
						if tile[4] == 1 then
							tile[3] = tile[6]
							tile[4] = 0
							tile[6] = 0
						elseif tile[4] == 3 then
							if tile[8] == 0 then
								if gf.check_if_fit(save_state, state.ware_data, {tile[6], 1}) then
									gf.add_to_storage(save_state, {tile[6], 1})
									tile[7] = tile[7] - 1
									if tile[7] == 0 then
										save_state[7] = save_state[7] - 1
										tile[4] = 0
										tile[6] = 0
									else
										if gf.check_if_on_stock(save_state, state.ware_data[tile[6] + 1][5]) then
											gf.remove_from_storage(save_state, state.ware_data[tile[6] + 1][5])
											tile[5] = state.ware_data[tile[6] + 1][6]
										else
											tile[8] = 2
										end
									end
								else
									tile[8] = 1
								end
							elseif tile[8] == 1 then
								if gf.check_if_fit(save_state, state.ware_data, {tile[6], 1}) then
									gf.add_to_storage(save_state, {tile[6], 1})
									tile[7] = tile[7] - 1
									tile[8] = 0
									if tile[7] == 0 then
										save_state[7] = save_state[7] - 1
										tile[4] = 0
										tile[6] = 0
									else
										if gf.check_if_on_stock(save_state, state.ware_data[tile[6] + 1][5]) then
											gf.remove_from_storage(save_state, state.ware_data[tile[6] + 1][5])
											tile[5] = state.ware_data[tile[6] + 1][6]
										else
											tile[8] = 2
										end
									end
								else
								end
							elseif tile[8] == 2 then
								if gf.check_if_on_stock(save_state, state.ware_data[tile[6] + 1][5]) then
									gf.remove_from_storage(save_state, state.ware_data[tile[6] + 1][5])
									tile[5] = state.ware_data[tile[6] + 1][6]
									tile[8] = 0
								else
								end
							end
						elseif tile[4] == 4 then
							nk.logger_info("sell_action")
							if math.random(0,100) >= 70 then
								nk.logger_info("succesfull_sell_action")
								if tile[8] == 0 then
									nk.logger_info("normal")
									local player = state.presences[presence]
									tile[7] = tile[7] - 1
									
									if gf.check_if_on_stock(save_state, {{tile[6] + 1, 1}}) then
										gf.remove_from_storage(save_state, {{tile[6] + 1, 1}})
										save_state[1]= save_state[1] - (state.ware_data[tile[6] + 1][7] * 2)
										if tile[7] == 0 then
											tile[4] = 0
											tile[6] = 0
										else
											tile[5] = 5
										end
									else
										nk.logger_info("keine ware")
										tile[8] = 2
									end
									
									if player ~= nil then
										dispatcher.broadcast_message(1, nk.json_encode({m - 1, l - 1}), {player}, nil)
									end
								elseif tile[8] == 2 then
									nk.logger_info("kein wahre")
									if gf.check_if_on_stock(save_state, {{tile[6] + 1, 1}}) then
										tile[8] = 0
										gf.remove_from_storage(save_state, {{tile[6] + 1, 1}})
										save_state[1]= save_state[1] - (state.ware_data[tile[6] + 1][7] * 2)
										if tile[7] == 0 then
											tile[4] = 0
											tile[6] = 0
										else
											nk.logger_info("immernoch keine ware")
											tile[5] = 5
										end
									end
								end	
							else
								nk.logger_info("faild_sell_action")
								tile[5] = 5
							end
						end
					else
					--	nk.logger_info(nk.json_encode())
						nk.logger_info("time_tick")
						tile[5] = tile[5] - 1
					end
				end
			end
		end
	--	nk.logger_info(nk.json_encode(save_state))
		local update = nk.json_encode(save_state)
		local new_save_state = {{collection = "player_data", key = "save_state", user_id = presence, value = {["SaveState"] = update}}}
		nk.storage_write(new_save_state)
	end
	
	return state
end



return World_Control