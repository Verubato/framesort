local _, addon = ...
local fsEnumerable = addon.Enumerable
local fsUnit = addon.Unit
local M = {}
addon.Frame = M

local function IsValidUnitFrame(frame, getUnit)
    return not frame:IsForbidden() and frame:GetTop() ~= nil and frame:GetLeft() ~= nil and getUnit(frame) ~= nil
end

local function IsValidGroupFrame(frame)
    return not frame:IsForbidden() and frame:GetTop() ~= nil and frame:GetLeft() ~= nil and string.match(frame:GetName() or "", "CompactRaidGroup")
end

local function GetUnit(frame)
    -- once we add support for other addons
    -- this function would extract the unit id token from their custom addon frame
    if SecureButton_GetUnit then
        return SecureButton_GetUnit(frame)
    end

    return frame.unit
end

local function ExtractFrames(container, getUnit, checkGroups, visibleOnly)
    local children = { container:GetChildren() }
    local frames = fsEnumerable:From(children)

    if checkGroups then
        local fromGroup = fsEnumerable
            :From(children)
            :Where(IsValidGroupFrame)
            :Map(function(group)
                return { group:GetChildren() }
            end)
            :Flatten()

        frames = frames:Concat(fromGroup)
    end

    if visibleOnly then
        frames = frames:Where(function(x)
            return x:IsVisible()
        end)
    end

    return frames:Where(function(frame)
        return IsValidUnitFrame(frame, getUnit)
    end)
end

---Returns the set of frames from the specified container.
---@param checkGroups boolean true to inspect groups, otherwise false.
---@return table[] players, table[] pets, fun(frame: table): string
local function GetUnitFrames(container, checkGroups, visibleOnly)
    if not container or container:IsForbidden() or not container:IsVisible() then
        local empty = fsEnumerable:Empty():ToTable()
        return empty, empty, function(_)
            return "none"
        end
    end

    local frames = ExtractFrames(container, GetUnit, checkGroups, visibleOnly):ToTable()
    local players = fsEnumerable
        :From(frames)
        :Where(function(x)
            -- a mind , falsecontrolled player is considered both a player and a pet and will have 2 frames
            -- so we want include their player frame but exclude their pet frame
            local unit = GetUnit(x)
            return unit and fsUnit:IsPlayer(unit) and not fsUnit:IsPet(unit)
        end)
        :ToTable()
    local pets = fsEnumerable
        :From(frames)
        :Where(function(x)
            local unit = GetUnit(x)
            return unit and fsUnit:IsPet(unit)
        end)
        :ToTable()

    return players, pets, GetUnit
end

---Returns the set of raid frame group frames.
---@return table[] groups
function M:GetGroups(container)
    if not container or container:IsForbidden() or not container:IsVisible() then
        return fsEnumerable:Empty():ToTable()
    end

    return fsEnumerable:From({ container:GetChildren() }):Where(IsValidGroupFrame):ToTable()
end

---Returns the set of party frames.
---@return table[] players, table[] pets, fun(frame: table): string
function M:GetPartyFrames()
    return GetUnitFrames(CompactPartyFrame, false, true)
end

---Returns the set of raid frames.
---@return table[] players, table[] pets, fun(frame: table): string
function M:GetRaidFrames()
    return GetUnitFrames(CompactRaidFrameContainer, M:KeepGroupsTogether(true), true)
end

---Returns the set of enemy arena frames.
---@return table[] players, table[] pets, fun(frame: table): string
function M:GetEnemyArenaFrames()
    return GetUnitFrames(CompactArenaFrame, false, true)
end

---Returns party frames if visible, otherwise raid frames.
function M:GetFrames()
    local party, pets, getUnit = M:GetPartyFrames()
    if #party > 0 then
        return party, pets, getUnit
    end

    return M:GetRaidFrames()
end

---Returns the set of raid frame group frames.
---@return table[] groups
function M:GetRaidFrameGroups()
    return M:GetGroups(CompactRaidFrameContainer)
end

---Returns the set of member frames within a raid group frame.
---@return table[] units
function M:GetRaidFrameGroupMembers(group)
    return ExtractFrames(group, GetUnit, false, true):ToTable()
end

