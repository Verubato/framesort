local addon = require("Addon")
local frame = require("Mock\\Frame")
local wow = addon.WoW.Api
local provider = addon.Providers.Test
local M = {}

function M:setup()
    addon:InitDB()
    addon.Providers:Init()
    addon.Scheduling.Scheduler:Init()
    addon.Modules.Targeting:Init()

    local partyContainer = frame:New()
    local player = frame:New("Frame", nil, partyContainer, nil)
    player.State.Position.Top = 300
    player.unit = "player"

    local p1 = frame:New("Frame", nil, partyContainer, nil)
    p1.State.Position.Top = 100
    p1.unit = "party1"

    local p2 = frame:New("Frame", nil, partyContainer, nil)
    p2.State.Position.Top = 200
    p2.unit = "party2"

    provider.State.PartyFrames = {
        player,
        p1,
        p2,
    }

    local arenaContainer = frame:New()
    local arena1 = frame:New("Frame", nil, arenaContainer, nil)
    arena1.State.Position.Top = 300
    arena1.unit = "arena1"

    local arena2 = frame:New("Frame", nil, arenaContainer, nil)
    arena2.State.Position.Top = 100
    arena2.unit = "arena2"

    local arena3 = frame:New("Frame", nil, arenaContainer, nil)
    arena3.State.Position.Top = 200
    arena3.unit = "arena3"

    provider.State.EnemyArenaFrames = {
        arena1,
        arena2,
        arena3,
    }
end

function M:teardown()
    addon:Reset()
end

function M:test_targets_update_on_provider_callback()
    local friendlyButtons = {}
    local enemyButtons = {}

    for _, frame in ipairs(wow.State.Frames) do
        if frame.Name and type(frame.Name) == "string" then
            if string.match(frame.Name, "FSTarget%d") then
                friendlyButtons[#friendlyButtons + 1] = frame
            elseif string.match(frame.Name, "FSTargetEnemy%d") then
                enemyButtons[#enemyButtons + 1] = frame
            end
        end
    end

    table.sort(friendlyButtons, function(a, b)
        return a.Name < b.Name
    end)

    table.sort(enemyButtons, function(a, b)
        return a.Name < b.Name
    end)

    assertEquals(#friendlyButtons, 5)
    assertEquals(#enemyButtons, 3)

    for _, frame in ipairs(friendlyButtons) do
        local unit = frame:GetAttribute("unit")
        assertEquals(unit, "none")
    end

    for _, frame in ipairs(enemyButtons) do
        local unit = frame:GetAttribute("unit")
        assertEquals(unit, "none")
    end

    provider:FireCallbacks()

    assertEquals(friendlyButtons[1]:GetAttribute("unit"), "player")
    assertEquals(friendlyButtons[2]:GetAttribute("unit"), "party2")
    assertEquals(friendlyButtons[3]:GetAttribute("unit"), "party1")
    assertEquals(friendlyButtons[4]:GetAttribute("unit"), "none")
    assertEquals(friendlyButtons[5]:GetAttribute("unit"), "none")

    assertEquals(enemyButtons[1]:GetAttribute("unit"), "arena1")
    assertEquals(enemyButtons[2]:GetAttribute("unit"), "arena3")
    assertEquals(enemyButtons[3]:GetAttribute("unit"), "arena2")
end

function M:test_targets_update_after_combat()
    local friendlyButtons = {}
    local enemyButtons = {}

    for _, frame in ipairs(wow.State.Frames) do
        if frame.Name and type(frame.Name) == "string" then
            if string.match(frame.Name, "FSTarget%d") then
                friendlyButtons[#friendlyButtons + 1] = frame
            elseif string.match(frame.Name, "FSTargetEnemy%d") then
                enemyButtons[#enemyButtons + 1] = frame
            end
        end
    end

    table.sort(friendlyButtons, function(a, b)
        return a.Name < b.Name
    end)

    table.sort(enemyButtons, function(a, b)
        return a.Name < b.Name
    end)

    assertEquals(#friendlyButtons, 5)
    assertEquals(#enemyButtons, 3)

    for _, frame in ipairs(friendlyButtons) do
        local unit = frame:GetAttribute("unit")
        assertEquals(unit, "none")
    end

    for _, frame in ipairs(enemyButtons) do
        local unit = frame:GetAttribute("unit")
        assertEquals(unit, "none")
    end

    wow.State.MockInCombat = true
    provider:FireCallbacks()

    -- assert nothing changed as we're in combat
    for _, frame in ipairs(friendlyButtons) do
        local unit = frame:GetAttribute("unit")
        assertEquals(unit, "none")
    end

    for _, frame in ipairs(enemyButtons) do
        local unit = frame:GetAttribute("unit")
        assertEquals(unit, "none")
    end

    wow.State.MockInCombat = false
    wow:FireEvent(wow.Events.PLAYER_REGEN_ENABLED)

    assertEquals(friendlyButtons[1]:GetAttribute("unit"), "player")
    assertEquals(friendlyButtons[2]:GetAttribute("unit"), "party2")
    assertEquals(friendlyButtons[3]:GetAttribute("unit"), "party1")
    assertEquals(friendlyButtons[4]:GetAttribute("unit"), "none")
    assertEquals(friendlyButtons[5]:GetAttribute("unit"), "none")

    assertEquals(enemyButtons[1]:GetAttribute("unit"), "arena1")
    assertEquals(enemyButtons[2]:GetAttribute("unit"), "arena3")
    assertEquals(enemyButtons[3]:GetAttribute("unit"), "arena2")
end

return M