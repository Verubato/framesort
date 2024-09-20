---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsFrame = addon.WoW.Frame
local fsProviders = addon.Providers
local fsEnumerable = addon.Collections.Enumerable
local M = {}

fsProviders.Gladius = M
table.insert(fsProviders.All, M)

function M:Name()
    return "Gladius"
end

function M:Enabled()
    return wow.GetAddOnEnableState(nil, "Gladius") ~= 0
end

function M:Init() end

function M:RegisterRequestSortCallback(_) end

function M:RegisterContainersChangedCallback(_) end

function M:Containers()
    ---@type FrameContainer[]
    local containers = {}

    containers[#containers + 1] = {
        Frame = wow.UIParent,
        Type = fsFrame.ContainerType.EnemyArena,
        LayoutType = fsFrame.LayoutType.Soft,
        VisibleOnly = true,
        Frames = function(_)
            return fsEnumerable
                :From({
                    ---@diagnostic disable: undefined-global
                    GladiusButtonFramearena1,
                    GladiusButtonFramearena2,
                    GladiusButtonFramearena3,
                    GladiusButtonFramearena4,
                    GladiusButtonFramearena5,
                })
                :Where(function(frame)
                    return frame:IsVisible()
                end)
                :ToTable()
        end,
    }

    return containers
end
