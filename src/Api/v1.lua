---@type string, Addon
local _, addon = ...
local fsEnumerable = addon.Collections.Enumerable
local fsCompare = addon.Collections.Comparer
local fsSort = addon.Modules.Sorting
local fsConfig = addon.Configuration
local fsFrame = addon.WoW.Frame

---@class ApiV1
local M = {
    Sorting = {},
    Options = {},
    Debugging = {},
    Logging = {},
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
    local frames = fsFrame:PartyFrames(blizzard)

    return VisualOrder(frames)
end

---Returns a collection of Blizzard raid frames ordered by their visual representation.
function M.Sorting:GetRaidFrames()
    local blizzard = addon.Providers.Blizzard
    local frames = fsFrame:RaidFrames(blizzard)

    return VisualOrder(frames)
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

    local table = addon.DB.Options.Sorting[area]
    return table.PlayerSortMode
end

---Sets the player sort mode.
---@param area Area
---@param mode PlayerSortMode
function M.Options:SetPlayerSortMode(area, mode)
    ValidateArea(area)
    ValidatePlayerSortMode(mode)

    local table = addon.DB.Options.Sorting[area]
    table.PlayerSortMode = mode

    fsConfig:NotifyChanged()
    fsSort:Run()
end

---Sets the group sort mode.
---@param area Area
---@param mode GroupSortMode
function M.Options:SetGroupSortMode(area, mode)
    ValidateArea(area)
    ValidateGroupSortMode(mode)

    local table = addon.DB.Options.Sorting[area]
    table.GroupSortMode = mode

    fsConfig:NotifyChanged()
    fsSort:Run()
end

---Gets the group sort mode.
---@param area Area
function M.Options:GetGroupSortMode(area)
    ValidateArea(area)

    local table = addon.DB.Options.Sorting[area]
    return table.GroupSortMode
end

---Gets the Enabled flag.
---@param area Area
function M.Options:GetEnabled(area)
    ValidateArea(area)

    local table = addon.DB.Options.Sorting[area]
    return table.Enabled
end

---Enables/disables sorting.
---@param area Area
---@param enabled boolean
function M.Options:SetEnabled(area, enabled)
    ValidateArea(area)

    local table = addon.DB.Options.Sorting[area]
    table.Enabled = enabled

    fsConfig:NotifyChanged()

    if enabled then
        fsSort:Run()
    end
end

---Enables/disables reverse sorting.
---@param area Area
function M.Options:GetReverse(area)
    ValidateArea(area)

    local table = addon.DB.Options.Sorting[area]
    return table.Reverse
end

---Enables/disables reverse sorting.
---@param area Area
---@param reverse boolean
function M.Options:SetReverse(area, reverse)
    ValidateArea(area)

    local table = addon.DB.Options.Sorting[area]
    table.Reverse = reverse

    fsConfig:NotifyChanged()
    fsSort:Run()
end

---Enables/disables logging.
function M.Logging:SetEnabled(enable)
    addon.DB.Options.Logging.Enabled = enable
    fsConfig:NotifyChanged()
end

---Exposes the addon table to the public when enabled.
function M.Debugging:SetEnabled(enable)
    if enable then
        FrameSort = addon
    else
        ---@diagnostic disable-next-line: assign-type-mismatch
        FrameSort = nil
    end
end
