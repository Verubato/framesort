---@type FrameProvider
return {
    Frames = {},
    Callbacks = {},
    Reset = function(self)
        self.Frames = {}
        self.Callbacks = {}
    end,
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
    PlayerRaidFrames = function(self)
        local frames = {}
        for _, frame in ipairs(self.Frames) do
            if frame.unit == "player" then
                frames[#frames + 1] = frame
            end
        end

        return frames
    end,
    IsUsingRaidStyleFrames = function() return true end,
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
