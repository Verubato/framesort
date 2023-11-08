---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsFrame = addon.WoW.Frame
local fsProviders = addon.Providers
local M = {}
local callbacks = {}

fsProviders.GladiusEx = M
table.insert(fsProviders.All, M)

function M:Name()
    return "GladiusEx"
end

function M:Enabled()
    return wow.IsRetail() and wow.GetAddOnEnableState(nil, "GladiusEx") ~= 0
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
    ---@type FrameContainer[]
    local containers = {}

    if GladiusExPartyFrame then
        containers[#containers + 1] = {
            Frame = GladiusExPartyFrame,
            Type = fsFrame.ContainerType.Party,
            LayoutType = fsFrame.LayoutType.Soft,
            SupportsSpacing = false,

            -- not applicable
            FramesOffset = function() return nil end,
            IsGrouped = function() return nil end,
            IsHorizontalLayout = function() return nil end,
            GroupFramesOffset = function(_) return nil end,
            FramesPerLine = function(_) return nil end
        }
    end

    if GladiusExArenaFrame then
        containers[#containers + 1] = {
            Frame = GladiusExArenaFrame,
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
    end

    return containers
end
