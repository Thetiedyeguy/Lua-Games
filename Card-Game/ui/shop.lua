local Shop = {}
local Card = require("card") -- Ensure Card is required here

function Shop.new(windowScale)
    return setmetatable({
        cards = {},
        maxCards = 6,
        windowScale = windowScale,
    }, { __index = Shop })
end

-- Roll new cards for the shop
function Shop:roll(suits)
    self.cards = {}
    for i = 1, self.maxCards do
        local suit = suits[math.random(#suits)]
        local rank = math.random(1, 10)
        local x = self.windowScale * ((i * 175) + (625 - (175 * ((self.maxCards - 1) / 2))))
        local y = self.windowScale * 50
        local scale = self.windowScale * 1.75
        self:addCard(Card.new(suit, rank, x, y, scale))
    end
end

-- Add a card to the shop
function Shop:addCard(card, index)
    if #self.cards < self.maxCards then
        table.insert(self.cards, index or #self.cards + 1, card)
    else
        print("Shop is full. Cannot add more cards.")
    end
end

-- Remove a card from the shop by index
function Shop:removeCard(index)
    return table.remove(self.cards, index)
end

-- Draw the shop
function Shop:draw()
    for i, card in ipairs(self.cards) do
        card.targetX = self.windowScale * ((i * 175) + (625 - (175 * (#self.cards / 2))))
        card.targetY = self.windowScale * 50
        card.scale = 1.75 * self.windowScale
        card:draw()
    end
end

-- Check if the mouse is hovering over any card in the shop
function Shop:mouseOver(x, y)
    for i, card in ipairs(self.cards) do
        if card:mouseOver(x, y) then
            return i
        end
    end
    return nil
end

return Shop
