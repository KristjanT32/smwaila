--- @class WAILA : ToolClass
WAILA = class(nil)

dofile("$CONTENT_DATA/Scripts/util/Utilities.lua")
dofile("$CONTENT_DATA/Scripts/util/Globals.lua")

--- @type GuiInterface WAILA GUI
WAILA.gui = sm.gui.createGuiFromLayout("$CONTENT_DATA/Gui/Layouts/panel_top.layout", false, {
    isHud = true, isInteractive = false, needsCursor = false
})


-- TODO: Implement suspension
-- Max title length: 51 char



-- A table of all inspectable object types
WAILA.inspectable = {
    INTERACTABLE = 1,
    SHAPE = 2,
    BODY = 3,
    LIFT = 4,
    CHARACTER = 5,
    PISTON = 6,
    BEARING = 7,
    HARVESTABLE = 8,
    CONSUMABLE = 9,
    TERRAIN_ASSET = 10,
    SUSPENSION = 11,
    MODDED = 406,
    HARDCODED = 405,
    UNKNOWN = 404,
    [1] = "INTERACTABLE",
    [2] = "SHAPE",
    [3] = "BODY",
    [4] = "LIFT",
    [5] = "CHARACTER",
    [6] = "PISTON",
    [7] = "BEARING",
    [8] = "HARVESTABLE",
    [9] = "CONSUMABLE",
    [10] = "TERRAIN_ASSET",
    [11] = "SUSPENSION",
    [404] = "UNKNOWN",
    [405] = "UNINSPECTABLE_HARDCODED",
    [406] = "MODDED"
}

WAILA.interactableType = {
    LOGIC_GATE = 1,
    TIMER = 2,
    CONTROLLER = 3,
    SWITCH = 4,
    SEAT = 5,
    SCRIPTED = 6,
    TOTEBOT_HEAD = 7,
    RADIO = 8,
    SENSOR = 9,
    THRUSTER = 10,
    LIGHT = 11
}

WAILA.vanillaCharacters = {
    [sm.uuid.new("264a563a-e304-430f-a462-9963c77624e9")] = "Woc",

    ["48c03f69-3ec8-454c-8d1a-fa09083363b1"] = { name = "Glowbug", icon = "icon_glowbug.png" },
    ["04761b4a-a83e-4736-b565-120bc776edb2"] = { name = "Tapebot (variant 1)", icon = "icon_tapebot_blue.png" },
    ["9dbbd2fb-7726-4e8f-8eb4-0dab228a561d"] = { name = "Tapebot (variant 2)", icon = "icon_tapebot_blue.png" },
    ["fcb2e8ce-ca94-45e4-a54b-b5acc156170b"] = { name = "Tapebot (variant 3)", icon = "icon_tapebot_blue.png" },
    ["68d3b2f3-ed4b-4967-9d22-8ee6f555df63"] = { name = "Tapebot (variant 4)", icon = "icon_tapebot_blue.png" },
    ["c3d31c47-0c9b-4b07-9bd4-8f022dc4333e"] = { name = "Explosive Tapebot", icon = "icon_tapebot_red.png" },
    ["8984bdbf-521e-4eed-b3c4-2b5e287eb879"] = { name = "Totebot", icon = "icon_totebot_green.png" },
    ["c8bfb8f3-7efc-49ac-875a-eb85ac0614db"] = { name = "Haybot", icon = "icon_haybot.png" },
    ["9f4fde94-312f-4417-b13b-84029c5d6b52"] = { name = "Farmbot", icon = "icon_farmbot.png" },
    ["b6cafd3e-970b-4974-bb9f-ba7184b02797"] = { name = "Builderbot", icon = "../unknown_object.png" }
}

