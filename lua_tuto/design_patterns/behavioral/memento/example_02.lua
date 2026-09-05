local editor = { text = "before" }

function editor:save()
	return { text = self.text }
end

function editor:restore(snapshot)
	self.text = snapshot.text
end

local history = {}
local function checkpoint()
	history[#history + 1] = editor:save()
end

checkpoint()
editor.text = "after"
checkpoint()
editor.text = "latest"
editor:restore(history[#history])
history[#history] = nil
editor:restore(history[#history])
assert(editor.text == "before")
print(editor.text)
