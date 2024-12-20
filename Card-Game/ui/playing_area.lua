local PlayingArea = {}

function PlayingArea.new(windowScale)
    return setmetatable({
        cards = {},
        maxCards = 6,
        windowScale = windowScale,
    }, { __index = PlayingArea })
end

function PlayingArea:addCard(card, index)
    table.insert(self.cards, index or #self.cards, card)
end

function PlayingArea:removeCard(index)
    return table.remove(self.cards, index)
end

function PlayingArea:draw()
    local cardSpacing = 175 * self.windowScale
    local startX = (625 - (175 * (#self.cards / 2))) * self.windowScale
    local startY = 300 * self.windowScale

    for i, card in ipairs(self.cards) do
        card.targetX = startX + i * cardSpacing
        card.targetY = startY
        card.scale = 1.75 * self.windowScale
        card:draw()
    end
end

function PlayingArea:mouseOver(x, y)
    for i, card in ipairs(self.cards) do
        if card:mouseOver(x, y) then
            return i
        end
    end
    return nil
end

return PlayingArea
