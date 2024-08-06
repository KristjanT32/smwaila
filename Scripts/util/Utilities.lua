-- Gets the part of a color's hex code that can be used for formatting.
--- @param color Color The color to get the formatting string of.
--- @return string formatting_string The string that can be used for formatting.
function getFormattingColorString(color)
    return "#" .. string.sub(color:getHexStr(), 1, 6)
end

-- Formats a given Vector3 to the following format: `(x, y, z)`
--- @param vec3 Vec3 The vector to format.
function formatVector(vec3)
    if (vec3 == nil) then return "(0 0 0)" end
    return "(" .. vec3.x .. " " .. vec3.y .. " " .. vec3.z .. ")"
end

-- Returns the size of a given table.
--- @param table table The table to inspect.
--- @return integer size The size of the table.
function sizeof(table)
    if (table == nil) then return 0 end
    local size = 0
    for _, _ in pairs(table) do
        size = size + 1
    end
    return size
end

function table.size(table)
    return sizeof(table)
end

function table.hasValue(table, value)
    return containsValue(table, value)
end

--- Returns `true` if the provided value is in `table`. Provides false otherwise.
--- @param table table The table to inspect
--- @param value any The value to check for.
---@return boolean found Whether the value is within `table`
function containsValue(table, value)
    for k, v in pairs(table) do
        if (v == value) then
            return true
        end
    end
    return false
end

-- Gets the Vector3 from the coords formatted with `formatVector(vec3)`
--- @param formatted_coords string The formatted coords
function vec3FromFormattedCoords(formatted_coords)
    local coords = {}
    local sanitized = formatted_coords:gsub("%(", "")
    sanitized = sanitized:gsub("%)", "")
    for match in sanitized:gmatch("%S+") do
        table.insert(coords, match)
    end

    return sm.vec3.new(tonumber(coords[1], 10), tonumber(coords[2], 10), tonumber(coords[3], 10))
end

--- @param shape Shape
function blocksInShape(shape)
    return (shape:getBoundingBox().x / 0.25) * (shape:getBoundingBox().y / 0.25) * (shape:getBoundingBox().z / 0.25)
end
