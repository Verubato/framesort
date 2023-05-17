local addonName, addon = ...
local builder = addon.OptionsBuilder
local verticalSpacing = addon.OptionsBuilder.VerticalSpacing

---Returns true if using raid-style party frames.
local function IsUsingRaidStyleFrames()
    local raidStyleFrames = false
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        raidStyleFrames = EditModeManagerFrame:UseRaidStylePartyFrames()
    else
        raidStyleFrames = GetCVarBool("useCompactPartyFrames")
    end

    return raidStyleFrames
end

---Returns true if the inbuilt Blizzard sorting functions have been tampered with.
local function SortingFunctionsTampered()
    return
        not issecurevariable("CRFSort_Group") or
        not issecurevariable("CRFSort_Role") or
        not issecurevariable("CRFSort_Alphabetical")
end

---Returns the friendly name of an addon from issecurevariable.
---@param name string the addon name from issecurevariable.
---@return string
local function AddonFriendlyName(name)
    if not name then
        return "(unknown)"
    elseif name == "" then
        return "(user macro)"
    elseif name == "*** ForceTaint_Strong ***" then
        return "(user macro)"
    else
        return name
    end
end

---Returns a string of conflicting addons that are enabled.
local function ConflictingAddons()
    local issecure, taintedAddon = issecurevariable(CompactRaidFrameContainer, "flowSortFunc")
    if not issecure and taintedAddon ~= addonName then
        return AddonFriendlyName(taintedAddon)
    end

    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        issecure, taintedAddon = issecurevariable(CompactPartyFrame, "flowSortFunc")
        if not issecure and taintedAddon ~= addonName then
            return AddonFriendlyName(taintedAddon)
        end
    end

    return nil
end

local function KeepGroupsTogether()
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        local raidGroupDisplayType = EditModeManagerFrame:GetSettingValue(
            Enum.EditModeSystem.UnitFrame,
            Enum.EditModeUnitFrameSystemIndices.Raid,
            Enum.EditModeUnitFrameSetting.RaidGroupDisplayType)

        return
            raidGroupDisplayType ~= Enum.RaidGroupDisplayType.CombineGroupsVertical and
            raidGroupDisplayType ~= Enum.RaidGroupDisplayType.CombineGroupsHorizontal
    else
        return CompactRaidFrameManager_GetSetting("KeepGroupsTogether")
    end
end

---Adds the health check options panel.
---@param parent table the parent UI panel.
function builder:BuildHealthCheck(parent)
    local panel = CreateFrame("Frame", "FrameSortHealthCheck", parent)
    panel.name = "Health Check"
    panel.parent = parent.name

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", verticalSpacing, -verticalSpacing)
    title:SetText("Health Check")

    local description = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    description:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -verticalSpacing)
    description:SetText("Any known issues with configuration or conflicting addons will be shown below.")

    local raidStyleDescription = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    raidStyleDescription:SetPoint("TOPLEFT", description, "BOTTOMLEFT", 0, -verticalSpacing)
    raidStyleDescription:SetText("Using Raid-Style Party Frames... ")

    local raidStyleResult = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    raidStyleResult:SetPoint("TOPLEFT", raidStyleDescription, "TOPRIGHT")

    local togetherDescription = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    togetherDescription:SetPoint("TOPLEFT", raidStyleDescription, "BOTTOMLEFT", 0, -verticalSpacing)
    togetherDescription:SetText("'Keep Groups Together' setting disabled... ")

    local togetherResult = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    togetherResult:SetPoint("TOPLEFT", togetherDescription, "TOPRIGHT")

    local tamperedDescription = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    tamperedDescription:SetPoint("TOPLEFT", togetherDescription, "BOTTOMLEFT", 0, -verticalSpacing)
    tamperedDescription:SetText("Blizzard sorting functions not tampered with... ")

    local tamperedResult = panel:CreateFontString(nil, "ARTWORK", "GameFontRed")
    tamperedResult:SetPoint("TOPLEFT", tamperedDescription, "TOPRIGHT")

    local conflictDescription = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    conflictDescription:SetPoint("TOPLEFT", tamperedDescription, "BOTTOMLEFT", 0, -verticalSpacing)
    conflictDescription:SetText("No conflicting addons... ")

    local conflictResult = panel:CreateFontString(nil, "ARTWORK", "GameFontRed")
    conflictResult:SetPoint("TOPLEFT", conflictDescription, "TOPRIGHT")

    local remediationTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    remediationTitle:SetPoint("TOPLEFT", conflictDescription, 0, -verticalSpacing * 2)
    remediationTitle:SetText("Remediation Steps")

    local raidStyleRemediation = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    raidStyleRemediation:SetText("- Please enable 'Use Raid-Style Party Frames' in the Blizzard settings.")

    local togetherRemediation = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        togetherRemediation:SetText("- Change the raid display mode to one of the 'Combined Groups' options via Edit Mode.")
    else
        togetherRemediation:SetText("- Disable the 'Keep Groups Together' raid profile setting.")
    end

    local tamperedRemediation = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    tamperedRemediation:SetText("- Please disable other frame sorting addons/macros.")

    local conflictRemediation = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")

    local remediationControls = {
        raidStyleRemediation,
        togetherRemediation,
        tamperedRemediation,
        conflictRemediation
    }

    panel:HookScript("OnShow", function()
        local usingRaidStyle = IsUsingRaidStyleFrames()
        raidStyleResult:SetText(usingRaidStyle and "Passed!" or "Failed")
        raidStyleResult:SetFontObject(usingRaidStyle and "GameFontGreen" or "GameFontRed")

        local groupsTogether = KeepGroupsTogether()
        togetherResult:SetText(not groupsTogether and "Passed!" or "Failed")
        togetherResult:SetFontObject(not groupsTogether and "GameFontGreen" or "GameFontRed")

        local sortingTampered = SortingFunctionsTampered()
        tamperedResult:SetText(not sortingTampered and "Passed!" or "Failed")
        tamperedResult:SetFontObject(not sortingTampered and "GameFontGreen" or "GameFontRed")

        local conflictingAddons = ConflictingAddons()
        local noConflicts = conflictingAddons == nil

        conflictResult:SetText(noConflicts and "Passed!" or "Failed")
        conflictResult:SetFontObject(noConflicts and "GameFontGreen" or "GameFontRed")

        local healthy = usingRaidStyle and not groupsTogether and not sortingTampered and noConflicts

        remediationTitle:SetShown(not healthy)
        raidStyleRemediation:SetShown(not usingRaidStyle)
        togetherRemediation:SetShown(groupsTogether)
        tamperedRemediation:SetShown(sortingTampered)

        if not noConflicts then
            conflictRemediation:SetText("- '" .. conflictingAddons .. "' may cause conflicts, consider disabling it.")
        end

        -- for each visible message, reposition them
        local anchor = remediationTitle
        for _, control in ipairs(remediationControls) do
            if control:IsShown() then
                control:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -verticalSpacing)
                anchor = control
            end
        end
    end)

    InterfaceOptions_AddCategory(panel)
end
