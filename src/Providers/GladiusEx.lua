---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsFrame = addon.WoW.Frame
local fsProviders = addon.Providers
local M = {}

fsProviders.GladiusEx = M
table.insert(fsProviders.All, M)

function M:Name()
    return "GladiusEx"
end

function M:Enabled()
    return wow.GetAddOnEnableState(nil, "GladiusEx") ~= 0
end

function M:Init() end

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
        }
    end

    if GladiusExArenaFrame then
        containers[#containers + 1] = {
            Frame = GladiusExArenaFrame,
            Type = fsFrame.ContainerType.EnemyArena,
            LayoutType = fsFrame.LayoutType.Soft,
        }
    end

    return containers
end
