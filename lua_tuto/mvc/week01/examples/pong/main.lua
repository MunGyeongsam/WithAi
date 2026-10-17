-- main.lua
-- Pong (Week01). 목적: 메타테이블 클래스 + update/draw 분리 + 고정 타임스텝 체득.
-- 아직 MVC 아님. 일부러 단순 구조로 둔다.
-- 조작: 왼쪽 W/S, 오른쪽 ↑/↓, 종료 Esc.

local class = require("class")

local lg = love.graphics

local FIXED_DT = 1 / 60
local WIDTH, HEIGHT = 800, 600
local PADDLE_W, PADDLE_H = 16, 100
local PADDLE_SPEED = 360 -- px/s
local BALL_SIZE = 16
local BALL_SPEED = 300 -- px/s

-- ── 엔티티 ────────────────────────────────────────────────────────────────
local Paddle = class()

function Paddle:init(x)
  self.x = x
  self.y = (HEIGHT - PADDLE_H) * 0.5
  self.w = PADDLE_W
  self.h = PADDLE_H
end

-- dir: -1(위) / 0(정지) / 1(아래)
function Paddle:update(dt, dir)
  self.y = self.y + dir * PADDLE_SPEED * dt
  if self.y < 0 then
    self.y = 0
  elseif self.y > HEIGHT - self.h then
    self.y = HEIGHT - self.h
  end
end

local Ball = class()

function Ball:init()
  self:reset(1)
end

function Ball:reset(dir)
  self.x = (WIDTH - BALL_SIZE) * 0.5
  self.y = (HEIGHT - BALL_SIZE) * 0.5
  self.w = BALL_SIZE
  self.h = BALL_SIZE
  self.vx = BALL_SPEED * dir
  self.vy = BALL_SPEED * 0.35
end

function Ball:update(dt)
  self.x = self.x + self.vx * dt
  self.y = self.y + self.vy * dt
end

-- ── 충돌 (AABB) ──────────────────────────────────────────────────────────
local function overlaps(a, b)
  return a.x < b.x + b.w
    and b.x < a.x + a.w
    and a.y < b.y + b.h
    and b.y < a.y + a.h
end

-- ── 게임 상태 ────────────────────────────────────────────────────────────
local game

local function newGame()
  return {
    left = Paddle(24),
    right = Paddle(WIDTH - 24 - PADDLE_W),
    ball = Ball(),
    scoreL = 0,
    scoreR = 0,
    acc = 0,
  }
end

-- 입력을 방향값으로 변환 (폴링). update 안에서만 호출.
local function readDir(upKey, downKey)
  local d = 0
  if love.keyboard.isDown(upKey) then
    d = d - 1
  end
  if love.keyboard.isDown(downKey) then
    d = d + 1
  end
  return d
end

-- 고정 타임스텝 1회분. 모든 상태 변경은 여기서만 일어난다.
local function step(dt)
  game.left:update(dt, readDir("w", "s"))
  game.right:update(dt, readDir("up", "down"))

  local ball = game.ball
  ball:update(dt)

  -- 상/하 벽 반사
  if ball.y < 0 then
    ball.y = 0
    ball.vy = -ball.vy
  elseif ball.y > HEIGHT - ball.h then
    ball.y = HEIGHT - ball.h
    ball.vy = -ball.vy
  end

  -- 패들 반사 (x 방향만 뒤집고 살짝 가속)
  if ball.vx < 0 and overlaps(ball, game.left) then
    ball.x = game.left.x + game.left.w
    ball.vx = -ball.vx * 1.05
  elseif ball.vx > 0 and overlaps(ball, game.right) then
    ball.x = game.right.x - ball.w
    ball.vx = -ball.vx * 1.05
  end

  -- 좌/우 득점
  if ball.x + ball.w < 0 then
    game.scoreR = game.scoreR + 1
    ball:reset(1)
  elseif ball.x > WIDTH then
    game.scoreL = game.scoreL + 1
    ball:reset(-1)
  end
end

-- ── LÖVE 콜백 ────────────────────────────────────────────────────────────
function love.load()
  lg.setBackgroundColor(0, 0, 0)
  game = newGame()
end

function love.update(dt)
  -- accumulator 패턴: 프레임률과 무관하게 FIXED_DT 단위로 물리를 돌린다.
  game.acc = game.acc + dt
  while game.acc >= FIXED_DT do
    step(FIXED_DT)
    game.acc = game.acc - FIXED_DT
  end
end

function love.draw()
  -- 상태를 읽어 그리기만 한다 (상태 변경 금지).
  local b = game.ball
  lg.setColor(1, 1, 1)
  lg.rectangle("fill", game.left.x, game.left.y, game.left.w, game.left.h)
  lg.rectangle("fill", game.right.x, game.right.y, game.right.w, game.right.h)
  lg.rectangle("fill", b.x, b.y, b.w, b.h)

  lg.printf(tostring(game.scoreL), 0, 20, WIDTH * 0.5 - 20, "right")
  lg.printf(tostring(game.scoreR), WIDTH * 0.5 + 20, 20, WIDTH * 0.5 - 20, "left")
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end
