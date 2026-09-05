local function base_reward(amount)
	return amount + 5
end

local function bonus_reward(amount, next_handler)
	if amount >= 100 then return amount + 20 end
	return next_handler(amount)
end

assert(bonus_reward(100, base_reward) == 120)
print(bonus_reward(50, base_reward))
