local Core_Functions = {}

-- Erstellt eine Deepcopy eines tables (inclusive metatable)
function Core_Functions.copy_table(orig)
	local orig_type = type(orig)
	local array_copy
	if orig_type == 'table' then
		array_copy = {}
		for orig_key, orig_value in next, orig, nil do
			array_copy[Core_Functions.copy_table(orig_key)] = Core_Functions.copy_table(orig_value)
		end
		setmetatable(array_copy, Core_Functions.copy_table(getmetatable(orig)))
	else -- number, string, boolean, etc
		array_copy = orig
	end
	return array_copy
end

--Vergleicht zwei Table
function Core_Functions.compair_array(array_1, array_2)
	if type(array_1) == "table" and type(array_2) == "table" then	
		if table.getn(array_1) and table.getn(array_2) then
			local array_equal = true
			for i = 1, table.getn(array_1) do
				if type(array_1[i]) == "table" and type(array_2[i]) == "table" then
					array_equal = compair_array(array_1[i], array_2[i])
				elseif type(array_1[i]) ~= type(array_2[i]) then
					array_equal = false
				elseif type(array_1[i]) == type(array_2[i]) and array_1[i] ~= array_2[i] then
					array_equal = false
				end
			end
			return array_equal
		else
			return false
		end	
	else
		return false
	end
end

--Durchsucht ob ein Table ein Object beinhaltet aber nur auf oberster ebene und nicht ob ein table in dem table das Object beinhaltet
function Core_Functions.table_contains(table, search_value)
	local contains = false
	
	for i,value in ipairs(table) do 
		if type(value) == "table" and type(search_value) == "table" and Core_Functions.compair_array(value, search_value) then
			contains = true 
		elseif type(value) == type(search_value) and value == search_value then
			contains = true
		end
	end
	return contains
end

return Core_Functions