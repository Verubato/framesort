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
    important:SetText("Blizzard patch 10.1.7 has broken FrameSort very badly.")

    local more = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    more:SetPoint("TOPLEFT", important, "BOTTOMLEFT", 0, -verticalSpacing)
    more:SetText("More info in the below Reddit post.")

    local redditLink = "https://www.reddit.com/r/worldofpvp/comments/16bjeli/psa_1017_has_broken_framesort/"
    local box = wow.CreateFrame("EditBox", nil, panel)
    box:SetPoint("TOPLEFT", more, "BOTTOMLEFT", 0, -verticalSpacing)
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

    local suggestion = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    suggestion:SetPoint("TOPLEFT", box, "BOTTOMLEFT", 0, -verticalSpacing)
    suggestion:SetText("As an interim, you might like to try your luck with the Traditional sorting method instead of Taintless.")

    local fin = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    fin:SetPoint("TOPLEFT", suggestion, "BOTTOMLEFT", 0, -verticalSpacing)
    fin:SetText("Hang in there bros while I try to find a workaround/solution.")
end
