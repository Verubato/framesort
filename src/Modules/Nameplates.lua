---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local capabilities = addon.WoW.Capabilities
local fsLog = addon.Logging.Log
local fsSortedUnits = addon.Modules.Sorting.SortedUnits
local fsUnit = addon.WoW.Unit
local fsInspector = addon.Modules.Inspector
---@class NameplatesModule : IInitialise
local M = {}
addon.Modules.Nameplates = M

local function FrameText(unit, friendly, frameNumber)
    local config = addon.DB.Options.Nameplates
    local text = (friendly and config.FriendlyFormat or config.EnemyFormat) or "$framenumber"
    local name = (wow.UnitName and wow.UnitName(unit)) or "unknown"

    local specText = nil
    if capabilities.HasSpecializations() and wow.GetSpecializationInfoByID then
        local specId = friendly and fsInspector:FriendlyUnitSpec(unit) or fsInspector:EnemyUnitSpec(unit)
        if specId then
            local _, specName = wow.GetSpecializationInfoByID(specId)
            specText = specName
        end
    end

    local vars = {
        framenumber = tostring(frameNumber),
        unit = unit,
        name = name,
        spec = specText or "unknown",
    }

    -- case-insensitive replacement while preserving original text casing
    text = text:gsub("%$(%a+)", function(key)
        local value = vars[key:lower()]
        return value ~= nil and value or "$" .. key
    end)

    return text
end

local function OnUpdateName(frame)
    if not frame then
        return
    end

    local unit = frame.unit

    if not unit then
        return
    end

    -- ignore pets and npcs
    if not wow.UnitIsPlayer(frame.unit) then
        return
    end

    -- only operate on nameplates, as this hook is used by raid frames too
    if not string.find(unit, "nameplate") then
        return
    end

    if not frame.name then
        fsLog:WarnOnce("No name for frame %s.", frame:GetName() or "nil")
        return
    end

    local friendly = fsUnit:IsFriendlyUnit(unit)

    if friendly and not addon.DB.Options.Nameplates.FriendlyEnabled then
        return
    end

    if not friendly and not addon.DB.Options.Nameplates.EnemyEnabled then
        return
    end

    local frameNumber, resolvedUnit = fsSortedUnits:FrameNumberForUnit(unit)

    if not frameNumber or not resolvedUnit then
        return
    end

    local text = FrameText(resolvedUnit, friendly, frameNumber)

    frame.name:SetText(text)
end

local function RefreshNameplates()
    if not wow.C_NamePlate or not wow.C_NamePlate.GetNamePlates then
        return
    end

    for _, plate in ipairs(wow.C_NamePlate.GetNamePlates()) do
        local unitFrame = plate.UnitFrame
        if unitFrame then
            OnUpdateName(unitFrame)
        end
    end
end

function M:CanRun()
    return CompactUnitFrame_UpdateName ~= nil or (wow.C_NamePlate and wow.C_NamePlate.GetNamePlates) ~= nil
end

function M:Run()
    RefreshNameplates()
end

function M:Init()
    if not M:CanRun() then
        fsLog:Warning("Nameplates module unable to run.")
        return
    end

    if CompactUnitFrame_UpdateName then
        wow.hooksecurefunc("CompactUnitFrame_UpdateName", OnUpdateName)
    end

    fsLog:Debug("Initialised the nameplates module.")
end
