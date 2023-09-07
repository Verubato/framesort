---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsConfig = addon.Configuration
local M = {}
fsConfig.Announcement = M

function M:Build(panel)
    local verticalSpacing = fsConfig.VerticalSpacing
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", verticalSpacing, -verticalSpacing)
    title:SetText("Announcement")

    local important = panel:CreateFontString(nil, "ARTWORK", "GameFontRedLarge")
    important:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -verticalSpacing)
    important:SetText("WoW patch 10.1.7 has broken FrameSort.")

    local lines = {
        "Blizzard have restricted the API method that FrameSort uses for sorting and spacing frames.",
        "The API method can no longer be used during combat.",
        "",
        "This is a problem because sorting is lost when frames are refreshed mid-combat which happens",
        "on events such as pet summons/dismisses, mind control, entering/exiting a vehicle,",
        "killing a boss, and members joining/leaving the group.",
        "",
        "Further discussion on Reddit:",
    }

    local anchor = important
    for i, text in ipairs(lines) do
        local line = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
        line:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, i == 1 and -verticalSpacing or -verticalSpacing / 2)
        line:SetText(text)
        anchor = line
    end

    local redditLink = "https://www.reddit.com/r/worldofpvp/comments/16bjeli/psa_1017_has_broken_framesort/"
    local box = wow.CreateFrame("EditBox", nil, panel)
    box:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -verticalSpacing)
    box:SetSize(600, 1)
    box:SetFontObject("GameFontWhite")
    box:SetAutoFocus(false)
    box:SetMultiLine(true)
    box:SetText(redditLink)
    box:SetCursorPosition(0)

    -- undo any user changes
    box:SetScript("OnTextChanged", function(_, userInput)
        if not userInput then
            return
        end

        box:SetText(redditLink)
    end)

    box:SetScript("OnEscapePressed", function()
        box:ClearFocus()
    end)

    local padding = 10
    box:SetTextInsets(padding, padding, padding, padding)

    local bg = wow.CreateFrame("Frame", nil, panel, "BackdropTemplate")
    bg:SetBackdrop({
        edgeFile = "Interface\\Glues\\Common\\TextPanel-Border",
        edgeSize = 16,
    })
    bg:SetAllPoints(box)

    local workaround = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    workaround:SetPoint("TOPLEFT", box, "BOTTOMLEFT", 0, -verticalSpacing)
    workaround:SetText("Workaround")

    local suggestion = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    suggestion:SetPoint("TOPLEFT", workaround, "BOTTOMLEFT", 0, -verticalSpacing)
    suggestion:SetText("As a workaround, use the Traditional sorting method and /reload at the start of each arena match.")

    local fin = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    fin:SetPoint("TOPLEFT", suggestion, "BOTTOMLEFT", 0, -verticalSpacing)
    fin:SetText("Hang in there bros while I try to find a better solution.")
end
