-- 02_fixed_timestep_demo.lua
-- 고정 타임스텝(accumulator)이 프레임 간격과 무관하게 "같은 결과"를 내는지 증명한다.
-- 실행: cd lua_tuto/mvc/week01/examples && lua 02_fixed_timestep_demo.lua

local FIXED_DT = 1 / 60

-- 고정 타임스텝: 프레임 시간을 모아 FIXED_DT 단위로 잘라 물리를 돌린다.
local function run_fixed(frame_dts, vx)
  local x, acc, steps = 0, 0, 0
  for i = 1, #frame_dts do
    acc = acc + frame_dts[i]
    while acc >= FIXED_DT do
      x = x + vx * FIXED_DT
      acc = acc - FIXED_DT
      steps = steps + 1
    end
  end
  return x, steps
end

-- 가변 타임스텝: 프레임 dt 를 그대로 적분한다 (비교용).
local function run_variable(frame_dts, vx)
  local x = 0
  for i = 1, #frame_dts do
    x = x + vx * frame_dts[i]
  end
  return x
end

-- 같은 총 시간(1.0초)을 서로 다른 프레임 간격으로 쪼갠 두 시나리오
local function make_frames(dt, count)
  local t = {}
  for i = 1, count do
    t[i] = dt
  end
  return t
end

local smooth = make_frames(1 / 60, 60) -- 부드러운 60프레임
local choppy = make_frames(3 / 60, 20) -- 끊기는 20프레임 (프레임당 3스텝 분량)

local vx = 100 -- 초당 100픽셀

local fx_s, steps_s = run_fixed(smooth, vx)
local fx_c, steps_c = run_fixed(choppy, vx)

print("== 고정 타임스텝 ==")
print(string.format("smooth: x=%.4f, steps=%d", fx_s, steps_s))
print(string.format("choppy: x=%.4f, steps=%d", fx_c, steps_c))
print("결정적인가(스텝 수·위치 동일):", steps_s == steps_c and math.abs(fx_s - fx_c) < 1e-9)

print("== 가변 타임스텝(참고) ==")
print(string.format("smooth: x=%.4f", run_variable(smooth, vx)))
print(string.format("choppy: x=%.4f", run_variable(choppy, vx)))

-- 핵심: 고정 타임스텝은 프레임 간격이 달라도 스텝 수가 동일 → 결정적.
-- 가변 타임스텝은 등속에선 같아 보여도, 충돌/비선형 힘이 끼면 결과가 갈린다.
