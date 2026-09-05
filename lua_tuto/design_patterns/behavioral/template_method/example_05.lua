local function authenticate(read_user, check, grant)
	local user = read_user()
	if check(user) then return grant(user) end
	return "denied"
end

local granted = authenticate(
	function() return "admin" end,
	function(user) return user == "admin" end,
	function() return "granted" end
)
local denied = authenticate(
	function() return "guest" end,
	function(user) return user == "admin" end,
	function() return "granted" end
)

assert(granted == "granted" and denied == "denied")
print(granted, denied)
