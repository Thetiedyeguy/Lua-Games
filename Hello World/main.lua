local curve = love.math.newBezierCurve({25,25, 25,125, 75,25, 125,25})
function love.draw()
	love.graphics.line(curve:render())
end