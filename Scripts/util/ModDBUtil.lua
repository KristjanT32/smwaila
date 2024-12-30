dofile("$CONTENT_40639a2c-bb9f-4d4f-b88c-41bfe264ffa8/Scripts/ModDatabase.lua")

---@class ModDBUtil
ModDBUtil = class(nil)

---@type boolean Whether the databases have been loaded.
ModDBUtil.loaded = false

---@type table<string, table> Stores cached shape info mapped to their UUID strings.
ModDBUtil.cachedShapeInfo = {}

---@type table<string, table>
ModDBUtil.cachedShapesets = {}

function ModDBUtil.init(self)
    local start = os.clock()
    log("Loading ModDB databases...")
    log("=================================================")
    ModDatabase.loadDescriptions()
    ModDatabase.loadShapesets()
    ModDatabase.loadHarvestablesets()
    ModDatabase.loadCharactersets()
    log("Database loading finished in " .. clockTimeToMillis(os.clock() - start) .. "ms")
    log("=================================================")
    log("Proceeding to cache shapesets...")
    log("=================================================")
    start = os.clock()
    for _, modLocalId in pairs(ModDatabase.getAllLoadedMods()) do
        if ModDatabase.databases.shapesets[modLocalId] == nil then goto skip end
        for shapeset, shapes in pairs(ModDatabase.databases.shapesets[modLocalId]) do
            self.cachedShapesets[shapeset] = {
                modName = ModDatabase.databases.descriptions[modLocalId].name,
                shapes = shapes
            }
        end
        ::skip::
    end
    log("Shapeset caching finished in " .. clockTimeToMillis(os.clock() - start) .. "ms")
    log("=================================================")
    self.loaded = true
end

local function hasBlockList(shapeset)
    return shapeset["blockList"] ~= nil
end

local function hasPartList(shapeset)
    return shapeset["partList"] ~= nil
end


function ModDBUtil.getModNameByLocalId(self, localId)
    if (not self.loaded) then self:init() end
    return ModDatabase.databases.descriptions[localId].name
end

--- Returns the mod name
---@param uuid Uuid The UUID of the object to look up.
---@return string
function ModDBUtil.getModNameByShape(self, uuid)
    if (self.cachedShapeInfo[tostring(uuid)] ~= nil) then
        return self.cachedShapeInfo[tostring(uuid)].modName
    end

    for shapeset, info in pairs(self.cachedShapesets) do
        for _, _uuid in pairs(info.shapes) do
            if (sm.uuid.new(_uuid) == uuid) then
                local opened_shapeset = sm.json.open(shapeset)
                local ratings = {}
                if (hasBlockList(opened_shapeset)) then
                    for _, value in pairs(opened_shapeset["blockList"]) do
                        if (value.uuid == uuid) then
                            ratings = value.ratings
                            break
                        end
                    end
                end
                if (hasPartList(opened_shapeset)) then
                    for _, value in pairs(opened_shapeset["partList"]) do
                        if (value.uuid == uuid) then
                            ratings = value.ratings
                            break
                        end
                    end
                end

                self.cachedShapeInfo[tostring(uuid)] = {
                    modName = info.modName,
                    ratings = ratings
                }
                return info.modName;
            end
        end
    end
    return "Unknown"
end

--- Gets the ratings for the supplied shape.
--- This will either return the full ratings table (if available),
--- or a shorter version with durability, buoyancy and a material name.
---
--- Full table `{durability, density, friction, buoyancy}`
--- <br>
--- Short table `{durability, buoyancy, material, modName}`
---@param self ModDBUtil
---@param shape Shape The shape to look up ratings for
---@return table The ratings table.
function ModDBUtil.getShapeRatings(self, shape)
    local uuid = shape.uuid

    -- Check for cached shape info first
    if (self.cachedShapeInfo[tostring(shape.uuid)] ~= nil) then
        return self.cachedShapeInfo[tostring(shape.uuid)].ratings
    end

    local originModName = ""

    for shapeset, info in pairs(self.cachedShapesets) do
        for _, _uuid in pairs(info.shapes) do
            if (sm.uuid.new(_uuid) == uuid) then
                originModName = info.modName
                local _shapeset = sm.json.open(shapeset)
                if (hasBlockList(_shapeset)) then
                    for _, entry in pairs(_shapeset["blockList"]) do
                        if (entry.uuid == tostring(uuid)) then
                            if (entry.ratings ~= nil) then
                                self.cachedShapeInfo[tostring(uuid)] = {
                                    modName = info.modName,
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
                                self.cachedShapeInfo[tostring(uuid)] = {
                                    modName = info.modName,
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

    if (self.cachedShapeInfo[tostring(uuid)] == nil) then
        self.cachedShapeInfo[tostring(uuid)] = {
            modName = originModName,
            ratings = {
                buoyancy = shape:getBuoyancy(),
                durability = sm.item.getQualityLevel(uuid),
                material = shape.material
            }
        }
    end
    return self.cachedShapeInfo[tostring(uuid)].ratings
end
