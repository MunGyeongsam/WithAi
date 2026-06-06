-- ============================================================================
-- conf.lua — LÖVE 윈도우 설정 (세로 모바일, 9:20 비율)
-- ============================================================================
--
-- ◆ 역할
--   love.conf(t)를 정의하여 윈도우 크기, MSAA, V-sync 등을 설정한다.
--   resolutionList에서 인덱스로 해상도를 선택한다.
--   현재 기본값: index 5 = 432 × 960 (세로 모드)

local resolutionList = {
    -- Portrait mode (9:20 ratio) - 세로 모드
    {width = 216, height = 480},   -- Very small portrait
    {width = 270, height = 600},   -- Small portrait
    {width = 324, height = 720},   -- Medium portrait
    {width = 378, height = 840},   -- Large portrait
    {width = 432, height = 960},   -- Very large portrait
    {width = 540, height = 1200},  -- Extra large portrait
}

local resolutionIndex = 5
local resolution = resolutionList[resolutionIndex]

function love.conf(t)
    t.title = "Tower Defense - Love2D"
    t.author = "WithAi"
    t.version = "11.5"

    -- Window settings (portrait mobile)
    t.window.width = resolution.width
    t.window.height = resolution.height
    t.window.minwidth = resolution.width / 2
    t.window.minheight = resolution.height / 2
    t.window.resizable = true
    t.window.centered = true
    t.window.vsync = 0
    t.window.msaa = 8
    t.window.fullscreen = false

    -- Module settings
    t.modules.audio = true
    t.modules.data = true
    t.modules.event = true
    t.modules.font = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.joystick = false
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.physics = false
    t.modules.sound = true
    t.modules.system = true
    t.modules.thread = true
    t.modules.timer = true
    t.modules.touch = true
    t.modules.video = false
    t.modules.window = true
end
