-- ============================================================================
-- gameplayScene.lua — 메인 게임플레이 (미로 빌딩 TD)
-- ============================================================================
local GameMap = require("03_game.gameMap")
local Tower = require("03_game.tower")
local WaveManager = require("03_game.waveManager")
local Economy = require("03_game.economy")
local Levels = require("03_game.levels")
local Hud = require("04_ui.hud")

local GameplayScene = {}
GameplayScene.__index = GameplayScene

-- 게임 상태
local STATE_BUILD = "build"
local STATE_WAVE = "wave"
local STATE_GAMEOVER = "gameover"
local STATE_VICTORY = "victory"

-- 배치 모드
local PLACE_WALL = "wall"
local PLACE_TOWER = "tower"

local WALL_COST = 5

function GameplayScene.new(baseWidth, baseHeight, levelIndex)
    local self = setmetatable({}, GameplayScene)
    self.baseWidth = baseWidth
    self.baseHeight = baseHeight
    self.levelIndex = levelIndex

    local levelData = Levels.getLevel(levelIndex)
    self.map = GameMap.new(levelData)
    self.economy = Economy.new(levelData.startGold, levelData.startLives)
    self.waveManager = WaveManager.new()
    self.hud = Hud.new(baseWidth, baseHeight)

    self.towers = {}
    self.enemies = {}
    self.state = STATE_BUILD

    -- 배치 상태
    self.placeMode = PLACE_WALL         -- "wall" or "tower"
    self.selectedTowerType = "gun"

    -- 맵 스크롤 오프셋 (세로로 맵이 화면보다 클 경우)
    self.mapOffsetY = 0

    return self
end

function GameplayScene:onEnter() end

