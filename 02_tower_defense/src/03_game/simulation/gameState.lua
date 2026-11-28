local GameState = {}
GameState.__index = GameState

function GameState.new(initial)
    initial = initial or {}

    local self = setmetatable({}, GameState)
    self.revision = initial.revision or 0
    self.tick = initial.tick or 0
    self.nextEntityId = initial.nextEntityId or 1
    self.phase = initial.phase or "build"
    self.map = initial.map
    self.economy = initial.economy
    self.enemies = initial.enemies or {}
    self.towers = initial.towers or {}
    self.wave = initial.wave
    return self
end

return GameState
