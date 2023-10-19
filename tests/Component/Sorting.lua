local addon = require("Addon")
local frame = require("Mock\\Frame")
local provider = addon.Providers.Test
local fsSort = addon.Modules.Sorting
local fsFrame = addon.WoW.Frame

local M = {}
local player = nil
local p1 = nil
local p2 = nil

function M:setup()
    addon:InitDB()
    fsSort:Init()

    local party = fsFrame:GetContainer(provider, fsFrame.ContainerType.Party)
    local partyContainer = assert(party).Frame

    assert(partyContainer ~= nil)

    p2 = frame:New("Frame", nil, partyContainer)
    p2.unit = "party2"

    player = frame:New("Frame", nil, partyContainer)
    player.unit = "player"

    p1 = frame:New("Frame", nil, partyContainer)
    p1.unit = "party1"
end

function M:teardown()
    addon:Reset()
end

function M:test_sort_party_frames_top()
    addon.DB.Options.World.Enabled = true
    addon.DB.Options.World.PlayerSortMode = "Top"
    addon.DB.Options.World.GroupSortMode = "Group"

    local width = 100
    local height = 100

    local party = fsFrame:GetContainer(provider, fsFrame.ContainerType.Party)
    local partyContainer = assert(party).Frame

    assert(partyContainer)
    assert(player)
    assert(p1)
    assert(p2)

    -- player = top
    -- p1 = middle
    -- p2 = bottom
    p2:SetPoint("TOPLEFT", partyContainer, "TOPLEFT", 0, 0)
    p2:SetPosition(0, 0, width, -height)
    player:SetPoint("TOPLEFT", p2, "BOTTOMLEFT", 0, 0)
    player:SetPosition(-height, 0, width, -height * 2)
    p1:SetPoint("TOPLEFT", player, "BOTTOMLEFT", 0, 0)
    p1:SetPosition(-height * 2, 0, width, -height * 3)

    assert(fsSort:Run())

    local function toPos(pos)
        return {
            Point = pos.Point,
            RelativeTo = pos.RelativeTo:GetName(),
            RelativePoint = pos.RelativePoint,
            XOffset = pos.XOffset,
            YOffset = pos.YOffset,
        }
    end

    assertEquals(toPos(player.State.Point),
        {
            Point = "TOPLEFT",
            RelativeTo = partyContainer:GetName(),
            RelativePoint = "TOPLEFT",
            XOffset = 0,
            YOffset = 0,
        })

    assertEquals(toPos(p1.State.Point),
        {
            Point = "TOPLEFT",
            RelativeTo = partyContainer:GetName(),
            RelativePoint = "TOPLEFT",
            XOffset = 0,
            YOffset = 100,
        })

    assertEquals(toPos(p2.State.Point),
        {
            Point = "TOPLEFT",
            RelativeTo = partyContainer:GetName(),
            RelativePoint = "TOPLEFT",
            XOffset = 0,
            YOffset = 200,
        })
end

return M
