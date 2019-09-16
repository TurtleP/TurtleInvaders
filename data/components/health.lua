local Health = Component(function(entity, amount)
    entity.amount = amount
    entity.maxAmount = amount
end)

function Health:Add(amount)
    self.amount = math.max(self.amount + amount, 0)
end

function Health:GetAmount()
    return self.amount
end

function Health:GetMax()
    return self.maxAmount
end

return Health
