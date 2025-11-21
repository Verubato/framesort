local frameMock = require("TestHarness\\Frame")
---@class ProviderFactory : IFactory<FrameProvider>
local M = {}

function M:Create()
    ---@type FrameProvider
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
        -- party
        Type = 1,
        -- hard
        LayoutType = 2,
        SupportsSpacing = true,
    }

    local raid = {
        Frame = frameMock:New("Raid"),
        -- raid
        Type = 2,
        -- hard
        LayoutType = 2,
        SupportsSpacing = true,
    }

    local arena = {
        Frame = frameMock:New("Arena"),
        -- arena
        Type = 3,
        -- hard
        LayoutType = 2,
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
