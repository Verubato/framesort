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
        "FrameSort supports the following:",
        "",
        "Blizzard",
        " - Party: yes",
        " - Raid: yes",
        " - Arena: broken (will fix it eventually).",
        "",
        "ElvUI",
        " - Party: yes",
        " - Raid: no",
        " - Arena: no",
        "",
        "sArena",
        " - Arena: yes",
        "",
        "Gladius",
        " - Arena: yes",
        " - Bicmex version: yes",
        "",
        "GladiusEx",
        " - Party: yes",
        " - Arena: yes",
        "",
        "Cell *new*",
        " - Party: yes",
        " - Raid: yes, only when using combined groups.",
    }

    fsConfig:TextBlock(lines, panel, title)

    return panel
end