WAILA.vanillaHarvestables = {
    ["b39349ae-9b7e-48e2-8e9d-6f9dc6472fd6"] = { name = "Soil", iconUUID = "9a3e478c-2224-44fa-887c-239965bd05ad" },
    ["bb600268-cd29-4715-babe-5fd02645eb1c"] = { name = "Blueberry Plant (growing)", iconUUID = "6a43fff2-8c6d-4460-9f44-e5483b5267dd" },
    ["9b031ec3-bc91-47b9-93fb-df79a8ef3026"] = { name = "Blueberry Plant (ready for harvesting)", iconUUID = "6a43fff2-8c6d-4460-9f44-e5483b5267dd" },
    ["d3fdedca-7e1c-45cc-a1db-f0deee381a71"] = { name = "Banana Plant (growing)", iconUUID = "aa4c9c5e-7fc6-4c27-967f-c550e551c872" },
    ["80cd6e60-154f-46da-8f26-ff30f2961fa2"] = { name = "Banana Plant (ready for harvesting)", iconUUID = "aa4c9c5e-7fc6-4c27-967f-c550e551c872" },
    ["18efedc5-8706-4ecb-afd4-e9294d3f1052"] = { name = "Redbeet Plant (growing)", iconUUID = "4ce00048-f735-4fab-b978-5f405e60f48f" },
    ["1a167796-8162-4990-97a7-b3810b3f94ca"] = { name = "Redbeet Plant (ready for harvesting)", iconUUID = "4ce00048-f735-4fab-b978-5f405e60f48f" },
    ["6dd177f4-3312-4b1e-a986-4421b5e83bff"] = { name = "Carrot Plant (growing)", iconUUID = "47ece75a-bfca-4e8a-b618-4f609fcea0da" },
    ["18990ae9-62d1-41f7-aab9-5199b31e3e89"] = { name = "Carrot Plant (ready for harvesting)", iconUUID = "47ece75a-bfca-4e8a-b618-4f609fcea0da" },
    ["c6f80a93-5b16-45ef-a478-ca56a50f61ae"] = { name = "Tomato Plant (growing)", iconUUID = "6d92d8e7-25e9-4698-b83d-a64dc97978c8" },
    ["534b13a0-3ec1-4558-a77a-cfccf6c3cb3e"] = { name = "Tomato Plant (ready for harvesting)", iconUUID = "6d92d8e7-25e9-4698-b83d-a64dc97978c8" },
    ["b1a17952-b6a2-436d-81e4-df8ffb552166"] = { name = "Orange Plant (growing)", iconUUID = "f5098301-1693-457b-8efc-83b3504105ac" },
    ["133ae17a-c038-4a55-ab79-f40f6840ab2b"] = { name = "Orange Plant (ready for harvesting)", iconUUID = "f5098301-1693-457b-8efc-83b3504105ac" },
    ["ec1cf82f-e8f3-4ca6-8e35-a4bdf0e8e259"] = { name = "Potato Plant (growing)", iconUUID = "bfcfac34-db0f-42d6-bd0c-74a7a5c95e82" },
    ["c42ad18d-797b-4196-ab79-86e222d8f767"] = { name = "Potato Plant (ready for harvesting)", iconUUID = "bfcfac34-db0f-42d6-bd0c-74a7a5c95e82" },
    ["1337f492-aa23-42d0-af7a-fae45b47e55f"] = { name = "Pineapple Plant (growing)", iconUUID = "4ec64cda-1a5b-4465-88b4-5ea452c4a556" },
    ["2cedbc23-92c5-4fba-8a08-ecbae23a28e5"] = { name = "Pineapple Plant (ready for harvesting)", iconUUID = "4ec64cda-1a5b-4465-88b4-5ea452c4a556" },
    ["1675314b-0dfc-4d34-b854-0bdf0476221d"] = { name = "Broccoli Plant (growing)", iconUUID = "b5cdd503-fe1c-482b-86ab-6a5d2cc4fc8f" },
    ["b166b142-792a-4c8f-9d06-f277dab6dba6"] = { name = "Broccoli Plant (ready for harvesting)", iconUUID = "b5cdd503-fe1c-482b-86ab-6a5d2cc4fc8f" },
    ["779b5e09-7ce7-4a16-9817-02f5cb8e11f6"] = { name = "Cotton Plant (growing)", iconUUID = "3440440b-d362-4473-aa03-b7c41e1fe7ad" },
    ["4d923a91-0c98-40f9-ae3f-ef386362ab1c"] = { name = "Cotton Plant (ready for harvesting)", iconUUID = "3440440b-d362-4473-aa03-b7c41e1fe7ad" },
    ["7261bb49-9c63-4097-999a-4dcab9645eb0"] = { name = "Beehive", iconUUID = "fcf0958c-084d-4854-9b1b-b06594b4262a" },
    ["3f1507bc-fc48-4b77-b87a-687cb1f4b787"] = { name = "Beehive (harvested)", iconUUID = "fcf0958c-084d-4854-9b1b-b06594b4262a" },
    ["c591d94b-d7d1-4305-a9dd-76ef06d6fb49"] = { name = "Wild Cotton Plant", iconUUID = "3440440b-d362-4473-aa03-b7c41e1fe7ad" },
    ["062d34ac-d7ed-44ef-b523-e5b3ad70fdac"] = { name = "Wild Cotton Plant (growing)", iconUUID = "3440440b-d362-4473-aa03-b7c41e1fe7ad" },
    ["f7567939-d170-437e-b5c4-352ee9d5850d"] = { name = "Pigment flower", iconUUID = "c9396a42-67c3-4fa3-b682-31428ff9eced" },
    ["1c5bdfa2-e28f-4ccd-8a4e-be52d812f18a"] = { name = "Pigment flower (growing)", iconUUID = "c9396a42-67c3-4fa3-b682-31428ff9eced" },
    ["2ab8edca-9cfe-4b1c-9f57-5092f94ea890"] = { name = "Oil Geyser", iconUUID = "1147e59d-6940-42b4-840b-07f05054f5e0" },
    ["b6a26689-d803-49cc-a6e8-7f2b66dfb54d"] = { name = "Oil Geyser (harvested)", iconUUID = "1147e59d-6940-42b4-840b-07f05054f5e0" },
    ["39a5aeba-a021-4117-8cad-e08ad159281d"] = { name = "Wild Corn", iconUUID = "fe8bfeba-850b-4827-9785-10e2468c9c23" },
    ["0f74d3a4-ade0-4054-8207-21f6be7903be"] = { name = "Wild Corn (harvested)", iconUUID = "fe8bfeba-850b-4827-9785-10e2468c9c23" },
    ["046a8ac8-300b-4e52-91f7-0912d53b2955"] = { name = "Slimy Clam", iconUUID = "40e8bd0d-04a0-4e95-b593-4038b54b156f" },
    ["8c95cede-25a5-48b4-be97-6c16dab31057"] = { name = "Slimy Clam (harvested)", iconUUID = "40e8bd0d-04a0-4e95-b593-4038b54b156f" },
    ["c4ea19d3-2469-4059-9f13-3ddb4f7e0b79"] = { name = "Birch Tree", iconUUID = "" },
    ["711c3e72-7ba1-4424-ae70-c13d23afe818"] = { name = "Birch Tree", iconUUID = "" },
    ["a7aa52af-4276-4b2d-af44-36bc41864e04"] = { name = "Birch Tree", iconUUID = "" },
    ["91ec04ea-9bf7-4a9d-bb7f-3d0125ff78c7"] = { name = "Leafy Tree", iconUUID = "" },
    ["4d482999-98b7-4023-a149-d47be709b8f7"] = { name = "Leafy Tree", iconUUID = "" },
    ["3db0a60d-8668-4c8a-8dd2-f5ceb294977e"] = { name = "Leafy Tree", iconUUID = "" },
    ["73f968f0-d3a3-4334-86a8-a90203a3a56d"] = { name = "Spruce Tree", iconUUID = "" },
    ["86324c5b-e97a-41f6-aa2c-7c6462f1f2e7"] = { name = "Spruce Tree", iconUUID = "" },
    ["27aa53ea-1e09-4251-a284-437f93850409"] = { name = "Spruce Tree", iconUUID = "" },
    ["8411caba-63db-4b93-ad67-7ae8e350d360"] = { name = "Pine Tree", iconUUID = "" },
    ["1cb503a4-9306-412f-9e13-371bc634af60"] = { name = "Pine Tree", iconUUID = "" },
    ["fa864e51-67db-4ac9-823b-cfbdf523375d"] = { name = "Pine Tree", iconUUID = "" },
    ["0d3362ae-4cb3-42ae-8a08-d3f9ed79e274"] = { name = "Small Stone", iconUUID = "" },
    ["f6b8e9b8-5592-46b6-acf9-86123bf630a9"] = { name = "Small Stone", iconUUID = "" },
    ["60ad4b7f-a7ef-4944-8a87-0844e6305513"] = { name = "Small Stone", iconUUID = "" },
    ["ab5b947e-a223-4842-83dd-aa6b23ac2b86"] = { name = "Medium Stone", iconUUID = "" },
    ["5da6c862-8a5c-4b56-90d3-5f038d569c4a"] = { name = "Medium Stone", iconUUID = "" },
    ["90e0ef6a-8409-4459-8926-e5351d7da611"] = { name = "Medium Stone", iconUUID = "" },
    ["ab362045-0444-4749-9f24-f5e850162857"] = { name = "Large Stone", iconUUID = "" },
    ["63fb92b3-e1dc-4b5c-9ed3-7b572bc01ca4"] = { name = "Large Stone", iconUUID = "" },
    ["67111401-1ee1-4bfb-8780-fa878352f90d"] = { name = "Large Stone", iconUUID = "" },
    ["b8eb68ca-25a0-47aa-8745-12f2dd13d873"] = { name = "Loot Crate", iconUUID = "" },
    ["a6b9fa26-df80-4f5b-9679-418f4567e5ca"] = { name = "Epic Loot Crate", iconUUID = "" },
    ["97fe0cf2-0591-4e98-9beb-9186f4fd83c8"] = { name = "Dropped Item", iconUUID = "" },
    ["74ffe0eb-17fe-41b3-a532-8dbb5924e5dc"] = { name = "loot_audiologfile", iconUUID = "" },
    ["6e7611e1-ad18-413a-a4cb-bab7e3a5ca75"] = { name = "loot_picturelogfile", iconUUID = "" },
    ["6726c35c-f8e6-49cf-b0b6-05e7efac4115"] = { name = "loot_informationlogfile", iconUUID = "" },
    ["3b7054d0-9ca7-4efa-8b4a-e8658eda3181"] = { name = "Logbook", iconUUID = "" },
    ["e3cb14d5-9d28-45e8-96f7-fc79c60de292"] = { name = "Rare Garment Box", iconUUID = "" },
    ["cceec00b-8a34-4d68-a419-8c3bc7aa075a"] = { name = "Epic Garment Box", iconUUID = "" },
    ["6757b211-f50c-42c5-bd7c-648dcbe3ed52"] = { name = "Glowstick Remains", iconUUID = "3a3280e4-03b6-4a4d-9e02-e348478213c9" }
}

