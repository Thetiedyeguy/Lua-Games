local Card = {}
Card.__index = Card

-- Constants
local BASE_CARD_WIDTH, BASE_CARD_HEIGHT = 90, 120 -- Base dimensions of the card

-- Create a new card
function Card.new(name, type, description, image, x, y, scale, state)
    return setmetatable({
        name = name,
        type = type,
        description = description,
        image = image,
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
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("line", 0, 0, cardWidth, cardHeight)
    love.graphics.setColor(1, 1, 1)
end

function Card:drawCardSkeleton()
    love.graphics.push()
    local cardWidth = BASE_CARD_WIDTH * self.scale
    local cardHeight = BASE_CARD_HEIGHT * self.scale
    self:applyTransformations(cardWidth, cardHeight)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", 0, 0, cardWidth, cardHeight)
    love.graphics.setColor(1, 1, 1)
    love.graphics.pop()
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

    self:drawName(0, 0, cardWidth, cardHeight / 6)
    self:drawImage(0, cardHeight / 6, cardWidth, cardHeight / 3)
    self:drawDescription(0, cardHeight / 2, cardWidth, cardHeight / 3)
    self:drawType(0, (5 * cardHeight) / 6, cardWidth, cardHeight / 6)
end

function Card:drawName(x, y, sectionWIdth, sectionHeight)
    local nameFont = love.graphics.newFont(10 * self.scale)
    love.graphics.printf(self.name, x, y, sectionWIdth, "center")
end

function Card:drawImage(x, y, sectionWIdth, sectionHeight)
    love.graphics.setColor(1, 1, 1, 1)
    if self.image then
        love.graphics.draw(self.image, x + sectionWIdth / 4, y, 0, self.scale / 8, self.scale / 8)
    end
    love.graphics.setColor(0, 0, 0 , 1)
end

function Card:drawDescription(x, y, sectionWIdth, sectionHeight)
    local descriptionFont = love.graphics.newFont(8 * self.scale)
    love.graphics.setFont(descriptionFont)
    local textWidth = descriptionFont:getWidth(self.description)
    local textHeight = descriptionFont:getHeight()
    love.graphics.printf(self.description, x, y + (sectionHeight / 5), sectionWIdth, "center")
end

function Card:drawType(x, y, sectionWIdth, sectionHeight)
    local typeFont = love.graphics.newFont(10 * self.scale)
    love.graphics.setFont(typeFont)
    love.graphics.printf(self.type, x, y, sectionWIdth, "center")
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
    local speed = speed or 14
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
