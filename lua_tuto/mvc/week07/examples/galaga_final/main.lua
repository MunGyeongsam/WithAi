-- main.lua
-- 조립(composition root). love 를 아는 유일한 파일.
-- 씬들이 love 를 모르도록 필요한 것(gfx, isDown, 시드, 종료, 씬 목록)을 ctx 하나로 묶어 넘긴다.
-- 조작: 타이틀 Enter/Space 시작 · 플레이 ←/→(A/D) 이동, Space 발사, X 미사일, P/Esc 일시정지
--       일시정지 P/Esc 재개, Q 타이틀 · 결과 R 재도전, V 리플레이, S 리플레이 저장, Enter 타이틀
--       타이틀 L 저장된 리플레이, Esc 종료 · 리플레이 Space 1/4배속, Esc/Enter 타이틀 · 어디서나 F3 성능 표시

love.filesystem.setRequirePath("?.lua;?/init.lua;models/?.lua;views/?.lua;controllers/?.lua;scenes/?.lua")

local SceneStack = require("SceneStack")

local stack
local games = 0

-- os.time 은 초 단위라 1초 안에 재도전하면 같은 시드(= 똑같은 판)가 나온다. 판 번호를 섞는다.
local function newSeed()
  games = games + 1
  return os.time() * 1000 + games
end

-- 씬은 파일 시스템을 모른다. 저장소는 이름 → 문자열 두 함수로만 보인다(테스트는 표로 대신한다).
local storage = {
  write = function(name, text)
    return love.filesystem.write(name, text) == true
  end,
  read = function(name)
    if love.filesystem.getInfo(name) then
      return love.filesystem.read(name)
    end
    return nil
  end,
}

-- F3 성능 표시. 측정은 love 를 아는 이 파일에서만 한다(씬·Model 에 측정 코드를 섞지 않는다).
local perf = { on = false, update = 0, draw = 0 }
local function smooth(old, new)
  return old * 0.9 + new * 0.1
end

function love.load()
  love.graphics.setBackgroundColor(0.02, 0.02, 0.06)

  -- 씬끼리 서로 require 하면 순환이 생긴다(Title→Play→Result→Title). 목록을 여기서 한 번 주입한다.
  local ctx = {
    width = 600,
    height = 800,
    isDown = love.keyboard.isDown,
    seed = newSeed,
    quit = love.event.quit,
    storage = storage,
    scenes = {
      Title = require("TitleScene"),
      Play = require("PlayScene"),
      Pause = require("PauseScene"),
      Result = require("ResultScene"),
      Replay = require("ReplayScene"),
    },
  }

  stack = SceneStack()
  stack:push(ctx.scenes.Title(ctx))
end

function love.update(dt)
  local t0 = love.timer.getTime()
  stack:update(dt)
  perf.update = smooth(perf.update, love.timer.getTime() - t0)
end

function love.draw()
  local t0 = love.timer.getTime()
  stack:draw(love.graphics)
  perf.draw = smooth(perf.draw, love.timer.getTime() - t0)
  if perf.on then
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 380, 740, 215, 56)
    love.graphics.setColor(0.6, 1, 0.6)
    love.graphics.print(string.format("FPS %d\nupdate %.3f ms  draw %.3f ms\nLua mem %.0f KB",
      love.timer.getFPS(), perf.update * 1000, perf.draw * 1000, collectgarbage("count")), 388, 744)
  end
end

function love.keypressed(key)
  if key == "f3" then
    perf.on = not perf.on
    return
  end
  stack:keypressed(key)
end
