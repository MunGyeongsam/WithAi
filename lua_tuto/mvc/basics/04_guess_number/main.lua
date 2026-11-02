-- main.lua  (예제 4: 숫자 맞히기 게임)
-- 실행: lua main.lua        → 자동 시연 (정답이 42 로 고정된 random 을 주입)
--       lua main.lua -i     → 직접 플레이 (진짜 난수)

local here = (arg and arg[0] or ""):match("(.*[/\\])") or "./"
package.path = here .. "?.lua;" .. package.path

local GuessModel = require("guess_model")
local GuessView = require("guess_view")
local GuessController = require("guess_controller")

local interactive = arg and arg[1] == "-i"

local random
if interactive then
  math.randomseed(os.time())
  random = function(a, b)
    return math.random(a, b)
  end
else
  random = function()
    return 42
  end
end

local model = GuessModel.new({ min = 1, max = 100, maxAttempts = 5, random = random })
local view = GuessView.new(print)
local controller = GuessController.new(model, view)

local script = { "50", "abc", "25", "150", "40", "42", "7", "quit" }
local step = 0

local function nextCommand()
  if interactive then
    io.write("> ")
    return io.read("*l")
  end
  step = step + 1
  local command = script[step]
  if command then
    print("> " .. command)
  end
  return command
end

view:showIntro(model)
while true do
  local command = nextCommand()
  if command == nil or not controller:handle(command) then
    break
  end
end
print("종료합니다.")
