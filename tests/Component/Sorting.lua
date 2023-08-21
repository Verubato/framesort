local addon = require("Addon")
local frame = require("Mock\\Frame")
local provider = addon.Providers.Test
local fsConfig = addon.Configuration
local fsSort = addon.Modules.Sorting

local M = {}
local partyContainer = frame:New()
local player = frame:New("Frame", nil, partyContainer, nil)
player.State.Position.Top = 100
player.unit = "player"

local p1 = frame:New("Frame", nil, partyContainer, nil)
p1.State.Position.Top = 200
p1.unit = "party1"

local p2 = frame:New("Frame", nil, partyContainer, nil)
p2.State.Position.Top = 300
p2.unit = "party2"

function M:setup()
    addon:InitDB()
    fsSort:Init()

    provider.State.PartyFrames = {
        player,
        p1,
        p2,
    }
end

function M:teardown()
    addon.DB.Options.World.PlayerSortMode = fsConfig.Defaults.PlayerSortMode
    addon.DB.Options.World.GroupSortMode = fsConfig.Defaults.GroupSortMode
    addon:Reset()
end

function M:test_sort_party_frames_top()
    addon.DB.Options.World.PlayerSortMode = "Top"
    addon.DB.Options.World.GroupSortMode = "Group"

    player.State.Position.Top = 100
    p1.State.Position.Top = 200
    p2.State.Position.Top = 300

    assert(fsSort:TrySort())

    assertEquals(player.State.Position.Top, 300)
    assertEquals(p1.State.Position.Top, 200)
    assertEquals(p2.State.Position.Top, 100)
end

return M
