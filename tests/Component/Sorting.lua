local addon = require("Addon")
local frame = require("Mock\\Frame")
local provider = addon.Providers.Test
local realBlizzardProvider = addon.Providers.Blizzard
local fsConfig = addon.Configuration
local fsSort = addon.Modules.Sorting

local M = {}

local p2 = frame:New("Frame", "Party2")
p2.unit = "party2"

local player = frame:New("Frame", "Player")
player.unit = "player"

local p1 = frame:New("Frame", "Player1")
p1.unit = "party1"

function M:setup()
    addon:InitDB()
    fsSort:Init()

    provider.State.PartyFrames = {
        player,
        p1,
        p2,
    }

    addon.Providers.Blizzard = provider
end

function M:teardown()
    addon.DB.Options.World.PlayerSortMode = fsConfig.Defaults.PlayerSortMode
    addon.DB.Options.World.GroupSortMode = fsConfig.Defaults.GroupSortMode
    addon.Providers.Blizzard = realBlizzardProvider
    addon:Reset()
end

function M:test_sort_party_frames_top()
    addon.DB.Options.World.PlayerSortMode = "Top"
    addon.DB.Options.World.GroupSortMode = "Group"

    local width = 100
    local height = 100

    -- player = top
    -- p1 = middle
    -- p2 = bottom
    p2:SetPoint("TOPLEFT", provider:PartyContainer(), "TOPLEFT", 0, 0)
    p2:SetPosition(0, 0, width, -height)
    player:SetPoint("TOPLEFT", p2, "BOTTOMLEFT", 0, 0)
    player:SetPosition(-height, 0, width, -height * 2)
    p1:SetPoint("TOPLEFT", player, "BOTTOMLEFT", 0, 0)
    p1:SetPosition(-height * 2, 0, width, -height * 3)

    assert(fsSort:TrySort())

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
            RelativeTo = provider:PartyContainer():GetName(),
            RelativePoint = "TOPLEFT",
            XOffset = 0,
            YOffset = 0,
        })

    assertEquals(toPos(p1.State.Point),
        {
            Point = "TOPLEFT",
            RelativeTo = provider:PartyContainer():GetName(),
            RelativePoint = "TOPLEFT",
            XOffset = 0,
            YOffset = 100,
        })

    assertEquals(toPos(p2.State.Point),
        {
            Point = "TOPLEFT",
            RelativeTo = provider:PartyContainer():GetName(),
            RelativePoint = "TOPLEFT",
            XOffset = 0,
            YOffset = 200,
        })
end

return M
