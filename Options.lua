---@diagnostic disable: undefined-global
local addonName, addon = ...
local builder = {}
local verticalSpacing = -16
local horizontalSpacing = 50

-- default configuration
addon.Defaults = {
    PlayerSortMode = "Top",
    RaidSortMode = "Role",
    PartySortMode = "Group",
    RaidSortEnabled = false,
    PartySortEnabled = true
}

addon.SortMode = {
    Group = "Group",
    Role = "Role",
    Alphabetical = "Alphabetical",
    Top = "Top",
    Bottom = "Bottom"
}

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
        local enabled = party:GetChecked()
        addon.Options.PartySortEnabled = enabled
        addon:ConfigChanged(enabled)
    end)

    local raid = CreateFrame("CheckButton", "chkEnableRaidSort", panel, "UICheckButtonTemplate")
    raid:SetPoint("LEFT", party, "RIGHT", 120, 0)
    raid.Text:SetText("Sort Raid Frames?")
    raid:SetChecked(addon.Options.RaidSortEnabled)
    raid:HookScript("OnClick", function(_, _, _)
        local enabled = raid:GetChecked()
        addon.Options.RaidSortEnabled = enabled
        addon:ConfigChanged(enabled)
    end)
end

function builder:BuildPlayerSortMode(panel)
    local label = panel:CreateFontString("lblPlayerSort", "ARTWORK", "GameFontNormal")
    label:SetPoint("TOPLEFT", chkEnablePartySort, "BOTTOMLEFT", 0, verticalSpacing)
    label:SetText("Player sort mode: ")

    -- why use checkboxes instead of a uidropdown?
    -- because the uidropdown has so many taint issues for years that still haven't been fixed
    -- also seems to have become much worse in dragonflight
    -- so while a dropdown would be better ui design, it's too buggy to use
    local top = CreateFrame("CheckButton", "chkPlayerSortModeTop", panel, "UICheckButtonTemplate")
    local bottom = CreateFrame("CheckButton", "chkPlayerSortModeBottom", panel, "UICheckButtonTemplate")

    top:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, verticalSpacing)
    top.Text:SetText(addon.SortMode.Top)
    top:SetChecked(addon.Options.PlayerSortMode == addon.SortMode.Top)
    top:HookScript("OnClick", function(_, _, _)
        if not top:GetChecked() then return end

        addon.Options.PlayerSortMode = addon.SortMode.Top
        bottom:SetChecked(false)
        addon:ConfigChanged()
    end)

    bottom:SetPoint("LEFT", top, "RIGHT", horizontalSpacing, 0)
    bottom.Text:SetText(addon.SortMode.Bottom)
    bottom:SetChecked(addon.Options.PlayerSortMode == addon.SortMode.Bottom)
    bottom:HookScript("OnClick", function(_, _, _)
        if not bottom:GetChecked() then return end

        addon.Options.PlayerSortMode = addon.SortMode.Bottom
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
    group.Text:SetText(addon.SortMode.Group)
    group:SetChecked(addon.Options.PartySortMode == addon.SortMode.Group)
    group:HookScript("OnClick", function(_, _, _)
        if not group:GetChecked() then return end

        addon.Options.PartySortMode = addon.SortMode.Group
        role:SetChecked(false)
        alpha:SetChecked(false)
        addon:ConfigChanged()
    end)

    role:SetPoint("LEFT", group, "RIGHT", horizontalSpacing, 0)
    role.Text:SetText(addon.SortMode.Role)
    role:SetChecked(addon.Options.PartySortMode == addon.SortMode.Role)
    role:HookScript("OnClick", function(_, _, _)
        if not role:GetChecked() then return end

        addon.Options.PartySortMode = addon.SortMode.Role
        group:SetChecked(false)
        alpha:SetChecked(false)
        addon:ConfigChanged()
    end)

    alpha:SetPoint("LEFT", role, "RIGHT", horizontalSpacing, 0)
    alpha.Text:SetText(addon.SortMode.Alphabetical)
    alpha:SetChecked(addon.Options.PartySortMode == addon.SortMode.Alphabetical)
    alpha:HookScript("OnClick", function(_, _, _)
        if not alpha:GetChecked() then return end

        addon.Options.PartySortMode = addon.SortMode.Alphabetical
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
    group.Text:SetText(addon.SortMode.Group)
    group:SetChecked(addon.Options.RaidSortMode == addon.SortMode.Group)
    group:HookScript("OnClick", function(_, _, _)
        if not group:GetChecked() then return end

        addon.Options.RaidSortMode = addon.SortMode.Group
        role:SetChecked(false)
        alpha:SetChecked(false)
        addon:ConfigChanged()
    end)

    role:SetPoint("LEFT", group, "RIGHT", horizontalSpacing, 0)
    role.Text:SetText(addon.SortMode.Role)
    role:SetChecked(addon.Options.RaidSortMode == addon.SortMode.Role)
    role:HookScript("OnClick", function(_, _, _)
        if not role:GetChecked() then return end

        addon.Options.RaidSortMode = addon.SortMode.Role
        group:SetChecked(false)
        alpha:SetChecked(false)
        addon:ConfigChanged()
    end)

    alpha:SetPoint("LEFT", role, "RIGHT", horizontalSpacing, 0)
    alpha.Text:SetText(addon.SortMode.Alphabetical)
    alpha:SetChecked(addon.Options.RaidSortMode == addon.SortMode.Alphabetical)
    alpha:HookScript("OnClick", function(_, _, _)
        if not alpha:GetChecked() then return end

        addon.Options.RaidSortMode = addon.SortMode.Alphabetical
        group:SetChecked(false)
        role:SetChecked(false)
        addon:ConfigChanged()
    end)
end

-- invoked when configuration changes which will then perform a resort
function addon:ConfigChanged(needsResort)
    addon:TrySort(needsResort or true)
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
