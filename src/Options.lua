---@diagnostic disable: undefined-global
local addonName, addon = ...
local builder = {}
local verticalSpacing = -16
local horizontalSpacing = 50

addon.SortMode = {
    Group = "Group",
    Role = "Role",
    Alphabetical = "Alphabetical",
    Top = "Top",
    Bottom = "Bottom"
}

-- default configuration
addon.Defaults = {
    Version = 2,

    ArenaEnabled = true,
    ArenaPlayerSortMode = addon.SortMode.Top,
    ArenaSortMode = addon.SortMode.Group,

    DungeonEnabled = true,
    DungeonPlayerSortMode = addon.SortMode.Top,
    DungeonSortMode = addon.SortMode.Role,

    WorldEnabled = true,
    WorldPlayerSortMode = addon.SortMode.Top,
    WorldSortMode = addon.SortMode.Role,

    RaidEnabled = false,
    RaidPlayerSortMode = addon.SortMode.Top,
    RaidSortMode = addon.SortMode.Role
}

function builder:BuiltTitle(panel)
    local title = panel:CreateFontString("lblTitle", "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", verticalSpacing * -1, verticalSpacing)
    title:SetText("Frame Sort")

    local description = panel:CreateFontString("lblDescription", "ARTWORK", "GameFontWhite")
    description:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, verticalSpacing)
    description:SetText("Sorts party/raid frames.")
end

function builder:BuildSortModeCheckboxes(
    parentPanel,
    pointOffset,
    labelText,
    uniqueGroupName,
    sortingEnabled,
    playerSortMode,
    sortMode,
    onEnabledChanged,
    onPlayerSortModeChanged,
    onSortModeChanged)
    local enabled = CreateFrame("CheckButton", "chk" .. uniqueGroupName .. "Enabled", parentPanel, "UICheckButtonTemplate")
    -- not sure why, but checkbox left seems to be off by about 4 units by default
    enabled:SetPoint("TOPLEFT", pointOffset, "BOTTOMLEFT", -4, verticalSpacing)
    enabled.Text:SetText(" " .. labelText)
    enabled.Text:SetFontObject("GameFontNormalLarge")
    enabled:SetChecked(sortingEnabled)
    enabled:HookScript("OnClick", function() onEnabledChanged(enabled:GetChecked()) end)

    local playerLabel = parentPanel:CreateFontString("lbl" .. uniqueGroupName .. "PlayerSortMode", "ARTWORK", "GameFontNormal")
    playerLabel:SetPoint("TOPLEFT", enabled, "BOTTOMLEFT", 4, verticalSpacing)
    playerLabel:SetText("Player: ")

    local top = CreateFrame("CheckButton", "chk" .. uniqueGroupName .. "PlayerSortTop", parentPanel, "UICheckButtonTemplate")
    top.Text:SetText("Top")
    top:SetPoint("LEFT", playerLabel, "RIGHT", horizontalSpacing / 2, 0)
    top:SetChecked(playerSortMode == addon.SortMode.Top)

    local bottom = CreateFrame("CheckButton", "chk" .. uniqueGroupName .. "PlayerSortBottom", parentPanel, "UICheckButtonTemplate")
    bottom.Text:SetText("Bottom")
    bottom:SetPoint("LEFT", top, "RIGHT", horizontalSpacing, 0)
    bottom:SetChecked(playerSortMode == addon.SortMode.Bottom)

    local playerModes = {
        [top] = addon.SortMode.Top,
        [bottom] = addon.SortMode.Bottom
    }

    local function onPlayerClick(sender)
        -- uncheck the others
        for chkbox, _ in pairs(playerModes) do
            if chkbox ~= sender then chkbox:SetChecked(false) end
        end

        -- at least 1 must be checked
        if not sender:GetChecked() then
            sender:SetChecked(true)
        end

        local mode = playerModes[sender]
        onPlayerSortModeChanged(mode)
    end

    for chkbox, _ in pairs(playerModes) do
        chkbox:HookScript("OnClick", onPlayerClick)
    end

    local modeLabel = parentPanel:CreateFontString("lbl" .. uniqueGroupName .. "SortMode", "ARTWORK", "GameFontNormal")
    modeLabel:SetPoint("TOPLEFT", playerLabel, "BOTTOMLEFT", 0, verticalSpacing * 1.5)
    modeLabel:SetText("Sort: ")

    -- why use checkboxes instead of a dropdown box?
    -- because the dropdown box control has taint issues that haven't been fixed for years
    -- also it seems to have become much worse in dragonflight
    -- so while a dropdown would be better ui design, it's too buggy to use at the moment
    local group = CreateFrame("CheckButton", "chk" .. uniqueGroupName .. "SortGroup", parentPanel, "UICheckButtonTemplate")
    group:SetPoint("LEFT", top, "LEFT")
    -- TODO: not sure why this doesn't align well even when aligning TOP/BOTTOM, so just hacking in a +10 to fix it for now
    group:SetPoint("TOP", modeLabel, "TOP", 0, 10)
    group.Text:SetText(addon.SortMode.Group)
    group:SetChecked(sortMode == addon.SortMode.Group)

    local role = CreateFrame("CheckButton", "chk" .. uniqueGroupName .. "SortRole", parentPanel, "UICheckButtonTemplate")
    role:SetPoint("LEFT", group, "RIGHT", horizontalSpacing, 0)
    role.Text:SetText(addon.SortMode.Role)
    role:SetChecked(sortMode == addon.SortMode.Role)

    local alpha = CreateFrame("CheckButton", "chk" .. uniqueGroupName .. "SortAlpha", parentPanel, "UICheckButtonTemplate")
    alpha:SetPoint("LEFT", role, "RIGHT", horizontalSpacing, 0)
    alpha.Text:SetText(addon.SortMode.Alphabetical)
    alpha:SetChecked(sortMode == addon.SortMode.Alphabetical)

    local modes = {
        [group] = addon.SortMode.Group,
        [role] = addon.SortMode.Role,
        [alpha] = addon.SortMode.Alphabetical
    }

    local function onModeClick(sender)
        -- uncheck the others
        for chkbox, _ in pairs(modes) do
            if chkbox ~= sender then chkbox:SetChecked(false) end
        end

        -- at least 1 must be checked
        if not sender:GetChecked() then
            sender:SetChecked(true)
        end

        local mode = modes[sender]
        onSortModeChanged(mode)
    end

    for chkbox, _ in pairs(modes) do
        chkbox:HookScript("OnClick", onModeClick)
    end
