local board = { cells = { "X", "O", "" } }

function board:save()
	local snapshot = { cells = {} }
	for index, cell in ipairs(self.cells) do
		snapshot.cells[index] = cell
	end
	return snapshot
end

function board:restore(snapshot)
	self.cells = {}
	for index, cell in ipairs(snapshot.cells) do
		self.cells[index] = cell
	end
end

local snapshot = board:save()
board.cells[3] = "X"
board:restore(snapshot)
assert(table.concat(board.cells, ",") == "X,O,")
print(table.concat(board.cells, ","))
