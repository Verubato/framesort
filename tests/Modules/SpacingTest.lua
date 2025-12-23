---@diagnostic disable: cast-local-type
---@type Addon
local addon
---@type SortingModule
local fsSort
---@type FrameUtil
local fsFrame
---@type WowApi
local wow

local M = {}

local provider = nil
local raidContainer = nil
local raid = nil

local frameCount = 20
local gridCols = 4

---@type table[]
local frames = {}

local function round(n)
    if n == nil then
        return 0
    end
    if n >= 0 then
        return math.floor(n + 0.5)
    end
    return math.ceil(n - 0.5)
end

local function xyKey(x, y)
    return tostring(x) .. "," .. tostring(y)
end

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
    local snap = {}
    for i, f in ipairs(frames) do
        snap[i] = toPos(f.State.Point)
    end
    return snap
end

local function assertPointsUnchanged(before)
    assertEquals(#before, #frames)
    for i, f in ipairs(frames) do
        assertEquals(toPos(f.State.Point), before[i])
    end
end

local function setRaidLayout(isHorizontal, framesPerLine)
    assert(raid)

    raid.IsHorizontalLayout = function(_)
        return isHorizontal
    end

    if framesPerLine == nil then
        raid.FramesPerLine = nil
    else
        raid.FramesPerLine = function(_)
            return framesPerLine
        end
    end
end

local function enableSortingGroup(enabled)
    local config = addon.DB.Options.Sorting.World
    config.Enabled = enabled ~= false
    config.GroupSortMode = "Group"
    config.Reverse = false
end

local function collectOffsets(axis)
    local out = {}
    for i, f in ipairs(frames) do
        if axis == "x" then
            out[i] = f.State.Point.XOffset or 0
        else
            out[i] = f.State.Point.YOffset or 0
        end
    end
    return out
end

local function sortNumbers(list, descending)
    table.sort(list, function(a, b)
        if descending then
            return a > b
        end
        return a < b
    end)
    return list
end

local function expectedArithmetic(n, start, step)
    local t = {}
    for i = 1, n do
        t[i] = start + step * (i - 1)
    end
    return t
end

local function assertSequenceEquals(actual, expected)
    assertEquals(#actual, #expected)
    for i = 1, #expected do
        assertEquals(actual[i], expected[i])
    end
end

local function assertOffsetsArithmetic(axis, start, step, descendingSort)
    local vals = sortNumbers(collectOffsets(axis), descendingSort)
    assertSequenceEquals(vals, expectedArithmetic(#frames, start, step))
end

local function collectOffsetCounts()
    local counts = {}
    for _, f in ipairs(frames) do
        local x = round(f.State.Point.XOffset or 0)
        local y = round(f.State.Point.YOffset or 0)
        local k = xyKey(x, y)
        counts[k] = (counts[k] or 0) + 1
    end
    return counts
end

local function assertCountsEqual(actual, expected)
    for k, v in pairs(expected) do
        assertEquals(actual[k], v)
    end
    for k, v in pairs(actual) do
        assertEquals(expected[k], v)
    end
end

-- Prime size so FrameMock:SetPoint() can compute Position when needed.
local function primeAllSizes(width, height)
    assert(raidContainer)
    raidContainer:SetSize(width, height)

    for _, f in ipairs(frames) do
        f:SetSize(width, height)
    end
end

-- ---------------- grid mapping + unified grid helpers ----------------
-- Horizontal grid: fill rows L->R then next row
-- Vertical grid: fill columns T->B then next column
local function gridRowCol(idx, framesPerLine, isHorizontalLayout)
    if isHorizontalLayout then
        local col = idx % framesPerLine
        local row = math.floor(idx / framesPerLine)
        return row, col
    else
        local row = idx % framesPerLine
        local col = math.floor(idx / framesPerLine)
        return row, col
    end
end

local function expectedGridOffsetCounts(framesPerLine, width, height, v, h, isHorizontalLayout)
    local counts = {}
    for i = 1, #frames do
        local idx = i - 1
        local row, col = gridRowCol(idx, framesPerLine, isHorizontalLayout)

        local x = col * (width + h)
        local y = -row * (height + v)

        local k = xyKey(round(x), round(y))
        counts[k] = (counts[k] or 0) + 1
    end
    return counts
end

-- Seed a "perfect" grid before spacing is applied.
-- Uses container-relative TOPLEFT points; spacing is 0 in seed.
local function layoutGridSeed(width, height, framesPerLine, isHorizontalLayout)
    assert(raidContainer)
    assert(#frames > 0)
    assert(framesPerLine and framesPerLine >= 1)

    primeAllSizes(width, height)

    for i = 1, #frames do
        local idx = i - 1
        local row, col = gridRowCol(idx, framesPerLine, isHorizontalLayout)

        local x = col * width
        local y = -row * height

        frames[i]:SetPoint("TOPLEFT", raidContainer, "TOPLEFT", x, y)
    end
end

-- A single helper to run a grid-spacing case
local function runGridCase(v, h, isHorizontalLayout, framesPerLine, width, height)
    addon.DB.Options.Spacing.Raid.Vertical = v
    addon.DB.Options.Spacing.Raid.Horizontal = h

    setRaidLayout(isHorizontalLayout, framesPerLine)
    enableSortingGroup(true)

    layoutGridSeed(width, height, framesPerLine, isHorizontalLayout)
    fsSort:Run()

    local actual = collectOffsetCounts()
    local expected = expectedGridOffsetCounts(framesPerLine, width, height, v, h, isHorizontalLayout)

    assertCountsEqual(actual, expected)
end

local function layoutVerticalStack(width, height)
    assert(raidContainer)
    assert(#frames > 0)

    primeAllSizes(width, height)

    frames[1]:SetPoint("TOPLEFT", raidContainer, "TOPLEFT", 0, 0)

    for i = 2, #frames do
        frames[i]:SetPoint("TOPLEFT", frames[i - 1], "BOTTOMLEFT", 0, 0)
    end
end

local function layoutHorizontalStack(width, height)
    assert(raidContainer)
    assert(#frames > 0)

    primeAllSizes(width, height)

    frames[1]:SetPoint("TOPLEFT", raidContainer, "TOPLEFT", 0, 0)

    for i = 2, #frames do
        frames[i]:SetPoint("TOPLEFT", frames[i - 1], "TOPRIGHT", 0, 0)
    end
end

function M:setup()
    local addonFactory = require("TestHarness\\AddonFactory")
    local providerFactory = require("TestHarness\\ProviderFactory")
    local frameMock = require("TestHarness\\FrameMock")

    addon = addonFactory:Create()
    fsSort = addon.Modules.Sorting
    fsFrame = addon.WoW.Frame

    provider = providerFactory:Create()
    addon.Providers.Test = provider
    addon.Providers.All[#addon.Providers.All + 1] = provider

    raid = fsFrame:GetContainer(provider, fsFrame.ContainerType.Raid)
    assert(raid)

    raidContainer = raid.Frame
    assert(raidContainer)

    frames = {}
    for i = 1, frameCount do
        local f = frameMock:New("Frame", nil, raidContainer)
        f.unit = "raid" .. tostring(i)
        frames[#frames + 1] = f
    end

    wow = addon.WoW.Api
    wow.IsInGroup = function()
        return true
    end
    wow.UnitExists = function(unit)
        local n = tonumber(string.match(unit or "", "^raid(%d+)$"))
        return n ~= nil and n >= 1 and n <= frameCount
    end
end

function M:teardown()
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
    raidContainer = nil
    raid = nil
    frames = {}
end

-- ---------------- tests ----------------

function M:test_space_raid_frames_vertical_10()
    addon.DB.Options.Spacing.Raid.Vertical = 10
    addon.DB.Options.Spacing.Raid.Horizontal = 0

    setRaidLayout(false, nil)
    enableSortingGroup(true)

    local w, h = 100, 100
    layoutVerticalStack(w, h)

    fsSort:Run()

    -- Y offsets are 0, -110, -220... sorted descending gives [0, -110, ...]
    assertOffsetsArithmetic("y", 0, -(h + 10), true)
    -- X offsets all 0
    assertOffsetsArithmetic("x", 0, 0, false)
end

function M:test_space_raid_frames_vertical_0_has_no_extra_gap()
    addon.DB.Options.Spacing.Raid.Vertical = 0
    addon.DB.Options.Spacing.Raid.Horizontal = 0

    setRaidLayout(false, nil)
    enableSortingGroup(true)

    local w, h = 100, 100
    layoutVerticalStack(w, h)

    fsSort:Run()

    assertOffsetsArithmetic("y", 0, -h, true)
end

function M:test_space_raid_frames_horizontal_10_vertical_layout()
    addon.DB.Options.Spacing.Raid.Vertical = 0
    addon.DB.Options.Spacing.Raid.Horizontal = 10

    setRaidLayout(false, nil)
    enableSortingGroup(true)

    local w, h = 100, 100
    layoutVerticalStack(w, h)

    fsSort:Run()

    -- vertical layout: horizontal spacing should not change X offsets
    assertOffsetsArithmetic("x", 0, 0, false)
end

function M:test_space_raid_frames_vertical_10_horizontal_layout()
    addon.DB.Options.Spacing.Raid.Vertical = 10
    addon.DB.Options.Spacing.Raid.Horizontal = 0

    setRaidLayout(true, nil)
    enableSortingGroup(true)

    local w, h = 100, 100
    layoutHorizontalStack(w, h)

    fsSort:Run()

    -- horizontal layout: vertical spacing should not change Y offsets
    assertOffsetsArithmetic("y", 0, 0, true)
end

function M:test_space_raid_frames_horizontal_0_is_no_extra_gap_horizontal_layout()
    addon.DB.Options.Spacing.Raid.Vertical = 0
    addon.DB.Options.Spacing.Raid.Horizontal = 0

    setRaidLayout(true, nil)
    enableSortingGroup(true)

    local w, h = 100, 100
    layoutHorizontalStack(w, h)

    fsSort:Run()

    assertOffsetsArithmetic("x", 0, w, false)
    assertOffsetsArithmetic("y", 0, 0, true)
end

function M:test_space_raid_frames_horizontal_15_with_width_80_horizontal_layout()
    addon.DB.Options.Spacing.Raid.Vertical = 0
    addon.DB.Options.Spacing.Raid.Horizontal = 15

    setRaidLayout(true, nil)
    enableSortingGroup(true)

    local w, h = 80, 100
    layoutHorizontalStack(w, h)

    fsSort:Run()

    assertOffsetsArithmetic("x", 0, w + 15, false)
end

function M:test_spacing_does_not_apply_when_sorting_disabled()
    addon.DB.Options.Spacing.Raid.Vertical = 10
    addon.DB.Options.Spacing.Raid.Horizontal = 0

    setRaidLayout(false, nil)
    enableSortingGroup(false)

    local w, h = 100, 100
    layoutVerticalStack(w, h)

    local before = snapshotPoints()
    fsSort:Run()

    assertPointsUnchanged(before)
end

-- Grid (horizontal orientation): FramesPerLine means columns
function M:test_space_raid_frames_vertical_10_horizontal_15_grid_layout()
    runGridCase(10, 15, true, gridCols, 100, 100)
end

function M:test_space_raid_frames_vertical_0_horizontal_15_grid_layout()
    runGridCase(0, 15, true, gridCols, 100, 100)
end

function M:test_space_raid_frames_vertical_10_horizontal_0_grid_layout()
    runGridCase(10, 0, true, gridCols, 100, 100)
end

function M:test_space_raid_frames_vertical_10_horizontal_15_grid_layout_with_width_80_height_70()
    runGridCase(10, 15, true, gridCols, 80, 70)
end

-- Grid (vertical orientation): FramesPerLine means rows-per-column
function M:test_space_raid_frames_vertical_10_horizontal_15_grid_layout_vertical_orientation()
    runGridCase(10, 15, false, gridCols, 100, 100)
end

function M:test_space_raid_frames_vertical_0_horizontal_15_grid_layout_vertical_orientation()
    runGridCase(0, 15, false, gridCols, 100, 100)
end

function M:test_space_raid_frames_vertical_10_horizontal_0_grid_layout_vertical_orientation()
    runGridCase(10, 0, false, gridCols, 100, 100)
end

function M:test_space_raid_frames_vertical_10_horizontal_15_grid_layout_vertical_orientation_with_width_80_height_70()
    runGridCase(10, 15, false, gridCols, 80, 70)
end

return M
