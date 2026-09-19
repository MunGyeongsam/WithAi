local editor = { text = "before" }

function editor:save()
	return { text = self.text }
end

function editor:restore(snapshot)
	self.text = snapshot.text
end

local history = { snapshots = {} }
function history:push(snapshot)
	self.snapshots[#self.snapshots + 1] = snapshot
end
function history:pop()
	local snapshot = self.snapshots[#self.snapshots]
	self.snapshots[#self.snapshots] = nil
	return snapshot
end

history:push(editor:save())
editor.text = "after"
history:push(editor:save())
editor.text = "latest"
editor:restore(history:pop())
editor:restore(history:pop())
assert(editor.text == "before")
print(editor.text)
