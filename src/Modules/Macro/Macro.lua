---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsScheduler = addon.Scheduling.Scheduler
local fsMacroParser = addon.Modules.Macro.Parser
local fsLog = addon.Logging.Log
local fsTarget = addon.Modules.Targeting
local maxMacros = 138
local isSelfEditingMacro = false
---@type table<number, boolean>
local isFsMacroCache = {}
---@class MacroModule: IInitialise
local M = addon.Modules.Macro

---@return boolean updated, boolean isFrameSortMacro, number newId
local function Rewrite(id, friendlyUnits, enemyUnits)
    local _, _, body = wow.GetMacroInfo(id)

    if not body or not fsMacroParser:IsFrameSortMacro(body) then
        return false, false, id
    end

    local newBody = fsMacroParser:GetNewBody(body, friendlyUnits, enemyUnits)

    if not newBody then
        return false, true, id
    end

    if body == newBody then
        return false, true, id
    end

    isSelfEditingMacro = true
    local newId = wow.EditMacro(id, nil, nil, newBody)
    isSelfEditingMacro = false

    return true, true, newId
end

local function UpdateMacro(id, friendlyUnits, enemyUnits, bypassCache)
    -- if we've already inspected this macro and it's not a framesort macro
    -- then skip attempting to re-process it
    local shouldInspect = bypassCache or isFsMacroCache[id] == nil or isFsMacroCache[id]

    if not shouldInspect then
        return false
    end

    friendlyUnits = friendlyUnits or fsTarget:FriendlyTargets()
    enemyUnits = enemyUnits or fsTarget:EnemyTargets()

    local updated, isFsMacro, newId = Rewrite(id, friendlyUnits, enemyUnits)
    isFsMacroCache[newId] = isFsMacro

    if id ~= newId then
        -- invalidate the old id if it changed
        -- I believe the id only changes when the name or icon is updated which we don't touch
        -- better to be safe though
        isFsMacroCache[id] = nil
    end

    return updated
end

local function ScanMacros()
    local start = wow.GetTimePreciseSec()
    local friendlyUnits = fsTarget:FriendlyTargets()
    local enemyUnits = fsTarget:EnemyTargets()
    local updatedCount = 0

    for id = 1, maxMacros do
        local updated = UpdateMacro(id, friendlyUnits, enemyUnits, false)

        if updated then
            updatedCount = updatedCount + 1
        end
    end

    local stop = wow.GetTimePreciseSec()
    fsLog:Debug(string.format("Update macros took %fms, %d updated.", (stop - start) * 1000, updatedCount))
end

local function OnEditMacro(id, _, _, _)
    -- prevent recursion from EditMacro hook
    if isSelfEditingMacro then
        return
    end

    fsScheduler:RunWhenCombatEnds(function()
        local updated = UpdateMacro(id, nil, nil, true)

        if updated then
            fsLog:Debug("Updated macro: " .. id)
        end
    end, "EditMacro" .. id)
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
