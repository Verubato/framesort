local frameMock = require("TestHarness\\FrameMock")
---@class ProviderFactory
local M = {}

local layoutSoft = 1
local layoutHard = 2

local typeParty = 1
local typeRaid = 2
local typeArena = 3

---@return FrameProvider
function M:Create(layoutType)
    local provider = {
        State = {
            Callbacks = {},
            Containers = {},
        },
        Name = function()
            return "Test"
        end,
        Init = function() end,
        Enabled = function()
            return true
        end,
        Containers = function(me)
            return me.State.Containers
        end,
        RegisterRequestSortCallback = function(me, callback)
            me.State.Callbacks[#me.State.Callbacks + 1] = callback
        end,
        RegisterContainersChangedCallback = function(_, _) end,
        FireCallbacks = function(me)
            for _, callback in ipairs(me.State.Callbacks) do
                callback(me)
            end
        end,
    }

    ---@type FrameContainer
    local party = {
        Frame = frameMock:New("Party"),
        Type = typeParty,
        LayoutType = layoutType or layoutHard,
        SupportsSpacing = true,
    }

    local raid = {
        Frame = frameMock:New("Raid"),
        Type = typeRaid,
        LayoutType = layoutType or layoutHard,
        SupportsSpacing = true,
    }

    local arena = {
        Frame = frameMock:New("Arena"),
        Type = typeArena,
        LayoutType = layoutType or layoutHard,
        SupportsSpacing = true,
    }

    provider.State.Containers = {
        party,
        raid,
        arena,
    }

    return provider
end

return M
