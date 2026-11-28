---@diagnostic disable: duplicate-set-field, cast-local-type

---@type Addon
local addon
local wow
local events
---@type SortedUnits
local fsSortedUnits
local M = {}

function M:setup()
    local addonFactory = require("TestHarness.AddonFactory")

    addon = addonFactory:Create()
    wow = addon.WoW.Api
    events = addon.WoW.Events
    fsSortedUnits = addon.Modules.Sorting.SortedUnits

    addon.Modules:Init()
end

function M:teardown()
    addon = nil
    wow = nil
    events = nil
    fsSortedUnits = nil
end

function M:test_combat_starting_invalidates_the_friendly_cache_before_loading_units()
    local invalidated = 0
    local invalidatedWhenLoaded = nil
    local originalInvalidate = fsSortedUnits.InvalidateFriendlyCache
    local originalFriendlyUnits = fsSortedUnits.FriendlyUnits

    fsSortedUnits.InvalidateFriendlyCache = function(...)
        invalidated = invalidated + 1
        return originalInvalidate(...)
    end

    fsSortedUnits.FriendlyUnits = function(...)
        invalidatedWhenLoaded = invalidatedWhenLoaded or invalidated
        return originalFriendlyUnits(...)
    end

    wow.FireEvent(events.PLAYER_REGEN_DISABLED)

    assert(invalidated == 1)
    assert(invalidatedWhenLoaded == 1)
end

function M:test_combat_starting_loads_enemy_spacing_only_from_the_sort_mode()
    addon.DB.Options.Sorting.Method = addon.Configuration.SortingMethod.Secure
    addon.Modules.Sorting.Secure:Init()
    addon.Modules.Sorting.Comparer.EnemySortMode = function()
        return true, "Group", false, true
    end

    local manager
    for _, frame in ipairs(wow.State.Frames) do
        if frame:GetAttribute("_onstate-framesort-run") then
            manager = frame
        end
    end
    assert(manager)

    -- the mock frame ignores this call, so record it
    local loaded = {}
    manager.SetAttributeNoHandler = function(_, name, value)
        loaded[name] = value
    end

    wow.FireEvent(events.PLAYER_REGEN_DISABLED)

    assertEquals(loaded.EnemySortEnabled, true)
    assertEquals(loaded.EnemySpacingOnly, true)
end

function M:test_combat_starting_loads_the_marked_enemy_order_and_role_sort_mode()
    addon.DB.Options.Sorting.Method = addon.Configuration.SortingMethod.Secure
    addon.Modules.Sorting.Secure:Init()
    addon.WoW.Capabilities.HasEnemySpecSupport = function()
        return true
    end
    wow.GetBuildInfo = function()
        return "x", "0", "0", 120105
    end
    addon.WoW.WowEx.MockInstance(true, "arena")
    addon.WoW.Unit.ArenaUnits = function()
        return { "arena1", "arena2", "arena3" }
    end
    local config = addon.DB.Options.Sorting.EnemyArena
    config.Enabled = true
    config.GroupSortMode = addon.Configuration.GroupSortMode.Role

    local manager
    for _, frame in ipairs(wow.State.Frames) do
        if frame:GetAttribute("_onstate-framesort-run") then
            manager = frame
        end
    end
    assert(manager)

    -- the mock frame ignores this call, so record it
    local loaded = {}
    manager.SetAttributeNoHandler = function(_, name, value)
        loaded[name] = value
    end

    -- the run would re-sort real frames, which this test has none of
    addon.Modules.Run = function() end
    -- the cache is filled first so only a mark change can empty it
    fsSortedUnits:ArenaUnits()
    local marks = addon.Modules.EnemyAssignments
    marks:Set(1, "DAMAGER")
    marks:Set(2, "HEALER")
    marks:Set(3, "TANK")

    wow.FireEvent(events.PLAYER_REGEN_DISABLED)
    addon.WoW.WowEx.ClearMockInstance()

    assertEquals(loaded.EnemySortEnabled, true)
    assertEquals(loaded.EnemyGroupSortMode, "Role")
    assertEquals(loaded.EnemySpacingOnly, false)
    assertEquals(loaded.EnemyUnit1, "arena3")
    assertEquals(loaded.EnemyUnit2, "arena2")
    assertEquals(loaded.EnemyUnit3, "arena1")
end

local function findManager()
    for _, frame in ipairs(wow.State.Frames) do
        if frame:GetAttribute("_onstate-framesort-run") then
            return frame
        end
    end

    return nil
end

function M:test_in_combat_post_sort_runs_only_for_opted_in_containers()
    addon.DB.Options.Sorting.Method = addon.Configuration.SortingMethod.Secure
    addon.Modules.Sorting.Secure:Init()

    local manager = findManager()
    assert(manager)

    local provider = require("TestHarness.ProviderFactory"):Create()
    local party, raid = provider.State.Containers[1], provider.State.Containers[2]
    provider.State.Containers = { party, raid }

    local partyPostSorted = 0
    party.InCombatSortingRequired = true
    party.PostSortInCombat = true
    party.PostSort = function()
        partyPostSorted = partyPostSorted + 1
    end

    local raidPostSorted = 0
    raid.InCombatSortingRequired = true
    raid.PostSort = function()
        raidPostSorted = raidPostSorted + 1
    end

    addon.Providers.All[#addon.Providers.All + 1] = provider

    -- the mock frame ignores this call, so record it
    local loaded = {}
    manager.SetAttributeNoHandler = function(_, name, value)
        loaded[name] = value
    end

    -- providers are loaded into the secure environment once the world is entered
    addon.Scheduling.Scheduler:ProcessEvent(events.PLAYER_ENTERING_WORLD)

    assertEquals(loaded.TestContainer1PostSortInCombat, true)
    assertEquals(loaded.TestContainer2PostSortInCombat, false)

    -- the secure in-combat run calls back by provider name and container index once a container moved
    manager:PostSort("Test", 1)
    manager:PostSort("Test", 2)

    assertEquals(partyPostSorted, 1)
    assertEquals(raidPostSorted, 0)
end

function M:test_party_post_sort_anchors_the_border_in_combat()
    local frameMock = require("TestHarness.FrameMock")
    local fsFrame = addon.WoW.Frame
    local party = fsFrame:GetContainer(addon.Providers.Blizzard, fsFrame.ContainerType.Party)
    assert(party and party.PostSort)

    local units = { "player", "party1" }
    wow.UnitExists = function(unit)
        return unit == "player" or unit == "party1"
    end

    local previous
    for i, unit in ipairs(units) do
        local frame = frameMock:New("Frame", "CompactPartyFrameMember" .. i, wow.CompactPartyFrame)
        frame.unit = unit
        frame:SetSize(100, 100)

        if previous then
            frame:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, 0)
        else
            frame:SetPoint("TOPLEFT", wow.CompactPartyFrame, "TOPLEFT", 0, 0)
        end

        previous = frame
    end

    local anchored = {}
    local border = {
        SetPoint = function(_, point)
            anchored[point] = true
        end,
        IsVisible = function()
            return true
        end,
        GetRect = function()
            return 0, 0, 0, 0
        end,
    }

    local originalBorder = _G.CompactPartyFrameBorderFrame
    _G.CompactPartyFrameBorderFrame = border
    wow.State.MockInCombat = true

    local ok, err = pcall(party.PostSort, party)

    wow.State.MockInCombat = false
    _G.CompactPartyFrameBorderFrame = originalBorder

    assert(ok, err)
    assertEquals(anchored.TOPLEFT, true)
    assertEquals(anchored.BOTTOMRIGHT, true)
end

return M
