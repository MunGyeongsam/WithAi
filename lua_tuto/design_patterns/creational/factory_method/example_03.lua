local Creator = {}
function Creator:create(width, height)
    local shape = self:create_shape(width, height)
    return { type = shape.type, area = shape:area() }
end

local RectangleCreator = setmetatable({}, { __index = Creator })
function RectangleCreator:create_shape(width, height)
    return {
        type = "rectangle",
        area = function() return width * height end
    }
end

local shape = RectangleCreator:create(4, 5)
assert(shape.type == "rectangle" and shape.area == 20)
print(shape.type, shape.area)
