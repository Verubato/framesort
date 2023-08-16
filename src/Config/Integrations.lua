local _, addon = ...
---@type WoW
local wow = addon.WoW
local fsBuilder = addon.OptionsBuilder
local verticalSpacing = fsBuilder.VerticalSpacing

---Adds the integrations options panel.
---@param parent table the parent UI panel.
function fsBuilder:BuildIntegrationOptions(parent)
    local panel = wow.CreateFrame("Frame", "FrameSortSortingIntegrations", parent)
    panel.name = "Integrations"
    panel.parent = parent.name

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

    wow.InterfaceOptions_AddCategory(panel)
end
