---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsConfig = addon.Configuration
local fsLog = addon.Logging.Log
local L = addon.Locale
local M = {}
fsConfig.Panels.Log = M

local logFrame

local function OnLogEntry(msg, level, timestamp)
    if not logFrame then
        return
    end

    local formatted = string.format("%dm %ds %s - %s", timestamp / 60, timestamp % 60, level, msg)

    if level == "Error" then
        logFrame:AddMessage(formatted, 1, 0, 0)
    elseif level == "Warning" then
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

    local intro = {
        L["FrameSort log to help with diagnosing issues."],
    }

    local anchor = fsConfig:TextBlock(intro, panel, title)
    logFrame = wow.CreateFrame("ScrollingMessageFrame", nil, panel)

    local width = 800
    local height = 800
    local margin = 100

    if wow.SettingsPanel then
        width = wow.SettingsPanel.Container:GetWidth() - margin
        height = wow.SettingsPanel.Container:GetHeight() - margin
    elseif wow.InterfaceOptionsFramePanelContainer then
        width = wow.InterfaceOptionsFramePanelContainer:GetWidth() - margin
        height = wow.InterfaceOptionsFramePanelContainer:GetHeight() - margin
    end

    -- Basic settings
    logFrame:SetSize(width, height)
    logFrame:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -verticalSpacing)
    logFrame:SetFontObject("GameFontWhite")
    logFrame:SetJustifyH("LEFT")
    logFrame:EnableMouseWheel(true)
    logFrame:SetFading(false)
    logFrame:SetInsertMode("TOP")
    logFrame:SetMaxLines(5000)

    -- scroll bar
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

    -- Sync scrollbar to mouse wheel / messages
    local function UpdateScrollbar()
        local max = logFrame:GetNumMessages()
        local offset = logFrame:GetScrollOffset()
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

    anchor = logFrame

    return panel
end
