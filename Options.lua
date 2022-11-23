---@diagnostic disable: undefined-global
local addonName, addon = ...

local builder = {}
local sortModeGroup = "Group"
local sortModeRole = "Role"
local sortModeAlphabetical = "Alphabetical"
local sortModeTop = "Top"
local sortModeBottom = "Bottom"

function builder:BuiltTitle(panel)
    local title = panel:CreateFontString("lblTitle", "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Frame Sort")

    local description = panel:CreateFontString("lblDescription", "ARTWORK", "GameFontWhite")
    description:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -16)
    description:SetText("Sorts party/raid frames.")
end

function builder.BuildPartySortEnabled(panel)
    local cb = CreateFrame("CheckButton", "chkEnablePartySort", panel, "UICheckButtonTemplate")
    cb:SetPoint("TOPLEFT", lblDescription, "BOTTOMLEFT", 0, -16)
    cb.Text:SetText("Sort Party Frames?")
    cb:SetChecked(addon.Options.PartySortEnabled)
    cb:HookScript("OnClick", function(_, _, _)
        addon.Options.PartySortEnabled = cb:GetChecked()
    end)
end

function builder.BuildRaidSortEnabled(panel)
    local cb = CreateFrame("CheckButton", "chkEnableRaidSort", panel, "UICheckButtonTemplate")
    cb:SetPoint("LEFT", chkEnablePartySort, "RIGHT", 120, 0)
    cb.Text:SetText("Sort Raid Frames?")
    cb:SetChecked(addon.Options.RaidSortEnabled)
    cb:HookScript("OnClick", function(_, _, _)
        addon.Options.RaidSortEnabled = cb:GetChecked()
    end)
end

function builder:BuildPlayerSortMode(panel)
    local label = panel:CreateFontString("lblPartySort", "ARTWORK", "GameFontNormal")
    label:SetPoint("TOPLEFT", chkEnablePartySort, "BOTTOMLEFT", 0, -16)
    label:SetText("Player sort mode: ")

    local dropDown = CreateFrame("FRAME", "ddlPlayerSortMode", panel, "UIDropDownMenuTemplate")
    dropDown:SetPoint("TOPLEFT", label, "BOTTOMLEFT", -18, -16)
    UIDropDownMenu_SetText(dropDown, addon.Options.PlayerSortMode)

    function SetPlayerSortMode(_, sortMode)
        addon.Options.PlayerSortMode = sortMode
        UIDropDownMenu_SetText(dropDown, sortMode)

        addon:ConfigChanged()
    end

    UIDropDownMenu_Initialize(dropDown, function()
        UIDropDownMenu_AddButton({
            text = sortModeTop,
            func = SetPlayerSortMode,
            arg1 = sortModeTop,
            checked = addon.Options.PlayerSortMode == sortModeTop
        })
        UIDropDownMenu_AddButton({
            text = sortModeBottom,
            func = SetPlayerSortMode,
            arg1 = sortModeBottom,
            checked = addon.Options.PlayerSortMode == sortModeBottom
        })
    end)
end

function builder:BuildPartySortMode(panel)
    local label = panel:CreateFontString("lblPartySort", "ARTWORK", "GameFontNormal")
    label:SetPoint("TOPLEFT", ddlPlayerSortMode, "BOTTOMLEFT", 18, -16)
    label:SetText("Party sort mode: ")

    local dropDown = CreateFrame("FRAME", "ddlPartySortMode", panel, "UIDropDownMenuTemplate")
    dropDown:SetPoint("TOPLEFT", label, "BOTTOMLEFT", -18, -16)
    UIDropDownMenu_SetText(dropDown, addon.Options.PartySortMode)

    function SetPartySortMode(_, sortMode)
        addon.Options.PartySortMode = sortMode
        UIDropDownMenu_SetText(dropDown, sortMode)

        addon:ConfigChanged()
    end

    UIDropDownMenu_Initialize(dropDown, function()
        UIDropDownMenu_AddButton({
            text = sortModeGroup,
            func = SetPartySortMode,
            arg1 = sortModeGroup,
            checked = addon.Options.PartySortMode == sortModeGroup
        })
        UIDropDownMenu_AddButton({
            text = sortModeRole,
            func = SetPartySortMode,
            arg1 = sortModeRole,
            checked = addon.Options.PartySortMode == sortModeRole
        })
        UIDropDownMenu_AddButton({
            text = sortModeAlphabetical,
            func = SetPartySortMode,
            arg1 = sortModeAlphabetical,
            checked = addon.Options.PartySortMode == sortModeAlphabetical
        })
    end)
end

function builder:BuildRaidSortMode(panel)
    local label = panel:CreateFontString("lblRaidSort", "ARTWORK", "GameFontNormal")
    label:SetPoint("TOPLEFT", ddlPartySortMode, "BOTTOMLEFT", 18, -16)
    label:SetText("Raid sort mode: ")

    local dropDown = CreateFrame("FRAME", "ddlRaidSortMode", panel, "UIDropDownMenuTemplate")
    dropDown:SetPoint("TOPLEFT", label, "BOTTOMLEFT", -18, -16)
    UIDropDownMenu_SetText(dropDown, addon.Options.RaidSortMode)

    function SetRaidSortMode(_, sortMode)
        addon.Options.RaidSortMode = sortMode
        UIDropDownMenu_SetText(dropDown, sortMode)

        addon:ConfigChanged()
    end

    UIDropDownMenu_Initialize(dropDown, function()
        UIDropDownMenu_AddButton({
            text = sortModeGroup,
            func = SetRaidSortMode,
            arg1 = sortModeGroup,
            checked = addon.Options.RaidSortMode == sortModeGroup
        })
        UIDropDownMenu_AddButton({
            text = sortModeRole,
            func = SetRaidSortMode,
            arg1 = sortModeRole,
            checked = addon.Options.RaidSortMode == sortModeRole
        })
        UIDropDownMenu_AddButton({
            text = sortModeAlphabetical,
            func = SetRaidSortMode,
            arg1 = sortModeAlphabetical,
            checked = addon.Options.RaidSortMode == sortModeAlphabetical
        })
    end)
end

function addon:InitOptions()
    local panel = CreateFrame("Frame")
    panel.name = addonName

    builder:BuiltTitle(panel)
    builder.BuildPartySortEnabled(panel)
    builder.BuildRaidSortEnabled(panel)
    builder:BuildPlayerSortMode(panel)
    builder:BuildPartySortMode(panel)
    builder:BuildRaidSortMode(panel)

    InterfaceOptions_AddCategory(panel)

    SLASH_FRAMESORT1 = "/fs"
    SLASH_FRAMESORT2 = "/framesort"

    SlashCmdList.FRAMESORT = function()
        InterfaceOptionsFrame_OpenToCategory(addonName)
    end
end
