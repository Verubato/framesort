---@type string, Addon
local _, addon = ...
local fsEnumerable = addon.Collections.Enumerable
local fsProviders = addon.Providers
local fsLog = addon.Logging.Log
local fsScheduler = addon.Scheduling.Scheduler

function fsProviders:Enabled()
    return fsEnumerable
        :From(fsProviders.All)
        :Where(function(provider)
            return provider:Enabled()
        end)
        :ToTable()
end

function fsProviders:Init()
    for _, provider in pairs(fsProviders.All) do
        provider:Init()
    end

    fsLog:Debug("Initialised the providers module.")

    fsScheduler:RunWhenEnteringWorld(function()
        for _, provider in pairs(fsProviders.All) do
            if provider:Enabled() then
                fsLog:Debug("Detected the '" .. provider:Name() .. "' frame addon is enabled.")
            end
        end
    end)
end
