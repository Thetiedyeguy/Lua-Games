local Card = {}
Card.__index = Card

-- Constants
local BASE_CARD_WIDTH, BASE_CARD_HEIGHT = 90, 120 -- Base dimensions of the card

-- Create a new card
function Card.new(suit, rank, x, y, scale, state)
    return setmetatable({
        suit = suit,
        rank = rank,
        x = x,
        y = y,
        targetX = x,
        targetY = y,
        scale = scale,
        rotation = 0,
        targetRotation = 0,
        rotationPoint = "center",
        state = state or "face-up",
    }, Card)
end

-- Get a display name for the card
function Card:getName()
    return self.rank .. " of " .. self.suit
end

-- Draw the card
function Card:draw(rotation, rotationPoint)
    self.rotation = rotation or 0
    self.rotationPoint = rotationPoint or "center"

    local cardWidth = BASE_CARD_WIDTH * self.scale
    local cardHeight = BASE_CARD_HEIGHT * self.scale

    love.graphics.push()
    self:applyTransformations(cardWidth, cardHeight)

    -- Draw the card
    if self.state == "blank" then
        self:drawBlankCard(cardWidth, cardHeight)
    elseif self.state == "face-down" then
        self:drawFaceDownCard(cardWidth, cardHeight)
    else
        self:drawRegularCard(cardWidth, cardHeight)
    end

    love.graphics.pop()
end

-- Apply transformations for rotation and scaling
function Card:applyTransformations(cardWidth, cardHeight)
    if self.rotationPoint == "center" then
        love.graphics.translate(self.x + cardWidth / 2, self.y + cardHeight / 2)
        love.graphics.rotate(self.rotation)
        love.graphics.translate(-cardWidth / 2, -cardHeight / 2)
    elseif self.rotationPoint == "bottom-left" then
        love.graphics.translate(self.x, self.y + cardHeight)
        love.graphics.rotate(self.rotation)
        love.graphics.translate(0, -cardHeight)
    end
end

-- Draw a blank card
function Card:drawBlankCard(cardWidth, cardHeight)
    -- love.graphics.setColor(1, 0, 0)
    -- love.graphics.rectangle("line", 0, 0, cardWidth, cardHeight)
    -- love.graphics.setColor(1, 1, 1)
end

function Card:drawFaceDownCard(cardWidth, cardHeight)
    love.graphics.setColor(0, 0, 1)
    love.graphics.rectangle("fill", 0, 0, cardWidth, cardHeight)
    for x = 0, cardWidth - cardWidth/3, cardWidth/3 do
        for y = 0, cardHeight - cardHeight/3, cardHeight/3 do
            love.graphics.setColor(1, 0, 0)
            love.graphics.polygon("fill", x, y + cardHeight / 6 , x +cardWidth / 6, y, x + cardWidth / 3, y + cardHeight / 6, x + cardWidth / 6, y + cardHeight / 3)
            love.graphics.setColor(1, 1, 1)
            love.graphics.polygon("line", x, y + cardHeight / 6 , x +cardWidth / 6, y, x + cardWidth / 3, y + cardHeight / 6, x + cardWidth / 6, y + cardHeight / 3)
        end
    end
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", 0, 0, cardWidth, cardHeight)
    love.graphics.setColor(1, 1, 1)
end

-- Draw a regular card
function Card:drawRegularCard(cardWidth, cardHeight)
    -- Card background
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, cardWidth, cardHeight)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", 0, 0, cardWidth, cardHeight)

    -- Card number and suit color
    local fontSize = 10 * self.scale
    local font = love.graphics.newFont(fontSize)
    love.graphics.setFont(font)
    love.graphics.setColor(self:getSuitColor())
    self:drawSuit(8 * self.scale, 21 * self.scale, 0.25 * self.scale)

    self:drawCardRank()
    self:drawCardSuits()
end

-- Get the color based on the suit
function Card:getSuitColor()
    if self.suit == "Clubs" or self.suit == "Spades" then
        return {0, 0, 0} -- Black
    else
        return {1, 0, 0} -- Red
    end
end

-- Draw the rank of the card
function Card:drawCardRank()
    local rankSymbols = { [1] = "A", [11] = "J", [12] = "Q", [13] = "K" }
    local rank = rankSymbols[self.rank] or tostring(self.rank)
    love.graphics.print(rank, 5 * self.scale, 5 * self.scale)
end

