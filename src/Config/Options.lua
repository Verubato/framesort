---@type string, Addon
local _, addon = ...
---@type WoW
local wow = addon.WoW
---@class OptionsBuilder
local M = {
    VerticalSpacing = 13,
    HorizontalSpacing = 50,
    Health = {},
    Macro = {},
    Sorting = {},
    Spacing = {},
    Keybinding = {},
    Integration = {},
    SortingMethod = {},
}
addon.OptionsBuilder = M

function M:TextShim(frame)
    if wow.WOW_PROJECT_ID ~= wow.WOW_PROJECT_CLASSIC then
        return
    end

    frame.Text = frame.text
end

---Initialises the addon options.
function addon:InitOptions()
    local panel = wow.CreateFrame("ScrollFrame", nil, nil, "UIPanelScrollFrameTemplate")
    panel.name = "FrameSort"

    local main = wow.CreateFrame("Frame")

    if wow.WOW_PROJECT_ID == wow.WOW_PROJECT_MAINLINE then
        main:SetWidth(wow.SettingsPanel.Container:GetWidth())
        main:SetHeight(wow.SettingsPanel.Container:GetHeight())
    else
        main:SetWidth(wow.InterfaceOptionsFramePanelContainer:GetWidth())
        main:SetHeight(wow.InterfaceOptionsFramePanelContainer:GetHeight())
    end

    panel:SetScrollChild(main)

    wow.InterfaceOptions_AddCategory(panel)

    M.Sorting:Build(main)
    M.SortingMethod:Build(panel)
    M.Keybinding:Build(panel)
    M.Macro:Build(panel)
    M.Spacing:Build(panel)
    M.Integration:Build(panel)
    M.Health:Build(panel)

    SLASH_FRAMESORT1 = "/fs"
    SLASH_FRAMESORT2 = "/framesort"

    wow.SlashCmdList.FRAMESORT = function()
        wow.InterfaceOptionsFrame_OpenToCategory(panel)

        -- workaround the classic bug where the first call opens the Game interface
        -- and a second call is required
        if wow.WOW_PROJECT_ID ~= wow.WOW_PROJECT_MAINLINE then
            wow.InterfaceOptionsFrame_OpenToCategory(panel)
        end
    end
end
