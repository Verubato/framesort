local _, addon = ...
local fsEnumerable = addon.Enumerable
local M = {
    Providers = {
        All = {},
    },
}

addon.Frame = M

function M.Providers:Enabled()
    return fsEnumerable
        :From(M.Providers.All)
        :Where(function(provider)
            return provider:Enabled()
        end)
        :ToTable()
end

---Returns all raid frames (including grouped members).
---@param provider FrameProvider
---@return table[]
function M:AllRaidFrames(provider)
    if not provider:RaidFramesEnabled() then
        return {}
    end

    if not provider:IsRaidGrouped() then
        return provider:RaidFrames()
    end

    return fsEnumerable
        :From(provider:RaidGroups())
        :Map(function(group)
            return provider:RaidGroupMembers(group)
        end)
        :Flatten()
        :ToTable()
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

---Returns true if the specified frame is a valid unit frame.
---@param frame table
---@param getUnit fun(frame: table): string
---@return boolean
function M:IsValidUnitFrame(frame, getUnit)
    if not frame then
        return false
    end

    if frame:IsForbidden() then
        return false
    end

    if frame:GetTop() == nil or frame:GetLeft() == nil then
        return false
    end

    local unit = getUnit(frame)

    if unit == nil then
        return false
    end

    -- we may have hidden the player frame, but for other frames we don't want them
    if unit == "player" or UnitIsUnit(unit, "player") then
        return true
    end

    return frame:IsVisible()
end

---Returns a collection of unit frames from the specified container.
---@param container table
---@param getUnit fun(frame: table): string
---@return table
function M:ChildUnitFrames(container, getUnit)
    if not container or container:IsForbidden() or not container:IsVisible() then
        return {}
    end

    return fsEnumerable
        :From({ container:GetChildren() })
        :Where(function(frame)
            return M:IsValidUnitFrame(frame, getUnit)
        end)
        :ToTable()
end
