---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local capabilities = addon.WoW.Capabilities
local fsLog = addon.Logging.Log

---@class WowEx
addon.WoW.WowEx = {
    ---@return boolean
    IsInstanceArena = function()
        local inInstance, instanceType = wow.IsInInstance()

        if not inInstance then
            return false
        end

        return instanceType == "arena"
    end,

    ---@return boolean
    IsInstanceBattleground = function()
        local inInstance, instanceType = wow.IsInInstance()
        local isBg = inInstance and instanceType == "pvp"

        if isBg then
            return true
        end

        if type(wow.C_PvP) == "table" and type(wow.C_PvP.IsBattleground) == "function" then
            return wow.C_PvP.IsBattleground()
        end

        return false
    end,

    ---@return boolean
    IsInstanceBrawl = function()
        local inInstance, instanceType = wow.IsInInstance()

        if not inInstance then
            return false
        end

        if type(wow.C_PvP) == "table" and type(wow.C_PvP.IsInBrawl) == "function" then
            return wow.C_PvP.IsInBrawl()
        end

        return false
    end,

    ---@return number
    ArenaOpponentsCount = function()
        -- prefer GetNumArenaOpponentSpecs as it seems reliable
        if capabilities.HasSpecializations() and capabilities.HasEnemySpecSupport() and wow.GetNumArenaOpponentSpecs then
            -- event if 0 is returned, still use it without fallback as it means spec information isn't available anyway
            return wow.GetNumArenaOpponentSpecs()
        end

        if wow.GetNumArenaOpponents then
            -- GetNumArenaOpponents sometimes lies and returns a greater number
            -- e.g. reports 4 enemies in 3v3
            -- seems to be related to pet classes where ally pets are classified as enemies for a split second
            local enemyCount = wow.GetNumArenaOpponents()

            -- compare our friendly group size to get a somewhat reasonable guestimate
            local allyCount = addon.WoW.WowEx.GroupMembersCount()

            return math.min(allyCount, enemyCount)
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

    IsAddOnEnabled = function(addonName)
        return wow.GetAddOnEnableState(addonName, wow.UnitName("player")) == 2
    end,
}
