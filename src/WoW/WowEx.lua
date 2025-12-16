---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
---@class WowEx
addon.WoW.WowEx = {
    -- non-blizzard related
    IsInstanceBattleground = function()
        local inInstance, instanceType = wow.IsInInstance()
        local isBg = inInstance and instanceType == "pvp"

        if isBg then
            return true
        end

        if wow.C_PvP and type(wow.C_PvP) == "table" and wow.C_PvP.IsBattleground and type(wow.C_PvP.IsBattleground) == "function" then
            return wow.C_PvP.IsBattleground()
        end

        return false
    end,
}