WAILA.uninspectableInteractables = {
    -- Sport suspensions 1-5
    ["67da25c9-3825-41f6-9724-4546a11cb2a5"] = "67da25c9-3825-41f6-9724-4546a11cb2a5",
    ["aae686a2-0eb3-43b3-b998-def282de79e9"] = "aae686a2-0eb3-43b3-b998-def282de79e9",
    ["d0aa2676-5266-432a-bf7e-3887e6ddedd5"] = "d0aa2676-5266-432a-bf7e-3887e6ddedd5",
    ["d9adddcc-972d-4726-a376-67f950b99a44"] = "d9adddcc-972d-4726-a376-67f950b99a44",
    ["52855106-a95c-4427-9970-3f227109b66d"] = "52855106-a95c-4427-9970-3f227109b66d",

    -- Off-road suspensions 1-5
    ["f3cfef9d-faef-4be8-9283-476eb99614d7"] = "f3cfef9d-faef-4be8-9283-476eb99614d7",
    ["00284190-1484-4286-a198-b2ddef768c2e"] = "00284190-1484-4286-a198-b2ddef768c2e",
    ["a9658eaf-0dd8-46a6-8cac-be6978f19b79"] = "a9658eaf-0dd8-46a6-8cac-be6978f19b79",
    ["4c3f6a7c-45c6-4ed8-bf13-c247c3db6b81"] = "4c3f6a7c-45c6-4ed8-bf13-c247c3db6b81",
    ["73f838db-783e-4a41-bc0f-9008967780f3"] = "73f838db-783e-4a41-bc0f-9008967780f3"
}

--- @type boolean
WAILA.isShown = false

WAILA.current = {
    --- @type Shape|Interactable|Harvestable|Character|Joint
    target = nil,

    --- @type string
    type = nil,

    --- @type integer
    lastUpdate = 0
}

--- @type table<string|table>
WAILA.cachedRatings = {}

function WAILA.client_onCreate(self)
    self:client_initializeGUI()
end

function WAILA.server_onCreate(self)
    print("[SM: WAILA] Initializing...")
    self:client_cacheShapeRatings()
end

