---@type string, Addon
local _, addon = ...
local fsConfig = addon.Configuration
local wow = addon.WoW.Api

fsConfig.VerticalSpacing = 13
fsConfig.HorizontalSpacing = 50

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

function fsConfig:TextShim(frame)
    if not frame.Text and frame.text then
        frame.Text = frame.text
    end
end

function fsConfig:Init()
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

    fsConfig.Sorting:Build(main)

    local sortingMethod = fsConfig.SortingMethod:Build(panel)
    local keybinding = fsConfig.Keybinding:Build(panel)
    local macro = fsConfig.Macro:Build(panel)
    local spacing = fsConfig.Spacing:Build(panel)
    local integration = fsConfig.Integration:Build(panel)
    local health = fsConfig.Health:Build(panel)

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
