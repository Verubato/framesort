---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsSorting = addon.Modules.Sorting
local fsCompare = addon.Collections.Comparer
local fsProviders = addon.Providers
local M = {}
addon.Modules.Sorting.Secure = M

local secureManager = nil

local function StoreFrames(provider)
    local friendlyEnabled, _, _, _ = fsCompare:FriendlySortMode()
    local enemyEnabled, _, _ = fsCompare:EnemySortMode()
    local party = {}
    local raid = {}
    local arena = {}

    if friendlyEnabled then
        party = provider:PartyFrames()
        raid = provider:RaidFrames()
    end

    if enemyEnabled and wow.IsRetail() then
        arena = provider:EnemyArenaFrames()
    end

    secureManager:SetAttribute("provider", provider:Name())
    secureManager:Execute([[
        local provider = self:GetAttribute("provider")
        local frames = FramesByProvider[provider]

        if not frames then
            frames = newtable()
            frames.Party = newtable()
            frames.Raid = newtable()
            frames.Arena = newtable()
            frames.Points = newtable()

            FramesByProvider[provider] = frames
        else
            frames.Party = wipe(frames.Party)
            frames.Raid = wipe(frames.Raid)
            frames.Arena = wipe(frames.Arena)
            frames.Points = wipe(frames.Points)
        end
    ]])

    local addFrameScript = [[
        local provider = self:GetAttribute("provider")
        local frames = FramesByProvider[provider]
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
        frames.Points[frame] = point
    ]]

    for _, frame in ipairs(party) do
        wow.SecureHandlerSetFrameRef(secureManager, "frame", frame)
        secureManager:SetAttribute("frameType", "Party")
        secureManager:Execute(addFrameScript)
    end

    for _, frame in ipairs(raid) do
        wow.SecureHandlerSetFrameRef(secureManager, "frame", frame)
        secureManager:SetAttribute("frameType", "Raid")
    end

    for _, frame in ipairs(arena) do
        wow.SecureHandlerSetFrameRef(secureManager, "frame", frame)
        secureManager:SetAttribute("frameType", "Arena")
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
    secureManager = wow.CreateFrame("Frame", "FrameSortGroupHeader", wow.UIParent, "SecureHandlerAttributeTemplate")

    secureManager:SetFrameRef("Manager", secureManager)
    secureManager:Execute("FramesByProvider = newtable()")
    secureManager:HookScript("OnEvent", OnEvent)
    secureManager:RegisterEvent(wow.Events.PLAYER_REGEN_DISABLED)

    for i = 1, wow.MAX_RAID_MEMBERS do
        wow.RegisterAttributeDriver(secureManager, "raid" .. i, string.format("[@raid%d, exists] true; false", i))
        wow.RegisterAttributeDriver(secureManager, "raidpet" .. i, string.format("[@raidpet%d, exists] true; false", i))
    end

    for i = 1, wow.MEMBERS_PER_RAID_GROUP - 1 do
        wow.RegisterAttributeDriver(secureManager, "party" .. i, string.format("[@party%d, exists] true; false", i))
    end

    wow.SecureHandlerWrapScript(
        secureManager,
        "OnAttributeChanged",
        secureManager,
        [[
        if not strmatch(name, "raid") and not strmatch(name, "party") then return end

        for provider, frames in pairs(FramesByProvider) do
            for _, frame in ipairs(frames.Party) do
                local to = frames.Points[frame]

                if to and to.point and to.relativeTo and to.relativePoint then
                    frame:SetPoint(to.point, to.relativeTo, to.relativePoint, to.offsetX, to.offsetY)
                end
            end
        end
    ]]
    )
end

---Attempts to sort frames.
---@return boolean sorted true if sorted, otherwise false.
---@param provider FrameProvider the provider to sort.
function M:TrySort(provider)
    -- TODO: probably do our own sorting instead of using taintless
    if not fsSorting.Taintless:TrySort(provider) then
        return false
    end

    StoreFrames(provider)
    return true
end