-- Draw the card's suit symbols
function Card:drawCardSuits()
    local suitPositions = self:getSuitPositions()

    for _, pos in ipairs(suitPositions) do
        self:drawSuit(pos.x, pos.y, pos.scale)
    end
end

-- Get positions for suit symbols based on rank
function Card:getSuitPositions()
    local positions = {
        [1] = { {x = 45, y = 60, scale = 1} },
        [2] = { {x = 45, y = 25, scale = 0.5}, {x = 45, y = 95, scale = 0.5} },
        [3] = { {x = 45, y = 25, scale = 0.5}, {x = 45, y = 60, scale = 0.5}, {x = 45, y = 95, scale = 0.5} },
        [4] = { {x = 25, y = 25, scale = 0.5}, {x = 25, y = 95, scale = 0.5}, {x = 65, y = 25, scale = 0.5}, {x = 65, y = 95, scale = 0.5} },
        [5] = { {x = 25, y = 25, scale = 0.5}, {x = 25, y = 95, scale = 0.5}, {x = 65, y = 25, scale = 0.5}, {x = 65, y = 95, scale = 0.5}, {x = 45, y = 60, scale = 0.5} },
        [6] = { {x = 25, y = 25, scale = 0.5}, {x = 25, y = 95, scale = 0.5}, {x = 65, y = 25, scale = 0.5}, {x = 65, y = 95, scale = 0.5}, {x = 25, y = 60, scale = 0.5}, {x = 65, y = 60, scale = 0.5} },
        [7] = { {x = 25, y = 25, scale = 0.5}, {x = 25, y = 95, scale = 0.5}, {x = 65, y = 25, scale = 0.5}, {x = 65, y = 95, scale = 0.5}, {x = 25, y = 60, scale = 0.5}, {x = 65, y = 60, scale = 0.5}, {x = 45, y = 45, scale = 0.5} },
        [8] = { {x = 25, y = 25, scale = 0.5}, {x = 25, y = 95, scale = 0.5}, {x = 65, y = 25, scale = 0.5}, {x = 65, y = 95, scale = 0.5}, {x = 25, y = 60, scale = 0.5}, {x = 65, y = 60, scale = 0.5}, {x = 45, y = 45, scale = 0.5}, {x = 45, y = 75, scale = 0.5} },
        [9] = { {x = 25, y = 25, scale = 0.5}, {x = 25, y = 95, scale = 0.5}, {x = 65, y = 25, scale = 0.5}, {x = 65, y = 95, scale = 0.5}, {x = 25, y = 50, scale = 0.5}, {x = 25, y = 70, scale = 0.5}, {x = 65, y = 50, scale = 0.5}, {x = 65, y = 70, scale = 0.5}, {x = 45, y = 60, scale = 0.5} },
        [10] = { {x = 25, y = 25, scale = 0.5}, {x = 25, y = 95, scale = 0.5}, {x = 65, y = 25, scale = 0.5}, {x = 65, y = 95, scale = 0.5}, {x = 25, y = 50, scale = 0.5}, {x = 25, y = 70, scale = 0.5}, {x = 65, y = 50, scale = 0.5}, {x = 65, y = 70, scale = 0.5}, {x = 45, y = 37, scale = 0.5}, {x = 45, y = 83, scale = 0.5} },
    }
    

    -- Scale positions and return them
    local scaledPositions = {}
    for _, pos in ipairs(positions[self.rank] or {}) do
        table.insert(scaledPositions, {
            x = pos.x * self.scale,
            y = pos.y * self.scale,
            scale = pos.scale * self.scale,
        })
    end
    return scaledPositions
end

-- Draw a suit symbol
function Card:drawSuit(x, y, scale)
    local size = 20 * scale

    if self.suit == "Clubs" then
        self:drawClub(x, y, size)
    elseif self.suit == "Spades" then
        self:drawSpade(x, y, size)
    elseif self.suit == "Hearts" then
        self:drawHeart(x, y, size)
    elseif self.suit == "Diamonds" then
        self:drawDiamond(x, y, size)
    end
end

function Card:drawClub(x, y, size)
    love.graphics.circle("fill", x, y - size * 0.5, size * 0.5)
    love.graphics.circle("fill", x - size * 0.4, y + size * 0.2, size * 0.5)
    love.graphics.circle("fill", x + size * 0.4, y + size * 0.2, size * 0.5)
    love.graphics.rectangle("fill", x - size * 0.1, y + size * 0.5, size * 0.2, size * 0.6)
