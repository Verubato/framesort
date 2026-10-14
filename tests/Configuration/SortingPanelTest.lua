---@type Addon
local addon
local wow
local panel
local M = {}

local enemyArenaLabel = "Enemy Arena (see addons panel for supported addons)"
local popupLabel = "Show the enemy roles window at the start of each arena round"

local function setBuild(build)
    wow.GetBuildInfo = function()
        return "x", "0", "0", build
    end
end

function M:setup()
    local addonFactory = require("TestHarness.AddonFactory")

    addon = addonFactory:Create()
    wow = addon.WoW.Api
    panel = addon.Configuration.Panels.Sorting

    addon.Locale:Init()

    wow.GetArenaOpponentSpec = function() end
    wow.GetNumArenaOpponentSpecs = function()
        return 0
    end
end

function M:teardown()
    addon = nil
    panel = nil
end

local function checkboxShown(label)
    local text = " " .. addon.Locale.Current[label]

    for _, frame in ipairs(wow.State.Frames) do
        if frame.Type == "CheckButton" and frame.State.Text == text then
            return true
        end
    end

    return false
end

local function popupVisible()
    local text = " " .. addon.Locale.Current[popupLabel]

    for _, frame in ipairs(wow.State.Frames) do
        if frame.Type == "CheckButton" and frame.State.Text == text then
            return frame:IsVisible()
        end
    end

    return nil
end

local function openButton()
    local text = addon.Locale.Current["Open enemy roles window"]

    for _, frame in ipairs(wow.State.Frames) do
        if frame.Type == "Button" and frame.State.Text == text then
            return frame
        end
    end

    return nil
end

local function build()
    panel:Build(wow.CreateFrame("Frame"))

    return checkboxShown(enemyArenaLabel), checkboxShown(popupLabel)
end

function M:test_enemy_arena_row_shows_on_12_1_0()
    setBuild(120100)

    assertEquals(panel:ShowsEnemyArena(), true)
    assertEquals(panel:ShowsEnemyRoles(), false)
    assertEquals({ build() }, { true, false })
end

function M:test_enemy_arena_row_and_popup_option_show_on_12_1_5()
    setBuild(120105)
    addon.DB.Options.Sorting.EnemyArena.Enabled = true

    assertEquals(panel:ShowsEnemyArena(), true)
    assertEquals(panel:ShowsEnemyRoles(), true)
    assertEquals({ build() }, { true, true })
end

function M:test_mists_classic_reads_specs_so_has_no_popup_option()
    setBuild(50504)

    assertEquals(panel:ShowsEnemyArena(), true)
    assertEquals(panel:ShowsEnemyRoles(), false)
    assertEquals({ build() }, { true, false })
end

function M:test_clients_without_enemy_specs_show_neither()
    wow.GetArenaOpponentSpec = nil
    setBuild(120105)

    assertEquals(panel:ShowsEnemyArena(), false)
    assertEquals(panel:ShowsEnemyRoles(), false)
    assertEquals({ build() }, { false, false })
end

function M:test_the_popup_option_shows_while_enemy_arena_sorting_is_on()
    setBuild(120105)
    addon.DB.Options.Sorting.EnemyArena.Enabled = true

    build()

    assertEquals(popupVisible(), true)
end

function M:test_the_popup_option_hides_while_enemy_arena_sorting_is_off()
    setBuild(120105)
    addon.DB.Options.Sorting.EnemyArena.Enabled = false

    build()

    assertEquals(popupVisible(), false)
end

function M:test_the_popup_option_follows_enemy_arena_sorting_after_a_change()
    setBuild(120105)
    addon.DB.Options.Sorting.EnemyArena.Enabled = true
    build()

    addon.DB.Options.Sorting.EnemyArena.Enabled = false
    addon.Configuration:NotifyChanged()
    assertEquals(popupVisible(), false)

    addon.DB.Options.Sorting.EnemyArena.Enabled = true
    addon.Configuration:NotifyChanged()
    assertEquals(popupVisible(), true)
end

function M:test_the_popup_option_is_never_created_on_12_1_0()
    setBuild(120100)
    addon.DB.Options.Sorting.EnemyArena.Enabled = true

    build()

    assertEquals(popupVisible(), nil)
end

function M:test_the_open_button_follows_enemy_arena_sorting()
    setBuild(120105)
    addon.DB.Options.Sorting.EnemyArena.Enabled = true
    build()

    assertEquals(openButton():IsVisible(), true)

    addon.DB.Options.Sorting.EnemyArena.Enabled = false
    addon.Configuration:NotifyChanged()

    assertEquals(openButton():IsVisible(), false)
end

function M:test_the_open_button_opens_the_window_for_the_current_context()
    setBuild(120105)
    addon.DB.Options.Sorting.EnemyArena.Enabled = true
    local opened = 0
    addon.Modules.EnemyAssignmentsWindow.OpenForCurrentContext = function()
        opened = opened + 1
        return true
    end
    build()

    for _, hook in ipairs(openButton().State.ScriptHooks) do
        if hook.Event == "OnClick" then
            hook.Callback()
        end
    end

    assertEquals(opened, 1)
end

return M
