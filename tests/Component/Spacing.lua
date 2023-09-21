local addon = require("Addon")
local frame = require("Mock\\Frame")
local fsProviders = addon.Providers
local provider = fsProviders.Test
local realBlizzardProvider = fsProviders.Blizzard
local fsCore = addon.Modules.Sorting.Core

local M = {}
local player = frame:New("Frame", "Player")
player.unit = "player"

local p1 = frame:New("Frame", "Party1")
p1.unit = "party1"

local p2 = frame:New("Frame", "Party2")
p2.unit = "party2"

function M:setup()
    addon:InitDB()

    provider.State.PartyFrames = {
        player,
        p1,
        p2,
    }

    fsProviders.Blizzard = provider
end

function M:teardown()
    addon:Reset()
    fsProviders.Blizzard = realBlizzardProvider
end

function M:test_sort_party_frames_top()
    addon.DB.Options.Appearance.Party.Spacing.Vertical = 10
    addon.DB.Options.World.PlayerSortMode = "Top"
    addon.DB.Options.World.GroupSortMode = "Group"

    local width = 100
    local height = 100

    -- 3 frames with no spacing between them
    -- player = top
    -- p1 = middle
    -- p2 = bottom
    player:SetPoint("TOPLEFT", provider:PartyContainer(), "BOTTOMLEFT", 0, 0)
    player:SetPosition(0, 0, width, -height)
    p1:SetPoint("TOPLEFT", player, "BOTTOMLEFT", 0, 0)
    p1:SetPosition(-height, 0, width, -height * 2)
    p2:SetPoint("TOPLEFT", provider:PartyContainer(), "TOPLEFT", 0, 0)
    p2:SetPosition(-height * 2, 0, width, -height * 3)

    fsCore.Test = true
    assert(fsCore:TrySort(provider))

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
            RelativeTo = provider:PartyContainer():GetName(),
            RelativePoint = "TOPLEFT",
            XOffset = 0,
            YOffset = 0,
        })

    -- next frame down should have moved 10 units
    assertEquals(toPos(p1.State.Point),
        {
            Point = "TOPLEFT",
            RelativeTo = provider:PartyContainer():GetName(),
            RelativePoint = "TOPLEFT",
            XOffset = 0,
            YOffset = 90,
        })

    -- next frame down should have moved 20 units
    assertEquals(toPos(p2.State.Point),
        {
            Point = "TOPLEFT",
            RelativeTo = provider:PartyContainer():GetName(),
            RelativePoint = "TOPLEFT",
            XOffset = 0,
            YOffset = 180,
        })
end

return M
