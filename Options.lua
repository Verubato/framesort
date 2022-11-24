---@diagnostic disable: undefined-global
local addonName, addon = ...

local builder = {}
local sortModeGroup = "Group"
local sortModeRole = "Role"
local sortModeAlphabetical = "Alphabetical"
local sortModeTop = "Top"
local sortModeBottom = "Bottom"
local verticalSpacing = -16
local horizontalSpacing = 50

function builder:BuiltTitle(panel)
    local title = panel:CreateFontString("lblTitle", "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, verticalSpacing)
    title:SetText("Frame Sort")

    local description = panel:CreateFontString("lblDescription", "ARTWORK", "GameFontWhite")
    description:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, verticalSpacing)
    description:SetText("Sorts party/raid frames.")

    local note = panel:CreateFontString("lblNote", "ARTWORK", "GameFontWhite")
    note:SetPoint("TOPLEFT", description, "BOTTOMLEFT", 0, verticalSpacing)
    note:SetText("Note: the weird usage of checkboxes here instead of dropdowns are to help avoiding taint issues.")
end

function builder.BuildSortEnabled(panel)
    local party = CreateFrame("CheckButton", "chkEnablePartySort", panel, "UICheckButtonTemplate")
    party:SetPoint("TOPLEFT", lblNote, "BOTTOMLEFT", 0, verticalSpacing)
    party.Text:SetText("Sort Party Frames?")
    party:SetChecked(addon.Options.PartySortEnabled)
    party:HookScript("OnClick", function(_, _, _)
        addon.Options.PartySortEnabled = party:GetChecked()
    end)

    local raid = CreateFrame("CheckButton", "chkEnableRaidSort", panel, "UICheckButtonTemplate")
    raid:SetPoint("LEFT", party, "RIGHT", 120, 0)
    raid.Text:SetText("Sort Raid Frames?")
    raid:SetChecked(addon.Options.RaidSortEnabled)
    raid:HookScript("OnClick", function(_, _, _)
        addon.Options.RaidSortEnabled = raid:GetChecked()
    end)
end

function builder:BuildPlayerSortMode(panel)
    local label = panel:CreateFontString("lblPlayerSort", "ARTWORK", "GameFontNormal")
    label:SetPoint("TOPLEFT", chkEnablePartySort, "BOTTOMLEFT", 0, verticalSpacing)
    label:SetText("Player sort mode: ")

    -- why use checkboxes instead of a uidropdown?
    -- because the uidropdown has so many taint issues for years that still haven't been fixed
    -- and seem to have become much worse in dragonflight
    -- so while a dropdown would be better ui design, it's too buggy to use
    local top = CreateFrame("CheckButton", "chkPlayerSortModeTop", panel, "UICheckButtonTemplate")
    local bottom = CreateFrame("CheckButton", "chkPlayerSortModeBottom", panel, "UICheckButtonTemplate")

    top:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, verticalSpacing)
    top.Text:SetText(sortModeTop)
    top:SetChecked(addon.Options.PlayerSortMode == sortModeTop)
    top:HookScript("OnClick", function(_, _, _)
        if not top:GetChecked() then return end

        addon.Options.PlayerSortMode = sortModeTop
        bottom:SetChecked(false)
        addon:ConfigChanged()
    end)

    bottom:SetPoint("LEFT", top, "RIGHT", horizontalSpacing, 0)
    bottom.Text:SetText(sortModeBottom)
    bottom:SetChecked(addon.Options.PlayerSortMode == sortModeBottom)
    bottom:HookScript("OnClick", function(_, _, _)
        if not bottom:GetChecked() then return end

        addon.Options.PlayerSortMode = sortModeBottom
        top:SetChecked(false)
        addon:ConfigChanged()
    end)
end

