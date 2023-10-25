---@type AddonMock
local addon = require("Mock\\Addon")
local frame = require("Mock\\Frame")
local fsProviders = addon.Providers
local provider = fsProviders.Test
local fsSort = addon.Modules.Sorting
local fsFrame = addon.WoW.Frame

local M = {}
local player = nil
local p1 = nil
local p2 = nil

function M:setup()
    addon:InitDB()

    ---@diagnostic disable-next-line: inject-field
    addon.DB.Options.SortingMethod = "Secure"

    local party = fsFrame:GetContainer(provider, fsFrame.ContainerType.Party)
    local partyContainer = assert(party).Frame

    assert(partyContainer)

    player = frame:New("Frame", nil, partyContainer)
    player.unit = "player"

    p1 = frame:New("Frame", nil, partyContainer)
    p1.unit = "party1"

    p2 = frame:New("Frame", nil, partyContainer)
    p2.unit = "party2"
end

function M:teardown()
    addon:Reset()
end

function M:test_sort_party_frames_top()
    addon.DB.Options.Spacing.Party.Vertical = 10

    local config = addon.DB.Options.Sorting.World
    config.Enabled = true
    config.PlayerSortMode = "Top"
    config.GroupSortMode = "Group"

    local width = 100
    local height = 100
    local party = fsFrame:GetContainer(provider, fsFrame.ContainerType.Party)
    local partyContainer = assert(party).Frame

    assert(partyContainer)
    assert(player)
    assert(p1)
    assert(p2)

    -- 3 frames with no spacing between them
    -- player = top
    -- p1 = middle
    -- p2 = bottom
    player:SetPoint("TOPLEFT", partyContainer, "BOTTOMLEFT", 0, 0)
    player:SetPosition(0, 0, width, -height)
    p1:SetPoint("TOPLEFT", player, "BOTTOMLEFT", 0, 0)
    p1:SetPosition(-height, 0, width, -height * 2)
    p2:SetPoint("TOPLEFT", partyContainer, "TOPLEFT", 0, 0)
    p2:SetPosition(-height * 2, 0, width, -height * 3)

    fsSort:Run()

    local function toPos(pos)
        return {
            Point = pos.Point,
            RelativeTo = pos.RelativeTo:GetName(),
            RelativePoint = pos.RelativePoint,
            XOffset = pos.XOffset,
            YOffset = pos.YOffset,
        }
    end

    -- top frame shouldn't have moved
    assertEquals(toPos(player.State.Point),
        {
            Point = "TOPLEFT",
            RelativeTo = partyContainer:GetName(),
            RelativePoint = "TOPLEFT",
            XOffset = 0,
            YOffset = 0,
        })

    -- next frame down should have moved 10 units
    assertEquals(toPos(p1.State.Point),
        {
            Point = "TOPLEFT",
            RelativeTo = partyContainer:GetName(),
            RelativePoint = "TOPLEFT",
            XOffset = 0,
            YOffset = 90,
        })

    -- next frame down should have moved 20 units
    assertEquals(toPos(p2.State.Point),
        {
            Point = "TOPLEFT",
            RelativeTo = partyContainer:GetName(),
            RelativePoint = "TOPLEFT",
            XOffset = 0,
            YOffset = 180,
        })
end

return M
