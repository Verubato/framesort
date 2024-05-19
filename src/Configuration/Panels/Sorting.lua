---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsHealth = addon.Health.HealthCheck
local fsConfig = addon.Configuration
local fsModules = addon.Modules
local verticalSpacing = fsConfig.VerticalSpacing
local horizontalSpacing = fsConfig.HorizontalSpacing
local labelWidth = 50
local M = {}
fsConfig.Panels.Sorting = M

---Adds the title UI components.
---@param panel table the parent UI panel.
---@return table The bottom left most control to use for anchoring subsequent UI components.
local function BuiltTitle(panel)
    local version = wow.GetAddOnMetadata("FrameSort", "Version")
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", verticalSpacing, -verticalSpacing)
    title:SetText("FrameSort - " .. version)

    local unhealthy = panel:CreateFontString(nil, "ARTWORK", "GameFontRed")
    unhealthy:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -verticalSpacing)
    unhealthy:SetText("There are some issuse that may prevent FrameSort from working correctly.")

    local unhealthyGoto = panel:CreateFontString(nil, "ARTWORK", "GameFontRed")
    unhealthyGoto:SetPoint("TOPLEFT", unhealthy, "BOTTOMLEFT", 0, -verticalSpacing)
    unhealthyGoto:SetText("Please go to the Health Check panel to view more details.")

    local lines = {
        Group = "party1 > party2 > partyN > partyN+1",
        Role = "tank > healer > dps",
        Alpha = "NameA > NameB > NameZ",
    }

    local keyWidth = 50
    local i = 1
    local anchor = title
    local sortingRules = {}
    local roleValueText = nil

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

        if k == "Role" then
            roleValueText = valueText
        end

        sortingRules[#sortingRules + 1] = {
            Key = keyText,
            Value = valueText,
        }
    end

    local dynamicAnchor = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    dynamicAnchor:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT")

    local onShow = function()
        local healthy = fsHealth:IsHealthy()
        unhealthy:SetShown(not healthy)
        unhealthyGoto:SetShown(not healthy)

        for _, rule in ipairs(sortingRules) do
            rule.Key:SetShown(healthy)
            rule.Value:SetShown(healthy)
        end

        assert(roleValueText ~= nil)

        if addon.DB.Options.Sorting.RoleOrdering == fsConfig.RoleOrdering.HealerTankDps then
            roleValueText:SetText("healer > tank > dps")
        elseif addon.DB.Options.Sorting.RoleOrdering == fsConfig.RoleOrdering.HealerDpsTank then
            roleValueText:SetText("healer > dps > tank")
        else
            roleValueText:SetText("tank > healer > dps")
        end

        if healthy then
            dynamicAnchor:SetPoint("TOPLEFT", sortingRules[#sortingRules].Key, "BOTTOMLEFT")
        else
            dynamicAnchor:SetPoint("TOPLEFT", unhealthyGoto, "BOTTOMLEFT")
        end
    end

    panel:HookScript("OnShow", onShow)

    local loader = wow.CreateFrame("Frame", nil, panel)
    loader:HookScript("OnEvent", onShow)
    loader:RegisterEvent("PLAYER_ENTERING_WORLD")

    return dynamicAnchor
end

---Adds a row of the player and group sort mode checkboxes.
---@param parentPanel table the parent UI panel.
---@param pointOffset table a UI component used as a relative position anchor for the new components.
---@param labelText string the text to display on the enabled checkbox.
---@param options table the configuration table
---@param hasPlayer boolean?
---@param hasAlpha boolean?
---@return table The bottom left most control to use for anchoring subsequent UI components.
local function BuildSortModeCheckboxes(parentPanel, pointOffset, labelText, options, hasPlayer, hasAlpha)
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

    local dynamicAnchor = parentPanel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    dynamicAnchor:SetPoint("TOPLEFT", enabled, "BOTTOMLEFT", 4)

    local playerLabel = nil
    local top = nil
    local middle = nil
    local bottom = nil
    local hidden = nil

    if hasPlayer then
        playerLabel = parentPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        playerLabel:SetPoint("TOPLEFT", enabled, "BOTTOMLEFT", 4, -verticalSpacing)
        playerLabel:SetText("Player:")
        playerLabel:SetJustifyH("LEFT")
        playerLabel:SetWidth(labelWidth)

        top = wow.CreateFrame("CheckButton", nil, parentPanel, "UICheckButtonTemplate")
        top.Text:SetText("Top")
        top:SetPoint("LEFT", playerLabel, "RIGHT", horizontalSpacing / 2, 0)
        top:SetChecked(options.PlayerSortMode == fsConfig.PlayerSortMode.Top)

        middle = wow.CreateFrame("CheckButton", nil, parentPanel, "UICheckButtonTemplate")
        middle.Text:SetText("Middle")
        middle:SetPoint("LEFT", top, "RIGHT", horizontalSpacing, 0)
        middle:SetChecked(options.PlayerSortMode == fsConfig.PlayerSortMode.Middle)

        bottom = wow.CreateFrame("CheckButton", nil, parentPanel, "UICheckButtonTemplate")
        bottom.Text:SetText("Bottom")
        bottom:SetPoint("LEFT", middle, "RIGHT", horizontalSpacing, 0)
        bottom:SetChecked(options.PlayerSortMode == fsConfig.PlayerSortMode.Bottom)

        hidden = wow.CreateFrame("CheckButton", nil, parentPanel, "UICheckButtonTemplate")
        hidden.Text:SetText("Hidden")
        hidden:SetPoint("LEFT", bottom, "RIGHT", horizontalSpacing, 0)
        hidden:SetChecked(options.PlayerSortMode == fsConfig.PlayerSortMode.Hidden)

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
            chkbox:HookScript("OnClick", onPlayerClick)
        end
    end

    local modeLabel = parentPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")

    if hasPlayer then
        modeLabel:SetPoint("TOPLEFT", playerLabel, "BOTTOMLEFT", 0, -verticalSpacing * 1.5)
    else
        modeLabel:SetPoint("TOPLEFT", enabled, "BOTTOMLEFT", 4, -verticalSpacing)
    end

    modeLabel:SetText("Sort:")
    modeLabel:SetJustifyH("LEFT")
    modeLabel:SetWidth(labelWidth)

    -- why use checkboxes instead of a dropdown box?
    -- because the dropdown box control has taint issues that haven't been fixed for years
    -- also it seems to have become much worse in dragonflight
    -- so while a dropdown would be better ui design, it's too buggy to use at the moment
    local group = wow.CreateFrame("CheckButton", nil, parentPanel, "UICheckButtonTemplate")
    group:SetPoint("LEFT", modeLabel, "RIGHT", horizontalSpacing / 2, 0)

    group.Text:SetText(fsConfig.GroupSortMode.Group)
    group:SetChecked(options.GroupSortMode == fsConfig.GroupSortMode.Group)

    local role = wow.CreateFrame("CheckButton", nil, parentPanel, "UICheckButtonTemplate")
    role:SetPoint("LEFT", group, "RIGHT", horizontalSpacing, 0)
    role.Text:SetText(fsConfig.GroupSortMode.Role)
    role:SetChecked(options.GroupSortMode == fsConfig.GroupSortMode.Role)

    local alpha = nil
    local modes = {
        [group] = fsConfig.GroupSortMode.Group,
        [role] = fsConfig.GroupSortMode.Role,
    }

    if hasAlpha then
        alpha = wow.CreateFrame("CheckButton", nil, parentPanel, "UICheckButtonTemplate")
        alpha:SetPoint("LEFT", role, "RIGHT", horizontalSpacing, 0)
        alpha.Text:SetText("Alpha")
        alpha:SetChecked(options.GroupSortMode == fsConfig.GroupSortMode.Alphabetical)

        modes[alpha] = fsConfig.GroupSortMode.Alphabetical
    end

    local reverse = wow.CreateFrame("CheckButton", nil, parentPanel, "UICheckButtonTemplate")
    reverse:SetPoint("LEFT", alpha or role, "RIGHT", horizontalSpacing, 0)
    reverse.Text:SetText("Reverse")
    reverse:SetChecked(options.Reverse)

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
        chkbox:HookScript("OnClick", onModeClick)
    end

    reverse:HookScript("OnClick", function()
        options.Reverse = reverse:GetChecked()
        fsConfig:NotifyChanged()
        fsModules:Run()
    end)

    parentPanel:HookScript("OnShow", function()
        -- update checkboxes on show, in case the api updated them
        enabled:SetChecked(options.Enabled)

        if hasPlayer then
            assert(top):SetChecked(options.PlayerSortMode == fsConfig.PlayerSortMode.Top)
            assert(middle):SetChecked(options.PlayerSortMode == fsConfig.PlayerSortMode.Middle)
            assert(bottom):SetChecked(options.PlayerSortMode == fsConfig.PlayerSortMode.Bottom)
            assert(hidden):SetChecked(options.PlayerSortMode == fsConfig.PlayerSortMode.Hidden)
        end

        group:SetChecked(options.GroupSortMode == fsConfig.GroupSortMode.Group)
        role:SetChecked(options.GroupSortMode == fsConfig.GroupSortMode.Role)

        if hasAlpha then
            assert(alpha):SetChecked(options.GroupSortMode == fsConfig.GroupSortMode.Alphabetical)
        end

        reverse:SetChecked(options.Reverse)
    end)

    local controls = {
        playerLabel,
        top,
        middle,
        bottom,
        hidden,
        modeLabel,
        group,
        role,
        alpha,
        reverse,
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

    enabled:HookScript("OnClick", function()
        local checked = enabled:GetChecked()

        options.Enabled = checked

        showHide(checked)

        fsConfig:NotifyChanged()

        if checked then
            fsModules:Run()
        end
    end)

    showHide(options.Enabled)

    return dynamicAnchor
end

function M:Build(panel)
    local anchor = BuiltTitle(panel)

    local config = addon.DB.Options.Sorting

    if not wow.IsClassic() then
        anchor = BuildSortModeCheckboxes(panel, anchor, "Arena - 2v2", config.Arena.Twos)

        local otherArenaSizes = wow.IsRetail() and "3v3" or "3v3 & 5v5"
        anchor = BuildSortModeCheckboxes(panel, anchor, "Arena - " .. otherArenaSizes, config.Arena.Default)
    end

    if wow.IsRetail() then
        anchor = BuildSortModeCheckboxes(panel, anchor, "Enemy Arena (Gladius, GladiusEx, sArena, Blizzard)", config.EnemyArena, false, false)
    end

    anchor = BuildSortModeCheckboxes(panel, anchor, "Dungeon (mythics, 5-mans)", config.Dungeon)
    anchor = BuildSortModeCheckboxes(panel, anchor, "Raid (battlegrounds, raids)", config.Raid)
    anchor = BuildSortModeCheckboxes(panel, anchor, "World (non-instance groups)", config.World)

    return panel
end
