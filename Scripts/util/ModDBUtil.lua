dofile("$CONTENT_40639a2c-bb9f-4d4f-b88c-41bfe264ffa8/Scripts/ModDatabase.lua")

---@class ModDBUtil
ModDBUtil = class(nil)

---@type boolean Whether the databases have been loaded.
ModDBUtil.loaded = false

---@type table<string, table> Stores cached results for mod info queries mapped to the string UUIDs of the shapes.
ModDBUtil.cachedQueries = {}

---@type table<string, table> Stores cached shape ratings mapped to their UUID strings.
ModDBUtil.cachedRatings = {}


function ModDBUtil.init(self)
    local start = os.clock()
    print("Loading ModDB databases...")
    ModDatabase.loadDescriptions()
    ModDatabase.loadShapesets()
    ModDatabase.loadToolsets()
    ModDatabase.loadHarvestablesets()
    ModDatabase.loadKinematicsets()
    ModDatabase.loadCharactersets()
    ModDatabase.loadScriptableobjectsets()
    print("Database loading finished in " .. clockTimeToMillis(os.clock() - start) .. "ms")
    self.loaded = true
end

local function hasBlockList(shapeset)
    return shapeset["blockList"] ~= nil
end

local function hasPartList(shapeset)
    return shapeset["partList"] ~= nil
end

--- Checks if the supplied UUID is in the `cachedRatings` table.
--- If it is not, the shape must be modded.
--- If it is, it is vanilla.
---@param self ModDBUtil
---@param cachedRatings table<string, table>
---@param uuid Uuid
function ModDBUtil.isModded(self, cachedRatings, uuid)
    return not containsKey(cachedRatings, tostring(uuid))
end

function ModDBUtil.getModNameByLocalId(self, localId)
    if (not self.loaded) then self:init() end
    return ModDatabase.databases.descriptions[localId].name
end

--- Returns a table of information about the object with the supplied UUID.
--- Returns nil, if no such object could be found.
---@param uuid Uuid The UUID of the object to look up.
function ModDBUtil.getModInfo(self, uuid)
    if (self.cachedQueries[tostring(uuid)] ~= nil) then
        return self.cachedQueries[tostring(uuid)]
    else
        print("Current target not cached - searching database")
    end

    for _, modLocalId in pairs(ModDatabase.getAllLoadedMods()) do
        if ModDatabase.databases.shapesets[modLocalId] == nil then goto skip end
        for shapeset, shapes in pairs(ModDatabase.databases.shapesets[modLocalId]) do
            for _, shapeUuid in pairs(shapes) do
                if (sm.uuid.new(shapeUuid) == uuid) then
                    local opened_shapeset = sm.json.open(shapeset)
                    local ratings = {}
                    if (opened_shapeset["blockList"] ~= nil) then
                        for _, value in pairs(opened_shapeset["blockList"]) do
                            if (value.uuid == uuid) then
                                ratings = value.ratings
                                break
                            end
                        end
                    end

                    self.cachedQueries[tostring(uuid)] = {
                        modName = self:getModNameByLocalId(modLocalId),
                        ratings = ratings
                    }
                    return {
                        modName = self:getModNameByLocalId(modLocalId),
                        ratings = ratings
                    }
                end
            end
        end
        ::skip::
    end
end

--- Gets the ratings for the supplied shape.
---@param self ModDBUtil
---@param shape Shape The shape to look up ratings for
---@return table The ratings table.
function ModDBUtil.getShapeRatings(self, shape)
    if (self.cachedRatings[tostring(shape.uuid)] ~= nil) then
        if (self.cachedRatings[tostring(shape.uuid)]["ratings"] ~= nil) then
            return self.cachedRatings[tostring(shape.uuid)].ratings
        end
    end
    local uuid = shape.uuid
    for _, modLocalId in pairs(ModDatabase.getAllLoadedMods()) do
        if ModDatabase.databases.shapesets[modLocalId] == nil then goto skip end
        for shapeset, shapes in pairs(ModDatabase.databases.shapesets[modLocalId]) do
            for _, shapeUuid in pairs(shapes) do
                if (sm.uuid.new(shapeUuid) == uuid) then
                    local _shapeset = sm.json.open(shapeset)

                    if (hasBlockList(_shapeset)) then
                        for _, entry in pairs(_shapeset["blockList"]) do
                            if (entry.uuid == tostring(uuid)) then
                                if (entry.ratings ~= nil) then
                                    self.cachedRatings[tostring(uuid)] = {
                                        modName = self:getModNameByLocalId(modLocalId),
                                        ratings = entry.ratings
                                    }
                                    return entry.ratings
                                end
                            end
                        end
                    end

                    if (hasPartList(_shapeset)) then
                        for _, entry in pairs(_shapeset["partList"]) do
                            if (entry.uuid == tostring(uuid)) then
                                if (entry.ratings ~= nil) then
                                    self.cachedRatings[tostring(uuid)] = {
                                        modName = self:getModNameByLocalId(modLocalId),
                                        ratings = entry.ratings
                                    }
                                    return entry.ratings
                                end
                            end
                        end
                    end
                end
            end
        end
        ::skip::
    end
    if (self.cachedRatings[tostring(uuid)] == nil) then
        print("Couldn't find ratings for " ..
            tostring(uuid) .. ". Returning all available vanilla ratings.")
        self.cachedRatings[tostring(uuid)] = {
            buoyancy = shape:getBuoyancy(),
            durability = sm.item.getQualityLevel(uuid)
        }
    end
    return self.cachedRatings[tostring(uuid)]
end
