---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsSorting = addon.Modules.Sorting
local fsCompare = addon.Collections.Comparer
local fsProviders = addon.Providers
local fsEnumerable = addon.Collections.Enumerable
local fsUnit = addon.WoW.Unit
local M = {}
addon.Modules.Sorting.Secure = M

local headers = {}
local secureMethods = {}

-- rounds a number to the specified decimal places
secureMethods["Round"] = [[
    local number, decimalPlaces = ...

    if number == nil then return nil end

    local mult = 10 ^ (decimalPlaces or 0)
    return math.floor(number * mult + 0.5) / mult
]]

-- returns true if in combat, otherwise false
secureMethods["InCombat"] = [[
    return SecureCmdOptionParse("[combat] true; false") == "true"
]]

-- gets the unit token from a frame
secureMethods["GetUnit"] = [[
    local frameName = ...
    local frame = _G[frameName]

    local unit = frame:GetAttribute("unit")

    if unit then return unit end

    local name = frame:GetName()
    if strmatch(name, "GladiusExButtonFrame") then
        unit = gsub(name, "GladiusExButtonFrame", "")
        return unit
    end

    return nil
]]

-- filters a set of frames to only unit frames
secureMethods["ExtractUnitFrames"] = [[
    local tableName, destinationTableName = ...
    local children = _G[tableName]
    local unitFrames = newtable()

    for _, child in ipairs(Children) do
        Frame = child
        local unit = self:RunAttribute("GetUnit", "Frame")
        Frame = nil

        if unit and child:IsVisible() then
            unitFrames[#unitFrames + 1] = child
        end
    end

    _G[destinationTableName] = unitFrames
]]

-- returns the index of the item within the array, or -1 if it doesn't exist
secureMethods["ArrayIndex"] = [[
    local arrayName, item = ...
    local array = _G[arrayName]

    for i, value in ipairs(array) do
        if value == item then
            return i
        end
    end

    return -1
]]

-- returns the index of the unit frame within the array of frames, or -1 if it doesn't exist
secureMethods["UnitIndex"] = [[
    local framesArrayName, unit = ...
    local frames = _G[framesArrayName]

    for i, frame in ipairs(frames) do
        Frame = frame
        local frameUnit = self:RunAttribute("GetUnit", "Frame")
        Frame = nil

        if frameUnit == unit then
            return i
        end
    end

    return -1
]]

-- copies elements from one table to another
secureMethods["CopyTable"] = [[
    local fromName, toName = ...
    local from = _G[fromName]
    local to = _G[toName]

    for k, v in pairs(from) do
        to[k] = v
    end
]]

-- converts an array of frames in a chain layout to a linked list
-- where the root node is the start of the chain
-- and each subsequent node depends on the one before it
-- i.e. root -> frame1 -> frame2 -> frame3
secureMethods["FrameChain"] = [[
    local framesArrayName, rootVariableName = ...
    local frames = _G[framesArrayName]
    local nodesByFrame = newtable()

    for _, frame in pairs(frames) do
        local node = newtable()
        node.Value = frame

        nodesByFrame[frame] = node
    end

    local root = nil
    for _, child in pairs(nodesByFrame) do
        local _, relativeTo, _, _, _ = child.Value:GetPoint()
        local parent = nodesByFrame[relativeTo]

        if parent then
            if parent.Next then
                return false, nil
            end

            parent.Next = child
            child.Previous = parent
        else
            root = child
        end
    end

    -- assert we have a complete chain
    local count = 0
    local current = root

    while current do
        count = count + 1
        current = current.Next
    end

    if count ~= #frames then
        return false
    end

    _G[rootVariableName] = root

    return true
]]

-- performs an in place sort on an array of frames by their visual order
secureMethods["SortFramesByTopLeft"] = [[
    local framesArrayName = ...
    local frames = _G[framesArrayName]

    -- bubble sort because it's easier to write
    -- not going to write an Olog(n) sort algorithm in this environment
    for i = 1, #frames do
        for j = 1, #frames - i do
            local left, bottom, width, height = frames[j]:GetRect()
            local nextLeft, nextBottom, nextWidth, nextHeight = frames[j + 1]:GetRect()
            local top = bottom + height
            local nextTop = nextBottom + nextHeight

            if top < nextTop or left > nextLeft then
                frames[j], frames[j + 1] = frames[j + 1], frames[j]
            end
        end
    end
]]

-- performs an in place sort on an array of points by their top left coordinate
secureMethods["SortPointsByTopLeft"] = [[
    local pointsArrayName = ...
    local points = _G[pointsArrayName]

    for i = 1, #points do
        for j = 1, #points - i do
            local point = points[j]
            local next = points[j + 1]

            local topFuzzy = self:RunAttribute("Round", point.Bottom + point.Height)
            local nextTopFuzzy = self:RunAttribute("Round", next.Bottom + next.Height)
            local leftFuzzy = self:RunAttribute("Round", point.Left)
            local nextLeftFuzzy = self:RunAttribute("Round", next.Left)

            if topFuzzy < nextTopFuzzy or leftFuzzy > nextLeftFuzzy then
                points[j], points[j + 1] = points[j + 1], points[j]
            end
        end
    end
]]

-- performs an in place sort on an array of points by their top left coordinate
secureMethods["SortPointsByLeftTop"] = [[
    local pointsArrayName = ...
    local points = _G[pointsArrayName]

    for i = 1, #points do
        for j = 1, #points - i do
            local point = points[j]
            local next = points[j + 1]

            local topFuzzy = self:RunAttribute("Round", point.Bottom + point.Height)
            local nextTopFuzzy = self:RunAttribute("Round", next.Bottom + next.Height)
            local leftFuzzy = self:RunAttribute("Round", point.Left)
            local nextLeftFuzzy = self:RunAttribute("Round", next.Left)

            if leftFuzzy > nextLeftFuzzy or topFuzzy < nextTopFuzzy then
                points[j], points[j + 1] = points[j + 1], points[j]
            end
        end
    end
]]

secureMethods["ApplySpacing"] = [[
    local pointsArrayName, spacingTableName = ...
    local points = _G[pointsArrayName]
    local spacing = _G[spacingTableName]
    local horizontal = spacing.Horizontal or 0
    local vertical = spacing.Vertical or 0

    OrderedTopLeft = newtable()
    OrderedLeftTop = newtable()

    self:RunAttribute("CopyTable", pointsArrayName, "OrderedTopLeft")
    self:RunAttribute("CopyTable", pointsArrayName, "OrderedLeftTop")

    self:RunAttribute("SortPointsByTopLeft", "OrderedTopLeft")
    self:RunAttribute("SortPointsByLeftTop", "OrderedLeftTop")

    for i = 2, #OrderedLeftTop do
        local point = OrderedLeftTop[i]
        local previous = OrderedLeftTop[i - 1]
        local sameRow = self:RunAttribute("Round", point.Bottom) == self:RunAttribute("Round", previous.Bottom)

        if sameRow then
            local existingSpace = point.Left - (previous.Left + previous.Width)
            local xDelta = horizontal - existingSpace
            point.Left = point.Left + xDelta
        end
    end

    for i = 2, #OrderedTopLeft do
        local point = OrderedTopLeft[i]
        local previous = OrderedTopLeft[i - 1]
        local sameColumn = self:RunAttribute("Round", point.Left) == self:RunAttribute("Round", previous.Left)

        if sameColumn then
            local existingSpace = previous.Bottom - (point.Bottom + point.Height)
            local yDelta = vertical - existingSpace
            point.Bottom = point.Bottom - yDelta
        end
    end
]]

-- rearranges a set of frames accoding to the pre-sorted unit positions
secureMethods["TrySortFrames"] = [[
    local framesTableName, unitsTableName, spacingTableName = ...
    local frames = _G[framesTableName]
    local units = _G[unitsTableName]

    EnumerationOrder = newtable()
    OrderedFrames = newtable()

    self:RunAttribute("CopyTable", framesTableName, "OrderedFrames")
    self:RunAttribute("SortFramesByTopLeft", "OrderedFrames")

    local points = newtable()
    for _, frame in ipairs(OrderedFrames) do
        local point = newtable()
        local left, bottom, width, height = frame:GetRect()

        point.Left = left
        point.Bottom = bottom
        point.Width = width
        point.Height = height

        points[#points + 1] = point
    end

    if spacingTableName then
        Points = points

        self:RunAttribute("ApplySpacing", "Points", spacingTableName)
    end

    Root = nil
    local isChain = self:RunAttribute("FrameChain", framesTableName, "Root")
    local enumerationOrder = nil

    if isChain then
        enumerationOrder = newtable()

        local next = Root
        while next do
            enumerationOrder[#enumerationOrder + 1] = next.Value
            next = next.Next
        end
    else
        enumerationOrder = OrderedFrames
    end

    local overflow = #Units
    local movedAny = false

    -- don't move frames if they are have minuscule position differences
    -- it's just a rounding error and makes no visual impact
    -- this helps preventing spam on our callbacks
    local decimalSanity = 2

    for i, source in ipairs(enumerationOrder) do
        Frame = source
        local unit = self:RunAttribute("GetUnit", "Frame")
        Frame = nil

        local desiredIndex = self:RunAttribute("ArrayIndex", unitsTableName, unit)

        if desiredIndex <= 0 then
            -- for any units we don't know about, e.g. players who joined mid-combat
            -- just assume they are last in the sort order until combat drops
            overflow = overflow + 1
            desiredIndex = overflow
        end

        if desiredIndex > 0 and desiredIndex <= #points then
            local left, bottom, width, height = source:GetRect()

            local destination = points[desiredIndex]
            local xDelta = destination.Left - left
            local yDelta = destination.Bottom - bottom

            local xDeltaRounded = self:RunAttribute("Round", xDelta, decimalSanity)
            local yDeltaRounded = self:RunAttribute("Round", yDelta, decimalSanity)

            if xDeltaRounded ~= 0 or yDeltaRounded ~= 0 then
                local point, relativeTo, relativePoint, offsetX, offsetY = source:GetPoint()
                local newOffsetX = (offsetX or 0) + xDelta
                local newOffsetY = (offsetY or 0) + yDelta

                source:SetPoint(point, relativeTo, relativePoint, newOffsetX, newOffsetY)
                movedAny = true
            end
        end
    end

    return movedAny
]]

-- places any frames that have moved back into their pre-combat sorted position
-- requires tables: FramesByProvider, PointsByProvider
secureMethods["TrySortOld"] = [[
    local sorted = false

    -- don't move frames if they are have minuscule position differences
    -- it's just a rounding error and makes no visual impact
    -- this helps preventing spam on our callbacks
    local decimalSanity = 2

    for provider, framesByType in pairs(FramesByProvider) do
        for _, frames in pairs(framesByType) do
            local framesToMove = newtable()

            -- first determine which frames require moving and clear their points
            for _, frame in ipairs(frames) do
                local to = PointsByProvider[provider][frame]
                if to then
                    local point, relativeTo, relativePoint, offsetX, offsetY = frame:GetPoint()

                    local offsetXRounded = self:RunAttribute("Round", offsetX, decimalSanity)
                    local offsetYRounded = self:RunAttribute("Round", offsetY, decimalSanity)
                    local toOffsetXRounded = self:RunAttribute("Round", to.offsetX, decimalSanity)
                    local toOffsetYRounded = self:RunAttribute("Round", to.offsetY, decimalSanity)

                    local different =
                        point ~= to.point or
                        relativeTo ~= to.relativeTo or
                        relativePoint ~= to.relativePoint or
                        offsetXRounded ~= toOffsetXRounded or
                        offsetYRounded ~= toOffsetYRounded

                    if different then
                        framesToMove[#framesToMove + 1] = frame
                        frame:ClearAllPoints()
                    end
                end
            end

            -- now move them after all points have been cleared
            -- to avoid any circular dependency issues
            for _, frame in ipairs(framesToMove) do
                local to = PointsByProvider[provider][frame]

                frame:SetPoint(to.point, to.relativeTo, to.relativePoint, to.offsetX, to.offsetY)
            end

            sorted = sorted or #framesToMove > 0
        end
    end

    return sorted
]]

-- sorts frames based on the pre-combat sorted units array
secureMethods["TrySortNew"] = [[
    local containersTableName = ...
    local containers = _G[containersTableName]
    local sorted = false

    for _, container in ipairs(containers) do
        if container.Frame:IsVisible() then
            Children = newtable()
            Frames = newtable()

            -- import into the global table for filtering
            container.Frame:GetChildList(Children)

            -- filter to unit frames
            self:RunAttribute("ExtractUnitFrames", "Children", "Frames")

            if #Frames > 0 then
                local units = container.UnitType == "Friendly" and FriendlyUnits or EnemyUnits

                -- the frames might be a subset if the container is a raid group
                -- filter units down to only those within the set of frames
                -- as otherwise our algorithm will get confused
                local frameUnits = newtable()

                for _, frame in ipairs(Frames) do
                    Frame = frame
                    local unit = self:RunAttribute("GetUnit", "Frame")
                    Frame = nil
                    frameUnits[unit] = true
                end

                -- now find the units in their sorted order
                Units = newtable()

                for _, unit in ipairs(units) do
                    if frameUnits[unit] then
                        Units[#Units + 1] = unit
                    end
                end

                Spacing = container.Spacing

                if #Units > 0 then
                    -- sort them
                    local framesSorted = self:RunAttribute("TrySortFrames", "Frames", "Units", Spacing and "Spacing")
                    sorted = sorted or framesSorted
                end
            end
        end
    end

    return sorted
]]

-- top level perform sort routine
secureMethods["TrySortWithoutNotify"] = [[
    -- local sortedOld = self:RunAttribute("TrySortOld")
    local sortedNew = self:RunAttribute("TrySortNew", "Containers")
    return sortedOld or sortedNew
]]

-- top level perform sort routine
secureMethods["TrySort"] = [[
    if not self:RunAttribute("InCombat") then
        return false
    end

    -- local sortedOld = self:RunAttribute("TrySortOld")
    local sortedNew = self:RunAttribute("TrySortNew", "Containers")
    local sorted = sortedOld or sortedNew

    if sorted then
        -- notify unsecure code to invoke callbacks
        self:CallMethod("InvokeCallbacks")
    end
]]

-- adds a frame to be watched and to have it's pre-combat positioned restored if it moves
secureMethods["AddFrames"] = [[
    local provider = self:GetAttribute("Provider")
    local frames = FramesByProvider[provider]

    if not frames then
        frames = newtable()
        frames.Arena = newtable()
        frames.Party = newtable()
        frames.Raid = newtable()
        frames.Groups = newtable()
        FramesByProvider[provider] = frames
    end

    local points = PointsByProvider[provider]

    if not points then
        points = newtable()
        PointsByProvider[provider] = points
    end

    local count = self:GetAttribute("FramesCount")
    local type = self:GetAttribute("FrameType")

    for i = 1, count do
        local frame = self:GetFrameRef("Frame" .. i)
        local point, relativeTo, relativePoint, offsetX, offsetY = frame:GetPoint()
        local data = newtable()

        data.point = point
        data.relativeTo = relativeTo
        data.relativePoint = relativePoint
        data.offsetX = offsetX
        data.offsetY = offsetY

        local destination = frames[type]
        destination[#destination + 1] = frame
        points[frame] = data
    end
]]

-- clears all global state
secureMethods["ClearState"] = [[
    FramesByProvider = wipe(FramesByProvider)
    PointsByProvider = wipe(PointsByProvider)
    Containers = wipe(Containers)
    FriendlyUnits = wipe(FriendlyUnits)
    EnemyUnits = wipe(EnemyUnits)
]]

secureMethods["Init"] = [[
    Header = self
    FramesByProvider = newtable()
    PointsByProvider = newtable()
    Containers = newtable()
    FriendlyUnits = newtable()
    EnemyUnits = newtable()
]]

local function AddFrames(header, provider, frames, type)
    if #frames == 0 then return end

    header:SetAttribute("FrameType", type)
    header:SetAttribute("Provider", provider:Name())
    header:SetAttribute("FramesCount", #frames)

    for i, frame in ipairs(frames) do
        header:SetFrameRef("Frame" .. i, frame)
    end

    header:Execute([[ self:RunAttribute("AddFrames") ]])
end

local function LoadFrames()
    local blizzard = fsProviders.Blizzard
    local friendlyEnabled, _, _, _ = fsCompare:FriendlySortMode()

    if not blizzard:Enabled() or not friendlyEnabled then return end

    local raidUngrouped = blizzard:RaidFrames()
    local groups = {}

    if blizzard:IsRaidGrouped() then
        groups = blizzard:RaidGroups()
    end

    for _, header in ipairs(headers) do
        AddFrames(header, blizzard, raidUngrouped, "Raid")
        AddFrames(header, blizzard, groups, "Groups")
    end
end

-- TODO: move all providers to use this and delete the AddFrames() stuff
local function LoadContainers()
    local friendlyEnabled = fsCompare:FriendlySortMode()
    local enemyEnabled = fsCompare:EnemySortMode()
    local containers = {}
    local appearance = addon.DB.Options.Appearance

    local elvui = fsProviders.ElvUI
    if friendlyEnabled and elvui:Enabled() then
        containers[#containers + 1] = {
            Frame = elvui:PartyContainer(),
            UnitType = "Friendly"
        }
    end

    local blizzard = fsProviders.Blizzard
    if blizzard:Enabled() then
        if friendlyEnabled then
            containers[#containers + 1] = {
                Frame = blizzard:PartyContainer(),
                UnitType = "Friendly",
                Spacing = appearance.Party.Spacing
            }

            local groups = blizzard:RaidGroups()

            for _, group in ipairs(groups) do
                containers[#containers + 1] = {
                    Frame = group,
                    UnitType = "Friendly",
                    Spacing = appearance.Raid.Spacing
                }
            end
        end

        if enemyEnabled then
            containers[#containers + 1] = {
                Frame = blizzard:EnemyArenaContainer(),
                UnitType = "Enemy",
                Spacing = appearance.EnemyArena.Spacing
            }
        end
    end

    local gex = fsProviders.GladiusEx
    if gex:Enabled() then
        if friendlyEnabled then
            containers[#containers + 1] = {
                Frame = gex:PartyContainer(),
                UnitType = "Friendly"
            }
        end

        if enemyEnabled then
            containers[#containers + 1] = {
                Frame = gex:EnemyArenaContainer(),
                UnitType = "Enemy"
            }
        end
    end

    local sarena = fsProviders.sArena
    if enemyEnabled and sarena:Enabled() then
        containers[#containers + 1] = {
            Frame = sarena:EnemyArenaContainer(),
            UnitType = "Enemy"
        }
    end

    containers = fsEnumerable
        :From(containers)
        :Where(function(x) return x.Frame ~= nil end)
        :ToTable()

    if #containers == 0 then return end

    for _, header in ipairs(headers) do
        for i, container in ipairs(containers) do
            header:SetFrameRef("Container" .. i, container.Frame)
            header:SetAttribute("ContainerUnitType" .. i, container.UnitType)
            header:SetAttribute("ContainerSpacingVertical" .. i, container.Spacing and container.Spacing.Vertical)
            header:SetAttribute("ContainerSpacingHorizontal" .. i, container.Spacing and container.Spacing.Vertical)
        end

        header:SetAttribute("ContainersCount", #containers)
        header:Execute([[
            local count = self:GetAttribute("ContainersCount")

            for i = 1, count do
                local frame = self:GetFrameRef("Container" .. i)
                local unitType = self:GetAttribute("ContainerUnitType" .. i)
                local spacingHorizontal = self:GetAttribute("ContainerSpacingHorizontal" .. i)
                local spacingVertical = self:GetAttribute("ContainerSpacingVertical" .. i)

                local container = newtable()
                container.Frame = frame
                container.UnitType = unitType

                if spacingHorizontal or spacingVertical then
                    container.Spacing = newtable()
                    container.Spacing.Horizontal = spacingHorizontal or 0
                    container.Spacing.Vertical = spacingVertical or 0
                end

                Containers[#Containers + 1] = container
            end
        ]])
    end
end

local function LoadUnits()
    local friendlyEnabled = fsCompare:FriendlySortMode()
    local enemyEnabled = fsCompare:EnemySortMode()

    -- TODO: we could transfer unit info to the restricted environment
    -- then perform the unit sort inside which would give us more control
    local friendlyUnits = friendlyEnabled and fsUnit:FriendlyUnits() or {}
    local enemyUnits = enemyEnabled and fsUnit:EnemyUnits() or {}

    if #friendlyUnits == 0 and #enemyUnits == 0 then return end

    if friendlyEnabled then
        local friendlyCompare = fsCompare:SortFunction(friendlyUnits)
        table.sort(friendlyUnits, friendlyCompare)
    end

    if enemyEnabled then
        local enemyCompare = fsCompare:EnemySortFunction()
        table.sort(enemyUnits, enemyCompare)
    end

    for _, header in ipairs(headers) do
        for i, unit in ipairs(friendlyUnits) do
            header:SetAttribute("FriendlyUnit" .. i, unit)
        end

        for i, unit in ipairs(enemyUnits) do
            header:SetAttribute("EnemyUnit" .. i, unit)
        end

        header:SetAttribute("FriendlyUnitsCount", #friendlyUnits)
        header:SetAttribute("EnemyUnitsCount", #enemyUnits)

        header:Execute([[
            local friendlyUnitsCount = self:GetAttribute("FriendlyUnitsCount")
            local enemyUnitsCount = self:GetAttribute("EnemyUnitsCount")

            for i = 1, friendlyUnitsCount do
                local unit = self:GetAttribute("FriendlyUnit" .. i)
                FriendlyUnits[#FriendlyUnits + 1] = unit
            end

            for i = 1, enemyUnitsCount do
                local unit = self:GetAttribute("EnemyUnit" .. i)
                EnemyUnits[#EnemyUnits + 1] = unit
            end
        ]])
    end
end

local function ProtectContainers()
    for _, provider in ipairs(fsProviders:Enabled()) do
        local containers = {
            provider:RaidContainer(),
            provider:PartyContainer(),
            provider:EnemyArenaContainer()
        }

        -- to fix a current blizzard bug where GetPoint() returns nil values on secure frames when their parent's are unsecure
        -- https://github.com/Stanzilla/WoWUIBugs/issues/470
        -- https://github.com/Stanzilla/WoWUIBugs/issues/480
        for _, container in pairs(containers) do
            container:SetProtected()
        end
    end
end

local function ClearState()
    for _, header in ipairs(headers) do
        header:Execute([[ self:RunAttribute("ClearState") ]])
    end
end

local function LoadState()
    ClearState()

    local friendlyEnabled, _, _, _ = fsCompare:FriendlySortMode()
    local enemyEnabled, _, _ = fsCompare:EnemySortMode()

    if not friendlyEnabled and not enemyEnabled then return end

    ProtectContainers()
    LoadUnits()
    LoadContainers()
    LoadFrames()
end

function OnEvent(_, event)
    if event == wow.Events.PLAYER_REGEN_DISABLED then
        LoadState()
    end
end

local function InjectSecureHelpers(secureFrame)
    if not secureFrame.Execute then
        function secureFrame:Execute(body)
            return wow.SecureHandlerExecute(self, body)
        end
    end

    if not secureFrame.WrapScript then
        function secureFrame:WrapScript(frame, script, preBody, postBody)
            return wow.SecureHandlerWrapScript(frame, script, self, preBody, postBody)
        end
    end

    if not secureFrame.SetFrameRef then
        function secureFrame:SetFrameRef(label, refFrame)
            return wow.SecureHandlerSetFrameRef(self, label, refFrame)
        end
    end
end

local function ConfigureHeader(header)
    InjectSecureHelpers(header)

    function header:InvokeCallbacks()
        fsSorting:InvokeCallbacks()
    end

    for name, snippet in pairs(secureMethods) do
        header:SetAttribute(name, snippet)
    end

    header:Execute([[ self:RunAttribute("Init") ]])

    -- show as much as possible
    header:SetAttribute("showRaid", true)
    header:SetAttribute("showParty", true)
    header:SetAttribute("showPlayer", true)
    header:SetAttribute("showSolo", true)

    -- unit buttons template type
    header:SetAttribute("template", "SecureHandlerAttributeTemplate")

    -- fired when a new unit button is created
    header:SetAttribute("initialConfigFunction", [=[
        -- self = the newly created unit button
        self:SetWidth(0)
        self:SetHeight(0)
        self:SetAttribute("Header", Header)

        -- secure snippet for refreshing unit ids on frames
        -- which we can then use to invoke our sorting
        RefreshUnitChange = [[
            local unit = self:GetAttribute("unit")
            local header = self:GetAttribute("Header")
            header:RunAttribute("TrySort")
        ]]

        self:SetAttribute("refreshUnitChange", RefreshUnitChange)
    ]=])

    -- TODO: delete these workaround triggers once it's all fixed
    wow.RegisterAttributeDriver(header, "state-framesort-target", "[@target, exists] true; false")
    wow.RegisterAttributeDriver(header, "state-framesort-modifier", "[mod] true; false")

    for i = 1, wow.MAX_RAID_MEMBERS do
        wow.RegisterAttributeDriver(header, "state-framesort-raid" .. i, string.format("[@raid%d, exists] true; false", i))
        wow.RegisterAttributeDriver(header, "state-framesort-raidpet" .. i, string.format("[@raidpet%d, exists] true; false", i))
    end

    for i = 1, wow.MEMBERS_PER_RAID_GROUP - 1 do
        wow.RegisterAttributeDriver(header, "state-framesort-party" .. i, string.format("[@party%d, exists] true; false", i))
        wow.RegisterAttributeDriver(header, "state-framesort-partypet" .. i, string.format("[@partypet%d, exists] true; false", i))
    end

    header:WrapScript(
        header,
        "OnAttributeChanged",
        [[
            if not strmatch(name, "framesort") then return end

            self:RunAttribute("TrySort")
        ]]
    )

    -- must be shown for it to work
    header:SetPoint("TOPLEFT", wow.UIParent, "TOPLEFT")
    header:Show()
end

function M:Init()
    local combatEndFrame = wow.CreateFrame("Frame")
    combatEndFrame:HookScript("OnEvent", OnEvent)
    combatEndFrame:RegisterEvent(wow.Events.PLAYER_REGEN_DISABLED)

    local groupHeader = wow.CreateFrame("Frame", "FrameSortGroupHeader", wow.UIParent, "SecureGroupHeaderTemplate")
    local petHeader = wow.CreateFrame("Frame", "FrameSortPetGroupHeader", wow.UIParent, "SecureGroupPetHeaderTemplate")

    headers = { groupHeader, petHeader }

    for _, header in ipairs(headers) do
        ConfigureHeader(header)
    end
end

---Attempts to sort frames.
---@return boolean sorted true if sorted, otherwise false.
---@param provider FrameProvider the provider to sort.
function M:TrySort(provider)
    -- ClearState()
    --
    -- local friendlyEnabled, _, _, _ = fsCompare:FriendlySortMode()
    -- local enemyEnabled, _, _ = fsCompare:EnemySortMode()
    --
    -- if not friendlyEnabled and not enemyEnabled then return false end
    --
    -- ProtectContainers()
    -- LoadUnits()
    -- LoadContainers()
    -- LoadFrames()
    --
    -- local header = headers[1]
    -- header:SetAttribute("TrySortResult", nil)
    -- header:Execute([[
    --     local sorted = self:RunAttribute("TrySortWithoutNotify")
    --     self:SetAttribute("TrySortResult", sorted)
    -- ]])
    --
    -- return header:GetAttribute("TrySortResult")
    return fsSorting.Core:TrySort(provider)
end
