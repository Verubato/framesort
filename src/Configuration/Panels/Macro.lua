---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsMacro = addon.Modules.Macro.Parser
local fsConfig = addon.Configuration
local fsLog = addon.Logging.Log
local L = addon.Locale
local M = {}
fsConfig.Panels.Macro = M

local function CountMacros()
    local count = 0

    for i = 1, addon.Modules.Macro.MaxMacros do
        local _, _, body = wow.GetMacroInfo(i)

        if body and fsMacro:IsFrameSortMacro(body) then
            count = count + 1
        end
    end

    return count
end

function M:Build(parent)
    local scroller = wow.CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    scroller.name = L["Macros"]
    scroller.parent = parent.name

    local panel = wow.CreateFrame("Frame")

    if wow.SettingsPanel then
        panel:SetWidth(wow.SettingsPanel.Container:GetWidth())
        panel:SetHeight(wow.SettingsPanel.Container:GetHeight())
    elseif wow.InterfaceOptionsFramePanelContainer then
        panel:SetWidth(wow.InterfaceOptionsFramePanelContainer:GetWidth())
        panel:SetHeight(wow.InterfaceOptionsFramePanelContainer:GetHeight())
    else
        fsLog:Bug("Unable to set configuration panel width.")
    end

    scroller:SetScrollChild(panel)

    local verticalSpacing = fsConfig.VerticalSpacing
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", verticalSpacing, -verticalSpacing)
    title:SetText(L["Macros"])

    local countText = L["FrameSort has found %d |4macro:macros; to manage."]
    local countLine = panel:CreateFontString(nil, "ARTWORK", "GameFontGreen")
    countLine:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -verticalSpacing)
    countLine:SetText(string.format(countText, 0))

    panel:HookScript("OnShow", function()
        local count = CountMacros()
        countLine:SetText(string.format(countText, count))
    end)

    local intro = {
        L['FrameSort will dynamically update variables within macros that contain the "#FrameSort" header.'],
        L["Below are some examples on how to use this."],
    }

    local anchor = fsConfig:TextBlock(intro, panel, countLine)
    local examples = {
        L["Macro_Example1"],
        L["Macro_Example2"],
        L["Macro_Example3"],
    }

    local padding = 10
    for i, example in ipairs(examples) do
        local header = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
        header:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -verticalSpacing)
        header:SetText(string.format(L["Example %d"], i))

        local box = wow.CreateFrame("EditBox", nil, panel)
        box:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -verticalSpacing)
        box:SetSize(500, 1)
        box:SetFontObject("GameFontWhite")
        box:SetAutoFocus(false)
        box:SetMultiLine(true)
        box:SetText(example)
        box:SetCursorPosition(0)

        -- undo any user changes
        box:SetScript("OnTextChanged", function(_, userInput)
            if not userInput then
                return
            end

            box:SetText(example)
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
    end

    local aiBlurb = L["Discord Bot Blurb"]
    anchor = fsConfig:MultilineTextBlock(aiBlurb, panel, anchor)

    return scroller
end
