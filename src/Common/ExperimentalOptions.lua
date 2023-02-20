local addonName, addon = ...
local builder = addon.OptionsBuilder
local verticalSpacing = -16

---Adds the experimental options panel.
---@param parentPanel table the parent UI panel.
function builder:BuildExperimentalOptions(parentPanel)
    local panel = CreateFrame("Frame", addonName .. "Experimental", parent)
    panel.name = "Experimental"
    panel.parent = parentPanel.name

    local enabled = CreateFrame("CheckButton", "chkExperimentalEnabled", panel, "UICheckButtonTemplate")
    enabled:SetPoint("TOPLEFT", panel, -verticalSpacing, verticalSpacing)
    enabled.Text:SetText("Experimental (requires reload)")
    enabled.Text:SetFontObject("GameFontNormalLarge")
    enabled:SetChecked(addon.Options.ExperimentalEnabled or false)
    enabled:HookScript("OnClick", function() addon:SetOption("ExperimentalEnabled", enabled:GetChecked()) end)

    local lines = {
        "Experimental new sorting mode that shouldn't bug/lock/taint the UI.",
        "Hasn't been fully tested yet hence why it's still experimental.",
        "Please reload after changing this setting."
    }

    local previous = enabled
    for i, line in ipairs(lines) do
        local description = panel:CreateFontString("lblExperimentalDescription" .. tostring(i), "ARTWORK", "GameFontWhite")
        description:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", i == 1 and 4 or 0, verticalSpacing)
        description:SetText(line)
        previous = description
    end

    InterfaceOptions_AddCategory(panel)
end

