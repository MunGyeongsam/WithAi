-- main.lua
-- 조립(composition root). 규칙·그리기·키 해석은 하지 않고, M·V·C 를 만들고 연결만 한다.
-- 이 파일만 love 와 세 계층을 모두 안다.
-- 조작: ←/→ (또는 A/D) 이동, Space 발사, R 재시작(게임오버 시), Esc 종료.

-- 폴더별 모듈을 이름만으로 require 하도록 경로를 등록한다(3주차 Model 을 수정하지 않기 위해).
love.filesystem.setRequirePath("?.lua;?/init.lua;models/?.lua;views/?.lua;controllers/?.lua")

local GameModel = require("GameModel")
local GameView = require("GameView")
local InputController = require("InputController")

local WIDTH, HEIGHT = 600, 800
local FIXED_DT = 1 / 60
local MAX_FRAME_DT = 0.25 -- 창 드래그 등으로 dt 가 튀어도 스텝이 폭주하지 않게

local game, view, controller
local acc = 0

function love.load()
  love.graphics.setBackgroundColor(0.02, 0.02, 0.06)
  -- 비결정 요소(시각 기반 시드)는 조립부에서만 정한다. Model 은 받은 시드대로 결정적으로 돈다.
  game = GameModel({ width = WIDTH, height = HEIGHT, seed = os.time() })
  view = GameView({ width = WIDTH, height = HEIGHT })
  controller = InputController(game, love.keyboard.isDown)
end

function love.update(dt)
  if dt > MAX_FRAME_DT then
    dt = MAX_FRAME_DT
  end

  -- C: 이번 프레임 입력을 한 번 읽는다
  local input = controller:read()

  -- M: 고정 타임스텝으로 규칙 진행 (프레임당 0~여러 번)
  acc = acc + dt
  while acc >= FIXED_DT do
    game:update(FIXED_DT, input)
    acc = acc - FIXED_DT
  end

  -- M → V: 이번 프레임에 쌓인 사건을 한 번에 넘긴다 (3주차 drainEvents)
  local events = game:drainEvents()
  for i = 1, #events do
    view:onEvent(events[i])
  end

  -- V: 연출 시간 진행
  view:update(dt)
end

function love.draw()
  view:draw(love.graphics, game)
end

function love.keypressed(key)
  if controller:keypressed(key) == "quit" then
    love.event.quit()
  end
end
