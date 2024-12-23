local Card = require("card")
local Button = require("button")
local Hand = require("ui.hand")
local PlayingArea = require("ui.playing_area")
local Shop = require("ui.shop")
local Deck = require("ui.deck")
local Discard = require("ui.discard")
local Colors = require("utils.colors")
local MathUtils = require("utils.math_utils")

-- Variables
local hand, playingArea, shop
local buttons
local windowScale
local suits = {"Hearts", "Spades", "Diamonds", "Clubs"}
local heldCard, clicked, origin
local cardStartX, cardStartY, mouseStartX, mouseStartY
local well, wellSpace
local blank
local dtotal = 0
local totalHeldTime, totalHandTime, totalShopTime, totalPlayingArea, totalDeckTime, totalDiscardTime, updateTotalTime = 0, 0, 0, 0, 0, 0, 0
local drawHeld, drawHand, drawButton, drawShop, drawPlayingArea, drawDeck, drawDiscard, drawTotal = 0, 0, 0, 0, 0, 0, 0, 0

local CARD_WIDTH, CARD_HEIGHT = 90, 120

-- Load the game
function love.load()
    math.randomseed(os.time())
    initWindowScale()

    -- Initialize components
    hand = Hand.new(windowScale)
    playingArea = PlayingArea.new(windowScale)
    shop = Shop.new(windowScale)
    deck = Deck.new(windowScale)
    discard = Discard.new(windowScale)
    buttons = {}
    blank = Card.new("blank", "none", "if this is shown there is an error", nil, 0, 0, 1.75 * windowScale, "blank")

    -- Add a roll button
    table.insert(buttons, Button.new("Roll", {0, 0, 1, 1}, {1, 1, 1, 1}, 100 * windowScale, 100 * windowScale, 100 * windowScale, 50 * windowScale, windowScale, function()
        shop:roll(suits)
    end))
    table.insert(buttons, Button.new("End Turn", {1, 0, 0, 1}, {1, 1, 1, 1}, 1350 * windowScale, 100 * windowScale, 100 * windowScale, 50 * windowScale, windowScale, function()
        endTurn()
    end))

    -- Populate the shop initially
    shop:roll(suits)
end

-- Adjust for window resizing
function love.resize(w, h)
    local oldScale = windowScale
    initWindowScale()
    rescaleComponents(oldScale, windowScale)
end

-- Update the game
function love.update(dt)
    dtotal = dtotal + dt   -- we add the time passed since the last update, probably a very small number like 0.01
    if dtotal >= 0.02 then
        dtotal = 0   -- reduce our timer by a second, but don't discard the change... what if our framerate is 2/3 of a second?
        local totalTimeStart = love.timer.getTime()
        local startTime = love.timer.getTime()
        if love.mouse.isDown(1) and clicked then
            updateHeldCardPosition()
            updateWell()
        end
        local endTime = love.timer.getTime()
        totalHeldTime = totalHeldTime + endTime - startTime
        startTime = endTime
        updateCardLocations(hand)
        endTime = love.timer.getTime()
        totalHandTime = totalHandTime + endTime - startTime
        startTime = endTime
        updateCardLocations(shop)
        endTime = love.timer.getTime()
        totalShopTime = totalShopTime + endTime - startTime
        startTime = endTime
        updateCardLocations(playingArea)
        endTime = love.timer.getTime()
        totalPlayingArea = totalPlayingArea + endTime - startTime
        startTime = endTime
        updateCardLocations(deck)
        endTime = love.timer.getTime()
        totalDeckTime = totalDeckTime + endTime - startTime
        startTime = endTime
        updateCardLocations(discard)
        endTime = love.timer.getTime()
        totalDiscardTime = totalDiscardTime + endTime - startTime
        local totalTimeEnd = love.timer.getTime()
        updateTotalTime = updateTotalTime + totalTimeEnd - totalTimeStart

        
        if not discardAnimationComplete then
            discardAnimationComplete = checkCardMovementComplete(discard)
            if discardAnimationComplete then
                dealCards(5) -- Deal cards once animation is done
            end
        end

        print("Update Total:", updateTotalTime, "Held:", totalHeldTime / updateTotalTime, ", Hand:", totalHandTime / updateTotalTime, ", Shop:", totalShopTime / updateTotalTime, ", Playing Area:", totalPlayingArea / updateTotalTime, ", Deck:", totalDeckTime / updateTotalTime, ", Discard:", totalDiscardTime / updateTotalTime)
        print()
    end
