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
    if (table == nil) then return 0 end
    return sizeof(table)
end

function table.hasValue(table, value)
    if (table == nil) then return false end
    return containsValue(table, value)
end

function table.hasKey(table, key)
    if (table == nil) then return false end
    return containsKey(table, key)
end

--- Returns `true` if the provided value is in `table`. Returns false otherwise.
--- @param _table table The table to inspect
--- @param value any The value to check for.
---@return boolean found Whether the value is within `table`
function containsValue(_table, value)
    for k, v in pairs(_table) do
        if (v == value) then
            return true
        end
    end
    return false
end

--- Returns `true` if the provided key is in `table`. Returns false otherwise.
--- @param _table table The table to inspect
--- @param value any The key to check for.
---@return boolean found Whether the key is within `table`
function containsKey(_table, key)
    return _table[key] ~= nil
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

--- Returns a formatted string representing an escaped color sequence for the provided color.
---@param color Color The color to format a hex string for.
function formatColorHex(color)
    local str = color:getHexStr()
    str = str:sub(0, str:len() - 2)
    return "##" .. str:upper()
end

--- @param shape Shape
function blocksInShape(shape)
    return (shape:getBoundingBox().x / 0.25) * (shape:getBoundingBox().y / 0.25) * (shape:getBoundingBox().z / 0.25)
end

--- Returns a string with only its first letter capitalized.
---@param str string The string to capitalize.
---@return string capitalized A capitalized string.
function string.capitalize(str)
    if (str == nil) then
        return ""
    end
    local capitalized = str:lower()
    return string.sub(capitalized, 1, 1):upper() .. string.sub(capitalized, 2, capitalized:len())
end

function string.count(str, sequence)
    local matches = 0
    for k, v in str:gmatch(sequence) do
        matches = matches + 1
    end
    return matches
end

function clockTimeToMillis(number)
    return math.ceil(number * 1000)
end

function log(msg, isError)
    if (isError == nil) then isError = false end
    if (not isError) then
        print("[SMWAILA/INFO]: " .. msg)
    else
        print("[SMWAILA/ERROR]: " .. msg)
    end
end
