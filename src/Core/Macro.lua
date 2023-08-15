local _, addon = ...
local fsScheduler = addon.Scheduler
local fsFrame = addon.Frame
local fsSort = addon.Sorting
local fsMacro = addon.Macro
local fsTarget = addon.Target
local maxMacros = 138
local isSelfEditingMacro = false
---@type table<number, boolean>
local isFsMacroCache = {}

local function CanUpdate()
    return true
end

local function InspectMacro(slot)
    local _, _, body = GetMacroInfo(slot)

    if not body or not fsMacro:IsFrameSortMacro(body) then
        return false
    end

    local friendlyUnits = fsTarget:FriendlyTargets()
    local enemyUnits = fsTarget:EnemyTargets()
    local newBody = fsMacro:GetNewBody(body, friendlyUnits, enemyUnits)

    if not newBody then
        return false
    end

    isSelfEditingMacro = true
    EditMacro(slot, nil, nil, newBody)
    isSelfEditingMacro = false

    return true
end

local function ScanMacros()
    for slot = 1, maxMacros do
        -- if we've already inspected this macro and it's not a framesort macro
        -- then skip attempting to re-process it
        local shouldInspect = isFsMacroCache[slot] == nil or isFsMacroCache[slot]

        if shouldInspect then
            isFsMacroCache[slot] = InspectMacro(slot)
        end
    end
end

local function OnEditMacro(slot, _, _, _)
    -- prevent recursion from EditMacro hook
    if isSelfEditingMacro then
        return
    end

    if InCombatLockdown() then
        fsScheduler:RunWhenCombatEnds(function()
            isFsMacroCache[slot] = InspectMacro(slot)
        end)
        fsLog:Warning("Can't update macros during combat.")
        return
    end

    isFsMacroCache[slot] = InspectMacro(slot)
end

local function Run()
    if InCombatLockdown() then
        fsScheduler:RunWhenCombatEnds(ScanMacros)
        fsLog:Warning("Can't update macros during combat.")
        return
    end

    ScanMacros()
end

---Initialises the macros module.
function addon:InitMacros()
    for _, provider in ipairs(fsFrame.Providers:Enabled()) do
        provider:RegisterCallback(Run)
    end

    fsSort:RegisterPostSortCallback(Run)

    hooksecurefunc("EditMacro", OnEditMacro)
end
