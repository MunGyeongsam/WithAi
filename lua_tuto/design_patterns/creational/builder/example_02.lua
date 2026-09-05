local function make_config()
    local config = { fullscreen = false }
    local builder = {}
    function builder:width(value) config.width = value; return self end
    function builder:height(value) config.height = value; return self end
    function builder:fullscreen(value) config.fullscreen = value; return self end
    function builder:build()
        assert(config.width and config.height, "width and height are required")
        return { width = config.width, height = config.height, fullscreen = config.fullscreen }
    end
    return builder
end
local config = make_config():width(800):height(600):fullscreen(true):build()
assert(config.width == 800 and config.height == 600 and config.fullscreen)
print(config.width, config.height)
