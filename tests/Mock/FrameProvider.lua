local wow = require("Mock\\WoW")

---@type FrameProvider
local provider = {
    State = {
        Callbacks = {},
        Containers = {}
    },
    Name = function()
        return "Test"
    end,
    Init = function() end,
    Enabled = function()
        return true
    end,
    Containers = function(self)
        return self.State.Containers
    end,
    RegisterRequestSortCallback = function(self, callback)
        self.State.Callbacks[#self.State.Callbacks + 1] = callback
    end,
    RegisterContainersChangedCallback = function(_, _) end,
    FireCallbacks = function(self)
        for _, callback in ipairs(self.State.Callbacks) do
            callback(self)
        end
    end,
}

---@diagnostic disable-next-line: inject-field
function provider:Reset()
    self.State.Callbacks = {}

    ---@type FrameContainer
    local party = {
        Frame = assert(wow.CompactPartyFrame),
        -- TODO: reference named values from addon.WoW.Frame
        -- party
        Type = 1,
        -- hard
        LayoutType = 2,
        SupportsSpacing = true,
        IsHorizontalLayout = function() return nil end,
        SupportsGrouping = function() return nil end,
        FramesOffset = function() return nil end,
        GroupFramesOffset = function() return nil end,
    }

    local raid = {
        Frame = assert(wow.CompactRaidFrameContainer),
        -- TODO: reference named values from addon.WoW.Frame
        -- raid
        Type = 2,
        -- hard
        LayoutType = 2,
        SupportsSpacing = true,
        IsHorizontalLayout = function() return nil end,
        SupportsGrouping = function() return nil end,
        FramesOffset = function() return nil end,
        GroupFramesOffset = function() return nil end,
    }

    local arena = {
        Frame = assert(wow.CompactArenaFrame),
        -- TODO: reference named values from addon.WoW.Frame
        -- arena
        Type = 3,
        -- hard
        LayoutType = 2,
        SupportsSpacing = true,
        IsHorizontalLayout = function() return nil end,
        SupportsGrouping = function() return nil end,
        FramesOffset = function() return nil end,
        GroupFramesOffset = function() return nil end,
    }

    self.State.Containers = {
        party,
        raid,
        arena
    }
end

provider:Reset()

return provider
