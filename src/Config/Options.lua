local _, addon = ...
addon.OptionsBuilder = {
    VerticalSpacing = 15,
    HorizontalSpacing = 50
}

local builder = addon.OptionsBuilder
local verticalSpacing = addon.OptionsBuilder.VerticalSpacing
local horizontalSpacing = addon.OptionsBuilder.HorizontalSpacing

---Adds the title UI components.
---@param panel table the parent UI panel.
---@return table The bottom left most control to use for anchoring subsequent UI components.
local function BuiltTitle(panel)
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", verticalSpacing, -verticalSpacing)
    title:SetText("Frame Sort")

    local lines = {
        Group = "party1 > party2 > partyN > partyN+1",
        Role  = "tank > healer > dps",
        Alpha = "NameA > NameB > NameZ"
    }

    local anchor = title
    local keyWidth = 50
    local i = 1
    for k, v in pairs(lines) do
        local keyText = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
        keyText:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -verticalSpacing * 0.75)
        keyText:SetText(k .. ": ")
        keyText:SetWidth(keyWidth)
        keyText:SetJustifyH("LEFT")
        anchor = keyText

        local valueText = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
        valueText:SetPoint("LEFT", keyText, "RIGHT")
        valueText:SetText(v)
        i = i + 1
    end

    return anchor
end

