---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsLog = addon.Logging.Log

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
            local count = wow.GetNumArenaOpponents()

            if count and count > 0 then
                return count
            end
        end

        if wow.GetNumArenaOpponentSpecs then
            local count = wow.GetNumArenaOpponentSpecs()

            if count and count > 0 then
                return count
            end
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

    ---Wraps GetArenaOpponentSpec() and returns nil instead of 0
    ---@param id number
    ---@return number|nil
    GetArenaOpponentSpecSafe = function(id)
        if type(id) ~= "number" then
            fsLog:Error("WowEx:GetArenaOpponentSpecSafe() - id must be a number, instead received %s.", type(id))
            return nil
        end

        if not wow.GetArenaOpponentSpec then
            return nil
        end

        local spec = wow.GetArenaOpponentSpec(id)

        if not spec or spec == 0 then
            return nil
        end

        return spec
    end,

    ---Wraps GetInspectSpecialization() and returns nil instead of 0
    ---@param unit string
    ---@return number|nil
    GetInspectSpecializationSafe = function(unit)
        if type(unit) ~= "string" then
            fsLog:Error("WowEx:GetInspectSpecializationSafe() - unit must be a string, instead received %s.", type(unit))
            return nil
        end

        if not wow.GetInspectSpecialization then
            return nil
        end

        local spec = wow.GetInspectSpecialization(unit)

        if not spec or spec == 0 then
            return nil
        end

        return spec
    end,
}
