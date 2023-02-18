local addonName, addon = ...
local builder = addon.OptionsBuilder
local verticalSpacing = -16

---Adds the debug options panel.
---@param parentPanel table the parent UI panel.
function builder:BuildDebugOptions(parentPanel)
    local panel = CreateFrame("Frame", addonName .. "Debug", parent)
    panel.name = "Debug"
    panel.parent = parentPanel.name

    local enabled = CreateFrame("CheckButton", "chkDebugEnabled", panel, "UICheckButtonTemplate")
    enabled:SetPoint("TOPLEFT", panel, -verticalSpacing, verticalSpacing)
    enabled.Text:SetText("Debug mode")
    enabled.Text:SetFontObject("GameFontNormalLarge")
    enabled:SetChecked(addon.Options.DebugEnabled or false)
    enabled:HookScript("OnClick", function() addon:SetOption("DebugEnabled", enabled:GetChecked()) end)

    local description = panel:CreateFontString("lblDebugDescription", "ARTWORK", "GameFontWhite")
    description:SetPoint("TOPLEFT", enabled, "BOTTOMLEFT", 4, verticalSpacing)
    description:SetText("Logs messages to the chat panel which is useful for diagnosing bugs.")

    InterfaceOptions_AddCategory(panel)
end

