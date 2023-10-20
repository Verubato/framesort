---@type string, Addon
local _, addon = ...
local fsProviders = addon.Providers
local fsScheduler = addon.Scheduling.Scheduler
local M = addon.Modules

local function OnProviderRequiresSort(provider)
    M:Run(provider)
end

function M:Run(provider)
    fsScheduler:RunWhenCombatEnds(function()
        -- run hide player first as it may impact sorting
        addon.Modules.HidePlayer:Run()

        -- run sorting next as it impacts targeting and macros
        addon.Modules.Sorting:Run(provider)

        addon.Modules.Targeting:Run()
        addon.Modules.Macro:Run()
    end, "Runner")
end

---Initialises all modules.
function M:Init()
    addon.Modules.HidePlayer:Init()
    addon.Modules.Sorting:Init()
    addon.Modules.Targeting:Init()
    addon.Modules.Macro:Init()

    for _, provider in ipairs(fsProviders.All) do
        provider:RegisterRequestSortCallback(OnProviderRequiresSort)
    end

    fsScheduler:RunWhenEnteringWorld(function() M:Run() end)
end
