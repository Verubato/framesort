local _, addon = ...
local fsUnit = addon.Unit
local fsSort = addon.Sorting
local fsEnumerable = addon.Enumerable
local fsFrame = addon.Frame
local fsCompare = addon.Compare
local fsLog = addon.Log
local prefix = "FSTarget"
local targetFramesButtons = {}
local targetBottomFrameButton = nil

local function CanUpdate()
    if InCombatLockdown() then
        fsLog:Warning("Can't update targets during combat.")
        return false
    end

    return true
end

local function GetTargets()
    local frames, getUnit = fsFrame:GetFrames()

    if #frames > 0 then
        return fsEnumerable
            :From(frames)
            :OrderBy(function(x, y)
                return fsCompare:CompareTopLeftFuzzy(x, y)
            end)
            :Map(getUnit)
            :ToTable()
    end

    -- fallback to retrieve the group units
    return fsUnit:GetUnits()
end

local function UpdateTargets()
    local units = GetTargets()

    -- if units has less than 5 items it's still fine as units[i] will just be nil
    for i, btn in ipairs(targetFramesButtons) do
        local unit = units[i]

        btn:SetAttribute("unit", unit or "none")
    end

    targetBottomFrameButton:SetAttribute("unit", units[#units] or "none")

    return true
end

local function Run()
    if not CanUpdate() then
        return
    end

    UpdateTargets()
end

---Initialises the targeting frames feature.
function addon:InitTargeting()
    -- target frame1-5
    local keybindingsCount = 5
    for i = 1, keybindingsCount do
        local button = CreateFrame("Button", prefix .. i, UIParent, "SecureActionButtonTemplate")
        button:RegisterForClicks("AnyDown")
        button:SetAttribute("type", "target")
        button:SetAttribute("unit", "none")

        targetFramesButtons[#targetFramesButtons + 1] = button
    end

    -- target bottom
    targetBottomFrameButton = CreateFrame("Button", prefix .. "Bottom", UIParent, "SecureActionButtonTemplate")
    targetBottomFrameButton:RegisterForClicks("AnyDown")
    targetBottomFrameButton:SetAttribute("type", "target")
    targetBottomFrameButton:SetAttribute("unit", "none")

    local eventFrame = CreateFrame("Frame")
    eventFrame:HookScript("OnEvent", Run)
    eventFrame:RegisterEvent(addon.Events.PLAYER_ENTERING_WORLD)
    eventFrame:RegisterEvent(addon.Events.GROUP_ROSTER_UPDATE)
    eventFrame:RegisterEvent(addon.Events.PLAYER_REGEN_ENABLED)
    fsSort:RegisterPostSortCallback(Run)
end