function WAILA.client_onFixedUpdate(self, deltaTime)
    --- @type RaycastResult
    local successful, result = sm.localPlayer.getRaycast(10)

    if (successful) then
        self:client_displayPanel(result)
    else
        if (self.isShown) then
            self:client_closePanel()
        end
    end
    self.current.lastUpdate = self.current.lastUpdate + 1
end

function WAILA.client_initializeGUI(self)
    self:client_setTitleLabel("Welcome to SM: WAILA")
    self:client_setPropertiesLabel(
        "You'll see information about the object you're looking here.\nFor some objects, special information is available.")
    self:client_setWAILAIcon(1)
    if (not self.gui:isActive()) then
        self.gui:open()
    end
end

--- Displays a WAILA panel for the <code>RaycastResult</code> supplied.
--- @param raycastResult RaycastResult The raycast result to display a WAILA panel for.
function WAILA.client_displayPanel(self, raycastResult)
    if (self.current.lastUpdate <= 1 and self.isShown) then
        --print("[SM: WAILA] Last refresh: " .. self.current.lastUpdate .. "ms")
        return
    end
    self.current.lastUpdate = 0
    local startTime = os.clock()
    if (not raycastResult.valid) then
        self:client_closePanel()
        return
    end
    if (raycastResult.type == "terrainSurface") then
        self:client_closePanel()
        return
    end

    if (self.gui:isActive()) then
        self.gui:close()
    end

    self:client_resetPanel()


    local hitType = self:client_getHitType(raycastResult)

    --- @type Shape
    local asShape = raycastResult:getShape()

    --- @type Joint
    local asJoint = raycastResult:getJoint()

    --- @type Lift
    local asLift = raycastResult:getLiftData()

    --- @type Character
    local asChar = raycastResult:getCharacter()

    --- @type Body
    local asBody = raycastResult:getBody()

    self.current.type = hitType

    if (hitType == self.inspectable.BODY) then
        if (asBody ~= nil) then
            if (sizeof(asBody:getShapes()) == 1) then
                asShape = asBody:getShapes()[1]
            end
        end
    end

    self:client_setTypeLabel(hitType)
    if (asShape ~= nil) then
        self:client_setShapeStats(asShape)
    elseif (asJoint ~= nil) then
        self:client_setShapeStatsByUUID(asJoint.uuid)
    else
        self:client_hideShapeStats()
    end

    if (hitType == self.inspectable.SHAPE) then
        self.current.target = asShape

        self:client_setColor(asShape.color)
        if (asShape.isBlock) then
            local _body = asBody
            local _shapes = {}

            if (sm.localPlayer.getPlayer():getCharacter():getWorld():isIndoor()) then
                _shapes = { asShape }
            else
                _shapes = _body:getShapes()
            end

            local blocks = 0
            local mass = 0
            local filterShape = nil
            local filterColor = nil

            local shapes = {}
            if (sizeof(_shapes) > 5) then
                shapes = { [1] = asShape }
                filterShape = shapes[1].uuid
                filterColor = shapes[1].color
            else
                filterShape = asShape.uuid
                filterColor = asShape.color
                shapes = _shapes
            end

            for _, shape in ipairs(shapes) do
                if (shape.uuid == filterShape and shape.color == filterColor) then
                    blocks = blocks + blocksInShape(shape)
                    mass = mass + shape.mass
                end
            end

            self:client_setTitleLabel(sm.shape.getShapeTitle(asShape.uuid) .. " #FCC200x" .. blocks)
            self:client_setPropertiesLabel("Mass: #FCC200" ..
                string.format("%.1f", mass) ..
                " kg\n#FFFFFFBuoyancy: #FCC200" .. string.format("%.1f", asShape:getBuoyancy()))
            self:client_setPreview(asShape.uuid)
        else
            self:client_setTitleLabel(sm.shape.getShapeTitle(asShape.uuid))
            self:client_setPreview(asShape.uuid)
        end
    elseif (hitType == self.inspectable.INTERACTABLE) then
        local asInter = asShape:getInteractable()
        local type = self:client_getInteractableType(asInter)
        self:client_setPreview(asInter:getShape().uuid)
        self.current.target = asInter

        if (type == self.interactableType.LOGIC_GATE) then
            local mode = self:client_getLogicGateTypeByUVIndex(asInter)
            self:client_setPropertiesLabel(
                "#0066B2" ..
                sizeof(asInter:getChildren(1)) ..
                " #ffffffoutgoing connections, #D4002E" ..
                sizeof(asInter:getParents(1)) .. " #ffffffincoming connections")


            self:client_setInteractableState(asInter.active)
            self.gui:setText("ObjectTitle",
                sm.shape.getShapeTitle(asInter:getShape().uuid) .. " #ffffff(" .. mode .. "#ffffff)")
            self:client_setColor(asInter.shape.color)
        elseif (type == self.interactableType.SWITCH) then
            self:client_setInteractableState(asInter.active)

            self.gui:setText("ObjectTitle",
                sm.shape.getShapeTitle(asInter:getShape().uuid))

            local controlsLabel = ""
            local seatConnectionLabel = ""
            if (sizeof(asInter:getChildren(1)) > 0) then
                controlsLabel = "#ffffffControls #FCC200" .. sizeof(asInter:getChildren(1)) .. " interactable(s)"
            end
            if (asInter:getSingleParent()) then
                if (not asInter:getSingleParent():hasSeat()) then return end
                seatConnectionLabel = "#ffffffControlled by #FCC200" ..
                    sm.shape.getShapeTitle(asInter:getSingleParent().shape.uuid)
            end

            if (seatConnectionLabel == "" and controlsLabel == "") then
                self:client_setPropertiesLabel("#D4002ENo connections")
            else
                if (controlsLabel == "") then
                    self:client_setPropertiesLabel(seatConnectionLabel)
                else
                    self:client_setPropertiesLabel(controlsLabel .. "\n" .. seatConnectionLabel)
                end
            end
            self:client_setColor(asInter.shape.color)
        elseif (type == self.interactableType.TIMER) then
            self:client_setTitleLabel(sm.shape.getShapeTitle(asInter:getShape().uuid))
            self:client_setInteractableState(asInter.active)
            if (asInter:getUvFrameIndex() > 0) then
                if (asInter.active) then
                    self:client_setPropertiesLabel("Idle (done)")
                else
                    self:client_setPropertiesLabel("Ticking up")
                end
            elseif (asInter:getUvFrameIndex() < 1023) then
                if (asInter:getUvFrameIndex() == 0) then
                    self:client_setPropertiesLabel("Idle (unpowered)")
                end
            end
        elseif (type == self.interactableType.CONTROLLER) then
            self:client_setTitleLabel(sm.shape.getShapeTitle(asInter:getShape().uuid))
            local controlledByLabel = ""
            local controlsLabel = ""
            if (asInter:getSingleParent() ~= nil) then
                controlledByLabel = "#ffffffControlled by #FCC200" ..
                    sm.shape.getShapeTitle(asInter:getSingleParent().shape.uuid)
            end
            local totalChildren = sizeof(asInter:getChildren(4)) + sizeof(asInter:getChildren(16))
            if (totalChildren > 0) then
                controlsLabel = "#ffffffControls #FCC200" .. totalChildren .. " interactable(s)"
            end

            if (controlledByLabel == "" and controlsLabel == "") then
                self:client_setPropertiesLabel("#D4002ENo connections")
            else
                if (controlledByLabel ~= "") then
                    self:client_setPropertiesLabel(controlledByLabel .. "\n" .. controlsLabel)
                else
                    self:client_setPropertiesLabel(controlsLabel)
                end
            end
        elseif (type == self.interactableType.SEAT) then
            self:client_setTitleLabel(sm.shape.getShapeTitle(asInter.shape.uuid))

            local connectionsString = ""
            if (sizeof(asInter:getSeatInteractables()) > 0) then
                connectionsString = "#ffffffControls #FCC200" ..
                    sizeof(asInter:getSeatInteractables()) .. " interactable(s)"
            end

            if (asInter:getSeatCharacter() ~= nil) then
                self:client_setPropertiesLabel("Occupied by #FCC200" ..
                    asInter:getSeatCharacter():getPlayer().name .. "\n" .. connectionsString)
            else
                self:client_setPropertiesLabel("#FCC200Vacant" .. "\n" .. connectionsString)
            end

            self:client_setTitleLabel(sm.shape.getShapeTitle(asInter.shape.uuid))
            self:client_setColor(asInter.shape.color)
        elseif (type == self.interactableType.RADIO or type == self.interactableType.LIGHT) then
            self:client_setInteractableState(asInter.active)

            self:client_setTitleLabel(sm.shape.getShapeTitle(asInter.shape.uuid))
            self:client_setColor(asInter.shape.color)
            if (asInter:getSingleParent() ~= nil) then
                self:client_setPropertiesLabel("Controlled by #FCC200" ..
                    sm.shape.getShapeTitle(asInter:getSingleParent().shape.uuid))
            else
                self:client_setPropertiesLabel("#D4002ENo connections")
            end
        elseif (type == self.interactableType.SENSOR) then
            self:client_setInteractableState(asInter.active)

            self.gui:setText("ObjectTitle",
                sm.shape.getShapeTitle(asInter:getShape().uuid))
            self:client_setColor(asInter.shape.color)
            if (sizeof(asInter:getChildren(1)) > 0) then
                self:client_setPropertiesLabel("#ffffffControls #FCC200" ..
                    sizeof(asInter:getChildren(1)) .. " interactable(s)")
            else
                self:client_setPropertiesLabel("#D4002ENo connections")
            end
        else
            self:client_setTitleLabel(sm.shape.getShapeTitle(asInter.shape.uuid))
            self:client_setColor(asInter.shape.color)
        end
        self:client_setColor(asInter.shape.color)
    elseif (hitType == self.inspectable.CONSUMABLE) then
        self.current.target = asShape

        local shape = raycastResult:getShape()
        self:client_setTitleLabel(sm.shape.getShapeTitle(shape.uuid))
        self:client_setPropertiesLabel(sm.shape.getShapeDescription(shape.uuid))
        self:client_setPreview(shape.uuid)
        self:client_setColor(asShape.color)
    elseif (hitType == self.inspectable.PISTON) then
        self:client_setTitleLabel(sm.shape.getShapeTitle(asJoint:getShapeUuid()))
        self:client_setPreview(asJoint:getShapeUuid())
        self.current.target = asJoint

        if (asJoint:getLength() < 1.5) then
            self:client_setPropertiesLabel("Not extended")
        else
            self:client_setPropertiesLabel(
                "Extended by: #FCC200" .. math.floor(asJoint:getLength()) .. " blocks")
        end
        self:client_setColor(asJoint:getShapeA().color)
    elseif (hitType == self.inspectable.BEARING) then
        self.current.target = asJoint
        self:client_setTitleLabel(sm.shape.getShapeTitle(asJoint:getShapeUuid()))
        self:client_setPreview(asJoint:getShapeUuid())
        self:client_setPropertiesLabel("Speed: #FCC200" ..
            math.floor(asJoint:getAngularVelocity()) ..
            " #ffffffrad/s (#FCC200" ..
            math.ceil(math.deg(asJoint:getAngularVelocity())) ..
            "#ffffff °/s)" .. "\n#ffffffAngle: #FCC200" .. math.floor(math.deg(asJoint:getAngle())) .. " #ffffff°")
        self:client_setColor(asJoint:getShapeA().color)
    elseif (hitType == self.inspectable.LIFT) then
        self.current.target = asLift
        if (sm.localPlayer.getOwnedLift() == asLift) then
            self:client_setTitleLabel("Your Lift")
        else
            self:client_setTitleLabel("Player Lift")
        end
        self:client_setColor(sm.shape.getShapeTypeColor(sm.uuid.new("5cc12f03-275e-4c8e-b013-79fc0f913e1b")))
        self:client_setPropertiesLabel("#ffffffID: #FCC200" ..
            asLift.id .. "\n#ffffffHeight: #FCC200" .. asLift.level .. " blocks")
        self:client_setPreview(sm.uuid.new("5cc12f03-275e-4c8e-b013-79fc0f913e1b"))
    elseif (hitType == self.inspectable.CHARACTER) then
        self.current.target = asChar
        if (asChar:getPlayer() ~= nil) then
            self:client_setTitleLabel(asChar:getPlayer().name)
        else
            if (table.hasKey(self.vanillaCharacters, tostring(asChar:getCharacterType()))) then
                self:client_setTitleLabel(self.vanillaCharacters[tostring(asChar:getCharacterType())].name)
                self:client_setCharacterIcon(self.vanillaCharacters[tostring(asChar:getCharacterType())].icon)
            else
                self:client_setTitleLabel("Character ##" .. asChar:getId())
            end

            local activeAnimations = ""
            for _, anim in ipairs(asChar:getActiveAnimations()) do
                activeAnimations = activeAnimations .. "#FCC200" .. anim.name
                if (asChar:getActiveAnimations()[_ + 1] ~= nil) then
                    activeAnimations = activeAnimations .. " "
                end
            end
            activeAnimations = string.gsub(activeAnimations, " ", "#ffffff, ")

            self:client_setPropertiesLabel(
                "Character id: #FCC200##" ..
                tostring(asChar:getId()) ..
                "\n#ffffffAnimation: " .. activeAnimations)
        end
        --self:client_setPreview(sm.uuid.new("068a89ca-504e-4782-9ede-48f710aeea73"))
    elseif hitType == self.inspectable.HARVESTABLE then
        local asHarvest = raycastResult:getHarvestable()
        self.current.target = asHarvest
        self:client_setTitleLabel(self.vanillaHarvestables[tostring(asHarvest.uuid)].name)
        if (self.vanillaHarvestables[tostring(asHarvest.uuid)].iconUUID) then
            self:client_setPreview(sm.uuid.new(self.vanillaHarvestables[tostring(asHarvest.uuid)].iconUUID))
        end
        self:client_setColor(asHarvest:getColor())
    elseif hitType == self.inspectable.TERRAIN_ASSET then
        return
    elseif (hitType == self.inspectable.HARDCODED) then
        self:client_setTitleLabel(sm.shape.getShapeTitle(asJoint:getShapeUuid()))
        self:client_setPreview(asJoint:getShapeUuid())
        self.current.target = asJoint
        self:client_setColor(asJoint:getShapeA().color)
        self:client_setTypeLabel(self.inspectable.SUSPENSION)
    elseif hitType == self.inspectable.UNKNOWN or hitType == self.inspectable.MODDED then
        local type = nil
        if (asShape ~= nil) then type = asShape end
        if (asJoint ~= nil) then type = asJoint end
        if (type ~= nil) then
            self:client_setTitleLabel(sm.shape.getShapeTitle(type:getShapeUuid()))
            self:client_setPreview(type:getShapeUuid())
            self.current.target = type
            self:client_setColor(type.color)
            if (hitType == self.inspectable.UNKNOWN) then
                self:client_setTypeLabel(self.inspectable.UNKNOWN)
            else
                self:client_setTypeLabel(self.inspectable.MODDED)
            end
        else
            self:client_setWAILAIcon(1)
            self:client_setTitleLabel("Unimplemented object")
            self:client_setPropertiesLabel("SMWAILA can't inspect this object yet.\nType: " .. raycastResult.type)
        end
    end
    self.gui:open()
    self.isShown = true
    if (math.ceil((os.clock() - startTime) * 1000) >= 10) then
        print("=[SM: WAILA NOTIFICATION]====================")
        print("WAILA panel update took " ..
            math.ceil((os.clock() - startTime) * 1000) ..
            "ms" ..
            "\nDisplaying information for: " ..
            self.current.type .. " (" .. tostring((self.current.target or {}).uuid or sm.uuid.getNil()) .. ")")
        print("=============================================")
    elseif (math.ceil((os.clock() - startTime) * 1000) >= 50) then
        print("=[SM: WAILA WARNING]=========================")
        print("WAILA panel update took " ..
            math.ceil((os.clock() - startTime) * 1000) .. "ms"
            .. "\nDisplaying information for: " .. self.current.type .. " (" .. tostring(self.current.target.uuid) .. ")"
        )
        print("=============================================")
    end
