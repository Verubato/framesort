---@type Addon
local addon
---@type SortingModule
local fsSort
---@type FrameUtil
local fsFrame

local M = {}
local player = nil
local p1 = nil
local p2 = nil

function M:setup()
    local addonFactory = require("TestHarness\\AddonFactory")
    local providerFactory = require("TestHarness\\ProviderFactory")
    local frameMock = require("TestHarness\\Frame")

    addon = addonFactory:Create()
    fsSort = addon.Modules.Sorting
    fsFrame = addon.WoW.Frame

    local provider = providerFactory:Create()
    addon.Providers.Test = provider
    addon.Providers.All[#addon.Providers.All + 1] = provider

    local party = fsFrame:GetContainer(provider, fsFrame.ContainerType.Party)
    local partyContainer = assert(party).Frame

    assert(partyContainer)

    player = frameMock:New("Frame", nil, partyContainer)
    player.unit = "player"

    p1 = frameMock:New("Frame", nil, partyContainer)
    p1.unit = "party1"

    p2 = frameMock:New("Frame", nil, partyContainer)
    p2.unit = "party2"
end

function M:test_space_party_frames()
    addon.DB.Options.Spacing.Party.Vertical = 10

    local config = addon.DB.Options.Sorting.World
    config.Enabled = true
    config.PlayerSortMode = "Top"
    config.GroupSortMode = "Group"

    local width = 100
    local height = 100
    local party = fsFrame:GetContainer(addon.Providers.Test, fsFrame.ContainerType.Party)
    local partyContainer = assert(party).Frame

    assert(player)
    assert(p1)
    assert(p2)

    -- 3 frames with no spacing between them
    -- player = top
    -- p1 = middle
    -- p2 = bottom
    player:SetPoint("TOPLEFT", partyContainer, "TOPLEFT", 0, 0)
    player:SetPosition(height * 3, 0, width, height * 2)

    p1:SetPoint("TOPLEFT", p2, "BOTTOMLEFT", 0, 0)
    p1:SetPosition(height * 2, 0, width, height)

    p2:SetPoint("TOPLEFT", player, "BOTTOMLEFT", 0, 0)
    p2:SetPosition(height, 0, width, 0)

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
            YOffset = -110,
        })

    -- next frame down should have moved 20 units
    assertEquals(toPos(p2.State.Point),
        {
            Point = "TOPLEFT",
            RelativeTo = partyContainer:GetName(),
            RelativePoint = "TOPLEFT",
            XOffset = 0,
            YOffset = -220,
        })
end

return M
