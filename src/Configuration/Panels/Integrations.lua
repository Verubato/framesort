---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsConfig = addon.Configuration
local M = {}
fsConfig.Panels.Integration = M

function M:Build(parent)
    local panel = wow.CreateFrame("Frame", "FrameSortSortingIntegrations", parent)
    panel.name = "Integrations"
    panel.parent = parent.name

    local verticalSpacing = fsConfig.VerticalSpacing
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", verticalSpacing, -verticalSpacing)
    title:SetText("Integrations")

    local lines = {
        "In addition to Blizzard frames, FrameSort also supports the following addons:",
        "",
        "ElvUI",
        " - Party: yes",
        " - Raid: no",
        " - Arena: no",
        "",
        "sArena",
        " - Arena: yes",
        "",
        "GladiusEx",
        " - Party: yes",
        " - Arena: yes",
    }

    local anchor = title
    for i, line in ipairs(lines) do
        local description = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
        description:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, i == 1 and -verticalSpacing or -verticalSpacing / 2)
        description:SetText(line)
        anchor = description
    end

    return panel
end
