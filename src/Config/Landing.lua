local _, addon = ...
local builder = addon.OptionsBuilder
local verticalSpacing = addon.OptionsBuilder.VerticalSpacing

---Adds the landing screen options panel.
---@param panel table the panel to add the UI controls to.
function builder:BuildLanding(panel)
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", verticalSpacing, -verticalSpacing)
    title:SetText("FrameSort")

    local countLine = panel:CreateFontString(nil, "ARTWORK", "GameFontGreen")
    countLine:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -verticalSpacing)
    countLine:SetText("Announcement")

    local lines = {
        "Since Blizzard's 10.1 patch there have been some newly introduced issues that affect FrameSort.",
        "I'm currently working on fixing them and will be releasing updates ASAP.",
        "This release of FrameSort has some major internal changes that should hopefully resolve many of them.",
        "",
        "Known issues that cause frames to become unsorted are:",
        " - Priests mind control.",
        " - Pets being summoned/killed/dismissed.",
        "",
        "If the latest version isn't working for you then there are two workarounds you can try:",
        "",
        "1. Disable \"Display Pets\" in Blizzard's raid frame settings.",
        "2. Use the Traditional sorting method instead of Taintless.",
        "",
        "Fix #1 should be sufficient (and keep Taintless on), but feel free to try #2 as well.",
        "",
        "I'll remove this message after the 10.1 issues have been resolved.",
        "",
        "I'd appreciate any feedback you can provide with how the latest updates are going."
    }

    local anchor = countLine
    for i, line in ipairs(lines) do
        local description = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
        description:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, i == 1 and -verticalSpacing or -verticalSpacing / 2)
        description:SetText(line)
        anchor = description
    end
end

