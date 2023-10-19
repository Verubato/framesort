---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsLog = addon.Logging.Log
local fsProviders = addon.Providers
local fsScheduler = addon.Scheduling.Scheduler
local M = addon.Modules

local function Run(provider)
    local start = wow.GetTimePreciseSec()

    -- run sorting first as it affects targeting and macros
    addon.Modules.Sorting:Run(provider)
    addon.Modules.HidePlayer:Run()
    addon.Modules.Targeting:Run()
    addon.Modules.Macro:Run()

    local stop = wow.GetTimePreciseSec()
    fsLog:Debug(string.format("FrameSort took %fms to run all modules.", (stop - start) * 1000))
end

local function OnProviderRequiresSort(provider)
    Run(provider)
end

---Initialises all modules.
function M:Init()
    addon.Modules.Sorting:Init()
    addon.Modules.HidePlayer:Init()
    addon.Modules.Targeting:Init()
    addon.Modules.Macro:Init()

    for _, provider in ipairs(fsProviders.All) do
        provider:RegisterRequestSortCallback(OnProviderRequiresSort)
    end

    fsScheduler:RunWhenEnteringWorld(Run)
end