end

-- Draw the game
function love.draw()
    local totalTimeStart = love.timer.getTime()
    local startTime = love.timer.getTime()
    love.graphics.clear(0.6, 0.9, 1)


    -- Draw UI components
    shop:draw()
    local endTime = love.timer.getTime()
    drawShop = drawShop + endTime - startTime
    startTime = endTime
    playingArea:draw()
    endTime = love.timer.getTime()
    drawPlayingArea = drawPlayingArea + endTime - startTime
    startTime = endTime
    hand:draw()
    endTime = love.timer.getTime()
    drawHand = drawHand + endTime - startTime
    startTime = endTime
    deck:draw()
    endTime = love.timer.getTime()
    drawDeck = drawDeck + endTime - startTime
    startTime = endTime
    discard:draw()
    endTime = love.timer.getTime()
    drawDiscard = drawDiscard + endTime - startTime
    startTime = endTime

    -- Draw buttons
    for _, button in ipairs(buttons) do
        button:draw()
    end
    endTime = love.timer.getTime()
    drawButton = drawButton + endTime - startTime
    startTime = endTime

    -- Draw the held card
    if heldCard then
        heldCard:draw()
    end
    endTime = love.timer.getTime()
    drawHeld = drawHeld + endTime - startTime

    local totalTimeEnd = love.timer.getTime()
    drawTotal = drawTotal + totalTimeEnd - totalTimeStart

    love.graphics.setColor(0, 0, 0)
    love.graphics.print("Update Total:".. math.floor(updateTotalTime + 0.5) .. " Held:".. math.floor(((totalHeldTime / updateTotalTime) * 100)+0.5) .. " Hand:".. math.floor(((totalHandTime / updateTotalTime) * 100)+0.5) .. " Shop:".. math.floor(((totalShopTime / updateTotalTime) * 100)+0.5).. " Playing Area:".. math.floor(((totalPlayingArea / updateTotalTime) * 100)+0.5) .. " Deck:".. math.floor(((totalDeckTime / updateTotalTime) * 100)+0.5).. " Discard:".. math.floor(((totalDiscardTime / updateTotalTime) * 100)+0.5), 20, 5)
    love.graphics.print("Draw Total:".. math.floor(drawTotal + 0.5) .. " Held:".. math.floor(((drawHeld / drawTotal) * 100)+0.5).. " Button:".. math.floor(((drawButton / drawTotal) * 100)+0.5).. " Hand:".. math.floor(((drawHand / drawTotal) * 100)+0.5).. " Shop:".. math.floor(((drawShop / drawTotal) * 100)+0.5).. " Playing Area:".. math.floor(((drawPlayingArea / drawTotal) * 100)+0.5).. " Deck:".. math.floor(((drawDeck / drawTotal) * 100)+0.5).. " Discard:".. math.floor(((drawDiscard / drawTotal) * 100)+0.5), 20, 25)
    print("Draw Total:", drawTotal, "Held:", drawHeld / drawTotal, "Button:", drawButton / drawTotal, ", Hand:", drawHand / drawTotal, ", Shop:", drawShop / drawTotal, ", Playing Area:", drawPlayingArea / drawTotal, ", Deck:", drawDeck / drawTotal, ", Discard:", drawDiscard / drawTotal)
    print()
    print()
end

-- Mouse input handlers
function love.mousepressed(x, y, button)
    if button == 1 then
        local index
        
        -- Try picking a card from discard
        index = checkCardMovementComplete(discard) and discard:mouseOver(x, y)
        if index then
            heldCard = discard:removeCard(index)
            startHoldingCard(x, y, "discard")
            return
        end

        -- Try picking a card from deck
        index = checkCardMovementComplete(deck) and deck:mouseOver(x, y)
        if index then
            heldCard = deck:removeCard(index)
            startHoldingCard(x, y, "deck")
            return
        end

        -- Try picking a card from hand
        index = checkCardMovementComplete(hand) and hand:mouseOver(x, y)
        if index then
            heldCard = hand:removeCard(index)
            startHoldingCard(x, y, "hand")
            return
        end

        -- Try picking a card from shop
        index = checkCardMovementComplete(shop) and shop:mouseOver(x, y)
        if index then
            heldCard = shop:removeCard(index)
            startHoldingCard(x, y, "shop")
            return
        end

        -- Try picking a card from playing area
        index = checkCardMovementComplete(playingArea) and playingArea:mouseOver(x, y)
        if index then
            heldCard = playingArea:removeCard(index)
            startHoldingCard(x, y, "playingArea")
            return
        end

        -- Handle button clicks
        for _, button in ipairs(buttons) do
            if button:mouseOver(x, y) then
                button:click()
                return
            end
        end
    end
    if button == 2 then
        
    end
