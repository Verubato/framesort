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

    secureManager:Execute([[
        FramesByProvider = newtable()
        PointsByProvider = newtable()
        ]])

    wow.SecureHandlerWrapScript(
        secureManager,
        "OnAttributeChanged",
        secureManager,
        [[
        if not strmatch(name, "framesort") then return end

        local inCombat = SecureCmdOptionParse("[combat] true; false") == "true"
        if not inCombat then return end

        for provider, framesByType in pairs(FramesByProvider) do
            for type, frames in pairs(framesByType) do
                -- first clear existing points
                for _, frame in ipairs(frames) do
                    local to = PointsByProvider[provider][frame]

                    if to then
                        frame:ClearAllPoints()
                    end
                end

                -- now set them
                for _, frame in ipairs(frames) do
                    local to = PointsByProvider[provider][frame]

                    if to then
                        frame:SetPoint(to.point, to.relativeTo, to.relativePoint, to.offsetX, to.offsetY)
                    end
                end
            end
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
