local board = { cells = { { "X", "O" }, { "", "X" } } }

function board:save()
	local snapshot = { cells = {} }
	for row_index, row in ipairs(self.cells) do
		snapshot.cells[row_index] = {}
		for column_index, cell in ipairs(row) do
			snapshot.cells[row_index][column_index] = cell
		end
	end
	return snapshot
end

function board:restore(snapshot)
	self.cells = {}
	for row_index, row in ipairs(snapshot.cells) do
		self.cells[row_index] = {}
		for column_index, cell in ipairs(row) do
			self.cells[row_index][column_index] = cell
		end
	end
end

local snapshot = board:save()
board.cells[1][2] = "X"
board.cells[2][1] = "O"
board:restore(snapshot)
assert(board.cells[1][2] == "O" and board.cells[2][1] == "")
print(table.concat(board.cells[1], ",") .. ";" .. table.concat(board.cells[2], ","))
