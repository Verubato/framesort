---@diagnostic disable: duplicate-set-field

---@type Addon
local addon
local wow
---@type EnemyAssignmentsWindow
local window
local M = {}

local paladin = 2
local holyPaladin = 65
local restoDruid = 105

local Healer = "HEALER"
local Tank = "TANK"
local Dps = "DAMAGER"

-- a table stands in for a secret value that errors when concatenated
local secretName = setmetatable({}, {
    __concat = function()
        error("concatenated a secret")
    end,
})

local secrets = {}

local function setBuild(build)
    wow.GetBuildInfo = function()
        return "x", "0", "0", build
    end
end

local function windowFrame()
    for _, frame in ipairs(wow.State.Frames) do
        if frame:GetName() == "FrameSortEnemyRoles" then
            return frame
        end
    end

    return nil
end

local function rowFrame(slot)
    for _, frame in ipairs(wow.State.Frames) do
        if rawget(frame, "Slot") == slot then
            return frame
        end
    end

    return nil
end

local function shownRecorder()
    return {
        SetShown = function(self, shown)
            self.Shown = shown
        end,
    }
end

local function iconRecorder()
    return {
        SetDesaturated = function() end,
        SetAlpha = function(self, alpha)
            self.Alpha = alpha
        end,
    }
end