end

--- Sets the color box's color for SMWAILA's panel
--- @param self WAILA
--- @param color Color The color to set
function WAILA.client_setColor(self, color)
    if (self.current.type ~= self.inspectable.INTERACTABLE) then
        self:client_showLongColorFlair()
        self:client_hideShortColorFlair()
    end
    self.gui:setColor("ObjectColor", color)
    self.gui:setColor("ObjectColorLong", color)
    self.gui:setText("ObjectColorCode", formatColorHex(color))
end

--- Sets the preview image to the icon of the supplied shapeUUID
---@param self WAILA
---@param shapeUUID Uuid The UUID for the shape whose icon to set the preview to
function WAILA.client_setPreview(self, shapeUUID)
    self.gui:setVisible("ObjectPreview", true)
    self.gui:setVisible("ObjectPreviewAlternative", false)

    self.gui:setIconImage("ObjectPreview", shapeUUID)
end

function WAILA.client_setWAILAIcon(self, type)
    self.gui:setVisible("ObjectPreview", false)
    self.gui:setVisible("ObjectPreviewAlternative", true)
    if (type == 1) then
        self.gui:setImage("ObjectPreviewAlternative", "$CONTENT_DATA/Gui/Assets/unknown_object.png")
    elseif (type == 2) then

    end