function builder:BuildPartySortMode(panel)
    local label = panel:CreateFontString("lblPartySort", "ARTWORK", "GameFontNormal")
    label:SetPoint("TOPLEFT", chkPlayerSortModeTop, "BOTTOMLEFT", 0, verticalSpacing)
    label:SetText("Party sort mode: ")

    local group = CreateFrame("CheckButton", "chkPartySortModeGroup", panel, "UICheckButtonTemplate")
    local role = CreateFrame("CheckButton", "chkPartySortModeRole", panel, "UICheckButtonTemplate")
    local alpha = CreateFrame("CheckButton", "chkPartySortModeAlpha", panel, "UICheckButtonTemplate")

    group:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, verticalSpacing)
    group.Text:SetText(sortModeGroup)
    group:SetChecked(addon.Options.PartySortMode == sortModeGroup)
    group:HookScript("OnClick", function(_, _, _)
        if not group:GetChecked() then return end

        addon.Options.PartySortMode = sortModeGroup
        role:SetChecked(false)
        alpha:SetChecked(false)
        addon:ConfigChanged()
    end)

    role:SetPoint("LEFT", group, "RIGHT", horizontalSpacing, 0)
    role.Text:SetText(sortModeRole)
    role:SetChecked(addon.Options.PartySortMode == sortModeRole)
    role:HookScript("OnClick", function(_, _, _)
        if not role:GetChecked() then return end

        addon.Options.PartySortMode = sortModeRole
        group:SetChecked(false)
        alpha:SetChecked(false)
        addon:ConfigChanged()
    end)

    alpha:SetPoint("LEFT", role, "RIGHT", horizontalSpacing, 0)
    alpha.Text:SetText(sortModeAlphabetical)
    alpha:SetChecked(addon.Options.PartySortMode == sortModeAlphabetical)
    alpha:HookScript("OnClick", function(_, _, _)
        if not alpha:GetChecked() then return end

        addon.Options.PartySortMode = sortModeAlphabetical
        group:SetChecked(false)
        role:SetChecked(false)
        addon:ConfigChanged()
    end)
end

function builder:BuildRaidSortMode(panel)
    local label = panel:CreateFontString("lblRaidSort", "ARTWORK", "GameFontNormal")
    label:SetPoint("TOPLEFT", chkPartySortModeGroup, "BOTTOMLEFT", 0, verticalSpacing)
    label:SetText("Raid sort mode: ")

    local group = CreateFrame("CheckButton", "chkRaidSortModeGroup", panel, "UICheckButtonTemplate")
    local role = CreateFrame("CheckButton", "chkRaidSortModeRole", panel, "UICheckButtonTemplate")
    local alpha = CreateFrame("CheckButton", "chkRaidSortModeAlpha", panel, "UICheckButtonTemplate")

    group:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, verticalSpacing)
    group.Text:SetText(sortModeGroup)
    group:SetChecked(addon.Options.RaidSortMode == sortModeGroup)
    group:HookScript("OnClick", function(_, _, _)
        if not group:GetChecked() then return end

        addon.Options.RaidSortMode = sortModeGroup
        role:SetChecked(false)
        alpha:SetChecked(false)
        addon:ConfigChanged()
    end)

    role:SetPoint("LEFT", group, "RIGHT", horizontalSpacing, 0)
    role.Text:SetText(sortModeRole)
    role:SetChecked(addon.Options.RaidSortMode == sortModeRole)
    role:HookScript("OnClick", function(_, _, _)
        if not role:GetChecked() then return end

        addon.Options.RaidSortMode = sortModeRole
        group:SetChecked(false)
        alpha:SetChecked(false)
        addon:ConfigChanged()
    end)

    alpha:SetPoint("LEFT", role, "RIGHT", horizontalSpacing, 0)
    alpha.Text:SetText(sortModeAlphabetical)
    alpha:SetChecked(addon.Options.RaidSortMode == sortModeAlphabetical)
    alpha:HookScript("OnClick", function(_, _, _)
        if not alpha:GetChecked() then return end

        addon.Options.RaidSortMode = sortModeAlphabetical
        group:SetChecked(false)
        role:SetChecked(false)
        addon:ConfigChanged()
    end)
end

-- invoked when configuration changes which will then perform a resort
function addon:ConfigChanged()
    addon.NeedsSort = true
    addon:TrySort()
end

function addon:InitOptions()
    local panel = CreateFrame("Frame")
    panel.name = addonName

    builder:BuiltTitle(panel)
    builder.BuildSortEnabled(panel)
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

