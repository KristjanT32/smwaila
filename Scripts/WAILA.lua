--- @class WAILA : ToolClass
WAILA = class(nil)

dofile("$CONTENT_DATA/Scripts/util/Utilities.lua")
dofile("$CONTENT_DATA/Scripts/util/Globals.lua")

--- @type GuiInterface WAILA GUI
WAILA.gui = sm.gui.createGuiFromLayout("$CONTENT_DATA/Gui/Layouts/panel_top.layout", false, {
    isHud = true, isInteractive = false, needsCursor = false
})

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
    [1] = "INTERACTABLE",
    [2] = "SHAPE",
    [3] = "BODY",
    [4] = "LIFT",
    [5] = "CHARACTER",
    [6] = "PISTON",
    [7] = "BEARING",
    [8] = "HARVESTABLE",
    [9] = "CONSUMABLE"
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


function WAILA.client_onCreate(self)
    self:client_initializeGUI()
end

function WAILA.server_onCreate(self)
    print("[SM: WAILA] Initializing...")
end

function WAILA.client_onFixedUpdate(self, deltaTime)
    --- @type RaycastResult
    local successful, result = sm.localPlayer.getRaycast(10)

    if (successful) then
        self:client_displayPanel(result)
    else
        self:client_closePanel()
    end
end

function WAILA.client_initializeGUI(self)
    self:client_setTitleLabel("Welcome to SM: WAILA")
    self:client_setPropertiesLabel(
        "You'll see information about the object you're looking here.\nFor some objects, special information is available.")
    self:client_setPreview(sm.uuid.new("fdb8b8be-96e7-4de0-85c7-d2f42e4f33ce"))
    if (not self.gui:isActive()) then
        self.gui:open()
    end
end

