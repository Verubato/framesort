---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local wowEx = addon.WoW.WowEx
local events = addon.WoW.Events
local capabilities = addon.WoW.Capabilities
local fsSpec = addon.Configuration.Specs
local fsLog = addon.Logging.Log

---@class EnemyAssignmentsModule : IProcessEvents
local M = {}
addon.Modules.EnemyAssignments = M

local maxSlots = 5

-- the enemy count when neither the enemy team nor our own group has a size yet
local defaultCount = 3

local validRoles = {
    [wowEx.Role.Tank] = true,
    [wowEx.Role.Healer] = true,
    [wowEx.Role.Dps] = true,
}

-- key = arena slot, value = { Role: string, SpecId: number|nil, Filled: boolean|nil }
-- Filled marks a row the healer rule added rather than the user.
local assignments = {}

local changedCallbacks = {}
local notifyCallbacks = {}
local promptCallbacks = {}

-- true once the prompt has been offered this round
local promptShown = false

local function Invoke(callbacks, name, ...)
    for _, callback in ipairs(callbacks) do
        local ok, err = pcall(callback, ...)

        if not ok then
            fsLog:Error("%s callback failed: %s", name, tostring(err))
        end
    end
end

local function Notify()
    Invoke(notifyCallbacks, "EnemyAssignments notify")
end

local function Commit()
    Invoke(changedCallbacks, "EnemyAssignments changed")

    addon.Modules:Run()
    addon.Modules:AfterRun(Notify)
end

local function ValidSlot(slot)
    return type(slot) == "number" and slot >= 1 and slot <= maxSlots and slot == math.floor(slot)
end

---Returns true if the slot's entry changed.
local function SetEntry(slot, role, specId)
    local entry = assignments[slot]

    if not role then
        assignments[slot] = nil
        return entry ~= nil
    end

    if entry and entry.Role == role and entry.SpecId == specId then
        -- the user confirming a filled row makes it theirs
        entry.Filled = nil
        return false
    end

    assignments[slot] = { Role = role, SpecId = specId }
    return true
end

---Returns true if any slot changed.
local function FillAroundHealer(slot)
    if M:Role(slot) ~= wowEx.Role.Healer then
        return false
    end

    local changed = false

    for i = 1, M:EnemyCount() do
        if i ~= slot and not assignments[i] then
            assignments[i] = { Role = wowEx.Role.Dps, Filled = true }
            changed = true
        end
    end

    return changed
end

local function FirePrompt(visible)
    Invoke(promptCallbacks, "EnemyAssignments prompt", visible)
end

local function ShowPrompt()
    local options = addon.DB.Options.EnemyAssignments

    if promptShown or not (options and options.PopupEnabled) or not wowEx.IsInstanceArena() then
        return
    end

    if M:IsComplete(M:EnemyCount()) then
        return
    end

    promptShown = true
    FirePrompt(true)
end

local function MatchState()
    if not capabilities.HasPvPMatchState() then
        return nil
    end

    return wow.C_PvP.GetActiveMatchState()
end

function M:IsActive()
    return capabilities.NeedsManualEnemyRoles()
end

---Returns the arena slot of an arena unit token, or nil for any other unit.
---@param unit string
---@return number|nil
function M:SlotForUnit(unit)
    return tonumber(string.match(unit, "^arena(%d+)$"))
end

---@param slot number arena slot
---@return string|nil role
function M:Role(slot)
    local entry = assignments[slot]
    return entry and entry.Role
end

---@param slot number arena slot
---@return number|nil specId
function M:Spec(slot)
    local entry = assignments[slot]
    return entry and entry.SpecId
end

---True when the healer rule marked the slot rather than the user.
---@param slot number arena slot
---@return boolean
function M:IsFilled(slot)
    local entry = assignments[slot]
    return entry ~= nil and entry.Filled == true
end

---@return boolean
function M:HasAny()
    return next(assignments) ~= nil
end

---True when every one of the first count slots has a role.
---@param count number
---@return boolean
function M:IsComplete(count)
    if not count or count <= 0 then
        return false
    end

    for i = 1, count do
        if not assignments[i] then
            return false
        end
    end

    return true
end

---Returns how many enemies there are to mark, counting our own group because a stealthed enemy can hide from the arena count.
---@return number
function M:EnemyCount()
    local count = math.max(wowEx.ArenaOpponentsCount() or 0, wowEx.GroupMembersCount() or 0)

    if count <= 0 then
        count = defaultCount
    end

    return math.min(count, maxSlots)
end

