local csv_reader = { read = function() return { "sword", "12" } end }
local item_reader = {
	load = function()
		local row = csv_reader.read()
		return { name = row[1], damage = tonumber(row[2]) }
	end
}
local item = item_reader.load()
assert(item.name == "sword" and item.damage == 12)
print(item.name, item.damage)
