-- main.lua (Hexagonal)
-- love 를 아는 유일한 파일 = 어댑터를 골라 코어에 꽂는 "조립 지점"(composition root).
-- 조작: ←/→(A/D) 이동, R 새 판, Esc 종료. 최고 점수는 저장 폴더의 best.txt 에 남는다.

love.filesystem.setRequirePath("?.lua;core/?.lua;adapters/?.lua")

local R = require("rules")
local CatchGame = require("CatchGame")
local PrngRandom = require("PrngRandom")
local FileScores = require("FileScores")
local Renderer = require("Renderer")

local game
local games = 0
local acc = 0

local scores = FileScores({
  getInfo = love.filesystem.getInfo,
  read = love.filesystem.read,
  write = love.filesystem.write,
})

local function newGame()
  games = games + 1
  acc = 0
  game = CatchGame({ random = PrngRandom(os.time() * 1000 + games), scores = scores })
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
  Renderer.draw(love.graphics, game)
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  elseif key == "r" then
    newGame()
  elseif key == "left" or key == "a" then
    game:move(-1)
  elseif key == "right" or key == "d" then
    game:move(1)
  end
end
