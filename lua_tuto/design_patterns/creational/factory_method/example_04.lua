local Creator = {}
function Creator:parse(value)
    return self:create_parser()(value)
end

local NumberParserCreator = setmetatable({}, { __index = Creator })
function NumberParserCreator:create_parser()
    return tonumber
end

local value = NumberParserCreator:parse("42")
assert(value == 42)
print(value)
