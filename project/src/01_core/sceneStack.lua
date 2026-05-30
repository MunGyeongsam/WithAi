local SceneStack = {}
SceneStack.__index = SceneStack

function SceneStack.new()
    local self = setmetatable({}, SceneStack)
    self.stack = {}
    return self
end

function SceneStack:top()
    return self.stack[#self.stack]
end

function SceneStack:push(scene)
    scene._stack = self
    self.stack[#self.stack + 1] = scene
    if scene.onEnter then
        scene:onEnter()
    end
end

function SceneStack:pop()
    local scene = self.stack[#self.stack]
    if not scene then
        return nil
    end

    if scene.onExit then
        scene:onExit()
    end

    self.stack[#self.stack] = nil
    return scene
end

function SceneStack:replace(scene)
    self:pop()
    self:push(scene)
end

function SceneStack:update(dt)
    local scene = self:top()
    if scene and scene.update then
        scene:update(dt)
    end
end

function SceneStack:draw()
    for i = 1, #self.stack do
        local scene = self.stack[i]
        if scene and scene.draw then
            scene:draw()
        end
    end
end

function SceneStack:keypressed(key, scancode)
    local scene = self:top()
    if scene and scene.keypressed then
        scene:keypressed(key, scancode)
    end
end

function SceneStack:setInputSnapshot(snapshot)
    local scene = self:top()
    if scene and scene.setInputSnapshot then
        scene:setInputSnapshot(snapshot)
    end
end

function SceneStack:resize(width, height)
    for i = 1, #self.stack do
        local scene = self.stack[i]
        if scene and scene.resize then
            scene:resize(width, height)
        end
    end
end

return SceneStack
