BINDING_HEADER_FRAMESORT_TARGET = "Targeting"
_G["BINDING_NAME_CLICK FSTarget1:LeftButton"]= "Target frame 1"
_G["BINDING_NAME_CLICK FSTarget2:LeftButton"]= "Target frame 2"
_G["BINDING_NAME_CLICK FSTarget3:LeftButton"]= "Target frame 3"
_G["BINDING_NAME_CLICK FSTarget4:LeftButton"]= "Target frame 4"
_G["BINDING_NAME_CLICK FSTarget5:LeftButton"]= "Target frame 5"

local _, addon = ...
local builder = addon.OptionsBuilder
local verticalSpacing = addon.OptionsBuilder.VerticalSpacing

---Adds the keybinding options description panel.
---@param parent table the parent UI panel.
function builder:BuildKeybindingOptions(parent)
    local panel = CreateFrame("Frame", "FrameSortKeybindings", parent)
    panel.name = "Keybindings"
    panel.parent = parent.name

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", verticalSpacing, -verticalSpacing)
    title:SetText("Keybindings")

    local lines = {
        "You can find the FrameSort keybindings in the standard WoW keybindings area.",
        "",
        "What are the keybindings useful for?",
        "They are useful for targeting players by their visually ordered representation rather than their",
        "party position (party1/2/3/etc.)",
        "",
        "For example, imagine a 5-man dungeon group sorted by role that looks like the following:",
        "  - Tank, party3",
        "  - Healer, player",
        "  - DPS, party1",
        "  - DPS, party4",
        "  - DPS, party2",
        "",
        "As you can see their visual representation differs to their actual party position which",
        "makes targeting confusing.",
        "If you were to /target party1, it would target the DPS player in position 3 rather than the tank.",
        "",
        "The FrameSort keybindings will target based on the visual frame position rather than the party position.",
        "So targeting 'Frame 1' will target the Tank, 'Frame 2' the healer, 'Frame 3' the DPS in spot 3, and so on.",
    }

    local anchor = title
    for _, line in ipairs(lines) do
        local description = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
        description:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -verticalSpacing / 2)
        description:SetText(line)
        anchor = description
    end

    InterfaceOptions_AddCategory(panel)
end
