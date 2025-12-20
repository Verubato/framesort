---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsProviders = addon.Providers
local fsEnumerable = addon.Collections.Enumerable
local fsCompare = addon.Modules.Sorting.Comparer
local fsFrame = addon.WoW.Frame
local fsLog = addon.Logging.Log

---@class SortedFrames
local M = {}
addon.Modules.Sorting.SortedFrames = M

local function VisualOrder(frames)
    return fsEnumerable
        :From(frames)
        :Where(function(x)
            return x.IsVisible and x:IsVisible()
        end)
        :OrderBy(function(x, y)
            return fsCompare:CompareTopLeftFuzzy(x, y)
        end)
        :ToTable()
end

local function GetFriendlyFrames(provider)
    local frames = fsFrame:PartyFrames(provider, true)

    if #frames == 0 then
        frames = fsFrame:RaidFrames(provider, true)
    end

    return frames
end

---Returns an array of friendly frames sorted by their visual order.
---Prefers blizzard frames over other providers.
---@return table
function M:FriendlyFrames()
    local frames = nil

    -- prefer Blizzard frames
    if fsProviders.Blizzard:Enabled() then
        frames = GetFriendlyFrames(fsProviders.Blizzard)
    end

    if not frames or #frames == 0 then
        local nonBlizzard = fsEnumerable
            :From(fsProviders:Enabled())
            :Where(function(provider)
                return provider ~= fsProviders.Blizzard
            end)
            :ToTable()

        for _, provider in ipairs(nonBlizzard) do
            frames = GetFriendlyFrames(provider)

            if #frames > 0 then
                break
            end
        end
    end

    if not frames or #frames == 0 then
        return {}
    end

    return VisualOrder(frames)
end

---Returns an array of arena frames sorted by their visual order.
---Prefers blizzard frames over other providers.
---@return table
function M:ArenaFrames()
    local frames = nil

    -- prefer Blizzard frames
    if fsProviders.Blizzard:Enabled() then
        frames = fsFrame:ArenaFrames(fsProviders.Blizzard, true)
    end

    if not frames or #frames == 0 then
        local nonBlizzard = fsEnumerable
            :From(fsProviders:Enabled())
            :Where(function(provider)
                return provider ~= fsProviders.Blizzard
            end)
            :ToTable()

        for _, provider in ipairs(nonBlizzard) do
            frames = fsFrame:ArenaFrames(provider, true)

            if #frames > 0 then
                break
            end
        end
    end

    if not frames or #frames == 0 then
        return {}
    end

    return VisualOrder(frames)
end
