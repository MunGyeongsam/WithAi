-- ============================================================================
-- hud.lua — HUD (Xeno Tactic 스타일: 벽/타워 선택 + 정보)
-- ============================================================================
local Tower = require("03_game.tower")

local Hud = {}
Hud.__index = Hud

local PANEL_HEIGHT = 180
local TOWER_TYPES = Tower.getTypes()

function Hud.new(baseWidth, baseHeight)
    local self = setmetatable({}, Hud)
    self.baseWidth = baseWidth
    self.baseHeight = baseHeight
    self.panelY = baseHeight - PANEL_HEIGHT
    self.buttons = {}
    self:_buildButtons()
    return self
end

function Hud:_buildButtons()
    local btnSize = 50
    local gap = 10
    local row1Y = self.panelY + 32

    -- 벽 버튼
    self.wallBtn = {
        x = 10,
        y = row1Y,
        w = btnSize,
        h = btnSize,
    }

    -- 타워 버튼들
    local startX = 10 + btnSize + gap + 10
    for i, ttype in ipairs(TOWER_TYPES) do
        self.buttons[i] = {
            x = startX + (i - 1) * (btnSize + gap),
            y = row1Y,
            w = btnSize,
            h = btnSize,
            type = ttype,
        }
    end

    -- Start Wave 버튼
    local swW = 130
    local swH = 36
    self.startWaveBtn = {
        x = self.baseWidth / 2 - swW / 2,
        y = self.panelY + 95,
        w = swW,
        h = swH,
    }

    -- Send Wave (웨이브 중 다음 즉시 시작)
    self.sendWaveBtn = self.startWaveBtn
end

function Hud:handleTap(tapX, tapY, scene)
    -- 패널 밖이면 무시
    if tapY < self.panelY then
        return false
    end

    -- 벽 버튼
    local wb = self.wallBtn
    if tapX >= wb.x and tapX <= wb.x + wb.w and tapY >= wb.y and tapY <= wb.y + wb.h then
        scene:setPlaceMode(scene.PLACE_WALL)
        return true
    end

    -- 타워 버튼
    for _, btn in ipairs(self.buttons) do
        if tapX >= btn.x and tapX <= btn.x + btn.w and tapY >= btn.y and tapY <= btn.y + btn.h then
            scene:selectTowerType(btn.type)
            return true
        end
    end

    -- Start Wave 버튼
    local sw = self.startWaveBtn
    if tapX >= sw.x and tapX <= sw.x + sw.w and tapY >= sw.y and tapY <= sw.y + sw.h then
        scene:startWave()
        return true
    end

    return true  -- 패널 내 탭 소비
end

function Hud:draw(scene)
    local gr = love.graphics

    -- 패널 배경
    gr.setColor(0.08, 0.08, 0.12, 0.92)
    gr.rectangle("fill", 0, self.panelY, self.baseWidth, PANEL_HEIGHT)
    gr.setColor(0.3, 0.3, 0.4, 1)
    gr.line(0, self.panelY, self.baseWidth, self.panelY)

    -- 정보바
    gr.setColor(1, 0.85, 0.2, 1)
    gr.print("G:" .. scene.economy:getGold(), 10, self.panelY + 6)
    gr.setColor(1, 0.3, 0.3, 1)
    gr.print("HP:" .. scene.economy:getLives(), 90, self.panelY + 6)
    gr.setColor(0.6, 0.8, 1, 1)
    local waveText = "W:" .. scene.waveManager:getCurrentWave() .. "/" .. scene.waveManager:getTotalWaves()
    gr.print(waveText, 180, self.panelY + 6)

    -- 현재 모드 표시
    gr.setColor(0.8, 0.8, 0.8, 0.7)
    local modeStr = scene.placeMode == scene.PLACE_WALL and "[Wall]" or "[" .. scene.selectedTowerType .. "]"
    gr.print("Mode: " .. modeStr, 280, self.panelY + 6)

    -- 벽 버튼
    local wb = self.wallBtn
    local isWallMode = (scene.placeMode == scene.PLACE_WALL)
    if isWallMode then
        gr.setColor(0.4, 0.5, 0.4, 1)
    else
        gr.setColor(0.25, 0.25, 0.3, 1)
    end
    gr.rectangle("fill", wb.x, wb.y, wb.w, wb.h, 4, 4)
    gr.setColor(0.5, 0.5, 0.5, 1)
    gr.rectangle("fill", wb.x + 12, wb.y + 12, 26, 26)
    gr.setColor(1, 1, 1, 0.8)
    local font = gr.getFont()
    local wCost = tostring(scene.WALL_COST)
    local wcw = font:getWidth(wCost)
    gr.print(wCost, wb.x + wb.w / 2 - wcw / 2, wb.y + wb.h - 14)

    -- 타워 버튼
    for _, btn in ipairs(self.buttons) do
        local def = Tower.DEFS[btn.type]
        local selected = (scene.placeMode == scene.PLACE_TOWER and scene.selectedTowerType == btn.type)

        if selected then
            gr.setColor(0.35, 0.45, 0.6, 1)
        else
            gr.setColor(0.2, 0.2, 0.28, 1)
        end
        gr.rectangle("fill", btn.x, btn.y, btn.w, btn.h, 4, 4)

        -- 타워 색상 아이콘
        gr.setColor(def.color[1], def.color[2], def.color[3], 1)
        gr.rectangle("fill", btn.x + 12, btn.y + 8, 26, 22)

        -- 비용
        gr.setColor(1, 1, 1, 0.8)
        local costStr = tostring(def.cost)
        local cw = font:getWidth(costStr)
        gr.print(costStr, btn.x + btn.w / 2 - cw / 2, btn.y + btn.h - 14)
    end

    -- Start Wave 버튼 (빌드 모드)
    if scene.state == scene.STATE_BUILD then
        local sw = self.startWaveBtn
        gr.setColor(0.2, 0.6, 0.3, 1)
        gr.rectangle("fill", sw.x, sw.y, sw.w, sw.h, 6, 6)
        gr.setColor(1, 1, 1, 1)
        local label = "START WAVE"
        local lw = font:getWidth(label)
        gr.print(label, sw.x + sw.w / 2 - lw / 2, sw.y + sw.h / 2 - 7)
    elseif scene.state == scene.STATE_WAVE then
        -- 웨이브 중에도 배치 가능 표시
        local sw = self.startWaveBtn
        gr.setColor(0.4, 0.4, 0.2, 1)
        gr.rectangle("fill", sw.x, sw.y, sw.w, sw.h, 6, 6)
        gr.setColor(0.9, 0.9, 0.5, 1)
        local label = "WAVE " .. scene.waveManager:getCurrentWave()
        local lw = font:getWidth(label)
        gr.print(label, sw.x + sw.w / 2 - lw / 2, sw.y + sw.h / 2 - 7)
    end

    -- 타워 설명 (하단)
    if scene.placeMode == scene.PLACE_TOWER then
        local def = Tower.DEFS[scene.selectedTowerType]
        if def then
            gr.setColor(0.7, 0.7, 0.7, 0.8)
            local desc = def.name .. " | DMG:" .. def.damage .. " RNG:" .. def.range .. " SPD:" .. def.fireRate
            if def.targetAir then desc = desc .. " [AIR]" end
            if def.slow > 0 then desc = desc .. " [SLOW]" end
            gr.print(desc, 10, self.panelY + 140)
        end
    end

    gr.setColor(1, 1, 1, 1)
end

return Hud
