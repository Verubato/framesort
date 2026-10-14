---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local wowEx = addon.WoW.WowEx
local events = addon.WoW.Events
local capabilities = addon.WoW.Capabilities
local fsConfig = addon.Configuration
local fsEnemyAssignments = addon.Modules.EnemyAssignments
local fsSpec = addon.Configuration.Specs
local fsScheduler = addon.Scheduling.Scheduler
local L = addon.Locale.Current

---@class EnemyAssignmentsWindow
local M = {}
addon.Modules.EnemyAssignmentsWindow = M

local maxRows = 5
local padding = 16
local spacing = 8
local rowHeight = 40
local rowGap = 4
local titleHeight = 18
local titleGap = 6
local hintHeight = 14
local nameWidth = 130
local portraitSize = 32
local roleIconSize = 15
local roleButtonSize = 26
local roleButtonGap = 2
local specWidth = 170
local specMenuHeight = 400
local clearHeight = 22
local checkboxHeight = 26

-- the checkbox art has a few pixels of empty border
local checkboxInset = 4

local footerHeight = spacing + clearHeight + checkboxInset + checkboxHeight + padding - checkboxInset

-- the dropdown value that means no spec is picked
local noSpec = 0

local unlitAlpha = 0.35
local filledAlpha = 0.6
local roleTexture = "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES"

-- matches GetTexCoordsForRole, which only exists once the group finder has loaded
local roleTexCoords = {
    [wowEx.Role.Tank] = { 0, 19 / 64, 22 / 64, 41 / 64 },
    [wowEx.Role.Healer] = { 20 / 64, 39 / 64, 1 / 64, 20 / 64 },
    [wowEx.Role.Dps] = { 20 / 64, 39 / 64, 22 / 64, 41 / 64 },
}

local roles = { wowEx.Role.Tank, wowEx.Role.Healer, wowEx.Role.Dps }

local window = nil
local rows = {}

-- true when the window was built with Blizzard's spec display
local hasSpecDisplay = false

-- the enemies /fs test shows
local previewEnemies = {
    { Name = "Oakheart", SpecId = 105 },
    { Name = "Rimefrost", SpecId = 64 },
    { Name = "Quickblade", SpecId = 260 },
}

-- the marks made in the preview, or nil outside it
local preview = nil

-- stands in for the real marks while previewing, so nothing reaches sorting or macros
local previewStore = {}

---Returns the value only when it is safe to compare and index with, otherwise nil.
local function Readable(value)
    if wow.issecretvalue(value) then
        return nil
    end

    return value
end

local function Store()
    return preview and previewStore or fsEnemyAssignments
end

local function SpecDisplay()
    local util = wow.UnitFrameUtil
    return util and util.UpdateArenaOpponentSpecDisplay
end

local function OptionsTable()
    return addon.DB.Options.EnemyAssignments
end

local function SavePoint(frame)
    local options = OptionsTable()

    if not options then
        return
    end

    local point, _, relativePoint, x, y = frame:GetPoint()
    options.Point = { point, relativePoint, x, y }
end

local function RestorePoint(frame)
    local options = OptionsTable()
    local saved = options and options.Point

    frame:ClearAllPoints()

    if type(saved) == "table" and saved[1] then
        frame:SetPoint(saved[1], wow.UIParent, saved[2], saved[3], saved[4])
    else
        frame:SetPoint("CENTER", wow.UIParent, "CENTER", 0, 100)
    end
end

local function TextX()
    return hasSpecDisplay and portraitSize + spacing or 0
end

local function ButtonsX()
    return TextX() + nameWidth + spacing
end

local function SpecX()
    return ButtonsX() + roleButtonSize * 3 + roleButtonGap * 2 + spacing
end

local function RowWidth()
    return SpecX() + specWidth
end

local function FrameHeight(count)
    local hints = hasSpecDisplay and 2 or 1
    local header = padding + titleHeight + titleGap + hints * hintHeight + fsConfig.VerticalSpacing
    return header + count * rowHeight + (count - 1) * rowGap + footerHeight
end

