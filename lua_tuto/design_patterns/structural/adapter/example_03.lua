local csv_reader = { read = function() return { "sword", "12" } end }

local csv_item_adapter = {
	load = function()
		local row = csv_reader.read()
		local damage = tonumber(row[2])
		if not row[1] or not damage then
			return nil, "invalid item row"
		end
		return { name = row[1], damage = damage }
	end
}

local item, err = csv_item_adapter.load()
assert(not err)
assert(item.name == "sword" and item.damage == 12)
print(item.name, item.damage)
