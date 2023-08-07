local _, addon = ...
local fsEnumerable = addon.Enumerable
local fsUnit = addon.Unit
local M = {}
addon.Frame = M

local function EmptyUnit(_)
    return "none"
end

local function GetUnit(frame)
    -- once we add support for other addons
    -- this function would extract the unit id token from their custom addon frame
    return frame.unit
end

local function IsValidUnitFrame(frame)
    if not frame then
        return false
    end

    if frame:IsForbidden() then
        return false
    end

    if frame:GetTop() == nil or frame:GetLeft() == nil then
        return false
    end

    if frame.inUse ~= nil and not frame.inUse then
        return false
    end

    if frame.frameType and frame.frameType == "target" then
        -- this frame is invisible when the tain/assist hasn't got anything targeted
        -- but we still want to include this frame for spacing reasons
        return true
    end

    if GetUnit(frame) == nil then
        return false
    end

    if not frame:IsVisible() then
        return false
    end

    return true
end

local function IsValidGroupFrame(frame)
    if not frame then
        return false
    end

    if frame:IsForbidden() then
        return false
    end

    if frame:GetTop() == nil or frame:GetLeft() == nil then
        return false
    end

    if not frame:IsVisible() then
        return false
    end

    return string.match(frame:GetName() or "", "CompactRaidGroup") ~= nil
end

local function GetFrames(container, filter)
    if not container or container:IsForbidden() or not container:IsVisible() then
        return {}, EmptyUnit
    end

    filter = filter or IsValidUnitFrame

    return fsEnumerable
        :From({ container:GetChildren() })
        :Where(function(frame)
            return filter(frame)
        end)
        :ToTable(), GetUnit
end

local function Find(filter)
    local party = GetFrames(CompactPartyFrame, filter)
    local raid = GetFrames(CompactRaidFrameContainer, filter)
    local groups = M:GetRaidGroups()
    local groupedMembers = fsEnumerable
        :From(groups)
        :Map(function(group)
            return GetFrames(group, filter)
        end)
        :Flatten()
        :ToTable()

    return fsEnumerable:From(party):Concat(raid):Concat(groupedMembers):ToTable()
end

---Returns the main container object for party frames.
function M:GetPartyFramesContainer()
    return CompactPartyFrame, "CompactPartyFrame"
end

---Returns the main container object for raid frames.
function M:GetRaidFramesContainer()
    return CompactRaidFrameContainer, "CompactRaidFrameContainer"
end

---Returns the main container object for raid frames.
function M:GetEnemyArenaFramesContainer()
    return CompactArenaFrame, "CompactArenaFrame"
end

---Returns the set of party frames.
---@return table[] frames, fun(frame: table): string a function to extract the unit token from a given frame.
function M:GetPartyFrames()
    local container = M:GetPartyFramesContainer()
    return GetFrames(container)
end

---Returns the set of non-grouped raid frames.
---@return table[] frames, fun(frame: table): string a function to extract the unit token from a given frame.
function M:GetRaidFrames()
    local container = M:GetRaidFramesContainer()
    return GetFrames(container)
end

---Returns the set of member frames within a raid group frame.
---@return table[] frames, fun(frame: table): string a function to extract the unit token from a given frame.
function M:GetRaidGroupMembers(group)
    return GetFrames(group)
end

---Returns the set of raid frame group frames.
---@return table[] groups
function M:GetRaidGroups()
    local container = M:GetRaidFramesContainer()
    local groups, _ = GetFrames(container, IsValidGroupFrame)
    return groups
end

---Returns the set of enemy arena frames.
---@return table[] players, fun(frame: table): string
function M:GetEnemyArenaFrames()
    local container = M:GetEnemyArenaFramesContainer()
    return GetFrames(container)
end

---Returns all frames (from both party and raid, including groups).
---@return table[] players, fun(frame: table): string
function M:GetFrames()
    return Find(IsValidUnitFrame), GetUnit
end

---Returns the player compact raid frame.
---@return table? playerFrame, fun(frame: table): string
function M:GetPlayerFrame()
    local players = Find(function(frame)
        local unit = GetUnit(frame)
        -- a player can have more than one frame if they occupy a vehicle
        -- as both the player and vehicle pet frame are shown
        return unit and UnitIsUnit("player", unit) and not fsUnit:IsPet(unit)
    end)

    if #players == 1 then
        return players[1], GetUnit
    end

    return fsEnumerable:From(players):First(function(x)
        return x:IsVisible(), GetUnit
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
---@return boolean
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

---Returns true if frames are grouped.
---@return boolean
function M:IsPartyGrouped()
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        return false
    end

    return CompactRaidFrameManager_GetSetting("KeepGroupsTogether")
end

---Returns true if frames are grouped.
---@return boolean
function M:IsRaidGrouped()
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        local raidGroupDisplayType = EditModeManagerFrame:GetSettingValue(Enum.EditModeSystem.UnitFrame, Enum.EditModeUnitFrameSystemIndices.Raid, Enum.EditModeUnitFrameSetting.RaidGroupDisplayType)
        return raidGroupDisplayType == Enum.RaidGroupDisplayType.SeparateGroupsVertical or raidGroupDisplayType == Enum.RaidGroupDisplayType.SeparateGroupsHorizontal
    end

    return CompactRaidFrameManager_GetSetting("KeepGroupsTogether")
end

---Returns true if the frames are using horizontal layout.
---@return boolean
function M:PartyHorizontalLayout()
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        return EditModeManagerFrame:GetSettingValueBool(Enum.EditModeSystem.UnitFrame, Enum.EditModeUnitFrameSystemIndices.Party, Enum.EditModeUnitFrameSetting.UseHorizontalGroups)
    end

    return CompactRaidFrameManager_GetSetting("HorizontalGroups")
end

---Returns true if the frames are using horizontal layout.
---@return boolean
function M:RaidHorizontalLayout()
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        local displayType = EditModeManagerFrame:GetSettingValue(Enum.EditModeSystem.UnitFrame, Enum.EditModeUnitFrameSystemIndices.Raid, Enum.EditModeUnitFrameSetting.RaidGroupDisplayType)
        return displayType == Enum.RaidGroupDisplayType.SeparateGroupsHorizontal or displayType == Enum.RaidGroupDisplayType.CombineGroupsHorizontal
    end

    return CompactRaidFrameManager_GetSetting("HorizontalGroups")
end

---Returns true if using raid-style party frames.
---@return boolean
function M:IsUsingRaidStyleFrames()
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        return EditModeManagerFrame:UseRaidStylePartyFrames()
    else
        return GetCVarBool("useCompactPartyFrames")
    end
end