end

function WAILA.client_setCharacterIcon(self, character_icon_file)
    self.gui:setVisible("ObjectPreview", false)
    self.gui:setVisible("ObjectPreviewAlternative", true)
    self.gui:setImage("ObjectPreviewAlternative", "$CONTENT_DATA/Gui/Assets/Characters/" .. character_icon_file)
end

--- Sets the title label to <code>title</code>
---@param self WAILA
---@param title string The title to set
function WAILA.client_setTitleLabel(self, title)
    self.gui:setText("ObjectTitle", title)
end

--- Sets the properties label to <code>properties</code>
--- @param self WAILA
--- @param properties string The text to show in the properties label.
function WAILA.client_setPropertiesLabel(self, properties)
    self.gui:setText("ObjectSubtitle", properties)
end

--- Updates the stats label to reflect the currently targeted shape's properties.
---@param self WAILA
---@param shape Shape the shape whose stats to display
function WAILA.client_setShapeStats(self, shape)
    self.gui:setVisible("ObjectStatsPanel", true)
    local ratings = self:client_getShapeRatings(shape.uuid)

    local str = "#ffffffBuoyancy: #FCC200" .. string.format("%.1f", shape:getBuoyancy())
        .. "   "
        .. "#ffffffDurability: #FCC200" .. string.format("%.1f", sm.item.getQualityLevel(shape.uuid))

    if (ratings ~= nil) then
        str = str .. "   "
            .. "#ffffffFriction: #FCC200" .. string.format("%.1f", ratings.friction or 0)
            .. "   "
            .. "#ffffffDensity (weight): #FCC200" .. string.format("%.1f", ratings.density or 1)
    end

    self.gui:setText("ObjectStats", str)
