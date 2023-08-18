---@type string, Addon
local _, addon = ...
local fsEnumerable = addon.Enumerable
local fsCompare = addon.Compare
local blizzard = addon.Frame.Providers.Blizzard
---@class ApiV1
local M = {
    Sorting = {},
    Options = {},
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
    if mode ~= addon.PlayerSortMode.Top and mode ~= addon.PlayerSortMode.Middle and mode ~= addon.PlayerSortMode.Bottom and mode ~= addon.PlayerSortMode.Hidden then
        error("Invalid player sort mode: " .. (mode or "nil"))
    end
end

---@param mode GroupSortMode
local function ValidateGroupSortMode(mode)
    if mode ~= addon.GroupSortMode.Group and mode ~= addon.GroupSortMode.Role and mode ~= addon.GroupSortMode.Alphabetical then
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

    addon.Sorting:RegisterPostSortCallback(callback)
end

---Returns a collection of Blizzard party frames ordered by their visual representation.
function M.Sorting:GetPartyFrames()
    local frames = blizzard:PartyFrames()
    return VisualOrder(frames)
end

---Returns a collection of Blizzard raid frames ordered by their visual representation.
function M.Sorting:GetRaidFrames()
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

    local table = addon.Options[area]
    return table.PlayerSortMode
end

---Sets the player sort mode.
---@param area Area
---@param mode PlayerSortMode
function M.Options:SetPlayerSortMode(area, mode)
    ValidateArea(area)
    ValidatePlayerSortMode(mode)

    local table = addon.Options[area]
    table.PlayerSortMode = mode

    addon.Sorting:TrySort()
end

---Sets the group sort mode.
---@param area Area
---@param mode GroupSortMode
function M.Options:SetGroupSortMode(area, mode)
    ValidateArea(area)
    ValidateGroupSortMode(mode)

    local table = addon.Options[area]
    table.GroupSortMode = mode

    addon.Sorting:TrySort()
end

---Gets the group sort mode.
---@param area Area
function M.Options:GetGroupSortMode(area)
    ValidateArea(area)

    local table = addon.Options[area]
    return table.GroupSortMode
end

---Gets the Enabled flag.
---@param area Area
function M.Options:GetEnabled(area)
    ValidateArea(area)

    local table = addon.Options[area]
    return table.Enabled
end

---Enables/disables sorting.
---@param area Area
---@param enabled boolean
function M.Options:SetEnabled(area, enabled)
    ValidateArea(area)

    local table = addon.Options[area]
    table.Enabled = enabled

    if enabled then
        addon.Sorting:TrySort()
    end
end

---Enables/disables reverse sorting.
---@param area Area
function M.Options:GetReverse(area)
    ValidateArea(area)

    local table = addon.Options[area]
    return table.Reverse
end

---Enables/disables reverse sorting.
---@param area Area
---@param reverse boolean
function M.Options:SetReverse(area, reverse)
    ValidateArea(area)

    local table = addon.Options[area]
    table.Reverse = reverse

    addon.Sorting:TrySort()
end