end

function love.mousereleased(x, y, button)
    if button == 1 and heldCard then
        -- Place the card in the determined well
        if wellSpace == "hand" then
            hand:removeCard(well)
            hand:addCard(heldCard, well)
        elseif wellSpace == "shop" then
            shop:removeCard(well)
            shop:addCard(heldCard, well)
        elseif wellSpace == "playingArea" then
            playingArea:removeCard(well)
            playingArea:addCard(heldCard, well)
        elseif wellSpace == "deck" then
            deck:removeCard(well)
            deck:addCard(heldCard, well)
        elseif wellSpace == "discard" then
            discard:removeCard(well)
            discard:addCard(heldCard, well)
        end
        resetHeldCard()
    end
end

-- Utility Functions
function initWindowScale()
    local windowWidth, windowHeight = love.graphics.getWidth(), love.graphics.getHeight()
    windowScale = math.min(windowWidth / 1536, windowHeight / 801)
end

function rescaleComponents(oldScale, newScale)
    shop.windowScale = windowScale
    for _, card in ipairs(shop.cards) do
        card.scale = (card.scale / oldScale) * newScale
        card.x = (card.x / oldScale) * newScale
        card.y = (card.y / oldScale) * newScale
    end
    hand.windowScale = windowScale
    for _, card in ipairs(hand.cards) do
        card.scale = (card.scale / oldScale) * newScale
        card.x = (card.x / oldScale) * newScale
        card.y = (card.y / oldScale) * newScale
    end
    playingArea.windowScale = windowScale
    for _, card in ipairs(playingArea.cards) do
        card.scale = (card.scale / oldScale) * newScale
        card.x = (card.x / oldScale) * newScale
        card.y = (card.y / oldScale) * newScale
    end
    deck.windowScale = windowScale
    for _, card in ipairs(deck.cards) do
        card.scale = (card.scale / oldScale) * newScale
        card.x = (card.x / oldScale) * newScale
        card.y = (card.y / oldScale) * newScale
    end
    discard.windowScale = windowScale
    for _, card in ipairs(discard.cards) do
        card.scale = (card.scale / oldScale) * newScale
        card.x = (card.x / oldScale) * newScale
        card.y = (card.y / oldScale) * newScale
    end
    for _, button in ipairs(buttons) do
        button.scale = (button.scale / oldScale) * newScale
        button.x = (button.x / oldScale) * newScale
        button.y = (button.y / oldScale) * newScale
    end
end

function updateHeldCardPosition()
    local mouseX, mouseY = love.mouse.getPosition()
    heldCard.x = cardStartX - (mouseStartX - mouseX)
    heldCard.y = cardStartY - (mouseStartY - mouseY)
end

function updateWell()
    local handClosest, playingAreaClosest, shopClosest, deckClosest, discardClosest, minDistance, minDistanceSpace

    -- Remove previous well
    removeFromWell()

    -- Find closest wells
    playingAreaClosest = findClosest(playingArea, windowScale * 537.5, windowScale * 300)
    handClosest = findClosest(hand, windowScale * 750, windowScale * 550)
    shopClosest = findClosest(shop, windowScale * 537.5, windowScale * 50)
    deckClosest = findClosest(deck, windowScale * 200, windowScale * 550)
    discardClosest = findClosest(discard, windowScale * 30, windowScale * 550)

    -- Determine new well
    if origin == "shop" then
        if shopClosest[1] < discardClosest[1] then
            minDistance, minDistanceSpace = shopClosest[2], "shop"
        else
            minDistance, minDistanceSpace = discardClosest[2], "discard"
        end
    elseif origin == "hand" then
        if handClosest[1] < playingAreaClosest[1] or #playingArea.cards >= playingArea.maxCards then
            minDistance, minDistanceSpace = handClosest[2], "hand"
        else
            minDistance, minDistanceSpace = playingAreaClosest[2], "playingArea"
        end
    elseif origin == "deck" then
        minDistance, minDistanceSpace = #deck.cards + 1, "deck"
    elseif origin == "playingArea" then
        minDistance, minDistanceSpace = playingAreaClosest[2], "playingArea"
    elseif origin == "discard" then
        minDistance, minDistanceSpace = discardClosest[2], "discard"
    end

    -- Update well
    well, wellSpace = minDistance or 1, minDistanceSpace or "hand"
    addToWell()
