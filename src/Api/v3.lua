---@type string, Addon
local _, addon = ...
local fsConfig = addon.Configuration
local fsFrame = addon.WoW.Frame
local fsInspector = addon.Modules.Inspector
local fsUnit = addon.WoW.Unit
local fsUnitTracker = addon.Modules.UnitTracker
local wow = addon.WoW.Api
local v2 = addon.Api.v2

---@class ApiV3
local M = {
    Sorting = {},
    Options = {},
    Inspector = {},
    Frame = {},
}
addon.Api.v3 = M

---Register a callback to invoke after sorting has been performed.
---@param callback function
function M.Sorting:RegisterPostSortCallback(callback)
    v2.Sorting:RegisterPostSortCallback(callback)
end

---Returns a collection of party frames ordered by their visual representation.
function M.Sorting:GetPartyFrames()
    return v2.Sorting:GetPartyFrames()
end

---Returns a collection of raid frames ordered by their visual representation.
function M.Sorting:GetRaidFrames()
    return v2.Sorting:GetRaidFrames()
end

---Returns a collection of enemy arena frames ordered by their visual representation.
function M.Sorting:GetArenaFrames()
    return v2.Sorting:GetArenaFrames()
end

---Returns party frames if there are any, otherwise raid frames.
function M.Sorting:GetFrames()
    return v2.Sorting:GetFrames()
end

---Returns a sorted array of friendly unit tokens.
function M.Sorting:GetFriendlyUnits()
    return v2.Sorting:GetFriendlyUnits()
end

---Returns a sorted array of enemy unit tokens.
function M.Sorting:GetEnemyUnits()
    return v2.Sorting:GetEnemyUnits()
end

---Gets the player sort mode.
---@param area Area
function M.Options:GetPlayerSortMode(area)
    return v2.Options:GetPlayerSortMode(area)
end

---Sets the player sort mode.
---@param area Area
---@param mode PlayerSortMode
function M.Options:SetPlayerSortMode(area, mode)
    return v2.Options:SetPlayerSortMode(area, mode)
end

---Sets the group sort mode.
---@param area Area
---@param mode GroupSortMode
function M.Options:SetGroupSortMode(area, mode)
    return v2.Options:SetGroupSortMode(area, mode)
end

---Gets the group sort mode.
---@param area Area
function M.Options:GetGroupSortMode(area)
    return v2.Options:GetGroupSortMode(area)
end

---Gets the Enabled flag.
---@param area Area
function M.Options:GetEnabled(area)
    return v2.Options:GetEnabled(area)
end

---Enables/disables sorting.
---@param area Area
---@param enabled boolean
function M.Options:SetEnabled(area, enabled)
    return v2.Options:SetEnabled(area, enabled)
end

---Enables/disables reverse sorting.
---@param area Area
function M.Options:GetReverse(area)
    return v2.Options:GetReverse(area)
end

---Enables/disables reverse sorting.
---@param area Area
---@param reverse boolean
function M.Options:SetReverse(area, reverse)
    return v2.Options:SetReverse(area, reverse)
end

---Gets the current spacing values.
---@param area SpacingArea
function M.Options:GetSpacing(area)
    return v2.Options:GetSpacing(area)
end

---Registers a callback to invoke when configuration changes.
---@param callback function
function M.Options:RegisterConfigurationChangedCallback(callback)
    fsConfig:RegisterConfigurationChangedCallback(callback)
end

---Adds/removes spacing.
---@param area SpacingArea
---@param horizontal number
---@param vertical number
function M.Options:SetSpacing(area, horizontal, vertical)
    return v2.Options:SetSpacing(area, horizontal, vertical)
end

---Returns the class specialization id of the specified unit guid, or 0/nil if unknown.
---@param unitGuid string
---@return number|nil
function M.Inspector:GetSpecId(unitGuid)
    if not unitGuid then
        error("Unit must not be nil.")
        return
    end

    return fsInspector:UnitSpec(unitGuid)
end

---Returns the class specialization id of the specified unit, or 0/nil if unknown.
---@param unit string
---@return number|nil
function M.Inspector:GetUnitSpecId(unit)
    if not unit then
        error("Unit must not be nil.")
        return
    end

    local guid = wow.UnitGUID(unit)

    if not guid then
        return nil
    end

    if wow.issecretvalue(guid) then
        return nil
    end

    return fsInspector:UnitSpec(guid)
end

---Returns the unit token from the given frame.
---@param frame table
function M.Frame:UnitFromFrame(frame)
    if not frame then
        error("Frame must not be nil.")
        return
    end

    return fsFrame:GetFrameUnit(frame)
end

---Returns the ordered frame number for the specified unit.
---@param unit string
---@return number|nil
function M.Frame:FrameNumberForUnit(unit)
    if not unit then
        error("Unit must not be nil.")
        return
    end

    local isFriendly = fsUnit:IsFriendlyUnit(unit)
    local units = isFriendly and M.Sorting:GetFriendlyUnits() or M.Sorting:GetEnemyUnits()

    for index, u in ipairs(units) do
        if u == unit then
            return index
        end

        local isUnitOrSecret = wow.UnitIsUnit(u, unit)

        if not wow.issecretvalue(isUnitOrSecret) and isUnitOrSecret then
            return index
        end
    end

    return nil
end

---Returns the party/raid/arena frame for the given unit.
---@param unit string
---@returns frame table
function M.Frame:FrameForUnit(unit)
    if not unit then
        error("Unit must not be nil.")
        return
    end

    return fsUnitTracker:GetFrameForUnit(unit)
end
