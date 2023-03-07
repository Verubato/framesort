local addonName, addon = ...
local builder = addon.OptionsBuilder
local verticalSpacing = addon.OptionsBuilder.VerticalSpacing
local minSpacing = 0
local maxSpacing = 100

local function ConfigureSlider(slider, value)
    slider:SetOrientation("HORIZONTAL")
    slider:SetMinMaxValues(minSpacing, maxSpacing)
    slider:SetValue(value)
    slider:SetValueStep(1)
    slider:SetObeyStepOnDrag(true)
    slider:SetHeight(20)
    slider:SetWidth(400)

    _G[slider:GetName() .. "Low"]:SetText(minSpacing)
    _G[slider:GetName() .. "High"]:SetText(maxSpacing)
    _G[slider:GetName() .. "Text"]:SetText(value)
end

local function BuildSpacingOptions(panel, anchor, name, spacing, additionalTopSpacing)
    local title = panel:CreateFontString("lbl" .. name .. "Title", "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -(verticalSpacing + additionalTopSpacing))
    title:SetText(name)

    local xLabel = panel:CreateFontString("lbl" .. name .. "XSpacing", "ARTWORK", "GameFontWhite")
    xLabel:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -verticalSpacing)
    xLabel:SetText("Horizontal")

    local xSlider = CreateFrame("Slider", "sld" .. name .. "XSpacing", panel, "OptionsSliderTemplate")
    xSlider:SetPoint("TOPLEFT", xLabel, "BOTTOMLEFT", 0, -verticalSpacing)
    ConfigureSlider(xSlider, spacing.Horizontal)

    xSlider:SetScript("OnValueChanged", function(_, value, _)
        _G[xSlider:GetName() .. "Text"]:SetText(tostring(value))
        spacing.Horizontal = value
        addon:ApplySpacing()
    end)

    local yLabel = panel:CreateFontString("lbl" .. name .. "YSpacing", "ARTWORK", "GameFontWhite")
    yLabel:SetPoint("TOPLEFT", xSlider, "BOTTOMLEFT", 0, -verticalSpacing * 2)
    yLabel:SetText("Vertical")

    local ySlider = CreateFrame("Slider", "sld" .. name .. "YSpacing", panel, "OptionsSliderTemplate")
    ySlider:SetPoint("TOPLEFT", yLabel, "BOTTOMLEFT", 0, -verticalSpacing)
    ConfigureSlider(ySlider, spacing.Vertical)

    ySlider:SetScript("OnValueChanged", function(_, value, _)
        _G[ySlider:GetName() .. "Text"]:SetText(tostring(value))
        spacing.Vertical = value
        addon:ApplySpacing()
    end)

    return ySlider
end

---Adds the spacing options panel.
---@param parentPanel table the parent UI panel.
function builder:BuildSpacingOptions(parentPanel)
    local panel = CreateFrame("Frame", addonName .. "Spacing", parentPanel)
    panel.name = "Spacing"
    panel.parent = parentPanel.name

    local spacingTitle = panel:CreateFontString("lblSpacingTitle", "ARTWORK", "GameFontNormalLarge")
    spacingTitle:SetPoint("TOPLEFT", panel, verticalSpacing, -verticalSpacing)
    spacingTitle:SetText("Spacing")

    local spacingDescription = panel:CreateFontString("lblAppearanceDescription", "ARTWORK", "GameFontWhite")
    spacingDescription:SetPoint("TOPLEFT", spacingTitle, "BOTTOMLEFT", 0, -verticalSpacing)
    spacingDescription:SetText("Add some spacing between party/raid frames.")

    local anchor = spacingDescription
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        -- for retail
        anchor = BuildSpacingOptions(panel, anchor, "Party", addon.Options.Appearance.Party.Spacing, 0)
    end

    local title = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE and "Raid" or "Group"
    anchor = BuildSpacingOptions(panel, anchor, title, addon.Options.Appearance.Raid.Spacing, verticalSpacing)

    InterfaceOptions_AddCategory(panel)
end