---Returns the player compact raid frame.
---@return table? playerFrame
function M:GetPlayerFrame()
    local party, _, getUnit = GetUnitFrames(CompactPartyFrame, false, false)
    local members = party

    if #party == 0 then
        local raid, _, raidGetUnit = GetUnitFrames(CompactRaidFrameContainer, false, false)
        members = raid
        getUnit = raidGetUnit
    end

    if #members == 0 then
        return nil
    end

    -- find the player frame
    local players = fsEnumerable
        :From(members)
        :Where(function(frame)
            local unit = getUnit(frame)
            -- a player can have more than one frame if they occupy a vehicle
            -- as both the player and vehicle pet frame are shown
            return unit and UnitIsUnit("player", unit) and not fsUnit:IsPet(unit)
        end)
        :ToTable()

    if #players == 1 then
        return players[1]
    end

    return fsEnumerable:From(players):First(function(x)
        return x:IsVisible()
    end)
end

---Returns the frames in order of their relative positioning to each other.
---@param frames table[] frames in any particular order
---@return LinkedListNode root in order of parent -> child -> child -> child
function M:ToFrameChain(frames)
    local invalid = { Valid = false }

    if #frames == 0 then
        return invalid
    end

    local nodesByFrame = fsEnumerable:From(frames):ToLookup(function(frame)
        return frame
    end, function(frame)
        return {
            Next = nil,
            Previous = nil,
            Value = frame,
        }
    end)

    local root = nil
    for _, child in pairs(nodesByFrame) do
        local _, relativeTo, _, _, _ = child.Value:GetPoint()
        local parent = nodesByFrame[relativeTo]

        if parent then
            if parent.Next then
                return invalid
            end

            parent.Next = child
            child.Previous = parent
        else
            root = child
        end
    end

    -- assert we have a complete chain
    local count = 0
    local current = root

    while current do
        count = count + 1
        current = current.Next
    end

    if count ~= #frames then
        return invalid
    end

    root.Valid = true
    return root
end

---Returns an ordered set of frames from the given chain
---@param chain LinkedListNode root
function M:FramesFromChain(chain)
    local frames = {}
    local next = chain

    while next do
        frames[#frames + 1] = next.Value

        next = next.Next
    end

    return frames
end

---Returns true if all the frames have the same anchor.
---@param frames table[] frames in any particular order
---@return boolean flat
function M:IsFlat(frames)
    if #frames == 0 then
        return false
    end

    local _, anchor, _, _, _ = frames[1]:GetPoint()
    for i = 2, #frames do
        local _, relativeTo, _, _, _ = frames[i]:GetPoint()

        if relativeTo ~= anchor then
            return false
        end
    end

    return true
end

---Returns true if pets are shown in raid frames
---@return boolean
function M:ShowPets()
    return CompactRaidFrameManager_GetSetting("DisplayPets")
end

---Returns true if groups are kept together.
---@return boolean
function M:KeepGroupsTogether(isRaid)
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        if not isRaid then
            return false
        end

        local raidGroupDisplayType = EditModeManagerFrame:GetSettingValue(Enum.EditModeSystem.UnitFrame, Enum.EditModeUnitFrameSystemIndices.Raid, Enum.EditModeUnitFrameSetting.RaidGroupDisplayType)
        return raidGroupDisplayType == Enum.RaidGroupDisplayType.SeparateGroupsVertical or raidGroupDisplayType == Enum.RaidGroupDisplayType.SeparateGroupsHorizontal
    else
        return CompactRaidFrameManager_GetSetting("KeepGroupsTogether")
    end
end

---Returns true if the frames are using horizontal layout.
---@param isRaid boolean true for raid frames, false for party.
function M:HorizontalLayout(isRaid)
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        if isRaid then
            local displayType = EditModeManagerFrame:GetSettingValue(Enum.EditModeSystem.UnitFrame, Enum.EditModeUnitFrameSystemIndices.Raid, Enum.EditModeUnitFrameSetting.RaidGroupDisplayType)

            return displayType == Enum.RaidGroupDisplayType.SeparateGroupsHorizontal or displayType == Enum.RaidGroupDisplayType.CombineGroupsHorizontal
        else
            return EditModeManagerFrame:GetSettingValueBool(Enum.EditModeSystem.UnitFrame, Enum.EditModeUnitFrameSystemIndices.Party, Enum.EditModeUnitFrameSetting.UseHorizontalGroups)
        end
    else
        return CompactRaidFrameManager_GetSetting("HorizontalGroups")
    end
end

---Returns true if using raid-style party frames.
function M:IsUsingRaidStyleFrames()
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        return EditModeManagerFrame:UseRaidStylePartyFrames()
    else
        return GetCVarBool("useCompactPartyFrames")
    end
end
