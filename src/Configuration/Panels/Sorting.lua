---@type string, Addon
local addonName, addon = ...
local wow = addon.WoW.Api
local capabilities = addon.WoW.Capabilities
local fsHealth = addon.Health.HealthCheck
local fsConfig = addon.Configuration
local fsModules = addon.Modules
local fsInspector = addon.Modules.Inspector
local fsEnemyAssignments = addon.Modules.EnemyAssignments
local L = addon.Locale.Current
local verticalSpacing = fsConfig.VerticalSpacing
local horizontalSpacing = fsConfig.HorizontalSpacing * 1.5
local labelWidth = 50
local M = {}
fsConfig.Panels.Sorting = M

---Adds the title UI components.
---@param panel table the parent UI panel.
---@return table The bottom left most control to use for anchoring subsequent UI components.
local function BuiltTitle(panel)
    local version = wow.GetAddOnMetadata(addonName, "Version")
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", verticalSpacing, -verticalSpacing)
    title:SetText(string.format(L["FrameSort - %s"], version))

    local unhealthy = panel:CreateFontString(nil, "ARTWORK", "GameFontRed")
    unhealthy:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -verticalSpacing)
    unhealthy:SetText(L["There are some issues that may prevent FrameSort from working correctly."])
    unhealthy:SetShown(false)

    local unhealthyGoto = panel:CreateFontString(nil, "ARTWORK", "GameFontRed")
    unhealthyGoto:SetPoint("TOPLEFT", unhealthy, "BOTTOMLEFT", 0, -verticalSpacing)
    unhealthyGoto:SetText(L["Please go to the Health Check panel to view more details."])
    unhealthyGoto:SetShown(false)

    local anchor = title
    local dynamicAnchor = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    dynamicAnchor:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT")

    local onShow = function()
        local healthy = fsHealth:IsHealthy()

        unhealthy:SetShown(not healthy)
        unhealthyGoto:SetShown(not healthy)

        if healthy then
            dynamicAnchor:SetPoint("TOPLEFT", title, "BOTTOMLEFT")
        else
            dynamicAnchor:SetPoint("TOPLEFT", unhealthyGoto, "BOTTOMLEFT")
        end
    end

    title:SetScript("OnShow", onShow)

    return dynamicAnchor
end

