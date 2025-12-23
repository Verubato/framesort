---@diagnostic disable: cast-local-type
---@type Addon
local addon
---@type SortedFrames
local fsSortedFrames
---@type FrameUtil
local fsFrame
---@type WowApi
local wow
local frameMock

local M = {}
local provider = nil
local partyContainer = nil
local raidContainer = nil
local arenaContainer = nil

local width, height = 100, 100

-- Keep originals so we can restore between tests
local originalProviders = nil
local originalBlizzard = nil

-- ---------------- helpers ----------------

local function newFrame(parent, x, y, visible)
    local f = frameMock:New("Frame", nil, parent)
    f:SetSize(width, height)
    if visible == false then
        f:Hide()
    else
        f:Show()
    end
    f:SetPoint("TOPLEFT", parent, "TOPLEFT", x or 0, y or 0)
    return f
end

local function assertIdOrder(actualFrames, expectedIds)
    assertEquals(#actualFrames, #expectedIds)
    for i = 1, #expectedIds do
        assertEquals(actualFrames[i].id, expectedIds[i])
    end
end

local function setEnemySortMode(enabled)
    -- SortedFrames calls fsCompare:EnemySortMode()
    addon.Modules.Sorting.Comparer.EnemySortMode = function()
        return enabled == true
    end
end

local function stubBlizzardProvider(enabled)
    addon.Providers.Blizzard = {
        Enabled = function()
            return enabled == true
        end,
    }
end

function M:setup()
    local addonFactory = require("TestHarness\\AddonFactory")
    local providerFactory = require("TestHarness\\ProviderFactory")
    frameMock = require("TestHarness\\FrameMock")

    addon = addonFactory:Create()

    fsFrame = addon.WoW.Frame
    fsSortedFrames = addon.Modules.Sorting.SortedFrames

    -- Provider mocking principle: create provider via factory and inject into Providers
    provider = providerFactory:Create()
    addon.Providers.Test = provider
    addon.Providers.All[#addon.Providers.All + 1] = provider

    -- Containers (use real FrameUtil container API)
    local party = fsFrame:GetContainer(provider, fsFrame.ContainerType.Party)
    assert(party)
    partyContainer = party.Frame
    partyContainer:SetSize(width, height)

    local raid = fsFrame:GetContainer(provider, fsFrame.ContainerType.Raid)
    assert(raid)
    raidContainer = raid.Frame
    raidContainer:SetSize(width, height)

    local arena = fsFrame:GetContainer(provider, fsFrame.ContainerType.EnemyArena)
    assert(arena)
    arenaContainer = arena.Frame
    arenaContainer:SetSize(width, height)

    wow = addon.WoW.Api
    wow.IsInGroup = function()
        return true
    end
    wow.UnitExists = function(_)
        return true
    end

    -- Save/restore Providers table members
    originalProviders = addon.Providers
    originalBlizzard = addon.Providers.Blizzard
end

function M:teardown()
    -- restore Blizzard provider if we changed it
    if addon and addon.Providers then
        ---@diagnostic disable-next-line: assign-type-mismatch
        addon.Providers.Blizzard = originalBlizzard
    end

    -- remove our injected provider from Providers.All
    if addon and provider and addon.Providers and addon.Providers.All then
        for i = #addon.Providers.All, 1, -1 do
            if addon.Providers.All[i] == provider then
                table.remove(addon.Providers.All, i)
            end
        end
        if addon.Providers.Test == provider then
            addon.Providers.Test = nil
        end
    end

    addon = nil
    fsSortedFrames = nil
    fsFrame = nil
    wow = nil
    provider = nil
    partyContainer = nil
    raidContainer = nil
    arenaContainer = nil
    originalProviders = nil
    originalBlizzard = nil
end

function M:test_FriendlyFrames_prefers_blizzard_party_frames()
    -- Blizzard enabled but has frames; Test provider also has frames; Blizzard should win.
    stubBlizzardProvider(true)

    -- Put some frames in Blizzard's party container path by monkeypatching PartyFrames call.
    -- We keep ProviderFactory injection for the non-blizzard provider.
    local blizzFrames = {
        newFrame(partyContainer, 0, 0, true),
        newFrame(partyContainer, 0, -100, true),
    }
    blizzFrames[1].id = "B1"
    blizzFrames[2].id = "B2"

    local testFrames = {
        newFrame(partyContainer, 50, -50, true),
    }
    testFrames[1].id = "T1"

    local origPartyFrames = fsFrame.PartyFrames
    fsFrame.PartyFrames = function(_, prov, visibleOnly)
        if prov == addon.Providers.Blizzard then
            return blizzFrames
        end
        if prov == provider then
            return testFrames
        end
        return {}
    end

    local out = fsSortedFrames:FriendlyFrames()
    assertIdOrder(out, { "B1", "B2" })

    fsFrame.PartyFrames = origPartyFrames
end

function M:test_FriendlyFrames_blizzard_party_empty_uses_blizzard_raid()
    stubBlizzardProvider(true)

    local blizzRaidFrames = {
        newFrame(raidContainer, 0, -100, true),
        newFrame(raidContainer, 0, 0, true),
    }
    blizzRaidFrames[1].id = "R1"
    blizzRaidFrames[2].id = "R2"

    local origPartyFrames = fsFrame.PartyFrames
    local origRaidFrames = fsFrame.RaidFrames

    fsFrame.PartyFrames = function(_, prov, visibleOnly)
        if prov == addon.Providers.Blizzard then
            return {} -- force fallback
        end
        return {}
    end

    fsFrame.RaidFrames = function(_, prov, visibleOnly)
        if prov == addon.Providers.Blizzard then
            return blizzRaidFrames
        end
        return {}
    end

    local out = fsSortedFrames:FriendlyFrames()
    -- Visual order sorts by Top desc -> R2 then R1
    assertIdOrder(out, { "R2", "R1" })

    fsFrame.PartyFrames = origPartyFrames
    fsFrame.RaidFrames = origRaidFrames
end

function M:test_friendly_frames_falls_back_to_test_provider_when_blizzard_disabled()
    stubBlizzardProvider(false)

    local testPartyFrames = {
        newFrame(partyContainer, 0, -100, true),
        newFrame(partyContainer, 0, 0, true),
        newFrame(partyContainer, 0, -50, false), -- invisible filtered
    }
    testPartyFrames[1].id = "T1"
    testPartyFrames[2].id = "T2"
    testPartyFrames[3].id = "T_INV"

    local origPartyFrames = fsFrame.PartyFrames
    fsFrame.PartyFrames = function(_, prov, visibleOnly)
        if prov == provider then
            return testPartyFrames
        end
        return {}
    end

    local out = fsSortedFrames:FriendlyFrames()
    assertEquals(#out, 2)
    assertIdOrder(out, { "T2", "T1" })

    fsFrame.PartyFrames = origPartyFrames
end

function M:test_friendly_frames_returns_empty_when_no_frames_anywhere()
    stubBlizzardProvider(false)

    local origPartyFrames = fsFrame.PartyFrames
    local origRaidFrames = fsFrame.RaidFrames

    fsFrame.PartyFrames = function()
        return {}
    end
    fsFrame.RaidFrames = function()
        return {}
    end

    local out = fsSortedFrames:FriendlyFrames()
    assertEquals(type(out), "table")
    assertEquals(#out, 0)

    fsFrame.PartyFrames = origPartyFrames
    fsFrame.RaidFrames = origRaidFrames
end

function M:test_arena_frames_returns_empty_when_enemy_sort_mode_disabled()
    setEnemySortMode(false)
    local out = fsSortedFrames:ArenaFrames()
    assertEquals(#out, 0)
end

function M:test_arena_frames_prefers_blizzard_when_enabled()
    setEnemySortMode(true)
    stubBlizzardProvider(true)

    local blizzArenaFrames = {
        newFrame(arenaContainer, 0, 0, true),
        newFrame(arenaContainer, 0, -100, true),
        newFrame(arenaContainer, 0, -50, false), -- invisible filtered
    }
    blizzArenaFrames[1].id = "A1"
    blizzArenaFrames[2].id = "A2"
    blizzArenaFrames[3].id = "A_INV"

    local testArenaFrames = {
        newFrame(arenaContainer, 0, -999, true),
    }
    testArenaFrames[1].id = "TA"

    local origArenaFrames = fsFrame.ArenaFrames
    fsFrame.ArenaFrames = function(_, prov, visibleOnly)
        if prov == addon.Providers.Blizzard then
            return blizzArenaFrames
        end
        if prov == provider then
            return testArenaFrames
        end
        return {}
    end

    local out = fsSortedFrames:ArenaFrames()
    assertEquals(#out, 2)
    assertIdOrder(out, { "A1", "A2" })

    fsFrame.ArenaFrames = origArenaFrames
end

function M:test_arena_frames_falls_back_to_test_provider_when_blizzard_empty()
    setEnemySortMode(true)
    stubBlizzardProvider(true)

    local testArenaFrames = {
        newFrame(arenaContainer, 0, -100, true),
        newFrame(arenaContainer, 0, 0, true),
    }
    testArenaFrames[1].id = "TA1"
    testArenaFrames[2].id = "TA2"

    local origArenaFrames = fsFrame.ArenaFrames
    fsFrame.ArenaFrames = function(_, prov, visibleOnly)
        if prov == addon.Providers.Blizzard then
            return {} -- force fallback
        end
        if prov == provider then
            return testArenaFrames
        end
        return {}
    end

    local out = fsSortedFrames:ArenaFrames()
    assertIdOrder(out, { "TA2", "TA1" })

    fsFrame.ArenaFrames = origArenaFrames
end

return M
