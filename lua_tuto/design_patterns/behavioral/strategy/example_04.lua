local payment_methods = {
    coin = function(amount) return "동전 " .. amount .. "개" end,
    card = function(amount) return "카드 승인 " .. amount end
}

local checkout = { payment = nil }
function checkout:set_payment(strategy)
    self.payment = strategy
end
function checkout:pay(amount)
    return self.payment(amount)
end

checkout:set_payment(payment_methods.card)
assert(checkout:pay(20) == "카드 승인 20")
print(checkout:pay(20))