---Adds a row of the player and group sort mode checkboxes.
---@param parentPanel table the parent UI panel.
---@param pointOffset table a UI component used as a relative position anchor for the new components.
---@param labelText string the text to display on the enabled checkbox.
---@param labelTooltip string the tooltip to display on the enabled checkbox.
---@param options table the configuration table
---@param hasPlayer boolean?
---@param hasAlpha boolean?
---@param note table? an unanchored text line to place under the title, shown with the other controls.
---@return table The bottom left most control to use for anchoring subsequent UI components.
local function BuildSortModeCheckboxes(parentPanel, pointOffset, labelText, labelTooltip, options, hasPlayer, hasAlpha, note)
    if hasPlayer == nil then
        hasPlayer = true
    end
    if hasAlpha == nil then
        hasAlpha = true
    end

    local enabled = wow.CreateFrame("CheckButton", nil, parentPanel, "UICheckButtonTemplate")
    -- not sure why, but checkbox left seems to be off by about 4 units by default
    enabled:SetPoint("TOPLEFT", pointOffset, "BOTTOMLEFT", -4, -verticalSpacing)
    enabled.Text:SetText(" " .. labelText)
    enabled.Text:SetFontObject("GameFontNormalLarge")
    enabled:SetChecked(options.Enabled)
    fsConfig:Tooltip(enabled, labelText, labelTooltip)

    local dynamicAnchor = parentPanel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    dynamicAnchor:SetPoint("TOPLEFT", enabled, "BOTTOMLEFT", 4)

    local belowTitle = enabled

    if note then
        note:SetPoint("TOPLEFT", enabled, "BOTTOMLEFT", 4, -verticalSpacing)
        belowTitle = note
    end

    local playerLabel = nil
    local top = nil
    local middle = nil
    local bottom = nil
    local hidden = nil

    if hasPlayer then
        playerLabel = parentPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        playerLabel:SetPoint("TOPLEFT", belowTitle, "BOTTOMLEFT", note and 0 or 4, -verticalSpacing)
        playerLabel:SetText(L["Player"] .. ":")
        playerLabel:SetJustifyH("LEFT")
        playerLabel:SetWidth(labelWidth)

        top = wow.CreateFrame("CheckButton", nil, parentPanel, "UICheckButtonTemplate")
        top.Text:SetText(L["Top"])
        top:SetPoint("LEFT", playerLabel, "RIGHT", horizontalSpacing / 2, 0)
        top:SetChecked(options.PlayerSortMode == fsConfig.PlayerSortMode.Top)
        fsConfig:Tooltip(top, L["Top"], L["Place your own frame at the top of the group."])

        middle = wow.CreateFrame("CheckButton", nil, parentPanel, "UICheckButtonTemplate")
        middle.Text:SetText(L["Middle"])
        middle:SetPoint("LEFT", top, "RIGHT", horizontalSpacing, 0)
        middle:SetChecked(options.PlayerSortMode == fsConfig.PlayerSortMode.Middle)
        fsConfig:Tooltip(middle, L["Middle"], L["Place your own frame in the middle of the group."])

        bottom = wow.CreateFrame("CheckButton", nil, parentPanel, "UICheckButtonTemplate")
        bottom.Text:SetText(L["Bottom"])
        bottom:SetPoint("LEFT", middle, "RIGHT", horizontalSpacing, 0)
        bottom:SetChecked(options.PlayerSortMode == fsConfig.PlayerSortMode.Bottom)
        fsConfig:Tooltip(bottom, L["Bottom"], L["Place your own frame at the bottom of the group."])

        hidden = wow.CreateFrame("CheckButton", nil, parentPanel, "UICheckButtonTemplate")
        hidden.Text:SetText(L["Hidden"])
        hidden:SetPoint("LEFT", bottom, "RIGHT", horizontalSpacing, 0)
        hidden:SetChecked(options.PlayerSortMode == fsConfig.PlayerSortMode.Hidden)
        fsConfig:Tooltip(hidden, L["Hidden"], L["Hide your own frame, leaving only your group members."])

        local playerModes = {
            [top] = fsConfig.PlayerSortMode.Top,
            [middle] = fsConfig.PlayerSortMode.Middle,
            [bottom] = fsConfig.PlayerSortMode.Bottom,
            [hidden] = fsConfig.PlayerSortMode.Hidden,
        }

        local function onPlayerClick(sender)
            -- uncheck the others
            for chkbox, _ in pairs(playerModes) do
                if chkbox ~= sender then
                    chkbox:SetChecked(false)
                end
            end

            options.PlayerSortMode = sender:GetChecked() and playerModes[sender] or ""
            fsConfig:NotifyChanged()
            fsModules:Run()
        end

        for chkbox, _ in pairs(playerModes) do
            chkbox:SetScript("OnClick", onPlayerClick)
        end
    end

    local modeLabel = parentPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")

    if hasPlayer then
        modeLabel:SetPoint("TOPLEFT", playerLabel, "BOTTOMLEFT", 0, -verticalSpacing * 1.5)
    else
        modeLabel:SetPoint("TOPLEFT", belowTitle, "BOTTOMLEFT", note and 0 or 4, -verticalSpacing)
    end

    modeLabel:SetText(L["Sort"] .. ":")
    modeLabel:SetJustifyH("LEFT")
    modeLabel:SetWidth(labelWidth)

    -- why use checkboxes instead of a dropdown box?
    -- because the dropdown box control has taint issues that haven't been fixed for years
    -- also it seems to have become much worse in dragonflight
    -- so while a dropdown would be better ui design, it's too buggy to use at the moment
    local group = wow.CreateFrame("CheckButton", nil, parentPanel, "UICheckButtonTemplate")
    group:SetPoint("LEFT", modeLabel, "RIGHT", horizontalSpacing / 2, 0)

    group.Text:SetText(L["Group"])
    group:SetChecked(options.GroupSortMode == fsConfig.GroupSortMode.Group)
    fsConfig:Tooltip(group, L["Group"], L["Sort by the unit id, e.g. party1 > party2 > party3."])

    local spec = wow.CreateFrame("CheckButton", nil, parentPanel, "UICheckButtonTemplate")
    spec:SetPoint("LEFT", group, "RIGHT", horizontalSpacing, 0)
    local canInspect = fsInspector:CanRun()
    local specText = canInspect and L["Spec"] or L["Role"]
    spec.Text:SetText(specText)
    spec:SetChecked(options.GroupSortMode == fsConfig.GroupSortMode.Role)
    local specTooltip = canInspect and L["Sort by role and spec, using the order from the Ordering panel."] or L["Sort by role (tank, healer, dps), using the order from the Ordering panel."]
    fsConfig:Tooltip(spec, specText, specTooltip)

    local alpha = nil
    local modes = {
        [group] = fsConfig.GroupSortMode.Group,
        [spec] = fsConfig.GroupSortMode.Role,
    }

    if hasAlpha then
        alpha = wow.CreateFrame("CheckButton", nil, parentPanel, "UICheckButtonTemplate")
        alpha:SetPoint("LEFT", spec, "RIGHT", horizontalSpacing, 0)
        alpha.Text:SetText(L["Alphabetical"])
        alpha:SetChecked(options.GroupSortMode == fsConfig.GroupSortMode.Alphabetical)
        fsConfig:Tooltip(alpha, L["Alphabetical"], L["Sort by name in alphabetical order."])

        modes[alpha] = fsConfig.GroupSortMode.Alphabetical
    end

    local reverse = wow.CreateFrame("CheckButton", nil, parentPanel, "UICheckButtonTemplate")
    reverse:SetPoint("LEFT", alpha or spec, "RIGHT", horizontalSpacing, 0)
    reverse.Text:SetText(L["Reverse"])
    reverse:SetChecked(options.Reverse)
    fsConfig:Tooltip(reverse, L["Reverse"], L["Reverse the sort order, so the last frame becomes the first."])

    local function onModeClick(sender)
        -- uncheck the others
        for chkbox, _ in pairs(modes) do
            if chkbox ~= sender then
                chkbox:SetChecked(false)
            end
        end

        options.GroupSortMode = sender:GetChecked() and modes[sender] or ""
        fsConfig:NotifyChanged()
        fsModules:Run()
    end

    for chkbox, _ in pairs(modes) do
        chkbox:SetScript("OnClick", onModeClick)
    end

    reverse:SetScript("OnClick", function()
        options.Reverse = reverse:GetChecked()
        fsConfig:NotifyChanged()
        fsModules:Run()
    end)

    local function refresh()
        -- update checkboxes on show, in case the api updated them
        enabled:SetChecked(options.Enabled)

        if hasPlayer then
            assert(top):SetChecked(options.PlayerSortMode == fsConfig.PlayerSortMode.Top)
            assert(middle):SetChecked(options.PlayerSortMode == fsConfig.PlayerSortMode.Middle)
            assert(bottom):SetChecked(options.PlayerSortMode == fsConfig.PlayerSortMode.Bottom)
            assert(hidden):SetChecked(options.PlayerSortMode == fsConfig.PlayerSortMode.Hidden)
        end

        group:SetChecked(options.GroupSortMode == fsConfig.GroupSortMode.Group)
        spec:SetChecked(options.GroupSortMode == fsConfig.GroupSortMode.Role)

        if hasAlpha then
            assert(alpha):SetChecked(options.GroupSortMode == fsConfig.GroupSortMode.Alphabetical)
        end

        reverse:SetChecked(options.Reverse)
    end

    parentPanel:SetScript("OnShow", refresh)

    local controls = {
        playerLabel,
        top,
        middle,
        bottom,
        hidden,
        modeLabel,
        group,
        spec,
        alpha,
        reverse,
        note,
    }

    local function showHide(show)
        for _, control in pairs(controls) do
            if control then
                control:SetShown(show)
            end
        end

        if show then
            dynamicAnchor:SetPoint("TOPLEFT", modeLabel, "BOTTOMLEFT")
        else
            dynamicAnchor:SetPoint("TOPLEFT", enabled, "BOTTOMLEFT", 4, 0)
        end
    end

    enabled:SetScript("OnClick", function()
        local checked = enabled:GetChecked()

        options.Enabled = checked

        showHide(checked)

        fsConfig:NotifyChanged()

        if checked then
            fsModules:Run()
        end
    end)

    -- an api change to Enabled must hide the note with the rows
    fsConfig:RegisterConfigurationChangedCallback(function()
        refresh()

        if note then
            showHide(options.Enabled)
        end
    end)

    showHide(options.Enabled)

    return dynamicAnchor
