local function guest_handler()
	return "guest"
end

local function member_handler(user, next_handler)
	if user.member then return "member" end
	return next_handler(user)
end

local function admin_handler(user, next_handler)
	if user.admin then return "admin" end
	return next_handler(user)
end

local function authorize(user)
	return admin_handler(user, function(next_user)
		return member_handler(next_user, guest_handler)
	end)
end

assert(authorize({ admin = true }) == "admin")
assert(authorize({ member = true }) == "member")
print(authorize({}))
