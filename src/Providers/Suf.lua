---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsFrame = addon.WoW.Frame
local fsProviders = addon.Providers
local fsLog = addon.Logging.Log
local M = {}

fsProviders.Suf = M
table.insert(fsProviders.All, M)

function M:Name()
    return "Shadowed Unit Frames"
end

function M:Enabled()
    return wow.GetAddOnEnableState(nil, "ShadowedUnitFrames") ~= 0
end

function M:Init() end
function M:RegisterRequestSortCallback() end
function M:RegisterContainersChangedCallback() end

function M:Containers()
    local containers = {}

    if not M:Enabled() then
        return
    end

    if SUFHeaderparty then
        ---@type FrameContainer
        local party = {
            Frame = SUFHeaderparty,
            Type = fsFrame.ContainerType.Party,
            LayoutType = fsFrame.LayoutType.NameList,
        }

        containers[#containers + 1] = party
    end

    if SUFHeaderarena then
        ---@type FrameContainer
        local arena = {
            Frame = SUFHeaderarena,
            Type = fsFrame.ContainerType.EnemyArena,
            LayoutType = fsFrame.LayoutType.NameList,
        }

        containers[#containers + 1] = arena
    end

    return containers
end
