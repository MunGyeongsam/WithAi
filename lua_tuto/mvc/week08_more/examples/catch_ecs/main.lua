-- main.lua (ECS)
-- love 를 아는 유일한 파일. 조작: ←/→(A/D) 이동, H 하트 섞기 켜고 끄기(새 판), R 새 판, Esc 종료

love.filesystem.setRequirePath("?.lua;ecs/?.lua;game/?.lua;systems/?.lua")

local R = require("rules")
local CatchGame = require("CatchGame")
local kinds = require("kinds")

local game
local games = 0
local acc = 0
local withHeart = false

local function newGame()
  games = games + 1
  acc = 0
  game = CatchGame({
    seed = os.time() * 1000 + games,
    spawnTable = withHeart and kinds.WITH_HEART or kinds.DEFAULT,
  })
end

function love.load()
  newGame()
end

function love.update(dt)
  acc = acc + dt
  while acc >= R.TICK do
    acc = acc - R.TICK
    game:tick()
  end
end

function love.draw()
  game:draw(love.graphics)
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  elseif key == "r" then
    newGame()
  elseif key == "h" then
    withHeart = not withHeart
    newGame()
  elseif key == "left" or key == "a" then
    game:move(-1)
  elseif key == "right" or key == "d" then
    game:move(1)
  end
end
