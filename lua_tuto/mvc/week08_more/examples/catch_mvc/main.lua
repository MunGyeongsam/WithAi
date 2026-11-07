-- main.lua (MVC)
-- love 를 아는 유일한 파일. 조작: ←/→(A/D) 이동, R 새 판, Esc 종료

love.filesystem.setRequirePath("?.lua;models/?.lua;views/?.lua;controllers/?.lua")

local CatchModel = require("CatchModel")
local CatchView = require("CatchView")
local CatchController = require("CatchController")

local model, controller
local games = 0

local function newGame()
  games = games + 1
  model = CatchModel(os.time() * 1000 + games)
  controller = CatchController(model)
end

function love.load()
  newGame()
end

function love.update(dt)
  controller:update(dt)
end

function love.draw()
  CatchView.draw(love.graphics, model)
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  elseif key == "r" then
    newGame()
  else
    controller:keypressed(key)
  end
end
