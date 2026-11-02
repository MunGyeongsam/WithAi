-- main.lua
-- love 를 아는 유일한 파일. App 에 콜백을 넘기기만 한다.
-- 조작: 방향키/WASD 회전, R 새 판, (죽은 뒤) V 리플레이, Esc 종료(리플레이 중엔 돌아가기)

love.filesystem.setRequirePath("?.lua;core/?.lua;flux/?.lua;game/?.lua;views/?.lua;controllers/?.lua")

local App = require("App")

local app
local games = 0

-- os.time 은 초 단위라 1초 안에 새 판을 열면 같은 시드가 된다(5주차에서 발견). 판 번호를 섞는다.
local function newSeed()
  games = games + 1
  return os.time() * 1000 + games
end

function love.load()
  love.graphics.setBackgroundColor(0.02, 0.02, 0.05)
  app = App({ seed = newSeed })
end

function love.update(dt)
  app:update(dt)
end

function love.draw()
  app:draw(love.graphics)
end

function love.keypressed(key)
  if app:keypressed(key) == "quit" then
    love.event.quit()
  end
end
