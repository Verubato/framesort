---@diagnostic disable: undefined-global
---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api

---@class ClientCapabilities
local M = {}

addon.WoW.Capabilities = M

function M.HasDropdown()
    return WowStyle1DropdownTemplate ~= nil
end

function M.HasEnemySpecSupport()
    -- MoP onwards have these functions; early xpacs do not
    return wow.GetArenaOpponentSpec ~= nil and wow.GetSpecializationInfoByID ~= nil
end

function M.HasArena()
    return LE_EXPANSION_BURNING_CRUSADE and LE_EXPANSION_LEVEL_CURRENT >= LE_EXPANSION_BURNING_CRUSADE
end

function M.Has5v5()
    return LE_EXPANSION_BURNING_CRUSADE and LE_EXPANSION_LEVEL_CURRENT == LE_EXPANSION_BURNING_CRUSADE
end

function M.CanOpenOptionsDuringCombat()
    return not LE_EXPANSION_MIDNIGHT or LE_EXPANSION_LEVEL_CURRENT < LE_EXPANSION_MIDNIGHT
end

function M.HasC_PvP()
    return type(wow.C_PvP) == "table" and type(wow.C_PvP.GetActiveMatchState) == "function"
end

function M.HasC_Map()
    return type(wow.C_Map) == "table" and type(wow.C_Map.GetBestMapForUnit) == "function"
end

function M.HasSoloShuffle()
    return M.HasC_PvP() and wow.C_PvP.IsSoloShuffle ~= nil and type(wow.C_PvP.IsSoloShuffle) == "function" and wow.Enum and type(wow.Enum) == "table" and wow.Enum.PvPMatchState ~= nil
end

function M.HasBrawl()
    return M.HasC_PvP() and wow.C_PvP.IsInBrawl ~= nil and type(wow.C_PvP.IsInBrawl) == "function"
end

function M.HasEditMode()
    return wow.EditModeManagerFrame ~= nil and wow.EditModeManagerFrame.UseRaidStylePartyFrames ~= nil and wow.EditModeManagerFrame.GetSettingValue ~= nil and wow.EventRegistry ~= nil
end

function M.HasSpecializations()
    -- specs were introduced in MoP, and prior expansions used a talent system
    return LE_EXPANSION_LEVEL_CURRENT >= LE_EXPANSION_MISTS_OF_PANDARIA
end
