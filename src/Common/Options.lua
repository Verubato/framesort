local addonName, addon = ...
addon.OptionsBuilder = {}
local builder = addon.OptionsBuilder
local verticalSpacing = -16
local horizontalSpacing = 50

---Default configuration.
addon.Defaults = {
    Version = 3,
    DebugEnabled = false,
    ArenaEnabled = true,
    ArenaPlayerSortMode = addon.SortMode.Top,
    ArenaSortMode = addon.SortMode.Group,
    DungeonEnabled = true,
    DungeonPlayerSortMode = addon.SortMode.Top,
    DungeonSortMode = addon.SortMode.Role,
    WorldEnabled = true,
    WorldPlayerSortMode = addon.SortMode.Top,
    WorldSortMode = addon.SortMode.Group,
    RaidEnabled = false,
    RaidPlayerSortMode = addon.SortMode.Top,
    RaidSortMode = addon.SortMode.Role,
    ExperimentalEnabled = false
}

---Adds the title UI components.
---@param panel table the parent UI panel.
---@return table The bottom left most control to use for anchoring subsequent UI components.
function builder:BuiltTitle(panel)
    local title = panel:CreateFontString("lblTitle", "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", -verticalSpacing, verticalSpacing)
    title:SetText("Frame Sort")

    local lines = {
        Group = "party1 > party2 > partyN > partyN+1",
        Role  = "tank > healer > dps",
        Alpha = "NameA > NameB > NameZ"
    }

    local anchor = title
    local keyWidth = 50
    for k, v in pairs(lines) do
        local keyText = panel:CreateFontString("lblDescriptionKey" .. tostring(i), "ARTWORK", "GameFontWhite")
        keyText:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, verticalSpacing)
        keyText:SetText(k .. ": ")
        keyText:SetWidth(keyWidth)
        keyText:SetJustifyH("LEFT")
        anchor = keyText

        local valueText = panel:CreateFontString("lblDescriptionValue" .. tostring(i), "ARTWORK", "GameFontWhite")
        valueText:SetPoint("LEFT", keyText, "RIGHT")
        valueText:SetText(v)
    end

    return anchor
end

---Adds a row of the player and group sort mode checkboxes.
---@param parentPanel table the parent UI panel.
---@param pointOffset table a UI component used as a relative position anchor for the new components.
---@param labelText string the text to display on the enabled checkbox.
---@param uniqueGroupName string a unique string used for the component names.
---@param sortingEnabled boolean whether sorting is currently enabled.
---@param playerSortMode string current player sort mode.
---@param sortMode string current group sort mode.
---@param onEnabledChanged function function(enabled) callback function when enabled changes.
---@param onPlayerSortModeChanged function function(mode) callback function when the player sort mode changes.
---@param onSortModeChanged function function(mode) callback function when the group sort mode changes.
---@return table The bottom left most control to use for anchoring subsequent UI components.
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

    local middle = CreateFrame("CheckButton", "chk" .. uniqueGroupName .. "PlayerSortMiddle", parentPanel, "UICheckButtonTemplate")
    middle.Text:SetText("Middle")
    middle:SetPoint("LEFT", top, "RIGHT", horizontalSpacing, 0)
    middle:SetChecked(playerSortMode == addon.SortMode.Middle)

    local bottom = CreateFrame("CheckButton", "chk" .. uniqueGroupName .. "PlayerSortBottom", parentPanel, "UICheckButtonTemplate")
    bottom.Text:SetText("Bottom")
    bottom:SetPoint("LEFT", middle, "RIGHT", horizontalSpacing, 0)
    bottom:SetChecked(playerSortMode == addon.SortMode.Bottom)

    local playerModes = {
        [top] = addon.SortMode.Top,
        [middle] = addon.SortMode.Middle,
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

    local alpha = CreateFrame("CheckButton", "chk" .. uniqueGroupName .. "SortAlpha", parentPanel,
        "UICheckButtonTemplate")
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

    return modeLabel
end

---Upgrades saved options to the current version.
function addon:UpgradeOptions()
    if addon.Options.Version == nil then
        addon:Debug("Upgrading options.")

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

    addon.Options.ExperimentalEnabled = addon.Options.ExperimentalEnabled or false
end

---Sets the specified option and re-sorts the party/raid frames if applicable.
function addon:SetOption(name, value)
    addon:Debug("Setting option - '" .. name .. "' = '" .. tostring(value) .. "'")
    addon.Options[name] = value

    if name ~= "DebugEnabled" then
        addon:TrySort()
    end
end

---Adds the options interface to the wow addons section and enables slash commands.
function addon:InitOptions()
    addon:UpgradeOptions()

    local panel = CreateFrame("Frame")
    panel.name = addonName

    local anchor = builder:BuiltTitle(panel)
    anchor = builder:BuildSortModeCheckboxes(
        panel,
        anchor,
        "Arena",
        "Arena",
        addon.Options.ArenaEnabled,
        addon.Options.ArenaPlayerSortMode,
        addon.Options.ArenaSortMode,
        function(enabled) addon:SetOption("ArenaEnabled", enabled) end,
        function(mode) addon:SetOption("ArenaPlayerSortMode", mode) end,
        function(mode) addon:SetOption("ArenaSortMode", mode) end
    )

    anchor = builder:BuildSortModeCheckboxes(
        panel,
        anchor,
        "Dungeon (mythics, 5-mans)",
        "Dungeon",
        addon.Options.DungeonEnabled,
        addon.Options.DungeonPlayerSortMode,
        addon.Options.DungeonSortMode,
        function(enabled) addon:SetOption("DungeonEnabled", enabled) end,
        function(mode) addon:SetOption("DungeonPlayerSortMode", mode) end,
        function(mode) addon:SetOption("DungeonSortMode", mode) end
    )

    anchor = builder:BuildSortModeCheckboxes(
        panel,
        anchor,
        "Raid (battlegrounds, raids)",
        "Raid",
        addon.Options.RaidEnabled,
        addon.Options.RaidPlayerSortMode,
        addon.Options.RaidSortMode,
        function(enabled) addon:SetOption("RaidEnabled", enabled) end,
        function(mode) addon:SetOption("RaidPlayerSortMode", mode) end,
        function(mode) addon:SetOption("RaidSortMode", mode) end
    )

    anchor = builder:BuildSortModeCheckboxes(
        panel,
        anchor,
        "World (non-instance groups)",
        "World",
        addon.Options.WorldEnabled,
        addon.Options.WorldPlayerSortMode,
        addon.Options.WorldSortMode,
        function(enabled) addon:SetOption("WorldEnabled", enabled) end,
        function(mode) addon:SetOption("WorldPlayerSortMode", mode) end,
        function(mode) addon:SetOption("WorldSortMode", mode) end
    )

    InterfaceOptions_AddCategory(panel)

    builder:BuildHealthCheck(panel)
    builder:BuildExperimentalOptions(panel)
    builder:BuildDebugOptions(panel)

    SLASH_FRAMESORT1 = "/fs"
    SLASH_FRAMESORT2 = "/framesort"

    SlashCmdList.FRAMESORT = function()
        InterfaceOptionsFrame_OpenToCategory(addonName)

        -- workaround the classic bug where the first call opens the Game interface
        -- and a second call is required
        if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            InterfaceOptionsFrame_OpenToCategory(addonName)
        end
    end
end
