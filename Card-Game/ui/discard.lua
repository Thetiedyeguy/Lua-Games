local Discard = {}

function Discard.new(windowScale)
    return setmetatable({
        cards = {},
        windowScale = windowScale
    }, {__index = Discard})
end

function Discard:addCard(card, index)
    local x = (25 + #self.cards) * self.windowScale
    local y = 550 * self.windowScale
    card.targetX = x
    card.targetY = y
    card.scale = 1.75 * self.windowScale
    table.insert(self.cards, index or (#self.cards + 1), card)
end

function Discard:removeCard(index)
    return table.remove(self.cards, index)
end

function Discard:draw()
    for i, card in ipairs(self.cards) do
        card.targetX = (25 + i) * self.windowScale
        if i >= #self.cards - 1 then
            card:draw()
        else
            card:drawCardSkeleton()
        end
    end
end

function Discard:mouseOver(x, y)
    if #self.cards > 0 then
        for i = #self.cards, 1, -1 do
            if self.cards[i].state ~= "blank" and self.cards[i]:mouseOver(x, y) then
                return i
            end
        end
    end
    return nil
end

return Discard