---Adds a row of the player and group sort mode checkboxes.
---@param parentPanel table the parent UI panel.
---@param pointOffset table a UI component used as a relative position anchor for the new components.
---@param labelText string the text to display on the enabled checkbox.
---@param sortingEnabled boolean whether sorting is currently enabled.
---@param playerSortMode string current player sort mode.
---@param sortMode string current group sort mode.
---@param onEnabledChanged function function(enabled) callback function when enabled changes.
---@param onPlayerSortModeChanged function function(mode) callback function when the player sort mode changes.
---@param onSortModeChanged function function(mode) callback function when the group sort mode changes.
---@return table The bottom left most control to use for anchoring subsequent UI components.
local function BuildSortModeCheckboxes(
    parentPanel,
    pointOffset,
    labelText,
    sortingEnabled,
    playerSortMode,
    sortMode,
    onEnabledChanged,
    onPlayerSortModeChanged,
    onSortModeChanged)
    local enabled = CreateFrame("CheckButton", nil, parentPanel, "UICheckButtonTemplate")
    -- not sure why, but checkbox left seems to be off by about 4 units by default
    enabled:SetPoint("TOPLEFT", pointOffset, "BOTTOMLEFT", -4, -verticalSpacing)
    enabled.Text:SetText(" " .. labelText)
    enabled.Text:SetFontObject("GameFontNormalLarge")
    enabled:SetChecked(sortingEnabled)
    enabled:HookScript("OnClick", function() onEnabledChanged(enabled:GetChecked()) end)

    local playerLabel = parentPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    playerLabel:SetPoint("TOPLEFT", enabled, "BOTTOMLEFT", 4, -verticalSpacing)
    playerLabel:SetText("Player: ")

    local top = CreateFrame("CheckButton", nil, parentPanel, "UICheckButtonTemplate")
    top.Text:SetText("Top")
    top:SetPoint("LEFT", playerLabel, "RIGHT", horizontalSpacing / 2, 0)
    top:SetChecked(playerSortMode == addon.PlayerSortMode.Top)

    local middle = CreateFrame("CheckButton", nil, parentPanel, "UICheckButtonTemplate")
    middle.Text:SetText("Middle")
    middle:SetPoint("LEFT", top, "RIGHT", horizontalSpacing, 0)
    middle:SetChecked(playerSortMode == addon.PlayerSortMode.Middle)

    local bottom = CreateFrame("CheckButton", nil, parentPanel, "UICheckButtonTemplate")
    bottom.Text:SetText("Bottom")
    bottom:SetPoint("LEFT", middle, "RIGHT", horizontalSpacing, 0)
    bottom:SetChecked(playerSortMode == addon.PlayerSortMode.Bottom)

    local playerModes = {
        [top] = addon.PlayerSortMode.Top,
        [middle] = addon.PlayerSortMode.Middle,
        [bottom] = addon.PlayerSortMode.Bottom
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
        addon:TrySort()
    end

    for chkbox, _ in pairs(playerModes) do
        chkbox:HookScript("OnClick", onPlayerClick)
    end

    local modeLabel = parentPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    modeLabel:SetPoint("TOPLEFT", playerLabel, "BOTTOMLEFT", 0, -verticalSpacing * 1.5)
    modeLabel:SetText("Sort: ")

    -- why use checkboxes instead of a dropdown box?
    -- because the dropdown box control has taint issues that haven't been fixed for years
    -- also it seems to have become much worse in dragonflight
    -- so while a dropdown would be better ui design, it's too buggy to use at the moment
    local group = CreateFrame("CheckButton", nil, parentPanel, "UICheckButtonTemplate")
    group:SetPoint("LEFT", top, "LEFT")
    -- TODO: not sure why this doesn't align well even when aligning TOP/BOTTOM, so just hacking in a +10 to fix it for now
    group:SetPoint("TOP", modeLabel, "TOP", 0, 10)
    group.Text:SetText(addon.GroupSortMode.Group)
    group:SetChecked(sortMode == addon.GroupSortMode.Group)

    local role = CreateFrame("CheckButton", nil, parentPanel, "UICheckButtonTemplate")
    role:SetPoint("LEFT", group, "RIGHT", horizontalSpacing, 0)
    role.Text:SetText(addon.GroupSortMode.Role)
    role:SetChecked(sortMode == addon.GroupSortMode.Role)

    local alpha = CreateFrame("CheckButton", nil, parentPanel, "UICheckButtonTemplate")
    alpha:SetPoint("LEFT", role, "RIGHT", horizontalSpacing, 0)
    alpha.Text:SetText(addon.GroupSortMode.Alphabetical)
    alpha:SetChecked(sortMode == addon.GroupSortMode.Alphabetical)

    local modes = {
        [group] = addon.GroupSortMode.Group,
        [role] = addon.GroupSortMode.Role,
        [alpha] = addon.GroupSortMode.Alphabetical
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
        addon:TrySort()
    end

    for chkbox, _ in pairs(modes) do
        chkbox:HookScript("OnClick", onModeClick)
    end

    return modeLabel
end

---Initialises the addon options.
function addon:InitOptions()
    -- eventually the idea is to delete the "Options" variable
    -- I didn't realise this is a global variable when first made the addon
    -- "Options" is too generic and maybe could cause conflicts?
    -- so now moving to the "Addon Name" + DB convention
    if not Options and not FrameSortDB then
        FrameSortDB = {
            Options = CopyTable(addon.Defaults)
        }
    elseif Options and not FrameSortDB then
        FrameSortDB = {
            Options = CopyTable(Options)
        }

        Options = nil
    end

    addon.Options = FrameSortDB.Options
    addon:UpgradeOptions()

    local panel = CreateFrame("Frame")
    panel.name = "Frame Sort"

    local anchor = BuiltTitle(panel)
    anchor = BuildSortModeCheckboxes(
        panel,
        anchor,
        "Arena",
        addon.Options.Arena.Enabled,
        addon.Options.Arena.PlayerSortMode,
        addon.Options.Arena.GroupSortMode,
        function(enabled) addon.Options.Arena.Enabled = enabled end,
        function(mode) addon.Options.Arena.PlayerSortMode = mode end,
        function(mode) addon.Options.Arena.GroupSortMode = mode end
    )

    anchor = BuildSortModeCheckboxes(
        panel,
        anchor,
        "Dungeon (mythics, 5-mans)",
        addon.Options.Dungeon.Enabled,
        addon.Options.Dungeon.PlayerSortMode,
        addon.Options.Dungeon.GroupSortMode,
        function(enabled) addon.Options.Dungeon.Enabled = enabled end,
        function(mode) addon.Options.Dungeon.PlayerSortMode = mode end,
        function(mode) addon.Options.Dungeon.GroupSortMode = mode end
    )

    anchor = BuildSortModeCheckboxes(
        panel,
        anchor,
        "Raid (battlegrounds, raids)",
        addon.Options.Raid.Enabled,
        addon.Options.Raid.PlayerSortMode,
        addon.Options.Raid.GroupSortMode,
        function(enabled) addon.Options.Raid.Enabled = enabled end,
        function(mode) addon.Options.Raid.PlayerSortMode = mode end,
        function(mode) addon.Options.Raid.GroupSortMode = mode end
    )

    anchor = BuildSortModeCheckboxes(
        panel,
        anchor,
        "World (non-instance groups)",
        addon.Options.World.Enabled,
        addon.Options.World.PlayerSortMode,
        addon.Options.World.GroupSortMode,
        function(enabled) addon.Options.World.Enabled = enabled end,
        function(mode) addon.Options.World.PlayerSortMode = mode end,
        function(mode) addon.Options.World.GroupSortMode = mode end
    )

    InterfaceOptions_AddCategory(panel)

    builder:BuildSortingMethodOptions(panel)
    builder:BuildKeybindingOptions(panel)
    builder:BuildMacroOptions(panel)
    builder:BuildSpacingOptions(panel)
    builder:BuildHealthCheck(panel)

    SLASH_FRAMESORT1 = "/fs"
    SLASH_FRAMESORT2 = "/framesort"

    SlashCmdList.FRAMESORT = function()
        InterfaceOptionsFrame_OpenToCategory(panel.name)

        -- workaround the classic bug where the first call opens the Game interface
        -- and a second call is required
        if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            InterfaceOptionsFrame_OpenToCategory(panel.name)
        end
    end
end
