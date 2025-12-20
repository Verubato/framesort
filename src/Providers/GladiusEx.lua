---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsFrame = addon.WoW.Frame
local fsProviders = addon.Providers
local fsEnumerable = addon.Collections.Enumerable
local fsCompare = addon.Modules.Sorting.Comparer
local fsLuaEx = addon.Language.LuaEx
local fsLog = addon.Logging.Log
local M = {}
local sortCallbacks = {}

fsProviders.GladiusEx = M
table.insert(fsProviders.All, M)

local function CalculateSpace(container)
    local frames = fsEnumerable
        :From(fsFrame:ExtractUnitFrames(container))
        :OrderBy(function(x, y)
            return fsCompare:CompareTopLeftFuzzy(x, y)
        end)
        :ToTable()

    if #frames <= 1 then
        return {
            Horizontal = 0,
            Vertical = 0,
        }
    end

    local first = frames[1]
    local second = frames[2]
    local vertical = first:GetBottom() - second:GetTop()

    return {
        Horizontal = 0,
        Vertical = vertical,
    }
end

local function RequestSort()
    for _, callback in ipairs(sortCallbacks) do
        callback(M)
    end
end

local function OnUpdateFrames()
    RequestSort()
end

function M:Name()
    return "GladiusEx"
end

function M:Enabled()
    return wow.GetAddOnEnableState("GladiusEx") ~= 0
end

function M:Init()
    if not M:Enabled() then
        return
    end

    if not GladiusEx then
        fsLog:Error("GladiusEx table is missing.")
    end

    if not GladiusEx.UpdateFrames then
        fsLog:Error("Unable to hook GladiusEx:UpdateFrames.")
        return
    end

    wow.hooksecurefunc(GladiusEx, "UpdateFrames", OnUpdateFrames)
end

function M:RegisterRequestSortCallback(callback)
    if not callback then
        fsLog:Error("GladiusEx:RegisterRequestSortCallback() - callback must not be nil.")
        return
    end

    sortCallbacks[#sortCallbacks + 1] = callback
end

function M:RegisterContainersChangedCallback() end

function M:Containers()
    local containers = {}

    if not M:Enabled() then
        return containers
    end

    if GladiusExPartyFrame then
        ---@type FrameContainer
        local party = {
            Frame = GladiusExPartyFrame,
            Type = fsFrame.ContainerType.Party,
            LayoutType = fsFrame.LayoutType.Soft,
            Spacing = function()
                return CalculateSpace(GladiusExPartyFrame)
            end,
        }

        containers[#containers + 1] = party
    end

    if GladiusExArenaFrame then
        ---@type FrameContainer
        local arena = {
            Frame = GladiusExArenaFrame,
            Type = fsFrame.ContainerType.EnemyArena,
            LayoutType = fsFrame.LayoutType.Soft,
            Spacing = function()
                return CalculateSpace(GladiusExArenaFrame)
            end,
        }

        containers[#containers + 1] = arena
    end

    return containers
end
