local Camera = require("camera")
local WorldAxis = require("worldAxis")
local cam

function love.load()
    -- 화면 높이의 절반을 orthoSize로 설정하여 1유닛 = 1픽셀 매핑을 기본으로 지정합니다.
    local height = love.graphics.getHeight()
    cam = Camera.new(0, 0, 5)
end

function love.update(dt)
end

local function drawScreenAxis()

    local gr = love.graphics

    gr.setLineWidth(4)

    -- X 축
    gr.setColor(1, 0, 0)
    gr.line(0, 0, 30, 0)

    -- Y 축
    gr.setColor(0, 1, 0)
    gr.line(0, 0, 0, 30)

    gr.setLineWidth(1)
end

function love.draw()
    -- 1. 카메라 좌표계 내에서 월드 축 그리기 (+x, +y)
    cam:apply()
    WorldAxis.drawGrid(10, 1, 1)
    WorldAxis.draw(cam, 3, 4)
    cam:reset()

    drawScreenAxis()

    -- 2. 스크린 기준 카메라 정보 출력
    cam:drawInfo(10, 10)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end