local function SpecText(specId)
    if specId == noSpec then
        return L["None"]
    end

    local _, name, _, icon = wow.GetSpecializationInfoByID(specId)

    if not name then
        return tostring(specId)
    end

    return icon and string.format("|T%s:16:16|t %s", tostring(icon), name) or name
end

local function MenuKey(items, picked)
    local ids = {}

    for _, item in ipairs(items) do
        if item.SpecId then
            ids[#ids + 1] = item.SpecId
        end
    end

    return table.concat(ids, ",") .. "|" .. tostring(picked or noSpec)
end

local function ClassHeading(classId)
    local className, classFile

    if wow.GetClassInfo then
        className, classFile = wow.GetClassInfo(classId)
    end

    className = className or tostring(classId)
    local color = classFile and wow.RAID_CLASS_COLORS and wow.RAID_CLASS_COLORS[classFile]

    if not color then
        return className
    end

    return string.format("|cff%02x%02x%02x%s|r", math.floor(color.r * 255), math.floor(color.g * 255), math.floor(color.b * 255), className)
end

local function SetLit(button, lit, filled)
    button.Icon:SetDesaturated(not lit)
    button.Icon:SetAlpha(not lit and unlitAlpha or filled and filledAlpha or 1)
end

---Fills the spec display the way Blizzard's would, which has nothing to show outside an arena.
local function FillPreviewSpecDisplay(elements, specId)
    local _, specName, _, icon, role, _, className = wow.GetSpecializationInfoByID(specId)
    local coords = roleTexCoords[role]

    -- Blizzard's updater may have hidden these during a real round
    elements.specPortrait:Show()
    elements.specNameText:Show()
    elements.classNameText:Show()

    elements.specPortrait:SetTexture(icon)
    elements.specNameText:SetText(specName)
    elements.classNameText:SetText(className)
    elements.roleIcon:SetSize(roleIconSize, roleIconSize)
    elements.roleIcon:SetTexture(roleTexture)
    elements.roleIcon:SetShown(coords ~= nil)

    if coords then
        elements.roleIcon:SetTexCoord(unpack(coords))
    end
end

local function RefreshSpecDisplay(row, enemy)
    if not row.SpecElements then
        return
    end

    if enemy then
        FillPreviewSpecDisplay(row.SpecElements, enemy.SpecId)
        return
    end

    local update = SpecDisplay()

    if not update then
        return
    end

    -- the result may be secret, so it is never read
    update(row.SpecElements, row.Slot)
end

local function RefreshRow(row)
    local unit = "arena" .. row.Slot
    local store = Store()
    local role = store:Role(row.Slot)
    local filled = store:IsFilled(row.Slot)
    local spec = store:Spec(row.Slot)
    local enemy = preview and previewEnemies[row.Slot]
    local name, classId, classFile

    if enemy then
        local info = fsSpec:GetSpecInfo(enemy.SpecId)
        name, classId = enemy.Name, info and info.ClassId
        classFile = select(6, wow.GetSpecializationInfoByID(enemy.SpecId))
    else
        name = wow.UnitName(unit)
        classId, classFile = M:ReadableClass(unit)
    end

    local color = classFile and wow.RAID_CLASS_COLORS and wow.RAID_CLASS_COLORS[classFile]

    row.Name:SetText(M:RowLabel(row.Slot, name))

    if color then
        row.Name:SetTextColor(color.r, color.g, color.b)
    else
        row.Name:SetTextColor(1, 1, 1)
    end

    for buttonRole, button in pairs(row.RoleButtons) do
        SetLit(button, buttonRole == role, filled)
    end

    local items = M:SpecMenuItems(role, classId, spec)
    local key = MenuKey(items, spec)

    -- regenerating rebuilds the menu even while it is open
    if key ~= row.SpecKey then
        row.SpecItems = items
        row.SpecKey = key
        row.Spec:GenerateMenu()
    end

    RefreshSpecDisplay(row, enemy)
end

function previewStore:Role(slot)
    local entry = preview[slot]
    return entry and entry.Role
end

function previewStore:Spec(slot)
    local entry = preview[slot]
    return entry and entry.SpecId
end

function previewStore:IsFilled(slot)
    local entry = preview[slot]
    return entry ~= nil and entry.Filled == true
end

function previewStore:Set(slot, role, specId)
    if specId then
        role = fsEnemyAssignments:RoleForSpec(specId)
    elseif role then
        specId = previewStore:Spec(slot)

        if specId and fsEnemyAssignments:RoleForSpec(specId) ~= role then
            specId = nil
        end
    end

    preview[slot] = role and { Role = role, SpecId = specId } or nil

    if role == wowEx.Role.Healer then
        for i = 1, #previewEnemies do
            if not preview[i] then
                preview[i] = { Role = wowEx.Role.Dps, Filled = true }
            end
        end
    end

    M:Refresh()
end

function previewStore:ClearSpec(slot)
    if preview[slot] then
        preview[slot].SpecId = nil
    end

    M:Refresh()
end

function previewStore:Clear()
    preview = {}
    M:Refresh()
end

local function BuildRoleButton(row, slot, role, anchor, anchorPoint, x)
    local button = wow.CreateFrame("Button", nil, row)
    button:SetSize(roleButtonSize, roleButtonSize)
    button:SetPoint("LEFT", anchor, anchorPoint, x, 0)

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints(button)
    icon:SetTexture(roleTexture)
    icon:SetTexCoord(unpack(roleTexCoords[role]))
    button.Icon = icon

    button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    button:SetScript("OnClick", function()
        M:OnRoleClick(slot, role)
    end)

    local names = {
        [wowEx.Role.Tank] = L["Tank"],
        [wowEx.Role.Healer] = L["Healer"],
        [wowEx.Role.Dps] = L["DPS"],
    }

    fsConfig:Tooltip(button, names[role], L["Click a lit role again to clear it. Click a dimmed one to confirm it."])

    return button
end

---Adds the elements Blizzard's spec display fills in.
---@return table elements
local function BuildSpecDisplay(row)
    local portrait = row:CreateTexture(nil, "ARTWORK")
    portrait:SetSize(portraitSize, portraitSize)
    portrait:SetPoint("LEFT", row, "LEFT", 0, 0)

    local roleIcon = row:CreateTexture(nil, "OVERLAY")
    roleIcon:SetSize(roleIconSize, roleIconSize)
    roleIcon:SetPoint("BOTTOMRIGHT", portrait, "BOTTOMRIGHT", 3, -3)

    -- the name sits just above the row's centre line and the spec line just below it
    row.Name:ClearAllPoints()
    row.Name:SetPoint("BOTTOMLEFT", row, "LEFT", TextX(), 1)

    local specName = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    specName:SetPoint("TOPLEFT", row, "LEFT", TextX(), -2)
    specName:SetJustifyH("LEFT")
    specName:SetWordWrap(false)

    -- the right edge ends the line at the name column so long text truncates
    local className = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    className:SetPoint("TOPLEFT", specName, "TOPRIGHT", 3, 0)
    className:SetPoint("TOPRIGHT", row, "LEFT", TextX() + nameWidth, -2)
    className:SetJustifyH("LEFT")
    className:SetWordWrap(false)

    return {
        specPortrait = portrait,
        specNameText = specName,
        classNameText = className,
        roleIcon = roleIcon,
    }
end

local function BuildRow(parent, slot, anchor)
    local row = wow.CreateFrame("Frame", nil, parent)
    row:SetSize(RowWidth(), rowHeight)
    row:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, slot == 1 and -fsConfig.VerticalSpacing or -rowGap)
    row.Slot = slot

    row.Name = row:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    row.Name:SetPoint("LEFT", row, "LEFT", 0, 0)
    row.Name:SetWidth(nameWidth)
    row.Name:SetJustifyH("LEFT")
    row.Name:SetWordWrap(false)

    row.SpecElements = false

    if hasSpecDisplay then
        row.SpecElements = BuildSpecDisplay(row)
    end

    -- every control hangs off the row's left centre at a fixed column, so all rows line up
    local buttonAnchor, anchorPoint, x = row, "LEFT", ButtonsX()

    row.RoleButtons = {}

    for _, role in ipairs(roles) do
        local button = BuildRoleButton(row, slot, role, buttonAnchor, anchorPoint, x)
        row.RoleButtons[role] = button
        buttonAnchor, anchorPoint, x = button, "RIGHT", roleButtonGap
    end

    row.SpecItems = {}
    row.SpecKey = false

    -- the shared dropdown cannot show class headings
    row.Spec = wow.CreateFrame("DropdownButton", nil, row, "WowStyle1DropdownTemplate")
    row.Spec:SetupMenu(function(_, rootDescription)
        if rootDescription.SetScrollMode then
            rootDescription:SetScrollMode(specMenuHeight)
        end

        for _, item in ipairs(row.SpecItems) do
            if item.Heading then
                rootDescription:CreateTitle(item.Text)
            else
                rootDescription:CreateRadio(item.Text, function(specId)
                    return specId == (Store():Spec(slot) or noSpec)
                end, function(specId)
                    M:OnSpecSelected(slot, specId)
                end, item.SpecId)
            end
        end
    end)
    row.Spec:SetPoint("LEFT", row, "LEFT", SpecX(), 0)
    row.Spec:SetWidth(specWidth)

    return row
