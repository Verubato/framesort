local _, addon = ...
local fsEnumerable = addon.Enumerable
local fsUnit = addon.Unit
local fsLog = addon.Log
local M = {}
addon.Frame = M

local function IsValidUnitFrame(frame, includeInvisible)
    return
        not frame:IsForbidden()
        and frame.unitExists
        and (includeInvisible or frame:IsVisible())
        -- to prevent some weird issue early in the loading process
        -- where frames are visible but aren't positioned
        and frame:GetTop() ~= nil
        and frame:GetLeft() ~= nil
end

local function IsValidGroupFrame(frame, includeInvisible)
    return
        not frame:IsForbidden()
        and (includeInvisible or frame:IsVisible())
        and string.match(frame:GetName() or "", "CompactRaidGroup")
end

local function ExtractFrames(children, includeInvisible)
    local fromRoot = fsEnumerable
        :From(children)
    local fromGroup = fsEnumerable
        :From(children)
        :Where(function(frame) return IsValidGroupFrame(frame, includeInvisible) end)
        :Map(function(group) return { group:GetChildren() } end)
        :Flatten()
    return fromRoot
        :Concat(fromGroup)
        :Where(function(frame) return IsValidUnitFrame(frame, includeInvisible) end)
        :ToTable()
end

---Returns the set of raid frames.
---@param includeInvisible boolean? true to include invisible frames.
---@return Enumerable<table>,Enumerable<table> frames member frames, pet frames
function M:GetRaidFrames(includeInvisible)
    local empty = fsEnumerable:Empty():ToTable()
    local container = CompactRaidFrameContainer

    if not container then return empty, empty end
    if container:IsForbidden() or not container:IsVisible() then return empty, empty end

    local children = { container:GetChildren() }
    local frames = ExtractFrames(children, includeInvisible)
    local members = fsEnumerable:From(frames)
        :Where(function(x) return fsUnit:IsMember(x.unit) end)
    local pets = fsEnumerable:From(frames)
        :Where(function(x) return fsUnit:IsPet(x.unit) end)

    return members:ToTable(), pets:ToTable()
end

---Returns the set of raid frame group frames.
---@param includeInvisible boolean? true to include invisible frames.
---@return table<table> frames group frames
function M:GetRaidFrameGroups(includeInvisible)
    local empty = fsEnumerable:Empty():ToTable()
    local container = CompactRaidFrameContainer

    if not container then return empty end
    if container:IsForbidden() or not container:IsVisible() then return empty end

    return fsEnumerable
        :From({ container:GetChildren() })
        :Where(function(frame) return IsValidGroupFrame(frame, includeInvisible) end)
        :ToTable()
end

---Returns the set of visible member frames within a raid group frame.
---@param includeInvisible boolean? true to include invisible frames.
---@return table<table> frames group frames
function M:GetRaidFrameGroupMembers(group, includeInvisible)
    return fsEnumerable
        :From({ group:GetChildren() })
        :Where(function(frame) return IsValidUnitFrame(frame, includeInvisible) end)
        :ToTable()
end

---Returns the set of visible party frames.
---@param includeInvisible boolean? true to include invisible frames.
---@return table<table> frames party frames
function M:GetPartyFrames(includeInvisible)
    local empty = fsEnumerable:Empty():ToTable()
    local container = CompactPartyFrame

    if not container then return empty end
    if container:IsForbidden() or not container:IsVisible() then return empty end

    return fsEnumerable
        :From({ container:GetChildren() })
        :Where(function(frame) return IsValidUnitFrame(frame, includeInvisible) end)
        :ToTable()
end

---Returns the player compact raid frame.
---@return table? playerFrame
function M:GetPlayerFrame()
    local frames = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE and M:GetPartyFrames(true) or nil

    if not frames or #frames == 0 then
        frames = M:GetRaidFrames(true)
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
    local empty = fsEnumerable:Empty():ToTable()
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
                return empty
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
        return empty
    end

    return root
end
