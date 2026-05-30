local ProgressStore = {}
ProgressStore.__index = ProgressStore

local DEFAULT_PATH = "save/progress_v1.lua"

local function cloneTable(value)
    if type(value) ~= "table" then
        return value
    end

    local copy = {}
    for key, item in pairs(value) do
        copy[key] = cloneTable(item)
    end
    return copy
end

local function sortedKeys(tbl)
    local keys = {}
    for key in pairs(tbl) do
        keys[#keys + 1] = key
    end
    table.sort(keys, function(a, b)
        if type(a) == type(b) then
            return a < b
        end
        return tostring(a) < tostring(b)
    end)
    return keys
end

local function serializeValue(value, indent)
    local valueType = type(value)
    if valueType == "number" or valueType == "boolean" then
        return tostring(value)
    end

    if valueType == "string" then
        return string.format("%q", value)
    end

    if valueType ~= "table" then
        return "nil"
    end

    local nextIndent = indent .. "    "
    local parts = {"{"}
    local keys = sortedKeys(value)

    for i = 1, #keys do
        local key = keys[i]
        local encodedKey
        if type(key) == "string" and string.match(key, "^[%a_][%w_]*$") then
            encodedKey = key
        else
            encodedKey = "[" .. serializeValue(key, nextIndent) .. "]"
        end
        parts[#parts + 1] = "\n" .. nextIndent .. encodedKey .. " = " .. serializeValue(value[key], nextIndent) .. ","
    end

    if #keys > 0 then
        parts[#parts + 1] = "\n" .. indent
    end
    parts[#parts + 1] = "}"
    return table.concat(parts)
end

local function defaultData()
    return {
        version = 1,
        modes = {},
    }
end

local function resolveFilesystem(filesystem)
    if filesystem then
        return filesystem
    end

    if love and love.filesystem then
        return love.filesystem
    end

    return {
        getInfo = function()
            return nil
        end,
        read = function()
            return ""
        end,
        write = function()
            return false
        end,
    }
end

function ProgressStore.new(options)
    local self = setmetatable({}, ProgressStore)
    self.options = options or {}
    self.path = self.options.path or DEFAULT_PATH
    self.filesystem = resolveFilesystem(self.options.filesystem)
    self.data = nil
    return self
end

function ProgressStore:load()
    if self.data then
        return self.data
    end

    local info = self.filesystem.getInfo and self.filesystem.getInfo(self.path)
    if not info then
        self.data = defaultData()
        return self.data
    end

    local contents = self.filesystem.read(self.path)
    local chunk = loadstring(contents)
    if not chunk then
        self.data = defaultData()
        return self.data
    end

    local ok, decoded = pcall(chunk)
    if not ok or type(decoded) ~= "table" then
        self.data = defaultData()
        return self.data
    end

    if type(decoded.modes) ~= "table" then
        decoded.modes = {}
    end

    self.data = decoded
    return self.data
end

function ProgressStore:save()
    local data = self:load()
    local payload = "return " .. serializeValue(data, "") .. "\n"
    self.filesystem.write(self.path, payload)
end

function ProgressStore:getModeProgress(modeId, totalLevels)
    local data = self:load()
    local modeProgress = data.modes[modeId]
    if type(modeProgress) ~= "table" then
        modeProgress = {
            unlockedLevel = 1,
            levels = {},
        }
        data.modes[modeId] = modeProgress
    end

    if type(modeProgress.levels) ~= "table" then
        modeProgress.levels = {}
    end

    if type(modeProgress.unlockedLevel) ~= "number" then
        modeProgress.unlockedLevel = 1
    end

    if totalLevels and totalLevels > 0 and modeProgress.unlockedLevel > totalLevels then
        modeProgress.unlockedLevel = totalLevels
    end

    return modeProgress
end

function ProgressStore:getLevelProgress(modeId, level, totalLevels)
    local modeProgress = self:getModeProgress(modeId, totalLevels)
    local levelProgress = modeProgress.levels[level]
    if type(levelProgress) ~= "table" then
        levelProgress = {
            cleared = false,
            bestScore = 0,
        }
        modeProgress.levels[level] = levelProgress
    end

    if type(levelProgress.cleared) ~= "boolean" then
        levelProgress.cleared = false
    end
    if type(levelProgress.bestScore) ~= "number" then
        levelProgress.bestScore = 0
    end

    return levelProgress
end

function ProgressStore:recordLevelResult(modeId, level, totalLevels, score, cleared, unlockLevel)
    local modeProgress = self:getModeProgress(modeId, totalLevels)
    local levelProgress = self:getLevelProgress(modeId, level, totalLevels)
    local changed = false
    local nextUnlock = unlockLevel or level

    if totalLevels and totalLevels > 0 and nextUnlock > totalLevels then
        nextUnlock = totalLevels
    end

    if score and score > levelProgress.bestScore then
        levelProgress.bestScore = score
        changed = true
    end

    if cleared and not levelProgress.cleared then
        levelProgress.cleared = true
        changed = true
    end

    if nextUnlock and nextUnlock > modeProgress.unlockedLevel then
        modeProgress.unlockedLevel = nextUnlock
        changed = true
    end

    if changed then
        self:save()
    end

    return changed
end

function ProgressStore:getSnapshot(modeId, totalLevels)
    local modeProgress = self:getModeProgress(modeId, totalLevels)
    local snapshot = {
        unlockedLevel = modeProgress.unlockedLevel,
        levels = {},
    }

    for level = 1, totalLevels do
        snapshot.levels[level] = cloneTable(self:getLevelProgress(modeId, level, totalLevels))
    end

    return snapshot
end

return ProgressStore