end

---Adds the popup checkbox and open button for clients where the user marks enemy roles by hand.
---@param panel table the parent UI panel.
---@param anchor table a UI component used as a relative position anchor for the new components.
---@return table The bottom left most control to use for anchoring subsequent UI components.
local function BuildEnemyRoles(panel, anchor)
    local options = addon.DB.Options.EnemyAssignments
    local popupText = L["Show the enemy roles window at the start of each arena round"]
    local popup = wow.CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    popup:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", -4, -verticalSpacing)
    popup.Text:SetText(" " .. popupText)
    popup:SetChecked(options.PopupEnabled)

    popup:SetScript("OnClick", function()
        options.PopupEnabled = popup:GetChecked()
        fsConfig:NotifyChanged()
    end)

    local specPicker = wow.CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    specPicker:SetPoint("TOPLEFT", popup, "BOTTOMLEFT", 0, -verticalSpacing / 2)
    specPicker.Text:SetText(" " .. L["Also pick enemy specs (used by other addons)"])
    specPicker:SetChecked(options.SpecPickerEnabled)

    specPicker:SetScript("OnClick", function()
        options.SpecPickerEnabled = specPicker:GetChecked()
        fsConfig:NotifyChanged()
    end)

    local open = wow.CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    open:SetPoint("TOPLEFT", specPicker, "BOTTOMLEFT", 4, -verticalSpacing / 2)
    open:SetWidth(200)
    open:SetText(L["Open enemy roles window"])
    open:SetScript("OnClick", function()
        -- the window module loads after the options panels
        addon.Modules.EnemyAssignmentsWindow:OpenForCurrentContext()
    end)

    local dynamicAnchor = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")

    local function refresh()
        popup:SetChecked(options.PopupEnabled)
        specPicker:SetChecked(options.SpecPickerEnabled)

        if M:ShowsEnemyRolesOptions() then
            popup:Show()
            specPicker:Show()
            open:Show()
            dynamicAnchor:SetPoint("TOPLEFT", open, "BOTTOMLEFT", 0, 0)
        else
            popup:Hide()
            specPicker:Hide()
            open:Hide()
            dynamicAnchor:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, 0)
        end
    end

    -- the Enemy Arena checkbox notifies a change when clicked, which lands here
    fsConfig:RegisterConfigurationChangedCallback(refresh)
    refresh()

    return dynamicAnchor
