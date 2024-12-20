local Deck = {}

function Deck.new(windowScale)
    return setmetatable({
        cards = {},
        windowScale = windowScale
    }, {__index = Deck})
end

function Deck:addCard(card, index)
    local x = (200 + #self.cards) * self.windowScale
    local y = 550 * self.windowScale
    card.scale = 1.75 * self.windowScale
    card.targetX = x
    card.targetY = y
    table.insert(self.cards, index or (#self.cards + 1), card)
end

function Deck:removeCard(index)
    return table.remove(self.cards, index)
end

function Deck:draw()
    for i, card in ipairs(self.cards) do
        card.targetX = (200 + i) * self.windowScale
        card.targetY = 550 * self.windowScale
        card:draw()
    end
end

function Deck:mouseOver(x, y)
    if #self.cards > 0 then
        for i = #self.cards, 1, -1 do
            if self.cards[i].state ~= "blank" then
                if self.cards[i]:mouseOver(x, y) then
                    return i
                else
                    return nil
                end
            end
        end
    end
    return nil
end

return Deck