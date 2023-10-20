---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsScheduler = addon.Scheduling.Scheduler
local fsMacro = addon.WoW.Macro
local fsLog = addon.Logging.Log
local fsTarget = addon.Modules.Targeting
local maxMacros = 138
local isSelfEditingMacro = false
---@type table<number, boolean>
local isFsMacroCache = {}
---@class MacroModule: IInitialise
local M = {}
addon.Modules.Macro = M

---@return boolean updated, boolean isFrameSortMacro, number newId
local function UpdateMacro(id, friendlyUnits, enemyUnits)
    local _, _, body = wow.GetMacroInfo(id)

    if not body or not fsMacro:IsFrameSortMacro(body) then
        return false, false, id
    end

    friendlyUnits = friendlyUnits or fsTarget:FriendlyTargets()
    enemyUnits = enemyUnits or fsTarget:EnemyTargets()

    local newBody = fsMacro:GetNewBody(body, friendlyUnits, enemyUnits)

    if not newBody then
        return false, true, id
    end

    if body == newBody then
        return false, true, id
    end

    isSelfEditingMacro = true
    local newId = wow.EditMacro(id, nil, nil, newBody)
    fsLog:Debug("Updated macro: " .. newId)
    isSelfEditingMacro = false

    return true, true, newId
end

local function ScanMacros()
    local start = wow.GetTimePreciseSec()
    local friendlyUnits = fsTarget:FriendlyTargets()
    local enemyUnits = fsTarget:EnemyTargets()
    local updatedCount = 0

    for id = 1, maxMacros do
        -- if we've already inspected this macro and it's not a framesort macro
        -- then skip attempting to re-process it
        local shouldInspect = isFsMacroCache[id] == nil or isFsMacroCache[id]

        if shouldInspect then
            local updated, isFsMacro, newId = UpdateMacro(id, friendlyUnits, enemyUnits)
            isFsMacroCache[newId] = isFsMacro

            if updated then
                updatedCount = updatedCount + 1
            end
        end
    end

    if updatedCount > 0 then
        fsLog:Debug(string.format("Updated %d macros", updatedCount))
    end

    local stop = wow.GetTimePreciseSec()
    fsLog:Debug(string.format("Update macros took %fms.", (stop - start) * 1000))
end

local function OnEditMacro(id, _, _, _)
    -- prevent recursion from EditMacro hook
    if isSelfEditingMacro then
        return
    end

    if wow.InCombatLockdown() then
        fsScheduler:RunWhenCombatEnds(function()
            local isFsMacro, newId = UpdateMacro(id)
            isFsMacroCache[newId] = isFsMacro
        end, "EditMacro" .. id)
        return
    end

    local _, isFsMacro, newId = UpdateMacro(id)
    isFsMacroCache[newId] = isFsMacro
end

function M:Run()
    assert(not wow.InCombatLockdown())

    ScanMacros()
end

function M:Init()
    if #isFsMacroCache > 0 then
        isFsMacroCache = {}
    end

    wow.hooksecurefunc("EditMacro", OnEditMacro)
end
