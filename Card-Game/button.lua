local Button = {}
Button.__index = Button

-- Constructor
function Button.new(text, backgroundColor, textColor, x, y, width, length, scale, onClick)
    return setmetatable({
        text = text,
        backgroundColor = backgroundColor or {0, 0, 1, 1},
        textColor = textColor or {1, 1, 1, 1},
        x = x,
        y = y,
        width = width,
        length = length,
        scale = scale,
        onClick = onClick,
    }, Button)
end

-- Check if the mouse is over the button
function Button:mouseOver(mouseX, mouseY)
    return mouseX > self.x and mouseX < self.x + self.width * self.scale and
           mouseY > self.y and mouseY < self.y + self.length * self.scale
end

-- Draw the button
function Button:draw()
    local font = love.graphics.newFont(20 * self.scale)
    love.graphics.setFont(font)

    local mouseX, mouseY = love.mouse.getPosition()
    if self:mouseOver(mouseX, mouseY) then
        love.graphics.setColor(self:lightenColor(self.backgroundColor, 0.3))
    else
        love.graphics.setColor(self.backgroundColor)
    end

    -- Draw button background
    love.graphics.rectangle("fill", self.x, self.y, self.width * self.scale, self.length * self.scale)

    -- Draw button border
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", self.x, self.y, self.width * self.scale, self.length * self.scale)

    -- Draw button text
    love.graphics.setColor(self.textColor)
    love.graphics.print(self.text, self.x + 10, self.y + 10)
end

-- Handle button click
function Button:click()
    if self.onClick then
        self.onClick(self)
    end
end

-- Lighten a color by a given factor
function Button:lightenColor(color, factor)
    factor = math.min(factor, 1) -- Clamp factor to a maximum of 1
    return {
        math.min(color[1] + (1 - color[1]) * factor, 1),
        math.min(color[2] + (1 - color[2]) * factor, 1),
        math.min(color[3] + (1 - color[3]) * factor, 1),
        color[4] or 1, -- Preserve alpha if provided
    }
end

return Button
