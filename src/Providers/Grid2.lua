---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsFrame = addon.WoW.Frame
local fsProviders = addon.Providers
local M = {}

fsProviders.Grid2 = M
table.insert(fsProviders.All, M)

function M:Name()
    return "Grid2"
end

function M:Enabled()
    return wow.GetAddOnEnableState(nil, "Grid2") ~= 0
end

function M:Init() end

function M:RegisterRequestSortCallback(_) end

function M:RegisterContainersChangedCallback(_) end

function M:Containers()
    ---@type FrameContainer
    local party = Grid2LayoutHeader1 and {
        Frame = Grid2LayoutHeader1,
        Type = fsFrame.ContainerType.Party,
        LayoutType = fsFrame.LayoutType.NameList,
    }

    return {
        party,
    }
end
