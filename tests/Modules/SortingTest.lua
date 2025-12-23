---@diagnostic disable: cast-local-type
---@type Addon
local addon
---@type SortingModule
local fsSort
---@type FrameUtil
local fsFrame
---@type Enumerable
local fsEnumerable
---@type Comparer
local fsCompare
---@type WowApi
local wow

local M = {}

local player = nil
local p1 = nil
local p2 = nil

local provider = nil
local partyContainer = nil

local width = 100
local height = 100

local function toPos(pos)
    return {
        Point = pos.Point,
        RelativeTo = pos.RelativeTo and pos.RelativeTo:GetName() or nil,
        RelativePoint = pos.RelativePoint,
        XOffset = pos.XOffset,
        YOffset = pos.YOffset,
    }
end

local function snapshotPoints()
    assert(player and p1 and p2)

    return {
        player = toPos(player.State.Point),
        p1 = toPos(p1.State.Point),
        p2 = toPos(p2.State.Point),
    }
end

local function assertPointsUnchanged(before)
    assert(player and p1 and p2)

    assertEquals(toPos(player.State.Point), before.player)
    assertEquals(toPos(p1.State.Point), before.p1)
    assertEquals(toPos(p2.State.Point), before.p2)
end

-- Ensure size known so SetPoint updates Position/Top/Left etc.
local function primeSizes(frames)
    for i = 1, #frames do
        frames[i]:SetSize(width, height)
    end

    assert(partyContainer)

    partyContainer:SetSize(width, height)
end

-- Lay frames out top-down in the order provided, with 0 spacing.
-- order[1] is top, order[2] below it, etc.
local function layoutTopDown(order)
    assert(partyContainer)
    primeSizes(order)

    -- anchor first to container
    order[1]:SetPoint("TOPLEFT", partyContainer, "TOPLEFT", 0, 0)

    -- anchor the rest to previous
    for i = 2, #order do
        local prev = order[i - 1]
        local cur = order[i]
        cur:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
    end
end

local function assertVisualOrder(expectedOrder)
    local orderedByTopLeft = fsEnumerable
        :From(expectedOrder)
        :OrderBy(function(a, b)
            return fsCompare:CompareTopLeftFuzzy(a, b)
        end)
        :ToTable()

    for i = 1, #expectedOrder do
        if expectedOrder[i] ~= orderedByTopLeft[i] then
            local exp = expectedOrder[i]
            local got = orderedByTopLeft[i]
            error(
                ("Visual order mismatch at index %d\n" .. "expected: %s top=%s left=%s\n" .. "got:      %s top=%s left=%s\n"):format(
                    i,
                    exp.unit,
                    tostring(exp:GetTop()),
                    tostring(exp:GetLeft()),
                    got.unit,
                    tostring(got:GetTop()),
                    tostring(got:GetLeft())
                )
            )
        end
    end
end

local function setPartyLayoutType(layoutType)
    assert(provider)

    -- provider factory creates party container with LayoutType set,
    -- but tests sometimes want to swap layout in-place.
    local party = fsFrame:GetContainer(provider, fsFrame.ContainerType.Party)
    assert(party)
    party.LayoutType = layoutType
end

