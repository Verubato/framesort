---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsScheduler = addon.Scheduling.Scheduler
local fsMacro = addon.WoW.Macro
local fsLog = addon.Logging.Log
local fsTarget = addon.Modules.Targeting
local fsSort = addon.Modules.Sorting
local fsProviders = addon.Providers
local maxMacros = 138
local isSelfEditingMacro = false
---@type table<number, boolean>
local isFsMacroCache = {}
---@class MacroModule: Initialise
local M = {}
addon.Modules.Macro = M

local function UpdateMacro(id)
    local _, _, body = wow.GetMacroInfo(id)

    if not body or not fsMacro:IsFrameSortMacro(body) then
        return false, id
    end

    local friendlyUnits = fsTarget:FriendlyTargets()
    local enemyUnits = fsTarget:EnemyTargets()
    local newBody = fsMacro:GetNewBody(body, friendlyUnits, enemyUnits)

    if not newBody then
        return false, id
    end

    isSelfEditingMacro = true
    local newId = wow.EditMacro(id, nil, nil, newBody)
    isSelfEditingMacro = false

    return true, newId
end

local function ScanMacros()
    for id = 1, maxMacros do
        -- if we've already inspected this macro and it's not a framesort macro
        -- then skip attempting to re-process it
        local shouldInspect = isFsMacroCache[id] == nil or isFsMacroCache[id]

        if shouldInspect then
            local isFsMacro, newId = UpdateMacro(id)
            isFsMacroCache[newId] = isFsMacro
        end
    end
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
        end)
        fsLog:Warning("Can't update macros during combat.")
        return
    end

    local isFsMacro, newId = UpdateMacro(id)
    isFsMacroCache[newId] = isFsMacro
end

local function Run()
    if wow.InCombatLockdown() then
        fsScheduler:RunWhenCombatEnds(ScanMacros)
        fsLog:Warning("Can't update macros during combat.")
        return
    end

    ScanMacros()
end

function M:Init()
    if #isFsMacroCache > 0 then
        isFsMacroCache = {}
    end

    for _, provider in ipairs(fsProviders:Enabled()) do
        provider:RegisterCallback(Run)
    end

    fsSort:RegisterPostSortCallback(Run)
    wow.hooksecurefunc("EditMacro", OnEditMacro)
end
