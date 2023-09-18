---@type string, Addon
local _, addon = ...
local fsEnumerable = addon.Collections.Enumerable
local fsCompare = addon.Collections.Comparer
local fsSort = addon.Modules.Sorting
local fsConfig = addon.Configuration

---@class ApiV1
local M = {
    Sorting = {},
    Options = {},
    Debugging = {},
}
addon.Api.v1 = M

local function VisualOrder(framesOrFunction)
    return fsEnumerable
        :From(framesOrFunction)
        :Where(function(x)
            return x:IsVisible()
        end)
        :OrderBy(function(x, y)
            return fsCompare:CompareTopLeftFuzzy(x, y)
        end)
        :ToTable()
end

---@param mode PlayerSortMode
local function ValidatePlayerSortMode(mode)
    if mode ~= fsConfig.PlayerSortMode.Top and mode ~= fsConfig.PlayerSortMode.Middle and mode ~= fsConfig.PlayerSortMode.Bottom and mode ~= fsConfig.PlayerSortMode.Hidden then
        error("Invalid player sort mode: " .. (mode or "nil"))
    end
end

---@param mode GroupSortMode
local function ValidateGroupSortMode(mode)
    if mode ~= fsConfig.GroupSortMode.Group and mode ~= fsConfig.GroupSortMode.Role and mode ~= fsConfig.GroupSortMode.Alphabetical then
        error("Invalid group sort mode: " .. (mode or "nil"))
    end
end

---@param area Area
local function ValidateArea(area)
    if area ~= "Arena" and area ~= "Dungeon" and area ~= "Raid" and area ~= "World" then
        error("Invalid area: " .. (area or "nil"))
    end
end

---Register a callback to invoke after sorting has been performed.
---@param callback function
function M.Sorting:RegisterPostSortCallback(callback)
    if not callback then
        error("Callback function must not be nil.")
        return
    end

    fsSort:RegisterPostSortCallback(callback)
end

---Returns a collection of Blizzard party frames ordered by their visual representation.
function M.Sorting:GetPartyFrames()
    local blizzard = addon.Providers.Blizzard
    local frames = blizzard:PartyFrames()
    return VisualOrder(frames)
end

---Returns a collection of Blizzard raid frames ordered by their visual representation.
function M.Sorting:GetRaidFrames()
    local blizzard = addon.Providers.Blizzard
    if not blizzard:IsRaidGrouped() then
        local frames = blizzard:RaidFrames()
        return VisualOrder(frames)
    end

    local all = fsEnumerable
        :From(blizzard:RaidGroups())
        :Map(function(group)
            return blizzard:RaidGroupMembers(group)
        end)
        :Flatten()

    return VisualOrder(all)
end

---Returns party frames if there are any, otherwise raid frames.
function M.Sorting:GetFrames()
    local party = M.Sorting:GetPartyFrames()
    if #party > 0 then
        return party
    end

    return M.Sorting:GetRaidFrames()
end

---Gets the player sort mode.
---@param area Area
function M.Options:GetPlayerSortMode(area)
    ValidateArea(area)

    local table = addon.DB.Options[area]
    return table.PlayerSortMode
end

---Sets the player sort mode.
---@param area Area
---@param mode PlayerSortMode
function M.Options:SetPlayerSortMode(area, mode)
    ValidateArea(area)
    ValidatePlayerSortMode(mode)

    local table = addon.DB.Options[area]
    table.PlayerSortMode = mode

    fsSort:TrySort()
end

---Sets the group sort mode.
---@param area Area
---@param mode GroupSortMode
function M.Options:SetGroupSortMode(area, mode)
    ValidateArea(area)
    ValidateGroupSortMode(mode)

    local table = addon.DB.Options[area]
    table.GroupSortMode = mode

    fsSort:TrySort()
end

---Gets the group sort mode.
---@param area Area
function M.Options:GetGroupSortMode(area)
    ValidateArea(area)

    local table = addon.DB.Options[area]
    return table.GroupSortMode
end

---Gets the Enabled flag.
---@param area Area
function M.Options:GetEnabled(area)
    ValidateArea(area)

    local table = addon.DB.Options[area]
    return table.Enabled
end

---Enables/disables sorting.
---@param area Area
---@param enabled boolean
function M.Options:SetEnabled(area, enabled)
    ValidateArea(area)

    local table = addon.DB.Options[area]
    table.Enabled = enabled

    if enabled then
        fsSort:TrySort()
    end
end

---Enables/disables reverse sorting.
---@param area Area
function M.Options:GetReverse(area)
    ValidateArea(area)

    local table = addon.DB.Options[area]
    return table.Reverse
end

---Enables/disables reverse sorting.
---@param area Area
---@param reverse boolean
function M.Options:SetReverse(area, reverse)
    ValidateArea(area)

    local table = addon.DB.Options[area]
    table.Reverse = reverse

    fsSort:TrySort()
end

---Enables logging and exposes the addon table to the public.
function M.Debugging:Enable()
    FrameSort = addon
    addon.DB.Options.Logging.Enabled = true
end

---Disables debug mode.
function M.Debugging:Disable()
    if FrameSort then
        ---@diagnostic disable-next-line: assign-type-mismatch
        FrameSort = nil
    end

    addon.DB.Options.Logging.Enabled = false
end