function M:setup()
    local addonFactory = require("TestHarness\\AddonFactory")
    local providerFactory = require("TestHarness\\ProviderFactory")
    local frameMock = require("TestHarness\\FrameMock")

    addon = addonFactory:Create()
    fsSort = addon.Modules.Sorting
    fsFrame = addon.WoW.Frame
    fsEnumerable = addon.Collections.Enumerable
    fsCompare = addon.Modules.Sorting.Comparer

    fsSort:Init()

    provider = providerFactory:Create()
    addon.Providers.Test = provider
    addon.Providers.All[#addon.Providers.All + 1] = provider

    local party = fsFrame:GetContainer(provider, fsFrame.ContainerType.Party)
    assert(party)
    partyContainer = party.Frame
    assert(partyContainer)

    -- Prime container size too
    partyContainer:SetSize(width, height)
    partyContainer:SetName("partyContainer")

    -- Create frames in the party container
    p2 = frameMock:New("Frame", nil, partyContainer)
    p2.unit = "party2"
    p2:SetSize(width, height)
    p2:SetName("party2")

    player = frameMock:New("Frame", nil, partyContainer)
    player.unit = "player"
    player:SetSize(width, height)
    player:SetName("player")

    p1 = frameMock:New("Frame", nil, partyContainer)
    p1.unit = "party1"
    p1:SetSize(width, height)
    p1:SetName("party1")

    wow = addon.WoW.Api
    wow.IsInGroup = function()
        return true
    end
    wow.UnitExists = function(unit)
        return unit == "player" or unit == "party1" or unit == "party2"
    end
end

function M:teardown()
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
    fsSort = nil
    fsFrame = nil
    wow = nil
    provider = nil
    partyContainer = nil
    player = nil
    p1 = nil
    p2 = nil
end

function M:test_hard_sort_party_frames_top()
    setPartyLayoutType(fsFrame.LayoutType.Hard)

    local config = addon.DB.Options.Sorting.World
    config.Enabled = true
    config.PlayerSortMode = "Top"
    config.GroupSortMode = "Group"
    config.Reverse = false

    -- initial: p2 top, player middle, p1 bottom
    layoutTopDown({ p2, player, p1 })

    local sorted = false
    addon.Modules.Sorting:RegisterPostSortCallback(function()
        sorted = true
    end)

    fsSort:Run()

    assert(sorted)
    assert(player and p1 and p2 and partyContainer)

    -- expected order: player, party1, party2 (top-down)
    assertEquals(toPos(player.State.Point), {
        Point = "TOPLEFT",
        RelativeTo = partyContainer:GetName(),
        RelativePoint = "TOPLEFT",
        XOffset = 0,
        YOffset = 0,
    })
    assertEquals(toPos(p1.State.Point), {
        Point = "TOPLEFT",
        RelativeTo = partyContainer:GetName(),
        RelativePoint = "TOPLEFT",
        XOffset = 0,
        YOffset = -100,
    })
    assertEquals(toPos(p2.State.Point), {
        Point = "TOPLEFT",
        RelativeTo = partyContainer:GetName(),
        RelativePoint = "TOPLEFT",
        XOffset = 0,
        YOffset = -200,
    })
end

function M:test_hard_sort_party_frames_bottom()
    setPartyLayoutType(fsFrame.LayoutType.Hard)

    local config = addon.DB.Options.Sorting.World
    config.Enabled = true
    config.PlayerSortMode = "Bottom"
    config.GroupSortMode = "Group"
    config.Reverse = false

    -- initial: player top, p2 middle, p1 bottom
    layoutTopDown({ player, p2, p1 })

    local sorted = false
    addon.Modules.Sorting:RegisterPostSortCallback(function()
        sorted = true
    end)

    fsSort:Run()

    assert(sorted)
    assert(player and p1 and p2 and partyContainer)

    -- expected order: party1, party2, player
    assertEquals(toPos(p1.State.Point).YOffset, 0)
    assertEquals(toPos(p2.State.Point).YOffset, -100)
    assertEquals(toPos(player.State.Point).YOffset, -200)
end

function M:test_hard_sort_party_frames_middle()
    setPartyLayoutType(fsFrame.LayoutType.Hard)

    local config = addon.DB.Options.Sorting.World
    config.Enabled = true
    config.PlayerSortMode = "Middle"
    config.GroupSortMode = "Group"
    config.Reverse = false

    layoutTopDown({ p1, p2, player })

    local sorted = false
    addon.Modules.Sorting:RegisterPostSortCallback(function()
        sorted = true
    end)

    fsSort:Run()

    assert(sorted)
    assert(player and p1 and p2 and partyContainer)

    assertEquals(toPos(p1.State.Point).YOffset, 0)
    assertEquals(toPos(player.State.Point).YOffset, -100)
    assertEquals(toPos(p2.State.Point).YOffset, -200)
end

function M:test_hard_sort_party_frames_hidden_pushes_player_to_end()
    setPartyLayoutType(fsFrame.LayoutType.Hard)

    local config = addon.DB.Options.Sorting.World
    config.Enabled = true
    config.PlayerSortMode = "Hidden"
    config.GroupSortMode = "Group"
    config.Reverse = false

    layoutTopDown({ player, p1, p2 })

    local sorted = false
    addon.Modules.Sorting:RegisterPostSortCallback(function()
        sorted = true
    end)

    fsSort:Run()

    assert(sorted)
    assert(p1 and p2 and player)

    assertEquals(toPos(p1.State.Point).YOffset, 0)
    assertEquals(toPos(p2.State.Point).YOffset, -100)
    assertEquals(toPos(player.State.Point).YOffset, -200)
end

function M:test_hard_sort_party_frames_reverse_group()
    setPartyLayoutType(fsFrame.LayoutType.Hard)

    local config = addon.DB.Options.Sorting.World
    config.Enabled = true
    config.PlayerSortMode = nil
    config.GroupSortMode = "Group"
    config.Reverse = true

    layoutTopDown({ p1, player, p2 })

    local sorted = false
    addon.Modules.Sorting:RegisterPostSortCallback(function()
        sorted = true
    end)

    fsSort:Run()

    assert(sorted)
    assert(p1 and p2 and player)

    assertEquals(toPos(player.State.Point).YOffset, 0)
    assertEquals(toPos(p2.State.Point).YOffset, -100)
    assertEquals(toPos(p1.State.Point).YOffset, -200)
end

function M:test_hard_sort_disabled_does_not_move_points()
    setPartyLayoutType(fsFrame.LayoutType.Hard)

    local config = addon.DB.Options.Sorting.World
    config.Enabled = false
    config.PlayerSortMode = "Top"
    config.GroupSortMode = "Group"
    config.Reverse = false

    layoutTopDown({ p2, p1, player })

    local before = snapshotPoints()

    local sorted = false
    addon.Modules.Sorting:RegisterPostSortCallback(function()
        sorted = true
    end)

    fsSort:Run()

    assert(sorted == false)
    assertPointsUnchanged(before)
end

function M:test_soft_sort_party_frames_top_reorders_visually()
    setPartyLayoutType(fsFrame.LayoutType.Soft)

    local config = addon.DB.Options.Sorting.World
    config.Enabled = true
    config.PlayerSortMode = "Top"
    config.GroupSortMode = "Group"
    config.Reverse = false

    -- initial: p2 top, player middle, p1 bottom
    layoutTopDown({ p2, player, p1 })

    local sorted = false
    addon.Modules.Sorting:RegisterPostSortCallback(function()
        sorted = true
    end)

    fsSort:Run()
    assert(sorted)

    assertVisualOrder({ player, p1, p2 })
end

function M:test_soft_sort_party_frames_bottom_reorders_visually()
    setPartyLayoutType(fsFrame.LayoutType.Soft)

    local config = addon.DB.Options.Sorting.World
    config.Enabled = true
    config.PlayerSortMode = "Bottom"
    config.GroupSortMode = "Group"
    config.Reverse = false

    -- initial scrambled
    layoutTopDown({ player, p2, p1 })

    local sorted = false
    addon.Modules.Sorting:RegisterPostSortCallback(function()
        sorted = true
    end)

    fsSort:Run()
    assert(sorted)

    assertVisualOrder({ p1, p2, player })
end

function M:test_soft_sort_party_frames_reverse_group_reorders_visually()
    setPartyLayoutType(fsFrame.LayoutType.Soft)

    local config = addon.DB.Options.Sorting.World
    config.Enabled = true
    config.PlayerSortMode = nil
    config.GroupSortMode = "Group"
    config.Reverse = true

    -- initial: p1 top, player middle, p2 bottom
    layoutTopDown({ p1, player, p2 })

    local sorted = false
    addon.Modules.Sorting:RegisterPostSortCallback(function()
        sorted = true
    end)

    fsSort:Run()
    assert(sorted)

    assertVisualOrder({ player, p2, p1 })
end

function M:test_soft_sort_disabled_does_not_move_points()
    setPartyLayoutType(fsFrame.LayoutType.Soft)

    local config = addon.DB.Options.Sorting.World
    config.Enabled = false
    config.PlayerSortMode = "Top"
    config.GroupSortMode = "Group"
    config.Reverse = false

    layoutTopDown({ p2, p1, player })

    local before = snapshotPoints()

    fsSort:Run()

    -- should not move points
    assertPointsUnchanged(before)
end

return M
