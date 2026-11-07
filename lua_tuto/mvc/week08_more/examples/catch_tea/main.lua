-- main.lua (TEA)
-- love 를 아는 유일한 파일. effect(소리)를 실제로 실행하는 곳도 여기다.
-- 조작: ←/→(A/D) 이동, Backspace 4틱 되감기, R 새 판, Esc 종료

love.filesystem.setRequirePath("?.lua;tea/?.lua")

local catch = require("catch")
local Runtime = require("Runtime")

local runtime, sounds
local games = 0

local function tone(freq, duration)
  local rate = 44100
  local n = math.floor(rate * duration)
  local data = love.sound.newSoundData(n, rate, 16, 1)
  for i = 0, n - 1 do
    data:setSample(i, math.sin(2 * math.pi * freq * i / rate) * 0.2 * (1 - i / n))
  end
  return love.audio.newSource(data)
end

local function onEffect(e)
  if e.type == "beep" and sounds[e.name] then
    sounds[e.name]:stop()
    sounds[e.name]:play()
  end
end

local function newGame()
  games = games + 1
  runtime = Runtime(catch, os.time() * 1000 + games, onEffect)
end

function love.load()
  sounds = { coin = tone(880, 0.08), bomb = tone(140, 0.2) }
  newGame()
end

function love.update(dt)
  runtime:update(dt)
end

function love.draw()
  runtime:draw(love.graphics)
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  elseif key == "r" then
    newGame()
  elseif key == "backspace" then
    runtime:rewind(4)
  else
    runtime:keypressed(key)
  end
end
