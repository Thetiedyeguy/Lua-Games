-- Define the grid size
local gridSize = 20
local gridWidth, gridHeight
local snake, food
local direction, nextDirection
local gameOver
local score -- Add a score variable
local foodSize
local change
local gameState

function love.load()
    -- Set the window size
    love.window.setMode(400, 400)

    gameState = "start"
    
    foodSize = gridSize / 2
    change = -1 * gridSize / 2048

    gridWidth = love.graphics.getWidth() / gridSize
    gridHeight = love.graphics.getHeight() / gridSize
    
    -- Initialize the snake
    snake = { {x = 5, y = 5} }
    direction = {x = 1, y = 0}
    nextDirection = direction
    
    -- Initialize the score
    score = 0 -- Initialize the score to 0
    
    -- Spawn the first food
    spawnFood()
    
    gameOver = false
end

function love.update(dt)
    if gameOver then return end

    -- Move the snake every 0.2 seconds
    if love.timer.getTime() % 0.2 < dt then
        moveSnake()
    end
end

function love.draw()
    if gameState == "start" then
        love.graphics.printf("Press space to start", 0, love.graphics.getHeight()/2, love.graphics.getWidth()/2, "center")
    else
        -- Set a background color
        love.graphics.clear(0.1, 0.1, 0.1) -- Dark gray background
        
        love.graphics.setColor(0.3, 0.3, 0.3) -- Light gray grid
        for x = 0, gridWidth do
            love.graphics.line(x * gridSize, 0, x * gridSize, love.graphics.getHeight())
        end
        for y = 0, gridHeight do
            love.graphics.line(0, y * gridSize, love.graphics.getWidth(), y * gridSize)
        end
        love.graphics.setColor(1, 1, 1) -- Reset to white

        -- Use a different color for the snake
        love.graphics.setColor(0, 1, 0) -- Green
        for _, segment in ipairs(snake) do
            love.graphics.circle("fill", (segment.x - 0.5) * gridSize, (segment.y - 0.5) * gridSize, gridSize/2)
        end

        -- Use a contrasting color for the food
        
        love.graphics.setColor(1, 0, 0) -- Red
        love.graphics.circle("fill", (food.x - 0.5) * gridSize, (food.y - 0.5) * gridSize, foodSize)
        love.graphics.setColor(1, 1, 1) -- Reset to white

        foodSize = foodSize + change
        if foodSize >= gridSize/2 or foodSize <= 5 * gridSize/12 then change = -1 * change end


        -- Draw the score
        love.graphics.print("Score: " .. score, 10, 10) -- Display score in the top-left corner

        -- Draw game over text
        if gameOver then
            love.graphics.printf("Game Over! Press R to Restart", 0, love.graphics.getWidth() / 2, love.graphics.getHeight(), "center")
        end
    end
end

function love.keypressed(key)
    -- Change direction
    if key == "space" and gameState == "start" then gameState = "play" end
    if key == "up" and direction.y == 0 and gameState == "play" then nextDirection = {x = 0, y = -1} end
    if key == "down" and direction.y == 0 and gameState == "play" then nextDirection = {x = 0, y = 1} end
    if key == "left" and direction.x == 0 and gameState == "play" then nextDirection = {x = -1, y = 0} end
    if key == "right" and direction.x == 0 and gameState == "play" then nextDirection = {x = 1, y = 0} end

    -- Restart the game
    if key == "r" then love.load() end
end

function moveSnake()
    -- Update direction
    direction = nextDirection

    -- Create a new head
    local head = snake[1]
    local newHead = {x = head.x + direction.x, y = head.y + direction.y}

    -- Check for collisions
    if newHead.x < 1 or newHead.y < 1 or newHead.x > gridWidth or newHead.y > gridHeight then
        gameOver = true
        return
    end
    for _, segment in ipairs(snake) do
        if segment.x == newHead.x and segment.y == newHead.y then
            gameOver = true
            return
        end
    end

    -- Add the new head
    table.insert(snake, 1, newHead)

    -- Check if food is eaten
    if newHead.x == food.x and newHead.y == food.y then
        score = score + 1 -- Increment the score
        spawnFood()
    else
        -- Remove the tail
        table.remove(snake)
    end
end

function spawnFood()
    food = {x = love.math.random(1, gridWidth), y = love.math.random(1, gridHeight)}
end
