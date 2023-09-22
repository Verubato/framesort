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

---@param provider FrameProvider
local function StoreFrames(provider)
    assert(secureManager ~= nil)

    secureManager:SetAttribute("provider", provider:Name())
    secureManager:Execute([[
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
    ]])

    local friendlyEnabled, _, _, _ = fsCompare:FriendlySortMode()
    local enemyEnabled, _, _ = fsCompare:EnemySortMode()
    local party = {}
    local raid = {}
    local groups = {}
    local arena = {}

    if friendlyEnabled then
        party = provider:PartyFrames()

        if provider:IsRaidGrouped() then
            groups = provider:RaidGroups()
            raid = fsEnumerable
                :From(groups)
                :Map(function(group)
                    return provider:RaidGroupMembers(group)
                end)
                :Flatten()
                :ToTable()
        else
            raid = provider:RaidFrames()
        end
    end

    if enemyEnabled and wow.IsRetail() then
        arena = provider:EnemyArenaFrames()
    end

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

    for _, frame in ipairs(party) do
        wow.SecureHandlerSetFrameRef(secureManager, "frame", frame)
        secureManager:SetAttribute("frameType", "Party")
        secureManager:Execute(addFrameScript)
    end

    for _, frame in ipairs(raid) do
        wow.SecureHandlerSetFrameRef(secureManager, "frame", frame)
        secureManager:SetAttribute("frameType", "Raid")
        secureManager:Execute(addFrameScript)
    end

    for _, frame in ipairs(groups) do
        wow.SecureHandlerSetFrameRef(secureManager, "frame", frame)
        secureManager:SetAttribute("frameType", "Groups")
        secureManager:Execute(addFrameScript)
    end

    for _, frame in ipairs(arena) do
        wow.SecureHandlerSetFrameRef(secureManager, "frame", frame)
        secureManager:SetAttribute("frameType", "Arena")
        secureManager:Execute(addFrameScript)
    end
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

function M:Init()
    secureManager = wow.CreateFrame("Frame", nil, wow.UIParent, "SecureHandlerStateTemplate")
    secureManager:HookScript("OnEvent", OnEvent)
    secureManager:RegisterEvent(wow.Events.PLAYER_REGEN_DISABLED)

    secureManager:Execute([=[
        FramesByProvider = newtable()
        PointsByProvider = newtable()

        Round = [[
            local number, decimalPlaces = ...

            if number == nil then return nil end

            local mult = 10 ^ (decimalPlaces or 0)
            return math.floor(number * mult + 0.5) / mult
        ]]
        ]=])

    function secureManager:InvokeCallbacks()
        fsSorting:InvokeCallbacks()
    end

    wow.SecureHandlerWrapScript(
        secureManager,
        "OnAttributeChanged",
        secureManager,
        [[
        if not strmatch(name, "framesort") then return end

        local inCombat = SecureCmdOptionParse("[combat] true; false") == "true"
        if not inCombat then return end

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
    )

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
