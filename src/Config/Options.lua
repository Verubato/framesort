---@type string, Addon
local _, addon = ...
---@type WoW
local wow = addon.WoW
---@class OptionsBuilder
local M = {
    VerticalSpacing = 13,
    HorizontalSpacing = 50,
}
addon.OptionsBuilder = M

local function AddCategory(panel)
    if wow.IsRetail() then
        local category = wow.Settings.RegisterCanvasLayoutCategory(panel, panel.name, panel.name)
        category.ID = panel.name
        wow.Settings.RegisterAddOnCategory(category)
    else
        wow.InterfaceOptions_AddCategory(panel)
    end
end

local function AddSubCategory(panel)
    if wow.IsRetail() then
        local category = wow.Settings.GetCategory(panel.parent)
        local subcategory = wow.Settings.RegisterCanvasLayoutSubcategory(category, panel, panel.name, panel.name)
        subcategory.ID = panel.name
    else
        wow.InterfaceOptions_AddCategory(panel)
    end
end

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

    if wow.IsRetail() then
        main:SetWidth(wow.SettingsPanel.Container:GetWidth())
        main:SetHeight(wow.SettingsPanel.Container:GetHeight())
    else
        main:SetWidth(wow.InterfaceOptionsFramePanelContainer:GetWidth())
        main:SetHeight(wow.InterfaceOptionsFramePanelContainer:GetHeight())
    end

    panel:SetScrollChild(main)

    AddCategory(panel)

    M.Sorting:Build(main)

    local sortingMethod = M.SortingMethod:Build(panel)
    local keybinding = M.Keybinding:Build(panel)
    local macro = M.Macro:Build(panel)
    local spacing = M.Spacing:Build(panel)
    local integration = M.Integration:Build(panel)
    local health = M.Health:Build(panel)

    AddSubCategory(sortingMethod)
    AddSubCategory(keybinding)
    AddSubCategory(macro)
    AddSubCategory(spacing)
    AddSubCategory(integration)
    AddSubCategory(health)

    SLASH_FRAMESORT1 = "/fs"
    SLASH_FRAMESORT2 = "/framesort"

    wow.SlashCmdList.FRAMESORT = function()
        if wow.IsRetail() then
            wow.Settings.OpenToCategory(panel.name)
        else
            -- workaround the classic bug where the first call opens the Game interface
            -- and a second call is required
            wow.InterfaceOptionsFrame_OpenToCategory(panel)
            wow.InterfaceOptionsFrame_OpenToCategory(panel)
        end
    end
end
