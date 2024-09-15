---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsFrame = addon.WoW.Frame
local fsProviders = addon.Providers
local M = {}

fsProviders.Cell = M
table.insert(fsProviders.All, M)

function M:Name()
    return "Cell"
end

function M:Enabled()
    return wow.GetAddOnEnableState(nil, "Cell") ~= 0 and Cell ~= nil
end

function M:Init() end

function M:RegisterRequestSortCallback(_) end

function M:RegisterContainersChangedCallback(_) end

function M:Containers()
    ---@type FrameContainer
    local party = CellPartyFrameHeader and {
        Frame = CellPartyFrameHeader,
        Type = fsFrame.ContainerType.Party,
        LayoutType = fsFrame.LayoutType.NameList,
    }

    ---@type FrameContainer
    local raid = CellRaidFrameHeader0 and {
        Frame = CellRaidFrameHeader0,
        Type = fsFrame.ContainerType.Raid,
        LayoutType = fsFrame.LayoutType.NameList,
    }

    return {
        party,
        raid,
    }
end