end

-- Escape works in combat this way because the frame is not protected
local function SetClosesOnEscape(frame, closes)
    local list = wow.UISpecialFrames

    if type(list) ~= "table" then
        return
    end

    local name = frame:GetName()

    for i = #list, 1, -1 do
        if list[i] == name then
            table.remove(list, i)
        end
    end

    if closes then
        list[#list + 1] = name
    end
end

local function Build()
    hasSpecDisplay = SpecDisplay() ~= nil

    local frameWidth = padding * 2 + RowWidth()
    local frame = wow.CreateFrame("Frame", "FrameSortEnemyRoles", wow.UIParent, "BackdropTemplate")
    frame:SetFrameStrata("DIALOG")
    frame:SetSize(frameWidth, FrameHeight(fsEnemyAssignments:EnemyCount()))
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function()
        frame:StartMoving()
    end)
    frame:SetScript("OnDragStop", function()
        frame:StopMovingOrSizing()
        SavePoint(frame)
    end)
    RestorePoint(frame)

    -- one Escape closes every special frame, so the window leaves the list while settings are open
    local settings = wow.SettingsPanel
    local canWatchSettings = settings and settings.HookScript and settings.IsVisible
    SetClosesOnEscape(frame, not (canWatchSettings and settings:IsVisible()))

    if canWatchSettings then
        settings:HookScript("OnShow", function()
            SetClosesOnEscape(frame, false)
        end)
        -- the Escape pass that hid settings goes on to hide the listed frames
        settings:HookScript("OnHide", function()
            fsScheduler:RunNextFrame(function()
                if not settings:IsVisible() then
                    SetClosesOnEscape(frame, true)
                end
            end)
        end)
    end

    local close = wow.CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -6, -6)

    local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", frame, "TOPLEFT", padding, -padding)
    title:SetHeight(titleHeight)
    frame.Title = title

    -- fixed heights keep the frame height sum exact
    local hint = fsConfig:TextLine(L["Rows are in arena order, which is how the enemy frames start each round."], frame, title, "GameFontHighlightSmall", -titleGap)
    hint:SetWidth(frameWidth - padding * 2)
    hint:SetHeight(hintHeight)

    if hasSpecDisplay then
        hint = fsConfig:TextLine(L["Click the role that matches the spec shown for each enemy."], frame, hint, "GameFontHighlightSmall", 0)
        hint:SetWidth(frameWidth - padding * 2)
        hint:SetHeight(hintHeight)
    end

    local anchor = hint

    for slot = 1, maxRows do
        local row = BuildRow(frame, slot, anchor)
        rows[slot] = row
        anchor = row
    end

    local popup = wow.CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    popup:SetSize(checkboxHeight, checkboxHeight)
    popup:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", padding - checkboxInset, padding - checkboxInset)
    popup.Text:SetText(" " .. L["Show the enemy roles window at the start of each arena round"])
    popup:SetScript("OnClick", function()
        local options = OptionsTable()

        if options then
            options.PopupEnabled = popup:GetChecked()
            fsConfig:NotifyChanged()
        end
    end)
    frame.Popup = popup

    -- sits on the line above the checkbox so a long label cannot run into it
    local clear = wow.CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    clear:SetSize(80, clearHeight)
    clear:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -padding, padding + checkboxHeight)
    clear:SetText(L["Clear"])
    clear:SetScript("OnClick", function()
        M:OnClear()
    end)

    local combatNote = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    combatNote:SetPoint("LEFT", frame, "BOTTOMLEFT", padding, padding + checkboxHeight + clearHeight / 2)
    combatNote:SetText(L["Frames update when combat ends."])
    frame.CombatNote = combatNote

    -- these only matter while the window is up, so they are registered on show
    local liveEvents = {
        events.ARENA_PREP_OPPONENT_SPECIALIZATIONS,
        events.ARENA_OPPONENT_UPDATE,
        events.UNIT_NAME_UPDATE,
        events.PLAYER_REGEN_DISABLED,
        events.PLAYER_REGEN_ENABLED,
    }

    frame:SetScript("OnEvent", function(_, event, unit)
        M:OnEvent(event, unit)
    end)
    frame:SetScript("OnShow", function()
        for _, event in ipairs(liveEvents) do
            frame:RegisterEvent(event)
        end
    end)
    frame:SetScript("OnHide", function()
        frame:UnregisterAllEvents()
        preview = nil
    end)

    fsConfig:RegisterConfigurationChangedCallback(function()
        M:Refresh()
    end)

    frame:Hide()

    return frame
