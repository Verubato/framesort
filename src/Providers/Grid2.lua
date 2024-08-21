---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsFrame = addon.WoW.Frame
local fsProviders = addon.Providers
local M = {}
local callbacks = {}
local containersChangedCallbacks = {}
local updating = nil

fsProviders.Grid2 = M
table.insert(fsProviders.All, M)

local function RequestSort()
    for _, callback in ipairs(callbacks) do
        callback(M)
    end
end

local function OnHeaderUpdate(header)
    if header ~= Grid2LayoutHeader1 then
        return
    end
    -- prevent stack overflow as SetAttribute() calls will invoke another header update
    if updating then
        return
    end

    updating = true
    RequestSort()
    updating = false
end

function M:Name()
    return "Grid2"
end

function M:Enabled()
    return wow.GetAddOnEnableState(nil, "Grid2") ~= 0
end

function M:Init()
    if not M:Enabled() then
        return
    end

    if #callbacks > 0 then
        callbacks = {}
    end

    wow.hooksecurefunc("SecureGroupHeader_Update", OnHeaderUpdate)
end

function M:RegisterRequestSortCallback(callback)
    callbacks[#callbacks + 1] = callback
end

function M:RegisterContainersChangedCallback(callback)
    containersChangedCallbacks[#containersChangedCallbacks + 1] = callback
end

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