end

function addon:UpgradeOptions()
    if addon.Options.Version == nil then
        addon.Options.Version = addon.Defaults.Version

        addon.Options.ArenaEnabled = addon.Options.PartySortEnabled
        addon.Options.ArenaPlayerSortMode = addon.Options.PlayerSortMode
        addon.Options.ArenaSortMode = addon.Options.PartySortMode

        addon.Options.DungeonEnabled = addon.Options.PartySortEnabled
        addon.Options.DungeonPlayerSortMode = addon.Options.PlayerSortMode
        addon.Options.DungeonSortMode = addon.Options.PartySortMode

        addon.Options.WorldEnabled = addon.Options.PartySortEnabled
        addon.Options.WorldPlayerSortMode = addon.Options.PlayerSortMode
        addon.Options.WorldSortMode = addon.Options.PartySortMode

        addon.Options.RaidEnabled = addon.Options.RaidSortEnabled
        addon.Options.RaidPlayerSortMode = addon.Options.PlayerSortMode

        -- remove old values
        addon.Options.PartySortEnabled = nil
        addon.Options.PlayerSortMode = nil
        addon.Options.RaidSortEnabled = nil
    end
end

function addon:InitOptions()
    addon:UpgradeOptions()

    local panel = CreateFrame("Frame")
    panel.name = addonName

    local function setOption(name, value)
        addon.Options[name] = value
        addon:TrySort()
    end

    builder:BuiltTitle(panel)
    builder:BuildSortModeCheckboxes(
        panel,
        lblDescription,
        "Arena",
        "Arena",
        addon.Options.ArenaEnabled,
        addon.Options.ArenaPlayerSortMode,
        addon.Options.ArenaSortMode,
        function(enabled) setOption("ArenaEnabled", enabled) end,
        function(mode) setOption("ArenaPlayerSortMode", mode) end,
        function(mode) setOption("ArenaSortMode", mode) end
    )

    builder:BuildSortModeCheckboxes(
        panel,
        lblArenaSortMode,
        "Dungeon (mythics, 5-mans)",
        "Dungeon",
        addon.Options.DungeonEnabled,
        addon.Options.DungeonPlayerSortMode,
        addon.Options.DungeonSortMode,
        function(enabled) setOption("DungeonEnabled", enabled) end,
        function(mode) setOption("DungeonPlayerSortMode", mode) end,
        function(mode) setOption("DungeonSortMode", mode) end
    )

    builder:BuildSortModeCheckboxes(
        panel,
        lblDungeonSortMode,
        "Raid (battlegrounds, raids)",
        "Raid",
        addon.Options.RaidEnabled,
        addon.Options.RaidPlayerSortMode,
        addon.Options.RaidSortMode,
        function(enabled) setOption("RaidEnabled", enabled) end,
        function(mode) setOption("RaidPlayerSortMode", mode) end,
        function(mode) setOption("RaidSortMode", mode) end
    )

    builder:BuildSortModeCheckboxes(
        panel,
        lblRaidSortMode,
        "World (non-instance groups)",
        "World",
        addon.Options.WorldEnabled,
        addon.Options.WorldPlayerSortMode,
        addon.Options.WorldSortMode,
        function(enabled) setOption("WorldEnabled", enabled) end,
        function(mode) setOption("WorldPlayerSortMode", mode) end,
        function(mode) setOption("WorldSortMode", mode) end
    )

    InterfaceOptions_AddCategory(panel)

    SLASH_FRAMESORT1 = "/fs"
    SLASH_FRAMESORT2 = "/framesort"

    SlashCmdList.FRAMESORT = function()
        InterfaceOptionsFrame_OpenToCategory(addonName)
    end
end