end

---True on clients where the user marks enemy roles by hand.
---@return boolean
function M:IsAvailable()
    return capabilities.NeedsManualEnemyRoles()
end

---Returns the row's label, which is the name or "Enemy N".
---@param slot number arena slot
---@param name any what UnitName returned for the slot
---@return any label
function M:RowLabel(slot, name)
    -- SetText accepts a secret name as it is
    if wow.issecretvalue(name) then
        return name
    end

    if type(name) ~= "string" or name == "" or name == wow.UNKNOWNOBJECT then
        return string.format(L["Enemy %d"], slot)
    end

    return name
end

---Returns the class id and class file of a unit, each nil when it is secret.
---@param unit string
---@return number|nil classId
---@return string|nil classFile
function M:ReadableClass(unit)
    local _, classFile, classId = wow.UnitClass(unit)

    classId = Readable(classId)
    classFile = Readable(classFile)

    return type(classId) == "number" and classId or nil, type(classFile) == "string" and classFile or nil
end

---Returns the specs a row offers. A class narrows the list only when it is readable.
---@param role string? the role marked on the row
---@param classId any the class id from UnitClass, which may be secret
---@return number[]
function M:SpecChoices(role, classId)
    classId = Readable(classId)

    return fsEnemyAssignments:SpecChoices(role, type(classId) == "number" and classId or nil)