---@param specId number
---@return string|nil role
function M:RoleForSpec(specId)
    local info = fsSpec:GetSpecInfo(specId)

    if not info then
        return nil
    end

    if info.Type == fsSpec.Type.Tank then
        return wowEx.Role.Tank
    end

    if info.Type == fsSpec.Type.Healer then
        return wowEx.Role.Healer
    end

    return wowEx.Role.Dps
end

---Returns the spec ids a user can pick for a row, in the order of the spec list.
---@param role string? only specs of this role
---@param classId number? only specs of this class
---@return number[]
function M:SpecChoices(role, classId)
    local choices = {}

    for _, info in ipairs(fsSpec.Specs) do
        if (not classId or info.ClassId == classId) and (not role or M:RoleForSpec(info.SpecId) == role) then
            choices[#choices + 1] = info.SpecId
        end
    end

    return choices
end

---Marks an enemy. A spec decides the role. A role alone keeps the slot's spec if it still fits.
---Passing neither clears the slot.
---@param slot number arena slot, 1 based
---@param role string? a wowEx.Role value other than None
---@param specId number? an id from the spec list
---@return boolean accepted false if the mark was invalid or this client does not need marks
function M:Set(slot, role, specId)
    if not M:IsActive() then
        return false
    end

    if not ValidSlot(slot) then
        fsLog:Error("EnemyAssignments:Set() - slot '%s' is not valid.", tostring(slot))
        return false
    end

    if specId ~= nil and not fsSpec.SpecIdLookup[specId] then
        fsLog:Error("EnemyAssignments:Set() - spec id '%s' is not valid.", tostring(specId))
        return false
    end

    if role ~= nil and not validRoles[role] then
        fsLog:Error("EnemyAssignments:Set() - role '%s' is not valid.", tostring(role))
        return false
    end

    local newRole, newSpec

    if specId then
        newRole = M:RoleForSpec(specId)
        newSpec = specId
    elseif role then
        newRole = role
        newSpec = M:Spec(slot)

        if newSpec and M:RoleForSpec(newSpec) ~= role then
            newSpec = nil
        end
    end

    local changed = SetEntry(slot, newRole, newSpec)

    if FillAroundHealer(slot) then
        changed = true
    end

    if changed then
        Commit()
    end

    return true
end

---Drops the spec from a slot and keeps its role.
---@param slot number arena slot
function M:ClearSpec(slot)
    local entry = assignments[slot]

    if not entry or not entry.SpecId then
        return
    end

    entry.SpecId = nil
    Commit()
end

---Removes every mark.
function M:Clear()
    if not M:HasAny() then
        return
    end

    assignments = {}
    Commit()
end

---Starts a new round.
function M:Reset()
    promptShown = false
    FirePrompt(false)
    M:Clear()
end

---Called after every mark change and before the frames are re-sorted.
---@param callback fun()
function M:RegisterCallback(callback)
    if not callback then
        fsLog:ErrorOnce("EnemyAssignments:RegisterCallback() - callback must not be nil.")
        return
    end

    changedCallbacks[#changedCallbacks + 1] = callback
end

---Called after the run that applied a change, which in combat is once combat ends.
---@param callback fun()
function M:RegisterNotifyCallback(callback)
    if not callback then
        fsLog:ErrorOnce("EnemyAssignments:RegisterNotifyCallback() - callback must not be nil.")
        return
    end

    notifyCallbacks[#notifyCallbacks + 1] = callback
end

---Called with true when the window should be offered to the user, and false when it should close.
---@param callback fun(visible: boolean)
function M:RegisterPromptCallback(callback)
    if not callback then
        fsLog:ErrorOnce("EnemyAssignments:RegisterPromptCallback() - callback must not be nil.")
        return
    end

    promptCallbacks[#promptCallbacks + 1] = callback
end

function M:ProcessEvent(event)
    if not M:IsActive() then
        return
    end

    if event == events.PLAYER_ENTERING_WORLD then
        M:Reset()

        -- a reload mid round loses the marks, so ask for them again
        local state = MatchState()

        if state ~= nil and (state == wow.Enum.PvPMatchState.StartUp or state == wow.Enum.PvPMatchState.Engaged) then
            ShowPrompt()
        end
    elseif event == events.ARENA_PREP_OPPONENT_SPECIALIZATIONS then
        ShowPrompt()
    elseif event == events.PVP_MATCH_STATE_CHANGED then
        local state = MatchState()

        if state == nil then
            return
        end

        if state == wow.Enum.PvPMatchState.StartUp then
            ShowPrompt()
        elseif state == wow.Enum.PvPMatchState.PostRound or state == wow.Enum.PvPMatchState.Complete then
            M:Reset()
        end
    end
end
