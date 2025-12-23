---@diagnostic disable: duplicate-set-field
---@type Addon
local addon
---@type UnitTrackerModule
local fsTracker
---@type FrameUtil
local fsFrame
---@type Providers
local fsProviders
---@type UnitUtil
local fsUnit
---@type WowApi
local wow
local frameMock
local M = {}

local function assertSame(actual, expected, msg)
    if actual ~= expected then
        error(msg or string.format("expected same object, got %s vs %s", tostring(actual), tostring(expected)), 2)
    end
end

local function MakeUnitFrame(name, unit, visible)
    local frame = frameMock:New("Frame", name, nil, nil)
    frame.Unit = unit
    frame.State.Visible = (visible ~= false)
    return frame
end

function M:setup()
    local addonFactory = require("TestHarness\\AddonFactory")
    addon = addonFactory:Create()

    frameMock = require("TestHarness\\FrameMock")

    fsTracker = addon.Modules.UnitTracker
    fsFrame = addon.WoW.Frame
    fsProviders = addon.Providers
    fsUnit = addon.WoW.Unit
    wow = addon.WoW.Api

    fsUnit.IsFriendlyUnit = function(_, unit)
        return unit == "player" or string.match(unit, "^party") or string.match(unit, "^raid")
    end

    -- Frame unit lookup comes from our FrameMock property
    fsFrame.GetFrameUnit = function(_, frame)
        return frame and frame.Unit or nil
    end

    local provider = { Name = "TestProvider" }
    fsProviders.Enabled = function()
        return { provider }
    end

    fsFrame.PartyFrames = function()
        return {}
    end
    fsFrame.RaidFrames = function()
        return {}
    end
    fsFrame.ArenaFrames = function()
        return {}
    end
end

function M:teardown()
    ---@diagnostic disable-next-line: cast-local-type
    addon = nil
    ---@diagnostic disable-next-line: cast-local-type
    fsTracker = nil
    ---@diagnostic disable-next-line: cast-local-type
    fsFrame = nil
    ---@diagnostic disable-next-line: cast-local-type
    fsProviders = nil
    ---@diagnostic disable-next-line: cast-local-type
    fsUnit = nil
    ---@diagnostic disable-next-line: cast-local-type
    wow = nil
    frameMock = nil
end

function M:test_returns_nil_when_unit_nil()
    assertEquals(fsTracker:GetFrameForUnit(nil), nil)
end

function M:test_friendly_prefers_visible_cached_frame_when_still_matches()
    local f = MakeUnitFrame("Party1Frame", "party1", true)

    fsFrame.PartyFrames = function()
        return { f }
    end

    assertSame(fsTracker:GetFrameForUnit("party1"), f)
    -- second call should come from cache (still matches + visible)
    assertSame(fsTracker:GetFrameForUnit("party1"), f)
end

function M:test_cached_hidden_causes_rescan_and_prefers_visible_candidate()
    local hidden = MakeUnitFrame("HiddenParty1", "party1", false)
    local visible = MakeUnitFrame("VisibleParty1", "party1", true)

    -- first: only hidden exists -> fallback returns hidden (but should cache it)
    fsFrame.PartyFrames = function()
        return { hidden }
    end

    assertSame(fsTracker:GetFrameForUnit("party1"), hidden)

    -- second: visible now exists -> should return visible and update cache
    fsFrame.PartyFrames = function()
        return { hidden, visible }
    end

    assertSame(fsTracker:GetFrameForUnit("party1"), visible)
end

function M:test_cached_forbidden_frame_is_purged_and_refound()
    local f1 = MakeUnitFrame("Party1Old", "party1", true)
    local f2 = MakeUnitFrame("Party1New", "party1", true)

    fsFrame.PartyFrames = function()
        return { f1 }
    end

    assertSame(fsTracker:GetFrameForUnit("party1"), f1)

    -- cached frame becomes forbidden after caching
    f1.State.Forbidden = true

    fsFrame.PartyFrames = function()
        return { f1, f2 }
    end

    assertSame(fsTracker:GetFrameForUnit("party1"), f2)
end

function M:test_cached_frame_no_longer_matches_unit_is_cleared_and_refound()
    local f1 = MakeUnitFrame("FrameA", "party1", true)
    local f2 = MakeUnitFrame("FrameB", "party1", true)

    fsFrame.PartyFrames = function()
        return { f1 }
    end

    assertSame(fsTracker:GetFrameForUnit("party1"), f1)

    -- reassigned: f1 now represents party2 -> should not satisfy party1 anymore
    f1.Unit = "party2"

    fsFrame.PartyFrames = function()
        return { f1, f2 }
    end

    assertSame(fsTracker:GetFrameForUnit("party1"), f2)
    assertSame(fsTracker:GetFrameForUnit("party2"), f1)
end

function M:test_unitisunit_secretvalue_does_not_match()
    local f = MakeUnitFrame("Weird", "raid5", true)

    wow.UnitIsUnit = function()
        ---@diagnostic disable-next-line: return-type-mismatch
        return "SECRET"
    end

    fsFrame.RaidFrames = function()
        return { f }
    end

    assertEquals(fsTracker:GetFrameForUnit("player"), nil)
end

function M:test_unitisunit_true_allows_match_when_tokens_differ()
    local f = MakeUnitFrame("Alias", "raid5", true)

    wow.UnitIsUnit = function(a, b)
        if a == "raid5" and b == "player" then
            return true
        end
        return a == b
    end

    fsFrame.RaidFrames = function()
        return { f }
    end

    assertSame(fsTracker:GetFrameForUnit("player"), f)
end

function M:test_enemy_unit_searches_arena_frames_only()
    fsUnit.IsFriendlyUnit = function()
        return false
    end

    local arena2 = MakeUnitFrame("Arena2", "arena2", true)

    fsFrame.ArenaFrames = function()
        return { arena2 }
    end
    fsFrame.PartyFrames = function()
        return { MakeUnitFrame("BaitParty", "arena2", true) }
    end
    fsFrame.RaidFrames = function()
        return { MakeUnitFrame("BaitRaid", "arena2", true) }
    end

    assertSame(fsTracker:GetFrameForUnit("arena2"), arena2)
end

function M:test_friendly_checks_party_then_raid()
    local partyHit = MakeUnitFrame("PartyHit", "party1", true)
    local raidHit = MakeUnitFrame("RaidHit", "party1", true)

    fsFrame.PartyFrames = function()
        return { partyHit }
    end
    fsFrame.RaidFrames = function()
        return { raidHit }
    end

    assertSame(fsTracker:GetFrameForUnit("party1"), partyHit)
end

function M:test_fallback_returns_hidden_frame_when_only_hidden_found()
    local hiddenRaid = MakeUnitFrame("HiddenRaid3", "raid3", false)

    fsFrame.RaidFrames = function()
        return { hiddenRaid }
    end

    assertSame(fsTracker:GetFrameForUnit("raid3"), hiddenRaid)
end

return M
