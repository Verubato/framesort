local _, addon = ...
local fsFrame = addon.Frame
local fsEnumerable = addon.Enumerable
local fsCompare = addon.Compare

local Api = {
    v1 = {
        Sorting = {},
        Options = {},
    },
}

function addon:InitApi()
    FrameSortApi = Api
end

local function VisualOrder(frames)
    return fsEnumerable
        :From(frames)
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
        error("Invalid area: " .. (mode or "nil"))
    end
end

---Register a callback to invoke after sorting has been performed.
---@param callback function
function Api.v1.Sorting:RegisterPostSortCallback(callback)
    if not callback then
        error("Callback function must not be nil.")
        return
    end

    addon.Sorting:RegisterPostSortCallback(callback)
end

---Returns a collection of party frames ordered by their visual representation.
function Api.v1.Sorting:GetPartyFrames()
    local frames = fsFrame:GetPartyFrames()
    return VisualOrder(frames)
end

---Returns a collection of raid frames ordered by their visual representation.
function Api.v1.Sorting:GetRaidFrames()
    local frames = fsFrame:GetRaidFrames()
    return VisualOrder(frames)
end

---Returns a collection of party or raid frames (depending which are shown) ordered by their visual representation.
function Api.v1.Sorting:GetFrames()
    local frames = self:GetPartyFrames()
    if #frames > 0 then
        return frames
    end

    return self:GetRaidFrames()
end

---Gets the player sort mode.
---@param area Area
function Api.v1.Options:GetPlayerSortMode(area)
    ValidateArea(area)

    local table = addon.Options[area]
    return table.PlayerSortMode
end

---Sets the player sort mode.
---@param area Area
---@param mode PlayerSortMode
function Api.v1.Options:SetPlayerSortMode(area, mode)
    ValidateArea(area)
    ValidatePlayerSortMode(mode)

    local table = addon.Options[area]
    table.PlayerSortMode = mode

    addon.Sorting:TrySort()
end

---Sets the group sort mode.
---@param area Area
---@param mode GroupSortMode
function Api.v1.Options:SetGroupSortMode(area, mode)
    ValidateArea(area)
    ValidateGroupSortMode(mode)

    local table = addon.Options[area]
    table.GroupSortMode = mode

    addon.Sorting:TrySort()
end

---Gets the group sort mode.
---@param area Area
function Api.v1.Options:GetGroupSortMode(area)
    ValidateArea(area)

    local table = addon.Options[area]
    return table.GroupSortMode
end

---Gets the Enabled flag.
---@param area Area
function Api.v1.Options:GetEnabled(area)
    ValidateArea(area)

    local table = addon.Options[area]
    return table.Enabled
end

---Enables/disables sorting.
---@param area Area
---@param enabled boolean
function Api.v1.Options:SetEnabled(area, enabled)
    ValidateArea(area)

    local table = addon.Options[area]
    table.Enabled = enabled

    if enabled then
        addon.Sorting:TrySort()
    end
end

---Enables/disables reverse sorting.
---@param area Area
function Api.v1.Options:GetReverse(area)
    ValidateArea(area)

    local table = addon.Options[area]
    return table.Reverse
end

---Enables/disables reverse sorting.
---@param area Area
---@param reverse boolean
function Api.v1.Options:SetReverse(area, reverse)
    ValidateArea(area)

    local table = addon.Options[area]
    table.Reverse = reverse

    addon.Sorting:TrySort()
end