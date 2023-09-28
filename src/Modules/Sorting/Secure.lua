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

local headers = nil
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

-- filters a set of frames to only unit frames
-- requires globals: Children
secureMethods["ExtractUnitFrames"] = [[
    local frames = newtable()
    for _, child in ipairs(Children) do
        local unit = child:GetAttribute("unit")

        if unit then
            frames[#frames + 1] = child
        end
    end

    Frames = frames
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
        local frameUnit = frame:GetAttribute("unit")
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
-- modifies the "Root" global variable as secure methods cannot return complex types
secureMethods["FrameChain"] = [[
    local framesArrayName = ...
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
        return false, nil
    end

    Root = root

    return true, "Root"
]]

-- performs an in place sort on an array of frames by their visual order
secureMethods["SortByVisualOrder"] = [[
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

-- rearranges a set of frames accoding to the pre-sorted unit positions
-- requires globals: Frames, Units
secureMethods["TrySortFrames"] = [[
    -- TODO: figure out proper order from GetPoint() frame chain
    EnumerationOrder = newtable()
    OrderedFrames = newtable()

    self:RunAttribute("CopyTable", "Frames", "OrderedFrames")
    self:RunAttribute("SortByVisualOrder", "OrderedFrames")

    local points = newtable()
    for _, frame in ipairs(OrderedFrames) do
        local point = newtable()
        local left, bottom, width, height = frame:GetRect()

        point.Left = left
        point.Bottom = bottom
        point.Width = width
        point.Height = height
        point.Top = bottom + height

        points[#points + 1] = point
    end

    local isChain, rootVariableName = self:RunAttribute("FrameChain", "Frames")
    local enumerationOrder = nil

    if isChain then
        local root = _G[rootVariableName]
        enumerationOrder = newtable()

        local next = root
        while next do
            enumerationOrder[#enumerationOrder + 1] = next.Value
            next = next.Next
        end
    else
        enumerationOrder = Frames
    end

    local overflow = #Units
    local movedAny = false

    -- don't move frames if they are have minuscule position differences
    -- it's just a rounding error and makes no visual impact
    -- this helps preventing spam on our callbacks
    local decimalSanity = 2

    for i, source in ipairs(enumerationOrder) do
        local unit = source:GetAttribute("unit")
        local desiredIndex = self:RunAttribute("ArrayIndex", "Units", unit)

        if desiredIndex <= 0 then
            -- for any units we don't know about, e.g. players who joined mid-combat
            -- just assume they are last in the sort order until combat drops
            overflow = overflow + 1
            desiredIndex = overflow
        end

        if desiredIndex > 0 and desiredIndex <= #points then
            local left, bottom, width, height = source:GetRect()
            local top = bottom + height

            local destination = points[desiredIndex]
            local xDelta = destination.Left - left
            local yDelta = destination.Top - top

            xDelta = self:RunAttribute("Round", xDelta, decimalSanity)
            yDelta = self:RunAttribute("Round", yDelta, decimalSanity)

            if xDelta ~= 0 or yDelta ~= 0 then
                local point, relativeTo, relativePoint, offsetX, offsetY = source:GetPoint()
                local newOffsetX = offsetX + xDelta
                local newOffsetY = offsetY + yDelta

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
    if not self:RunAttribute("InCombat") then
        return false
    end

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
-- requires tables: Containers
secureMethods["TrySortNew"] = [[
    if not self:RunAttribute("InCombat") then
        return false
    end

    Children = wipe(Children)
    Frames = wipe(Frames)

    local sorted = false

    for _, container in ipairs(Containers) do
        -- import into the global table for filtering
        container:GetChildList(Children)

        -- filter to unit frames
        self:RunAttribute("ExtractUnitFrames")

        -- TODO: determine which units to use
        Units = FriendlyUnits

        -- sort them
        local framesSorted = self:RunAttribute("TrySortFrames")
        sorted = sorted or framesSorted

        Children = wipe(Children)
        Frames = wipe(Frames)
    end

    return sorted
]]

-- top level perform sort routine
secureMethods["TrySort"] = [[
    local sortedOld = self:RunAttribute("TrySortOld")
    local sortedNew = self:RunAttribute("TrySortNew")
    local sorted = sortedOld or sortedNew

    if sorted then
        -- notify unsecure code to invoke callbacks
        self:CallMethod("InvokeCallbacks")
    end
]]

-- adds a frame to be watched and to have it's pre-combat positioned restored if it moves
secureMethods["AddFrame"] = [[
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

    local frame = self:GetFrameRef("frame")
    local destination = self:GetAttribute("FrameType")
    local point, relativeTo, relativePoint, offsetX, offsetY = frame:GetPoint()
    local data = newtable()

    data.point = point
    data.relativeTo = relativeTo
    data.relativePoint = relativePoint
    data.offsetX = offsetX
    data.offsetY = offsetY

    tinsert(frames[destination], frame)
    points[frame] = data
]]

-- clears all global state
secureMethods["ClearState"] = [[
    FramesByProvider = wipe(FramesByProvider)
    PointsByProvider = wipe(PointsByProvider)
    Containers = wipe(Containers)
    FriendlyUnits = wipe(FriendlyUnits)
    EnemyUnits = wipe(EnemyUnits)
    Children = wipe(Children)
    Frames = wipe(Frames)
]]

secureMethods["Init"] = [[
    Header = self
    FramesByProvider = newtable()
    PointsByProvider = newtable()
    Containers = newtable()
    FriendlyUnits = newtable()
    EnemyUnits = newtable()
    Children = newtable()
    Frames = newtable()
]]

local function AddFrames(header, provider, frames, type)
    header:SetAttribute("FrameType", type)
    header:SetAttribute("Provider", provider:Name())

    for _, frame in ipairs(frames) do
        header:SetFrameRef("frame", frame)
        header:Execute([[self:RunAttribute("AddFrame")]])
    end
end

local function StoreFrames(header, provider)
    local friendlyEnabled, _, _, _ = fsCompare:FriendlySortMode()
    local enemyEnabled, _, _ = fsCompare:EnemySortMode()
    local party = {}
    local raidUngrouped = {}
    local raid = {}
    local groups = {}
    local arena = {}

    if friendlyEnabled then
        party = provider:PartyFrames()
        raidUngrouped = provider:RaidFrames()

        if provider:IsRaidGrouped() then
            groups = provider:RaidGroups()
            raid = fsEnumerable
                :From(groups)
                :Map(function(group)
                    return provider:RaidGroupMembers(group)
                end)
                :Flatten()
                :ToTable()
        end
    end

    if enemyEnabled and wow.IsRetail() then
        arena = provider:EnemyArenaFrames()
    end

    AddFrames(header, provider, party, "Party")
    AddFrames(header, provider, raid, "Raid")
    AddFrames(header, provider, raidUngrouped, "Raid")
    AddFrames(header, provider, groups, "Groups")
    AddFrames(header, provider, arena, "Arena")
end

function OnCombatStarting()
    assert(headers ~= nil)

    -- TODO: we could transfer unit info to the restricted environment
    -- then perform the unit sort inside which would give us more control
    local friendlyUnits = fsUnit:FriendlyUnits()
    local enemyUnits = fsUnit:EnemyUnits()
    local friendlyCompare = fsCompare:SortFunction(friendlyUnits)
    local enemyCompare = fsCompare:EnemySortFunction()

    table.sort(friendlyUnits, friendlyCompare)
    table.sort(enemyUnits, enemyCompare)

    -- reset state
    for _, header in ipairs(headers) do
        header:Execute([[ self:RunAttribute("ClearState") ]])
    end

    -- import new state
    for _, header in ipairs(headers) do
        for _, unit in ipairs(friendlyUnits) do
            header:SetAttribute("Unit", unit)
            header:Execute([[
                local unit = self:GetAttribute("Unit")
                FriendlyUnits[#FriendlyUnits + 1] = unit
            ]])
        end

        for _, unit in ipairs(enemyUnits) do
            header:SetAttribute("Unit", unit)
            header:Execute([[
                local unit = self:GetAttribute("Unit")
                EnemyUnits[#EnemyUnits + 1] = unit
            ]])
        end

        -- use the new sorting method for elvui
        local provider = fsProviders.ElvUI
        local containers = {
            provider:RaidContainer(),
            provider:PartyContainer(),
            provider:EnemyArenaContainer()
        }

        for _, container in pairs(containers) do
            header:SetFrameRef("Container", container)
            header:Execute([[
                local container = self:GetFrameRef("Container")
                Containers[#Containers + 1] = container
            ]])
        end
    end

    for _, provider in ipairs(fsProviders:Enabled()) do
        -- elvui is using the new "containers" method
        if provider ~= fsProviders.ElvUI then
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

            for _, header in ipairs(headers) do
                StoreFrames(header, provider)
            end
        end
    end
end

function OnEvent(_, event)
    if event == wow.Events.PLAYER_REGEN_DISABLED then
        OnCombatStarting()
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
    return fsSorting.Core:TrySort(provider)
end
