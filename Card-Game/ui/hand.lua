local Hand = {}
local Card = require("card")

-- Constructor
function Hand.new(windowScale)
    return setmetatable({
        cards = {}, -- Table to hold cards in the hand
        maxCards = 8,
        windowScale = windowScale,
    }, { __index = Hand })
end

-- Add a card to the hand
function Hand:addCard(card, index)
    table.insert(self.cards, index or (#self.cards + 1), card)
end

-- Remove a card from the hand by index
function Hand:removeCard(index)
    if index > 0 and index <= #self.cards then
        return table.remove(self.cards, index)
    end
    return nil
end

-- Get the size of the hand
function Hand:size()
    return #self.cards
end

-- Draw the hand
function Hand:draw()
    local handSize = #self.cards
    for i, card in ipairs(self.cards) do
        -- Calculate rotation for visual effect
        local rotation = (i - ((handSize + 1) / 2)) * (math.pi / (handSize + 15))
        
        -- Position and scale cards
        card.scale = 2 * self.windowScale
        card.targetX = (((i - ((handSize + 1) / 2)) * 25) + 750) * self.windowScale
        card.targetY = (550 - (i * 3)) * self.windowScale
        
        -- Draw the card with rotation
        card:draw(rotation, "bottom-left")
    end
end

-- Check if a card in the hand is under the mouse pointer
function Hand:mouseOver(x, y)
    for i = #self.cards, 1, -1 do
        if self.cards[i]:mouseOver(x, y) then
            return i
        end
    end
    return nil
end

return Hand
