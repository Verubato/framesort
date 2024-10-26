---@type Addon
local addon
local M = {}
local player

function M:setup()
    local addonFactory = require("Mock\\AddonFactory")
    local providerFactory = require("Mock\\ProviderFactory")
    local frameMock = require("Mock\\Frame")

    addon = addonFactory:Create()

    local fsFrame = addon.WoW.Frame
    local provider = providerFactory:Create()

    addon.Providers.Test = provider
    addon.Providers.All[#addon.Providers.All + 1] = provider
    addon.Providers.Blizzard = provider

    addon.Modules:Init()

    local party = fsFrame:GetContainer(provider, fsFrame.ContainerType.Party)
    local partyContainer = party.Frame

    player = frameMock:New("Frame", nil, partyContainer, nil)
    player.State.Position.Top = 300
    player.unit = "player"

    local p1 = frameMock:New("Frame", nil, partyContainer, nil)
    p1.State.Position.Top = 200
    p1.unit = "party1"

    local p2 = frameMock:New("Frame", nil, partyContainer, nil)
    p2.State.Position.Top = 100
    p2.unit = "party2"

    addon.WoW.Api.UnitExists = function(unit)
        return unit == "player" or unit == "party1" or unit == "party2"
    end
end

function M:test_player_shows_and_hides()
    local config = addon.DB.Options.Sorting.World
    config.Enabled = true

    -- hide the player first
    config.PlayerSortMode = "Hidden"
    addon.Modules:Run()

    assert(not player.State.HasUnitWatch)
    assert(not player:IsVisible())

    config.PlayerSortMode = "Top"
    addon.Modules:Run()

    assert(player.State.HasUnitWatch)
    assert(player:IsVisible())
end

return M