end

---True where the client offers enemy specs, whether it reads them or the user marks them.
---@return boolean
function M:ShowsEnemyArena()
    return capabilities.HasEnemySpecSupport()
end

---True where the user marks enemy roles, so the panel offers the popup option.
---@return boolean
function M:ShowsEnemyRoles()
    return fsEnemyAssignments:IsActive()
end

---True when the enemy roles controls should show.
---@return boolean
function M:ShowsEnemyRolesOptions()
    return addon.DB.Options.Sorting.EnemyArena.Enabled == true
end

function M:Build(panel)
    local anchor = BuiltTitle(panel)
    local config = addon.DB.Options.Sorting

    if capabilities.HasArena() then
        anchor = BuildSortModeCheckboxes(panel, anchor, L["Arena - 2v2"], L["Sort your frames while in 2v2 arena matches."], config.Arena.Twos)

        -- the tooltip stays in its own local: the locale checker reads a runtime-built key and a
        -- literal one on the same line as a single key, and reports it as missing everywhere.
        local otherArenaSizes = capabilities.Has5v5() and "3v3 & 5v5" or "3v3"
        local otherArenaTooltip = L["Sort your frames while in arena matches larger than 2v2."]
        anchor = BuildSortModeCheckboxes(panel, anchor, L["Arena - " .. otherArenaSizes], otherArenaTooltip, config.Arena.Default)
    end

    if M:ShowsEnemyArena() then
        local note = nil

        if M:ShowsEnemyRoles() then
            note = fsConfig:TextLine(L["From 12.1.5 onwards addons can't read enemy specs, so we've implemented a manual workaround."], panel, nil, "GameFontRed")
        end

        anchor = BuildSortModeCheckboxes(
            panel,
            anchor,
            L["Enemy Arena (see addons panel for supported addons)"],
            L["Sort the enemy frames created by supported arena addons."],
            config.EnemyArena,
            false,
            false,
            note
        )
    end

    if M:ShowsEnemyRoles() then
        anchor = BuildEnemyRoles(panel, anchor)
    end

    anchor = BuildSortModeCheckboxes(panel, anchor, L["Dungeon (mythics, 5-mans, delves)"], L["Sort your frames while in dungeons, mythic+, and delves."], config.Dungeon)
    anchor = BuildSortModeCheckboxes(panel, anchor, L["Raid (battlegrounds, raids)"], L["Sort your frames while in raids and battlegrounds."], config.Raid)
    BuildSortModeCheckboxes(panel, anchor, L["World (non-instance groups)"], L["Sort your frames while in a group out in the world."], config.World)

    return panel
end
