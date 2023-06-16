local _, addon = ...
local fsEnumerable = addon.Enumerable
local fsUnit = addon.Unit
local fsLog = addon.Log
local M = {}
addon.Frame = M

local function IsValidUnitFrame(frame)
    return
        not frame:IsForbidden()
        and frame.unitExists
        -- to prevent some weird issue where frames are visible but aren't positioned
        and frame:GetTop() ~= nil
        and frame:GetLeft() ~= nil
end

local function IsValidGroupFrame(frame)
    return
        not frame:IsForbidden()
        -- to prevent some weird issue where frames are visible but aren't positioned
        and frame:GetTop() ~= nil
        and frame:GetLeft() ~= nil
        and string.match(frame:GetName() or "", "CompactRaidGroup")
end

local function ExtractFrames(children)
    local fromRoot = fsEnumerable
        :From(children)
    local fromGroup = fsEnumerable
        :From(children)
        :Where(function(frame) return IsValidGroupFrame(frame) end)
        :Map(function(group) return { group:GetChildren() } end)
        :Flatten()
    return fromRoot
        :Concat(fromGroup)
        :Where(function(frame) return IsValidUnitFrame(frame) end)
        :ToTable()
end

---Returns the set of raid frames.
---@return Enumerable<table>,Enumerable<table> frames member frames, pet frames
function M:GetRaidFrames()
    local container = CompactRaidFrameContainer

    if not container or container:IsForbidden() or not container:IsVisible() then
        local empty = fsEnumerable:Empty():ToTable()
        return empty, empty
    end

    local frames = ExtractFrames({ container:GetChildren() })
    local players = fsEnumerable
        :From(frames)
        :Where(function(x) return fsUnit:IsPlayer(x.unit) end)
    local pets = fsEnumerable
        :From(frames)
        :Where(function(x) return fsUnit:IsPet(x.unit) end)

    return players:ToTable(), pets:ToTable()
end

---Returns the set of raid frame group frames.
---@return table<table> frames group frames
function M:GetRaidFrameGroups()
    local container = CompactRaidFrameContainer

    if not container or container:IsForbidden() or not container:IsVisible() then
        return fsEnumerable:Empty():ToTable()
    end

    return fsEnumerable
        :From({ container:GetChildren() })
        :Where(function(frame) return IsValidGroupFrame(frame) end)
        :ToTable()
end

---Returns the set of member frames within a raid group frame.
---@return table<table> frames group frames
function M:GetRaidFrameGroupMembers(group)
    return fsEnumerable
        :From({ group:GetChildren() })
        :Where(function(frame) return IsValidUnitFrame(frame) end)
        :ToTable()
end

---Returns the set of party frames.
---@return Enumerable<table> frames member frames
function M:GetPartyFrames()
    local container = CompactPartyFrame

    if not container or container:IsForbidden() or not container:IsVisible() then
        return fsEnumerable:Empty():ToTable()
    end

    return fsEnumerable
        :From({ container:GetChildren() })
        :Where(function(x) return IsValidUnitFrame(x) end)
        :Where(function(x) return fsUnit:IsPlayer(x.unit) end)
        :ToTable()
end

---Returns the player compact raid frame.
---@return table? playerFrame
function M:GetPlayerFrame()
    local frames = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE and M:GetPartyFrames() or nil

    if not frames or #frames == 0 then
        frames = M:GetRaidFrames()
    end

    -- find the player frame
    return fsEnumerable
        :From(frames)
        :First(function(frame) return UnitIsUnit("player", frame.unit) end)
end

---Returns the frames in order of their relative positioning to each other.
---@param frames table<table> frames in any particular order
---@return LinkedListNode root in order of parent -> child -> child -> child
function M:ToFrameChain(frames)
    local invalid = { Valid = false }
    local nodesByFrame = fsEnumerable
        :From(frames)
        :ToLookup(function(frame) return frame end, function(frame)
            return {
                Next = nil,
                Previous = nil,
                Value = frame
            }
        end)

    local root = nil
    for _, child in pairs(nodesByFrame) do
        local _, relativeTo, _, _, _ = child.Value:GetPoint()
        local parent = nodesByFrame[relativeTo]

        if parent then
            if parent.Next then
                fsLog:Error(string.format("Encountered multiple children for frame %s in frame frame chain.", parent.Value:GetName()))
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
        fsLog:Error(string.format("Incomplete/broken frame chain: expected %d nodes but only found %d", #frames, count))
        return invalid
    end

    root.Valid = true
    return root
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
        if not isRaid then return true end

        local raidGroupDisplayType = EditModeManagerFrame:GetSettingValue(
            Enum.EditModeSystem.UnitFrame,
            Enum.EditModeUnitFrameSystemIndices.Raid,
            Enum.EditModeUnitFrameSetting.RaidGroupDisplayType)

        return
            raidGroupDisplayType == Enum.RaidGroupDisplayType.SeparateGroupsVertical or
            raidGroupDisplayType == Enum.RaidGroupDisplayType.SeparateGroupsHorizontal
    else
        return CompactRaidFrameManager_GetSetting("KeepGroupsTogether")
    end
end

---Returns true if the frames are using horizontal layout.
---@param isRaid boolean true for raid frames, false for party.
function M:HorizontalLayout(isRaid)
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        if isRaid then
            local displayType = EditModeManagerFrame:GetSettingValue(
                Enum.EditModeSystem.UnitFrame,
                Enum.EditModeUnitFrameSystemIndices.Raid,
                Enum.EditModeUnitFrameSetting.RaidGroupDisplayType)

            return
                displayType == Enum.RaidGroupDisplayType.SeparateGroupsHorizontal or
                displayType == Enum.RaidGroupDisplayType.CombineGroupsHorizontal
        else
            return EditModeManagerFrame:GetSettingValueBool(
                Enum.EditModeSystem.UnitFrame,
                Enum.EditModeUnitFrameSystemIndices.Party,
                Enum.EditModeUnitFrameSetting.UseHorizontalGroups)
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
