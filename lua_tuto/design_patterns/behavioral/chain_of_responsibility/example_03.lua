local function validate_number(value, next_handler)
	if type(value) ~= "number" then return "invalid type" end
	return next_handler(value)
end

local function validate_positive(value, next_handler)
	if value <= 0 then return "not positive" end
	return next_handler(value)
end

local function accepted()
	return "accepted"
end

assert(validate_number(5, function(value)
	return validate_positive(value, accepted)
end) == "accepted")
print(validate_number("5", function(value)
	return validate_positive(value, accepted)
end))
