---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
---@class WowEx
addon.WoW.WowEx = {
    ---@return boolean
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

    ---@return number
    ArenaOpponentsCount = function()
        if wow.GetNumArenaOpponents then
            return wow.GetNumArenaOpponents()
        end

        if wow.GetNumArenaOpponentSpecs then
            return wow.GetNumArenaOpponentSpecs()
        end

        return 0
    end,

    ---@return number
    GroupMembersCount = function()
        if wow.GetNumGroupMembers then
            return wow.GetNumGroupMembers()
        end

        if wow.GetNumRaidMembers then
            local count = wow.GetNumRaidMembers()

            if count > 0 then
                return count
            end
        end

        if wow.GetNumPartyMembers then
            local count = wow.GetNumPartyMembers()

            if count > 0 then
                return count
            end
        end

        return 0
    end,
}
