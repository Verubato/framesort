---@type string, Addon
local _, addon = ...
---@type WoW
local wow = addon.WoW
local fsSort = addon.Sorting
local fsHide = addon.HidePlayer
local fsHealth = addon.Health
local verticalSpacing = addon.OptionsBuilder.VerticalSpacing
local horizontalSpacing = addon.OptionsBuilder.HorizontalSpacing
local labelWidth = 50

---Adds the title UI components.
---@param panel table the parent UI panel.
---@return table The bottom left most control to use for anchoring subsequent UI components.
local function BuiltTitle(panel)
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", verticalSpacing, -verticalSpacing)
    title:SetText("FrameSort")

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
    addon.OptionsBuilder:TextShim(enabled)
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
        addon.OptionsBuilder:TextShim(top)
        top.Text:SetText("Top")
        top:SetPoint("LEFT", playerLabel, "RIGHT", horizontalSpacing / 2, 0)
        top:SetChecked(options.PlayerSortMode == addon.PlayerSortMode.Top)

        middle = wow.CreateFrame("CheckButton", nil, parentPanel, "UICheckButtonTemplate")
        addon.OptionsBuilder:TextShim(middle)
        middle.Text:SetText("Middle")
        middle:SetPoint("LEFT", top, "RIGHT", horizontalSpacing, 0)
        middle:SetChecked(options.PlayerSortMode == addon.PlayerSortMode.Middle)

        bottom = wow.CreateFrame("CheckButton", nil, parentPanel, "UICheckButtonTemplate")
        addon.OptionsBuilder:TextShim(bottom)
        bottom.Text:SetText("Bottom")
        bottom:SetPoint("LEFT", middle, "RIGHT", horizontalSpacing, 0)
        bottom:SetChecked(options.PlayerSortMode == addon.PlayerSortMode.Bottom)

        hidden = wow.CreateFrame("CheckButton", nil, parentPanel, "UICheckButtonTemplate")
        addon.OptionsBuilder:TextShim(hidden)
        hidden.Text:SetText("Hidden")
        hidden:SetPoint("LEFT", bottom, "RIGHT", horizontalSpacing, 0)
        hidden:SetChecked(options.PlayerSortMode == addon.PlayerSortMode.Hidden)

        local playerModes = {
            [top] = addon.PlayerSortMode.Top,
            [middle] = addon.PlayerSortMode.Middle,
            [bottom] = addon.PlayerSortMode.Bottom,
            [hidden] = addon.PlayerSortMode.Hidden,
        }

        local function onPlayerClick(sender)
            -- uncheck the others
            for chkbox, _ in pairs(playerModes) do
                if chkbox ~= sender then
                    chkbox:SetChecked(false)
                end
            end

            options.PlayerSortMode = sender:GetChecked() and playerModes[sender] or ""
            fsHide:ShowHidePlayer()
            fsSort:TrySort()
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

    addon.OptionsBuilder:TextShim(group)
    group.Text:SetText(addon.GroupSortMode.Group)
    group:SetChecked(options.GroupSortMode == addon.GroupSortMode.Group)

    local role = wow.CreateFrame("CheckButton", nil, parentPanel, "UICheckButtonTemplate")
    role:SetPoint("LEFT", group, "RIGHT", horizontalSpacing, 0)
    addon.OptionsBuilder:TextShim(role)
    role.Text:SetText(addon.GroupSortMode.Role)
    role:SetChecked(options.GroupSortMode == addon.GroupSortMode.Role)

    local alpha = nil
    local modes = {
        [group] = addon.GroupSortMode.Group,
        [role] = addon.GroupSortMode.Role,
    }

    if hasAlpha then
        alpha = wow.CreateFrame("CheckButton", nil, parentPanel, "UICheckButtonTemplate")
        alpha:SetPoint("LEFT", role, "RIGHT", horizontalSpacing, 0)
        addon.OptionsBuilder:TextShim(alpha)
        alpha.Text:SetText("Alpha")
        alpha:SetChecked(options.GroupSortMode == addon.GroupSortMode.Alphabetical)

        modes[alpha] = addon.GroupSortMode.Alphabetical
    end

    local reverse = wow.CreateFrame("CheckButton", nil, parentPanel, "UICheckButtonTemplate")
    reverse:SetPoint("LEFT", alpha or role, "RIGHT", horizontalSpacing, 0)
    addon.OptionsBuilder:TextShim(reverse)
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
        fsSort:TrySort()
    end

    for chkbox, _ in pairs(modes) do
        chkbox:HookScript("OnClick", onModeClick)
    end

    reverse:HookScript("OnClick", function()
        options.Reverse = reverse:GetChecked()
        fsSort:TrySort()
    end)

    parentPanel:HookScript("OnShow", function()
        -- update checkboxes on show, in case the api updated them
        enabled:SetChecked(options.Enabled)

        if hasPlayer then
            top:SetChecked(options.PlayerSortMode == addon.PlayerSortMode.Top)
            middle:SetChecked(options.PlayerSortMode == addon.PlayerSortMode.Middle)
            bottom:SetChecked(options.PlayerSortMode == addon.PlayerSortMode.Bottom)
            hidden:SetChecked(options.PlayerSortMode == addon.PlayerSortMode.Hidden)
        end

        group:SetChecked(options.GroupSortMode == addon.GroupSortMode.Group)
        role:SetChecked(options.GroupSortMode == addon.GroupSortMode.Role)

        if hasAlpha then
            alpha:SetChecked(options.GroupSortMode == addon.GroupSortMode.Alphabetical)
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
            fsSort:TrySort()

            dynamicAnchor:SetPoint("TOPLEFT", modeLabel, "BOTTOMLEFT")
        else
            dynamicAnchor:SetPoint("TOPLEFT", enabled, "BOTTOMLEFT", 4, 0)
        end
    end

    enabled:HookScript("OnClick", function()
        local checked = enabled:GetChecked()

        options.Enabled = checked

        showHide(checked)

        if checked then
            fsSort:TrySort()
        end
    end)

    showHide(options.Enabled)

    return dynamicAnchor
end

addon.OptionsBuilder.Sorting = {
    Build = function(_, parent)
        local anchor = BuiltTitle(parent)

        if not wow.IsClassic() then
            anchor = BuildSortModeCheckboxes(parent, anchor, "Arena", addon.Options.Arena)
        end

        if wow.IsRetail() then
            anchor = BuildSortModeCheckboxes(parent, anchor, "Enemy Arena (GladiusEx, sArena, Blizzard)", addon.Options.EnemyArena, false, false)
        end

        anchor = BuildSortModeCheckboxes(parent, anchor, "Dungeon (mythics, 5-mans)", addon.Options.Dungeon)
        anchor = BuildSortModeCheckboxes(parent, anchor, "Raid (battlegrounds, raids)", addon.Options.Raid)
        anchor = BuildSortModeCheckboxes(parent, anchor, "World (non-instance groups)", addon.Options.World)

        return parent
    end,
}