end

function WAILA.client_setShapeStatsByUUID(self, uuid)
    self.gui:setVisible("ObjectStatsPanel", true)
    local ratings = self:client_getShapeRatings(uuid)
    if (ratings == nil) then
        self.gui:setVisible("ObjectStatsPanel", false)
        return
    end

    local str = "#ffffffBuoyancy: #FCC200" .. string.format("%.1f", ratings.buoyancy or 0)
        .. "   "
        .. "#ffffffDurability: #FCC200" .. string.format("%.1f", ratings.durability or 0)
        .. "   "
        .. "#ffffffFriction: #FCC200" .. string.format("%.1f", ratings.friction or 0)
        .. "   "
        .. "#ffffffDensity (weight): #FCC200" .. string.format("%.1f", ratings.density or 1)


    self.gui:setText("ObjectStats", str)
end

--- Sets the interactable state (on/off) displayed on the WAILA panel.
---@param self WAILA
---@param state boolean Whether the interactable is on or off.
function WAILA.client_setInteractableState(self, state)
    self:client_showShortColorFlair()
    self:client_hideLongColorFlair()
    self:client_showInteractableStateFlair()
    if (state) then
        self.gui:setColor("ObjectState", sm.color.new("#57CC21"))
        self.gui:setText("ObjectStateLabel", "ON")
    else
        self.gui:setColor("ObjectState", sm.color.new("#B51D18"))
        self.gui:setText("ObjectStateLabel", "OFF")
    end
end

function WAILA.client_hideShapeStats(self, shape)
    self.gui:setVisible("ObjectStatsPanel", false)
end

function WAILA.client_setTypeLabel(self, type)
    if (self.inspectable[type] ~= nil) then
        local text = string.gsub(self.inspectable[type], "_", "")
        self.gui:setText("TypeLabel", text)
    else
        self.gui:setText("TypeLabel", "UNKNOWN")
    end
end

--- Hides the SMWAILA panel
--- @param self WAILA
function WAILA.client_closePanel(self)
    self.gui:close()
    self:client_setTitleLabel("")
    self:client_setPropertiesLabel("")
    self:client_setColor(sm.color.new("#ffffff"))
    self:client_clearPreview()
    self:client_hideInteractableStateFlair()
    self.isShown = false
end

function WAILA.client_resetPanel(self)
    self:client_setTitleLabel("")
    self:client_setPropertiesLabel("")
    self:client_setColor(sm.color.new("#ffffff"))
    self:client_clearPreview()
    self:client_hideInteractableStateFlair()
    self:client_hideLongColorFlair()
end

function WAILA.client_clearPreview(self)
    self.gui:setVisible("ObjectPreviewAlternative", false)
    self.gui:setVisible("ObjectPreview", false)
end

function WAILA.client_showInteractableStateFlair(self)
    self.gui:setVisible("ObjectState", true)
end

function WAILA.client_hideInteractableStateFlair(self)
    self.gui:setVisible("ObjectState", false)
end

function WAILA.client_hideShortColorFlair(self)
    self.gui:setVisible("ObjectColor", false)
end

function WAILA.client_showShortColorFlair(self)
    self.gui:setVisible("ObjectColor", true)
end

function WAILA.client_showLongColorFlair(self)
    self.gui:setVisible("ObjectColorLong", true)
end

function WAILA.client_hideLongColorFlair(self)
    self.gui:setVisible("ObjectColor", true)
    self.gui:setVisible("ObjectColorLong", false)
end