local function specDisplayRecorder()
    local calls = {}

    wow.UnitFrameUtil = {
        UpdateArenaOpponentSpecDisplay = function(elements, arenaIndex)
            calls[#calls + 1] = { Elements = elements, Index = arenaIndex }
        end,
    }

    return calls
end

-- reduces menu items to spec ids, and headings to "H" plus their text
local function menuShape(items)
    local shape = {}

    for _, item in ipairs(items) do
        shape[#shape + 1] = item.Heading and "H" .. item.Text or item.SpecId
    end

    return shape
end

-- keeps the generator each spec dropdown is given, since the mock never runs it
local function menuRecorder()
    local create = wow.CreateFrame

    wow.CreateFrame = function(frameType, ...)
        local frame = create(frameType, ...)

        if frameType == "DropdownButton" then
            frame.Generated = 0
            frame.SetupMenu = function(self, generator)
                self.Generator = generator
            end
            frame.GenerateMenu = function(self)
                self.Generated = self.Generated + 1
            end
        end

        return frame
    end
end

local function openMenu(slot)
    local entries = {}
    local root = {
        SetScrollMode = function(_, height)
            entries.ScrollHeight = height
        end,
        CreateTitle = function(_, text)
            entries[#entries + 1] = { Title = text }
        end,
        CreateRadio = function(_, text, isSelected, select, value)
            entries[#entries + 1] = {
                Text = text,
                Value = value,
                Selected = isSelected(value),
                Select = function()
                    select(value)
                end,
            }
        end,
    }

    rowFrame(slot).Spec.Generator(nil, root)

    return entries
end

local function selectedValues(entries)
    local values = {}

    for _, entry in ipairs(entries) do
        if entry.Selected then
            values[#values + 1] = entry.Value
        end
    end

    return values
end

local function windowFrames()
    local found = 0

    for _, frame in ipairs(wow.State.Frames) do
        if frame:GetName() == "FrameSortEnemyRoles" then
            found = found + 1
        end
    end

    return found
end

function M:setup()
    local addonFactory = require("TestHarness.AddonFactory")

    addon = addonFactory:Create()
    wow = addon.WoW.Api
    window = addon.Modules.EnemyAssignmentsWindow
    secrets = {}

    addon.Locale:Init()

    wow.issecretvalue = function(value)
        return value ~= nil and secrets[value] == true
    end
    wow.GetArenaOpponentSpec = function() end
    wow.GetNumArenaOpponentSpecs = function()
        return 3
    end
    wow.GetNumGroupMembers = function()
        return 3
    end
    wow.UnitClass = function()
        return "Paladin", "PALADIN", paladin
    end
    addon.WoW.Capabilities.HasSpecializations = function()
        return true
    end

    setBuild(120105)
end

function M:teardown()
    addon = nil
    wow = nil
    window = nil
end

function M:test_row_label_uses_a_readable_name()
    assertEquals(window:RowLabel(1, "Bob"), "Bob")
end

function M:test_row_label_passes_a_secret_name_through_untouched()
    secrets[secretName] = true

    assertEquals(window:RowLabel(2, secretName) == secretName, true)
end

function M:test_row_label_falls_back_to_the_slot_without_a_name()
    assertEquals(window:RowLabel(3, nil), "Enemy 3")
end

function M:test_spec_choices_narrow_by_a_readable_class()
    assertEquals(window:SpecChoices("HEALER", paladin), { holyPaladin })
end

function M:test_spec_choices_list_every_spec_of_the_role_when_the_class_is_secret()
    secrets[paladin] = true

    local choices = window:SpecChoices("HEALER", paladin)

    assertEquals(choices, addon.Modules.EnemyAssignments:SpecChoices("HEALER"))
    assertEquals(#choices > 1, true)
end

function M:test_spec_menu_lists_none_then_each_class_in_class_id_order()
    assertEquals(menuShape(window:SpecMenuItems("HEALER")), {
        0,
        "H2", holyPaladin,
        "H5", 256, 257,
        "H7", 264,
        "H10", 270,
        "H11", restoDruid,
        "H13", 1468,
    })
end

function M:test_spec_menu_heads_only_the_classes_it_lists()
    local headings = {}

    for _, item in ipairs(window:SpecMenuItems("TANK")) do
        if item.Heading then
            headings[#headings + 1] = item.Text
        end
    end

    assertEquals(headings, { "1", "2", "6", "10", "11", "12" })
end

function M:test_spec_menu_sorts_a_class_by_spec_id()
    assertEquals(menuShape(window:SpecMenuItems(nil, paladin)), { 0, "H2", holyPaladin, 66, 70 })
end

function M:test_spec_menu_for_a_readable_class_has_one_group()
    assertEquals(menuShape(window:SpecMenuItems("HEALER", paladin)), { 0, "H2", holyPaladin })
end

function M:test_spec_menu_lists_a_picked_spec_outside_the_class()
    assertEquals(menuShape(window:SpecMenuItems("HEALER", paladin, restoDruid)), { 0, "H2", holyPaladin, "H11", restoDruid })
end

function M:test_spec_menu_colours_headings_and_shows_spec_icons()
    wow.GetClassInfo = function()
        return "Paladin", "PALADIN", paladin
    end
    wow.RAID_CLASS_COLORS = { PALADIN = { r = 1, g = 0.5, b = 0 } }
    wow.GetSpecializationInfoByID = function(specId)
        return specId, "Holy", "", 135920
    end

    local items = window:SpecMenuItems("HEALER", paladin)

    assertEquals(items[1].Text, "None")
    assertEquals(items[2].Text, "|cffff7f00Paladin|r")
    assertEquals(items[3].Text, "|T135920:16:16|t Holy")
end

function M:test_readable_class_hides_a_secret_class()
    assertEquals({ window:ReadableClass("arena1") }, { paladin, "PALADIN" })

    secrets[paladin] = true
    secrets["PALADIN"] = true

    assertEquals({ window:ReadableClass("arena1") }, {})
end

function M:test_row_count_follows_the_enemy_team_and_caps_at_five()
    assertEquals(window:RowCount(), 3)

    wow.GetNumArenaOpponentSpecs = function()
        return 8
    end

    assertEquals(window:RowCount(), 5)
end

function M:test_row_count_falls_back_to_the_group_size_when_specs_are_missing()
    wow.GetNumArenaOpponentSpecs = function()
        return 0
    end
    wow.GetNumGroupMembers = function()
        return 2
    end

    assertEquals(window:RowCount(), 2)
end

function M:test_window_opens_on_12_1_5()
    assertEquals(window:Show(), true)
    assertEquals(windowFrames(), 1)
end

function M:test_window_never_builds_on_12_1_0()
    setBuild(120100)

    assertEquals(window:Show(), false)
    assertEquals(window:Toggle(), false)
    assertEquals(windowFrames(), 0)
end

function M:test_window_never_builds_on_clients_without_enemy_specs()
    wow.GetArenaOpponentSpec = nil

    assertEquals(window:Show(), false)
    assertEquals(windowFrames(), 0)
end

function M:test_the_prompt_opens_the_window()
    window:Init()
    addon.DB.Options.EnemyAssignments.PopupEnabled = true
    addon.WoW.WowEx.MockInstance(true, "arena")

    addon.Modules.EnemyAssignments:ProcessEvent(addon.WoW.Events.ARENA_PREP_OPPONENT_SPECIALIZATIONS)

    addon.WoW.WowEx.ClearMockInstance()
    assertEquals(windowFrames(), 1)
    assertEquals(windowFrame():IsVisible(), true)
end

function M:test_the_prompt_stays_closed_when_the_popup_option_is_off()
    window:Init()
    window:Show()
    window:Hide()
    addon.DB.Options.EnemyAssignments.PopupEnabled = false
    addon.WoW.WowEx.MockInstance(true, "arena")

    addon.Modules.EnemyAssignments:ProcessEvent(addon.WoW.Events.ARENA_PREP_OPPONENT_SPECIALIZATIONS)

    addon.WoW.WowEx.ClearMockInstance()
    assertEquals(windowFrame():IsVisible(), false)
end

function M:test_clicking_a_role_marks_the_row_and_clicking_it_again_clears_it()
    window:OnRoleClick(1, Tank)
    assertEquals(addon.Modules.EnemyAssignments:Role(1), Tank)

    window:OnRoleClick(1, Healer)
    assertEquals(addon.Modules.EnemyAssignments:Role(1), Healer)

    window:OnRoleClick(1, Healer)
    assertEquals(addon.Modules.EnemyAssignments:Role(1), nil)
end

function M:test_clicking_the_role_of_a_filled_row_confirms_it()
    local marks = addon.Modules.EnemyAssignments
    window:Show()
    marks:Set(2, Healer)
    local icon = iconRecorder()
    rowFrame(1).RoleButtons[Dps].Icon = icon

    window:OnRoleClick(1, Dps)

    assertEquals(marks:Role(1), Dps)
    assertEquals(marks:IsFilled(1), false)
    assertEquals(icon.Alpha, 1)
end

function M:test_a_filled_row_shows_its_role_dimmed()
    window:Show()
    local filledIcon = iconRecorder()
    local userIcon = iconRecorder()
    rowFrame(1).RoleButtons[Dps].Icon = filledIcon
    rowFrame(2).RoleButtons[Healer].Icon = userIcon

    addon.Modules.EnemyAssignments:Set(2, Healer)
    window:Refresh()

    assertEquals(filledIcon.Alpha, 0.6)
    assertEquals(userIcon.Alpha, 1)
end

function M:test_picking_a_spec_sets_it_and_none_keeps_the_role()
    local marks = addon.Modules.EnemyAssignments

    window:OnSpecSelected(1, holyPaladin)
    assertEquals(marks:Spec(1), holyPaladin)
    assertEquals(marks:Role(1), Healer)

    window:OnSpecSelected(1, 0)
    assertEquals(marks:Spec(1), nil)
    assertEquals(marks:Role(1), Healer)
end

function M:test_the_dropdown_lists_a_picked_spec_outside_the_readable_class()
    window:Show()
    addon.Modules.EnemyAssignments:Set(1, nil, restoDruid)
    window:Refresh()

    local items = rowFrame(1).SpecItems
    assertEquals(items[#items].SpecId, restoDruid)
end

function M:test_the_spec_menu_shows_headings_as_titles_and_scrolls()
    secrets[paladin] = true
    menuRecorder()
    window:Show()
    local headings = 0

    for _, item in ipairs(rowFrame(1).SpecItems) do
        if item.Heading then
            headings = headings + 1
        end
    end

    local entries = openMenu(1)
    local titles = 0

    for _, entry in ipairs(entries) do
        if entry.Title then
            titles = titles + 1
        else
            assertEquals(entry.Value ~= nil, true)
        end
    end

    assertEquals(headings > 1, true)
    assertEquals(titles, headings)
    assertEquals(entries.ScrollHeight, 400)
end

function M:test_the_spec_menu_regenerates_only_when_its_entries_change()
    menuRecorder()
    window:Show()
    local dropdown = rowFrame(1).Spec
    local before = dropdown.Generated

    window:Refresh()
    assertEquals(dropdown.Generated, before)

    addon.Modules.EnemyAssignments:Set(1, nil, holyPaladin)
    window:Refresh()
    assertEquals(dropdown.Generated, before + 1)
end

function M:test_the_spec_menu_checks_the_marked_spec_and_marks_a_pick()
    menuRecorder()
    window:Show()
    local marks = addon.Modules.EnemyAssignments

    assertEquals(selectedValues(openMenu(1)), { 0 })

    for _, entry in ipairs(openMenu(1)) do
        if entry.Value == holyPaladin then
            entry.Select()
        end
    end

    assertEquals(marks:Spec(1), holyPaladin)
    assertEquals(selectedValues(openMenu(1)), { holyPaladin })
end

function M:test_the_combat_note_shows_as_combat_starts()
    window:Show()
    local note = shownRecorder()
    windowFrame().CombatNote = note

    window:OnEvent(addon.WoW.Events.PLAYER_REGEN_DISABLED)
    assertEquals(note.Shown, true)

    window:OnEvent(addon.WoW.Events.PLAYER_REGEN_ENABLED)
    assertEquals(note.Shown, false)
end

function M:test_name_updates_only_refresh_for_arena_units()
    window:Show()
    local note = shownRecorder()
    windowFrame().CombatNote = note

    window:OnEvent(addon.WoW.Events.UNIT_NAME_UPDATE, "party1")
    assertEquals(note.Shown, nil)

    window:OnEvent(addon.WoW.Events.UNIT_NAME_UPDATE, "arena2")
    assertEquals(note.Shown, false)
end

function M:test_refresh_hands_each_row_to_the_spec_display()
    local calls = specDisplayRecorder()

    window:Show()

    assertEquals(#calls, 3)

    for i, call in ipairs(calls) do
        local elements = rowFrame(i).SpecElements
        assertEquals(call.Index, i)
        assertEquals(call.Elements == elements, true)
        assertEquals(elements.specPortrait ~= nil, true)
        assertEquals(elements.specNameText ~= nil, true)
        assertEquals(elements.classNameText ~= nil, true)
        assertEquals(elements.roleIcon ~= nil, true)
    end
end

function M:test_refresh_skips_the_spec_display_once_it_is_gone()
    local calls = specDisplayRecorder()
    window:Show()
    local before = #calls

    wow.UnitFrameUtil = nil
    window:Refresh()

    assertEquals(#calls, before)
end

function M:test_a_window_built_without_the_spec_display_never_calls_it()
    window:Show()
    assertEquals(rowFrame(1).SpecElements, false)

    local calls = specDisplayRecorder()
    window:Refresh()

    assertEquals(#calls, 0)
end

local function playPreview()
    window:ShowPreview()
    window:OnRoleClick(1, Healer)
    window:OnRoleClick(2, Dps)
    window:OnSpecSelected(3, 260)
    window:OnSpecSelected(3, 0)
    window:OnRoleClick(3, Dps)
    window:OnClear()
end

function M:test_the_preview_never_sets_or_clears_the_real_marks()
    local marks = addon.Modules.EnemyAssignments
    local calls = 0

    for _, name in ipairs({ "Set", "Clear", "ClearSpec" }) do
        local original = marks[name]
        marks[name] = function(...)
            calls = calls + 1
            return original(...)
        end
    end

    playPreview()

    assertEquals(calls, 0)
end

function M:test_the_preview_leaves_the_real_marks_alone()
    local marks = addon.Modules.EnemyAssignments
    marks:Set(1, Tank)
    local changes = 0
    marks:RegisterCallback(function()
        changes = changes + 1
    end)

    playPreview()

    assertEquals(marks:Role(1), Tank)
    assertEquals(marks:Role(2), nil)
    assertEquals(changes, 0)
end

function M:test_the_preview_fills_the_team_from_the_healer()
    window:ShowPreview()
    local icon = iconRecorder()
    rowFrame(2).RoleButtons[Dps].Icon = icon

    window:OnRoleClick(1, Healer)

    assertEquals(icon.Alpha, 0.6)
end

function M:test_opening_in_an_arena_shows_the_real_window()
    addon.WoW.WowEx.MockInstance(true, "arena")

    assertEquals(window:OpenForCurrentContext(), true)
    window:OnRoleClick(1, Tank)

    addon.WoW.WowEx.ClearMockInstance()
    assertEquals(windowFrame():IsVisible(), true)
    assertEquals(addon.Modules.EnemyAssignments:Role(1), Tank)
end

function M:test_opening_outside_an_arena_shows_the_preview()
    addon.WoW.WowEx.MockInstance(false, "none")

    assertEquals(window:OpenForCurrentContext(), true)
    window:OnRoleClick(1, Tank)

    addon.WoW.WowEx.ClearMockInstance()
    assertEquals(windowFrame():IsVisible(), true)
    assertEquals(addon.Modules.EnemyAssignments:Role(1), nil)
end

function M:test_the_preview_dropdown_reads_the_preview_spec()
    menuRecorder()
    addon.Modules.EnemyAssignments:Set(1, nil, holyPaladin)

    window:ShowPreview()
    window:OnSpecSelected(1, restoDruid)

    assertEquals(selectedValues(openMenu(1)), { restoDruid })
end

function M:test_the_preview_shows_the_spec_elements_it_fills()
    specDisplayRecorder()
    window:ShowPreview()
    local shown = {}
    local elements = {}

    for _, name in ipairs({ "specPortrait", "specNameText", "classNameText", "roleIcon" }) do
        elements[name] = {
            Show = function()
                shown[name] = true
            end,
            SetShown = function(_, value)
                shown[name] = value
            end,
            SetTexture = function() end,
            SetText = function() end,
            SetSize = function() end,
            SetTexCoord = function() end,
        }
    end
    rowFrame(1).SpecElements = elements

    window:Refresh()

    assertEquals(shown.specPortrait, true)
    assertEquals(shown.specNameText, true)
    assertEquals(shown.classNameText, true)
end

function M:test_the_window_height_follows_the_row_count()
    window:Show()
    local frame = windowFrame()
    local height
    frame.SetHeight = function(_, value)
        height = value
    end

    window:Refresh()
    local three = height

    wow.GetNumArenaOpponentSpecs = function()
        return 2
    end
    wow.GetNumGroupMembers = function()
        return 2
    end
    window:Refresh()
    local two = height

    window:ShowPreview()

    assertEquals(two < three, true)
    assertEquals(height, three)
end

local function fireHooks(frame, event)
    for _, hook in ipairs(frame.State.ScriptHooks) do
        if hook.Event == event then
            hook.Callback(frame)
        end
    end
end

local function closesOnEscape()
    for _, name in ipairs(wow.UISpecialFrames) do
        if name == "FrameSortEnemyRoles" then
            return true
        end
    end

    return false
end

function M:test_escape_leaves_the_window_open_while_settings_are_open()
    local pending = {}
    wow.C_Timer.After = function(_, callback)
        pending[#pending + 1] = callback
    end
    wow.UISpecialFrames = {}
    wow.SettingsPanel = wow.CreateFrame("Frame")
    wow.SettingsPanel:Hide()
    window:Show()

    assertEquals(closesOnEscape(), true)

    wow.SettingsPanel:Show()
    fireHooks(wow.SettingsPanel, "OnShow")
    assertEquals(closesOnEscape(), false)

    wow.SettingsPanel:Hide()
    fireHooks(wow.SettingsPanel, "OnHide")
    assertEquals(closesOnEscape(), false)

    for _, callback in ipairs(pending) do
        callback()
    end

    assertEquals(closesOnEscape(), true)
end

function M:test_settings_reopened_before_the_next_frame_keep_the_window_off_the_list()
    local pending = {}
    wow.C_Timer.After = function(_, callback)
        pending[#pending + 1] = callback
    end
    wow.UISpecialFrames = {}
    wow.SettingsPanel = wow.CreateFrame("Frame")
    wow.SettingsPanel:Show()
    window:Show()

    wow.SettingsPanel:Hide()
    fireHooks(wow.SettingsPanel, "OnHide")
    wow.SettingsPanel:Show()
    fireHooks(wow.SettingsPanel, "OnShow")

    for _, callback in ipairs(pending) do
        callback()
    end

    assertEquals(closesOnEscape(), false)
end

function M:test_a_window_built_while_settings_are_open_waits_to_close_on_escape()
    wow.UISpecialFrames = {}
    wow.SettingsPanel = wow.CreateFrame("Frame")
    wow.SettingsPanel:Show()

    window:OpenForCurrentContext()

    assertEquals(closesOnEscape(), false)
end

function M:test_the_real_prompt_leaves_the_preview()
    window:Init()
    window:ShowPreview()
    addon.DB.Options.EnemyAssignments.PopupEnabled = true
    addon.WoW.WowEx.MockInstance(true, "arena")

    addon.Modules.EnemyAssignments:ProcessEvent(addon.WoW.Events.ARENA_PREP_OPPONENT_SPECIALIZATIONS)
    window:OnRoleClick(1, Tank)

    addon.WoW.WowEx.ClearMockInstance()
    assertEquals(addon.Modules.EnemyAssignments:Role(1), Tank)
end

return M
