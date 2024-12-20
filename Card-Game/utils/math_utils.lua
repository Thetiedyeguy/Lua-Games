local MathUtils = {}

-- Calculate the Euclidean distance between two points
function MathUtils.distance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end

-- Clamp a value between a minimum and a maximum
function MathUtils.clamp(value, min, max)
    if value < min then return min end
    if value > max then return max end
    return value
end

-- Linear interpolation between two values
function MathUtils.lerp(a, b, t)
    return a + (b - a) * t
end

-- Check if a value is within a range (inclusive)
function MathUtils.inRange(value, min, max)
    return value >= min and value <= max
end

-- Map a value from one range to another
function MathUtils.map(value, inMin, inMax, outMin, outMax)
    return outMin + ((value - inMin) / (inMax - inMin)) * (outMax - outMin)
end

return MathUtils
