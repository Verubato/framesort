---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsFrame = addon.WoW.Frame
local fsProviders = addon.Providers
local M = {}
local callbacks = {}

fsProviders.sArena = M
table.insert(fsProviders.All, M)

function M:Name()
    return "sArena"
end

function M:Enabled()
    return wow.IsRetail() and wow.GetAddOnEnableState(nil, "sArena Updated") ~= 0
end

function M:Init()
    if not M:Enabled() then
        return
    end

    if #callbacks > 0 then
        callbacks = {}
    end
end

function M:RegisterRequestSortCallback(_) end

function M:RegisterContainersChangedCallback(_) end

function M:Containers()
    if not sArena then
        return {}
    end

    ---@type FrameContainer
    local arena = {
        Frame = sArena,
        Type = fsFrame.ContainerType.EnemyArena,
        LayoutType = fsFrame.LayoutType.Soft,
        SupportsSpacing = false,

        -- not applicable
        FramesOffset = function() return nil end,
        IsGrouped = function() return nil end,
        IsHorizontalLayout = function() return nil end,
        GroupFramesOffset = function(_) return nil end,
        FramesPerLine = function(_) return nil end
    }

    return {
        arena
    }
end
