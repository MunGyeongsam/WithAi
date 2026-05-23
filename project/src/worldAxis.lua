local WorldAxis = {}

--- 월드 공간에 그리드를 그립니다.
-- @param count 각 방향으로 그릴 선의 개수 (기본값: 10)
-- @param spacing 그리드 간격 (월드 유닛, 기본값: 1)
-- @param screenThickness 화면에 표시될 원하는 픽셀 두께 (기본값: 1)
function WorldAxis.drawGrid(count, spacing, screenThickness)
    count = count or 10
    spacing = spacing or 1
    screenThickness = screenThickness or 1

    local height = love.graphics.getHeight()
    local zoom = height / 2
    local thickness = screenThickness / zoom

    local prevWidth = love.graphics.getLineWidth()
    local prevR, prevG, prevB, prevA = love.graphics.getColor()

    love.graphics.setLineWidth(thickness)
    love.graphics.setColor(0.3, 0.3, 0.3)

    local maxDist = count * spacing

    for i = -count, count do
        local pos = i * spacing
        love.graphics.line(pos, -maxDist, pos, maxDist)
        love.graphics.line(-maxDist, pos, maxDist, pos)
    end

    love.graphics.setLineWidth(prevWidth)
    love.graphics.setColor(prevR, prevG, prevB, prevA)
end

--- 월드 공간의 0,0 위치에 +X(빨간색), +Y(초록색) 축을 그립니다.
-- @param camera 카메라 객체 (카메라의 줌 비율을 반영하여 선 두께를 보정)
-- @param length 축의 길이 (기본값: 40)
-- @param screenThickness 화면에 표시될 원하는 픽셀 두께 (기본값: 4)
function WorldAxis.draw(camera, length, screenThickness)
    length = length or 40
    screenThickness = screenThickness or 4

    -- 카메라의 줌(zoom) 값을 구합니다.
    local zoom = 1
    if camera then
        if camera.zoom then
            zoom = camera.zoom
        else
            -- 카메라 줌이 아직 초기화되지 않았다면 직접 계산합니다.
            local height = love.graphics.getHeight()
            if height > 0 and camera.orthoSize and camera.orthoSize > 0 then
                zoom = height / (2 * camera.orthoSize)
            end
        end
    end

    -- 카메라의 줌을 반영하여 실제 화면에서 일정한 두께(screenThickness 픽셀)로 렌더링되도록 변환합니다.
    local thickness = screenThickness / zoom

    -- 이전 그리기 상태 저장 (선 폭, 색상)
    local prevWidth = love.graphics.getLineWidth()
    local prevR, prevG, prevB, prevA = love.graphics.getColor()

    -- 축 선 설정 및 그리기
    love.graphics.setLineWidth(thickness)

    -- +X축: Red (빨간색)
    love.graphics.setColor(1, 0, 0)
    love.graphics.line(0, 0, length, 0)

    -- +Y축: Green (초록색)
    love.graphics.setColor(0, 1, 0)
    love.graphics.line(0, 0, 0, length)

    -- 이전 그리기 상태 복원
    love.graphics.setLineWidth(prevWidth)
    love.graphics.setColor(prevR, prevG, prevB, prevA)
end

return WorldAxis
