local _, addon = ...
---@type WoW
local wow = addon.WoW
local fsScheduler = addon.Scheduler
local fsFrame = addon.Frame
local fsSort = addon.Sorting
local fsMacro = addon.Macro
local fsTarget = addon.Target
local fsLog = addon.Log
local maxMacros = 138
local isSelfEditingMacro = false
---@type table<number, boolean>
local isFsMacroCache = nil

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

---Initialises the macros module.
function addon:InitMacros()
    isFsMacroCache = {}

    for _, provider in ipairs(fsFrame.Providers:Enabled()) do
        provider:RegisterCallback(Run)
    end

    fsSort:RegisterPostSortCallback(Run)
    wow.hooksecurefunc("EditMacro", OnEditMacro)
end
