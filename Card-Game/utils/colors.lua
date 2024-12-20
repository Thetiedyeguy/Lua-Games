local Colors = {}

-- Lighten a color by a given factor
function Colors.lighten(color, factor)
    factor = math.min(factor, 1) -- Clamp factor to a maximum of 1
    return {
        math.min(color[1] + (1 - color[1]) * factor, 1),
        math.min(color[2] + (1 - color[2]) * factor, 1),
        math.min(color[3] + (1 - color[3]) * factor, 1),
        color[4] or 1, -- Preserve alpha if provided
    }
end

-- Darken a color by a given factor
function Colors.darken(color, factor)
    factor = math.min(factor, 1) -- Clamp factor to a maximum of 1
    return {
        math.max(color[1] * (1 - factor), 0),
        math.max(color[2] * (1 - factor), 0),
        math.max(color[3] * (1 - factor), 0),
        color[4] or 1, -- Preserve alpha if provided
    }
end

-- Blend two colors together
function Colors.blend(color1, color2, ratio)
    ratio = math.min(math.max(ratio, 0), 1) -- Clamp ratio between 0 and 1
    return {
        color1[1] * (1 - ratio) + color2[1] * ratio,
        color1[2] * (1 - ratio) + color2[2] * ratio,
        color1[3] * (1 - ratio) + color2[3] * ratio,
        color1[4] * (1 - ratio) + color2[4] * ratio,
    }
end

-- Convert a color from RGB to grayscale
function Colors.toGrayscale(color)
    local gray = 0.3 * color[1] + 0.59 * color[2] + 0.11 * color[3]
    return {gray, gray, gray, color[4] or 1}
end

return Colors
