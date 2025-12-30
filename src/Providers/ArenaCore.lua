---@type string, Addon
local _, addon = ...
local fsProviders = addon.Providers
local wowEx = addon.WoW.WowEx
local M = {}

fsProviders.ArenaCore = M
table.insert(fsProviders.All, M)

-- arena core sorts frames itself
-- this is provider just exists for logging purposes
function M:Name()
    return "Arena Core"
end

function M:Enabled()
    return wowEx.IsAddOnEnabled("ArenaCore")
end

function M:RegisterRequestSortCallback() end

function M:RegisterContainersChangedCallback() end

function M:Containers()
    return {}
end

function M:Init() end