end

---Returns the spec dropdown's entries, with None first and each class's specs under a heading.
---@param role string? only specs of this role
---@param classId number? only specs of this class
---@param picked number? a spec to list even when the filters leave it out
---@return table[] items each { SpecId, Text } for a choice or { Heading, Text } for a class heading
function M:SpecMenuItems(role, classId, picked)
    local items = { { SpecId = noSpec, Text = L["None"] } }
    local groups = {}
    local classIds = {}

    local function Add(specId)
        local info = fsSpec.SpecIdLookup[specId]

        if not info or (groups[info.ClassId] and groups[info.ClassId][specId]) then
            return
        end

        if not groups[info.ClassId] then
            groups[info.ClassId] = {}
            classIds[#classIds + 1] = info.ClassId
        end

        local group = groups[info.ClassId]
        group[specId] = true
        group[#group + 1] = specId
    end

    for _, specId in ipairs(M:SpecChoices(role, classId)) do
        Add(specId)
    end

    -- the radio check only shows on a value the menu lists
    if picked and picked ~= noSpec then
        Add(picked)
    end

    -- class ids keep the same order in every locale
    table.sort(classIds)

    for _, id in ipairs(classIds) do
        local group = groups[id]
        table.sort(group)
        items[#items + 1] = { Heading = true, Text = ClassHeading(id) }

        for _, specId in ipairs(group) do
            items[#items + 1] = { SpecId = specId, Text = SpecText(specId) }
        end
    end

    return items
end

---@return number rows the number of enemies the window lists
function M:RowCount()
    if preview then
        return #previewEnemies
    end

    return fsEnemyAssignments:EnemyCount()
end

---Marks a row with a role, or clears it when the role is already the user's mark.
---@param slot number arena slot
---@param role string
function M:OnRoleClick(slot, role)
    local store = Store()

    if store:Role(slot) ~= role then
        store:Set(slot, role)
    elseif store:IsFilled(slot) then
        store:Set(slot, role)

        -- confirming changes no mark, so no change callback redraws the row
        M:Refresh()
    else
        store:Set(slot, nil)
    end
end

---@param slot number arena slot
---@param specId number a spec id, or 0 to drop the spec and keep the role
function M:OnSpecSelected(slot, specId)
    if specId == noSpec then
        Store():ClearSpec(slot)
    else
        Store():Set(slot, nil, specId)
    end
end

function M:OnClear()
    Store():Clear()
end

---@param event string
---@param unit string? the unit the event is about
function M:OnEvent(event, unit)
    if event == events.UNIT_NAME_UPDATE and not (type(unit) == "string" and fsEnemyAssignments:SlotForUnit(unit)) then
        return
    end

    -- the regen disabled event fires before combat lockdown starts
    local inCombat = nil

    if event == events.PLAYER_REGEN_DISABLED then
        inCombat = true
    elseif event == events.PLAYER_REGEN_ENABLED then
        inCombat = false
    end

    M:Refresh(inCombat)
end

---Redraws every row from the current marks.
---@param inCombat boolean? overrides the combat check
function M:Refresh(inCombat)
    if not window then
        return
    end

    if inCombat == nil then
        inCombat = wow.InCombatLockdown()
    end

    local count = M:RowCount()

    for i, row in ipairs(rows) do
        row:SetShown(i <= count)

        if i <= count then
            RefreshRow(row)
        end
    end

    window.Title:SetText(string.format(L["FrameSort - %s"], preview and L["Enemy roles (preview)"] or L["Enemy roles"]))

    local options = OptionsTable()
    window.Popup:SetChecked(options ~= nil and options.PopupEnabled == true)
    window.CombatNote:SetShown(inCombat)
    window:SetHeight(FrameHeight(count))
end

---Shows the window, building it on first use.
---@return boolean shown false on clients that read enemy specs themselves or have no enemy spec support
function M:Show()
    if not M:IsAvailable() then
        return false
    end

    preview = nil
    window = window or Build()
    window:Show()
    M:Refresh()

    return true
end

---Shows the window with made up enemies whose marks are thrown away, for checking the layout.
---@return boolean shown false where the window is not available
function M:ShowPreview()
    if not M:IsAvailable() then
        return false
    end

    window = window or Build()
    preview = {}
    window:Show()
    M:Refresh()

    return true
end

---Shows the real window in an arena and the preview elsewhere, where there are no enemies to mark.
---@return boolean shown false where the window is not available
function M:OpenForCurrentContext()
    if wowEx.IsInstanceArena() then
        return M:Show()
    end

    return M:ShowPreview()
end

function M:Hide()
    if window then
        window:Hide()
    end
end

---@return boolean shown whether the window is now showing
function M:Toggle()
    if window and window:IsShown() then
        M:Hide()
        return false
    end

    return M:OpenForCurrentContext()
end

function M:Init()
    fsEnemyAssignments:RegisterPromptCallback(function(visible)
        if visible then
            M:Show()
        else
            M:Hide()
        end
    end)

    fsEnemyAssignments:RegisterCallback(function()
        if window and window:IsShown() then
            M:Refresh()
        end
    end)
end
