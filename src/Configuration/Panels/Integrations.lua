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
        "FrameSort has mostly been developed for Blizzard frames but also supports some other frame addons.",
        "",
        "This functionality is very new and is still being developed.",
        "Feel free to let me know (Curseforge/GitHub) if you encounter any issues or have any feature requests.",
        "",
        "Here is the current status:",
        "",
        "ElvUI",
        " - Party: yes",
        " - Raid: no",
        " - Arena: no",
        " - Pets: no",
        " - Hide player: no",
        "",
        "sArena",
        " - Arena: yes",
        "",
        "GladiusEx",
        " - Party: yes",
        " - Arena: yes",
        " - Hide player: no",
        "",
        "Shadowed Unit Frames:",
        " - not yet implemented",
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
