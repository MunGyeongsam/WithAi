-- main.lua  (STARTER)
-- 조립(composition root). 규칙·그리기·키 해석은 하지 않고, M·V·C 를 만들고 연결만 한다.
-- 조작: ←/→ (또는 A/D) 이동, Space 발사, R 재시작(게임오버 시), Esc 종료.

love.filesystem.setRequirePath("?.lua;?/init.lua;models/?.lua;views/?.lua;controllers/?.lua")

local GameModel = require("GameModel")
local GameView = require("GameView")
local InputController = require("InputController")

local WIDTH, HEIGHT = 600, 800
local FIXED_DT = 1 / 60
local MAX_FRAME_DT = 0.25

local game, view, controller
local acc = 0

function love.load()
  love.graphics.setBackgroundColor(0.02, 0.02, 0.06)
  game = GameModel({ width = WIDTH, height = HEIGHT, seed = os.time() })
  view = GameView({ width = WIDTH, height = HEIGHT })
  controller = InputController(game, love.keyboard.isDown)
end

function love.update(dt)
  -- TODO: 한 프레임의 순서 (tests/integration_test.lua 의 app.frame 과 같아야 한다)
  --   0) dt 를 MAX_FRAME_DT 로 자른다
  --   1) C: input = controller:read()            ← 프레임당 1회
  --   2) M: acc 에 dt 를 더하고, FIXED_DT 단위로 game:update(FIXED_DT, input) 반복
  --   3) M→V: game:drainEvents() 의 각 이벤트를 view:onEvent 로   ← 반복문 "밖"에서 1회
  --   4) V: view:update(dt)
end

function love.draw()
  view:draw(love.graphics, game)
end

function love.keypressed(key)
  if controller:keypressed(key) == "quit" then
    love.event.quit()
  end
end
