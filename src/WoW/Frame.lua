-- TODO: move this to a better namespace
---@type string, Addon
local _, addon = ...
local fsEnumerable = addon.Collections.Enumerable
---@class FrameUtil
local M = {
    ---@class ContainerType
    ContainerType = {
        Party = 1,
        Raid = 2,
        EnemyArena = 3
    },
    ---@class FrameLayoutType
    LayoutType = {
        --- Arrange frames by adjusting their x/y coordinates without changing the anchor.
        Soft = 1,
        --- Arrange frames by setting their anchors.
        Hard = 2,
        -- Uses the NameList attribute of a SecureGroupHeader to order members.
        NameList = 3
    }
}

addon.WoW.Frame = M

---@param provider FrameProvider
---@param type number
---@param visibleOnly boolean?
local function GetFrames(provider, type, visibleOnly)
    local target = M:GetContainer(provider, type)
    if not target then return {} end

    local frames = M:ExtractUnitFrames(target.Frame, visibleOnly)

    if not target.IsGrouped or not target:IsGrouped() then
        return frames
    end

    local groups = M:ExtractGroups(target.Frame, visibleOnly)
    local ungrouped = fsEnumerable
        :From(groups)
        :Map(function(group)
            return M:ExtractUnitFrames(group)
        end)
        :Flatten()

    return fsEnumerable
        :From(frames)
        :Concat(ungrouped)
        :ToTable()
end

---Returns the frames in order of their relative positioning to each other.
---@param frames table[] frames in any particular order
---@return FrameChain root in order of parent -> child -> child -> child
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

    assert(root ~= nil)

    root.Valid = true
    return root
end

---Returns an ordered set of frames from the given chain
---@param chain FrameChain root
function M:FramesFromChain(chain)
    local frames = {}
    local next = chain

    while next do
        frames[#frames + 1] = next.Value

        ---@diagnostic disable-next-line: cast-local-type
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

--- Returns the unit token from a frame.
---@param frame table
---@return string|nil
function M:GetFrameUnit(frame)
    if frame.unit then
        return frame.unit
    end

    return frame:GetAttribute("unit")
end

---Returns a collection of unit frames from the specified container.
---@param container table
---@param visibleOnly boolean?
---@return table
function M:ExtractUnitFrames(container, visibleOnly)
    if not container or M:IsForbidden(container) or not container:IsVisible() then
        return {}
    end

    visibleOnly = visibleOnly or false

    return fsEnumerable
        :From({ container:GetChildren() })
        :Where(function(frame)
            if type(frame) ~= "table" then return false end
            if M:IsForbidden(frame) then return false end
            if frame:GetTop() == nil or frame:GetLeft() == nil then return false end
            if visibleOnly and not frame:IsVisible() then return false end

            local unit = M:GetFrameUnit(frame)
            return unit ~= nil
        end)
        :ToTable()
end

---Returns a collection of groups from the specified container.
---@param container table
---@param visibleOnly boolean?
---@return table
function M:ExtractGroups(container, visibleOnly)
    if not container or M:IsForbidden(container) or not container:IsVisible() then
        return {}
    end

    visibleOnly = visibleOnly or false

    return fsEnumerable
        :From({ container:GetChildren() })
        :Where(function(frame)
            if type(frame) ~= "table" then return false end
            if M:IsForbidden(frame) then return false end
            if frame:GetTop() == nil or frame:GetLeft() == nil then return false end
            if visibleOnly and not frame:IsVisible() then return false end

            local name = frame:GetName()

            if not name then return false end

            -- wotlk with 1 group uses the party frame
            if string.match(name, "CompactPartyFrame") then return true end

            -- only supports blizzard groups atm
            return string.match(name, "CompactRaidGroup")
        end)
        :ToTable()
end

---@param provider FrameProvider
---@param type number
---@return FrameContainer?
function M:GetContainer(provider, type)
    local containers = provider:Containers()

    for _, container in ipairs(containers) do
        if container.Type == type then
            return container
        end
    end

    return nil
end

---Returns the party frames of the specified provider.
---@param provider FrameProvider
---@param visibleOnly boolean?
---@return table[]
function M:PartyFrames(provider, visibleOnly)
    return GetFrames(provider, M.ContainerType.Party, visibleOnly)
end

---Returns the raid frames of the specified provider.
---@param provider FrameProvider
---@param visibleOnly boolean?
---@return table[]
function M:RaidFrames(provider, visibleOnly)
    return GetFrames(provider, M.ContainerType.Raid, visibleOnly)
end

---Returns the enemy arena frames of the specified provider.
---@param provider FrameProvider
---@param visibleOnly boolean?
---@return table[]
function M:ArenaFrames(provider, visibleOnly)
    return GetFrames(provider, M.ContainerType.EnemyArena, visibleOnly)
end

function M:IsForbidden(frame)
    -- wotlk 3.3.5 doesn't have this function
    if not frame.IsForbidden then return false end

    return frame:IsForbidden()
end
