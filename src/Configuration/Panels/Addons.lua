---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsConfig = addon.Configuration
local M = {}
fsConfig.Panels.Addons = M

function M:Build(parent)
    local panel = wow.CreateFrame("Frame", nil, parent)
    panel.name = "Addons"
    panel.parent = parent.name

    local verticalSpacing = fsConfig.VerticalSpacing
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", verticalSpacing, -verticalSpacing)
    title:SetText("Addons")

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
        "Gladius *NEW*",
        " - May not work 100%, needs testing.",
        " - Arena: yes",
        " - Bicmex version: yes",
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
