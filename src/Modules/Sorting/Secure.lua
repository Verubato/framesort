---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsSorting = addon.Modules.Sorting
local fsCompare = addon.Collections.Comparer
local fsProviders = addon.Providers
local fsEnumerable = addon.Collections.Enumerable
local M = {}
addon.Modules.Sorting.Secure = M

local headers = nil

local function AddFrames(header, provider, frames, type)
    header:SetAttribute("FS-FrameType", type)
    header:SetAttribute("FS-Provider", provider:Name())

    for _, frame in ipairs(frames) do
        header:SetFrameRef("frame", frame)
        header:Execute([[
            local provider = self:GetAttribute("FS-Provider")
            local frames = FramesByProvider[provider]
            local points = PointsByProvider[provider]
            local frame = self:GetFrameRef("frame")
            local destination = self:GetAttribute("FS-FrameType")
            local point, relativeTo, relativePoint, offsetX, offsetY = frame:GetPoint()
            local data = newtable()

            data.point = point
            data.relativeTo = relativeTo
            data.relativePoint = relativePoint
            data.offsetX = offsetX
            data.offsetY = offsetY

            tinsert(frames[destination], frame)
            points[frame] = data
        ]])
    end
end

---@param provider FrameProvider
local function StoreFrames(header, provider)
    header:SetAttribute("FS-Provider", provider:Name())

    -- clear existing frames
    header:Execute([[
        local provider = self:GetAttribute("FS-Provider")
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
    ]])

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

        for _, header in ipairs(headers) do
            StoreFrames(header, provider)
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

    -- state tables
    header:Execute([=[
        Header = self
        FramesByProvider = newtable()
        PointsByProvider = newtable()
    ]=])

    -- some utility functions
    header:SetAttribute("FS-Round", [[
        local number, decimalPlaces = ...

        if number == nil then return nil end

        local mult = 10 ^ (decimalPlaces or 0)
        return math.floor(number * mult + 0.5) / mult
    ]])

    header:SetAttribute("FS-InCombat", [[
        return SecureCmdOptionParse("[combat] true; false") == "true"
    ]])

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
        self:SetAttribute("FS-Header", Header)

        -- secure snippet for refreshing unit ids on frames
        -- which we can then use to invoke our sorting
        RefreshUnitChange = [[
            local header = self:GetAttribute("FS-Header")
            header:RunAttribute("FS-TrySort")
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

    header:SetAttribute("FS-TrySort", [[
        if not self:RunAttribute("FS-InCombat") then
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

                        local offsetXRounded = self:RunAttribute("FS-Round", offsetX, decimalSanity)
                        local offsetYRounded = self:RunAttribute("FS-Round", offsetY, decimalSanity)
                        local toOffsetXRounded = self:RunAttribute("FS-Round", to.offsetX, decimalSanity)
                        local toOffsetYRounded = self:RunAttribute("FS-Round", to.offsetY, decimalSanity)

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

        return sorted
    ]])

    header:WrapScript(
        header,
        "OnAttributeChanged",
        [[
            if not strmatch(name, "framesort") then return end

            self:RunAttribute("FS-TrySort")
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
