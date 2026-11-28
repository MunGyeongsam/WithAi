local scriptPath = debug.getinfo(1, "S").source:match("^@(.+)$") or ""
scriptPath = scriptPath:gsub("\\", "/")
local scriptDirectory = scriptPath:match("^(.*[/])") or ""
local isWindows = package.config:sub(1, 1) == "\\"
local interpreter = os.getenv("TD_LUA_EXECUTABLE") or arg[-1] or "lua"

local harnesses = {
    "core/fixed_timestep_harness.lua",
    "core/scene_stack_harness.lua",
    "core/virtual_resolution_harness.lua",
    "core/input_adapter_harness.lua",
    "scenes/input_routing_harness.lua",
    "ui/hud_harness.lua",
    "pathfinder_harness.lua",
    "map_harness.lua",
    "economy_harness.lua",
    "enemy_harness.lua",
    "tower_harness.lua",
    "wave_harness.lua",
    "data/levels_harness.lua",
    "scenes/gameplay_scene_harness.lua",
    "model/command_processor_harness.lua",
}

local function quote(value)
    value = tostring(value)
    if isWindows then
        return "\"" .. value:gsub("\"", "\"\"") .. "\""
    end
    return "'" .. value:gsub("'", "'\"'\"'") .. "'"
end

local function splitPath(path)
    local directory, file = path:match("^(.*)/([^/]+)$")
    if directory then
        return directory, file
    end
    return "", path
end

local function commandFor(harness)
    local relativeDirectory, file = splitPath(harness)
    local directory = scriptDirectory
    if relativeDirectory ~= "" then
        directory = directory .. relativeDirectory
    end
    if directory == "" then
        directory = "."
    end

    if isWindows then
        return "cd /d " .. quote(directory) .. " && " ..
            quote(interpreter) .. " " .. quote(file)
    end
    return "cd " .. quote(directory) .. " && " ..
        quote(interpreter) .. " " .. quote(file)
end

local function runHarness(harness)
    print("[RUN ] " .. harness)
    io.stdout:flush()
    local result = os.execute(commandFor(harness))
    if result == 0 or result == true then
        print("[DONE] " .. harness)
        return true
    end

    io.stderr:write("[FAIL] " .. harness .. " (exit " .. tostring(result) .. ")\n")
    return false, result
end

if arg[1] == "--failure-fixture" then
    harnesses = {"support/failure_fixture.lua"}
elseif arg[1] ~= nil then
    io.stderr:write("Usage: " .. (arg[0] or "run_all_harnesses.lua") ..
        " [--failure-fixture]\n")
    os.exit(2)
end

for _, harness in ipairs(harnesses) do
    local ok = runHarness(harness)
    if not ok then
        os.exit(1)
    end
end

print("[PASS] " .. #harnesses .. " harnesses")
