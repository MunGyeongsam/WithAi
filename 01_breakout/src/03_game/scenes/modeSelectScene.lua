local LevelSelectScene = require("03_game.scenes.levelSelectScene")

local ModeSelectScene = {}
ModeSelectScene.__index = ModeSelectScene

local ENTRIES = {
    {id = "classic", label = "Classic", desc = "Stable pacing and readable routes"},
    {id = "combo_rush", label = "Combo Rush", desc = "Faster tempo with risk reward"},
}

local function entryY(height, index)
    return height * (0.32 + (index - 1) * 0.18)
end

local function inBackButton(x, y, width, height)
    return x >= width * 0.04 and x <= width * 0.24 and y >= height * 0.05 and y <= height * 0.11
end

function ModeSelectScene.new(width, height, options)
    local self = setmetatable({}, ModeSelectScene)
    self.width = width
    self.height = height
    self.options = options or {}
    self.selected = self.options.selectedIndex or 1
    self.nextSceneFactory = self.options.nextSceneFactory or function(w, h, modeId)
        return LevelSelectScene.new(w, h, {modeId = modeId})
    end
    self.previousSceneFactory = self.options.previousSceneFactory or function(w, h)
        return require("03_game.scenes.titleScene").new(w, h)
    end
    return self
end

function ModeSelectScene:resize(width, height)
    self.width = width
    self.height = height
end

function ModeSelectScene:startSelected(modeId)
    if not self._stack then
        return
    end
    self._stack:replace(self.nextSceneFactory(self.width, self.height, modeId))
end

function ModeSelectScene:keypressed(key)
    if key == "backspace" then
        if self._stack then
            self._stack:replace(self.previousSceneFactory(self.width, self.height))
        end
        return
    end

    if key == "1" then
        self:startSelected("classic")
        return
    end

    if key == "2" then
        self:startSelected("combo_rush")
        return
    end

    if key == "up" or key == "w" then
        self.selected = self.selected - 1
        if self.selected < 1 then
            self.selected = #ENTRIES
        end
        return
    end

    if key == "down" or key == "s" then
        self.selected = self.selected + 1
        if self.selected > #ENTRIES then
            self.selected = 1
        end
        return
    end

    if key == "return" or key == "space" then
        self:startSelected(ENTRIES[self.selected].id)
    end
end

function ModeSelectScene:touchpressed(_, x, y)
    if inBackButton(x, y, self.width, self.height) then
        if self._stack then
            self._stack:replace(self.previousSceneFactory(self.width, self.height))
        end
        return
    end

    for i = 1, #ENTRIES do
        local y0 = entryY(self.height, i)
        local y1 = y0 + 56
        if y >= y0 and y <= y1 then
            if self.selected == i then
                self:startSelected(ENTRIES[i].id)
            else
                self.selected = i
            end
            return
        end
    end
end

function ModeSelectScene:mousepressed(x, y, button)
    if button == 1 then
        self:touchpressed(nil, x, y)
    end
end

function ModeSelectScene:draw()
    local gr = love.graphics
    gr.setColor(0.07, 0.09, 0.14, 1)
    gr.rectangle("fill", 0, 0, self.width, self.height)

    gr.setColor(0.88, 0.93, 0.98, 1)
    gr.printf("SELECT MODE", 0, self.height * 0.16, self.width, "center")

    gr.setColor(0.75, 0.82, 0.90, 0.92)
    gr.rectangle("line", self.width * 0.04, self.height * 0.05, self.width * 0.20, self.height * 0.06, 8, 8)
    gr.printf("BACK", self.width * 0.04, self.height * 0.068, self.width * 0.20, "center")

    for i = 1, #ENTRIES do
        local entry = ENTRIES[i]
        local y = entryY(self.height, i)
        local active = (self.selected == i)

        if active then
            gr.setColor(0.95, 0.9, 0.72, 1)
        else
            gr.setColor(0.72, 0.78, 0.86, 1)
        end
        gr.printf(tostring(i) .. ". " .. entry.label, 0, y, self.width, "center")

        gr.setColor(0.62, 0.68, 0.78, 1)
        gr.printf(entry.desc, 0, y + 26, self.width, "center")
    end

    gr.setColor(0.9, 0.9, 0.9, 1)
    gr.printf("UP/DOWN + ENTER or press 1/2", 0, self.height * 0.82, self.width, "center")

    gr.setColor(0.64, 0.70, 0.78, 1)
    gr.printf("BACKSPACE: Back  ESC: Quit", 0, self.height * 0.87, self.width, "center")

    gr.setColor(0.64, 0.74, 0.86, 1)
    gr.printf("Mobile: tap card to select, tap again to start", 0, self.height * 0.91, self.width, "center")
end

return ModeSelectScene