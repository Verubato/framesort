---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsSorting = addon.Modules.Sorting
local fsCompare = addon.Collections.Comparer
local fsProviders = addon.Providers
local fsEnumerable = addon.Collections.Enumerable
local fsUnit = addon.WoW.Unit
local fsScheduler = addon.Scheduling.Scheduler
local fsConfig = addon.Configuration
local fsLog = addon.Logging.Log
local M = {}
addon.Modules.Sorting.Secure.InCombat = M

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
    local framesVariable = ...
    local frame = _G[framesVariable]

    local unit = frame:GetAttribute("unit")

    if unit then return unit end

    local name = frame:GetName()
    if name and strmatch(name, "GladiusExButtonFrame") then
        unit = gsub(name, "GladiusExButtonFrame", "")
        return unit
    end

    return nil
]]

-- filters a set of frames to only unit frames
secureMethods["ExtractUnitFrames"] = [[
    local framesVariable, destinationVariable, visibleOnly = ...
    local children = _G[framesVariable]
    local unitFrames = newtable()

    for _, child in ipairs(children) do
        Frame = child
        local unit = self:RunAttribute("GetUnit", "Frame")
        Frame = nil

        if unit and (child:IsVisible() or not visibleOnly) then
            unitFrames[#unitFrames + 1] = child
        end
    end

    _G[destinationVariable] = unitFrames
    return #unitFrames > 0
]]

-- extracts a set of groups from a container
secureMethods["ExtractGroups"] = [[
    local containerTableName, destinationTableName = ...
    local container = _G[containerTableName]
    local children = newtable()

    container.Frame:GetChildList(children)
    if #children == 0 then return false end

    local groups = newtable()

    for _, child in ipairs(children) do
        local name = child:GetName()

        if child:IsVisible() and name and strmatch(name, "CompactRaidGroup") then
            groups[#groups + 1] = child
        end
    end

    _G[destinationTableName] = groups
    return #groups > 0
]]

-- returns the index of the item within the array, or -1 if it doesn't exist
secureMethods["ArrayIndex"] = [[
    local arrayVariable, item = ...
    local array = _G[arrayVariable]

    for i, value in ipairs(array) do
        if value == item then
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
    local framesVariable, destinationVariable = ...
    local frames = _G[framesVariable]
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

    _G[destinationVariable] = root

    return true
]]

-- performs an in place sort on an array of frames by their visual order
secureMethods["SortFramesByTopLeft"] = [[
    local framesVariable = ...
    local frames = _G[framesVariable]

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
    local pointsVariable = ...
    local points = _G[pointsVariable]

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
    local pointsVariable = ...
    local points = _G[pointsVariable]

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
    local pointsVariable, spacingVariable = ...
    local points = _G[pointsVariable]
    local spacing = _G[spacingVariable]
    local horizontal = spacing.Horizontal or 0
    local vertical = spacing.Vertical or 0

    OrderedTopLeft = newtable()
    OrderedLeftTop = newtable()

    self:RunAttribute("CopyTable", pointsVariable, "OrderedTopLeft")
    self:RunAttribute("CopyTable", pointsVariable, "OrderedLeftTop")

    self:RunAttribute("SortPointsByTopLeft", "OrderedTopLeft")
    self:RunAttribute("SortPointsByLeftTop", "OrderedLeftTop")

    local changed = false

    for i = 2, #OrderedLeftTop do
        local point = OrderedLeftTop[i]
        local previous = OrderedLeftTop[i - 1]
        local sameRow = self:RunAttribute("Round", point.Bottom) == self:RunAttribute("Round", previous.Bottom)

        if sameRow then
            local existingSpace = point.Left - (previous.Left + previous.Width)
            local xDelta = horizontal - existingSpace
            point.Left = point.Left + xDelta
            changed = changed or xDelta ~= 0
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
            changed = changed or yDelta ~= 0
        end
    end

    return changed
]]

-- rearranges a set of frames accoding to the pre-sorted unit positions
secureMethods["SoftArrange"] = [[
    local framesVariable, unitsVariable, spacingVariable = ...
    local frames = _G[framesVariable]
    local units = _G[unitsVariable]

    EnumerationOrder = newtable()
    OrderedFrames = newtable()

    self:RunAttribute("CopyTable", framesVariable, "OrderedFrames")
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

    if spacingVariable then
        Points = points

        self:RunAttribute("ApplySpacing", "Points", spacingVariable)
    end

    Root = nil
    local isChain = self:RunAttribute("FrameChain", framesVariable, "Root")
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

    local overflow = #units
    local movedAny = false

    -- don't move frames if they are have minuscule position differences
    -- it's just a rounding error and makes no visual impact
    -- this helps preventing spam on our callbacks
    local decimalSanity = 2

    for i, source in ipairs(enumerationOrder) do
        Frame = source
        local unit = self:RunAttribute("GetUnit", "Frame")
        Frame = nil

        local desiredIndex = self:RunAttribute("ArrayIndex", unitsVariable, unit)

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
    if not FramesByProvider or not PointsByProvider then return false end

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

-- attempts to sort the frames within the container
secureMethods["TrySortContainer"] = [[
    local friendlyEnabled = self:GetAttribute("FriendlySortEnabled")
    local enemyEnabled = self:GetAttribute("EnemySortEnabled")

    local containerVariable, providerVariable = ...
    local container = _G[containerVariable]
    local provider = _G[providerVariable]

    Children = newtable()
    Frames = newtable()

    -- import into the global table for filtering
    container.Frame:GetChildList(Children)

    -- blizzard frames can have non-existant units assigned, so filter them out
    if not self:RunAttribute("ExtractUnitFrames", "Children", "Frames", provider.IsBlizzard) then
        return false
    end

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

    Spacing = nil

    if provider.IsBlizzard then
        local horizontalSpacing = self:GetAttribute(container.Type .. "SpacingHorizontal")
        local verticalSpacing = self:GetAttribute(container.Type .. "SpacingVertical")

        if (horizontalSpacing and horizontalSpacing ~= 0) or (verticalSpacing and verticalSpacing ~= 0) then
            Spacing = newtable()
            Spacing.Horizontal = horizontalSpacing
            Spacing.Vertical = verticalSpacing
        end
    end

    ContainerSortedUnits = newtable()
    local units = nil

    if container.Type == "Party" then
        units = FriendlyUnits
    elseif container.Type == "Raid" then
        units = FriendlyUnits
    elseif container.Type == "EnemyArena" then
        units = EnemyUnits
    else
        -- TODO: log bug
    end

    -- ensure units is not nil
    units = units or newtable()

    -- now find the units in their sorted order
    for _, unit in ipairs(units) do
        if frameUnits[unit] then
            ContainerSortedUnits[#ContainerSortedUnits + 1] = unit
        end
    end

    return self:RunAttribute("SoftArrange", "Frames", "ContainerSortedUnits", Spacing and "Spacing")
]]

-- sorts frames based on the pre-combat sorted units array
secureMethods["TrySortNew"] = [[
    if not Providers then return false end

    local friendlyEnabled = self:GetAttribute("FriendlySortEnabled")
    local enemyEnabled = self:GetAttribute("EnemySortEnabled")

    if not friendlyEnabled and not enemyEnabled then return false end

    local loadedUnits = self:GetAttribute("LoadedUnits")
    if not loadedUnits then
        self:RunAttribute("LoadUnits")
        self:SetAttribute("LoadedUnits", true)
    end

    local sorted = false

    for _, provider in pairs(Providers) do
        local providerEnabled = self:GetAttribute("Provider" .. provider.Name .. "Enabled")
        if providerEnabled then
            local containers = newtable()

            if friendlyEnabled then
                containers[#containers + 1] = provider.Party

                if provider.Raid and provider.Raid.Frame then
                    if provider.IsBlizzard then
                        Raid = provider.Raid
                        Groups = nil

                        -- TODO: apply spacing between groups
                        if self:RunAttribute("ExtractGroups", "Raid", "Groups") then
                            for _, group in ipairs(Groups) do
                                local groupContainer = newtable()
                                groupContainer.Frame = group
                                groupContainer.Type = provider.Raid.Type

                                containers[#containers + 1] = groupContainer
                            end
                        end

                        Raid = nil
                        Groups = nil
                    else
                        containers[#containers + 1] = provider.Raid
                    end
                end
            end

            if enemyEnabled then
                containers[#containers + 1] = provider.EnemyArena
            end

            for _, container in ipairs(containers) do
                if container.Frame and container.Frame:IsVisible() then
                    Container = container
                    Provider = provider

                    local containerSorted = self:RunAttribute("TrySortContainer", "Container", "Provider")
                    sorted = sorted or containerSorted

                    Provider = nil
                    Container = nil
                end
            end
        end
    end

    return sorted
]]

-- top level perform sort routine
secureMethods["TrySort"] = [[
    if not self:RunAttribute("InCombat") then
        return false
    end

    --local sortedOld = self:RunAttribute("TrySortOld")
    local sortedNew = self:RunAttribute("TrySortNew")

    if sortedOld or sortedNew then
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
        frames.Raid = newtable()
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

secureMethods["LoadProvider"] = [[
    local name = self:GetAttribute("ProviderName")
    local provider = Providers[name]

    if not provider then
        provider = newtable()
        provider.Name = name
        provider.IsBlizzard = name == "Blizzard"
        Providers[name] = provider
    end

    local types = newtable()
    types[#types + 1] = "Party"
    types[#types + 1] = "Raid"
    types[#types + 1] = "EnemyArena"

    for _, type in ipairs(types) do
        local frame = self:GetFrameRef(type .. "Container")
        local hasType = self:GetAttribute(type)

        if frame and hasType then
            local data = newtable()

            data.Frame = frame
            data.Type = type

            provider[type] = data
        end
    end
]]

secureMethods["LoadUnits"] = [[
    FriendlyUnits = newtable()
    EnemyUnits = newtable()

    local friendlyUnitsCount = self:GetAttribute("FriendlyUnitsCount")
    local enemyUnitsCount = self:GetAttribute("EnemyUnitsCount")

    if friendlyUnitsCount then
        for i = 1, friendlyUnitsCount do
            local unit = self:GetAttribute("FriendlyUnit" .. i)
            FriendlyUnits[#FriendlyUnits + 1] = unit
        end
    end

    if enemyUnitsCount then
        for i = 1, enemyUnitsCount do
            local unit = self:GetAttribute("EnemyUnit" .. i)
            EnemyUnits[#EnemyUnits + 1] = unit
        end
    end
]]

secureMethods["Init"] = [[
    Header = self
    Providers = newtable()
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

local function LoadUnits()
    -- TODO: we could transfer unit info to the restricted environment
    -- then perform the unit sort inside which would give us more control
    local friendlyUnits = fsUnit:FriendlyUnits()
    local enemyUnits = fsUnit:EnemyUnits()
    local friendlyCompare = fsCompare:SortFunction(friendlyUnits)
    local enemyCompare = fsCompare:EnemySortFunction()

    table.sort(friendlyUnits, friendlyCompare)
    table.sort(enemyUnits, enemyCompare)

    for _, header in ipairs(headers) do
        for i, unit in ipairs(friendlyUnits) do
            header:SetAttribute("FriendlyUnit" .. i, unit)
        end

        for i, unit in ipairs(enemyUnits) do
            header:SetAttribute("EnemyUnit" .. i, unit)
        end

        header:SetAttribute("FriendlyUnitsCount", #friendlyUnits)
        header:SetAttribute("EnemyUnitsCount", #enemyUnits)
        -- flag that the units need to be reloaded
        header:SetAttribute("LoadedUnits", false)
    end
end

local function LoadEnabled()
    local friendlyEnabled = fsCompare:FriendlySortMode()
    local enemyEnabled = fsCompare:EnemySortMode()

    for _, header in ipairs(headers) do
        header:SetAttribute("FriendlySortEnabled", friendlyEnabled)
        header:SetAttribute("EnemySortEnabled", enemyEnabled)

        for _, provider in ipairs(fsProviders.All) do
            header:SetAttribute("Provider" .. provider:Name() .. "Enabled", provider:Enabled())
        end
    end
end

local function LoadSpacing()
    local appearance = addon.DB.Options.Appearance

    for _, header in ipairs(headers) do
        for type, value in pairs(appearance) do
            header:SetAttribute(type .. "SpacingHorizontal", value.Spacing.Horizontal)
            header:SetAttribute(type .. "SpacingVertical", value.Spacing.Vertical)
        end
    end
end

-- TODO: delete this and use the container approach instaed
local function LoadFrames()
    local blizzard = fsProviders.Blizzard
    local friendlyEnabled, _, _, _ = fsCompare:FriendlySortMode()

    if not blizzard:Enabled() or not friendlyEnabled then return end

    local raidUngrouped = blizzard:RaidFrames()

    for _, header in ipairs(headers) do
        header:Execute([[
            FramesByProvider = newtable()
            PointsByProvider = newtable()
        ]])

        AddFrames(header, blizzard, raidUngrouped, "Raid")
    end
end

---@param provider FrameProvider
local function LoadProvider(provider)
    local data = {
        {
            Container = provider:PartyContainer(),
            Type = "Party"
        },
        {
            Container = provider:RaidContainer(),
            Type = "Raid"
        },
        {
            Container = provider:EnemyArenaContainer(),
            Type = "EnemyArena"
        }
    }

    if provider == fsProviders.Blizzard and provider:IsRaidGrouped() then
        local groups = provider:RaidGroups()

        -- c'mon blizzard, seriously?
        for _, group in ipairs(groups) do
            group:SetProtected()
        end
    end

    -- skip loading the container if we've already loaded it
    -- 99% of the time we've already loaded it
    local shouldLoad = fsEnumerable
        :From(data)
        :Any(function(x)
            return x.Container and not x.Container:GetAttribute("FrameSortLoaded")
        end)

    if not shouldLoad then
        return
    end

    for _, header in ipairs(headers) do
        header:SetAttribute("ProviderName", provider:Name())

        for _, item in ipairs(data) do
            header:SetAttribute(item.Type, item.Container and true or false)

            if item.Container then
                header:SetFrameRef(item.Type .. "Container", item.Container)
            end
        end

        header:Execute([[ self:RunAttribute("LoadProvider") ]])
    end

    for _, item in ipairs(data) do
        if item.Container then
            -- flag as imported
            item.Container:SetAttribute("FrameSortLoaded", true)

            -- to fix a current blizzard bug where GetPoint() returns nil values on secure frames when their parent's are unsecure
            -- https://github.com/Stanzilla/WoWUIBugs/issues/470
            -- https://github.com/Stanzilla/WoWUIBugs/issues/480
            item.Container:SetProtected()
        end
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

    function header:UnitButtonCreated(index)
        local children = { header:GetChildren() }
        local frame = children[index]

        if not frame then
            fsLog:Error("Failed to find unit button " .. index)
            return
        end

        fsScheduler:RunWhenCombatEnds(function()
            frame:SetAttribute("_onattributechanged", [[
                if name == "unit" then
                    local header = self:GetAttribute("Header")
                    header:RunAttribute("TrySort")
                end
            ]])

            -- don't need the refresh script anymore so remove it to reduc enoise
            frame:SetAttribute("refreshUnitChange", nil)
        end)
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

        RefreshUnitChange = [[
            local unit = self:GetAttribute("unit")
            local header = self:GetAttribute("Header")
            header:RunAttribute("TrySort")
        ]]

        self:SetAttribute("refreshUnitChange", RefreshUnitChange)

        UnitButtonsCount = (UnitButtonsCount or 0) + 1
        Header:CallMethod("UnitButtonCreated", UnitButtonsCount)
    ]=])

    -- event ordering in wow is undefined, and blizzard may process GROUP_ROSTER_UPDATE events after we've been notified
    -- so add some attribute triggers to help run our code after blizzard perform their updates
    -- TODO: need more reliable solution to ensure our code runs after blizzard
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

local function OnProviderUpdate(provider)
    -- don't respond to provider events during combat
    if wow.InCombatLockdown() then return end

    -- we may have loaded the provider before it had a chance to initialise itself
    -- so re-import the provider if it's changed
    -- there's likely a better event to place this instead of here as it's too noisy
    LoadProvider(provider)
end

local function OnConfigChanged()
    fsScheduler:RunWhenCombatEnds(function()
        LoadSpacing()
        LoadEnabled()
    end, "SecureSortConfigChanged")
end

function M:Init()
    local groupHeader = wow.CreateFrame("Frame", "FrameSortGroupHeader", wow.UIParent, "SecureGroupHeaderTemplate")
    local petHeader = wow.CreateFrame("Frame", "FrameSortPetGroupHeader", wow.UIParent, "SecureGroupPetHeaderTemplate")

    headers = { groupHeader, petHeader }

    for _, header in ipairs(headers) do
        ConfigureHeader(header)
    end

    for _, provider in ipairs(fsProviders.All) do
        LoadProvider(provider)
        provider:RegisterCallback(OnProviderUpdate)
    end

    LoadEnabled()
    LoadSpacing()
    LoadFrames()

    fsConfig:RegisterConfigurationChangedCallback(OnConfigChanged)
end

function M:RefreshUnits()
    LoadUnits()
    LoadFrames()
end
