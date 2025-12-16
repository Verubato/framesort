---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsProviders = addon.Providers
local fsLog = addon.Logging.Log
local fsFrame = addon.WoW.Frame
local fsUnit = addon.WoW.Unit

---@class UnitTrackerModule : IInitialise
local M = {}
addon.Modules.UnitTracker = M

local frameByUnit = {}

local function OnSetUnit(frame, unit)
    if not frame or not unit or fsFrame:IsForbidden(frame) then
        return
    end

    frameByUnit[unit] = frame
end

local function FindUnitFrame(frames, unit)
    for _, frame in ipairs(frames) do
        local frameUnit = fsFrame:GetFrameUnit(frame)
        local isUnitOrSecret = frameUnit ~= nil and wow.UnitIsUnit(frameUnit, unit)

        if frameUnit == unit or (not wow.issecretvalue(isUnitOrSecret) and isUnitOrSecret) then
            return frame
        end
    end

    return nil
end

function M:GetFrameForUnit(unit)
    local cachedFrame = frameByUnit[unit]

    if cachedFrame and fsFrame:IsForbidden(cachedFrame) then
        cachedFrame = nil
        frameByUnit[unit] = nil
    elseif cachedFrame then
        local frameUnit = fsFrame:GetFrameUnit(cachedFrame)
        local isUnitOrSecret = frameUnit ~= nil and wow.UnitIsUnit(frameUnit, unit)
        local matchesUnit = frameUnit == unit or (not wow.issecretvalue(isUnitOrSecret) and isUnitOrSecret)

        -- check the visibility of the frame, as blizzard frames may have been hidden by an addon
        -- in which case we don't want to use it
        if matchesUnit and cachedFrame:IsVisible() then
            return cachedFrame
        elseif not matchesUnit then
            cachedFrame = nil
            frameByUnit[unit] = nil
        end
    end

    local isFriendly = fsUnit:IsFriendlyUnit(unit)

    for _, provider in ipairs(fsProviders:Enabled()) do
        if isFriendly then
            local party = fsFrame:PartyFrames(provider, false)
            local partyFound = FindUnitFrame(party, unit)

            if partyFound then
                frameByUnit[unit] = partyFound
                cachedFrame = partyFound

                if cachedFrame:IsVisible() then
                    return cachedFrame
                end
            end

            local raid = fsFrame:RaidFrames(provider, false)
            local raidFound = FindUnitFrame(raid, unit)

            if raidFound then
                frameByUnit[unit] = raidFound
                cachedFrame = raidFound

                if cachedFrame:IsVisible() then
                    return cachedFrame
                end
            end
        else
            local arena = fsFrame:ArenaFrames(provider, false)
            local arenaFound = FindUnitFrame(arena, unit)

            if arenaFound then
                frameByUnit[unit] = arenaFound
                cachedFrame = arenaFound

                if cachedFrame:IsVisible() then
                    return cachedFrame
                end
            end
        end
    end

    -- fallback to whatever we found that's not visible
    return cachedFrame
end

function M:Init()
    if CompactUnitFrame_SetUnit then
        wow.hooksecurefunc("CompactUnitFrame_SetUnit", OnSetUnit)
    else
        fsLog:Warning("CompactUnitFrame_SetUnit API not available for the unit tracker module.")
    end

    fsLog:Debug("Initialised the unit tracker module.")
end
