local Inventory = { listeners = {}, items = {} }

function Inventory.subscribe(observer)
    Inventory.listeners[#Inventory.listeners + 1] = observer
end

function Inventory.add(item)
    Inventory.items[#Inventory.items + 1] = item
    for _, observer in ipairs(Inventory.listeners) do observer:update(Inventory) end
end

local ui = { item_count = 0, last_item = "" }
function ui:update(subject)
    self.item_count = #subject.items
    self.last_item = subject.items[self.item_count]
end

Inventory.subscribe(ui)
Inventory.add("열쇠")
assert(ui.item_count == 1 and ui.last_item == "열쇠")
print(ui.item_count, ui.last_item)
