-- main.lua
-- 조립(composition root). love 를 아는 유일한 파일.
-- 씬들이 love 를 모르도록 필요한 것(gfx, isDown, 시드, 종료, 씬 목록)을 ctx 하나로 묶어 넘긴다.
-- 조작: 타이틀 Enter/Space 시작 · 플레이 ←/→(A/D) 이동, Space 발사, X 미사일, P/Esc 일시정지
--       일시정지 P/Esc 재개, Q 타이틀 · 결과 R 재도전, Enter 타이틀 · 타이틀 Esc 종료

love.filesystem.setRequirePath("?.lua;?/init.lua;models/?.lua;views/?.lua;controllers/?.lua;scenes/?.lua")

local SceneStack = require("SceneStack")

local stack
local games = 0

-- os.time 은 초 단위라 1초 안에 재도전하면 같은 시드(= 똑같은 판)가 나온다. 판 번호를 섞는다.
local function newSeed()
  games = games + 1
  return os.time() * 1000 + games
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
    scenes = {
      Title = require("TitleScene"),
      Play = require("PlayScene"),
      Pause = require("PauseScene"),
      Result = require("ResultScene"),
    },
  }

  stack = SceneStack()
  stack:push(ctx.scenes.Title(ctx))
end

function love.update(dt)
  stack:update(dt)
end

function love.draw()
  stack:draw(love.graphics)
end

function love.keypressed(key)
  stack:keypressed(key)
end