--- Displays a WAILA panel for the <code>RaycastResult</code> supplied.
--- @param raycastResult RaycastResult The raycast result to display a WAILA panel for.
function WAILA.client_displayPanel(self, raycastResult)
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

    self:client_setTitleLabel("")
    self:client_setPropertiesLabel("")

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

    if (asBody ~= nil) then
        if (sizeof(asBody:getShapes()) == 1) then
            asShape = asBody:getShapes()[1]
        end
    end

    if (hitType == self.inspectable.SHAPE) then
        self:client_setColor(asShape.color)
        if (asShape.isBlock) then
            local blocks = 0
            local mass = 0
            local filterShape = asShape.uuid
            local filterColor = asShape.color
            for _, shape in ipairs(raycastResult:getBody():getShapes()) do
                if (shape.uuid == filterShape and shape.color == filterColor) then
                    blocks = blocks + blocksInShape(shape)
                    mass = mass + shape.mass
                end
            end

            self:client_setTitleLabel(sm.shape.getShapeTitle(asShape.uuid) .. " #FCC200x" .. blocks)
            self:client_setPropertiesLabel("Mass: #FCC200" .. mass .. " kg")
            self:client_setPreview(asShape.uuid)
        else
            self:client_setTitleLabel(sm.shape.getShapeTitle(asShape.uuid))
            self:client_setPreview(asShape.uuid)
        end
    elseif (hitType == self.inspectable.INTERACTABLE) then
        local asInter = asShape:getInteractable()
        local type = self:client_getInteractableType(asInter)
        self:client_setPreview(asInter:getShape().uuid)

        if (type == self.interactableType.LOGIC_GATE) then
            local mode = self:client_getLogicGateTypeByUVIndex(asInter)
            self:client_setPropertiesLabel(
                "#0066B2" ..
                sizeof(asInter:getChildren(1)) ..
                " #ffffffoutgoing connections, #D4002E" ..
                sizeof(asInter:getParents(1)) .. " #ffffffincoming connections")

            local state = ""
            if (asInter.active) then
                state = "#4cbb17[ON]"
            else
                state = "#D43C00[OFF]"
            end

            self.gui:setText("ObjectTitle",
                sm.shape.getShapeTitle(asInter:getShape().uuid) .. " #ffffff(" .. mode .. "#ffffff) - " .. state)
        elseif (type == self.interactableType.SWITCH) then
            local state = ""
            if (asInter.active) then
                state = "#4cbb17[ON]"
            else
                state = "#D43C00[OFF]"
            end

            self.gui:setText("ObjectTitle",
                sm.shape.getShapeTitle(asInter:getShape().uuid) .. " " .. state)

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
        elseif (type == self.interactableType.TIMER) then
            self:client_setTitleLabel(sm.shape.getShapeTitle(asInter:getShape().uuid))
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
            local state = ""
            if (asInter.active) then
                state = "#4cbb17[ON]"
            else
                state = "#D43C00[OFF]"
            end

            self:client_setTitleLabel(sm.shape.getShapeTitle(asInter.shape.uuid) .. " " .. state)

            self:client_setColor(asInter.shape.color)
            if (asInter:getSingleParent() ~= nil) then
                self:client_setPropertiesLabel("Controlled by #FCC200" ..
                    sm.shape.getShapeTitle(asInter:getSingleParent().shape.uuid))
            else
                self:client_setPropertiesLabel("#D4002ENo connections")
            end
        elseif (type == self.interactableType.SENSOR) then
            local state = ""
            if (asInter.active) then
                state = "#4cbb17[ON]"
            else
                state = "#D43C00[OFF]"
            end

            self.gui:setText("ObjectTitle",
                sm.shape.getShapeTitle(asInter:getShape().uuid) .. " " .. state)
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
    elseif (hitType == self.inspectable.CONSUMABLE) then
        local shape = raycastResult:getShape()
        self:client_setTitleLabel(sm.shape.getShapeTitle(shape.uuid))
        self:client_setPropertiesLabel(sm.shape.getShapeDescription(shape.uuid))
        self:client_setPreview(shape.uuid)
    elseif (hitType == self.inspectable.PISTON) then
        self:client_setTitleLabel(sm.shape.getShapeTitle(asJoint:getShapeUuid()))
        self:client_setPreview(asJoint:getShapeUuid())

        if (asJoint:getLength() < 1.5) then
            self:client_setPropertiesLabel("Not extended")
        else
            self:client_setPropertiesLabel(
                "Extended by: #FCC200" .. math.floor(asJoint:getLength()) .. " blocks")
        end
    elseif (hitType == self.inspectable.BEARING) then
        self:client_setTitleLabel(sm.shape.getShapeTitle(asJoint:getShapeUuid()))
        self:client_setPreview(asJoint:getShapeUuid())
        self:client_setPropertiesLabel("Speed: #FCC200" ..
            math.floor(asJoint:getAngularVelocity()) ..
            " #ffffffrad/s (#FCC200" ..
            math.ceil(math.deg(asJoint:getAngularVelocity())) ..
            "#ffffff °/s)" .. "\n#ffffffAngle: #FCC200" .. math.floor(math.deg(asJoint:getAngle())) .. " #ffffff°")
    elseif (hitType == self.inspectable.LIFT) then
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
        if (asChar:getPlayer() ~= nil) then
            self:client_setTitleLabel(asChar:getPlayer().name)
        else
            self:client_setTitleLabel("Character #" .. asChar:getId())

            local activeAnimations = ""
            for _, anim in ipairs(asChar:getActiveAnimations()) do
                activeAnimations = activeAnimations .. "#FCC200" .. anim.name
                if (asChar:getActiveAnimations()[_ + 1] ~= nil) then
                    activeAnimations = activeAnimations .. " "
                end
            end
            activeAnimations = string.gsub(activeAnimations, " ", "#ffffff, ")


            self:client_setPropertiesLabel(
                "UUID: #FCC200" ..
                tostring(asChar:getCharacterType()) ..
                "\n#ffffffAnimation: " .. activeAnimations)
        end
        self:client_setPreview(sm.uuid.new("068a89ca-504e-4782-9ede-48f710aeea73"))
    end


    if (asShape ~= nil) then
        -- If we hit a Joint (piston/bearing)
    elseif (asJoint ~= nil) then
    elseif (asLift ~= nil) then

    elseif (asChar ~= nil) then

    end
    self.gui:open()
end

--- Sets the color box's color for SMWAILA's panel
--- @param self WAILA
--- @param color Color The color to set
function WAILA.client_setColor(self, color)
    self.gui:setColor("ObjectColor", color)
end

--- Sets the preview image to the icon of the supplied shapeUUID
---@param self WAILA
---@param shapeUUID Uuid The UUID for the shape whose icon to set the preview to
function WAILA.client_setPreview(self, shapeUUID)
    self.gui:setIconImage("ObjectPreview", shapeUUID)
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

--- Hides the SMWAILA panel
--- @param self WAILA
function WAILA.client_closePanel(self)
    self.gui:close()
    self:client_setTitleLabel("...")
    self:client_setPropertiesLabel("...")
    self:client_setPreview(sm.uuid.new("fdb8b8be-96e7-4de0-85c7-d2f42e4f33ce"))
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
        end
    end
    if (raycastResult:getCharacter() ~= nil) then
        return self.inspectable.CHARACTER
    end
    if (raycastResult:getHarvestable() ~= nil) then return self.inspectable.HARVESTABLE end
    if (raycastResult:getBody() ~= nil) then return self.inspectable.BODY end
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
    --print(interactable:getType())
end

function WAILA.server_getPublicData(self, interactable)
    print(interactable.publicData)
end

--- @param character Character
function WAILA.server_getUnit(self, character)
    print(character:getUnit())
end