--- Returns a string representing the current mode of operation for the supplied <code>Interactable</code>
--- @param self WAILA
--- @param interactable Interactable
--- @return string gateType The operation mode for the specified logic gate
function WAILA.client_getLogicGateTypeByUVIndex(self, interactable)
    if (interactable:getUvFrameIndex() == 0 or interactable:getUvFrameIndex() == 6) then
        return "AND"
    elseif (interactable:getUvFrameIndex() == 1 or interactable:getUvFrameIndex() == 7) then
        return "OR"
    elseif (interactable:getUvFrameIndex() == 2 or interactable:getUvFrameIndex() == 8) then
        return "XOR"
    elseif (interactable:getUvFrameIndex() == 3 or interactable:getUvFrameIndex() == 9) then
        return "NAND"
    elseif (interactable:getUvFrameIndex() == 4 or interactable:getUvFrameIndex() == 10) then
        return "NOR"
    elseif (interactable:getUvFrameIndex() == 5 or interactable:getUvFrameIndex() == 11) then
        return "XNOR"
    end
end

--- Gets the type of object hit from the RaycastResult.<br>
--- All possible values are in the <code>WAILA.inspectable</code> table.
--- @param raycastResult RaycastResult
--- @return number type The type of object hit by the ray.
function WAILA.client_getHitType(self, raycastResult)
    if (raycastResult.type == "terrainAsset") then
        return self.inspectable.TERRAIN_ASSET
    end
    if (raycastResult:getShape() ~= nil) then
        if (raycastResult:getShape():getInteractable() ~= nil) then
            if (raycastResult:getShape():getInteractable().type == "itemStack") then
                return self.inspectable.CONSUMABLE
            else
                return self.inspectable.INTERACTABLE
            end
        else
            return self.inspectable.SHAPE
        end
    end
    if (raycastResult:getLiftData() ~= nil) then return self.inspectable.LIFT end
    if (raycastResult:getJoint() ~= nil) then
        if (raycastResult:getJoint().type == "piston") then
            return self.inspectable.PISTON
        elseif (raycastResult:getJoint().type == "bearing") then
            return self.inspectable.BEARING
        elseif (raycastResult:getJoint().type == "unknown") then
            local hardcoded = self.uninspectableInteractables[tostring(raycastResult:getJoint():getShapeUuid())]
            if (hardcoded ~= nil) then
                return self.inspectable.HARDCODED
            else
                if (self:client_getShapeRatings(raycastResult:getJoint():getShapeUuid()) == nil) then
                    return self.inspectable.MODDED
                else
                    return self.inspectable.UNKNOWN
                end
            end
        end
        return self.inspectable.UNKNOWN
    end
    if (raycastResult:getCharacter() ~= nil) then
        return self.inspectable.CHARACTER
    end
    if (raycastResult:getHarvestable() ~= nil) then return self.inspectable.HARVESTABLE end
    if (raycastResult:getBody() ~= nil) then return self.inspectable.BODY end
    return self.inspectable.UNKNOWN
end

--- Gets the type of interactable the supplied <code>Interactable</code> represents as a <code>WAILA.interactableType</code>.
--- @param interactable Interactable
--- @return number type The type of interactable this Interactable represents
function WAILA.client_getInteractableType(self, interactable)
    if (interactable:getType() == "lever" or interactable:getType() == "button") then
        return self.interactableType
            .SWITCH
    end
    if (interactable:getType() == "logic") then return self.interactableType.LOGIC_GATE end
    if (interactable:getType() == "survivalSequence" or interactable:getType() == "controller") then
        return self
            .interactableType.CONTROLLER
    end
    if (interactable:getType() == "timer") then return self.interactableType.TIMER end
    if (interactable:getType() == "scripted" or interactable:getType() == "simpleInteractive") then
        if (interactable:hasSeat()) then
            return self.interactableType.SEAT
        else
            return self.interactableType.SCRIPTED
        end
    end
    if (interactable:getType() == "seat") then return self.interactableType.SEAT end
    if (interactable:getType() == "tone") then return self.interactableType.TOTEBOT_HEAD end
    if (interactable:getType() == "radio") then return self.interactableType.RADIO end
    if (interactable:getType() == "sensor" or interactable:getType() == "survivalSensor") then
        return self
            .interactableType.SENSOR
    end
    if (interactable:getType() == "thruster" or interactable:getType() == "survivalThruster") then
        return self
            .interactableType.THRUSTER
    end
    if (interactable:getType() == "spotLight" or interactable:getType() == "pointLight") then
        return self.interactableType.LIGHT
    end
    return self.interactableType.UNKNOWN
end

function WAILA.client_getShapeRatings(self, uuid)
    if (self.cachedRatings == {}) then
        self:client_cacheShapeRatings()
    end
    return self.cachedRatings[tostring(uuid)]
end

--- Returns a table representing the ratings of the supplied shape.
---@return table|nil ratings The ratings table, or nil if none found/shape invalid.
function WAILA.client_cacheShapeRatings(self)
    self.cachedRatings = {}
    local start = os.clock()
    print("[SM: WAILA] Caching shape ratings...")

    local shapesets = sm.json.open("$GAME_DATA/Objects/Database/shapesets.json")
    for _, shapeset in pairs(shapesets.shapeSetList) do
        local opened_shapeset = sm.json.open(shapeset)
        if (opened_shapeset["blockList"] ~= nil) then
            for _, value in pairs(opened_shapeset["blockList"]) do
                self.cachedRatings[tostring(value.uuid)] = value.ratings
            end
        end
        if (opened_shapeset["partList"] ~= nil) then
            for _, value in pairs(opened_shapeset["partList"]) do
                self.cachedRatings[tostring(value.uuid)] = value.ratings
            end
        end
    end
    print("[SM: WAILA] Caching completed in " .. math.floor((os.clock() - start) * 1000) .. "ms")
end

--- Checks whether a supplied object has changed.
---@param self WAILA
---@param target Shape|Harvestable|Interactable|Joint
function WAILA.client_hasChanged(self, target)

end