function GameplayScene:update(dt)
    if self.state == STATE_GAMEOVER or self.state == STATE_VICTORY then
        return
    end

    -- 타워 업데이트
    for _, tower in ipairs(self.towers) do
        local proj = tower:update(dt, self.enemies)
        if proj then
            -- 즉시 데미지 적용
            if proj.target and not proj.target.dead then
                proj.target:takeDamage(proj.damage)
                -- 슬로우 적용
                if proj.slow and proj.slow > 0 then
                    proj.target:applySlow(proj.slow, proj.slowDuration or 1.5)
                end
                -- 스플래시
                if proj.splash and proj.splash > 0 then
                    for _, enemy in ipairs(self.enemies) do
                        if enemy ~= proj.target and not enemy.dead then
                            local dx = enemy.x - proj.targetX
                            local dy = enemy.y - proj.targetY
                            if (dx * dx + dy * dy) <= (proj.splash * proj.splash) then
                                enemy:takeDamage(proj.damage * 0.3)
                                if proj.slow and proj.slow > 0 then
                                    enemy:applySlow(proj.slow * 0.5, (proj.slowDuration or 1.5) * 0.5)
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- 적 업데이트
    for i = #self.enemies, 1, -1 do
        local enemy = self.enemies[i]
        enemy:update(dt)

        if enemy.dead then
            self.economy:earn(enemy.reward)
            table.remove(self.enemies, i)
        elseif enemy.reachedEnd then
            self.economy:loseLife(1)
            table.remove(self.enemies, i)
        end
    end

    -- 웨이브 스폰
    if self.state == STATE_WAVE then
        local pathPixels = self.map:getPathPixels()
        local entryX, entryY = self.map:cellToPixel(self.map.entryCol, self.map.entryRow)
        local exitX, exitY = self.map:cellToPixel(self.map.exitCol, self.map.exitRow)
        local entryPixel = {x = entryX, y = entryY}
        local exitPixel = {x = exitX, y = exitY}

        local spawned = self.waveManager:update(dt, pathPixels, entryPixel, exitPixel)
        if spawned then
            for _, e in ipairs(spawned) do
                self.enemies[#self.enemies + 1] = e
            end
        end

        -- 웨이브 종료 체크
        if not self.waveManager:isWaveInProgress() and #self.enemies == 0 then
            if self.waveManager.allWavesComplete then
                self.state = STATE_VICTORY
            else
                self.state = STATE_BUILD
            end
        end
    end

    -- 게임 오버
    if self.economy:isGameOver() then
        self.state = STATE_GAMEOVER
    end
end

function GameplayScene:setInputSnapshot(snapshot)
    if self.state == STATE_GAMEOVER or self.state == STATE_VICTORY then
        if snapshot.tapped then
            self:_returnToTitle()
        end
        return
    end

    if not snapshot.tapped then return end
    local tapX, tapY = snapshot.tapX, snapshot.tapY

    -- HUD 처리 우선
    local hudAction = self.hud:handleTap(tapX, tapY, self)
    if hudAction then return end

    -- 맵 영역 탭 → 배치
    local col, row = self.map:pixelToCell(tapX, tapY + self.mapOffsetY)

    if self.placeMode == PLACE_WALL then
        if self.economy:canAfford(WALL_COST) and self.map:canPlace(col, row) then
            if self.map:placeWall(col, row) then
                self.economy:spend(WALL_COST)
                self:_updateEnemyPaths()
            end
        end
    elseif self.placeMode == PLACE_TOWER then
        local cost = Tower.getCost(self.selectedTowerType)
        if self.economy:canAfford(cost) and self.map:canPlace(col, row) then
            if self.map:placeTower(col, row) then
                self.economy:spend(cost)
                local px, py = self.map:cellToPixel(col, row)
                local tower = Tower.new(self.selectedTowerType, px, py)
                self.towers[#self.towers + 1] = tower
                self:_updateEnemyPaths()
            end
        end
    end
end

function GameplayScene:_updateEnemyPaths()
    local pathPixels = self.map:getPathPixels()
    if not pathPixels then return end
    for _, enemy in ipairs(self.enemies) do
        enemy:updatePath(pathPixels)
    end
end

function GameplayScene:startWave()
    if self.state == STATE_BUILD then
        if self.waveManager:startNextWave() then
            self.state = STATE_WAVE
        end
    end
end

function GameplayScene:setPlaceMode(mode)
    self.placeMode = mode
end

function GameplayScene:selectTowerType(towerType)
    self.selectedTowerType = towerType
    self.placeMode = PLACE_TOWER
end

function GameplayScene:draw()
    local gr = love.graphics

    gr.push()
    gr.translate(0, -self.mapOffsetY)

    -- 맵
    self.map:draw()

    -- 타워
    for _, tower in ipairs(self.towers) do
        tower:draw()
    end

    -- 적
    for _, enemy in ipairs(self.enemies) do
        enemy:draw()
    end

    gr.pop()

    -- HUD (화면 고정)
    self.hud:draw(self)

    -- 오버레이
    if self.state == STATE_GAMEOVER then
        self:_drawOverlay("GAME OVER", {1, 0.2, 0.2})
    elseif self.state == STATE_VICTORY then
        self:_drawOverlay("VICTORY!", {0.2, 1, 0.4})
    end

    gr.setColor(1, 1, 1, 1)
end

function GameplayScene:_drawOverlay(text, color)
    local gr = love.graphics
    gr.setColor(0, 0, 0, 0.75)
    gr.rectangle("fill", 0, 0, self.baseWidth, self.baseHeight)
    gr.setColor(color[1], color[2], color[3], 1)
    local font = gr.getFont()
    local tw = font:getWidth(text)
    gr.print(text, self.baseWidth / 2 - tw / 2, self.baseHeight / 2 - 20)
    gr.setColor(0.7, 0.7, 0.7, 1)
    local sub = "Tap to return"
    local sw = font:getWidth(sub)
    gr.print(sub, self.baseWidth / 2 - sw / 2, self.baseHeight / 2 + 10)
end

function GameplayScene:_returnToTitle()
    local TitleScene = require("03_game.scenes.titleScene")
    self._stack:replace(TitleScene.new(self.baseWidth, self.baseHeight))
end

function GameplayScene:resize(width, height) end

-- 상태 접근자
GameplayScene.STATE_BUILD = STATE_BUILD
GameplayScene.STATE_WAVE = STATE_WAVE
GameplayScene.PLACE_WALL = PLACE_WALL
GameplayScene.PLACE_TOWER = PLACE_TOWER
GameplayScene.WALL_COST = WALL_COST

return GameplayScene
