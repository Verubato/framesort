local _, addon = ...
local fsBuilder = addon.OptionsBuilder
local fsSpacing = addon.Spacing
local verticalSpacing = fsBuilder.VerticalSpacing
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
end

local function ConfigureEditBox(box, value)
    box:SetFontObject("GameFontWhite")
    box:SetSize(50, 20)
    box:SetAutoFocus(false)
    box:SetMaxLetters(math.log10(maxSpacing) + 1)
    box:SetText(tostring(value))
    box:SetCursorPosition(0)
    box:SetJustifyH("CENTER")
    box:SetNumeric(true)
end

local function BuildSpacingOptions(panel, parentAnchor, name, spacing, addX, addY, additionalTopSpacing)
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", parentAnchor, "BOTTOMLEFT", 0, -(verticalSpacing + additionalTopSpacing))
    title:SetText(name)

    local anchor = title
    local setValue = function(auto, slider, box)
        local value = tonumber(auto)

        if not value or value < minSpacing or value > maxSpacing then
            box:SetFontObject("GameFontRed")
            return nil
        end

        local text = tostring(value)
        box:SetFontObject("GameFontWhite")

        box:SetText(text)
        slider:SetValue(value)
        return value
    end

    if addX then
        local label = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
        label:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -verticalSpacing)
        label:SetText("Horizontal")

        local slider = CreateFrame("Slider", "sld" .. name .. "XSpacing", panel, "OptionsSliderTemplate")
        slider:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -verticalSpacing)
        ConfigureSlider(slider, spacing.Horizontal)

        local box = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
        box:SetPoint("CENTER", slider, "CENTER", 0, 25)
        ConfigureEditBox(box, spacing.Horizontal)

        slider:SetScript("OnValueChanged", function(_, sliderValue, userInput)
            if not userInput then
                return
            end

            local value = setValue(sliderValue, slider, box)
            if value then
                spacing.Horizontal = value
                fsSpacing:ApplySpacing()
            end
        end)

        box:SetScript("OnTextChanged", function(_, userInput)
            if not userInput then
                return
            end

            local value = setValue(box:GetText(), slider, box)
            if value then
                spacing.Horizontal = value
                fsSpacing:ApplySpacing()
            end
        end)

        anchor = slider
    end

    if addY then
        local label = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
        label:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -verticalSpacing)
        label:SetText("Vertical")

        local slider = CreateFrame("Slider", "sld" .. name .. "YSpacing", panel, "OptionsSliderTemplate")
        slider:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -verticalSpacing)
        ConfigureSlider(slider, spacing.Vertical)

        local box = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
        box:SetPoint("CENTER", slider, "CENTER", 0, 25)
        ConfigureEditBox(box, spacing.Vertical)

        slider:SetScript("OnValueChanged", function(_, sliderValue, userInput)
            if not userInput then
                return
            end

            local value = setValue(sliderValue, slider, box)
            if value then
                spacing.Vertical = value
                fsSpacing:ApplySpacing()
            end
        end)

        box:SetScript("OnTextChanged", function(_, userInput)
            if not userInput then
                return
            end

            local value = setValue(box:GetText(), slider, box)

            if value then
                spacing.Vertical = value
                fsSpacing:ApplySpacing()
            end
        end)

        anchor = slider
    end

    return anchor
end

---Adds the spacing options panel.
---@param parent table the parent UI panel.
function fsBuilder:BuildSpacingOptions(parent)
    local panel = CreateFrame("Frame", "FrameSortSpacing", parent)
    panel.name = "Spacing"
    panel.parent = parent.name

    local spacingTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    spacingTitle:SetPoint("TOPLEFT", panel, verticalSpacing, -verticalSpacing)
    spacingTitle:SetText("Spacing")

    local spacingDescription = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    spacingDescription:SetPoint("TOPLEFT", spacingTitle, "BOTTOMLEFT", 0, -verticalSpacing)
    spacingDescription:SetText("Add some spacing between party/raid frames.")

    local anchor = spacingDescription
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        -- for retail
        anchor = BuildSpacingOptions(panel, anchor, "Party", addon.Options.Appearance.Party.Spacing, true, true, 0)
    end

    local title = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE and "Raid" or "Group"
    anchor = BuildSpacingOptions(panel, anchor, title, addon.Options.Appearance.Raid.Spacing, true, true, verticalSpacing)

    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE and CompactArenaFrame then
        anchor = BuildSpacingOptions(panel, anchor, "Enemy Arena", addon.Options.Appearance.EnemyArena.Spacing, false, true, verticalSpacing)
    end

    InterfaceOptions_AddCategory(panel)
end
