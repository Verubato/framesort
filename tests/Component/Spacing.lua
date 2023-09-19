local addon = require("Addon")
local frame = require("Mock\\Frame")
local fsProviders = addon.Providers
local realBlizzardProvider = fsProviders.Blizzard
local provider = fsProviders.Test
local fsConfig = addon.Configuration
local fsSpacing = addon.Modules.Spacing

local M = {}
local frameHeight = 100
local partyContainer = frame:New()
-- 3 frames with no spacing between them
-- player = top
-- p1 = middle
-- p2 = bottom
local player = frame:New("Frame", nil, partyContainer, nil)
player.State.Position.Left = 0
player.State.Position.Top = 500
player.State.Position.Bottom = player.State.Position.Top - frameHeight
player.unit = "player"

local p1 = frame:New("Frame", nil, partyContainer, nil)
p1.State.Position.Left = 0
p1.State.Position.Top = player.State.Position.Bottom
p1.State.Position.Bottom = p1.State.Position.Top - frameHeight
p1.unit = "party1"

local p2 = frame:New("Frame", nil, partyContainer, nil)
p2.State.Position.Left = 0
p2.State.Position.Top = p1.State.Position.Bottom
p2.State.Position.Bottom = p2.State.Position.Top - frameHeight
p2.unit = "party2"

function M:setup()
    addon:InitDB()
    fsSpacing:Init()

    provider.State.PartyFrames = {
        player,
        p1,
        p2,
    }

    fsProviders.Blizzard = provider
end

function M:teardown()
    addon.DB.Options.Appearance.Party.Spacing.Vertical = fsConfig.Defaults.Appearance.Party.Spacing.Vertical
    fsProviders.Blizzard = realBlizzardProvider
    addon:Reset()
end

function M:test_sort_party_frames_top()
    addon.DB.Options.Appearance.Party.Spacing.Vertical = 10

    fsSpacing:ApplySpacing()

    -- top frame shouldn't have moved
    assertEquals(player.State.Position.Top, 500)
    -- next frame down should have moved 10 units from 400 to 390
    assertEquals(p1.State.Position.Top, 390)
    -- next frame down should have moved 20 units from 300 to 280
    assertEquals(p2.State.Position.Top, 280)
end

return M
