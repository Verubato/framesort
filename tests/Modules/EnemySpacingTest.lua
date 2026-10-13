---@diagnostic disable: duplicate-set-field, cast-local-type

---@type Addon
local addon
---@type SortingModule
local fsSort
local provider
local arenaContainer
local frames = {}
local M = {}

local frameWidth = 100
local frameHeight = 50

local function setBuild(build)
    addon.WoW.Api.GetBuildInfo = function()
        return "x", "0", "0", build
    end
end

-- arena3 sits on top, so a correct layout has to move it to the bottom
local function seedReversed()
    for i, f in ipairs(frames) do
        f:SetSize(frameWidth, frameHeight)
        f:SetPoint("TOPLEFT", arenaContainer, "TOPLEFT", 0, -(#frames - i) * frameHeight)
    end
end

local function yOffsets()
    local out = {}
    for i, f in ipairs(frames) do
        out[i] = f.State.Point.YOffset
    end
    return out
end

function M:setup()
    local addonFactory = require("TestHarness.AddonFactory")
    local providerFactory = require("TestHarness.ProviderFactory")
    local frameMock = require("TestHarness.FrameMock")
    local fsFrame

    addon = addonFactory:Create()
    fsSort = addon.Modules.Sorting
    fsFrame = addon.WoW.Frame

    provider = providerFactory:Create()
    provider.Name = function()
        return "Blizzard"
    end
    addon.Providers.Test = provider
    addon.Providers.All[#addon.Providers.All + 1] = provider

    local arena = fsFrame:GetContainer(provider, fsFrame.ContainerType.EnemyArena)
    assert(arena)
    arenaContainer = arena.Frame

    frames = {}
    for i = 1, 3 do
        local f = frameMock:New("Frame", nil, arenaContainer)
        f.unit = "arena" .. i
        frames[i] = f
    end

    local wow = addon.WoW.Api
    wow.IsInInstance = function()
        return true, "arena"
    end
    wow.UnitExists = function(unit)
        return string.match(unit or "", "^arena%d$") ~= nil
    end

    local options = addon.DB.Options
    options.Sorting.Arena.Default.Enabled = false
    options.Sorting.Arena.Twos.Enabled = false
    options.Sorting.EnemyArena.Enabled = false
    options.Spacing.EnemyArena.Vertical = 10
    options.Spacing.EnemyArena.Horizontal = 0

    setBuild(120105)
    seedReversed()
end

function M:teardown()
    addon = nil
    fsSort = nil
    provider = nil
    arenaContainer = nil
    frames = {}
end

function M:test_spacing_lays_frames_out_in_arena_order_when_specs_are_unreadable()
    fsSort:Run()

    local step = frameHeight + 10
    assertEquals(yOffsets(), { 0, -step, -2 * step })
end

function M:test_spacing_ignores_the_saved_enemy_sort_options_when_specs_are_unreadable()
    local config = addon.DB.Options.Sorting.EnemyArena
    config.GroupSortMode = addon.Configuration.GroupSortMode.Alphabetical
    config.Reverse = true

    fsSort:Run()

    local step = frameHeight + 10
    assertEquals(yOffsets(), { 0, -step, -2 * step })
end

function M:test_nothing_moves_when_enemy_spacing_is_zero()
    addon.DB.Options.Spacing.EnemyArena.Vertical = 0

    local before = yOffsets()
    fsSort:Run()

    assertEquals(yOffsets(), before)
end

function M:test_providers_other_than_blizzard_are_not_moved_even_if_they_support_spacing()
    provider.Name = function()
        return "ElvUI"
    end

    local before = yOffsets()
    fsSort:Run()

    assertEquals(yOffsets(), before)
end

function M:test_spacing_is_not_applied_without_sorting_when_specs_are_readable()
    setBuild(120100)

    local before = yOffsets()
    fsSort:Run()

    assertEquals(yOffsets(), before)
end

function M:test_marked_roles_sort_providers_other_than_blizzard_when_enemy_sorting_is_on()
    provider.Name = function()
        return "ElvUI"
    end
    addon.WoW.Capabilities.HasEnemySpecSupport = function()
        return true
    end
    -- the run would sort twice, and this test calls it itself
    addon.Modules.Run = function() end
    local config = addon.DB.Options.Sorting.EnemyArena
    config.Enabled = true
    config.GroupSortMode = addon.Configuration.GroupSortMode.Role
    local marks = addon.Modules.EnemyAssignments
    marks:Set(1, "DAMAGER")
    marks:Set(2, "DAMAGER")
    marks:Set(3, "TANK")

    fsSort:Run()

    local step = frameHeight + 10
    assertEquals(yOffsets(), { -step, -2 * step, 0 })
end

return M
