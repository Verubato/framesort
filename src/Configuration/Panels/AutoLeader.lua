---@type string, Addon
local _, addon = ...
local fsConfig = addon.Configuration
local wow = addon.WoW.Api
local M = {}
fsConfig.Panels.AutoLeader = M

function M:Build(parent)
    local verticalSpacing = fsConfig.VerticalSpacing
    local panel = wow.CreateFrame("Frame", nil, parent)
    panel.name = "Auto Leader"
    panel.parent = parent.name

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", verticalSpacing, -verticalSpacing)
    title:SetText("Auto Leader")

    local lines = {
        "Auto promote healers to leader in solo shuffle.",
        "Why? So healers can configure target marker icons and re-order party1/2 to their preference.",
    }

    local anchor = title
    for i, line in ipairs(lines) do
        local text = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
        text:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, i == 1 and -verticalSpacing or -verticalSpacing / 2)
        text:SetText(line)
        anchor = text
    end

    local enabled = wow.CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    enabled:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", -4, -verticalSpacing)
    enabled.Text:SetText("Enabled")
    enabled.Text:SetFontObject("GameFontNormalLarge")
    enabled:SetChecked(addon.DB.Options.AutoLeader.Enabled or false)

    local function OnClick(box)
        addon.DB.Options.AutoLeader.Enabled = box:GetChecked()
    end

    enabled:HookScript("OnClick", OnClick)

    return panel
end
