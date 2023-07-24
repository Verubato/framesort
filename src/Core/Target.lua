local _, addon = ...
local fsSort = addon.Sorting
local fsEnumerable = addon.Enumerable
local fsVisual = addon.Visual
local fsLog = addon.Log
local prefix = "FSTarget"
local previousUnits = nil
local targetFramesButtons = {}
local targetBottomFrameButton = nil

local function CanUpdate()
    if InCombatLockdown() then
        fsLog:Warning("Can't update targets during combat.")
        return false
    end

    return true
end

local function UpdateTargets()
    local units = fsVisual:GetVisuallyOrderedUnits()

    -- prevent editing macros if the units haven't changed
    if previousUnits and fsEnumerable:ArrayEquals(previousUnits, units) then
        return
    end

    -- if units has less than 5 items it's still fine as units[i] will just be nil
    for i, btn in ipairs(targetFramesButtons) do
        local unit = units[i]

        btn:SetAttribute("unit", unit or "none")
    end

    targetBottomFrameButton:SetAttribute("unit", units[#units] or "none")

    previousUnits = units

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
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    fsSort:RegisterPostSortCallback(Run)

    if CompactRaidFrameContainer.LayoutFrames then
        hooksecurefunc(CompactRaidFrameContainer, "LayoutFrames", Run)
    elseif CompactRaidFrameContainer_LayoutFrames then
        hooksecurefunc("CompactRaidFrameContainer_LayoutFrames", Run)
    end
end
