-- main.lua (MVVM)
-- love 를 아는 유일한 파일. 조작: ←/→(A/D) 이동, R 새 판, Esc 종료

love.filesystem.setRequirePath("?.lua;core/?.lua;models/?.lua;viewmodels/?.lua;views/?.lua")

local CatchModel = require("CatchModel")
local CatchViewModel = require("CatchViewModel")
local CatchView = require("CatchView")

local vm, view
local games = 0

local function newGame()
  if view then
    view:destroy()
  end
  games = games + 1
  vm = CatchViewModel(CatchModel(os.time() * 1000 + games))
  view = CatchView(vm)
end

function love.load()
  newGame()
end

function love.update(dt)
  vm:update(dt)
  view:update(dt)
end

function love.draw()
  view:draw(love.graphics)
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  elseif key == "r" then
    newGame()
  else
    view:keypressed(key)
  end
end