end

function removeFromWell()
    if wellSpace == "hand" then hand:removeCard(well)
    elseif wellSpace == "shop" then shop:removeCard(well)
    elseif wellSpace == "playingArea" then playingArea:removeCard(well)
    elseif wellSpace == "deck" then deck:removeCard(well)
    elseif wellSpace == "discard" then discard:removeCard(well)
    end
end

function addToWell()
    local target = (wellSpace == "hand" and hand.cards) or
                   (wellSpace == "shop" and shop.cards) or
                   (wellSpace == "playingArea" and playingArea.cards) or
                   (wellSpace == "deck" and deck.cards) or
                   (wellSpace == "discard" and discard.cards)
    if well > #target then
        table.insert(target, blank)
    else
        table.insert(target, well, blank)
    end
end

function findClosest(area, defaultX, defaultY)
    local minDistance = {-1, nil}
    local cardCenterX = heldCard.x + CARD_WIDTH / 2 * windowScale
    local lastSlotIndex = #area.cards + 1

    if #area.cards == 0 then
        -- Empty area, return default position
        local dx, dy = cardCenterX - defaultX, heldCard.y - defaultY
        return {math.sqrt(dx * dx + dy * dy), 1}
    end

    for i, slot in ipairs(area.cards) do
        local dx, dy = cardCenterX - slot.x, heldCard.y - slot.y
        local distance = math.sqrt(dx * dx + dy * dy)
        if minDistance[1] == -1 or distance < minDistance[1] then
            minDistance = {distance, i}
        end
    end

    -- Consider space after the last slot
    local lastCard = area.cards[#area.cards]
    local dx, dy = cardCenterX - (lastCard.x + 175 * windowScale), heldCard.y - lastCard.y
    local distance = math.sqrt(dx * dx + dy * dy)
    if distance < minDistance[1] then
        minDistance = {distance, lastSlotIndex}
    end

    return minDistance
end

function startHoldingCard(x, y, source)
    cardStartX, cardStartY = heldCard.x, heldCard.y
    mouseStartX, mouseStartY = x, y
    clicked = true
    origin = source
end

function resetHeldCard()
    heldCard = nil
    clicked = false
    well = nil
    wellSpace = nil
end

function updateCardLocations(area)
    for i, card in ipairs(area.cards) do
        card:moveTowardsTarget()
    end
end

function shuffleDeck()
    while #discard.cards > 0 do
        local randomIndex = math.random(1, #discard.cards)
        local randomCard = discard:removeCard(randomIndex)
        if randomCard then
            randomCard.state = "face-down"
            deck:addCard(randomCard)
        end
    end
end

function endTurn()
    discardAnimationComplete = false -- Start the discard animation
    clearPlayingArea()
end

function dealCards(num)
    for i = 1, num or 1 do
        local drawnCard = nil
        if #deck.cards > 0 then
            drawnCard = deck:removeCard(1)
        elseif #discard.cards ~= 0 then
            shuffleDeck()
            drawnCard = deck:removeCard(1)
        end
        if drawnCard then
            drawnCard.state = "face-up"
            hand:addCard(drawnCard)
        end
    end
end

function clearPlayingArea()
    for i = #playingArea.cards, 1, -1 do
        if playingArea.cards[i].state ~= "blank" then
            local clearedCard = playingArea:removeCard(i)
            discard:addCard(clearedCard)
        end
    end
    for i = #hand.cards, 1, -1 do
        if hand.cards[i].state ~= "blank" then
            local clearedCard = hand:removeCard(i)
            discard:addCard(clearedCard)
        end
    end
end



function checkCardMovementComplete(area)
    for _, card in ipairs(area.cards) do
        if not card:isAtTarget() then
            return false -- If any card is still moving, animation is not complete
        end
    end
    return true -- All cards are at their target positions
end



