---@diagnostic disable: inject-field
local addon = require("Mock\\Addon")
local frame = require("Mock\\Frame")
local wow = addon.WoW.Api
local provider = addon.Providers.Test
local fsFrame = addon.WoW.Frame
local M = {}
local restoreFunctions = {}

function M:setup()
    addon:InitDB()
    addon.Providers:Init()
    addon.Scheduling.Scheduler:Init()
    addon.Modules:Init()

    local party = fsFrame:GetContainer(provider, fsFrame.ContainerType.Party)
    local partyContainer = assert(party).Frame

    assert(partyContainer)

    local player = frame:New("Frame", nil, partyContainer, nil)
    player.State.Position.Top = 300
    player.unit = "player"

    local p1 = frame:New("Frame", nil, partyContainer, nil)
    p1.State.Position.Top = 100
    p1.unit = "party1"

    local p2 = frame:New("Frame", nil, partyContainer, nil)
    p2.State.Position.Top = 200
    p2.unit = "party2"

    local arena = fsFrame:GetContainer(provider, fsFrame.ContainerType.EnemyArena)
    local arenaContainer = assert(arena).Frame
    assert(arenaContainer)

    -- enemy arena units aren't retrieved from the frame position
    -- so their position doesn't matter
    local arena1 = frame:New("Frame", nil, arenaContainer, nil)
    arena1.State.Position.Top = 100
    arena1.unit = "arena1"

    local arena2 = frame:New("Frame", nil, arenaContainer, nil)
    arena2.State.Position.Top = 200
    arena2.unit = "arena2"

    local arena3 = frame:New("Frame", nil, arenaContainer, nil)
    arena3.State.Position.Top = 300
    arena3.unit = "arena3"

    restoreFunctions.GetNumGroupMembers = wow.GetNumGroupMembers
    restoreFunctions.GetNumArenaOpponentSpecs = wow.GetNumArenaOpponentSpecs
    restoreFunctions.IsInGroup = wow.IsInGroup
    restoreFunctions.IsInInstance = wow.IsInGroup

    wow.GetNumGroupMembers = function() return 3 end
    wow.GetNumArenaOpponentSpecs = function() return 3 end
    wow.IsInGroup = function() return true end
    wow.IsInInstance = function() return true, "arena" end

    local config = addon.DB.Options.Sorting.EnemyArena
    config.Enabled = true
    config.Reverse = true
    config.GroupSortMode = "Group"
end

function M:teardown()
    addon:Reset()

    wow.GetNumGroupMembers = restoreFunctions.GetNumGroupMembers
    wow.GetNumArenaOpponentSpecs = restoreFunctions.GetNumArenaOpponentSpecs
    wow.IsInGroup = restoreFunctions.IsInGroup
    wow.IsInInstance = restoreFunctions.IsInGroup
end

function M:test_targets_update_on_provider_callback()
    local friendlyButtons = {}
    local friendlyPetButtons = {}
    local enemyButtons = {}
    local enemyPetButtons = {}

    for _, f in ipairs(wow.State.Frames) do
        if f.Name and type(f.Name) == "string" then
            if string.match(f.Name, "FSTarget%d") then
                friendlyButtons[#friendlyButtons + 1] = f
            elseif string.match(f.Name, "FSTargetEnemy%d") then
                enemyButtons[#enemyButtons + 1] = f
            elseif string.match(f.Name, "FSTargetPet%d") then
                friendlyPetButtons[#friendlyPetButtons + 1] = f
            elseif string.match(f.Name, "FSTargetEnemyPet%d") then
                enemyPetButtons[#enemyPetButtons + 1] = f
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

    -- ensure there is nothing already set
    for _, f in ipairs(friendlyButtons) do
        f:SetAttribute("unit", "none")
    end

    for _, f in ipairs(enemyButtons) do
        f:SetAttribute("unit", "none")
    end

    addon.Modules.Targeting:Run()

    assertEquals(friendlyButtons[1]:GetAttribute("unit"), "player")
    assertEquals(friendlyButtons[2]:GetAttribute("unit"), "party2")
    assertEquals(friendlyButtons[3]:GetAttribute("unit"), "party1")
    assertEquals(friendlyButtons[4]:GetAttribute("unit"), "none")
    assertEquals(friendlyButtons[5]:GetAttribute("unit"), "none")

    assertEquals(enemyButtons[1]:GetAttribute("unit"), "arena3")
    assertEquals(enemyButtons[2]:GetAttribute("unit"), "arena2")
    assertEquals(enemyButtons[3]:GetAttribute("unit"), "arena1")

    -- pets
    assertEquals(friendlyPetButtons[1]:GetAttribute("unit"), "pet")
    assertEquals(friendlyPetButtons[2]:GetAttribute("unit"), "partypet2")
    assertEquals(friendlyPetButtons[3]:GetAttribute("unit"), "partypet1")
    assertEquals(friendlyPetButtons[4]:GetAttribute("unit"), "none")
    assertEquals(friendlyPetButtons[5]:GetAttribute("unit"), "none")

    assertEquals(enemyPetButtons[1]:GetAttribute("unit"), "arenapet3")
    assertEquals(enemyPetButtons[2]:GetAttribute("unit"), "arenapet2")
    assertEquals(enemyPetButtons[3]:GetAttribute("unit"), "arenapet1")
end

function M:test_targets_update_after_combat()
    local friendlyButtons = {}
    local enemyButtons = {}

    for _, f in ipairs(wow.State.Frames) do
        if f.Name and type(f.Name) == "string" then
            if string.match(f.Name, "FSTarget%d") then
                friendlyButtons[#friendlyButtons + 1] = f
            elseif string.match(f.Name, "FSTargetEnemy%d") then
                enemyButtons[#enemyButtons + 1] = f
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

    for _, f in ipairs(friendlyButtons) do
        f:SetAttribute("unit", "none")
    end

    for _, f in ipairs(enemyButtons) do
        f:SetAttribute("unit", "none")
    end

    wow.State.MockInCombat = true

    addon.Modules:Run()

    -- assert nothing changed as we're in combat
    for _, f in ipairs(friendlyButtons) do
        local unit = f:GetAttribute("unit")
        assertEquals(unit, "none")
    end

    for _, f in ipairs(enemyButtons) do
        local unit = f:GetAttribute("unit")
        assertEquals(unit, "none")
    end

    wow.State.MockInCombat = false
    wow:FireEvent(wow.Events.PLAYER_REGEN_ENABLED)

    assertEquals(friendlyButtons[1]:GetAttribute("unit"), "player")
    assertEquals(friendlyButtons[2]:GetAttribute("unit"), "party2")
    assertEquals(friendlyButtons[3]:GetAttribute("unit"), "party1")
    assertEquals(friendlyButtons[4]:GetAttribute("unit"), "none")
    assertEquals(friendlyButtons[5]:GetAttribute("unit"), "none")

    assertEquals(enemyButtons[1]:GetAttribute("unit"), "arena3")
    assertEquals(enemyButtons[2]:GetAttribute("unit"), "arena2")
    assertEquals(enemyButtons[3]:GetAttribute("unit"), "arena1")
end

return M
