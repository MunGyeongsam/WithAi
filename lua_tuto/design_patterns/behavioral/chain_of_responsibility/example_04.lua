local function tier3(level)
	if level == "high" then return "tier3" end
	return "unassigned"
end

local function tier2(level)
	if level == "medium" then return "tier2" end
	return tier3(level)
end

local function tier1(level)
	if level == "low" then return "tier1" end
	return tier2(level)
end

assert(tier1("low") == "tier1")
assert(tier1("high") == "tier3")
print(tier1("medium"))