end

-- Draw a spade
function Card:drawSpade(x, y, size)
    x = x - size * 0.1
    -- Spades: Inverted heart with a stem
    love.graphics.polygon("fill", 
        x, y - size, -- Top point
        x - size * 0.6, y + size * 0.2, -- Bottom left curve
        x + size * 0.6, y + size * 0.2  -- Bottom right curve
    )
    love.graphics.circle("fill", x - size * 0.3, y + size * 0.2, size * 0.275, 40) -- Left curve
    love.graphics.circle("fill", x + size * 0.3, y + size * 0.2, size * 0.275, 40) -- Right curve
    love.graphics.rectangle("fill", x - size * 0.1, y + size * 0.2, size * 0.2, size * 0.6) -- Stem
end

-- Draw a heart
function Card:drawHeart(x, y, size)
    -- Hearts: Two circles and a triangle
    love.graphics.arc("fill", x - size * 0.4, y - size * 0.2, size * 0.4, math.pi,  2* math.pi) -- Left circle
    love.graphics.arc("fill", x + size * 0.4, y - size * 0.2, size * 0.4, math.pi, 2 * math.pi) -- Right circle
    love.graphics.polygon("fill", 
        x, y + size * 0.6, -- Bottom point
        x - size * 0.8, y - size * 0.2, -- Left point
        x + size * 0.8, y - size * 0.2  -- Right point
    )
    local leftCurve = love.math.newBezierCurve({x, y + size * 0.6, x - size * 0.7, y + size * 0.2,  x - size * 0.8, y - size * 0.2})
    local rightCurve = love.math.newBezierCurve({x, y + size * 0.6, x + size * 0.7, y + size * 0.2,  x + size * 0.8, y - size * 0.2})

    love.graphics.polygon("fill", leftCurve:render())
    love.graphics.polygon("fill", rightCurve:render())
end

-- Draw a diamond
function Card:drawDiamond(x, y, size)
    love.graphics.polygon("fill", x, y - size, x - size * 0.6, y, x, y + size, x + size * 0.6, y)
end

-- Detect if the mouse is over the card
function Card:mouseOver(x, y)
    local cardWidth = BASE_CARD_WIDTH * self.scale
    local cardHeight = BASE_CARD_HEIGHT * self.scale
    local originX, originY = self:getOrigin(cardWidth, cardHeight)

    local dx = x - originX
    local dy = y - originY
    local rotatedX = dx * math.cos(-self.rotation) - dy * math.sin(-self.rotation)
    local rotatedY = dx * math.sin(-self.rotation) + dy * math.cos(-self.rotation)
    if self.rotationPoint == "center" then
        return rotatedX > -(cardWidth / 2) and rotatedX < (cardWidth / 2) and rotatedY > -(cardHeight / 2) and rotatedY < (cardHeight / 2)
    elseif self.rotationPoint == "bottom-left" then
        return rotatedX > 0 and rotatedX < cardWidth and rotatedY > -cardHeight and rotatedY < 0
    end
end

-- Get origin for rotation
function Card:getOrigin(cardWidth, cardHeight)
    if self.rotationPoint == "center" then
        return self.x + cardWidth / 2, self.y + cardHeight / 2
    elseif self.rotationPoint == "bottom-left" then
        return self.x, self.y + cardHeight
    end
end

function Card:moveTowardsTarget(speed)
    local speed = speed or 7
    if self.x ~= self.targetX or self.y ~= self.targetY then
        if self.suit == "blank" then
            self.x, self.y = self.targetX, self.targetY
        end
        local dx = self.targetX - self.x
        local dy = self.targetY - self.y
        local magnitude = math.sqrt((dx * dx) + (dy * dy))
        if magnitude > speed then
            self.x = self.x + (speed * (dx / magnitude))
            self.y = self.y + (speed * (dy / magnitude))
        else
            self.x = self.targetX
            self.y = self.targetY
        end
    end
    if self.rotation ~= self.targetRotation then
        local delta = self.targetRotation - self.rotation
        if delta > 1 then
            self.rotation = self.rotation + speed
        elseif delta < -1 then
            self.rotation = self.rotation - speed
        else
            self.rotation = self.targetRotation
        end
    end
end

function Card:isAtTarget()
    local epsilon = 1 -- Allow for small inaccuracies in position
    return math.abs(self.x - self.targetX) <= epsilon and math.abs(self.y - self.targetY) <= epsilon
end

return Card
