---@type string, Addon
local _, addon = ...
local fsSorting = addon.Modules.Sorting
local fsConfig = addon.Configuration
local fsScheduler = addon.Scheduling.Scheduler
local wow = addon.WoW.Api
local minSpacing = 0
local maxSpacing = 100
local M = {}
fsConfig.Panels.Spacing = M

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
    box:SetCursorPosition(0)
end

local function ApplySpacing()
    fsScheduler:RunWhenCombatEnds(function()
        fsSorting:Run()
    end, "ApplySpacingConfig")
end

local function BuildSpacingOptions(panel, parentAnchor, name, spacing, addX, addY, additionalTopSpacing)
    local verticalSpacing = fsConfig.VerticalSpacing
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", parentAnchor, "BOTTOMLEFT", 0, -(verticalSpacing + additionalTopSpacing))
    title:SetText(name)

    local anchor = title
    local systemChange = false
    local setValue = function(auto, slider, box)
        local value = tonumber(auto)

        if not value or value < minSpacing or value > maxSpacing then
            box:SetFontObject("GameFontRed")
            return nil
        end

        local text = tostring(value)
        box:SetFontObject("GameFontWhite")

        systemChange = true
        box:SetText(text)
        slider:SetValue(value)
        systemChange = false

        return value
    end

    if addX then
        local label = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
        label:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -verticalSpacing)
        label:SetText("Horizontal")

        local slider = wow.CreateFrame("Slider", "sld" .. name .. "XSpacing", panel, "OptionsSliderTemplate")
        slider:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -verticalSpacing)
        ConfigureSlider(slider, spacing.Horizontal)

        local box = wow.CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
        box:SetPoint("CENTER", slider, "CENTER", 0, 30)
        ConfigureEditBox(box, spacing.Horizontal)

        slider:SetScript("OnValueChanged", function(_, sliderValue, userInput)
            if systemChange or (userInput ~= nil and not userInput) then
                -- wotlk private doesn't have the userInput flag for sliders, but it does for text boxes
                -- so check our own flag
                return
            end

            local value = setValue(sliderValue, slider, box)
            if value then
                spacing.Horizontal = value
                fsConfig:NotifyChanged()
                ApplySpacing()
            end
        end)

        box:SetScript("OnTextChanged", function(_, userInput)
            if not userInput then
                return
            end

            local value = setValue(box:GetText(), slider, box)
            if value then
                spacing.Horizontal = value
                fsConfig:NotifyChanged()
                ApplySpacing()
            end
        end)

        anchor = slider
    end

    if addY then
        local label = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
        label:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -verticalSpacing)
        label:SetText("Vertical")

        local slider = wow.CreateFrame("Slider", "sld" .. name .. "YSpacing", panel, "OptionsSliderTemplate")
        slider:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -verticalSpacing)
        ConfigureSlider(slider, spacing.Vertical)

        local box = wow.CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
        box:SetPoint("CENTER", slider, "CENTER", 0, 30)
        ConfigureEditBox(box, spacing.Vertical)

        slider:SetScript("OnValueChanged", function(_, sliderValue, userInput)
            if systemChange or (userInput ~= nil and not userInput) then
                return
            end

            box:SetText(tostring(sliderValue))

            local value = setValue(sliderValue, slider, box)
            if value then
                spacing.Vertical = value
                fsConfig:NotifyChanged()
                ApplySpacing()
            end
        end)

        box:SetScript("OnTextChanged", function(_, userInput)
            if not userInput then
                return
            end

            local value = setValue(box:GetText(), slider, box)

            if value then
                spacing.Vertical = value
                fsConfig:NotifyChanged()
                ApplySpacing()
            end
        end)

        anchor = slider
    end

    return anchor
end

function M:Build(parent)
    local verticalSpacing = fsConfig.VerticalSpacing
    local panel = wow.CreateFrame("Frame", nil, parent)
    panel.name = "Spacing"
    panel.parent = parent.name

    local spacingTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    spacingTitle:SetPoint("TOPLEFT", panel, verticalSpacing, -verticalSpacing)
    spacingTitle:SetText("Spacing")

    local descriptionLine1 = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    descriptionLine1:SetPoint("TOPLEFT", spacingTitle, "BOTTOMLEFT", 0, -verticalSpacing)
    descriptionLine1:SetText("Add some spacing between party/raid frames.")

    local descriptionLine2 = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    descriptionLine2:SetPoint("TOPLEFT", descriptionLine1, "BOTTOMLEFT", 0, -verticalSpacing)
    descriptionLine2:SetText("This only applies to Blizzard frames.")

    local anchor = descriptionLine2
    local config = addon.DB.Options.Spacing
    if wow.IsRetail() then
        -- for retail
        anchor = BuildSpacingOptions(panel, anchor, "Party", config.Party, true, true, 0)
    end

    local title = wow.IsRetail() and "Raid" or "Group"
    anchor = BuildSpacingOptions(panel, anchor, title, config.Raid, true, true, verticalSpacing)

    if wow.IsRetail() and wow.CompactArenaFrame then
        anchor = BuildSpacingOptions(panel, anchor, "Enemy Arena", config.EnemyArena, false, true, verticalSpacing)
    end

    return panel
end
