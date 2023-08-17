---@type FrameProvider
return {
    Frames = {},
    Callbacks = {},
    Name = function()
        return "Test"
    end,
    Init = function() end,
    Enabled = function()
        return true
    end,
    GetUnit = function(_, frame)
        return frame.unit
    end,
    RaidFrames = function(self)
        return self.Frames
    end,
    RaidGroups = function()
        return {}
    end,
    PartyFrames = function(self)
        return self.Frames
    end,
    ShowPartyPets = function()
        return false
    end,
    ShowRaidPets = function()
        return false
    end,
    IsRaidGrouped = function()
        return false
    end,
    EnemyArenaFrames = function(self)
        return self.Frames
    end,
    RaidGroupMembers = function()
        return {}
    end,
    RegisterCallback = function(self, callback)
        self.Callbacks[#self.Callbacks + 1] = callback
    end,
    FireCallbacks = function(self)
        for _, callback in ipairs(self.Callbacks) do
            callback(self)
        end
    end,
}
