-- main.lua  (예제 3: 온도 변환기 — Model 하나에 View 두 개)
-- 실행: lua main.lua        → 자동 시연
--       lua main.lua -i     → 직접 입력 (c 25, f 98.6, up, down, quit)

local here = (arg and arg[0] or ""):match("(.*[/\\])") or "./"
package.path = here .. "?.lua;" .. package.path

local TemperatureModel = require("temperature_model")
local TextView = require("text_view")
local GaugeView = require("gauge_view")
local TemperatureController = require("temperature_controller")

local model = TemperatureModel.new(20)
local textView = TextView.new(print)
local gaugeView = GaugeView.new(print)

textView:attach(model)
local detachGauge = gaugeView:attach(model)

local controller = TemperatureController.new(model, print)

local interactive = arg and arg[1] == "-i"
-- "gauge off" 는 main 이 처리하는 특별 명령: 막대 View 만 구독 해제한다.
local script = { "c 25", "up", "f 212", "c -300", "gauge off", "down", "quit" }
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

textView:render(model)
gaugeView:render(model)
while true do
  local command = nextCommand()
  if command == nil then
    break
  elseif command == "gauge off" then
    detachGauge()
    print("  (막대 View 구독 해제 — Model/Controller 는 그대로)")
  elseif not controller:handle(command) then
    break
  end
end
print("종료합니다.")
