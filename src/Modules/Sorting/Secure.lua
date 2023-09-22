---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsSorting = addon.Modules.Sorting
local fsCompare = addon.Collections.Comparer
local fsProviders = addon.Providers
local fsEnumerable = addon.Collections.Enumerable
local M = {}
addon.Modules.Sorting.Secure = M

local secureManager = nil
local groupHeader = nil
local petHeader = nil

local addFrameScript = [[
    local provider = self:GetAttribute("provider")
    local frames = FramesByProvider[provider]
    local points = PointsByProvider[provider]
    local frame = self:GetFrameRef("frame")
    local destination = self:GetAttribute("frameType")
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

local clearFramesScript = [[
    local provider = self:GetAttribute("provider")
    local frames = FramesByProvider[provider]

    if not frames then
        frames = newtable()
        frames.Party = newtable()
        frames.Raid = newtable()
        frames.Arena = newtable()
        frames.Groups = newtable()

        FramesByProvider[provider] = frames
    else
        frames.Party = wipe(frames.Party)
        frames.Raid = wipe(frames.Raid)
        frames.Arena = wipe(frames.Arena)
        frames.Groups = wipe(frames.Groups)
    end

    local points = PointsByProvider[provider]
    PointsByProvider[provider] = points and wipe(points) or newtable()
]]

local function AddFrames(frames, type)
    assert(secureManager ~= nil)

    for _, frame in ipairs(frames) do
        secureManager:SetFrameRef("frame", frame)
        secureManager:SetAttribute("frameType", type)
        secureManager:Execute(addFrameScript)
    end
end

---@param provider FrameProvider
local function StoreFrames(provider)
    assert(secureManager ~= nil)

    secureManager:SetAttribute("provider", provider:Name())
    secureManager:Execute(clearFramesScript)

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

    AddFrames(party, "Party")
    AddFrames(raid, "Raid")
    AddFrames(raidUngrouped, "Raid")
    AddFrames(groups, "Groups")
    AddFrames(arena, "Arena")
end

function OnCombatStarting()
    for _, provider in ipairs(fsProviders:Enabled()) do
        StoreFrames(provider)

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

local function ConfigureHeader(header, manager)
    InjectSecureHelpers(header)
    header:SetFrameRef("Manager", manager)

    -- secure snippet for refreshing unit ids on frames
    -- which we can then use to invoke our sorting
    header:Execute([=[
        Header = self
        Manager = self:GetFrameRef("Manager")

        RefreshUnitChange = [[
            local unit = self:GetAttribute("unit")
            local frame = self:GetAttribute("UnitFrame")

            if frame then
                frame:SetAttribute("unit", unit)
            end

            local manager = self:GetAttribute("Manager")
            local run = manager:GetAttribute("state-framesort-run-toggle")
            manager:SetAttribute("state-framesort-run-toggle", not run)
        ]]
    ]=])

    -- show as much as possible
    header:SetAttribute("showRaid", true)
    header:SetAttribute("showParty", true)
    header:SetAttribute("showPlayer", true)
    header:SetAttribute("showSolo", true)

    -- unit buttons template type
    header:SetAttribute("template", "SecureHandlerAttributeTemplate")

    -- fired when a new unit button is created
    header:SetAttribute("initialConfigFunction", [[
        -- self = the newly created unit button
        self:SetWidth(0)
        self:SetHeight(0)
        self:SetAttribute("Header", Header)
        self:SetAttribute("Manager", Manager)
        self:SetAttribute("refreshUnitChange", RefreshUnitChange)
    ]])

    -- must be shown for it to work
    header:SetPoint("TOPLEFT", wow.UIParent, "TOPLEFT")
    header:Show()
end

function M:Init()
    secureManager = wow.CreateFrame("Frame", nil, wow.UIParent, "SecureHandlerStateTemplate")
    InjectSecureHelpers(secureManager)

    secureManager:HookScript("OnEvent", OnEvent)
    secureManager:RegisterEvent(wow.Events.PLAYER_REGEN_DISABLED)

    function secureManager:InvokeCallbacks()
        fsSorting:InvokeCallbacks()
    end

    -- tables to store frames that we manage
    secureManager:Execute([[
        FramesByProvider = newtable()
        PointsByProvider = newtable()
    ]])

    -- some utility functions
    secureManager:Execute([=[
        Round = [[
            local number, decimalPlaces = ...

            if number == nil then return nil end

            local mult = 10 ^ (decimalPlaces or 0)
            return math.floor(number * mult + 0.5) / mult
        ]]

        InCombat = [[
            return SecureCmdOptionParse("[combat] true; false") == "true"
        ]]
    ]=])

    -- main function to restore frame positions
    -- TODO: see if possible to perform full sorting/spacing instead of just retaining positions
    secureManager:Execute([=[
        RestoreFrames = [[
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

                            local offsetXRounded = self:Run(Round, offsetX, decimalSanity)
                            local offsetYRounded = self:Run(Round, offsetY, decimalSanity)
                            local toOffsetXRounded = self:Run(Round, to.offsetX, decimalSanity)
                            local toOffsetYRounded = self:Run(Round, to.offsetY, decimalSanity)

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

            if sorted then
                -- notify unsecure code to invoke callbacks
                self:CallMethod("InvokeCallbacks")
            end
        ]]
    ]=])

    -- triggers
    secureManager:WrapScript(
        secureManager,
        "OnAttributeChanged",
        [[
            if not strmatch(name, "framesort") then return end
            if not self:Run(InCombat) then return end

            self:Run(RestoreFrames)
        ]]
    )

    groupHeader = wow.CreateFrame("Frame", nil, nil, "SecureGroupHeaderTemplate")
    ConfigureHeader(groupHeader, secureManager)

    petHeader = wow.CreateFrame("Frame", nil, nil, "SecureGroupPetHeaderTemplate")
    ConfigureHeader(petHeader, secureManager)

    wow.RegisterAttributeDriver(secureManager, "state-framesort-target", "[@target, exists] true; false")
    wow.RegisterAttributeDriver(secureManager, "state-framesort-modifier", "[mod] true; false")

    for i = 1, wow.MAX_RAID_MEMBERS do
        wow.RegisterAttributeDriver(secureManager, "state-framesort-raid" .. i, string.format("[@raid%d, exists] true; false", i))
        wow.RegisterAttributeDriver(secureManager, "state-framesort-raidpet" .. i, string.format("[@raidpet%d, exists] true; false", i))
    end

    for i = 1, wow.MEMBERS_PER_RAID_GROUP - 1 do
        wow.RegisterAttributeDriver(secureManager, "state-framesort-party" .. i, string.format("[@party%d, exists] true; false", i))
        wow.RegisterAttributeDriver(secureManager, "state-framesort-partypet" .. i, string.format("[@partypet%d, exists] true; false", i))
    end
end

---Attempts to sort frames.
---@return boolean sorted true if sorted, otherwise false.
---@param provider FrameProvider the provider to sort.
function M:TrySort(provider)
    return fsSorting.Core:TrySort(provider)
end
