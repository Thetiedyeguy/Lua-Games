local cardData = {
    {
        name = "Payday",
        type = "currency",
        description = "Gain 3 gold coins.",
        image = love.graphics.newImage("assets/payday.png")
    },
    {
        name = "Chore",
        type = "task",
        description = "Clean the room to earn 2 gold.",
        image = love.graphics.newImage("assets/chore.png")
    },
    {
        name = "Punch",
        type = "attack",
        description = "Deal 3 damage to an opponent.",
        image = love.graphics.newImage("assets/punch.png")
    }
}

return cardData