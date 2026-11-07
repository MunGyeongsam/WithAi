-- main.lua (MVP)
-- love 를 아는 유일한 파일. 조작: ←/→(A/D) 이동, R 새 판, Esc 종료

love.filesystem.setRequirePath("?.lua;models/?.lua;views/?.lua;presenters/?.lua")

local CatchModel = require("CatchModel")
local CatchView = require("CatchView")
local CatchPresenter = require("CatchPresenter")

local view, presenter
local games = 0

local function newGame()
  games = games + 1
  view = CatchView()
  presenter = CatchPresenter(CatchModel(os.time() * 1000 + games), view)
end

function love.load()
  newGame()
end

function love.update(dt)
  presenter:update(dt)
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
    presenter:onKey(key)
  end
end
