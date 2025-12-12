---@type string, Addon
local addonName, addon = ...
local wow = addon.WoW.Api
local fsConfig = addon.Configuration
local fsLog = addon.Logging.Log
local L = addon.Locale
local M = {}
fsConfig.Panels.Log = M

local logFrame
local copyWindow
local copyEditBox

local function GetAllLogMessages()
    if not logFrame then
        return ""
    end

    local lines = {}
    local num = logFrame:GetNumMessages() or 0

    for i = 1, num do
        local msg = logFrame:GetMessageInfo(i)
        if msg and msg ~= "" then
            lines[#lines + 1] = msg
        end
    end

    return table.concat(lines, "\n")
end

local function CreateCopyWindow()
    copyWindow = wow.CreateFrame("Frame", nil, nil, "BackdropTemplate")
    copyWindow:SetSize(800, 500)
    copyWindow:SetPoint("CENTER")
    copyWindow:SetFrameStrata("DIALOG")
    copyWindow:SetClampedToScreen(true)
    copyWindow:EnableMouse(true)
    copyWindow:SetMovable(true)
    copyWindow:RegisterForDrag("LeftButton")
    copyWindow:SetScript("OnDragStart", copyWindow.StartMoving)
    copyWindow:SetScript("OnDragStop", copyWindow.StopMovingOrSizing)
    copyWindow:Hide()

    copyWindow:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })

    local title = copyWindow:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -16)
    title:SetText(L["Log"])

    local close = wow.CreateFrame("Button", nil, copyWindow, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)

    local scrollFrame = wow.CreateFrame("ScrollFrame", nil, copyWindow, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 20, -40)
    scrollFrame:SetPoint("BOTTOMRIGHT", -32, 20)

    copyEditBox = wow.CreateFrame("EditBox", nil, scrollFrame)
    copyEditBox:SetMultiLine(true)
    copyEditBox:SetFontObject("GameFontHighlightSmall")
    copyEditBox:SetWidth(scrollFrame:GetWidth())
    copyEditBox:SetAutoFocus(true)
    copyEditBox:SetScript("OnEscapePressed", function()
        copyWindow:Hide()
    end)

    scrollFrame:SetScrollChild(copyEditBox)
end

local function ShowCopyWindow()
    local text = GetAllLogMessages()
    copyEditBox:SetText(text or "")
    copyEditBox:HighlightText()
    copyEditBox:SetFocus()

    copyWindow:Show()
end

local function OnLogEntry(msg, level, timestamp)
    if not logFrame then
        return
    end

    local levelText = fsLog:LevelText(level)
    local formatted = string.format("%dm %ds %s - %s", timestamp / 60, timestamp % 60, levelText, msg)

    if level == fsLog.Level.Error or level == fsLog.Level.Critical or level == fsLog.Level.Bug then
        logFrame:AddMessage(formatted, 1, 0, 0)
    elseif level == fsLog.Level.Warning then
        logFrame:AddMessage(formatted, 1, 1, 0)
    else
        logFrame:AddMessage(formatted)
    end
end

function M:Build(parent)
    local panel = wow.CreateFrame("Frame", nil, parent)
    panel.name = L["Log"]
    panel.parent = parent.name

    local verticalSpacing = fsConfig.VerticalSpacing
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", verticalSpacing, -verticalSpacing)
    title:SetText(L["Log"])

    local copyButton = wow.CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    copyButton:SetSize(120, 22)
    copyButton:SetPoint("TOPRIGHT", -verticalSpacing, -verticalSpacing)
    copyButton:SetText(L["Copy Log"])
    copyButton:SetScript("OnClick", function()
        ShowCopyWindow()
    end)

    local intro = {
        L["FrameSort log to help with diagnosing issues."],
    }

    local anchor = fsConfig:TextBlock(intro, panel, title)
    logFrame = wow.CreateFrame("ScrollingMessageFrame", nil, panel)

    local width = 800
    local height = 800
    local margin = 100
    local panelWidth, panelHeight = fsConfig:SettingsSize()

    width = panelWidth - margin
    height = panelHeight - margin

    logFrame:SetSize(width, height)
    logFrame:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -verticalSpacing)
    logFrame:SetFontObject("GameFontWhite")
    logFrame:SetJustifyH("LEFT")
    logFrame:EnableMouseWheel(true)
    logFrame:SetFading(false)
    logFrame:SetInsertMode("TOP")
    logFrame:SetMaxLines(5000)

    local scrollbar = wow.CreateFrame("Slider", nil, logFrame, "UIPanelScrollBarTemplate")
    scrollbar:SetPoint("TOPRIGHT", logFrame, "TOPRIGHT", 20, -16)
    scrollbar:SetPoint("BOTTOMRIGHT", logFrame, "BOTTOMRIGHT", 20, 16)
    scrollbar:SetWidth(16)

    scrollbar:SetValueStep(1)
    scrollbar:SetObeyStepOnDrag(true)

    scrollbar:SetScript("OnValueChanged", function(_, value)
        local max = logFrame:GetNumMessages()
        logFrame:SetScrollOffset(max - value)
    end)

    local function UpdateScrollbar()
        local max = logFrame:GetNumMessages()
        -- wow 3.3.5 has GetCurrentScroll instead of GetScrollOffset
        local scrollMethod = logFrame.GetScrollOffset or logFrame.GetCurrentScroll
        local offset = scrollMethod(logFrame)
        scrollbar:SetMinMaxValues(0, max)
        scrollbar:SetValue(max - offset)
    end

    logFrame:SetScript("OnMouseWheel", function(scroller, delta)
        if delta > 0 then
            scroller:ScrollUp()
        else
            scroller:ScrollDown()
        end

        UpdateScrollbar()
    end)

    -- get the log entries that happened before we got here
    local cachedLogEntries = fsLog:GetCachedEntries()
    for _, entry in ipairs(cachedLogEntries) do
        OnLogEntry(entry.Message, entry.Level, entry.Timestamp)
    end

    fsLog:ClearAndDisableCache()
    fsLog:AddLogCallback(OnLogEntry)

    CreateCopyWindow()

    return panel
end
