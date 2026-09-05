local discounts = {
    member = function(price) return price * 0.9 end,
    vip = function(price) return price * 0.7 end,
    none = function(price) return price end
}

local pricing = { discount = discounts.none }
function pricing:set_discount(strategy)
    self.discount = strategy
end
function pricing:final_price(price)
    return self.discount(price)
end

pricing:set_discount(discounts.vip)
assert(pricing:final_price(100) == 70)
print(pricing:final_price(100))
