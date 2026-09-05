local GameState = { current = "menu" }

function GameState.change(next_state)
    GameState.current = next_state
end

local menu_state = GameState
local ui_state = GameState
ui_state.change("playing")

assert(menu_state == ui_state and menu_state.current == "playing")
print(menu_state.current, ui_state.current)
