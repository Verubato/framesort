---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsConfig = addon.Configuration
local M = {}
fsConfig.Panels.Help = M

function M:Build(parent)
    local panel = wow.CreateFrame("Frame", nil, parent)
    panel.name = "Help"
    panel.parent = parent.name

    local verticalSpacing = fsConfig.VerticalSpacing
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", verticalSpacing, -verticalSpacing)
    title:SetText("Discord")

    local anchor = title
    local intro = {
        "Need help with something?",
        "Talk directly with the developer on Discord."
    }

    for _, line in ipairs(intro) do
        local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
        subtitle:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -verticalSpacing)
        subtitle:SetText(line)
        anchor = subtitle
    end

    local link = "https://discord.gg/bF3XkyuU3E"
    local padding = 10

    local box = wow.CreateFrame("EditBox", nil, panel)
    box:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -verticalSpacing)
    box:SetSize(500, 1)
    box:SetFontObject("GameFontWhite")
    box:SetAutoFocus(false)
    box:SetMultiLine(true)
    box:SetText(link)
    box:SetCursorPosition(0)

    -- undo any user changes
    box:SetScript("OnTextChanged", function(_, userInput)
        if not userInput then
            return
        end

        box:SetText(link)
    end)

    box:SetScript("OnEscapePressed", function()
        box:ClearFocus()
    end)
    box:SetTextInsets(padding, padding, padding, padding)

    local bg = wow.CreateFrame("Frame", nil, panel, "BackdropTemplate")
    bg:SetBackdrop({
        edgeFile = "Interface\\Glues\\Common\\TextPanel-Border",
        edgeSize = 16,
    })
    bg:SetAllPoints(box)

    anchor = box

    return panel
end
