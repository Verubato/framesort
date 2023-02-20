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

---Adds the health check options panel.
---@param parent table the parent UI panel.
function builder:BuildHealthCheck(parent)
    local panel = CreateFrame("Frame", addonName .. "HealthCheck", parent)
    panel.name = "Health Check"
    panel.parent = parent.name

    local title = panel:CreateFontString("lblHealthCheck", "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", verticalSpacing, -verticalSpacing)
    title:SetText("Health Check")

    local description = panel:CreateFontString("lblHealthCheck", "ARTWORK", "GameFontWhite")
    description:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -verticalSpacing)
    description:SetText("Any known issues with configuration or conflicting addons will be shown below.")

    local raidStyleWarning = panel:CreateFontString("lblRaidStyleFramesWarning", "ARTWORK", "GameFontRed")
    raidStyleWarning:SetPoint("TOPLEFT", description, "BOTTOMLEFT", 0, -verticalSpacing)
    raidStyleWarning:SetText("Please enable 'Use Raid-Style Party Frames' in the Blizzard settings.")

    local tamperedWarning = panel:CreateFontString("lblInBuiltSortingWarning", "ARTWORK", "GameFontRed")
    tamperedWarning:SetPoint("TOPLEFT", raidStyleWarning, "BOTTOMLEFT", 0, -verticalSpacing)
    tamperedWarning:SetText("Blizzard sorting functions have been tampered with, please disable other frame sorting macro/addons.")

    local conflictWarning = panel:CreateFontString("lblConflictingAddonsWarning", "ARTWORK", "GameFontRed")
    conflictWarning:SetPoint("TOPLEFT", tamperedWarning, "BOTTOMLEFT", 0, -verticalSpacing)

    local healthyMessage = panel:CreateFontString("lblHealthy", "ARTWORK", "GameFontGreen")
    healthyMessage:SetPoint("TOPLEFT", description, "BOTTOMLEFT", 0, -verticalSpacing)
    healthyMessage:SetText("All health checks have passed!")

    local controls = {
        raidStyleWarning,
        tamperedWarning,
        conflictWarning
    }

    panel:HookScript("OnShow", function()
        local usingRaidStyle = IsUsingRaidStyleFrames()
        local sortingTampered = SortingFunctionsTampered()

        raidStyleWarning:SetShown(not usingRaidStyle)

        tamperedWarning:SetShown(sortingTampered)
        if sortingTampered then
            tamperedWarning:SetPoint("TOPLEFT", description, "BOTTOMLEFT", 0, -verticalSpacing)
        end

        local conflictingAddons = ConflictingAddons()
        conflictWarning:SetShown(conflictingAddons ~= nil)
        conflictWarning:SetText(conflictingAddons
        and "'" .. conflictingAddons .. "' may cause conflicts, consider disabling it."
        or "")

        local healthy = usingRaidStyle and not sortingTampered and not conflictingAddons
        healthyMessage:SetShown(healthy)

        -- for each visible message, reposition them
        local anchor = description
        for _, control in ipairs(controls) do
            if control:IsShown() then
                control:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -verticalSpacing)
                anchor = control
            end
        end
    end)

    InterfaceOptions_AddCategory(panel)
end
